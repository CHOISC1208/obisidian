---
tags:
  - 緑茶園
  - 案件
  - platform
  - 統合調査
  - データモデル
client: 緑茶園グループ
created: 2026-09-14
updated: 2026-09-14
---

# 概念が重なるテーブルと型

親: [[platform - 00 概要]] ／ 関連: [[Airtable再構築 - ヒアリング回答ログ]]（SKUの正体）・[[platform - 10 変換器構想とMDC出力]]（SKU対応表の由来）

> [!info] 先に全体像
> 2つのアプリは**扱っている業務の向きが逆**。inventory は「生産者から**買う**」側、EC は「顧客に**売った**注文」側。
> そのため同じ単語（商品・SKU・取引先・マスタ）でも指しているものが違い、**素朴に結合すると誤った結果が出る**箇所がある。

## 対応表

| 概念 | inventory | EC Channel Console | 重なり方 |
|---|---|---|---|
| **商品** | `inventory.products`（2,894件）。**仕入単位**＝取引先×規格8要素×`variant_no` | 永続化された商品マスタは無い。明細に `product_name`・`sku` を文字列で持つだけ | 🔴 別物。粒度が違う |
| **商品コード／SKU** | `products.product_code`＝`0014-`＋(100＋autoNumber) | `order_backlog_lines.sku`（easyECS の商品コード）、`manual_order_lines.source_sku`／`resolved_sku` | 🔴 **文字列が一致するのに別商品**（下記） |
| **外部コードの対応** | `inventory.marketplace_codes`（`product_id`, `channel`, `code`）。**0件・空の器** | `manual_order_sku_map`（`destination`, `source_sku` → `resolved_sku`）。0件 | 🟡 目的は近いが、向きと解決先が違う |
| **取引先** | `inventory.partners`（35件）。**仕入先**（生産者・卸） | 該当なし。販売側は `ChannelId`（7モール）・`store`（easyECS のストア名テキスト）・`destination`（`mdc`/`other`） | 🟡 名前が衝突しうる |
| **顧客** | 持たない | `ChannelOrder.customerName`（画面表示のみ・**保存しない**。個人情報を持たない方針） | — |
| **取引・明細** | `inventory.transactions`（入荷伝票の行） | `order_backlog_lines`／`manual_order_lines`（受注明細の写し）／`ChannelOrderItem`（API応答・非保存） | 🟢 業務が別。共通化しない |
| **取込の1回分** | 抽出の実行（テーブルは無く、`migration_issues.extracted_at` で表す） | `order_backlog_snapshots`／`manual_order_batches`（uuid、`imported_at`、`imported_by`、件数、警告 jsonb） | 🟢 型は似ている。共通の「取込ログ」にまとめる余地 |
| **品質・警告** | `inventory.migration_issues`（`severity`：blocker/warning/info、`detail` jsonb） | `parse_warnings` jsonb・`rejected_rows` jsonb | 🟢 同上 |
| **ログ** | `inventory.audit_logs`（**変更履歴**：前後の値＋`changed_by`） | `multi_channel_order_fetcher_logs`（**エラーログ**。監査証跡ではない） | 🟡 名前は似ているが目的が違う。EC は監査証跡が先方要望の筆頭で未着手 → inventory の仕組みが流用候補 |
| **設定・マスタ** | 規格マスタ8種・取引先・商品（業務データ） | `multi_channel_order_fetcher`（チャネル認証情報の key/value）。画面名は「マスタ設定」 | 🟡 「マスタ」の意味が違う |
| **税・金額** | `tax_rates`、`unit_price numeric(12,2)`、税率別集計ビュー | `ChannelOrder.totalAmount`・`unitPrice`（number、非保存） | 🟢 重ならない |

## 🔴 商品コードの見かけの一致（2026-09-14 実データで確認）

easyECS 受注CSVの SKU は `mm-101-th-aozora`・`rg-149-10-2`・`pio-104-2` のように**品目略号＋番号**が大半だが、**10個だけ `0014-` で始まる**。これは inventory の `product_code` と同じ書式である。そこで突き合わせた。

| SKU | easyECS 側の商品名（受注残） | inventory の同じコード | 同じ商品か |
|---|---|---|---|
| `0014-101` | 山形県産ラフランス＆ふじりんごセット3kg | 無し | — |
| `0014-102` | 訳あり 山形県産ラフランス 2kg | 無し | — |
| `0014-103` | 山形県産 秀品 ラフランス 2kg | **ぶどう オリエンタルスター 秀 500g DB 2入**（高橋慎吾） | ❌ 別物 |
| `0014-103-th` | 洋梨 ラフランス 秀品 2kg … | （接尾辞を外すと上と同じ） | ❌ |
| `0014-104` / `-th` | ラフランス 3kg | 無し | — |
| `0014-105` | 山形県産 秀品 ラフランス 5kg | **ぶどう シャインマスカット 秀 170g カップ 1入**（高橋慎吾） | ❌ 別物 |
| `0014-105-th` | 洋梨 ラフランス 秀品 5kg … | （接尾辞を外すと上と同じ） | ❌ |
| `0014-111` | 【お徳用】山形産 ラフランス 5kg | **ぶどう シャインマスカット 秀 500g DB 2入**（元木洋介） | ❌ 別物 |
| `0014-113` | 山形県産 サンふじりんご＆ラフランス セット 2kg | **ぶどう シャインマスカット 秀 600g DB 1入**（元木洋介） | ❌ 別物 |

> [!danger] `product_code = sku` で結合してはいけない
> **4件が文字列として完全一致し、4件とも別の商品**。`-th` 接尾辞を外すと6件になる。
> [[Airtable再構築 - ヒアリング回答ログ]] で判明したとおり、inventory の `0014-` は Airtable が自動採番した**社内の連番**である（商品コードAが全件固定の `0014-`、Bが autoNumber）。一方 easyECS の SKU は販売側で別に採番されている。`0014-` という同じ接頭辞を、**2つの独立した採番体系が偶然共有している**と考えるのが妥当。
> ただし `0014` が何を意味するのか（会社コードか等）は両側とも未確認。→ [[08 要確認事項]] の「既存の商品コード・SKU表記は他システムと参照・突合されているか」に直結する

### 粒度も合わない

- inventory の商品は**仕入単位**（生産者ごと・規格ごと。ラフランスを「秀 5kg」で仕入れる）
- easyECS の SKU は**販売単位**（「ラフランス＆ふじりんごセット3kg」「訳あり 2kg」）。セット品は複数の仕入商品から成る
- つまり関係は **N:M**（構成表）であり、`marketplace_codes` が想定する「1仕入商品 : N モールコード」の形にも収まらない可能性がある

### 「自社SKU」の意味も違う

EC の `manual_order_sku_map.resolved_sku` のコメントは「自社SKU」だが、中身は **easyECS の商品コード**（MDC 出力の相手先で使うコード）。inventory の `product_code` ではない。統合コンソールで「自社SKU」という言葉を使うなら、どちらを指すか決める必要がある。

## TypeScript の型

どちらも **DB 列は snake_case、TS の型は camelCase** で揃っている。変換は手書き（型生成は使っていない）。

| 型 | ファイル | 内容 |
|---|---|---|
| `PartnerOption` `ProductOption` `TransactionRow` `TaxTotal` `ReceiptInput` `TransactionEditInput` | inventory `lib/inventory/types.ts` | 画面と Server Action の受け渡し。id は `number`（bigserial） |
| `ActionResult { ok, message }` `FormState { error, message? }` | 同上 | 結果の形。`useActionState` 前提 |
| `PaymentStatus` と各種 `*_LABELS` | inventory `lib/inventory/constants.ts` | DB の check 制約の値と日本語ラベル |
| `ChannelOrder` `ChannelOrderItem` `ChannelClient` | EC `lib/channels/types.ts` | 全チャネルの正規化先。保存しない |
| `ChannelError` `ChannelErrorCode` | 同上 | エラーの共通契約（HTTPステータスと対応） |
| `BacklogLine` `BacklogSource` | EC `lib/backlog/types.ts` | 受注残の正規化明細。ソース（CSV / SQL Server）に依存しない |
| `ManualOrderLine` `ManualOrderDestination` | EC `lib/manual-orders/types.ts` | 手動取り込みの明細。`sourceSku` と `resolvedSku` |
| `ChannelDefinition` `CredentialField` | EC `lib/channels/registry.ts` | チャネル定義を唯一の情報源にする |

重なりそうな点：

- **id の型**：inventory は全部 `number`。EC は取込の1回分が `uuid`（`string`）、明細が bigserial
- **日付**：どちらも `'YYYY-MM-DD'` の文字列で扱う（inventory は `pg` の DATE パーサを文字列のままにしている）。揃っている
- **数量**：inventory `quantity`（負の値あり＝返品）、EC `qty`（0以上）。列名が違う
- **結果・エラーの形が2種類**：`ActionResult`/`FormState` と `{ error: { code, message, detail } }`。統合時にどちらかへ寄せるか、Server Action 用と API 用で使い分けるかを決める
- **CSV**：EC に `lib/csv/`（RFC4180パーサ、CP932/UTF-8 自動判定）がある。inventory は CSV 出力のみ。取り込みと出力の共通部品にまとめられる
