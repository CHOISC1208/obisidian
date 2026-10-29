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

親: [[30-プラットフォーム/powerquery/Power Query MOC|Power Query MOC]] ／ 共通の前提: [[30-プラットフォーム/powerquery/基本/Power Query 基本方針|基本方針]]

> [!info] 概要
> マスタリスト「従業員マスタ」(内部名 `EmployeeMaster`)の取得とリネーム。出典 `17_employee-master.xml`(2026-10-29)。
> XML から機械生成したもの。**テナントでの取得は未検証**。

## M コード

```
let
  ソース = SharePoint.Tables("https://ktec19950401.sharepoint.com/sites/s-portal_ver11.0.7", [Implementation = null, ApiVersion = 15]),
  JST = (x) => DateTime.From(x) + #duration(0, 9, 0, 0),
  人名 = (v) =>
    let 一人 = (r) => if r is record then Record.FieldOrDefault(r, "Title", Record.FieldOrDefault(r, "DisplayName", null)) else r
    in if v = null then null else if v is list then Text.Combine(List.Transform(v, 一人), "、") else 一人(v),
  リスト = ソース{[Title = "従業員マスタ"]}[Items],
  必要列 = Table.SelectColumns(リスト, {"ID","Title","EmployeeNo","FamilyName","GivenName","EmployeeUser","EmployeeDepartment","HireDate","EmploymentType","Grade","Position","Gender","EnrollmentStatus","RetirementDate","RehireDate","RehireEndDate","RegularizationDate","ContractEmployeeNo","ContractHireDate","PayType","LastNameRoman","FirstNameRoman","EmployeeEmail","BirthDate","Created"}, MissingField.UseNull),
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
  }),

  // 日時はUTCで返るため+9時間(JST)にしてから型変換。日付のみの列は日付型にする
  日時変換 = Table.TransformColumns(列名変更, {
    {"入社日", each if _ = null then null else Date.From(JST(_)), type date},
    {"退職日", each if _ = null then null else Date.From(JST(_)), type date},
    {"再雇用日", each if _ = null then null else Date.From(JST(_)), type date},
    {"再雇用退職予定日", each if _ = null then null else Date.From(JST(_)), type date},
    {"正社員転換日", each if _ = null then null else Date.From(JST(_)), type date},
    {"契約社員時の入社日", each if _ = null then null else Date.From(JST(_)), type date},
    {"生年月日", each if _ = null then null else Date.From(JST(_)), type date},
    {"作成日時", each if _ = null then null else DateTime.From(JST(_)), type datetime}
  }),

  // Person列(Record)を氏名の文字列にする
  人名変換 = Table.TransformColumns(日時変換, {{"テナントユーザー名", 人名, type text}}),

  型変換 = Table.TransformColumnTypes(人名変換, {{"ID", Int64.Type}, {"氏名", type text}, {"従業員番号", type number}, {"氏", type text}, {"名", type text}, {"主部署", type text}, {"雇用形態", type text}, {"グレード・等級", type text}, {"役職・職位", type text}, {"性別", type text}, {"在籍状況", type text}, {"契約社員時の社員番号", type text}, {"給与支給形態", type text}, {"氏名(姓)※半角ローマ字", type text}, {"氏名(名)※半角ローマ字", type text}, {"メールアドレス", type text}})
in
  型変換
```

## 注意

- 「見つかりません」になったら `[Title = "従業員マスタ"]` を `[Name = "EmployeeMaster"]` に変える。
- Person列は氏名の文字列に変換済み(下の注を参照)。Lookup列は Record のまま。
