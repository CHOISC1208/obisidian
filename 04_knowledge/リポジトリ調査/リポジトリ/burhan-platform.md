---
title: burhan-platform
tags:
  - type/リポジトリ
  - topic/OSS調査
repo: Ibrahem3/burhan-platform
url: https://github.com/Ibrahem3/burhan-platform
stars: 108
language: Vue（Nuxt 4）
last_pushed: 2026-09-27
license: AGPL-3.0
status: コード読了（RLS・暗号化・プロビジョニング）
created: 2026-09-30
updated: 2026-09-30
info_freshness: 2026-09-30 時点。★・更新日は GitHub、概要は README、ディレクトリは GitHub API で確認
---

# burhan-platform

親: [[リポジトリ調査 MOC]] ／ 分類: [[リポジトリ調査 - Next.js×Supabaseの権限とRLS]]

[Ibrahem3/burhan-platform](https://github.com/Ibrahem3/burhan-platform) ／ ★108 ／ Vue（Nuxt 4） ／ 最終更新 2026-09-27 ／ **AGPL-3.0**

Nuxt 4 ＋ Supabase ＋ PostgreSQL RLS の**マルチテナントSaaS**。アラビア語／英語対応のコンテンツ公開基盤で、AI 執筆補助も持つ。

## READMEの要点

- **RLS でテナント分離**し、4段階のロール（`super_admin`／`owner`／`manager`／`member`）で権限を制御
- `provision_tenant` という単一トランザクションの RPC で、組織作成〜契約プラン〜メインブランチ〜所有者昇格を一括処理
- プランの上限（ブランチ数など）を **DB トリガー（`check_branch_limit`）で強制**し、API 経由の回避を防ぐ
- **BYOK**：テナントが持ち込む API キーを AES-256-GCM で暗号化して保管。SSRF 対策も実装
- マイグレーション 00001〜00021 を順に積み、`schema.sql` に統合版がある
- `ARCHITECTURE.md`／`SUPABASE.md`／`SECURITY.md` が付属

## 効く課題

**ロール別の権限分離**（受注を見る人／支払明細書を発行する人／モールのAPIキーを書き換える人）の設計例。**モールの API キーの暗号化保管**（BYOK 部分）も直接の参考になる。

## 読む場所

- `supabase/migrations/00001_initial_schema.sql`〜（RLS の積み上げ方。`00002`、`00003`、`00008`、`00011` は RLS の**修正**なので失敗例として有用）
- `supabase/migrations/00016_enforce_branch_limit.sql`（トリガーでの上限強制）
- `supabase/migrations/00018_tenant_ai_credentials.sql`／`server/utils/crypto.ts`（キーの暗号化）
- `supabase/migrations/00019_tenant_provisioning_engine.sql`（一括プロビジョニング）
- `ARCHITECTURE.md`／`SUPABASE.md`

## 注意

- **AGPL-3.0**：コード流用は不可。設計の考え方を読む
- フロントは Nuxt（Vue）。Next.js の参考にはならない。**SQL とサーバー側のロジックを読む**
- マイグレーションに RLS の修正が繰り返し入っている点は、そのまま**RLS は一度で正しく書けない**という教訓として読める

## 次に読むもの

`00001` から `00003` までの RLS の変遷を読み、[[pgrls]] にかけて指摘が出るか試す

## 読書メモ

コードを読んだ結果は [[burhan-platform - コードリーディング]] にまとめた。要点：

- RLS の修正が5本あり、**自己参照の再帰・匿名経路・`TO` 句なしポリシーの回帰・自己昇格の穴**が典型例として全部載っている
- 権限昇格は RLS だけでなく **BEFORE UPDATE トリガー**で二重に塞ぐ
- 秘密は AES-256-GCM で暗号化し、**RLS ＋ 権限全剥奪 ＋ service_role 専用**のテーブルに置く
- API ハンドラは「トークン検証 → サーバー側でロール確定 → 判定 → 入力検証」の順
