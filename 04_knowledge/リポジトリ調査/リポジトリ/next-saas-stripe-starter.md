---
title: next-saas-stripe-starter
tags:
  - type/リポジトリ
  - topic/OSS調査
repo: mickasmt/next-saas-stripe-starter
url: https://github.com/mickasmt/next-saas-stripe-starter
stars: 3.0k
language: TypeScript
last_pushed: 2026-09-28
license: MIT
status: README読了（コード未読）
created: 2026-09-30
updated: 2026-09-30
info_freshness: 2026-09-30 時点。★・更新日は GitHub、概要は README、ディレクトリは GitHub API で確認
---

# next-saas-stripe-starter

親: [[リポジトリ調査 MOC]] ／ 分類: [[リポジトリ調査 - Next.js×Supabaseの権限とRLS]]

[mickasmt/next-saas-stripe-starter](https://github.com/mickasmt/next-saas-stripe-starter) ／ ★3.0k ／ TypeScript ／ 最終更新 2026-09-28 ／ **MIT**

Next.js 16、Better Auth、Drizzle、Neon、Stripe による**モジュール式の SaaS スターター**。認証・組織・課金・管理画面・ドキュメント・ブログ・変更履歴を機能フラグで切り替える。

## READMEの要点

- `config/features.ts` の機能フラグで、モジュールを ON／OFF（OFF にするとルートが 404 になり、エンドポイントも拒否される）
- `pnpm modules:prune` で不要モジュールを削除（確認なしでは実行せず一覧のみ表示）
- auth（Google サインイン）／billing／admin（管理者向けユーザー管理）／docs／blog／changelog
- Drizzle スキーマ、Zod 検証、Server Actions で型を一貫
- 有料の Pro 版がある（オンボーディング、チーム、席課金）

## 効く課題

**機能フラグによるモジュール分割**は、`ryokuchaen-platform` で SSO・仕入・受注を段階的に統合するときの構成の参考になる。管理者ロールの持たせ方も見られる。

## 読む場所

- `config/features.ts`（機能フラグ）
- `modules/`
- `app/`（App Router）
- `drizzle/`（マイグレーション）
- `AGENTS.md`

## 注意

- **Supabase ではなく Neon ＋ Better Auth**。認証・DB 層はそのまま参考にならない
- 権限は「管理者かどうか」程度で、細かい RBAC は無料版にはない

## 次に読むもの

機能フラグの実装箇所を読み、[[platform - 00 概要]] のモジュール境界と比べる

## 読書メモ

（コードを読んだら書く）
