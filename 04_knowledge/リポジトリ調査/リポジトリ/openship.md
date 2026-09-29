---
title: openship
tags:
  - type/リポジトリ
  - topic/OSS調査
repo: openshiporg/openship
url: https://github.com/openshiporg/openship
stars: 1.6k
language: TypeScript
last_pushed: 2026-08-25
license: AGPL-3.0
status: README読了（コード未読）
created: 2026-09-30
updated: 2026-09-30
info_freshness: 2026-09-30 時点。★・更新日は GitHub、概要は README、ディレクトリは GitHub API で確認
---

# openship

親: [[リポジトリ調査 MOC]] ／ 分類: [[リポジトリ調査 - EC受注管理（OMS）]]

[openshiporg/openship](https://github.com/openshiporg/openship) ／ ★1.6k ／ TypeScript ／ 最終更新 2026-08-25 ／ **AGPL-3.0**

販売先（shop）から受けた注文を、出荷を担う先（channel）へ自動で振り分ける**注文ルーター**。ドロップシッピング／3PL連携が主な用途。

## READMEの要点

- Shop（注文の発生元。Shopify、WooCommerce、カスタムAPI、Webhook）と Channel（注文の履行先。供給元のShopify、3PL、メール、Google Sheets、Webhook）の2軸で接続を管理
- Shop と Channel の商品を**マッチング**する機能（バリアント単位、一括、例外ルール）
- 注文のリアルタイム同期、失敗時のリトライ、注文履歴
- Keystone（GraphQL）＋ Prisma ＋ Next.js の構成。Vercel／Railway／Docker にデプロイ可能

## 効く課題

[[受注機能（旧 EC Channel Console）]] のモール（発生元）と後続処理（履行先）の**抽象化**、および [[03 概念が重なるテーブルと型]] の**商品マッチング**（外部SKUと内部商品の対応表）の参考。

## 読む場所

- `features/integrations/`（Shop／Channel 連携のアダプタ）
- `features/keystone/`（データモデルとスキーマ）
- `schema.prisma`／`schema.graphql`／`migrations/`
- `OPENFRONT-INTEGRATION.md`／`OAUTH_FLOW.md`（連携の設計メモ）

## 注意

- **用途が想定と違う**：当初は「複数モールの受注を集約する」ものと見ていたが、README では販売先→履行先へ**振り分けるルーター**（ドロップシッピング前提）。モール受注の**取り込み**とは向きが違う
- **AGPL-3.0**：改変してネットワーク越しに提供するとソース公開義務が生じる。コード流用は不可と考え、設計の参考にとどめる
- README にデモ環境の認証情報が載っている（ここには転記しない）

## 次に読むもの

[[Saleor]] のチャネル設計と見比べる

## 読書メモ

（コードを読んだら書く）
