---
tags:
  - ケーテック
  - プラットフォーム
  - PowerQuery
client: ケーテック株式会社
created: 2026-10-29
updated: 2026-10-29
---

# PQ 海外保険加入依頼

親: [[30-プラットフォーム/powerquery/Power Query MOC|Power Query MOC]] ／ 共通の前提: [[30-プラットフォーム/powerquery/基本/Power Query 基本方針|基本方針]]

> [!info] 概要
> 申請リスト「海外保険加入依頼」(内部名 `OverseasInsurance`)の取得とリネーム。出典 `03_overseas-insurance.xml`(2026-10-29)。
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
  リスト = ソース{[Title = "海外保険加入依頼"]}[Items],
  必要列 = Table.SelectColumns(リスト, {"ID","Title","Applicant","RequestDate","ApplicantDepartment","Status","Approver","ApprovedAt","ApproverComment","ApprovalMessage","TravelerName","TravelerEmployeeRef","TravelerFullName","TravelerLastNameRoman","TravelerFirstNameRoman","TravelerEmail","TravelerBirthDate","TravelerGender","Destination","TravelPurpose","DepartureDate","ReturnDate","Companions","LeaderApprover","IsRetroactive","Created"}, MissingField.UseNull),
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
    {"TravelerName", "渡航者(旧・Person)"},
    {"TravelerEmployeeRef", "渡航者の従業員番号"},
    {"TravelerFullName", "渡航者氏名"},
    {"TravelerLastNameRoman", "氏名(姓)※半角ローマ字"},
    {"TravelerFirstNameRoman", "氏名(名)※半角ローマ字"},
    {"TravelerEmail", "メールアドレス"},
    {"TravelerBirthDate", "生年月日"},
    {"TravelerGender", "性別"},
    {"Destination", "渡航先"},
    {"TravelPurpose", "渡航目的"},
    {"DepartureDate", "出発日"},
    {"ReturnDate", "帰宅日"},
    {"Companions", "同行者"},
    {"LeaderApprover", "1次承認者(リーダー)"},
    {"IsRetroactive", "事後申請(緊急時の後追い)"},
    {"Created", "作成日時"}
  }),

  // 日時はUTCで返るため+9時間(JST)にしてから型変換。日付のみの列は日付型にする
  日時変換 = Table.TransformColumns(列名変更, {
    {"申請日", each if _ = null then null else Date.From(JST(_)), type date},
    {"承認日時", each if _ = null then null else DateTime.From(JST(_)), type datetime},
    {"生年月日", each if _ = null then null else Date.From(JST(_)), type date},
    {"出発日", each if _ = null then null else Date.From(JST(_)), type date},
    {"帰宅日", each if _ = null then null else Date.From(JST(_)), type date},
    {"作成日時", each if _ = null then null else DateTime.From(JST(_)), type datetime}
  }),

  // Person列(Record)を氏名の文字列にする
  人名変換 = Table.TransformColumns(日時変換, {{"申請者", 人名, type text}, {"承認者", 人名, type text}, {"渡航者(旧・Person)", 人名, type text}, {"1次承認者(リーダー)", 人名, type text}}),

  // 参照列(Lookup)を表示値(ShowField)の文字列にする
  参照変換 = Table.TransformColumns(人名変換, {{"渡航者の従業員番号", 参照値, type text}}),

  型変換 = Table.TransformColumnTypes(参照変換, {{"ID", Int64.Type}, {"件名", type text}, {"所属部署", type text}, {"ステータス", type text}, {"承認コメント", type text}, {"承認メッセージ", type text}, {"渡航者氏名", type text}, {"氏名(姓)※半角ローマ字", type text}, {"氏名(名)※半角ローマ字", type text}, {"メールアドレス", type text}, {"性別", type text}, {"渡航先", type text}, {"渡航目的", type text}, {"同行者", type text}, {"事後申請(緊急時の後追い)", type logical}})
in
  型変換
```

## 注意

- 「見つかりません」になったら `[Title = "海外保険加入依頼"]` を `[Name = "OverseasInsurance"]` に変える。
- Person列は氏名、Lookup列は表示値の文字列に変換済み(基本方針の「Person列と Lookup列」を参照)。
