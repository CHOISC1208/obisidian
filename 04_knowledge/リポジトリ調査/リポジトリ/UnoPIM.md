---
title: UnoPIM
tags:
  - type/リポジトリ
  - topic/OSS調査
repo: unopim/unopim
url: https://github.com/unopim/unopim
stars: 11k
language: PHP（Laravel 13）
last_pushed: 2026-09-29
license: MIT
status: README読了（コード未読）
created: 2026-09-30
updated: 2026-09-30
info_freshness: 2026-09-30 時点。★・更新日は GitHub、概要は README、ディレクトリは GitHub API で確認
---

# UnoPIM

親: [[リポジトリ調査 MOC]] ／ 分類: [[リポジトリ調査 - マスタ・在庫・PSI]]

[unopim/unopim](https://github.com/unopim/unopim) ／ ★11k ／ PHP（Laravel 13） ／ 最終更新 2026-09-29 ／ **MIT**

商品情報管理（PIM）とデジタルアセット管理（DAM）のプラットフォーム。商品データとアセットを1か所に集め、整備して配信先へ渡す。

## READMEの要点

- **属性**による商品情報の拡張、**チャネル**と**ロケール**（33言語）の切り替え
- **完成度（Completeness）**：チャネルごとに商品データの充足度を測る
- CSV／XLSX／ZIP のインポート・エクスポート（進捗トラッカー付き）
- REST API（Postman コレクションあり）と Webhook
- **Publication Channels**：整えた商品データを配信先へキューで送り、チャネルごとのペイロードと配信記録を残す
- AI による商品コンテンツ生成、自然言語での商品操作

## 効く課題

商品コード衝突（[[03 概念が重なるテーブルと型]]）と、[[PRJ-01-商品マスタ構築]]。**内部の商品と、チャネルごとの出し分けを分けて持つ**考え方。

## 読む場所

- `packages/Webkul/Attribute/`（属性）
- `packages/Webkul/Product/`（商品）
- `packages/Webkul/Completeness/`（完成度）
- `packages/Webkul/Publication/`（配信）
- `packages/Webkul/DataTransfer/`（取込・出力）

## 注意

- PHP／Laravel 製。設計の参考として読む
- AI 機能（MagicAI、AiAgent）は今回の関心の外

## 次に読むもの

Attribute と Product のマイグレーションから、商品・属性・チャネルの関係を確認する

## 読書メモ

（コードを読んだら書く）
