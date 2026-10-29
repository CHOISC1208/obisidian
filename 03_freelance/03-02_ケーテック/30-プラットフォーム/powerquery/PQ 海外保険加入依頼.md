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

親: [[30-プラットフォーム/powerquery/Power Query MOC|Power Query MOC]] ／ 共通の前提: [[30-プラットフォーム/powerquery/Power Query 基本方針|基本方針]]

> [!info] 概要
> 申請リスト「海外保険加入依頼」(内部名 `OverseasInsurance`)の取得とリネーム。出典 `03_overseas-insurance.xml`(2026-10-29)。
> XML から機械生成したもの。**テナントでの取得は未検証**。

## M コード

```
let
  ソース = SharePoint.Tables("https://ktec19950401.sharepoint.com/sites/s-portal_ver11.0.7", [Implementation = null, ApiVersion = 15]),
  リスト = ソース{[Title = "海外保険加入依頼"]}[Items],
  必要列 = Table.SelectColumns(リスト, {"ID","Title","Applicant","RequestDate","ApplicantDepartment","Status","Approver","ApprovedAt","ApproverComment","ApprovalMessage","TravelerName","TravelerEmployeeRef","TravelerFullName","TravelerLastNameRoman","TravelerFirstNameRoman","TravelerEmail","TravelerBirthDate","TravelerGender","Destination","TravelPurpose","DepartureDate","ReturnDate","Companions","LeaderApprover","IsRetroactive","Created"}),
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
  })
in
  列名変更
```

## 注意

- 「見つかりません」になったら `[Title = "海外保険加入依頼"]` を `[Name = "OverseasInsurance"]` に変える。
- Person / Lookup 列はリネームのみ(展開は未検証)。
