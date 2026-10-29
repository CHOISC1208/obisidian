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

親: [[30-プラットフォーム/powerquery/Power Query MOC|Power Query MOC]] ／ 共通の前提: [[30-プラットフォーム/powerquery/Power Query 基本方針|基本方針]]

> [!info] 概要
> 申請リスト「昼食申込」(内部名 `LunchOrders`)の取得とリネーム。出典 `06_lunch-order.xml`(2026-10-29)。
> XML から機械生成したもの。**テナントでの取得は未検証**。

## M コード

```
let
  ソース = SharePoint.Tables("https://ktec19950401.sharepoint.com/sites/s-portal_ver11.0.7", [Implementation = null, ApiVersion = 15]),
  リスト = ソース{[Title = "昼食申込"]}[Items],
  必要列 = Table.SelectColumns(リスト, {"ID","Title","Applicant","RequestDate","ApplicantDepartment","Status","Approver","ApprovedAt","ApproverComment","ApprovalMessage","SubmissionMode","OrderDate","PeriodStartDate","PeriodEndDate","OrderType","DinerName","MenuItem","Quantity","CostDepartment","Amount","Created"}),
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
  })
in
  列名変更
```

## 注意

- 「見つかりません」になったら `[Title = "昼食申込"]` を `[Name = "LunchOrders"]` に変える。
- Person / Lookup 列はリネームのみ(展開は未検証)。
