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

親: [[30-プラットフォーム/powerquery/Power Query MOC|Power Query MOC]] ／ 共通の前提: [[30-プラットフォーム/powerquery/Power Query 基本方針|基本方針]]

> [!info] 概要
> 申請リスト「休日出勤/振休/代休申請」(内部名 `HolidayWorkRequests`)の取得とリネーム。出典 `19_holiday-work.xml`(2026-10-29)。
> XML から機械生成したもの。**テナントでの取得は未検証**。

## M コード

```
let
  ソース = SharePoint.Tables("https://ktec19950401.sharepoint.com/sites/s-portal_ver11.0.7", [Implementation = null, ApiVersion = 15]),
  リスト = ソース{[Title = "休日出勤/振休/代休申請"]}[Items],
  必要列 = Table.SelectColumns(リスト, {"ID","Title","Applicant","RequestDate","ApplicantDepartment","Status","Approver","ApprovedAt","ApproverComment","ApprovalMessage","LeaderApprover","RecordType","WorkDate","WorkStartTime","WorkEndTime","CompensatoryType","CompensatoryDate","Created"}),
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
  })
in
  列名変更
```

## 注意

- 「見つかりません」になったら `[Title = "休日出勤/振休/代休申請"]` を `[Name = "HolidayWorkRequests"]` に変える。
- Person / Lookup 列はリネームのみ(展開は未検証)。
