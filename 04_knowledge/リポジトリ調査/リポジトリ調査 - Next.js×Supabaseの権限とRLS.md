---
title: リポジトリ調査 - Next.js×Supabaseの権限とRLS
tags:
  - type/調査
  - topic/OSS調査
  - topic/Supabase
created: 2026-09-30
updated: 2026-09-30
source: GitHub検索
info_freshness: 2026-09-30 時点（★・更新日）
---

# Next.js × Supabase の権限モデル・RLS・認証構成

親: [[リポジトリ調査 MOC]]

## 効く課題

[[platform - 00 概要]] の障害「**権限モデルが無い。ログインできれば誰でも全機能**」「データアクセス層が2系統（`pg` 直結と `supabase-js` service_role）」。

## 候補

| リポジトリ | ★ | 学べること |
|---|---|---|
| [[supabase examples\|supabase/supabase]] の `examples/` | 110k | 公式の Next.js + `@supabase/ssr` 実例。`proxy.ts`・認証まわりの答え合わせ |
| [[burhan-platform\|Ibrahem3/burhan-platform]] | 108 | Supabase + PostgreSQL RLS のマルチテナントSaaS（**Nuxt 4** 構成）。4段階ロール、DBトリガーでのプラン上限、APIキーのAES-256-GCM暗号化保管まで実装 |
| [[pgrls\|pgrls/pgrls]] | 27 | RLS静的解析。68ルールが「RLSの落とし穴集」になる。`pgrls generate` でRLSの雛形も作れる |
| [[database-sentinel\|Farenhytee/database-sentinel]] | 45 | RLS設定ミス・鍵露出を監査する Claude Skill。service_role 運用の点検に使える |
| [[next-saas-stripe-starter\|mickasmt/next-saas-stripe-starter]] | 3.0k | Next.js 16 でのロール・組織・管理画面の構成（Supabase ではなく Drizzle + Neon） |

## 使い方

1. burhan-platform で「ロール → RLSポリシー」の対応を見る
2. pgrls / database-sentinel で**自分のスキーマ**（`public` と `inventory`）を点検する
3. 「受注を見る人」「支払明細書を発行する人」「APIキーを書き換える人」の権限分離に落とす

## 注意

- burhan-platform は小規模でフロントも異なる。**考え方を見る用途**で、流用はしない
- 「Supabase × Next.js」の topic 検索は大型プラットフォームが上位を占めてノイズが多かった。キーワード検索も0件が多く、上表は topic（`row-level-security` ほか）から拾った
- ライセンス・品質は未確認
