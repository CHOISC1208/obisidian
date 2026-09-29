---
title: Saleor
tags:
  - type/リポジトリ
  - topic/OSS調査
repo: saleor/saleor
url: https://github.com/saleor/saleor
stars: 23k
language: Python
last_pushed: 2026-09-29
license: BSD-3-Clause
status: README読了（コード未読）
created: 2026-09-30
updated: 2026-09-30
info_freshness: 2026-09-30 時点。★・更新日は GitHub、概要は README、ディレクトリは GitHub API で確認
---

# Saleor

親: [[リポジトリ調査 MOC]] ／ 分類: [[リポジトリ調査 - EC受注管理（OMS）]]

[saleor/saleor](https://github.com/saleor/saleor) ／ ★23k ／ Python ／ 最終更新 2026-09-29 ／ **BSD-3-Clause**

GraphQL ネイティブの **API 専用（ヘッドレス）コマース基盤**。画面は別リポジトリ（Dashboard）で、Storefront は自由に作る。

## READMEの要点

- 多通貨・多言語・**多倉庫**（README の表現は “multi-warehouse, tutti multi”）
- 注文モデルが柔軟（分割支払い、複数倉庫、返品）
- プロモーション（セール、バウチャー、カートルール、ギフトカード）
- 決済のオーケストレーション（複数ゲートウェイ、拡張可能な決済 API）
- Apps：iframe で管理画面を任意のスタックで拡張
- CMS 機能、翻訳、SEO

## 効く課題

**チャネル**（販路ごとに価格・在庫・販売可否を分ける）、**注文と出荷のステータス遷移**、**Variant と SKU**、**Warehouse／Stock／Allocation**（在庫引当）。[[受注機能（旧 EC Channel Console）]] のデータモデルと [[03 概念が重なるテーブルと型]] の参考。

## 読む場所

- `saleor/channel/`
- `saleor/order/`
- `saleor/warehouse/`
- `saleor/product/`（`models.py` に Product／ProductVariant）
- `saleor/attribute/`
- `saleor/checkout/`
- `saleor/webhook/`／`saleor/app/`（外部連携）
- `docs/`／`AGENTS.md`

## 注意

- **BSD-3-Clause**：今回の候補のなかで、流用を含め最も自由度が高い
- **導入する製品ではない**。Saleor は「自社で売る」側で、こちらは「他モールの受注を取り込む」側
- 規模が大きい。上記ディレクトリに絞る

## 次に読むもの

`channel` と `order` のモデルを読み、[[受注機能（旧 EC Channel Console）]] のテーブルと対応表を作る

## 読書メモ

（コードを読んだら書く）
