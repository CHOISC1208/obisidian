---
tags:
  - ケーテック
  - プラットフォーム
  - PowerQuery
client: ケーテック株式会社
created: 2026-10-29
updated: 2026-10-29
---

# PQ 昼食申込

親: [[30-プラットフォーム/powerquery/Power Query MOC|Power Query MOC]] ／ 共通の前提: [[30-プラットフォーム/powerquery/基本/Power Query 基本方針|基本方針]]

> [!info] 概要
> 申請リスト「昼食申込」(内部名 `LunchOrders`)の取得とリネーム。出典 `06_lunch-order.xml`(2026-10-29)。
> XML から機械生成したもの。**テナントでの取得は未検証**。

## M コード

```
let
  ソース = SharePoint.Tables("https://ktec19950401.sharepoint.com/sites/s-portal_ver11.0.7", [Implementation = null, ApiVersion = 15]),
  JST = (x) => DateTime.From(x) + #duration(0, 9, 0, 0),
  人名 = (v) =>
    let 一人 = (r) => if r is record then Record.FieldOrDefault(r, "Title", Record.FieldOrDefault(r, "DisplayName", null)) else r
    in if v = null then null else if v is list then Text.Combine(List.Transform(v, 一人), "、") else 一人(v),
  参照値 = (v) =>
    let 一件 = (r) => if r is record
          then (let 他 = Record.RemoveFields(r, {"Id"}, MissingField.Ignore)
                in Record.FieldOrDefault(他, "Value", Record.FieldOrDefault(他, "Title", List.First(Record.FieldValues(他), null))))
          else r
    in if v = null then null else if v is list then Text.Combine(List.Transform(v, each Text.From(一件(_))), "、") else Text.From(一件(v)),
  リスト = ソース{[Title = "昼食申込"]}[Items],
  必要列 = Table.SelectColumns(リスト, {"ID","Title","Applicant","RequestDate","ApplicantDepartment","Status","Approver","ApprovedAt","ApproverComment","ApprovalMessage","SubmissionMode","OrderDate","PeriodStartDate","PeriodEndDate","OrderType","DinerName","MenuItem","Quantity","CostDepartment","Amount","Created"}, MissingField.UseNull),
  列名変更 = Table.RenameColumns(必要列, {
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
    {"MenuItem", "メニュー"},
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

  // 参照列(Lookup)を表示値(ShowField)の文字列にする
  参照変換 = Table.TransformColumns(人名変換, {{"メニュー", 参照値, type text}}),

  型変換 = Table.TransformColumnTypes(参照変換, {{"ID", Int64.Type}, {"件名", type text}, {"所属部署", type text}, {"ステータス", type text}, {"承認コメント", type text}, {"承認メッセージ", type text}, {"申込方法", type text}, {"区分", type text}, {"利用者氏名", type text}, {"数量", type number}, {"費用負担部署", type text}, {"金額", Currency.Type}})
in
  型変換
```

## 注意

- 「見つかりません」になったら `[Title = "昼食申込"]` を `[Name = "LunchOrders"]` に変える。
- Person列は氏名、Lookup列は表示値の文字列に変換済み(基本方針の「Person列と Lookup列」を参照)。
