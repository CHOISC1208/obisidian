---
title: GreaterWMS
tags:
  - type/リポジトリ
  - topic/OSS調査
repo: GreaterWMS/GreaterWMS
url: https://github.com/GreaterWMS/GreaterWMS
stars: 4.4k
language: Python
last_pushed: 2026-09-17
license: Apache-2.0
status: README読了（コード未読）
created: 2026-09-30
updated: 2026-09-30
info_freshness: 2026-09-30 時点。★・更新日は GitHub、概要は README、ディレクトリは GitHub API で確認
---

# GreaterWMS

親: [[リポジトリ調査 MOC]] ／ 分類: [[リポジトリ調査 - マスタ・在庫・PSI]]

[GreaterWMS/GreaterWMS](https://github.com/GreaterWMS/GreaterWMS) ／ ★4.4k ／ Python ／ 最終更新 2026-09-17 ／ **Apache-2.0**

倉庫管理システム（WMS）。入庫（ASN）、出庫（DN）、在庫、棚卸、PDA スキャンなどを備える。

## READMEの要点

- Django REST Framework ＋ Quasar（Vue）のフロント・バックエンド分離
- 業務単位でモジュール化（ASN、DN、在庫、棚位置、棚卸 など）
- 同一バックエンドを PDA・モバイル・デスクトップ・Web から使う（Quasar のビルド）
- **3.0 で中核が Bomiot（Rust 製のプラグイン基盤）上に再構築**され、開発ドキュメントも Bomiot 側へ移行

## 効く課題

入出庫・棚卸の**業務フローの分け方**。ただし Green Earth の PSI（計画）とは粒度が違い、倉庫の実務側の参考。

## 読む場所

- `asn/`（入庫）
- `dn/`（出庫）
- `cyclecount/`（棚卸）
- `goods/`、`binset/`（品目・棚位置）

## 注意

- 3.0 で基盤が Bomiot に変わったため、**リポジトリのコードと最新版の構成が一致しない可能性**がある
- README は中国語圏の利用例が中心

## 次に読むもの

優先度は低い。入出庫の項目定義を眺める程度

## 読書メモ

（コードを読んだら書く）
