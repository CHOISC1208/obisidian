---
tags:
  - ケーテック
  - プラットフォーム
  - PowerQuery
client: ケーテック株式会社
created: 2026-10-29
updated: 2026-10-29
---

# PQ 従業員マスタ

親: [[30-プラットフォーム/powerquery/Power Query MOC|Power Query MOC]] ／ 共通の前提: [[30-プラットフォーム/powerquery/Power Query 基本方針|基本方針]]

> [!info] 概要
> マスタリスト「従業員マスタ」(内部名 `EmployeeMaster`)の取得とリネーム。出典 `17_employee-master.xml`(2026-10-29)。
> XML から機械生成したもの。**テナントでの取得は未検証**。

## M コード

```
let
  ソース = SharePoint.Tables("https://ktec19950401.sharepoint.com/sites/s-portal_ver11.0.7", [Implementation = null, ApiVersion = 15]),
  リスト = ソース{[Title = "従業員マスタ"]}[Items],
  必要列 = Table.SelectColumns(リスト, {"ID","Title","EmployeeNo","FamilyName","GivenName","EmployeeUser","EmployeeDepartment","HireDate","EmploymentType","Grade","Position","Gender","EnrollmentStatus","RetirementDate","RehireDate","RehireEndDate","RegularizationDate","ContractEmployeeNo","ContractHireDate","PayType","LastNameRoman","FirstNameRoman","EmployeeEmail","BirthDate","Created"}),
  列名変更 = Table.RenameColumns(必要列, {
    {"ID", "ID"},
    {"Title", "氏名"},
    {"EmployeeNo", "従業員番号"},
    {"FamilyName", "氏"},
    {"GivenName", "名"},
    {"EmployeeUser", "テナントユーザー名"},
    {"EmployeeDepartment", "主部署"},
    {"HireDate", "入社日"},
    {"EmploymentType", "雇用形態"},
    {"Grade", "グレード・等級"},
    {"Position", "役職・職位"},
    {"Gender", "性別"},
    {"EnrollmentStatus", "在籍状況"},
    {"RetirementDate", "退職日"},
    {"RehireDate", "再雇用日"},
    {"RehireEndDate", "再雇用退職予定日"},
    {"RegularizationDate", "正社員転換日"},
    {"ContractEmployeeNo", "契約社員時の社員番号"},
    {"ContractHireDate", "契約社員時の入社日"},
    {"PayType", "給与支給形態"},
    {"LastNameRoman", "氏名(姓)※半角ローマ字"},
    {"FirstNameRoman", "氏名(名)※半角ローマ字"},
    {"EmployeeEmail", "メールアドレス"},
    {"BirthDate", "生年月日"},
    {"Created", "作成日時"}
  })
in
  列名変更
```

## 注意

- 「見つかりません」になったら `[Title = "従業員マスタ"]` を `[Name = "EmployeeMaster"]` に変える。
- Person / Lookup 列はリネームのみ(展開は未検証)。
