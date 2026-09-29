---
title: Odoo
tags:
  - type/リポジトリ
  - topic/OSS調査
repo: odoo/odoo
url: https://github.com/odoo/odoo
stars: 55k
language: Python
last_pushed: 2026-09-29
license: LICENSE ファイル要確認（GitHub は判定なし。README に記載なし）
status: README読了（コード未読）
created: 2026-09-30
updated: 2026-09-30
info_freshness: 2026-09-30 時点。★・更新日は GitHub、概要は README、ディレクトリは GitHub API で確認
---

# Odoo

親: [[リポジトリ調査 MOC]] ／ 分類: [[リポジトリ調査 - マスタ・在庫・PSI]]

[odoo/odoo](https://github.com/odoo/odoo) ／ ★55k ／ Python ／ 最終更新 2026-09-29 ／ **LICENSE ファイル要確認（GitHub は判定なし。README に記載なし）**

CRM、Web サイト、EC、倉庫管理、プロジェクト、会計、POS、人事、製造などを含む業務アプリ群。単独でも、組み合わせて ERP としても使える。

## READMEの要点

- アプリ単位（`addons/`）で機能を分け、必要なものだけ入れる
- `stock` アプリに、移動（`stock_move`）、在庫数量（`stock_quant`）、ロット、ピッキング、倉庫、補充ルール（`stock_orderpoint`）などのモデルがある

## 効く課題

**在庫の持ち方**：現在庫を `stock_quant`、動きを `stock_move`／`stock_move_line` に分ける構造は、PSI の在庫・入出庫の設計の参考になる。

## 読む場所

- `addons/stock/models/stock_quant.py`（在庫数量）
- `addons/stock/models/stock_move.py`／`stock_move_line.py`（動き）
- `addons/stock/models/stock_orderpoint.py`（補充点）
- `addons/stock/models/stock_lot.py`（ロット）
- `addons/product/`（商品）

## 注意

- 極めて巨大。**`addons/stock` と `addons/product` だけ**
- ライセンスは LICENSE と COPYRIGHT を読んで確認する（コミュニティ版と Enterprise 版の区分がある）

## 次に読むもの

`stock_quant` と `stock_move` の関係を追う

## 読書メモ

（コードを読んだら書く）
