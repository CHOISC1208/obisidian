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
層: 入口
created: 2026-09-14
updated: 2026-09-21
aliases:
  - platform
  - 統合コンソール
  - ryokuchaen-platform
---

# platform：2リポジトリの統合コンソール化 — 事前調査

親: [[00 MOC|緑茶園グループ MOC]] ／ 親論点: [[テーマ1 - 受注チャネル統合とツール複数人化]]・[[テーマ2 - グループウェアの役割再定義]]
統合元: [[platform - 09 受注機能（旧 EC Channel Console）|EC Channel Console]]（`multi-channel-order-fetcher`）／[[Airtable再構築 - 00 概要|Airtable再構築]]（`ryokuchaen-inventory`）

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

フォルダは切らず、この3層で読む順序を持たせる。各ノートの frontmatter に `層:` を入れてある。

### 基盤（動く前提）

| ノート | 内容 |
|---|---|
| [[platform - 01 スタックと構成の比較]] | README要約・アーキテクチャ・依存パッケージのバージョン差・スクリプトとテスト |
| [[platform - 02 Supabase・認証・環境変数]] | プロジェクト同一性の根拠・スキーマ・マイグレーション履歴・環境変数・Supabase Auth の使い方の違い |
| [[platform - 03 概念が重なるテーブルと型]] | 商品/SKU・取引先/ストア・取込バッチ・監査ログ・TS型の対応表 |
| [[platform - 04 移植の障害と設計判断]] | 命名規則・ルーティング・レイアウト・データライフサイクル・権限・デプロイの障害を重大度つきで整理 |
| [[さくらVPS（ryokuchaen）\|さくらVPS（固定IP踏み台）]] | 固定IPが要る処理を寄せたサーバ1台。au PAY 中継プロキシと、easyECS の SQL Server へ繋ぐ踏み台・同期 cron |

### 設計（決定と方針）

| ノート | 内容 |
|---|---|
| [[platform - 05 統合方針（決定事項と設計）]] | **2026-09-14 の決定事項**と、スキーマ・`sql/`・データアクセス・権限・画面構成の設計方針、EC のスキーマ移動の手順 |
| [[platform - 06 デザイン指示書]] | 統合コンソールのデザイン指示書（**v2・正本**。07 の指摘を反映）。カラートークンとコントラスト、タイポグラフィ、モジュールと画面の割り当て、Tailwind v4 形式の CSS 変数、避けるべきパターン |
| └ [[platform - 07 デザイン指示書レビュー]] | 06 のレビュー記録。指示書の検算（HSL と HEX のずれ、Tailwind v4 での書き方）、コントラスト検証、05 とのレイアウトの突き合わせ、既存コードとの差 |

### 機能（機能単位の検討・手順）

| ノート | 内容 |
|---|---|
| [[platform - 08 TrustLogin SSO 検討]] ／ [[platform - 08a TrustLogin SSO 導入手順]] | **2026-09-16**：TrustLogin（GMO）経由のログインを足したいという要望。08 が判断の経緯と未決事項、08a が手順の正本（先方に渡す SP 情報と依頼文、`supabase sso add` 以降の作業、切り替え前の検証） |
| [[platform - 09 受注機能（旧 EC Channel Console）]] | 7チャネルの受注取得・受注残ボード・手動受注取り込み。**2026-09-15 に platform へ統合済み**（旧 `multi-channel-order-fetcher`） |
| [[platform - 10 変換器構想とMDC出力]] | 受注を easyECS に流し込む「変換器」の構想と、VPS中継＋Supabase同期での実現。MDC 形式の解読 |
| [[platform - 11 商品ポートフォリオの運用サイクル（PPM）]] | **2026-09-19**：PPM を「分類して終わり」でなく運用サイクル（戦略割り当て→バランス診断→ラインナップ→遷移の追跡）にしたいという構想と、売上ダッシュボードの受注履歴でどこまでできるかの試算 |
| [[Airtable再構築 - 00 概要\|仕入（Airtable再構築からの移植）]] | 仕入機能の設計史・移植元。要件定義・データモデル・`inventory` スキーマ・画面設計。POC は `ryokuchaen-inventory`、移植後は凍結 |

## 決定ログ

各ノートに散っている日付つきの決定と未決事項を時系列に並べたもの。**内容の正本は各ノート側**で、ここは索引。

### 決定・判明したこと

- 2026-09-05 複数人利用の壁は大半が解消済みと判明（リポジトリを直接確認し旧記述が古いと分かった） → [[platform - 09 受注機能（旧 EC Channel Console）]]
- 2026-09-07 au PAYマーケットだけ、デプロイした状態ではIP制限で通らないと判明 → [[platform - 09 受注機能（旧 EC Channel Console）]]
- 2026-09-07 稼働中のクロスモールも Shopify・LINEギフトの受注連携メニューを持つと判明（「断絶」の理由が未確定に） → [[platform - 09 受注機能（旧 EC Channel Console）]]
- 2026-09-07 LINEギフトは技術的には実装可能。ブロックしているのは仕様書の入手だけと結論 → [[platform - 09 受注機能（旧 EC Channel Console）]]
- 2026-09-08 ツールの位置づけを「表示」から「変換器」へ広げた → [[platform - 10 変換器構想とMDC出力]]
- 2026-09-08 easyECS の DB は SQL Server と判明。読み取りはCSVに依存しなくてよくなった → [[platform - 10 変換器構想とMDC出力]]
- 2026-09-08 vault と repo の役割を分けた（システム仕様はリポジトリ側が正本） → [[platform - 09 受注機能（旧 EC Channel Console）]]
- 2026-09-09 au PAY は本番デプロイでも実データ取得を確認（IP制限を解決） → [[platform - 09 受注機能（旧 EC Channel Console）]]
- 2026-09-09 au PAY の APIキーはクロスモールと共用だったと判明 → [[platform - 09 受注機能（旧 EC Channel Console）]]
- 2026-09-09 easyECS は外部から名前解決すらできず、拠点間VPNも存在しないと確認 → [[platform - 10 変換器構想とMDC出力]]
- 2026-09-09 暫定判断：Vercel から直接 SQL Server を叩かず、VPS中継＋Supabase同期にする → [[platform - 10 変換器構想とMDC出力]]
- 2026-09-11 Airtable は案B（自前）で進める（→ 09-12 に再オープン） → [[Airtable再構築 - 00 概要]]
- 2026-09-11 顧客マスタ・請求書・納品書は後回しと決定。第1弾は仕入側で完結させる → [[Airtable再構築 - 00 概要]]
- 2026-09-11 支払明細書（＝月締め入荷記録）が現行業務の中核アウトプットと判明 → [[Airtable再構築 - 00 概要]]
- 2026-09-12 kintone 案を再オープン → [[Airtable再構築 - 00 概要]]
- 2026-09-14 統合方針を確定（D1〜D10。仕入は自前前提／データアクセスは1系統／`sql/` が正本／権限はロール＋個人／統合先は `ryokuchaen-platform`） → [[platform - 05 統合方針（決定事項と設計）]]
- 2026-09-14 Supabase は同じプロジェクトを使い続け、EC は `public` から新スキーマへ移すと決定 → [[platform - 02 Supabase・認証・環境変数]]
- 2026-09-14 Airtable は自前（案B）で確定。統合コンソールの仕入機能として作る → [[Airtable再構築 - 00 概要]]
- 2026-09-14 画面とデータの切り方が確定（画面はモジュール、データ・権限は業務で切る。受注残ボードと月締めは「入出荷」） → [[platform - 05 統合方針（決定事項と設計）]]
- 2026-09-14 デザイン指示書レビューの指摘をすべて v2 に反映（コントラスト・モジュール割り当て・サイドバー折りたたみ・リンク色・ヘッダー52px・URL の英語名を確定） → [[platform - 07 デザイン指示書レビュー]]
- 2026-09-14 段階1（土台）を実装 → [[platform - 05 統合方針（決定事項と設計）]]
- 2026-09-15 EC のオブジェクトは 09-14 に `public` から `multi_channel_order_fetcher` スキーマへ移されていたと判明 → [[platform - 02 Supabase・認証・環境変数]]
- 2026-09-15 初期ロールを4ロールで確定 → [[platform - 05 統合方針（決定事項と設計）]]
- 2026-09-15 ユーザー作成だけは Auth 管理 API の secret key を使うと決定 → [[platform - 05 統合方針（決定事項と設計）]]
- 2026-09-15 段階2（ベースライン・`core`・権限設定画面）を実装し本番に適用 → [[platform - 05 統合方針（決定事項と設計）]]
- 2026-09-15 段階3（inventory の移植）完了 → [[Airtable再構築 - 00 概要]]
- 2026-09-15 段階4（EC の移植）をコードとして実装（`ec` スキーマが無く実行検証は段階5へ） → [[platform - 09 受注機能（旧 EC Channel Console）]]
- 2026-09-15 段階5（切り替え）完了。`ryokuchaen-platform` を本番デプロイし、旧 EC Channel Console は Vercel・GitHub ともに撤去 → [[platform - 09 受注機能（旧 EC Channel Console）]]
- 2026-09-15 Vercel Functions のリージョンを `hnd1`（東京）に固定（画面遷移の遅さを解消） → [[01_engineering/Vercel - Functionsのリージョン設定]]
- 2026-09-15 先方の現状運用が判明：Amazon・Yahoo・au PAY は Power Automate で自動化済み → [[platform - 09 受注機能（旧 EC Channel Console）]]
- 2026-09-16 TrustLogin SSO の検討を開始し、Supabase 側の SAML を有効化。案にあった「メールドメインで束ねる」は不要と訂正 → [[platform - 08 TrustLogin SSO 検討]]
- 2026-09-17 2段階認証（TOTP）を全員に必須にした（SSO が入るまでの代わり） → [[platform - 05 統合方針（決定事項と設計）]]
- 2026-09-17 easyECS の SQL Server へ読み取り専用で接続できた（Tailscale 経由で経路が開通） → [[platform - 10 変換器構想とMDC出力]]
- 2026-09-17 VPS中継＋Supabase同期を確定し、受注残ボードで稼働開始 → [[さくらVPS（ryokuchaen）]]
- 2026-09-17 EC Channel Console のノートを `platform - 09`・`10` として吸収 → [[platform - 09 受注機能（旧 EC Channel Console）]]
- 2026-09-19 PPM の分類単位を商品シリーズ（品目×品種×用途×形態。果物以外は親コード）に決定 → [[platform - 11 商品ポートフォリオの運用サイクル（PPM）]]
- 2026-09-19 PPM の閾値を決定（伸びは2年の年率と会社全体の差、大きさは構成比1%以上） → [[platform - 11 商品ポートフォリオの運用サイクル（PPM）]]

### 未決事項

- 【未決】ログインを TrustLogin の SSO に寄せるか。最優先の技術論点は**既存ユーザーの uuid が維持されるか**（権限は `auth.users.id` 基準） → [[platform - 08 TrustLogin SSO 検討]]
- 【未決】パスワードログインを残すか、SSO に一本化するか（管理者アカウントを1つ残すのが安全側） → [[platform - 08 TrustLogin SSO 検討]]
- 【未決】SSO を入れた後、TOTP をどう扱うか（SSO で入った人に `aal2` が付くかは実機確認） → [[platform - 08 TrustLogin SSO 検討]]
- 【未決】EC検証用ボットの扱い。2026-09-17 以降は2段階認証でも止まり、SSO 一本化と両立しない → [[platform - 08 TrustLogin SSO 検討]]
- 【未決】TrustLogin 側が SP メタデータXMLのアップロードに対応しているか〔未確認〕 → [[platform - 08a TrustLogin SSO 導入手順]]
- 【未決】商品の対応づけをどう持つか。仕入商品（取引先×規格）と販売SKU（セット・箱単位）は 1:1 にならない → [[platform - 03 概念が重なるテーブルと型]]
- 【未決】[[テーマ2 - グループウェアの役割再定義]] の GUIファースト方針との整合。統合コンソールは保守の SPOF を1か所に集める
- 【未決】Supabase ダッシュボードの「新規サインアップを許可」がオフになっているか未確認 → [[platform - 02 Supabase・認証・環境変数]]
- 【未決】受注残ボード（連携表示）・MDC出力はスタブのまま → [[platform - 10 変換器構想とMDC出力]]
- 【未決】消し込みを誰がやるか（自作取込の設計上の急所） → [[platform - 10 変換器構想とMDC出力]]
- 【未決】LINEギフトの仕様書の入手（先方の出店資料待ち） → [[platform - 09 受注機能（旧 EC Channel Console）]]
- 【未決】さくらVPS のパスワード認証を無効化し SSH 鍵に切り替えるか（海外IPからの総当たりを観測） → [[さくらVPS（ryokuchaen）]]
- 【未決】Airtable：M1の残り（インボイス要件／DocsAutomator継続可否）をヒアリングで潰す → [[Airtable再構築 - 00 概要]]
- 【未決】Airtable：支払明細書を要件・スキーマに正式に組み込む → [[Airtable再構築 - 00 概要]]
- 【未決】Airtable：自前で解体・再構築する方針の是非を先方に確認（2026-09-16 アジェンダ） → [[Airtable再構築 - 00 概要]]
- 【未決】PPM：SKU の枝番を1商品として数えてよいか／`ss-` は何を分けているか／品種おまかせのまとめ方／原価を写すか／先方に四半期の見直しを回す体制があるか → [[platform - 11 商品ポートフォリオの運用サイクル（PPM）]]

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

> [!info] 2026-09-16：TrustLogin（GMO）SSO の検討を開始。Supabase 側の SAML を有効化
> ログインを TrustLogin に寄せたいという要望。持ち込まれた手順案を検証し、順番の誤り（プラン確認は前提／SAML 有効化が先）とドメイン指定が不要なことを確認した。SAML 有効化と SP 情報の確定まで済み、先方（TrustLogin 管理者）への依頼待ち。手順と依頼文は [[platform - 08a TrustLogin SSO 導入手順]]、判断の経緯は → [[platform - 08 TrustLogin SSO 検討]]
> - 最大の論点は**既存ユーザーの uuid が維持されるか**。権限は `auth.users.id` 基準なので、変わると superuser 権限とロール割り当てが外れる

> [!success] 2026-09-17：2段階認証（TOTP）を全員に必須にした
> 入っているデータが本格化してきたため。TrustLogin の SSO は時間がかかる見込みなので、それまでの代わりに Supabase Auth の TOTP（認証アプリ、QR で登録）を入れた。端末を無くした人は superuser が権限設定の画面から解除する（Auth 管理 API の例外を広げた）。判断の経緯 → [[platform - 05 統合方針（決定事項と設計）]] 3章

- [ ] **ログインを TrustLogin（GMO）の SSO に寄せるか**。2026-09-16 に要望。既存ユーザーの uuid が維持されるか（権限の割り当てが外れないか）と、パスワードログインを残すかが未決 → [[platform - 08 TrustLogin SSO 検討]]
- [ ] **商品の対応づけをどう持つか**。仕入商品（取引先×規格）と販売SKU（セット・箱単位）は 1:1 にならない
- [ ] [[テーマ2 - グループウェアの役割再定義]] の GUIファースト方針との整合。統合コンソールは保守の SPOF をさらに1か所に集める

## 調査方法

- 両リポジトリの README・CLAUDE.md・package.json・`node_modules` 内の実バージョン・`app/`・`lib/`・`components/`・`supabase/migrations/` を読んだ
- Supabase は MCP で**読み取りのみ**実行（プロジェクト一覧・テーブル一覧・マイグレーション履歴・RLS/ビュー設定・`auth.users` の件数・コード体系の突き合わせ）。書き込みはしていない
- `.env.local` は変数名と URL だけを見た。キーやパスワードの値はこのノートに書いていない
