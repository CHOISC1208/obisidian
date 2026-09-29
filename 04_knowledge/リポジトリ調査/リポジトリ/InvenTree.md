---
title: InvenTree
tags:
  - type/リポジトリ
  - topic/OSS調査
repo: inventree/InvenTree
url: https://github.com/inventree/InvenTree
stars: 7.7k
language: Python
last_pushed: 2026-09-29
license: MIT
status: README読了（コード未読）
created: 2026-09-30
updated: 2026-09-30
info_freshness: 2026-09-30 時点。★・更新日は GitHub、概要は README、ディレクトリは GitHub API で確認
---

# InvenTree

親: [[リポジトリ調査 MOC]] ／ 分類: [[リポジトリ調査 - マスタ・在庫・PSI]]

[inventree/InvenTree](https://github.com/inventree/InvenTree) ／ ★7.7k ／ Python ／ 最終更新 2026-09-29 ／ **MIT**

低レベルの在庫管理と部品トラッキングを提供するオープンソース。Python／Django の DB バックエンドが管理画面と REST API を持つ。

## READMEの要点

- Django、DRF、Django Q（バックグラウンド処理）、Allauth（認証）
- DB は PostgreSQL／MySQL／MariaDB／SQLite
- 拡張手段：REST API、Python モジュール、**プラグイン**インターフェース
- ドキュメント（docs.inventree.org）とデモサイトあり
- `AGENTS.md`／`CLAUDE.md` が付属

## 効く課題

部品（品目）・在庫・発注の**モデルの分け方**。ERPNext より軽く、`part`／`stock`／`order` の3つに整理されている。原材料マスタ（[[原材料マスタの整備]]）や在庫ロットの参考。

## 読む場所

- `src/backend/InvenTree/part/`（部品マスタ）
- `src/backend/InvenTree/stock/`（在庫）
- `src/backend/InvenTree/order/`（発注・受注）
- `src/backend/InvenTree/company/`（取引先）
- `src/backend/InvenTree/plugin/`（拡張の仕組み）

## 注意

- MIT ライセンスで、今回の候補のなかでは最も条件がゆるい
- 電子部品・製造向けの色が強く、食品ロット・賞味期限の扱いは別途確認が必要

## 次に読むもの

`part/models.py` の主要フィールドと `stock/models.py` の StockItem を読む

## 読書メモ

（コードを読んだら書く）
