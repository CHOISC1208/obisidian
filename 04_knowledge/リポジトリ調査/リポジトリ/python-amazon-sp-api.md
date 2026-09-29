---
title: python-amazon-sp-api
tags:
  - type/リポジトリ
  - topic/OSS調査
repo: saleweaver/python-amazon-sp-api
url: https://github.com/saleweaver/python-amazon-sp-api
stars: 681
language: Python
last_pushed: 2026-09-29
license: MIT
status: README読了（コード未読）
created: 2026-09-30
updated: 2026-09-30
info_freshness: 2026-09-30 時点。★・更新日は GitHub、概要は README、ディレクトリは GitHub API で確認
---

# python-amazon-sp-api

親: [[リポジトリ調査 MOC]] ／ 分類: [[リポジトリ調査 - EC受注管理（OMS）]]

[saleweaver/python-amazon-sp-api](https://github.com/saleweaver/python-amazon-sp-api) ／ ★681 ／ Python ／ 最終更新 2026-09-29 ／ **MIT**

Amazon Selling Partner API の Python ラッパー。Orders、Reports、Feeds、Data Kiosk などを簡易に呼べる。

## READMEの要点

- `Orders().get_orders(CreatedAfter=...)` のように受注を取得（`LastUpdatedAfter` での差分取得も可）
- PII を含む注文情報は Restricted Data Token を渡して取得
- httpx ベースの同期クライアントと、`sp_api.asyncio` の非同期クライアント
- AWS Secrets Manager での認証情報管理にも対応（extras）

## 効く課題

[[Amazon - SP-API 受注リファレンス]] の認証（LWA）・受注取得・PII の扱いを、実装で答え合わせする。

## 読む場所

- `sp_api/api/orders/`（受注取得）
- `sp_api/base/`（認証・共通処理・例外）
- `docs/`（Read the Docs の元）
- `llms.txt`（LLM 向けの案内）

## 注意

- Python 製。緑茶園の Next.js からは直接使えない。**仕様の確認用**
- README に「本番での PII は Restricted Data Token が必要」とある。取得範囲の設計時に確認する

## 次に読むもの

JS 版 [[amazon-sp-api（jrl84）]] と、レート制限・リトライの扱いを比べる

## 読書メモ

（コードを読んだら書く）
