---
title: リポジトリ調査 - マスタ・在庫・PSI
tags:
  - type/調査
  - topic/OSS調査
  - topic/マスタ管理
created: 2026-09-30
updated: 2026-09-30
source: GitHub検索
info_freshness: 2026-09-30 時点（★・更新日）
---

# マスタ管理・在庫・PSI

親: [[リポジトリ調査 MOC]]

## 効く課題

- 緑茶園: [[03 概念が重なるテーブルと型]] の**商品コード衝突**（easyECS SKU と inventory `product_code` が同一文字列で別商品）
- Green Earth: [[PRJ-01-商品マスタ構築]] ／ [[PRJ-03-クラウドPSI基盤の構築]] ／ [[原材料マスタの整備]]

## 候補

| リポジトリ | ★ | 言語 | 学べること |
|---|---|---|---|
| [[ERPNext\|frappe/erpnext]] | 39k | Python | 品目マスタ（Item）・倉庫・在庫元帳。`stock/` だけ読む |
| [[InvenTree\|inventree/InvenTree]] | 7.7k | Python | 部品・在庫・ロット。品目とカテゴリの構造が整理されている |
| [[UnoPIM\|unopim/unopim]] | 11k | PHP | PIM/DAM。属性設計・内部IDと外部コードの分離 |
| [[Pimcore\|pimcore/pimcore]] | 3.9k | PHP | PIM/MDM。マスタ統合の思想 |
| [[GreaterWMS\|GreaterWMS/GreaterWMS]] | 4.4k | Python | 倉庫・入出庫・棚卸の業務フロー |
| [[Odoo\|odoo/odoo]] | 55k | Python | 巨大。`addons/stock` と `addons/product` に絞る |

## 使い方

- 商品コード衝突 → PIMの考え方（**内部IDを持ち、チャネル別の外部コードはマッピング表で紐づける**）。UnoPIM のスキーマから
- PSI の在庫モデル → ERPNext の在庫元帳（入出庫の履歴から残高を導く）

## 注意

- PSI（生産・販売・在庫の計画）そのものを扱うOSSは今回の検索では見つからなかった。`supply-chain` topic は関係の薄いセキュリティ系が大半だった。計画系は別途、数理最適化側（OR-Tools 等）で探す必要がある
