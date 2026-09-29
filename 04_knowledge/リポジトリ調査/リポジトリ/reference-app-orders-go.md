---
title: reference-app-orders-go
tags:
  - type/リポジトリ
  - topic/OSS調査
repo: temporalio/reference-app-orders-go
url: https://github.com/temporalio/reference-app-orders-go
stars: 84
language: Go
last_pushed: 2026-09-25
license: MIT
status: README読了（コード未読）
created: 2026-09-30
updated: 2026-09-30
info_freshness: 2026-09-30 時点。★・更新日は GitHub、概要は README、ディレクトリは GitHub API で確認
---

# reference-app-orders-go

親: [[リポジトリ調査 MOC]] ／ 分類: [[リポジトリ調査 - EC受注管理（OMS）]]

[temporalio/reference-app-orders-go](https://github.com/temporalio/reference-app-orders-go) ／ ★84 ／ Go ／ 最終更新 2026-09-25 ／ **MIT**

Temporal のワークフローで**注文処理**を組んだ参考実装（Go）。注文、請求、出荷、不正検知を別のワークフローに分ける。

## READMEの要点

- Workflow／Activity を Worker が実行し、状態は Temporal サービスが履歴として保持（クラッシュしても復元して再開）
- REST API サーバーと Web アプリ付き。ローカル実行も Kubernetes も可能
- 作者による4本立ての解説動画シリーズあり

## 効く課題

受注取得の**失敗時リトライ・再実行**、注文の状態遷移を「状態の更新」でなく「処理の履歴」として持つ考え方。

## 読む場所

- `order/`（注文）
- `billing/`（請求）
- `shipment/`（出荷）
- `fraud/`（不正検知）
- `docs/README.md`（設計解説。最初に読む）

## 注意

- Temporal 基盤が前提。**Vercel + Supabase の構成にそのまま持ち込めるものではない**。考え方を学ぶ用途
- Go 製

## 次に読むもの

`docs/README.md` を読んで、注文のワークフロー分割を確認する

## 読書メモ

（コードを読んだら書く）
