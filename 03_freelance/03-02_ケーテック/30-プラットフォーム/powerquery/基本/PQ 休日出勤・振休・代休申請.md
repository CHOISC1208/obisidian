---
tags:
  - ケーテック
  - プラットフォーム
  - PowerQuery
client: ケーテック株式会社
created: 2026-10-29
updated: 2026-10-29
---

# PQ 休日出勤・振休・代休申請

親: [[30-プラットフォーム/powerquery/Power Query MOC|Power Query MOC]] ／ 共通の前提: [[30-プラットフォーム/powerquery/基本/Power Query 基本方針|基本方針]]

> [!info] 概要
> 申請リスト「休日出勤/振休/代休申請」(内部名 `HolidayWorkRequests`)の取得とリネーム。出典 `19_holiday-work.xml`(2026-10-29)。
> XML から機械生成したもの。**テナントでの取得は未検証**。

## M コード

```
let
  ソース = SharePoint.Tables("https://ktec19950401.sharepoint.com/sites/s-portal_ver11.0.7", [Implementation = null, ApiVersion = 15]),
  JST = (x) => DateTime.From(x) + #duration(0, 9, 0, 0),
  人名 = (v) =>
    let 一人 = (r) => if r is record then Record.FieldOrDefault(r, "Title", Record.FieldOrDefault(r, "DisplayName", null)) else r
    in if v = null then null else if v is list then Text.Combine(List.Transform(v, 一人), "、") else 一人(v),
  リスト = ソース{[Title = "休日出勤/振休/代休申請"]}[Items],
  必要列 = Table.SelectColumns(リスト, {"ID","Title","Applicant","RequestDate","ApplicantDepartment","Status","Approver","ApprovedAt","ApproverComment","ApprovalMessage","LeaderApprover","RecordType","WorkDate","WorkStartTime","WorkEndTime","CompensatoryType","CompensatoryDate","Created"}, MissingField.UseNull),
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
    {"LeaderApprover", "1次承認者(リーダー)"},
    {"RecordType", "予定/実績区分"},
    {"WorkDate", "休日出勤日"},
    {"WorkStartTime", "休日出勤時間(開始)"},
    {"WorkEndTime", "休日出勤時間(終了)"},
    {"CompensatoryType", "振休/代休区分"},
    {"CompensatoryDate", "振休/代休取得日"},
    {"Created", "作成日時"}
  }),

  // 日時はUTCで返るため+9時間(JST)にしてから型変換。日付のみの列は日付型にする
  日時変換 = Table.TransformColumns(列名変更, {
    {"申請日", each if _ = null then null else Date.From(JST(_)), type date},
    {"承認日時", each if _ = null then null else DateTime.From(JST(_)), type datetime},
    {"休日出勤日", each if _ = null then null else Date.From(JST(_)), type date},
    {"振休/代休取得日", each if _ = null then null else Date.From(JST(_)), type date},
    {"作成日時", each if _ = null then null else DateTime.From(JST(_)), type datetime}
  }),

  // Person列(Record)を氏名の文字列にする
  人名変換 = Table.TransformColumns(日時変換, {{"申請者", 人名, type text}, {"承認者", 人名, type text}, {"1次承認者(リーダー)", 人名, type text}}),

  型変換 = Table.TransformColumnTypes(人名変換, {{"ID", Int64.Type}, {"件名", type text}, {"所属部署", type text}, {"ステータス", type text}, {"承認コメント", type text}, {"承認メッセージ", type text}, {"予定/実績区分", type text}, {"休日出勤時間(開始)", type text}, {"休日出勤時間(終了)", type text}, {"振休/代休区分", type text}})
in
  型変換
```

## 注意

- 「見つかりません」になったら `[Title = "休日出勤/振休/代休申請"]` を `[Name = "HolidayWorkRequests"]` に変える。
- Person列は氏名の文字列に変換済み(下の注を参照)。Lookup列は Record のまま。
