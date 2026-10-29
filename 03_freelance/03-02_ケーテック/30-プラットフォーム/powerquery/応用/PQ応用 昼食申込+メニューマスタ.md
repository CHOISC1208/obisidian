---
tags:
  - ケーテック
  - プラットフォーム
  - PowerQuery
client: ケーテック株式会社
created: 2026-10-29
updated: 2026-10-29
---

# PQ応用 昼食申込+メニューマスタ

親: [[30-プラットフォーム/powerquery/Power Query MOC|Power Query MOC]] ／ 元のクエリ: [[30-プラットフォーム/powerquery/基本/PQ 昼食申込]]・[[30-プラットフォーム/powerquery/基本/PQ メニューマスタ]]

> [!info] 概要
> 昼食申込の `MenuItem`(メニューマスタへの参照列)は、そのままだと ID(数字)や Record でしか見えない。
> メニューマスタを結合して、**メニュー名・注文パターン・ご飯の量・価格**を昼食の行に付ける。
> **テナントでの取得は未検証**(参照列の返り方が数値か Record かは実機で確認していない)。

## 方針

- 他のクエリを参照せず、**1クエリで自己完結**させる(ファイルを他人に共有するため)。
- 結合キーは、昼食側は `MenuItem` から取り出した ID、マスタ側は `ID`。
- 外部結合は**左外部**。メニューが削除済みでも昼食の行を落とさない(その行はメニュー名が `null` になる)。
- マスタの `Title` は結合後に昼食の `Title`(件名)と衝突するため、先に `メニュー名` へ改名してから結合する。

## M コード

```
let
  ソース = SharePoint.Tables("https://ktec19950401.sharepoint.com/sites/s-portal_ver11.0.7", [Implementation = null, ApiVersion = 15]),
  JST = (x) => DateTime.From(x) + #duration(0, 9, 0, 0),
  人名 = (v) =>
    let 一人 = (r) => if r is record then Record.FieldOrDefault(r, "Title", Record.FieldOrDefault(r, "DisplayName", null)) else r
    in if v = null then null else if v is list then Text.Combine(List.Transform(v, 一人), "、") else 一人(v),

  // 昼食申込
  昼食 = Table.SelectColumns(ソース{[Title = "昼食申込"]}[Items], {"ID","Title","Applicant","RequestDate","ApplicantDepartment","Status","Approver","ApprovedAt","ApproverComment","ApprovalMessage","SubmissionMode","OrderDate","PeriodStartDate","PeriodEndDate","OrderType","DinerName","MenuItem","Quantity","CostDepartment","Amount","Created"}),

  // メニューマスタ(結合用に必要な列だけ。列名は結合後に衝突しないよう先に変える)
  メニュー = Table.RenameColumns(
    Table.SelectColumns(ソース{[Title = "メニューマスタ"]}[Items], {"ID","Title","MealPattern","RiceSize","Price"}),
    {{"ID","メニューID"},{"Title","メニュー名"},{"MealPattern","注文パターン"},{"RiceSize","ご飯の量"},{"Price","価格"}}),

  // MenuItem(参照列)からメニューマスタの ID を取り出す。Record で返る場合と数値で返る場合の両方に対応
  メニューID取得 = Table.AddColumn(昼食, "メニューID",
    each if Value.Is([MenuItem], type record) then Record.FieldOrDefault([MenuItem], "Id", null) else [MenuItem], Int64.Type),
  参照列を削除 = Table.RemoveColumns(メニューID取得, {"MenuItem"}),

  // 左外部結合(メニューが削除されていても昼食の行は残す)
  結合 = Table.NestedJoin(参照列を削除, {"メニューID"}, メニュー, {"メニューID"}, "メニュー", JoinKind.LeftOuter),
  展開 = Table.ExpandTableColumn(結合, "メニュー", {"メニュー名","注文パターン","ご飯の量","価格"}),

  列名変更 = Table.RenameColumns(展開, {
    {"ID", "ID"},
    {"Title", "件名"},
    {"Applicant", "申請者"},
    {"RequestDate", "申請日"},
    {"ApplicantDepartment", "所属部署"},
    {"Status", "ステータス"},
    {"Approver", "承認者"},
    {"ApprovedAt", "承認日時"},
    {"ApproverComment", "承認コメント"},
    {"ApprovalMessage", "承認メッセージ"},
    {"SubmissionMode", "申込方法"},
    {"OrderDate", "喫食日"},
    {"PeriodStartDate", "対象期間(開始)"},
    {"PeriodEndDate", "対象期間(終了)"},
    {"OrderType", "区分"},
    {"DinerName", "利用者氏名"},
    {"Quantity", "数量"},
    {"CostDepartment", "費用負担部署"},
    {"Amount", "金額"},
    {"Created", "作成日時"}
  }),

  // 日時はUTCで返るため+9時間(JST)にしてから型変換。日付のみの列は日付型にする
  日時変換 = Table.TransformColumns(列名変更, {
    {"申請日", each if _ = null then null else Date.From(JST(_)), type date},
    {"承認日時", each if _ = null then null else DateTime.From(JST(_)), type datetime},
    {"喫食日", each if _ = null then null else Date.From(JST(_)), type date},
    {"対象期間(開始)", each if _ = null then null else Date.From(JST(_)), type date},
    {"対象期間(終了)", each if _ = null then null else Date.From(JST(_)), type date},
    {"作成日時", each if _ = null then null else DateTime.From(JST(_)), type datetime}
  }),

  // Person列(Record)を氏名の文字列にする
  人名変換 = Table.TransformColumns(日時変換, {{"申請者", 人名, type text}, {"承認者", 人名, type text}}),

  型変換 = Table.TransformColumnTypes(人名変換, {{"ID", Int64.Type}, {"件名", type text}, {"所属部署", type text}, {"ステータス", type text}, {"承認コメント", type text}, {"承認メッセージ", type text}, {"申込方法", type text}, {"区分", type text}, {"利用者氏名", type text}, {"数量", type number}, {"費用負担部署", type text}, {"金額", Currency.Type}, {"価格", Currency.Type}})
in
  型変換
```

## 確認ポイント

- `メニューID` が全部 `null` になる: `MenuItem` の返り方が想定と違う。ステップ「メニューID取得」の直前で `MenuItem` の中身を確認し、
  Record のフィールド名が `Id` でなければ直す。
- 「`Title = "メニューマスタ"` が見つかりません」: `[Name = "MenuMaster"]` に変える。
- 価格は昼食申込側の `金額`(=価格×数量、フロー設定)とは別。`価格`はマスタの現在の単価で、後から単価を変えると過去の行の `価格` も変わる。
