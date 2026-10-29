---
tags:
  - ケーテック
  - プラットフォーム
  - PowerQuery
client: ケーテック株式会社
created: 2026-10-29
updated: 2026-10-29
---

# PQ メニューマスタ

親: [[30-プラットフォーム/powerquery/Power Query MOC|Power Query MOC]] ／ 共通の前提: [[30-プラットフォーム/powerquery/基本/Power Query 基本方針|基本方針]]

> [!info] 概要
> マスタリスト「メニューマスタ」(内部名 `MenuMaster`)の取得とリネーム。出典 `13_menu-master.xml`(2026-10-29)。
> XML から機械生成したもの。**テナントでの取得は未検証**。

## M コード

```
let
  ソース = SharePoint.Tables("https://ktec19950401.sharepoint.com/sites/s-portal_ver11.0.7", [Implementation = null, ApiVersion = 15]),
  JST = (x) => DateTime.From(x) + #duration(0, 9, 0, 0),
  リスト = ソース{[Title = "メニューマスタ"]}[Items],
  必要列 = Table.SelectColumns(リスト, {"ID","Title","MealPattern","RiceSize","Price","IsActive","Created"}),
  列名変更 = Table.RenameColumns(必要列, {
    {"ID", "ID"},
    {"Title", "メニュー名"},
    {"MealPattern", "注文パターン"},
    {"RiceSize", "ご飯の量"},
    {"Price", "価格"},
    {"IsActive", "提供中"},
    {"Created", "作成日時"}
  }),

  // 日時はUTCで返るため+9時間(JST)にしてから型変換。日付のみの列は日付型にする
  日時変換 = Table.TransformColumns(列名変更, {
    {"作成日時", each if _ = null then null else DateTime.From(JST(_)), type datetime}
  }),

  型変換 = Table.TransformColumnTypes(日時変換, {{"ID", Int64.Type}, {"メニュー名", type text}, {"注文パターン", type text}, {"ご飯の量", type text}, {"価格", Currency.Type}, {"提供中", type logical}})
in
  型変換
```

## 注意

- 「見つかりません」になったら `[Title = "メニューマスタ"]` を `[Name = "MenuMaster"]` に変える。
- Person / Lookup 列はリネームのみ(展開は未検証)。
