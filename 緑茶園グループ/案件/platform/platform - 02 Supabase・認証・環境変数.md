---
tags:
  - 緑茶園
  - 案件
  - platform
  - 統合調査
  - Supabase
  - 認証
client: 緑茶園グループ
created: 2026-09-14
updated: 2026-09-15
---

# Supabase・認証・環境変数

親: [[platform - 00 概要]]

## Supabase プロジェクトは同一

**結論：両リポジトリとも `ryokuchaen`（ref `tphdmbhufxcpdifxxvzl`）を使っている。** 別プロジェクトではない。

| 根拠 | inventory | EC |
|---|---|---|
| `.env.local` の `NEXT_PUBLIC_SUPABASE_URL` | `https://tphdmbhufxcpdifxxvzl.supabase.co` | `https://tphdmbhufxcpdifxxvzl.supabase.co` |
| DB 接続ユーザー | `postgres.tphdmbhufxcpdifxxvzl`（Session pooler） | —（DB 直結しない） |
| README の記述 | 「同じ Supabase プロジェクトのログインユーザーでそのまま入れる」「`public` スキーマは EC Channel Console が使用中のため分離した」 | 「専用プロジェクト前提」で短いテーブル名にした（**前提はすでに崩れている**） |
| 実DB（MCP で確認） | `inventory` スキーマに17テーブル＋3ビュー | `public` スキーマに7テーブル＋5ビュー |

プロジェクトの詳細：東京リージョン（ap-northeast-1）、PostgreSQL 17（17.6.1.166）、2026-09-03 作成。
同じ Organization には `green-earth-platform`（vault の `GreenEarth/` 側の別案件）と `common` もあるが、どちらのリポジトリからも参照していない。

### スキーマと件数（2026-09-14）

| スキーマ | テーブル（行数） | ビュー | 持ち主 |
|---|---|---|---|
| `public` | `multi_channel_order_fetcher`（6）／`multi_channel_order_fetcher_logs`（76）／`order_backlog_snapshots`（1）／`order_backlog_lines`（3,211）／`manual_order_batches`（2）／`manual_order_lines`（15）／`manual_order_sku_map`（0） | `v_backlog_by_sku` `v_backlog_by_date` `v_backlog_by_jun` `v_backlog_overdue` `v_manual_order_lines_current` | EC |
| `inventory` | `partners`（35）／規格マスタ8種／`tax_rates`（2）／`products`（2,894）／`product_prices`（487）／`marketplace_codes`（0）／`payment_statements`（80）／`transactions`（5,924）／`audit_logs`（20）／`migration_issues`（328） | `v_statement_totals` `v_products_needing_review` `v_migration_issues_open` | 仕入 |

- **RLS**：両スキーマの全テーブルで有効・**ポリシーは0件**。service_role と Postgres 直結（テーブル所有者）からしか見えない
- **ビュー**：8本すべて `security_invoker=true`（2026-09-12 に是正済み）

> [!success] 2026-09-14 決定：同じプロジェクトを使い続け、EC は `public` から新スキーマへ移す
> `public` は原則使わない。移動先の名前・改名するテーブル・切り替え手順は → [[platform - 05 統合方針（決定事項と設計）]] の1章・6章

> [!warning] 2026-09-15 判明：上の表の `public` の7テーブル・5ビューは、2026-09-14 22:31 JST に `multi_channel_order_fetcher` スキーマへ移されている
> 履歴 `20260914133154 move_public_objects_to_multi_channel_order_fetcher_schema`（どのリポジトリにもファイルは無い）。件数は変わっていない。意図どおりの移動と確認済み → [[platform - 05 統合方針（決定事項と設計）]] の1章

## マイグレーション履歴がリポジトリと合っていない

本番の `supabase_migrations` に記録されている履歴：

| version | name | 対応するリポジトリのファイル |
|---|---|---|
| `20260903125649` | `create_credentials_and_logs_tables` | **どこにも無い**（EC README は「ダッシュボードで手動作成、DDL化されていない」と書いているが、履歴には載っている） |
| `20260912144225` | `create_inventory_schema` | inventory `20260912010000_inventory_schema.sql`（**version が違う**） |
| `20260912145132` | `inventory_schema_aligned_with_design` | 同上のファイルに統合済みと思われる（ファイルは1本だけ） |
| `20260912150909` | `views_security_invoker` | EC `0003_views_security_invoker.sql`（ファイル名の体系が違う） |

履歴に**無い**もの：EC の `0001_backlog.sql`・`0002_manual_orders.sql`。README どおり SQL Editor で手で流しているため、テーブルは本番にあるが履歴に残っていない。

> [!danger] inventory のマイグレーションは先頭で `drop schema if exists inventory cascade;` している
> POC 中の「作り直し前提」の書き方。統合リポジトリで `supabase db reset` や再適用の運用に乗せると、本番の仕入データ（取引5,924件・支払明細書80件）が消える。統合時は**本番の現状からベースラインを取り直す**必要がある。

命名体系も違う：EC は `0001_` の連番、inventory は Supabase CLI 形式のタイムスタンプ。

## 環境変数

| 変数 | inventory | EC | 備考 |
|---|---|---|---|
| `NEXT_PUBLIC_SUPABASE_URL` | ✅ 使う（Auth） | ✅ 使う（Auth・`proxy.ts`） | **EC の `.env.local.example` に無い**。例には `SUPABASE_URL` しか無く、例から作るとログインが動かない（実 `.env.local` には入っている） |
| `NEXT_PUBLIC_SUPABASE_ANON_KEY` | ✅ | ✅ | inventory の例は `sb_publishable_...`（新形式）だが、実 `.env.local` は両方とも**同じ長さの旧 JWT 形式** |
| `SUPABASE_URL` | ⚪ `.env.local` にあるが未使用 | ✅ `lib/supabase.ts`（無ければ `NEXT_PUBLIC_` を使う） | |
| `SUPABASE_SERVICE_ROLE_KEY` | ⚪ `.env.local` にあるが未使用（例では「使わない」と明記） | ✅ 必須 | 旧 JWT 形式 |
| `SUPABASE_DB_HOST` / `_PORT` / `_USER` / `_PASSWORD` / `_NAME` | ✅ 必須（アプリと抽出） | — | 実値は `aws-0-ap-northeast-1.pooler.supabase.com:5432`（Session pooler）。`config.ts` のエラーメッセージは `aws-1-` と書いていて食い違う（軽微） |
| `SUPABASE_DB_URL` / `DATABASE_URL` | 分割指定が無いときの代替 | — | |
| `AIRTABLE_API_KEY`（別名 `AIRTABLE_PAT`）/ `AIRTABLE_BASE_ID` / `OUTPUT_DIR` | 抽出スクリプトのみ | — | 統合後はアプリ本体に不要 |
| `EC_MOCK_TEST_EMAIL` / `EC_MOCK_TEST_PASSWORD` | — | `test:mock` のみ | Auth に専用アカウントが要る |
| `EC_MOCK_API_BASE_URL` / `EC_DIST_DIR` | — | `dev:mock`・`test:mock` のみ | 本番では無効化される |
| チャネル認証情報（`RAKUTEN_*` など） | — | **環境変数ではない**。DB の `multi_channel_order_fetcher`（key/value）に保存し、`registry.ts` の許可リストのキーだけ書ける | |

**必要な接続の種類が違う**のが本質的な差。inventory は「DB パスワード」、EC は「service_role キー」を秘密情報として持つ。統合アプリはデータアクセスの方式を決めるまで、**両方を抱える**ことになる。

## 認証（Supabase Auth）

### 共通点（ほぼ同一コード）

- メール＋パスワード。ログイン画面（Client Component）から `signInWithPassword`
- `@supabase/ssr` の Cookie セッション。`lib/auth/server.ts`・`lib/auth/client.ts` はコメント以外ほぼ同一
- `proxy.ts`（Next.js 16 で `middleware` から改名）で `getUser()` し、未ログインなら `/login` へ。matcher も同一
- 自己サインアップ画面は無い。ユーザーは管理側で作る運用
- **同じプロジェクトなので Cookie 名も同じ**（`sb-tphdmbhufxcpdifxxvzl-auth-token`）。localhost ではポートが違っても Cookie は共有されるため、片方でログインするともう片方にも入れる

### 相違点

| | inventory | EC |
|---|---|---|
| 未ログインで `/api/*` | （API が無い） | **401 JSON** を返す（fetch がHTMLを読んで壊れないように） |
| `Authorization: Bearer` | 受け付けない | 受け付ける（`test:mock` 用） |
| ルート・処理ごとの認証 | Server Action の先頭で **`requireUser()` を必ず呼ぶ**（POSTで直接呼べるため） | Route Handler 側では確認しない（「proxy.ts で保護されているので不要」と README に明記） |
| ユーザーIDの記録 | `audit_logs.changed_by`（20件中20件に入っている）、`transactions.created_by`（アプリ入力分の1件） | `imported_by` 列はあるが**一度も入っていない**（`order_backlog_snapshots` 1件中0、`manual_order_batches` 2件中0）。コードで `getUser()` を呼んでいない |
| サイドバーのメール表示 | あり | なし |

### 実ユーザー（2026-09-14）

`auth.users` は **3名**。全員メール認証で、直近30日以内にログインしている。

> [!warning] 2026-09-15 確認：3件のうち1件は人ではない
> `test-bot@multi-channel-order-fetcher.local` は EC の `test:mock` 用のアカウント。人は superuser と `info@yamagata-elab.com` の2名。`app_metadata`・`user_metadata` に role を持つユーザーは**0名**。

> [!warning] 権限の区別がどこにも無い
> どちらのアプリも「ログインしているか」しか見ていない。統合すると、受注を見るためにログインした人が**支払明細書の発行・取り消し**も**モールのAPIキーの上書き**もできる状態になる。今は利用者が3名で問題が表に出ていないだけ。
>
> あわせて、**ダッシュボードの「新規サインアップを許可」がオフになっているかは未確認**（MCP では Auth 設定を読めない）。anon キーはブラウザに渡る公開キーなので、この設定がオンだと画面が無くても API から直接サインアップでき、ロールが無い以上そのまま全機能に入れる。→ [[08 要確認事項]] に積む候補
