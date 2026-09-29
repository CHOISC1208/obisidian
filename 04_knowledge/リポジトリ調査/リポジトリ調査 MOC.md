---
title: リポジトリ調査 MOC
aliases:
  - リポジトリ調査
  - 参考OSS
tags:
  - type/MOC
  - topic/OSS調査
created: 2026-09-30
updated: 2026-09-30
---

# リポジトリ調査 MOC

親: [[00 MOC|04_knowledge MOC]]

案件の設計に効きそうな**公開リポジトリを、カテゴリ別に調べて残す**場所。「読んで学ぶ候補」の一覧であり、コードの流用を前提にしない。

## 何を入れるか

- どのカテゴリで探したか、何が見つかったか、**自分の案件のどの課題に効くか**
- 読むときに見るべきディレクトリ・ファイル
- ★数・最終更新日は**調査日時点**の値（古くなる前提）

## ノート一覧

| ノート | 対象 | 効く案件 |
|---|---|---|
| [[リポジトリ調査 - 調べ方]] | GitHub検索の演算子・見分け方・読み方 | 全般 |
| [[リポジトリ調査 - Next.js×Supabaseの権限とRLS]] | RLS・権限モデル・認証構成 | 緑茶園 platform |
| [[リポジトリ調査 - EC受注管理（OMS）]] | 複数チャネル受注・注文ステート・SP-API | 緑茶園 受注機能 |
| [[burhan-platform - コードリーディング]] | RLS修正の変遷・権限昇格の防止・APIキー暗号化保管・認可パターン（コード読了） | 緑茶園 platform の権限モデル／モールのAPIキー保管 |
| [[リポジトリ調査 - マスタ・在庫・PSI]] | 品目マスタ・PIM・在庫元帳 | 緑茶園 商品コード衝突 ／ Green Earth PSI |

## リポジトリ別ノート（`リポジトリ/`）

1リポジトリ1ノート（17本）。**READMEは全本読了、コードは未読**（frontmatter の `status` で管理。コードを読んだら「読書メモ」に書く）。

- 受注管理: [[openship]] ／ [[Vendure]] ／ [[Saleor]] ／ [[reference-app-orders-go]] ／ [[python-amazon-sp-api]] ／ [[amazon-sp-api（jrl84）]] ／ [[Fleetbase]]
- 権限とRLS: [[supabase examples]] ／ [[burhan-platform]] ／ [[pgrls]] ／ [[database-sentinel]] ／ [[next-saas-stripe-starter]]
- マスタ・在庫: [[ERPNext]] ／ [[InvenTree]] ／ [[UnoPIM]] ／ [[Pimcore]] ／ [[GreaterWMS]] ／ [[Odoo]]

## ライセンス早見表（README／GitHub で確認）

| 区分 | リポジトリ | 案件でコードを流用する場合 |
|---|---|---|
| **ゆるい** | [[Saleor]]（BSD-3-Clause）／[[InvenTree]]（MIT）／[[UnoPIM]]（MIT）／[[pgrls]]（MIT）／[[database-sentinel]]（MIT）／[[next-saas-stripe-starter]]（MIT）／[[python-amazon-sp-api]]（MIT）／[[amazon-sp-api（jrl84）]]（MIT）／[[reference-app-orders-go]]（MIT）／[[supabase examples]]（Apache-2.0）／[[GreaterWMS]]（Apache-2.0） | 表示義務を守れば流用可 |
| **コピーレフト（GPL）** | [[ERPNext]]（GPL-3.0）／[[Vendure]]（GPLv3、商用ライセンスの案内あり） | 配布形態に条件が付く。**設計の参考にとどめる** |
| **ネットワークコピーレフト（AGPL）** | [[openship]]／[[burhan-platform]]／[[Fleetbase]]（いずれも AGPL-3.0） | 改変してネットワーク提供するとソース公開義務。**コードは持ち込まない** |
| **独自／要確認** | [[Pimcore]]（POCL）／[[Odoo]]（LICENSE 要確認） | 利用条件を読んでから |

いずれも、Vault に置いた時点で**設計の参考として読む**扱いで、コードのコピーは前提にしていない。

## 未調査のカテゴリ

ワークフロー・承認・勤怠（ケーテック）／ DBマイグレーション管理 ／ BI・ダッシュボード（PRJ-04）／ 数理最適化・生産計画（OR-Tools, HiGHS など）

## まず読む3本（優先順）

1. [[openship]]（※注文の振り分けが用途。READMEを読んで、想定よりドロップシッピング寄りと判明。データモデルを見るなら [[Saleor]] を先にしてもよい） — 複数チャネル受注の集約
2. [[burhan-platform]] — RLSと権限モデル
3. [[InvenTree]] — 品目と在庫のスキーマ

## 関連

- [[プラットフォーム選定の判断軸]] — Green Earth 側の基盤選定
- [[01_engineering/00 MOC|01_engineering]] — 学びを案件で使える形にしたもの
