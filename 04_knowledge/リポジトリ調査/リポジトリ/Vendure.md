---
title: Vendure
tags:
  - type/リポジトリ
  - topic/OSS調査
repo: vendurehq/vendure
url: https://github.com/vendurehq/vendure
stars: 8.5k
language: TypeScript
last_pushed: 2026-09-29
license: GPLv3（README 記載。GitHub の判定は NOASSERTION）
status: README読了（コード未読）
created: 2026-09-30
updated: 2026-09-30
info_freshness: 2026-09-30 時点。★・更新日は GitHub、概要は README、ディレクトリは GitHub API で確認
---

# Vendure

親: [[リポジトリ調査 MOC]] ／ 分類: [[リポジトリ調査 - EC受注管理（OMS）]]

[vendurehq/vendure](https://github.com/vendurehq/vendure) ／ ★8.5k ／ TypeScript ／ 最終更新 2026-09-29 ／ **GPLv3（README 記載。GitHub の判定は NOASSERTION）**

Node.js／NestJS／GraphQL のヘッドレスコマース基盤。**プラグイン優先**で、コア改変なしに拡張できる設計。

## READMEの要点

- カタログ・注文・顧客・プロモーション・チャネル・税・配送・決済・在庫を標準で持つ
- サービスの差し替えとプラグイン契約で、独自エンティティや価格ロジックを追加
- D2C／B2B／マーケットプレイス／オムニチャネルを1つのバックエンドで扱う
- 管理画面は React ＋ TanStack。`npx @vendure/create my-shop` で雛形を作れる
- 対応DB：PostgreSQL、MySQL、MariaDB、SQLite

## 効く課題

TypeScript 一貫の構成なので、緑茶園の Next.js／TypeScript スタックと読み方が近い。**注文のステート遷移**と**チャネル**の設計、プラグイン境界の切り方の参考。

## 読む場所

- `packages/core/`（`@vendure/core` 本体）
- `packages/dashboard/`（管理画面）
- `packages/*-plugin/`（公式プラグイン。拡張の実例）
- `e2e-common/`（テスト基盤）

## 注意

- ライセンスは GPLv3（README のバッジ）。商用ライセンスの案内もあり、**利用形態によって条件が変わる**
- 全体を読まず、注文まわりのサービスとプラグイン境界だけに絞る

## 次に読むもの

注文ステートの定義箇所を探す（`packages/core` 内）

## 読書メモ

（コードを読んだら書く）
