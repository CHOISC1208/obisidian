---
title: ERPNext
tags:
  - type/リポジトリ
  - topic/OSS調査
repo: frappe/erpnext
url: https://github.com/frappe/erpnext
stars: 39k
language: Python
last_pushed: 2026-09-29
license: GPL-3.0
status: README読了（コード未読）
created: 2026-09-30
updated: 2026-09-30
info_freshness: 2026-09-30 時点。★・更新日は GitHub、概要は README、ディレクトリは GitHub API で確認
---

# ERPNext

親: [[リポジトリ調査 MOC]] ／ 分類: [[リポジトリ調査 - マスタ・在庫・PSI]]

[frappe/erpnext](https://github.com/frappe/erpnext) ／ ★39k ／ Python ／ 最終更新 2026-09-29 ／ **GPL-3.0**

会計、受注管理、製造、資産管理、プロジェクトを含むオープンソースのERP。Frappe Framework 上で動く。

## READMEの要点

- 受注管理：在庫水準、補充、受注、顧客、仕入先、出荷、履行
- 製造：BOM、資材消費、能力計画、外注
- Frappe（Python／JS のフルスタック基盤）＋ Frappe UI（Vue）
- メタデータ駆動（DocType を定義するとテーブル・画面・APIが生える）

## 効く課題

**品目マスタの持ち方**：`item` に加え、`item_barcode`、`item_variant`、`item_attribute`、`item_price`、`item_supplier`、`item_customer_detail`、`item_reorder`、`item_lead_time` など**関連情報を別テーブルに分ける**構成。商品コード衝突（[[03 概念が重なるテーブルと型]]）と、PSI の在庫・補充まわりの参考。

## 読む場所

- `erpnext/stock/doctype/item/`（品目マスタ）
- `erpnext/stock/doctype/item_barcode/`、`item_variant/`、`item_attribute/`
- `erpnext/stock/doctype/item_reorder/`、`item_lead_time/`（補充・リードタイム）
- `erpnext/stock/doctype/material_request/`、`delivery_note/`

## 注意

- **GPL-3.0**
- DocType（JSON 定義）で構成されるため、SQL でなく**フィールド定義を読む**
- 巨大。`erpnext/stock/` だけを読む

## 次に読むもの

`item` の JSON 定義を読んで、必須項目と一意キーを確認する

## 読書メモ

（コードを読んだら書く）
