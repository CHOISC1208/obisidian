---
tags:
  - ケーテック
  - プラットフォーム
  - PowerQuery
client: ケーテック株式会社
created: 2026-10-29
updated: 2026-10-29
---

# PQ 営業日カレンダー

親: [[30-プラットフォーム/powerquery/Power Query MOC|Power Query MOC]] ／ 共通の前提: [[30-プラットフォーム/powerquery/Power Query 基本方針|基本方針]]

> [!info] 概要
> マスタリスト「営業日カレンダー」(内部名 `BusinessCalendar`)の取得とリネーム。出典 `14_business-calendar.xml`(2026-10-29)。
> XML から機械生成したもの。**テナントでの取得は未検証**。

## M コード

```
let
  ソース = SharePoint.Tables("https://ktec19950401.sharepoint.com/sites/s-portal_ver11.0.7", [Implementation = null, ApiVersion = 15]),
  リスト = ソース{[Title = "営業日カレンダー"]}[Items],
  必要列 = Table.SelectColumns(リスト, {"ID","Title","HolidayDate","HolidayType","Created"}),
  列名変更 = Table.RenameColumns(必要列, {
    {"ID", "ID"},
    {"Title", "名称"},
    {"HolidayDate", "日付"},
    {"HolidayType", "区分"},
    {"Created", "作成日時"}
  })
in
  列名変更
```

## 注意

- 「見つかりません」になったら `[Title = "営業日カレンダー"]` を `[Name = "BusinessCalendar"]` に変える。
- Person / Lookup 列はリネームのみ(展開は未検証)。
