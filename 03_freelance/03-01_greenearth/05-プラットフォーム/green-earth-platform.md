---
type: platform
repo: /Users/choiseoncheol/git/green-earth-platform
role: 業務の頭脳（バックオフィス／実行レイヤー）
tags: [platform]
---

# green-earth-platform

> 製造業務（原価・在庫・生産・販売実績）を回す基幹業務システム。

⚠️ **このノートはまだ設計方針だけで、実装の現況が入っていません。** リポジトリ調査の結果を反映してください。

## 位置づけ

貯めたデータを使って計算・計画・分析する。単一組織前提。MFA必須で「守りやすさ」を優先した設計。

対になるのが [[choi-tone]]（入力の窓口・収集レイヤー）。新要件をどちらに載せるかは [[プラットフォーム選定の判断軸]] を参照。

## スタック

Next.js (App Router) / React / Tailwind CSS v4 / shadcn-ui / Supabase (Postgres) / Vercel / AWS Lambda + EventBridge

- 認証: Supabase Auth（メール＋パスワード）＋ TOTP二要素認証が全ユーザー必須（aal2到達必須）
- 公開サインアップなし。管理者が個別に作成
- Supabase project ID: `gxnuqmrbpoyuiavrjemc`

## ルーティング（業務ドメイン別）

`costing` / `inventory` / `production` / `master` / `dashboard` / `settings`

## 設計原則

- **単一の真実**: 業務ロジック（原価計算・アレルゲン集約・会計年度・在庫評価）はすべて Supabase の RPC／再帰CTEに置く。生の一次データだけを保存し、導出値はクエリ時に計算する
- **段階の順序は変えない**: 商品マスタ → 在庫・売上の可視化 → PSI・生産計画
- **モジュールとして足す**: 受発注・勤怠・プライスカードは別システムにせず、このプラットフォームのモジュールとして追加する（マスタ・UIパターン・データ基盤を共有するため）

## スキーマの要点

- `public` に運用テーブル: `items` / `product_info` / `item_allergens` / `bom_components` / `set_components`
- `master` スキーマは計画されたが存在しない。関連テーブルはすべて `public` にある
- `cheesepige_site` スキーマは [[cheesepige-site]] 用。**サイト側のマイグレーションから `public` や社内テーブルを触らない**
- アレルゲンは原材料レベルに保持。最終商品IDで直接joinすると null。`bom_components` の再帰CTEで辿ること
- 税込 = `CEIL(sales_price * 1.08)`（切り上げ）
- 会計年度 = `(year - 2023) + 13 + (1 if month >= 6 else 0)`（6月1日開始）

## 載っている案件

[[PRJ-01-商品マスタ構築]] / [[PRJ-02-生産状況の可視化]] / [[PRJ-03-クラウドPSI基盤の構築]] / [[PRJ-04-経営用ダッシュボード]] / [[PRJ-05-勤怠修正フローの効率化（紙修正表→転記作業の削減）]] / [[PRJ-06-直営店・FC店受発注の自社システム化によるインフォマートコスト削減]] / [[PRJ-08-実績のDB化]] / [[PRJ-09-プライスカード自動生成・確認フロー改善]]

## 実装状況

（リポジトリ調査の結果をここに貼る）

## 未反映の課題

（[[_課題一覧]] のうち、このプラットフォームに実装先が向いていて未着手のもの）
