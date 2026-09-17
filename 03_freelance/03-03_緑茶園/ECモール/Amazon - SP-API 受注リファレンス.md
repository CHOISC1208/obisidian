---
tags:
  - 緑茶園
  - ECモール
  - API仕様
client: 緑茶園グループ
関連テーマ: テーマ1 - 受注チャネル統合とツール複数人化
created: 2026-09-16
updated: 2026-09-16
aliases:
  - Amazon SP-API リファレンス
  - SP-API Orders
---

# Amazon SP-API Orders API 受注情報取得リファレンス

親: [[00 MOC|緑茶園グループ MOC]] ／ 関連テーマ: [[テーマ1 - 受注チャネル統合とツール複数人化]]

> [!info] このノートの位置づけ
> Amazon の受注を API でどこまで取れるかを整理した**調査ノート**（調査日 2026-09-16、出典は本文中のリンク）。
> 用途は [[platform - 00 概要|統合コンソール（ryokuchaen-platform）]] の EC 機能（旧 [[platform - 09 受注機能（旧 EC Channel Console）|EC Channel Console]]。2026-09-15 に platform へ移行済み）の受注取り込み設計と、PowerAutomate 置換（Amazon純正フォーマットCSV出力、→ [[platform - 10 変換器構想とMDC出力]]）の実現可否の判断。
> 緑茶園にとっての含意と、現行実装との突き合わせは冒頭の「緑茶園・統合コンソールへの含意」にまとめた。§1 以降は緑茶園に依存しない API 仕様の整理。
>
> **対象環境**：Amazon.co.jp（MarketplaceId `A1VC38T7YXB528`）／ SP-APIリージョン `fe`（極東）／ LWA リフレッシュトークン認証
> 実際のセラーIDは [[山形eLab・果逢]] を参照（§2.1 の `A1B2C3D4E5F6G7` はダミー値）。認証情報の取得手順は [[各モール API認証情報の取得手順]]。

## 緑茶園・統合コンソールへの含意

> [!warning] 2026-09-16 現行実装との突き合わせ（`ryokuchaen-platform` main `571d222` 時点・`lib/ec/clients/amazon.ts`。移植元の `multi-channel-order-fetcher` から同じ実装を引き継いでいる）
> | 観点 | 現行実装 | このリファレンスとの差 |
> |---|---|---|
> | APIバージョン | Orders **v0**（`getOrders` → 先頭20件だけ `getOrderItems`） | v0 は deprecated。新規開発は v2026-01-01 推奨（§7）→ 廃止日が未発表のため、**まず v0 のまま実データで照合し、その後に移行**する（照合前に版を変えると失敗原因の切り分けが難しくなる） |
> | 認証ヘッダ名 | **`x-amzn-access-token`** | 公式は **`x-amz-access-token`**（§2.2）。**実データでの照合が未了のチャネル**なので、この差で 403 になる可能性がある。~~要確認~~ → **2026-09-16 公式どおりに是正** |
> | ページング | `MaxResultsPerPage=50`、`NextToken` 未処理 | 51件目以降を取りこぼす（§6.2）→ **2026-09-16 是正**（100件／ページで `NextToken` を最大5ページ辿る。明細を取るのは先頭20件のまま） |
> | 取得軸 | `CreatedAfter` のみ | ステータス変更（出荷済・キャンセル）を拾うには `LastUpdatedAfter` の併用が必要（§6.2）→ 画面は都度取得して保存しない「直近N日の作成分」の確認用なので**当面は変えない**。定期取り込みを作るときに併用する |
> | 氏名 | `BuyerInfo.BuyerName ?? ShippingAddress.Name ?? "(非公開)"` | RDT も restricted ロールも無いので、実運用では**常に「(非公開)」になる**と見込まれる（§4） |
> | Pending 注文の金額 | 考慮なし | `Pending` は明細の価格・税・送料が返らない（§3.2） |

> [!important] PowerAutomate 置換（Amazon純正フォーマットCSV出力）の前提になる論点
> easyECS に取り込んで**出荷（送り状発行）まで流すには配送先の氏名・住所・電話が要る**。SP-API でそれを取るには：
> 1. アプリに **Direct to Consumer Delivery (Restricted)** ロールを付与する審査（開発者プロファイル＋データセキュリティ審査）を通す
> 2. 対象が **FBM（自己配送）注文であること**。FBA 注文は日本ではどのロールでも氏名・住所は取れない（§4.2）
>
> つまり「API で取れる」の射程は**審査を通した場合の FBM 注文のみ**。現状の PowerAutomate が何を元に CSV を作っているか（注文レポートか、セラーセントラルのダウンロードか）と、**緑茶園の Amazon 注文が FBM か FBA か**は未確認 → [[08 要確認事項]] に登録済み。
> 審査を避けたい場合の現実解は、受注の検知・明細・金額は API、住所は注文レポートや既存 CSV 経路に任せる分担。

---

## 1. 結論（TL;DR）

| 質問 | 答え |
|---|---|
| 注文本体（ステータス・日時・金額）は取れるか | **取れる**（非制限情報） |
| 注文明細（SKU・数量・単価・送料・税）は取れるか | **取れる**。ただし `Pending`（決済オーソリ前）の注文は金額系が返らない |
| 購入者・配送先の氏名/住所/電話は取れるか | **制限情報（PII）**。アプリへの restricted ロール付与審査 + RDT 発行が必須。取得できるのは **自己配送（FBM）のみ** |
| FBA注文の氏名・住所は？ | **原理的に取得不可**（郵便番号のみ可） |
| 購入者のメールアドレスは？ | 実アドレスではなく **Amazonが生成する匿名化アドレス** |
| クレジットカード番号は？ | **取得不可**（支払方法の区分のみ） |
| v0 を使ってよいか | v0 は **非推奨（deprecated）**。新規開発は **Orders API v2026-01-01** を推奨 |

---

## 2. 前提：認証とエンドポイント

### 2.1 手元の認証情報の役割

| 認証情報 | 役割 |
|---|---|
| `Atzr\|...`（リフレッシュトークン） | セラーセントラルでアプリを認可した際に発行。LWAトークン交換に使用 |
| `amzn1.application-oa2-client...`（クライアントID） | アプリID。クライアントシークレットとペアで使用 |
| `A1B2C3D4E5F6G7`（SellerId・ダミー値） | **Orders API の呼び出しパラメータには不要**。トークンに紐づく出品者権限で動作（デバッグ時の確認用） |
| `A1VC38T7YXB528` | MarketplaceId。`getOrders` の **必須** パラメータ `MarketplaceIds` に指定 |
| `fe` | SP-APIリージョン。エンドポイントは `https://sellingpartnerapi-fe.amazon.com` |

### 2.2 呼び出しの流れ

1. LWAトークン交換：`POST https://api.amazon.com/auth/o2/token` に `grant_type=refresh_token` + リフレッシュトークン + クライアントID/シークレット → 有効期限約1時間のアクセストークン
2. SP-API呼び出し：`x-amz-access-token` ヘッダにアクセストークンを設定

```bash
# 1) トークン交換
curl -s https://api.amazon.com/auth/o2/token \
  -d grant_type=refresh_token \
  -d refresh_token="Atzr|..." \
  -d client_id="amzn1.application-oa2-client...." \
  -d client_secret="..."

# 2) 受注取得（日本）
curl -s "https://sellingpartnerapi-fe.amazon.com/orders/v0/orders?MarketplaceIds=A1VC38T7YXB528&CreatedAfter=2026-09-15T00:00:00Z" \
  -H "x-amz-access-token: <アクセストークン>"
```

### 2.3 依存する操作とロール

`getOrders` / `getOrder` / `getOrderItems` は多くのロールのいずれか1つがあれば呼べる（Inventory and Order Tracking, Finance and Accounting, Amazon Fulfillment など）。一方 **PII系操作・PII項目は restricted ロールの承認と RDT が別途必要**（§4）。

---

## 3. 取得できる項目（非制限情報）

出典：公式スキーマ定義 [ordersV0.json](https://github.com/amzn/selling-partner-api-models/blob/main/models/orders-api-model/ordersV0.json)

### 3.1 注文ヘッダ（`getOrders` / `getOrder`）

| カテゴリ | フィールド | 内容 |
|---|---|---|
| 識別 | `AmazonOrderId` | 受注ID（3-7-7形式） |
| | `SellerOrderId` | 出品者側の注文番号 |
| | `MarketplaceId` | 注文が発生したマーケットプレイス |
| 日時 | `PurchaseDate` | 受注日時 |
| | `LastUpdateDate` | 最終更新日時（差分取得のキー） |
| 状態 | `OrderStatus` | `Pending` / `Unshipped` / `PartiallyShipped` / `Shipped` / `InvoiceUnconfirmed` / `Canceled` / `Unfulfillable` / `PendingAvailability` |
| 数量 | `NumberOfItemsShipped` / `NumberOfItemsUnshipped` | 出荷済/未出荷点数 |
| 金額 | `OrderTotal` | 注文合計金額 |
| 出荷区分 | `FulfillmentChannel` | `MFN`（自己配送）/ `AFN`（FBA） |
| 支払 | `PaymentMethod` | `COD`（代金引換）/ `CVS`（コンビニ払い）区分のみ |
| | `PaymentMethodDetails` | 支払方法のリスト |
| | `PaymentExecutionDetail` | COD等のサブ支払明細 |
| 出荷約束 | `EarliestShipDate` / `LatestShipDate` | 出荷約束ウィンドウ（MFNのみ） |
| | `EarliestDeliveryDate` / `LatestDeliveryDate` | お届け約束ウィンドウ（MFNのみ） |
| 便種 | `ShipServiceLevel` | 出荷サービスレベル |
| | `ShipmentServiceLevelCategory` | `Standard` / `NextDay` / `Expedited` / `Scheduled` / `SameDay` 等 |
| プログラム | `IsPrime` | セラー配送Prime注文 |
| | `IsBusinessOrder` | Amazon Business注文 |
| | `IsPremiumOrder` | プレミアム便 |
| | `IsISPU` | 店舗受け取り |
| | `IsAccessPointOrder` | 受け取り場所（ロッカー等）指定 |
| | `IsReplacementOrder` / `ReplacedOrderId` | 再注文（交換・代替） |
| 配送元 | `DefaultShipFromLocationAddress` | チェックアウト時の推奨出荷元住所 |
| | `FulfillmentInstruction` | 充当指示（出荷元ロケーション等） |
| その他 | `HasRegulatedItems` | 規制品フラグ |
| | `AutomatedShippingSettings` | 自動出荷設定の情報 |
| | `SalesChannel` / `OrderChannel` / `OrderType` / `CbaDisplayableShippingLabel` | 補助情報（多くは未使用） |

### 3.2 注文明細（`getOrderItems`）

| カテゴリ | フィールド | 受注管理での用途 |
|---|---|---|
| 商品特定 | `ASIN` / `SellerSKU` / `OrderItemId` / `Title` | 自社SKU突合・商品名 |
| 数量 | `QuantityOrdered` / `QuantityShipped` | 引当・残数管理 |
| 金額 | `ItemPrice` | 商品単価×数量 |
| | `ShippingPrice` | 送料 |
| | `ItemTax` / `ShippingTax` | 税額 |
| | `ShippingDiscount` / `ShippingDiscountTax` | 送料割引 |
| | `PromotionDiscount` / `PromotionDiscountTax` / `PromotionIds` | プロモーション・クーポン |
| | `PointsGranted` | Amazonポイント付与（点数・価値） |
| | `CODFee` / `CODFeeDiscount` | 代引き手数料 |
| 条件 | `ConditionId` / `ConditionSubtypeId` / `ConditionNote` | 新品/中古等 |
| ギフト | `IsGift` | ギフト注文 |
| 日時指定 | `ScheduledDeliveryStartDate` / `ScheduledDeliveryEndDate` | 配達日時指定 |
| FBA関連 | `SerialNumbers` | FBAのシリアル管理品 |
| | `IsTransparency` | Transparency参加（シリアル照合） |
| 税 | `TaxCollection` | 源泉税（マーケットプレイス徴収）区分 |
| 制約 | `ShippingConstraints` / `ShippingRequirements` | 出荷制約 |
| その他 | `BuyerRequestedCancel` | 購入者によるキャンセル依頼 |
| | `BuyerInfo`（明細側） | カスタマイズ情報等（制限情報、§4） |

> [!important] `Pending` 注文は金額が返らない
> `Pending` 状態（注文済み・決済オーソリ前）の注文に対する `getOrderItems` は、**価格・税・送料・ギフト・プロモーションを返さない**。決済承認後（`Unshipped` 以降）に取得可能（[getOrderItems リファレンス](https://developer-docs.amazon.com/sp-api/reference/getorderitems)）。

---

## 4. 制限情報（PII）：氏名・住所・電話

### 4.1 v0 での扱い

`BuyerInfo`（購入者氏名・メール）と `ShippingAddress`（氏名・住所行・電話）は restricted データ。アクセスには：

1. アプリへの **restricted ロール付与**（開発者プロファイル審査 + データセキュリティ審査）
2. 各注文IDごとの **RDT（Restricted Data Token）発行**
3. RDT付きで `getOrderAddress` / `getOrderBuyerInfo` / `getOrderItemsBuyerInfo` を呼び出し

RDTなしでは操作自体が 403 となり、`getOrder` レスポンス内の該当フィールドは **マスク/欠落** して返る（[Access Orders PII](https://developer-docs.amazon.com/sp-api/docs/access-orders-pii)）。

### 4.2 取得可否マトリクス（日本ストア）

出典：[Access Orders PII](https://developer-docs.amazon.com/sp-api/docs/access-orders-pii) の国別表（日本）

| 項目 | ロールなし | Tax Remittance / Tax Invoice ロール<br>（FBA / FBM） | Direct to Consumer Delivery (Restricted)<br>（FBA / FBM） |
|---|---|---|---|
| 購入者メール `buyerEmail` | × | × / × | **× / ○** |
| 購入者氏名 `buyerName` | × | × / × | **× / ○** |
| 配送先氏名 `deliveryAddress.name` | × | × / × | **× / ○** |
| 住所行1〜3 `addressLine1-3` | × | × / × | **× / ○** |
| 電話 `deliveryAddress.phone` | × | × / × | **× / ○** |
| 拡張住所 `extendedFields` | × | × / × | **× / ○** |
| **郵便番号** `postalCode` | **○** | **○ / ○** | **○ / ○** |
| ギフトメッセージ / カスタマイズURL | × | × / × | **× / ○** |
| 税務登録情報 `taxRegistrations` | × | ○ / ○ | × / × |

**読み方**：日本では

- **Tax系ロールでは氏名・住所は一切取れない**（米国・シンガポールも同様。この3か国固有の制限）
- 氏名・住所・電話が取れるのは **「Direct to Consumer Delivery (Restricted)」ロールを持ち、かつFBM（自己配送）注文のみ**
- **FBA注文はどのロールでも氏名・住所・電話は取れない**（郵便番号のみ）
- 郵便番号だけはロール不要で常に取れる

### 4.3 マスク・欠落の細則

| 現象 | 条件 |
|---|---|
| 電話番号が常に空 | **FBA（AFN）注文は全件抑制** |
| 電話番号が空 | FBMでも **最新お届け日（`LatestDeliveryDate`）を過ぎた出荷済注文** は抑制 |
| `ShippingAddress` 自体が返らない | ステータスが `Unshipped` / `PartiallyShipped` / `Shipped` / `InvoiceUnconfirmed` 以外（= `Canceled` 等） |
| 購入者メールが実アドレスでない | 仕様。Amazonが生成する **匿名化メールアドレス**（`xxx@marketplace.amazon.com` 形式） |

---

## 5. Orders API では取れない情報（担当API一覧）

| 受注管理に必要な情報 | Orders APIの可否 | 担当するAPI / 手段 |
|---|---|---|
| 入金・販売手数料・FBA手数料の実績（消込） | × | [Finance API](https://developer-docs.amazon.com/sp-api/docs/finance-api-reference)（`listFinancialEvents`）or 精算レポート |
| 出荷確定（送り状番号の登録・追跡番号通知） | ×（v0 Orders APIは状態更新のみ） | Feeds API（`POST_ORDER_ACKNOWLEDGEMENT_DATA`）または [confirmShipment](https://developer-docs.amazon.com/sp-api/docs/confirm-the-shipment-status) |
| FBA在庫数 | × | Inventory API（`getInventorySummaries`） |
| クレジットカード番号等の決済詳細 | **取得不可**（区分のみ） | —（存在しない） |
| 商品マスタ（画像・商品区分・重量等） | × | Catalog Items API / Catalog Items 2022（`searchCatalogItems`） |
| 購入者へのメッセージ | × | Messaging API |
| 2年以上前の注文 | **API応答に出ない** | 注文レポート（過去分はCSV取り込みで補完） |

> [!tip] 緑茶園の文脈では
> 送り状番号のモール返却は easyECS の「出口」側の価値（→ [[platform - 09 受注機能（旧 EC Channel Console）]]）。統合コンソールが担うのは入口なので、confirmShipment / Feeds API は当面スコープ外。

---

## 6. 実装上の注意

### 6.1 レート制限（デフォルト値）

| 操作 | レート | バースト | 実質 |
|---|---|---|---|
| `getOrders` | **0.0167 req/s** | 20 | **約1リクエスト/分**。1ページ最大100件 → 理論上 約6,000件/時 |
| `getOrder` / `getOrderItems` / `getOrderAddress` | 0.5 req/s | 30 | 1注文あたり1〜2回の個別取得は高速 |

出典：各操作のリファレンス（[getOrders](https://developer-docs.amazon.com/sp-api/reference/getorders) / [getOrder](https://developer-docs.amazon.com/sp-api/reference/getorder)）。大口出品でスループットが必要な場合は **注文レポート**（`GET_FLAT_FILE_ALL_ORDERS_DATA_BY_LAST_UPDATE_GENERAL` 等）との併用が定石。

### 6.2 ポーリング設計（抜け漏れ対策）

- **新規受注**：`CreatedAfter` で作成ベース取得
- **ステータス変更**（出荷済み化・キャンセル等）：`LastUpdatedAfter` で更新ベース取得を併行
- `NextToken` によるページングは必須（`MaxResultsPerPage` 1〜100）
- 注文抜け回避ロジックはAmazon公式が動画・ガイドで解説しているテーマ（二重ポーリング推奨）

### 6.3 その他

- `MarketplaceIds` は必須パラメータ（単一指定なら `A1VC38T7YXB528`）
- `BuyerEmail` / `SellerOrderId` / `AmazonOrderIds` 等による検索フィルタあり（ただし `BuyerEmail` は匿名化メールのみ有効）
- 日時パラメータはISO 8601（`2026-09-15T00:00:00+09:00` など）
- トークン交換は1時間ごと。401時は再取得→リトライを実装

---

## 7. Orders API v2026-01-01（v0 からの移行）

v0 は **非推奨（deprecated）**。廃止日は公式に明示されていないが、新規開発は新版での実装を推奨（[移行ガイド](https://developer-docs.amazon.com/sp-api/docs/orders-api-migration-guide)）。

### 7.1 新版の利点

| 利点 | 内容 |
|---|---|
| 呼び出し回数の削減 | `includedData` パラメータ1回で明細・購入者・住所・金額内訳まで取得 |
| **RDT不要** | PIIアクセスはロール付与のみで可（v0のRDT発行プロセス廃止） |
| 柔軟な取得 | `includedData` = `BUYER` / `RECIPIENT` / `FULFILLMENT` / `PROCEEDS` / `EXPENSE` / `PROMOTION` / `CANCELLATION` / `PACKAGES` / `TAX` / `PAYMENT` |
| 配送追跡 | `packages[]` で配送業者・追跡番号・配送状況（`IN_TRANSIT` / `DELIVERED` 等）を取得可 |
| 一括同期 | `searchOrders` が `includedData` 対応（v0の `getOrders`→個別 `getOrder` の二段構成が不要） |

### 7.2 v0 からの主な変更点

| 項目 | v0 | v2026-01-01 |
|---|---|---|
| 操作名 | `getOrders` / `getOrder` / `getOrderItems` / `getOrderBuyerInfo` / `getOrderAddress` | `searchOrders` / `getOrder`（明細は常に同梱）/ `getOrder` + `includedData=BUYER` / `getOrder` + `includedData=RECIPIENT` |
| ステータス値 | `Unshipped` / `Canceled` 等 | `UNSHIPPED` / `CANCELLED`（Upper snake case・綴り変更） |
| チャネル | `MFN` / `AFN` | `MERCHANT` / `AMAZON` |
| ページングトークン | 無期限 | **24時間で失効** |
| `BuyerEmail` 検索パラメータ | あり | **廃止** |
| `PaymentMethods` 検索パラメータ | あり | **廃止** |
| PIIの取り方 | RDT + restrictedロール | ロールのみ（条件：FBM注文のみ等は同じ。日本ではTaxロールでも氏名・住所不可も同じ） |
| フラグ類 | `IsPrime` / `IsBusinessOrder` 等 | `programs[]` 配列に統合（`PRIME` / `AMAZON_BUSINESS` / `PREORDER` 等） |

### 7.3 v0 → v2026 フィールド対応（主要項目）

| v0 | v2026-01-01 |
|---|---|
| `AmazonOrderId` | `orderId` |
| `PurchaseDate` / `LastUpdateDate` | `createdTime` / `lastUpdatedTime` |
| `OrderStatus` | `fulfillment.fulfillmentStatus` |
| `FulfillmentChannel` | `fulfillment.fulfilledBy` |
| `OrderTotal` | `proceeds.grandTotal`（`includedData=PROCEEDS`） |
| `ShippingAddress` | `recipient.deliveryAddress`（`includedData=RECIPIENT`） |
| `BuyerInfo` | `buyer`（`includedData=BUYER`） |
| `Earliest/LatestShipDate` / `Earliest/LatestDeliveryDate` | `fulfillment.shipByWindow` / `deliverByWindow` |
| `PaymentMethod` / `PaymentExecutionDetail` | `payment.paymentExecutions[]`（`includedData=PAYMENT`） |

---

## 8. 参考リンク

| ドキュメント | URL |
|---|---|
| Orders API v0 スキーマ定義（全フィールド） | https://github.com/amzn/selling-partner-api-models/blob/main/models/orders-api-model/ordersV0.json |
| Orders API v2026-01-01 スキーマ定義 | https://github.com/amzn/selling-partner-api-models/blob/main/models/orders-api-model/orders_2026-01-01.json |
| Orders API ユースケースガイド | https://developer-docs.amazon.com/sp-api/docs/orders-api-v0-use-case-guide |
| Access Orders PII（PII取得条件・国別表） | https://developer-docs.amazon.com/sp-api/docs/access-orders-pii |
| v0 → v2026-01-01 移行ガイド | https://developer-docs.amazon.com/sp-api/docs/orders-api-migration-guide |
| getOrders リファレンス（レート制限含む） | https://developer-docs.amazon.com/sp-api/reference/getorders |
| getOrder リファレンス | https://developer-docs.amazon.com/sp-api/reference/getorder |
| getOrderItems リファレンス | https://developer-docs.amazon.com/sp-api/reference/getorderitems |
| 注文レポートのフィールド定義（セラーセントラル） | https://sellercentral.amazon.co.jp/help/hub/reference/external/G201648780 |

## 関連ノート

- [[platform - 09 受注機能（旧 EC Channel Console）]] — Amazon を含む7チャネルの実装状況（移行前の案件ノート）
- [[platform - 00 概要]] — 移行先の統合コンソール
- [[各モール API認証情報の取得手順]] — `AMAZON_LWA_APP_ID` 等の取得手順（先方配布用）
- [[platform - 10 変換器構想とMDC出力]] — PowerAutomate置換（純正フォーマットCSV出力）の構想
- [[クロスモール（I'LL社）]] — クロスモールは Amazon を注文レポートの定期ダウンロードで取得している（API直呼びとの対比）
- [[Temu - Open Platform 受注リファレンス]] — 同じ形式で整理した Temu 版（PIIの扱いを対比）
- [[LINEギフト - API 受注リファレンス]] — 同じ形式で整理した LINEギフト 版
