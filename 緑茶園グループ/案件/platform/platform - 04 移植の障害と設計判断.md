---
tags:
  - 緑茶園
  - 案件
  - platform
  - 統合調査
  - リスク
client: 緑茶園グループ
created: 2026-09-14
updated: 2026-09-14
---

# 移植の障害と設計判断

親: [[platform - 00 概要]] ／ 根拠: [[platform - 01 スタックと構成の比較]]・[[platform - 02 Supabase・認証・環境変数]]・[[platform - 03 概念が重なるテーブルと型]]

> [!info] 重大度の読み方
> 🔴 **着手前に決める**（決めずに進むと作り直しになる）／🟡 **統合作業の中で決める**／🟢 **機械的に揃えれば済む**
> ここでは「どうすべきか」の結論は出さず、**選択肢と判断材料**まで書く。

## 一覧

> [!success] 2026-09-14：方針が出た障害は「方針」列を参照 → 詳細は [[platform - 05 統合方針（決定事項と設計）]]

| # | 障害 | 重大度 | 方針（2026-09-14） |
|---|---|---|---|
| 1 | 仕入業務の行き先（kintone案）が未決 | 🔴 | ✅ 自前前提で作る |
| 2 | データアクセス層が2系統 | 🔴 | ✅ 統一する（推奨：`pg` 直結＋Server Actions） |
| 3 | マイグレーションの正本が無い | 🔴 | ✅ `sql/` に整理。新規実装は必ず共通ルール |
| 4 | 権限モデルが無い | 🔴 | ✅ ロール＋個人。superuser が設定画面で設定、superuser 自体は Supabase で直接 |
| 5 | 商品コードの見かけの一致と粒度の違い | 🔴 | ⬜ 未決（文字列では結びつけない、とだけ決める） |
| 6 | POC データのライフサイクル（全件入れ直し・id振り直し） | 🟡 | 🔶 カットオーバーまでスキーマをまたぐ外部キーを張らない |
| 7 | テーブル命名とスキーマ配置の規則が違う | 🟡 | ✅ EC を新スキーマへ移す。`public` は原則使わない |
| 8 | ルーティングと言葉の衝突（`/`・「マスタ」） | 🟡 | 🔶 URL＝スキーマ＝lib＝権限キーの接頭辞で揃える（案） |
| 9 | サイドバーとレイアウトの設計思想が違う | 🟡 | 🔶 第1階層は業務、その中は各アプリの切り方を保つ（案） |
| 10 | デプロイと DB 接続方式 | 🟡 | 🔶 アプリ専用DBロール・pooler の方式は要検証 |
| 11 | エラー・結果の返し方が2種類 | 🟡 | 🔶 1つの形に揃える（案） |
| 12 | 認証チェックの層の違い（proxy のみ／Action ごと） | 🟡 | ✅ 処理の先頭で必ず権限を確認する（4. に含む） |
| 13 | ファイル命名・クォート・tsconfig の差 | 🟢 | 🔶 できるだけ合わせる（推奨の決まりは 05） |
| 14 | 同名コンポーネント・ほぼ同一の共通コード | 🟢 | 🔶 同上 |
| 15 | 開発ポート・env 例・lint スクリプトの不整合 | 🟢 | 🔶 同上 |
| 16 | 自動バージョン更新フック・vault 同期ルールの引き継ぎ | 🟢 | 🔶 同上 |

凡例：✅ ユーザー決定済み／🔶 決定を受けた推奨案（05）／⬜ 未決

---

## 🔴 1. 仕入業務の行き先が未決

[[Airtable再構築 - 00 概要]] で **kintone 案（案A）が 2026-09-12 に再オープン**している。inventory は案B（自前）の POC であり、案Aに転べば統合の対象から外れる。

- 判断材料：kintone を推す最大の理由は [[テーマ2 - グループウェアの役割再定義]] の GUIファースト方針（git/npm 依存のアプリは SPOF を生む）。**統合コンソールはその SPOF をさらに1か所に集める**方向なので、この論点を強める
- 逆に、統合によって「Vercel/Supabase のインフラに相乗りし限界費用ほぼゼロ」という案Bの利点ははっきりする

## 🔴 2. データアクセス層が2系統

| | inventory | EC |
|---|---|---|
| 接続 | `pg` で Postgres 直結（Session pooler、`postgres` ユーザー） | `supabase-js`＋service_role（PostgREST） |
| 書き込みの入口 | Server Actions | Route Handlers |
| 理由 | 支払明細書の発行などで**複数テーブルを1トランザクション**で更新する | 認証情報・取込データの単純な読み書き |

- `inventory` スキーマは PostgREST に公開されていない（Supabase の既定は `public` のみ）。**EC の書き方に寄せるなら、スキーマ公開の設定変更か、トランザクション処理を DB 関数（RPC）に移す**必要がある
- inventory の書き方に寄せるなら、EC の `store.ts` 群を生SQLに書き換える。EC 側の機能は単純なのでこちらの方が移植量は少なそう（未見積もり）
- 併用のまま進めることもできるが、**秘密情報が「DBパスワード」と「service_role キー」の2つ**になり、Supabase の新しい API キー形式（`sb_secret_`）への移行も2経路で考えることになる

## 🔴 3. マイグレーションの正本が無い

- 本番の履歴4件とリポジトリのファイルが対応していない（EC の2本は手動適用で履歴に無い、認証情報テーブルの DDL は無い、inventory のファイルは version が違う）
- inventory のマイグレーションは `drop schema if exists inventory cascade` で始まる。**再適用すると本番の仕入データが消える**
- 番号体系も違う（`0001_` 連番／タイムスタンプ）
- 選択肢：`ryokuchaen-platform` で本番の現状スキーマをダンプして**ベースライン1本**を作り、以降をそこから積む。統合前の2リポジトリの `migrations/` は履歴として凍結する

## 🔴 4. 権限モデルが無い

- 両アプリとも「ログインしているか」しか見ていない。`auth.users` 3名、role を持つユーザー0名
- 統合で**影響範囲が広がる操作**：チャネル認証情報の上書き（`/settings`）、支払明細書の発行・取り消し（`/closing`・`/statements`）、マスタの削除、受注残の全件置き換え（消し込み方式A）
- EC の Route Handler は各ルートで認証を確認していない（proxy 任せ）。ロールを入れるなら**全ルートに確認を足す**作業が発生する
- 自己サインアップが Auth 設定でオフになっているかは未確認（→ [[platform - 02 Supabase・認証・環境変数]]）
- EC は「ユーザー単位の操作履歴」が先方要望の筆頭で未着手。inventory の `audit_logs` の仕組みを横展開する好機でもある（EC の `imported_by` は列だけあって一度も入っていない）

## 🔴 5. 商品コードの見かけの一致と粒度の違い

- easyECS の SKU `0014-103` `0014-105` `0014-111` `0014-113` が inventory の `product_code` と**完全一致するが別商品**（→ [[platform - 03 概念が重なるテーブルと型]]）
- 仕入商品（取引先×規格）と販売SKU（セット・箱）は **N:M**。「受注残から必要な仕入量を出す」ような横断機能を作るなら、**構成表（BOM）相当の対応づけ**が別に要る
- `inventory.marketplace_codes`（1:N 前提・0件）と EC の `manual_order_sku_map`（0件）は、どちらもまだ空。**データが入る前に**1つの設計に寄せられる、今が一番安いタイミング

---

## 🟡 6. POC データのライフサイクル

- inventory は抽出のたびに**全件を消して入れ直し、id を1から振り直す**。アプリで入れたデータも消える
- 統合コンソールで EC 側から inventory の id を参照（外部キーやURL）すると、抽出のたびに**別の行を指す**
- カットオーバー（Airtable 停止）までは、スキーマをまたぐ外部キーは張れない。コードでつなぐなら `airtable_record_id` か `product_code`（ただし5.の問題あり）

## 🟡 7. テーブル命名とスキーマ配置

| | inventory | EC |
|---|---|---|
| 住み分け | **専用スキーマ** `inventory` | `public` に直置き |
| 接頭辞 | なし（スキーマで区別） | 古い2本は `multi_channel_order_fetcher` 接頭辞、新しい5本は短い名前（`order_backlog_*`・`manual_order_*`） |
| 主キー | 全部 bigserial | 取込の1回分は uuid、明細は bigserial |
| ビュー | `v_` 接頭辞 | `v_` 接頭辞 |

- EC のマイグレーションには「他アプリとプロジェクトを共有するなら接頭辞を足してから適用」と書いてあるが、**共有したまま短い名前で適用済み**
- 選択肢：EC のテーブルも業務単位のスキーマ（例：受注系）へ移す／`public` のまま命名だけ揃える。移すとビューとコードの参照先が全部変わる
- `multi_channel_order_fetcher` はリポジトリ名由来で、中身（チャネル認証情報）を表していない。統合時は改名の候補

## 🟡 8. ルーティングと言葉の衝突

- パスの衝突は `/`（inventory ホーム／EC ダッシュボード）と `/login` のみ
- **「マスタ」の意味が違う**：inventory のサイドバーの「マスタ」は取引先・商品・規格。EC の「マスタ設定」（`/settings`）はモールの API 認証情報。統合すると同じサイドバーに並ぶ
- **「取引先」**：inventory では仕入先。販売側の相手（モール・ストア）を同じ言葉で呼ばないように決めておく
- API の置き場所：EC は `/api/**`、inventory は CSV 出力だけ `(app)/transactions/export/route.ts`。proxy の「`/api/` なら401 JSON」という分岐は、inventory の CSV 出力には効かない（リダイレクトになる）
- 選択肢：業務ごとのパス接頭辞（例：仕入系／受注系）で切るか、今のパスを保ったまま並べるか。後者は将来の衝突に弱い

## 🟡 9. サイドバーとレイアウトの設計思想

| | inventory | EC |
|---|---|---|
| グループの切り方 | **使う頻度**（毎日／月次／マスタ／POC期間のみ）。[[Airtable再構築 - 画面設計（UI・UX）]] の判断 | **機能**（チャネルの情報取得／手動受注取り込み／受注残ボード） |
| アイコン | lucide-react | なし |
| 折りたたみ | あり（w-52 ⇔ w-14、localStorage に保存、1024px 未満は畳んで開始） | なし（w-64 常時全展開） |
| ヘッダー要素 | アプリ名、ログイン中のメール | ロゴ、バージョン、チャネルごとの設定状態ドット |
| 本文幅 | `max-w-6xl`、`px-6 py-6` | `max-w-5xl`、`px-8 py-8` |
| 固有の帯 | 「POC環境」の注意帯 | なし |
| 印刷 | `.no-print`（支払明細書を帳票として印刷） | なし |
| layout のデータ取得 | ユーザーのみ | **全ページで**チャネル設定状態を DB から読む（`force-dynamic`） |

- 統合すると、EC の layout の DB 読み取りが**仕入画面の全ページにも乗る**。サイドバーのデータ取得を業務ごとに分けるかを決める
- 「頻度で切る」と「機能で切る」は両立しにくい。先に上位の切り方（業務ドメイン）を決め、その中を各方式にするのが素直

## 🟡 10. デプロイと DB 接続方式

- EC は Vercel にデプロイ済み（vault 記載）。au PAY はさくらVPSの中継プロキシ経由（固定IP）
- inventory はデプロイされていない（`.vercel` 無し）
- inventory の `pg.Pool` は **Session pooler（5432）に `max: 5`** で接続している。サーバーレスでインスタンスが増えると接続数が膨らむ。Transaction pooler（6543）への切り替えやプール設定の見直しが必要か、**要検証**
- easyECS の SQL Server 直結（EC の構想）は、Vercel から客先サーバへの到達性という au PAY と同じ壁がある。統合コンソールのデプロイ先を決めるときに一緒に考える

## 🟡 11. エラー・結果の返し方

- inventory：`ActionResult { ok, message }`／`FormState { error, message? }`（`useActionState` 前提）、`UserError` クラス
- EC：`{ error: { code, message, detail } }`＋`ChannelError`（コード→HTTPステータス対応）、エラーは `logError()` で DB にも残す
- Server Action と Route Handler は返し方の性質が違うので、**入口の方式（2.）を決めると自然に決まる**

## 🟡 12. 認証チェックの層

- inventory：proxy に加えて Server Action の先頭で `requireUser()`（多層防御）
- EC：proxy のみ。Route Handler は「proxy で保護済みなので不要」
- Next.js の proxy は matcher の書き方ひとつで素通りする経路ができるので、統合後は**処理側でも確認する**方に寄せる判断が要る（ロール導入＝4. とセットで決める）

---

## 🟢 13. ファイル命名・クォート・tsconfig

| | inventory | EC |
|---|---|---|
| `lib/` のファイル名 | **kebab-case**（`due-date.ts`、`master-actions.ts`） | **camelCase**（`parseMdc.ts`、`skuMap.ts`、`errorDetail.ts`） |
| ディレクトリ名 | kebab-case | kebab-case（`manual-orders`） |
| コンポーネント | PascalCase・default export | 同左 |
| クォート | 混在（`lib/db/config.ts` と抽出スクリプトはシングル、アプリはダブル） | ダブルのみ |
| `package.json` `"type"` | `"module"` | 指定なし |
| tsconfig | `noUncheckedIndexedAccess`・`noUnusedLocals` あり | なし |

- **EC のコードを inventory の tsconfig に載せると型エラーが出る見込み**（配列アクセスが `T \| undefined` になる）。統合先の tsconfig をどちらの厳しさにするか先に決める
- フォーマッタ・リンタの設定はどちらにも無い。統合を機に入れるなら、差分の大半はこれで吸収できる

## 🟢 14. 同名コンポーネント・ほぼ同一の共通コード

- 同名：`components/Sidebar.tsx`・`components/PageHeader.tsx`（PageHeader は `mb-5`／`mb-6` の差だけ）
- ほぼ同一：`lib/auth/server.ts`（inventory に `requireUser()` が追加されているだけ）・`lib/auth/client.ts`・`proxy.ts`（EC に Bearer 対応と401 JSON）・`app/globals.css`（inventory に印刷用）・ログイン画面（タイトルとロゴの有無）
- 同じ雛形から作られているので、**寄せる作業は機械的**

## 🟢 15. 小さな不整合

- 開発ポート：inventory の `launch.json` が **3100**、EC の `test:mock` も **3100**。同時に動かすとぶつかる
- EC の `.env.local.example` に `NEXT_PUBLIC_SUPABASE_URL` が無い（例から作るとログインできない）
- EC の `"lint": "next lint"` は Next 16 で廃止されたコマンド
- inventory の `.env.local` に、使っていない `SUPABASE_SERVICE_ROLE_KEY`・`SUPABASE_URL` が残っている
- `@types/node` が 22 と 24

## 🟢 16. 運用ルールの引き継ぎ

- EC の post-commit フック（version 自動更新・`--amend`）。統合リポジトリに持ち込むなら、**アプリ単位のバージョンか全体のバージョンか**を決める
- EC の CLAUDE.md にある「vault 同期ルール」（どの変更でどのノートを更新するか）は、統合後は仕入側のノート（[[Airtable再構築 - 00 概要]] 系）も対象に広げる必要がある
- EC の AGENTS.md（`next dev` が自動で書き込む Next.js エージェント規約）は統合先でも再生成される
