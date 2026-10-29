---
tags:
  - ケーテック
  - プラットフォーム
  - PowerQuery
client: ケーテック株式会社
created: 2026-10-29
updated: 2026-10-29
---

# PQ 勤怠申請

親: [[30-プラットフォーム/powerquery/Power Query MOC|Power Query MOC]] ／ 共通の前提: [[30-プラットフォーム/powerquery/Power Query 基本方針|基本方針]]

> [!info] 概要
> 申請リスト「勤怠申請」(内部名 `LeaveRequests`)の取得とリネーム。出典 `07_leave-request.xml`(2026-10-29)。
> XML から機械生成したもの。**テナントでの取得は未検証**。

## M コード

```
let
  ソース = SharePoint.Tables("https://ktec19950401.sharepoint.com/sites/s-portal_ver11.0.7", [Implementation = null, ApiVersion = 15]),
  リスト = ソース{[Title = "勤怠申請"]}[Items],
  必要列 = Table.SelectColumns(リスト, {"ID","Title","Applicant","RequestDate","ApplicantDepartment","Status","Approver","ApprovedAt","ApproverComment","ApprovalMessage","LeaderApprover","InitiatorType","TargetEmployee","LeaveType","StartDate","EndDate","LeaveDays","Reason","SpecialLeaveDetail","StartTime","EndTime","Created"}),
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
    {"InitiatorType", "起票区分"},
    {"TargetEmployee", "対象者(代理申請)"},
    {"LeaveType", "勤怠区分"},
    {"StartDate", "取得日(開始)"},
    {"EndDate", "取得日(終了)"},
    {"LeaveDays", "取得日数"},
    {"Reason", "事由"},
    {"SpecialLeaveDetail", "内容"},
    {"StartTime", "時刻(開始)"},
    {"EndTime", "時刻(終了)"},
    {"Created", "作成日時"}
  })
in
  列名変更
```

## 注意

- 「見つかりません」になったら `[Title = "勤怠申請"]` を `[Name = "LeaveRequests"]` に変える。
- Person / Lookup 列はリネームのみ(展開は未検証)。
