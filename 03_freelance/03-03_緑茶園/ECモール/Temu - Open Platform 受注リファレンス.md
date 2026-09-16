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
  - Temu API リファレンス
  - Temu Open Platform
---

# TEMU Open Platform API 受注情報取得リファレンス

親: [[00 MOC|緑茶園グループ MOC]] ／ 関連テーマ: [[テーマ1 - 受注チャネル統合とツール複数人化]]

> [!info] このノートの位置づけ
> TEMU（テミュ）の出品者受注を API で取り込めるかを整理した**調査ノート**（調査日 2026-09-16、出典は本文中のリンク）。
> 用途は [[platform - 00 概要|統合コンソール（ryokuchaen-platform）]] の EC 機能（旧 [[EC Channel Console - 00 概要|EC Channel Console]]。2026-09-15 に platform へ移行済み）で**スタブのまま止まっている Temu チャネルの実装判断**。
> 緑茶園にとっての含意と、現行実装との突き合わせは冒頭の「緑茶園・統合コンソールへの含意」にまとめた。§1 以降は緑茶園に依存しない API 仕様の整理。
>
> **情報の性格**：注釈がない限り TEMU 公式ドキュメント（Temu Partner Platform）の記載に基づく。**※印は第三者資料（ERPベンダー・統合ベンダー）による補足で、要確認事項**。
> 姉妹ノート：[[Amazon - SP-API 受注リファレンス]]（§5 で PII の扱いを対比）

## 緑茶園・統合コンソールへの含意

> [!important] これまでの「Temuは対応状況自体が不明」は解消。ブロッカーは「APIがあるか」から「アプリ審査」と「店舗モデル」に移った
> [[EC Channel Console - 00 概要]]（移行前の案件ノート）では Temu を「クロスモールの連携資料も見つからず、対応状況自体が不明」としていた。この調査で**出品者向けの公式 受注API は存在する**ことが確認できた。残る論点は次の3つ。
> 1. **緑茶園の Temu 店舗はどの販売モデルか。** 全托管（TEMUが発送）なら受注APIで取る対象がそもそも無い（§2.1）。現状「コピー＆ペーストで受注処理している」（[[04 ツールリファレンス]]）ので自社発送＝**本土店か半托管の可能性が高いが未確認**
> 2. **アプリ登録と審査が要る。** Partner Platform で Self-developed アプリを作り、セキュリティ・コンプライアンス質問票の審査を通し、出品者がセラーセンターで認可して初めて `access_token` が出る（§2.2）。Yahoo!（1〜2週間）と同様に**リードタイムを見込んで先に着手すべき**
> 3. **日本本土店の router ホストが未確認。** GLOBAL／US は判明しているが、日本はオンボーディング時に公式確認が必要（§7-7）

> [!warning] 2026-09-16 現行実装との突き合わせ（`ryokuchaen-platform` main `571d222` 時点・`lib/ec/clients/temu.ts`。移植元の `multi-channel-order-fetcher` も同じスタブ）
> | 観点 | 現行実装 | このリファレンスから見えること |
> |---|---|---|
> | 受注取得 | **スタブ**（`fetchOrders` は未実装エラー） | `bg.order.list.v2.get` で親注文＋子明細が取れる（§4） |
> | 認証情報の項目 | `TEMU_APP_KEY` / `TEMU_APP_SECRET` / `TEMU_ACCESS_TOKEN` | 共通パラメータ（`app_key` / `access_token` / MD5 `sign`）と整合（§3.2）。**不足候補は router ホスト（またはリージョン）と `regionId`** |
> | トークン期限 | 考慮なし（固定値を保存するだけ） | `access_token` に有効期限あり。期限前の再認可が要る※（§7-4）。LINEギフトのような refresh_token 自動更新ではなく、**出品者による再認可**になる可能性 |
> | 取得間隔 | 他チャネルと同じく画面操作時に取得 | 出荷期限は注文時刻起算で、追跡番号登録は24時間以内が基準※（§6・§7-1）。**受注残ボード的な使い方をするなら短周期の差分取得か Webhook が要る** |

> [!warning] 住所（PII）は「送り状作成時に取得し、長期保存しない」が運用指針※
> 配送先の氏名・住所は注文APIとは別スコープ・別API（§5）。第三者資料によれば**長期保存するとデータレビューで失格になりうる**。
> [[EC Channel Console - 変換器構想とMDC出力|MDC出力]] で easyECS に住所ごと投入する構想や、Supabase に受注明細を保存する設計とは**緊張関係がある**。Temu をMDC投入対象に含める前に、保存の範囲（住所を持たない／期限付きで消す）を決める必要がある。

> [!tip] 出口側（追跡番号の返却）は Temu API で自前化できる
> [[テーマ1 - 受注チャネル統合の方向性協議|2026-09-16 テーマ1協議]] で未回答だった「easyECS は Temu への送り状番号返却に対応しているか」が No の場合でも、`bg.logistics.shipment.confirm`（§6）で統合コンソール側から返却する道はある。ただし配送業者は公式対応リストとの照合と追跡番号の形式チェックがあり※、ヤマト（B2）の番号が通るかは要確認。

---

## 1. 結論（TL;DR）

| 質問 | 答え |
|---|---|
| TEMUに出品者向けAPIはあるか | **ある**。公式は「Temu Open Platform / Partner Platform」（[partner.temu.com](https://partner.temu.com/)）として提供 |
| 誰でも即APIを使えるか | **できない**。パートナー（ISV/自社開発）としてアプリ登録→審査（セキュリティ・コンプライアンス質問票）→出品者がセラーセンターで認可、という手順が必須（§2） |
| 受注情報は取れるか | **取れる**。注文リスト（`bg.order.list.v2.get`）で親注文+子注文明細、注文詳細（`bg.order.detail.v2.get`）で個別取得（§4） |
| 購入者・配送先の氏名/住所は？ | 注文APIとは **別スコープ・別API**（`bg.order.shippinginfo.v2.get`）+機密フィールドは復号専用API（`bg.order.decryptshippinginfo.get`）（§5）※ |
| 出荷確定（追跡番号通知）は？ | Fulfillment API（`bg.logistics.shipment.confirm`）で対応。TEMUは24時間以内の追跡番号登録を要求※ |
| Amazon SP-APIとの大きな違い | Pinduoduo系の **RPCルーター形式**（全APIが `POST /openapi/router` に `type` でメソッド名を渡す）、MD5署名、権限パッケージ単位の認可、**Webhook（イベント通知）あり** |
| 最大の注意点 | **全托管（完全委託）出品の場合、受注はTEMU側で完結しAPIで取る対象が存在しない**。API受注管理が意味を持つのは **半托管/本土店（自社発送）** のみ（§2.1） |

---

## 2. 前提：TEMUの販売モデルとAPIの位置づけ

### 2.1 三つの販売モデル

| モデル | 出荷者 | 受注管理の要否 | API対応 |
|---|---|---|---|
| **全托管**（Fully managed） | TEMU（出品者は納品のみ） | 受注業務なし（TEMUが買取り・販売） | 受注APIの対象外 |
| **半托管**（Semi managed / 越境EC） | **出品者**（国内発送相当） | **必要** | 注文・物流APIあり（越境店は `agentseller.temu.com` 系） |
| **本土店 / Local**（日本本土店・米国本土店等） | **出品者** | **必要** | 注文・物流APIあり（`seller.temu.com` 系） |

出典※：[マBangERP操作マニュアル](https://help.mabangerp.com/kbzx/nested/details?id=2892&resource_id=1)・[datacaciques解説](https://www.datacaciques.com/blog/industry/101190)（「全托管はTemu統一発送、半托管は seller 自室発送」）。日本の店舗（本土店）は自社発送のため受注取り込みの対象になる。

### 2.2 アクセス取得の全体像（公式）

[Registration Overview](https://partner.temu.com/documentation?menu_code=52ef88bdef1d4527b15f6d303b173e48) より：

1. **Partner Profile の作成** — Partner Platform（partner.temu.com = GLOBAL / partner-us.temu.com = US / partner-eu.temu.com = EU）で登録
2. **最初のアプリ作成** — アプリ種別には ERP ほか「Self-developed（自社開発アプリ）」もあり
3. **コンプライアンス・セキュリティ質問票** の申請・審査
4. **アプリ公開（App Store）** または自社利用
5. **出品者による認可** — セラーセンターの認可画面（越境半托管店：`agentseller.temu.com/main/system-manage/client-manage` / 本土店：`seller.temu.com/open-platform/client-manage`）でアプリを選び **権限（スコープ/インターフェース単位）** にチェック → `access_token` が発行される※（[易倉ERP授权説明](https://ecwiki.eccang.com/docs/show/3709)）

> [!important] Authorization が最重要
> 権限スコープは「注文 / 出荷・追跡 / 商品・在庫 / 配送先住所」など単位ごとに分かれており、**トークン発行後にスコープを追加した場合は再認可・トークン再発行が必要**。住所スコープ無しで発行したトークンでは注文は取れるが住所が空になる（§5）※（[InfiPlex解説](https://infiplex.com/temu-open-platform-api-order-lifecycle)）

---

## 3. プロトコル（共通仕様）

出典：公式 [bg.order.list.v2.get](https://partner.temu.com/documentation?menu_code=fb16b05f7a904765aac4af3a24b87d4a&sub_menu_code=554fd46b45ee49269cbdd6d4008a5dc1)（Common Parameters 章・最終更新 2026-08-04）

### 3.1 エンドポイント（ルーター形式）

全APIが単一のルーターURLにPOSTし、`type` パラメータでメソッド名を指定する（Pinduoduo POP系の方式）：

| 項目 | 値 |
|---|---|
| 方式 | `POST https://openapi-b-global.temu.com/openapi/router`（GLOBALサイト） |
| 米国ローカル | `openapi-b-us.temu.com` が別ホストとして存在※ |
| リージョン指定 | パラメータ `regionId`（例：USA = 211） |

### 3.2 共通パラメータ（公式）

| パラメータ | 型 | 必須 | 説明 |
|---|---|---|---|
| `type` | STRING | ○ | APIメソッド名（例：`bg.order.list.v2.get`） |
| `app_key` | STRING | ○ | アプリのキー |
| `access_token` | STRING | ○ | 出品者認可で発行されたセキュアトークン |
| `sign` | STRING | ○ | 署名。対応方式は **MD5**（`sign_method=md5`）※ |
| `timestamp` | STRING | ○ | UNIX秒（10桁）。**現在時刻の±300秒以内** という有効性チェック |
| `data_type` | STRING | − | レスポンス形式。JSON固定 |
| `version` | STRING | − | APIバージョン（省略時 V1） |

署名方式の詳細は公式「Signature Method for API request」（[partner-eu](https://partner-eu.temu.com/documentation?menu_code=98501210a0cc465695e6d94e364bb83c&sub_menu_code=51bad7095f434b198df3996d3f2adfa1)）参照 — リクエストパラメータ群をMD5で署名する方式。

### 3.3 権限パッケージ（公式・注文APIの場合）

| パーミッションパッケージ | アプリ種別 |
|---|---|
| Semi Order Management | public |
| Order Management | private / public |
| Semi Seller In House System Management | private |

※「public = アプリストア公開型（ISV）」「private = 自社開発・専用アプリ」。

---

## 4. 取得できる項目（注文API）

### 4.1 注文APIファミリー（公式ドキュメントのOrderセクション）

| メソッド | 役割 |
|---|---|
| `bg.order.list.v2.get` | 注文リスト一括取得（親注文+子明細）。Local / Cross Border 両対応 |
| `bg.order.detail.v2.get` | 親注文1件の詳細（子明細・数量・SKU・出荷期限等） |
| `bg.order.shippinginfo.v2.get` | 注文の **配送先氏名・住所**（PII・別スコープ） |
| `bg.order.decryptshippinginfo.get` | 住所の **機密フィールドを平文で復号** 取得（PII） |
| `temu.order.amount.v2.query` / `bg.order.amount.query` | 注文金額照会（V1/V2/V3） |
| `bg.order.combinedshipment.list.get` | **同梱（まとめ発送）グループ** の取得 — 同一購入者の複数親注文を1箱化 |
| `bg.order.customization.get` | カスタマイズ（名入れ等）商品の個人化テキスト・ファイル |
| `temu.local.order.verification.upload` | Local注文の認証（検証）アップロード |

他のセクション：Authorization / Product / Price / Order Cancellation / Fulfillment / Return and Refund / Promotion / **Webhook** / Ads / Compliance — 商品・在庫・価格・キャンセル・返金・広告までAPIファミリーが分かれており、**Webhook（イベント通知）の仕組みも提供されている**。

### 4.2 `bg.order.list.v2.get` リクエスト（公式・全パラメータ）

| パラメータ | 型 | 説明 |
|---|---|---|
| `pageNumber` / `pageSize` | INTEGER | ページング。pageSize 既定10・**最大100** |
| `parentOrderStatus` | INTEGER | **0:全件 / 1:PENDING（未確定） / 2:UN_SHIPPING（出荷待ち） / 3:CANCELED（キャンセル） / 4:SHIPPED（出荷済） / 5:RECEIPTED（受取済） / 41:部分出荷（本土店のみ） / 51:部分受取（本土店のみ）** |
| `parentOrderSnList` | STRING[] | 親注文番号指定（**最大20件/回**） |
| `createAfter` / `createBefore` | INTEGER | 受注作成日の範囲（UNIX秒・閉区間・**両方指定必須**） |
| `updateAtStart` / `updateAtEnd` | INTEGER | ステータス変更日時の範囲（差分取得用・両方指定必須） |
| `expectShipLatestTimeStart` / `End` | INTEGER | 出荷期限（期待最遅出荷時刻）での絞り込み |
| `parentConfirmTimeStart` / `End` | INTEGER | 注文確定時刻の範囲（両方指定必須） |
| `fulfillmentTypeList` | STRING[] | `fulfillBySeller`（出品者発送）/ `fulfillByCooperativeWarehouse`（提携倉庫） |
| `parentOrderLabel` | STRING[] | `soon_to_be_overdue`（出荷期限接近）/ `past_due`（期限超過）/ `pending_buyer_cancellation` / `pending_buyer_address_change` / `pending_risk_control_alert` / `signature_required_on_delivery` |
| `packageAbnormalTypeList` | STRING[] | 配送異常：`WRONG_SHIPPING_ADDRESS` / `SUSPECTED_ERROR_PROVIDER` / `NO_TRACK` / `TRACK_TOO_EARLY` / `OVERTIME_COLLECTION` / `TRACK_COLLECT_FAIL` |
| `sortby` | STRING | `createTime`（既定）/ `updateTime`（逆順出力） |
| `regionId` | LONG | リージョン（例：米国=211） |
| `skuId` | LONG | SKU指定 |
| `hasPreSaleOrder` | BOOLEAN | 予約（在庫輸送中）注文を含むか |
| `hasQualificationRequiredOrder` | BOOLEAN | 資格（許認可）アップロード要注文を含むか |

### 4.3 `bg.order.list.v2.get` レスポンス（公式・主要フィールド）

**親注文レベル `pageItems[].parentOrderMap`**：

| フィールド | 内容 |
|---|---|
| `parentOrderSn` | 親注文番号（**PO接頭辞**。購入者にも表示される番号）※ |
| `parentOrderStatus` | 上記ステータス列挙値 |
| `parentOrderTime` | 受注時刻（**出荷期限の起算点はこの時刻**） |
| `updateTime` | 最終更新時刻（差分取得のキー） |
| `expectShipLatestTime` | **出荷期限**（これを過ぎると `past_due`） |
| `latestDeliveryTime` | 最終お届け期限 |
| `parentConfirmTime` / `parentShippingTime` / `parentOrderPendingFinishTime` | 確定・出荷・保留完了時刻 |
| `shippingMethod` / `hasShippingFee` / `orderPaymentType` | 配送方式・送料有無・支払種別 |
| `batchOrderNumberList` | 同梱グループの注文番号リスト |
| `parentOrderLabel[]` / `fulfillmentWarning[]` | 上記ラベル・履行警告 |
| `regionId` / `siteId` | リージョン・サイト |

**子明細レベル `pageItems[].orderList[]`**：

| フィールド | 内容 |
|---|---|
| `orderSn` | 子注文番号 |
| `goodsId` / `skuId` / `goodsName` / `originalGoodsName` | 商品ID・SKU ID・商品名 |
| `spec` / `originalSpecName` | 規格（バリエーション） |
| `quantity` / `originalOrderQuantity` / `canceledQuantityBeforeShipment` | 数量・元数量・出荷前キャンセル数 |
| `orderStatus` / `orderLabel[]` | 子明細ステータス・ラベル |
| `fulfillmentType` | 出荷主体（`fulfillBySeller` 等） |
| `isCancelledDuringPending` | PENDING中キャンセルフラグ |
| `thumbUrl` | 商品サムネイル |
| `orderCreateTime` / `orderShippingTime` / `earliestTimeGetShippingDocument` | 作成・出荷・送り状取得可能時刻 |
| `qualificationUploadEndTime` | 許認可アップロード期限 |
| `packageAbnormalTypeList[]` / `fulfillmentWarning[]` | 配送異常・警告 |
| `inventoryDeductionWarehouseId` / `Name` | 在庫引当倉庫 |
| `productList[]`（`productSkuId` / `productId` / `extCode` / `soldFactor`） | SKU→商品分解（セット品の構成）・外部コード |

**主なエラーコード（公式）**：`140020012`（時刻範囲の逆転）/ `140020013`（必須パラメータ欠落）/ `140020014`（タイムスタンプ形式不正）/ `140020001`（**トークンに紐づく店舗がSEMI/LOCALとタイプ不一致** — 越境 sellers が Local 専用APIを叩くと発生）。

> [!warning] SKU情報の注意※
> TEMU商品側で「貨号（SellerSKU）」を未整備だと、取得した注文に自社SKUが付かない。商品リストの「メンテナンス」で紐付け後は **新規注文のみ** に反映（易倉資料）。受注管理側では `skuId` ベースのマスタ突合を推奨。
> 緑茶園の文脈では、統合コンソールの **SKU対応表**（[[platform - 00 概要]]）に Temu の `skuId` を載せる形になる。

---

## 5. PII（氏名・住所）の扱い — Amazonとの対比

TEMUは **注文データと住所データを別API・別スコープに分離** している※（[InfiPlex解説](https://infiplex.com/temu-open-platform-api-order-lifecycle)）：

| 項目 | TEMU | Amazon SP-API（参考：[[Amazon - SP-API 受注リファレンス]]） |
|---|---|---|
| 注文リスト・明細 | `bg.order.list.v2.get` 等（非PII） | `getOrders` / `getOrderItems`（非PII） |
| 住所（氏名・住所行・電話） | **別スコープ必須**。`bg.order.shippinginfo.v2.get` で取得 | RDT+restrictedロール必須。**FBMのみ**。FBAは取得不可 |
| 機密フィールドの平文化 | `bg.order.decryptshippinginfo.get`（復号専用API・都度取得） | RDT付き操作で平文取得 |
| 運用指針 | **ラベル（送り状）作成時に取得・長期保存しない**（データレビューで失格になる）※ | PII保存ポリシー（データ保護計画）審査 |

※TEMUも「Data Security Policy for Service Providers」を公式ポリシーとして掲げており（公式フッター参照）、PII保存期間・暗号化が審査項目になる。

---

## 6. Orders API 単体では完結しない受注業務（担当API）

| 受注管理に必要な業務 | TEMUのAPI |
|---|---|
| 出荷確定・追跡番号通知 | `bg.logistics.shipment.confirm`（半托管自社発送）※ — **配送後24時間以内** が運用基準で、未対応は遅延出荷扱い※ |
| 送り状（面単）印刷・オンライン配送依頼 | `bg.logistics.shipment.create` / `bg.logistics.shipment.result.get` / `bg.logistics.shipment.update` / `bg.logistics.shipment.document.get`（平台在线发货）※ |
| 物流会社マスタ | `bg.logistics.companies.get`※ / 出荷元倉庫 `bg.logistics.warehouse.list.get`※ / 利用可能配送サービス `bg.logistics.shippingservices.get`※ |
| 商品・在庫（在庫引当・ATS管理） | Product/Goods系メソッド（`temu.local.goods.v3.add` 等）・在庫更新 |
| 注文キャンセル処理 | Order Cancellation セクション |
| 返金・返品 | Return and Refund セクション |
| イベント駆動の受信 | **Webhook**（注文作成・キャンセル等の通知を受信可 — 公式セクション存在） |
| 入金明細 | 注文金額照会（`temu.order.amount.v2.query`）または精算データ — 消込用途は別途確認 |

---

## 7. 実装上の注意

1. **ポーリング頻度**※：TEMUの出荷期限カウントは **注文時刻起算**。1日1回の取得では24時間の即納ウィンドウを溶かす。`sortby=updateTime` + `updateAtStart/End` での差分取得を短周期で回すのが定石
2. **同梱（まとめ発送）**：`bg.order.combinedshipment.list.get` で同梱グループを取得し、グループ単位で1つの追跡番号を確定送信 → グループ内の全親注文が出荷済みになる※
3. **追跡番号の検証**：TEMUは配送業者を公式対応リストと照合し、追跡番号形式チェックも行う。未対応の地域業者・誤記はリジェクトされ「出荷済み」にならず遅延扱いになる※
4. **トークンの有効期限**：出品者認可で発行した `access_token` には **有効期限があり**（認可一覧画面に表示）※、期限切れ前に再認可フローを実装。スコープ変更時は再発行
5. **レート制限**：公式APIリファレンスは各メソッドに「Rate Limiting Rules」セクションを持つが、**具体値は要確認**（未ログイン状態では数値取得不可）。PENDING→UN_SHIPPINGへの遷移検知などイベント性の高い更新は Webhook 受信+REST取得の併用が安全
6. **店タイプとAPIの一致**：越境半托管店と本土店（Local）でセラーセンターURL・権限体系が異なる。エラーコード `140020001` が出たらトークンの紐づく店タイプを確認
7. **日本の本土店のホスト**：GLOBAL用 `openapi-b-global.temu.com` / 米国Local用 `openapi-b-us.temu.com` が確認済み。**日本本土店のrouterホストはオンボーディング時に公式確認が必要**（要確認）

---

## 8. 参考リンク

| ドキュメント | URL |
|---|---|
| TEMU Partner Platform（GLOBAL・公式開発者ポータル） | https://partner.temu.com/ |
| Partner Guide（登録フロー・公式） | https://partner.temu.com/documentation?menu_code=52ef88bdef1d4527b15f6d303b173e48 |
| Developer Guide（API Request Endpoints・認可・公式） | https://partner.temu.com/documentation?menu_code=38e79b35d2cb463d85619c1c786dd303 |
| API Reference: bg.order.list.v2.get（公式・本稿の主要出典） | https://partner.temu.com/documentation?menu_code=fb16b05f7a904765aac4af3a24b87d4a&sub_menu_code=554fd46b45ee49269cbdd6d4008a5dc1 |
| Signature Method for API request（公式） | https://partner-eu.temu.com/documentation?menu_code=98501210a0cc465695e6d94e364bb83c&sub_menu_code=51bad7095f434b198df3996d3f2adfa1 |
| Authorize and Authorization Callback（公式・EU版） | https://partner-eu.temu.com/documentation?menu_code=7289390cfd724be4a196f11ebe45a896 |
| Data Security Policy for Service Providers（公式ポリシー） | https://partner.temu.com/documentation?menu_code=d8425dcd25b04658843e622e178a3b42&sub_menu_code=9cc3edb526494a059c477fd99953fa3e |
| 半托管認可手順・インターフェース一覧（易倉ERPwiki・第三者） | https://ecwiki.eccang.com/docs/show/3709 |
| Open Platform 受注ライフサイクル解説（InfiPlex・第三者） | https://infiplex.com/temu-open-platform-api-order-lifecycle |
| Temu受注API利用方法（GoQSystemマニュアル・第三者） | https://goqsystem.com/manual/179861/ |
| TEMU半托管接入介绍（領星ERP・第三者） | https://www.lingxing.com/help/article/TEMUSemiShopInitiate |

## 関連ノート

- [[EC Channel Console - 00 概要]] — Temu を含む7チャネルの実装状況（移行前の案件ノート）
- [[platform - 00 概要]] — 移行先の統合コンソール
- [[Amazon - SP-API 受注リファレンス]] — 同じ形式で整理した Amazon 版
- [[EC Channel Console - 変換器構想とMDC出力]] — Temu を MDC 投入対象に含める構想（PII保存方針と要調整）
- [[クロスモール（I'LL社）]] — クロスモールの Temu 対応は資料が見つかっておらず不明のまま
- [[08 要確認事項]] — 店舗モデル・アプリ登録の確認事項
- [[LINEギフト - API 受注リファレンス]] — 同じ形式で整理した LINEギフト 版
