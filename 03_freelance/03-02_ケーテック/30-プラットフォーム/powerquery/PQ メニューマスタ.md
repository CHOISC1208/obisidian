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

親: [[30-プラットフォーム/powerquery/Power Query MOC|Power Query MOC]] ／ 共通の前提: [[30-プラットフォーム/powerquery/Power Query 基本方針|基本方針]]

> [!info] 概要
> マスタリスト「メニューマスタ」(内部名 `MenuMaster`)の取得とリネーム。出典 `13_menu-master.xml`(2026-10-29)。
> XML から機械生成したもの。**テナントでの取得は未検証**。

## M コード

```
let
  ソース = SharePoint.Tables("https://ktec19950401.sharepoint.com/sites/s-portal_ver11.0.7", [Implementation = null, ApiVersion = 15]),
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
  })
in
  列名変更
```

## 注意

- 「見つかりません」になったら `[Title = "メニューマスタ"]` を `[Name = "MenuMaster"]` に変える。
- Person / Lookup 列はリネームのみ(展開は未検証)。
