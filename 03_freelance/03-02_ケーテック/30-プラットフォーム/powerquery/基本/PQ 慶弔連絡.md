---
tags:
  - ケーテック
  - プラットフォーム
  - PowerQuery
client: ケーテック株式会社
created: 2026-10-29
updated: 2026-10-29
---

# PQ 慶弔連絡

親: [[30-プラットフォーム/powerquery/Power Query MOC|Power Query MOC]] ／ 共通の前提: [[30-プラットフォーム/powerquery/基本/Power Query 基本方針|基本方針]]

> [!info] 概要
> 申請リスト「慶弔連絡」(内部名 `KeichoReports`)の取得とリネーム。出典 `02_keicho-report.xml`(2026-10-29)。
> XML から機械生成したもの。**テナントでの取得は未検証**。

## M コード

```
let
  ソース = SharePoint.Tables("https://ktec19950401.sharepoint.com/sites/s-portal_ver11.0.7", [Implementation = null, ApiVersion = 15]),
  JST = (x) => DateTime.From(x) + #duration(0, 9, 0, 0),
  人名 = (v) =>
    let 一人 = (r) => if r is record then Record.FieldOrDefault(r, "Title", Record.FieldOrDefault(r, "DisplayName", null)) else r
    in if v = null then null else if v is list then Text.Combine(List.Transform(v, 一人), "、") else 一人(v),
  リスト = ソース{[Title = "慶弔連絡"]}[Items],
  必要列 = Table.SelectColumns(リスト, {"ID","Title","Applicant","RequestDate","ApplicantDepartment","Status","Approver","ApprovedAt","ApproverComment","ApprovalMessage","LeaderApprover","EmployeeMasterRef","InitiatorType","TargetEmployee","RequestType","TargetPerson","EmploymentType","YearsOfService","IsSecondMarriage","SpouseName","HasCeremony","CeremonyDate","VenueName","ChildName","ChildNameKana","ChildRelationship","DeceasedName","IsWorkRelated","Diagnosis","Symptoms","ReturnToWorkDate","EventDate","Remarks","PlannedAmount","Created"}, MissingField.UseNull),
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
    {"EmployeeMasterRef", "対象者(従業員台帳から検索)"},
    {"InitiatorType", "起票区分"},
    {"TargetEmployee", "対象者(代理申請)"},
    {"RequestType", "制度種別"},
    {"TargetPerson", "対象者"},
    {"EmploymentType", "雇用形態"},
    {"YearsOfService", "勤続年数"},
    {"IsSecondMarriage", "入社後2回目以降の結婚"},
    {"SpouseName", "配偶者氏名"},
    {"HasCeremony", "挙式あり"},
    {"CeremonyDate", "挙式日"},
    {"VenueName", "結婚式場名"},
    {"ChildName", "子女氏名/お子様のお名前"},
    {"ChildNameKana", "子女氏名(フリガナ)"},
    {"ChildRelationship", "お子様の続柄"},
    {"DeceasedName", "死亡者氏名"},
    {"IsWorkRelated", "対象(業務上の傷病)"},
    {"Diagnosis", "病名"},
    {"Symptoms", "症状"},
    {"ReturnToWorkDate", "出社予定日"},
    {"EventDate", "事実発生日"},
    {"Remarks", "備考"},
    {"PlannedAmount", "支給予定額"},
    {"Created", "作成日時"}
  }),

  // 日時はUTCで返るため+9時間(JST)にしてから型変換。日付のみの列は日付型にする
  日時変換 = Table.TransformColumns(列名変更, {
    {"申請日", each if _ = null then null else Date.From(JST(_)), type date},
    {"承認日時", each if _ = null then null else DateTime.From(JST(_)), type datetime},
    {"挙式日", each if _ = null then null else Date.From(JST(_)), type date},
    {"出社予定日", each if _ = null then null else Date.From(JST(_)), type date},
    {"事実発生日", each if _ = null then null else Date.From(JST(_)), type date},
    {"作成日時", each if _ = null then null else DateTime.From(JST(_)), type datetime}
  }),

  // Person列(Record)を氏名の文字列にする
  人名変換 = Table.TransformColumns(日時変換, {{"申請者", 人名, type text}, {"承認者", 人名, type text}, {"1次承認者(リーダー)", 人名, type text}, {"対象者(代理申請)", 人名, type text}}),

  型変換 = Table.TransformColumnTypes(人名変換, {{"ID", Int64.Type}, {"件名", type text}, {"所属部署", type text}, {"ステータス", type text}, {"承認コメント", type text}, {"承認メッセージ", type text}, {"起票区分", type text}, {"制度種別", type text}, {"対象者", type text}, {"雇用形態", type text}, {"勤続年数", type number}, {"入社後2回目以降の結婚", type logical}, {"配偶者氏名", type text}, {"挙式あり", type logical}, {"結婚式場名", type text}, {"子女氏名/お子様のお名前", type text}, {"子女氏名(フリガナ)", type text}, {"お子様の続柄", type text}, {"死亡者氏名", type text}, {"対象(業務上の傷病)", type logical}, {"病名", type text}, {"症状", type text}, {"備考", type text}, {"支給予定額", Currency.Type}})
in
  型変換
```

## 注意

- 「見つかりません」になったら `[Title = "慶弔連絡"]` を `[Name = "KeichoReports"]` に変える。
- Person列は氏名の文字列に変換済み(下の注を参照)。Lookup列は Record のまま。
