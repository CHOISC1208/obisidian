---
tags:
  - ケーテック
  - プラットフォーム
  - PowerQuery
client: ケーテック株式会社
created: 2026-10-29
updated: 2026-10-29
---

# PQ 慶弔マスタ

親: [[30-プラットフォーム/powerquery/Power Query MOC|Power Query MOC]] ／ 共通の前提: [[30-プラットフォーム/powerquery/基本/Power Query 基本方針|基本方針]]

> [!info] 概要
> マスタリスト「慶弔マスタ」(内部名 `KeichoMaster`)の取得とリネーム。出典 `12_keicho-master.xml`(2026-10-29)。
> 取得とリネームまでは**実機で確認済み**。型変換(2026-10-29追加)は未検証。

## M コード

```
let
  ソース = SharePoint.Tables("https://ktec19950401.sharepoint.com/sites/s-portal_ver11.0.7", [Implementation = null, ApiVersion = 15]),
  JST = (x) => DateTime.From(x) + #duration(0, 9, 0, 0),
  リスト = ソース{[Title = "慶弔マスタ"]}[Items],
  必要列 = Table.SelectColumns(リスト, {"ID","Title","RequestType","TargetPerson","EmploymentTier","InjuryCondition","Amount","Created"}),
  列名変更 = Table.RenameColumns(必要列, {
    {"ID", "ID"},
    {"Title", "行ラベル"},
    {"RequestType", "制度種別"},
    {"TargetPerson", "対象者"},
    {"EmploymentTier", "雇用区分"},
    {"InjuryCondition", "業務上/業務上以外"},
    {"Amount", "慶弔金額"},
    {"Created", "作成日時"}
  }),

  // 日時はUTCで返るため+9時間(JST)にしてから型変換。日付のみの列は日付型にする
  日時変換 = Table.TransformColumns(列名変更, {
    {"作成日時", each if _ = null then null else DateTime.From(JST(_)), type datetime}
  }),

  型変換 = Table.TransformColumnTypes(日時変換, {{"ID", Int64.Type}, {"行ラベル", type text}, {"制度種別", type text}, {"対象者", type text}, {"雇用区分", type text}, {"業務上/業務上以外", type text}, {"慶弔金額", Currency.Type}})
in
  型変換
```

## 注意

- 「見つかりません」になったら `[Title = "慶弔マスタ"]` を `[Name = "KeichoMaster"]` に変える。
- Person / Lookup 列はリネームのみ(展開は未検証)。
