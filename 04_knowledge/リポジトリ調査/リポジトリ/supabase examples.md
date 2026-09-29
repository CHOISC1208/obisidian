---
title: supabase examples
tags:
  - type/リポジトリ
  - topic/OSS調査
repo: supabase/supabase
url: https://github.com/supabase/supabase
stars: 110k
language: TypeScript
last_pushed: 2026-09-29
license: Apache-2.0
status: README読了（コード未読）
created: 2026-09-30
updated: 2026-09-30
info_freshness: 2026-09-30 時点。★・更新日は GitHub、概要は README、ディレクトリは GitHub API で確認
---

# supabase examples

親: [[リポジトリ調査 MOC]] ／ 分類: [[リポジトリ調査 - Next.js×Supabaseの権限とRLS]]

[supabase/supabase](https://github.com/supabase/supabase) ／ ★110k ／ TypeScript ／ 最終更新 2026-09-29 ／ **Apache-2.0**

Supabase 本体（Postgres、認証、自動生成API、Realtime、Edge Functions、Storage、ベクトル検索）。`examples/` に各種フレームワークの連携例がある。

## READMEの要点

- 認証・認可（RLS）、REST／GraphQL、Realtime、Functions、Storage、AI／ベクトルを提供
- モノレポ（`apps/`、`packages/`、`examples/`、`docker/`、`supabase/`）
- `AGENTS.md`／`CLAUDE.md` があり、AI エージェント向けの案内も整備

## 効く課題

[[platform - 00 概要]] の **Supabase 認証・`@supabase/ssr`・`proxy.ts`** の公式流儀との答え合わせ。

## 読む場所

- `examples/`（Next.js 系の認証例）
- `packages/`（クライアント周辺）
- `docker/`（セルフホスト構成）

## 注意

- 本体が巨大。**`examples/` の Next.js 認証例だけ**を見る
- 公式ドキュメント（supabase.com/docs）の方が最新のことが多い

## 次に読むもの

Next.js 認証例の `proxy.ts` に相当するファイルを、自分の実装と比べる

## 読書メモ

（コードを読んだら書く）
