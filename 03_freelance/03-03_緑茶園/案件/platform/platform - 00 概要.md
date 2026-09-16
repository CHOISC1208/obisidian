---
tags:
  - 緑茶園
  - 案件
  - platform
  - 統合調査
client: 緑茶園グループ
親論点:
  - テーマ1 - 受注チャネル統合とツール複数人化
  - テーマ2 - グループウェアの役割再定義
フェーズ: 調査
created: 2026-09-14
updated: 2026-09-16
aliases:
  - platform
  - 統合コンソール
  - ryokuchaen-platform
---

# platform：2リポジトリの統合コンソール化 — 事前調査

親: [[00 MOC|緑茶園グループ MOC]] ／ 親論点: [[テーマ1 - 受注チャネル統合とツール複数人化]]・[[テーマ2 - グループウェアの役割再定義]]
統合元: [[EC Channel Console - 00 概要|EC Channel Console]]（`multi-channel-order-fetcher`）／[[Airtable再構築 - 00 概要|Airtable再構築]]（`ryokuchaen-inventory`）

> [!info] このフォルダの位置づけ
> 2つのリポジトリを1つの統合コンソールにまとめる計画の**着手前調査**。コードは書いていない。
> 2026-09-14 時点のスナップショットであり、両リポジトリの README（システム仕様の正本）を置き換えるものではない。ここに書くのは「**統合するときに何がぶつかるか**」だけ。

## 調査対象（2026-09-14 時点）

| | ryokuchaen-inventory | multi-channel-order-fetcher |
|---|---|---|
| 中身 | 生産者仕入業務の POC アプリ＋Airtable 抽出スクリプト | EC Channel Console（受注取得・手動受注取り込み・受注残ボード） |
| GitHub | `ryokuchaen/ryokuchaen-inventory` | `ryokuchaen/multi-channel-order-fetcher` |
| 調べたコミット | `f77a3b5`（main） | `c464bba`（**`fix/views-security-invoker` ブランチ**。main ではない） |
| package.json | `ryokuchaen-inventory` 0.1.0 | `ec-channel-console` 0.10.2 |

統合先と思われる **`ryokuchaen/ryokuchaen-platform`** リポジトリがすでに作られている（`04_ryokuuchaen/ryokuchaen-platform`）。中身は Initial commit のみで、README の1行（「緑茶園の総合プラットフォーム」）・Node 用 `.gitignore`・空の `.env.local` だけ。

## 結論（先に要点）

> [!success] 土台はすでに統合済みに近い
> - **Supabase プロジェクトは同一**（`ryokuchaen` / ref `tphdmbhufxcpdifxxvzl`）。スキーマで住み分けている（EC＝`public`、仕入＝`inventory`）。→ [[platform - 02 Supabase・認証・環境変数]]
> - **ログインユーザーも同一**（Supabase Auth のメール＋パスワード、現在3名。2026-09-15 確認：うち1件は EC の検証用ボットで、人は2名）。inventory のログイン画面は「EC Channel Console と同じアカウントでログインできます」と明示している
> - **スタックはほぼ同じ**：Next.js 16.3.x／React 19.2.8／Tailwind CSS 4.3.3／`@supabase/ssr` 0.12.x。**shadcn/ui はどちらも未導入**（差分ゼロ）。→ [[platform - 01 スタックと構成の比較]]
> - `globals.css`・`proxy.ts`・`lib/auth/*`・ログイン画面・`PageHeader` は**ほぼ同じコード**。同じ雛形から作られている

> [!warning] 本当の障害は「見た目」ではなく次の5つ
> 1. **仕入アプリ自体の行き先が未決。** [[Airtable再構築 - 00 概要]] で kintone 案が再オープン中。kintone に転べば統合の対象から外れる
> 2. **データアクセス層が2系統。** inventory は `pg` 直結＋Server Actions、EC は `supabase-js`（service_role）＋Route Handlers。`inventory` スキーマは PostgREST から見えないので、EC の書き方には寄せられない
> 3. **マイグレーション履歴がリポジトリと食い違っている。** 本番の履歴は4件、リポジトリのファイルは合計4本だが対応していない。EC の2本は SQL Editor で手動適用、認証情報テーブルの DDL はどこにも無い
> 4. **権限モデルが無い。** ログインできれば誰でも全機能を使える。統合すると「受注を見る人」が「支払明細書を発行する人」「モールの API キーを書き換える人」と同じ権限になる
> 5. **商品コードが見かけ上ぶつかる。** easyECS の SKU に `0014-103` などがあり、inventory の `product_code` と**文字列が完全一致するのに別商品**（ラフランス 2kg と ぶどう 500g）。→ [[platform - 03 概念が重なるテーブルと型]]
>
> 詳細と重大度は → [[platform - 04 移植の障害と設計判断]]

## ノート一覧

| ノート | 内容 |
|---|---|
| [[platform - 01 スタックと構成の比較]] | README要約・アーキテクチャ・依存パッケージのバージョン差・スクリプトとテスト |
| [[platform - 02 Supabase・認証・環境変数]] | プロジェクト同一性の根拠・スキーマ・マイグレーション履歴・環境変数・Supabase Auth の使い方の違い |
| [[platform - 03 概念が重なるテーブルと型]] | 商品/SKU・取引先/ストア・取込バッチ・監査ログ・TS型の対応表 |
| [[platform - 04 移植の障害と設計判断]] | 命名規則・ルーティング・レイアウト・データライフサイクル・権限・デプロイの障害を重大度つきで整理 |
| [[platform - 05 統合方針（決定事項と設計）]] | **2026-09-14 の決定事項**と、スキーマ・`sql/`・データアクセス・権限・画面構成の設計方針、EC のスキーマ移動の手順 |
| [[platform - 06 デザイン指示書]] | 統合コンソールのデザイン指示書（**v2・正本**。07 の指摘を反映）。カラートークンとコントラスト、タイポグラフィ、モジュールと画面の割り当て、Tailwind v4 形式の CSS 変数、避けるべきパターン |
| [[platform - 07 デザイン指示書レビュー]] | 指示書の検算（HSL と HEX のずれ、Tailwind v4 での書き方）、コントラスト検証、05 とのレイアウトの突き合わせ、既存コードとの差 |
| [[platform - 08 TrustLogin SSO 検討]] | **2026-09-16**：TrustLogin（GMO）経由のログインを足したいという要望。手順案の検証結果と、ユーザー管理の持ち主をどちらにするかの未決事項 |

## 着手前に決めること

> [!success] 2026-09-14：主要な論点に方針が出た → [[platform - 05 統合方針（決定事項と設計）]]
> 仕入は自前前提／データアクセスは1系統に統一／新規のマイグレーションは共通ルール／SQL は `sql/` に整理／権限はロール＋個人で superuser が設定／統合先は `ryokuchaen-platform`／EC は `public` から新スキーマへ移し、`public` は原則使わない。

- [x] ~~**仕入業務は kintone に行くのか、自前に残るのか**~~ → **自前前提で作る**（2026-09-14）。[[Airtable再構築 - 00 概要]] への反映は未
- [x] ~~**統合後のデータアクセスをどちらに寄せるか**~~ → **統一する**。推奨は `pg` 直結＋Server Actions（→ 05 の3章）
- [x] ~~**マイグレーションの正本をどこに置くか**~~ → **`sql/` ディレクトリ**。新規実装は必ず共通ルールに従う（→ 05 の2章）
- [x] ~~**ロールをどう切るか**~~ → **ロール単位と個人単位で、superuser が設定画面で設定する。superuser は Supabase で直接設定**（→ 05 の4章。初期ロールは 2026-09-15 に4ロールで確定）
> [!info] 2026-09-14：段階1（土台）を実装
> `ryokuchaen-platform` の `stage1/foundation` ブランチ（未 push）。雛形・デザイントークン・`sql/` の骨組み・ログイン・App Shell まで。権限は「全員 superuser」の仮実装で、本番DBには書き込んでいない。段階の切り方は同リポジトリの `CLAUDE.md`。

> [!info] 2026-09-15：段階2（ベースライン・`core`・権限設定画面）を実装し、本番に適用
> 着手時の読み取り調査で、前提が2つ動いた（→ [[platform - 05 統合方針（決定事項と設計）]] の「未決・要確認」）。
> - EC のオブジェクトは 2026-09-14 に `public` から `multi_channel_order_fetcher` スキーマへ移されていた（意図どおりと確認）。旧 EC Channel Console は動かない前提
> - ユーザーの作成には Auth 管理 API の secret key が要る → テーブルの読み書きには使わず、ユーザー作成だけに1本持つと決めた

> [!info] 2026-09-15：段階3（inventory の移植）を実装
> `stage3/inventory` ブランチ。仕入アプリ（`../ryokuchaen-inventory`）の画面・Server Action・抽出スクリプトを、新しい URL（`/logistics`・`/documents`・`/masters`）と権限（`requirePermission()`）・`ActionResult` に載せ替えた。
> - `inventory` スキーマと `platform_app` への grant は段階2のベースラインで既に揃っていたため、**新しい migration は不要**（アプリコードの移植のみ）
> - 監査ログは決定どおりカットオーバーまで `inventory.audit_logs` に残したまま（`core.audit_logs` には未統合）
> - 自前部品を指示書どおり shadcn/ui に置き換えた（`SidePeek` → `Sheet`、`PartnerCombobox` → `Command`＋`Popover`）
> - 抽出スクリプトの DB 接続ユーザーを決定（→ 05 の「未決・要確認」）。本番での抽出実行はまだ行っていない

> [!info] 2026-09-15：段階4（EC の移植）をコードとして実装（画面は未確認）
> `stage4/ec` ブランチ。`multi-channel-order-fetcher` の7チャネル（楽天・Amazon・Yahoo・au PAY・Shopify・Temu・LINEギフト）・受注残ボード（手動表示）・手動受注取り込み（MDC／その他）・SKU対応表・チャネル認証情報画面を、`supabase-js`（service_role）から `pg` 直結＋`lib/ec/` へ移植した。
> - 段階4は CLAUDE.md の定義どおり「コードのみ」。`ec` スキーマが無いため実行・検証はできない。`npm run build`・`typecheck`・`lint` は通した。パース純関数（受注残・手動受注取込）は `npm run test:backlog`・`test:manual-orders` で検証済み（DB不要のため今すぐ実行できる）
> - `ChannelError` クラスは廃止し、`lib/core/result.ts` の `AppError`／`ActionResult` に統一した（05 の3章どおり）
> - Route Handler はファイルの入出力（CSV取り込み・CSVエクスポート）だけに絞り、チャネル別の受注取得・認証情報の保存・SKU対応の登録は Server Action にした（移植元は全て Route Handler だった）
> - 受注残ボード（連携表示）・MDC出力は移植元と同じくスタブのまま（easyECS SQL Server 接続情報の受領待ち）
> - EC検証用ボット（`test-bot@...`）への権限割り当ては `sql/ops/assign_test_bot_role.sql` にドラフトのみ用意し、適用は段階5に送った（未決事項の決着 → 05 の「未決・要確認」）
> - 移植元の `test:mock`（HTTPでの通し検証）は、多くの操作が Route Handler から Server Action に変わったためそのまま移植できない。詳細と段階5での作り直し方針は `ryokuchaen-platform` の `test/README.md`

> [!success] 2026-09-15：段階5（切り替え）完了。`ryokuchaen-platform` を本番デプロイ
> `multi_channel_order_fetcher` → `ec` へのスキーマリネーム（`sql/migrations/20260915040000_ec_cutover.sql`）を適用し、移行前後の件数一致を確認。旧 EC Channel Console は Vercel プロジェクトごと削除・GitHubリポジトリもアーカイブ済み。`ryokuchaen-platform` はこれが初回デプロイ（[[platform - 05 統合方針（決定事項と設計）]]「未決・要確認」参照）。
> - 動作確認で2件の不具合を発見・修正：① au PAY 中継プロキシ（さくらVPS `ryokuchaen`）で `ufw` が443番ポートを許可しておらずAPIに接続できなかった（`sudo ufw allow 443/tcp` で解消。VPS側の設定漏れで、アプリのコードとは無関係）。② EC の `timestamptz` 列（`imported_at` など）が `pg` 標準どおり `Date` オブジェクトのまま返り、Reactが「Objects are not valid as a React child」でクラッシュしていた（手動受注取り込み画面が「ページが無い」ように見えた原因）。`lib/core/queries.ts` は元々 `Date` を前提にしていたため気づかず、EC側の該当箇所で `.toISOString()` の文字列化を追加して解消
> - デプロイ後、画面遷移が毎回1〜3秒遅いという報告 → Vercel Functions の既定リージョン（`iad1`・米国）と Supabase（東京）が離れていたことが原因と判明。`vercel.json` で `hnd1`（東京）に固定して解消（一般的な知見として [[01_engineering/Vercel - Functionsのリージョン設定]] にも記録）
> - 残作業：`ec._archived_multi_channel_order_fetcher_logs`（旧エラーログの控え）は運用が安定してから drop する。EC検証用ボットの権限適用は `test:mock` 相当の検証を作り直すときに判断する

- [ ] **ログインを TrustLogin（GMO）の SSO に寄せるか**。2026-09-16 に要望。載せるメールドメインと、既存のパスワードログインを残すかが未決 → [[platform - 08 TrustLogin SSO 検討]]
- [ ] **商品の対応づけをどう持つか**。仕入商品（取引先×規格）と販売SKU（セット・箱単位）は 1:1 にならない
- [ ] [[テーマ2 - グループウェアの役割再定義]] の GUIファースト方針との整合。統合コンソールは保守の SPOF をさらに1か所に集める

## 調査方法

- 両リポジトリの README・CLAUDE.md・package.json・`node_modules` 内の実バージョン・`app/`・`lib/`・`components/`・`supabase/migrations/` を読んだ
- Supabase は MCP で**読み取りのみ**実行（プロジェクト一覧・テーブル一覧・マイグレーション履歴・RLS/ビュー設定・`auth.users` の件数・コード体系の突き合わせ）。書き込みはしていない
- `.env.local` は変数名と URL だけを見た。キーやパスワードの値はこのノートに書いていない
