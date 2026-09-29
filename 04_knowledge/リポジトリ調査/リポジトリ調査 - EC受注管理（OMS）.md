---
title: リポジトリ調査 - EC受注管理（OMS）
tags:
  - type/調査
  - topic/OSS調査
  - topic/EC
created: 2026-09-30
updated: 2026-09-30
info_freshness: 2026-09-30 時点。各リポジトリの README を読んで確認済み（コードは未読）
source: GitHub検索
info_freshness: 2026-09-30 時点（★・更新日）
---

# EC・受注管理（OMS）・複数チャネル

親: [[リポジトリ調査 MOC]]

## 効く課題

[[受注機能（旧 EC Channel Console）]] の「モール別の差異を共通モデルに寄せる」「受注残ボードのステータス管理」。各モールの取得は [[Amazon - SP-API 受注リファレンス]] ほか。

## 候補

| リポジトリ | ★ | 言語 | 学べること |
|---|---|---|---|
| [[openship\|openshiporg/openship]] | 1.6k | TypeScript | **注文ルーター**。販売先（shop）の注文を履行先（channel）へ振り分ける。商品マッチングの仕組みが参考（用途は取り込みでなく振り分け。AGPL-3.0） |
| [[Vendure\|vendurehq/vendure]] | 8.5k | TypeScript | プラグイン構成、注文ステート遷移 |
| [[Saleor\|saleor/saleor]] | 23k | Python | チャネル・注文・在庫割当のデータモデル |
| [[reference-app-orders-go\|temporalio/reference-app-orders-go]] | 84 | Go | 注文処理を状態機械/ワークフローとして扱う |
| [[python-amazon-sp-api\|saleweaver/python-amazon-sp-api]] | 681 | Python | SP-API の認証・注文取得（JS版: [[amazon-sp-api（jrl84）\|jrl84/amazon-sp-api]]） |
| [[Fleetbase\|fleetbase/fleetbase]] | 4.0k | JavaScript | 物流/サプライチェーンOS（周辺知識） |

## 使い方

- モール差異の吸収 → Saleor のチャネル設計と、openship の Shop／Channel の抽象化（README精読で、openship はドロップシッピング向けの注文振り分けと判明）
- 注文ステータス設計 → Vendure のステート遷移
- Amazon の認証 → SP-API ラッパーの LWA 実装

## 注意

- 多くは「自社で売る」側の設計。**他モールの受注を取り込む**側の案件とは向きが逆なので、設計の参考にとどめる
- Temu / LINEギフト / クロスモール向けの目ぼしい公開実装は今回の検索では見つからなかった
