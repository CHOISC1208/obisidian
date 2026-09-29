---
title: database-sentinel
tags:
  - type/リポジトリ
  - topic/OSS調査
repo: Farenhytee/database-sentinel
url: https://github.com/Farenhytee/database-sentinel
stars: 45
language: Python
last_pushed: 2026-09-29
license: MIT
status: README読了（コード未読）
created: 2026-09-30
updated: 2026-09-30
info_freshness: 2026-09-30 時点。★・更新日は GitHub、概要は README、ディレクトリは GitHub API で確認
---

# database-sentinel

親: [[リポジトリ調査 MOC]] ／ 分類: [[リポジトリ調査 - Next.js×Supabaseの権限とRLS]]

[Farenhytee/database-sentinel](https://github.com/Farenhytee/database-sentinel) ／ ★45 ／ Python ／ 最終更新 2026-09-29 ／ **MIT**

データベースバックエンドの**セキュリティ監査**ツール。Claude Skill、読み取り専用の MCP サーバー、CLI エージェントの3形態で使える。Supabase と MongoDB に対応。

## READMEの要点

- Supabase 向けに27のアンチパターンを検出（RLS 無効、フロントへの service-role キー露出、`USING (true)`、RLS を迂回するビュー、公開された `SECURITY DEFINER` 関数、ポリシー内の `user_metadata`、公開バケットなど）
- **読み取り専用**：システムカタログのみ読み、テーブルの行データは読まない。書き込みや外部通信のプローブは任意
- 導入は `claude plugin install` の1コマンド。Cursor の MCP 導入にも対応
- 10件の正解付きケースで精度を評価するベンチマークあり

## 効く課題

緑茶園の **`service_role` 運用**（EC 側が supabase-js＋service_role）の点検。「service-role キーの露出」は直接の確認項目。

## 読む場所

- `backends/supabase/anti-patterns.md`（27パターンの一覧）
- `docs/mcp.md`（読み取り専用ロールの作り方）
- `DECISIONS.md`（設計判断の記録）

## 注意

- **本番 DB に接続して監査する**ので、必ず README の手順で読み取り専用ロールを作ってから使う
- 変更履歴に「6本の監査クエリが誤っていた」との記載がある。若いプロジェクトなので、指摘は他ツール（[[pgrls]]）とも照合する

## 次に読むもの

アンチパターン一覧だけ先に読み、自分の構成に当てはまる項目を手作業で確認する

## 読書メモ

（コードを読んだら書く）
