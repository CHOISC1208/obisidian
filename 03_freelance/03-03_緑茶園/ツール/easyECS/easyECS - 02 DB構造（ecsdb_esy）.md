---
tags:
  - 緑茶園
  - ツール
  - easyECS
  - DB設計
client: 緑茶園グループ
関連テーマ: テーマ1 - 受注チャネル統合とツール複数人化
created: 2026-09-17
updated: 2026-09-17
aliases:
  - ecsdb_esy
  - easyECS テーブル一覧
---

# easyECS — DB構造（ecsdb_esy）

親: [[easyECS - 00 概要]] ／ 関連: [[easyECS - 01 DB接続（Tailscale・SQL Server）]] ／ [[easyECS - 03 受注テーブル（t_sell系）]]

> [!info] 出典と取り方
> 2026-09-17、読み取り専用ログインで SQL Server のシステムカタログ（`sys.tables`・`INFORMATION_SCHEMA.COLUMNS`・`sys.indexes`・`sys.foreign_keys`）から取得。**行数は `sys.partitions` の値**（テーブルを数え上げていないので概数だが、ほぼ正確）。業務データの中身はこの取得では読んでいない。
> **ベンダーのテーブル定義書は未入手**。分類と「何の機能か」はテーブル名・列名からの推定。

## 全体像

| 項目 | 値 |
|---|---|
| スキーマ | すべて `dbo` |
| テーブル | **120**（データあり 40／空 80） |
| ビュー | 2（`V_indexes`・`V_Tables`。DB管理用と思われる） |
| 列 | 2,123 |
| 主キー | 主要テーブルには付いている（クラスタ化インデックス） |
| 外部キー | **ほぼ無い**（`m_name` の自己参照1つだけ）。テーブル間の関係は列名で読む |

### 名前の付け方

| 接頭辞 | 意味〔推定〕 |
|---|---|
| `m_` | マスタ（商品・顧客・区分値・設定） |
| `t_` | 取引・履歴（受注・在庫の動き・API とのやり取り） |
| `w_` | 作業用の一時テーブル（ほぼ空） |
| `bk_` | バックアップ（空） |
| `*_inst` | API に送る指示を貯めるキュー〔推定〕 |
| `*_result_*`／`*_response` | API からの応答の記録〔推定〕 |

API 連携の略語：`api`＝モール受注取り込み全般／`rpay`＝楽天ペイ／`npapi`＝NP後払い／`rapi`＝楽天の物流連携〔推定：楽天スーパーロジスティクス〕／`yaapi`＝ヤフオク！／`ypf`＝Yahoo! 系〔推定〕

## 使われている機能・使われていない機能

**テーブルが空＝その機能を緑茶園は使っていない**と読める。

| 機能 | 状態 | 根拠 |
|---|---|---|
| モール受注の取り込み・受注管理 | 🟢 使用中 | `t_api_order` 84万行、`t_sell` 52万行 |
| NP後払い連携 | 🟢 使用中 | `t_npapi_*` に数千〜9千行 |
| 楽天ペイ・カード決済の記録 | 🟢 使用中 | `t_api_rpay_data` 17万行、`t_api_card` 12万行 |
| 受注メール | 🟢 使用中 | `t_mail` 25万行、テンプレート51件 |
| 在庫の増減履歴 | 🟢 使用中 | `t_stock_log` 67万行 |
| 楽天の物流倉庫連携 | ⚪ 未使用 | `t_rapi_*` 37テーブルがすべて空 |
| ヤフオク！連携 | ⚪ 未使用 | `t_yaapi_*` 17テーブルがすべて空 |
| 仕入・定期購入・問い合わせ | ⚪ 未使用 | `t_buy*`・`t_regular_purchase`・`t_inquiry` が空 |
| キャンペーン・セット商品 | ⚪ 未使用 | `m_campaign`・`m_goods_set` が空 |

## テーブル一覧（分類別・行数の多い順）

### 受注（本体）

8テーブル（うち空 4）・計 1,626,025 行

| テーブル | 行数 | 列数 |
|---|--:|--:|
| `t_sell_goods` | 566,813 | 39 |
| `t_sell_delivery` | 531,325 | 59 |
| `t_sell` | 523,033 | 103 |
| `t_sell_data` | 4,854 | 6 |
| `bk_t_sell` | 0 | 37 |
| `bk_t_sell_delivery` | 0 | 24 |
| `bk_t_sell_goods` | 0 | 23 |
| `t_sell_calc` | 0 | 4 |

### モールからの受注取り込み

5テーブル（うち空 1）・計 1,098,142 行

| テーブル | 行数 | 列数 |
|---|--:|--:|
| `t_api_order` | 838,282 | 13 |
| `t_api_check_confirm` | 239,425 | 10 |
| `t_api_check_order` | 17,867 | 10 |
| `t_api_check_cancel` | 2,568 | 10 |
| `t_api_order_inst` | 0 | 12 |

### 決済（楽天ペイ・カード・NP後払い）

18テーブル（うち空 5）・計 331,648 行

| テーブル | 行数 | 列数 |
|---|--:|--:|
| `t_api_rpay_data` | 172,717 | 7 |
| `t_api_card` | 122,199 | 12 |
| `t_npapi_result_authori_response` | 9,047 | 17 |
| `t_npapi_result_trans_regist_response` | 8,778 | 14 |
| `t_npapi_result_ship_report_response` | 7,645 | 14 |
| `t_npapi_result_trans_regist` | 5,459 | 10 |
| `t_npapi_result_ship_report` | 3,360 | 10 |
| `t_npapi_result_billed_print_response` | 1,931 | 127 |
| `t_npapi_result_trans_revision_response` | 188 | 14 |
| `t_npapi_result_trans_revision` | 161 | 10 |
| `t_npapi_result_trans_cancel_response` | 82 | 14 |
| `t_npapi_result_trans_cancel` | 80 | 10 |
| `w_rpay_next_order` | 1 | 5 |
| `t_api_card_inst` | 0 | 9 |
| `t_npapi_ship_report_inst` | 0 | 7 |
| `t_npapi_trans_cancel_inst` | 0 | 7 |
| `t_npapi_trans_regist_inst` | 0 | 7 |
| `t_npapi_trans_revision_inst` | 0 | 7 |

### メール

6テーブル（うち空 3）・計 253,187 行

| テーブル | 行数 | 列数 |
|---|--:|--:|
| `t_mail` | 252,708 | 13 |
| `m_mail_template_limit` | 428 | 6 |
| `m_mail_template` | 51 | 10 |
| `t_mail_order` | 0 | 9 |
| `w_mail_uid` | 0 | 5 |
| `w_order_mail` | 0 | 6 |

### 在庫

4テーブル（うち空 2）・計 677,097 行

| テーブル | 行数 | 列数 |
|---|--:|--:|
| `t_stock_log` | 670,843 | 23 |
| `m_stock` | 6,254 | 8 |
| `t_stock_batch_log` | 0 | 8 |
| `w_stock_back` | 0 | 6 |

### 商品

5テーブル（うち空 3）・計 25,323 行

| テーブル | 行数 | 列数 |
|---|--:|--:|
| `m_goods_conv` | 22,196 | 10 |
| `m_goods` | 3,127 | 130 |
| `m_goods_set` | 0 | 7 |
| `t_goods_set_log` | 0 | 11 |
| `w_file_image` | 0 | 6 |

### 顧客

1テーブル（うち空 0）・計 437,482 行

| テーブル | 行数 | 列数 |
|---|--:|--:|
| `m_customer` | 437,482 | 29 |

### 区分値・設定・カレンダー

11テーブル（うち空 2）・計 148,170 行

| テーブル | 行数 | 列数 |
|---|--:|--:|
| `m_zipcd` | 144,627 | 16 |
| `m_name` | 1,033 | 58 |
| `m_db_patch` | 1,000 | 5 |
| `m_delivery_day` | 564 | 9 |
| `m_system` | 327 | 9 |
| `m_form_property` | 325 | 17 |
| `m_holiday` | 270 | 5 |
| `m_datasheet` | 14 | 7 |
| `m_delivery_place` | 10 | 6 |
| `m_campaign` | 0 | 10 |
| `m_carriage` | 0 | 6 |

### 社員・仕入先

3テーブル（うち空 1）・計 15 行

| テーブル | 行数 | 列数 |
|---|--:|--:|
| `m_employee` | 13 | 6 |
| `m_supplier` | 2 | 18 |
| `m_employee_role` | 0 | 6 |

### 楽天スーパーロジスティクス連携〔推定〕（未使用）

37テーブル（うち空 37）・計 0 行

| テーブル | 行数 | 列数 |
|---|--:|--:|
| `t_rapi_cre_inbnd_cncl_dtl_inst` | 0 | 35 |
| `t_rapi_cre_inbnd_cncl_inst` | 0 | 9 |
| `t_rapi_cre_inbnd_sche_dtl_inst` | 0 | 34 |
| `t_rapi_cre_inbnd_sche_inst` | 0 | 20 |
| `t_rapi_cre_vender_ret_dtl_inst` | 0 | 20 |
| `t_rapi_cre_vender_ret_inst` | 0 | 31 |
| `t_rapi_create_prod_st_dtl_inst` | 0 | 7 |
| `t_rapi_create_prod_st_inst` | 0 | 7 |
| `t_rapi_create_product_inst` | 0 | 98 |
| `t_rapi_create_ship_cncl_inst` | 0 | 9 |
| `t_rapi_create_shipping_dtl_inst` | 0 | 20 |
| `t_rapi_create_shipping_inst` | 0 | 93 |
| `t_rapi_create_vender_inst` | 0 | 10 |
| `t_rapi_result_cre_inbnd_cncl` | 0 | 16 |
| `t_rapi_result_cre_inbnd_sche` | 0 | 16 |
| `t_rapi_result_cre_vender_ret` | 0 | 16 |
| `t_rapi_result_create_prod_st` | 0 | 16 |
| `t_rapi_result_create_product` | 0 | 16 |
| `t_rapi_result_create_ship_cncl` | 0 | 16 |
| `t_rapi_result_create_shipping` | 0 | 16 |
| `t_rapi_result_create_vender` | 0 | 16 |
| `t_rapi_result_search_inbound` | 0 | 15 |
| `t_rapi_result_search_inbound_stat` | 0 | 14 |
| `t_rapi_result_search_inventory` | 0 | 14 |
| `t_rapi_result_search_inventory_diff` | 0 | 14 |
| `t_rapi_result_search_ship` | 0 | 15 |
| `t_rapi_result_search_ship_ng` | 0 | 15 |
| `t_rapi_result_search_vender_ret` | 0 | 15 |
| `t_rapi_search_inbound_inst` | 0 | 10 |
| `t_rapi_search_inbound_stat_inst` | 0 | 9 |
| `t_rapi_search_inventory_diff_inst` | 0 | 8 |
| `t_rapi_search_inventory_inst` | 0 | 7 |
| `t_rapi_search_ship_inst` | 0 | 8 |
| `t_rapi_search_ship_ng_inst` | 0 | 9 |
| `t_rapi_search_vender_ret_inst` | 0 | 10 |
| `t_rapi_vender_return` | 0 | 22 |
| `t_rapi_vender_return_detail` | 0 | 21 |

### ヤフオク！連携（未使用）

17テーブル（うち空 17）・計 0 行

| テーブル | 行数 | 列数 |
|---|--:|--:|
| `t_yaapi_advance_notify_inst` | 0 | 8 |
| `t_yaapi_approval_pt_dtl_inst` | 0 | 7 |
| `t_yaapi_approval_pt_inst` | 0 | 7 |
| `t_yaapi_cancel_point_dtl_inst` | 0 | 7 |
| `t_yaapi_cancel_point_inst` | 0 | 7 |
| `t_yaapi_leave_feedbk_dtl_inst` | 0 | 7 |
| `t_yaapi_leave_feedbk_inst` | 0 | 9 |
| `t_yaapi_order_notify_inst` | 0 | 8 |
| `t_yaapi_remove_winner_inst` | 0 | 11 |
| `t_yaapi_result_advance_notify` | 0 | 12 |
| `t_yaapi_result_approval_pt` | 0 | 14 |
| `t_yaapi_result_cancel_point` | 0 | 14 |
| `t_yaapi_result_leave_feedbk` | 0 | 16 |
| `t_yaapi_result_order_notify` | 0 | 11 |
| `t_yaapi_result_remove_winner` | 0 | 13 |
| `t_yaapi_result_sold_notify` | 0 | 11 |
| `t_yaapi_sold_notify_inst` | 0 | 8 |

### 仕入・定期購入・問い合わせ（未使用）

5テーブル（うち空 5）・計 0 行

| テーブル | 行数 | 列数 |
|---|--:|--:|
| `t_buy` | 0 | 22 |
| `t_buy_detail` | 0 | 31 |
| `t_inquiry` | 0 | 14 |
| `t_regular_purchase` | 0 | 16 |
| `w_next_order` | 0 | 8 |

## 商品マスタ `m_goods` と、売上分析に使えるか（2026-09-17 追記）

売れ筋・前年比のダッシュボードを検討するために、読み取り専用で `m_goods`（3,127件）と受注の件数を調べた。

> [!important] 商品の「短い名前」や「カテゴリ」は easyECS に無い
> - `goods_name` はモールの商品ページのタイトルそのもの（「桃 秀品 2kg 山形県産 選べる10品種 … 伊達白桃」）。**略称・カナ（`goods_name_kana` は全件空）・分類は持っていない**
> - 商品属性 `property01`〜`10` は全件空。`property11`〜`14` には「小分類区分・配送区分・在庫管理対象・表示上削除」という名前が付いているが、値が入っているのは「在庫管理対象」（ほぼ全件 `1`）だけ
> - **原価 `cost_price` は全件 0**。粗利は easyECS だけでは出せない（原価は Airtable 側 → [[Airtable再構築 - 00 概要]]）
> - 商品区分 `goods_type` は「一般商品／その他」だけ
>
> 分析で使える手がかりは次の3つ。
> 1. **SKU（`goods_cd`）の接頭辞が商品群を表している**〔推定。商品名からの読み取り〕：`sk-` さくらんぼ／`mm-` 桃／`pio-` ぶどう／`rg-` りんご／`km-` 米／`fuku-` フルーツギフト／`oka-` 焼き菓子／`c-`・`z-`・`macha-` お茶／`water-` 保存水／`yz-` 米沢牛など。接頭辞は120種類あり、`ss-mm-…` のように2段になるものもある
> 2. **品種は SKU の末尾と、明細の購入時の選択肢 `t_sell_goods.option_x` に入っている**：`mm-130-th-date` の `option_x` は「ご購入品種:伊達白桃（9月中旬） | …」。2026年の明細 46,709件のうち `option_x` に「品種」を含むのは 5,974件
> 3. **同じ SKU でも商品名は時期で変わる**：`sk-119`（佐藤錦 特秀 L玉 24粒）は2026年だけで42通りの名前（「母の日」「遅れてごめんね 母の日」など）。**集計のキーは必ず `goods_cd`**。表示用の短い名前は自前で対応表を作る必要がある

### 受注の年別件数（キャンセル・削除済みを除く、受注日で集計）

| 年 | 受注 | 年 | 受注 |
|---|--:|---|--:|
| 2011〜2014 | 100〜440／年 | 2021 | 65,469 |
| 2015 | 4,590 | 2022 | 63,850 |
| 2016 | 5,068 | 2023 | 52,538 |
| 2017 | 23,573 | 2024 | 52,964 |
| 2018 | 37,359 | 2025 | 47,945 |
| 2019 | 47,262 | 2026（9/17まで） | 43,608 |
| 2020 | 67,373 | | |

- **前年比は十分な期間で取れる**（本格的なデータは2017年から）。2025年と2026年の 1/1〜9/17 で売れた SKU は 742種類と877種類、両年に共通なのは578種類。**年ごとに SKU を作り直す商品がある**（`mm-130-th` は2025-08、品種別の `mm-130-th-*` は2026-04〜08 に登録）ので、SKU 単位の前年比は途切れる
- 受注日は**予約した日**。さくらんぼの予約が入る5〜6月に受注が集中する（2025年は5月 8,196件・6月 6,770件）。「いつ売れたか」と「いつ出荷したか」（`t_sell_delivery.ship_date`）で見え方が大きく変わる
- `all_total`（請求合計）が 0 の受注が、楽天Pay で年に約1,000件、Wowma! で約400〜500件ある〔理由は未確認。全額ポイント払いなどの可能性〕

## 区分値の辞書 `m_name`

コード値の名前は、1つのテーブル `m_name` にまとめて入っている。**主キーは `(name_id, name_cd)`**。`name_id` が区分の種類、`name_cd` がコード、`name_value` が表示名、`name_order` が並び順。`option1`〜`option50` は区分ごとの付加情報。

- 各区分の先頭に `name_cd = '-'` の行があり、`name_value` が区分の見出し（例：`【受注進捗】`）になっている
- **先方が自分で行を足して運用している区分がある**（`order_status` の 900番台を商品カテゴリに使っているなど）
- `name_id` は **121種類**・計1,033行

受注で使う区分の中身は [[easyECS - 03 受注テーブル（t_sell系）]] に載せた。そのほかの `name_id`（件数）：

`api_card_progress`カードAPI処理名称（19）、`api_order_progress`受注API処理名称（16）、`api_order_stutas`受注API処理ステータス名称（7）、`api_rms_cancel`楽天RMSキャンセル理由（12）、`api_rms_status`楽天RMSステータス名（10）、`api_rpay_cancel`楽天Payキャンセル理由（12）、`api_rpay_reduction`楽天Pay減額理由（12）、`apology_flg`お詫びフラグ（3）、`campaign_type`キャンペーンサービス内容（4）、`comment_fill`コメントフィルタ受注データ備考欄から自動削除する文字列を指定（6）、`comment_menu`倉庫指示文面受注画面の倉庫指示欄内右クリック時に表示される挿入用文字列（6）、`custom_return_cd`カスタマー返品可能区分（4）、`customer_property`顧客属性顧客属性名称を指定（11）、`dangerous_flg`危険物フラグ（3）、`delivery_company`配送業者（66）、`dlv_defray_type`元着区部（3）、`dlv_design_time`お届け指定時間帯（8）、`dlv_service_flg`宅配便フラグ（4）、`dlv_service_type`配送サービス種別（3）、`dlv_ship_cd_ypf`納品伝票区分（3）、`dlv_type_cd_ypf`お届け方法（5）、`dlv_type_cd1`配送便種コード1（6）、`dlv_type_cd2`配送便種コード2（3）、`exceed_claim_flg`配送保険フラグ（3）、`expiration_ypf`賞味期限/消費期限管理区分（3）、`form_role`権限名称（4）、`ftp_status_order`（2）、`gift_comb_flg_ypf`ギフト梱包方法フラグ（3）、`gift_impossible_flg`ギフト不可フラグ（3）、`gift_kind_cls_ypf`ギフト包装の種類（10）、`goods_property`商品属性商品属性名称を指定（21）、`goods_property_ts`テンポスター商品CSV出力属性変換（21）、`goods_property01`商品属性01商品属性名称を指定（2）、`goods_property02`商品属性02商品属性名称を指定（2）、`goods_property03`商品属性03商品属性名称を指定（2）、`goods_property04`商品属性04商品属性名称を指定（2）、`goods_property05`商品属性05商品属性名称を指定（2）、`goods_property06`商品属性06商品属性名称を指定（2）、`goods_property07`商品属性07商品属性名称を指定（2）、`goods_property08`商品属性08商品属性名称を指定（2）、`goods_property09`商品属性09商品属性名称を指定（2）、`goods_property10`商品属性10商品属性名称を指定（2）、`goods_type`商品区分（3）、`goods_use_type`商品取扱区分（3）、`in_cancel_reason`入荷キャンセル理由（4）、`inbound_form`入荷形態（5）、`inbound_inst_ypf`入荷エクスポート出力対象（2）、`inquiry_cat1`問い合わせカテゴリ1（5）、`inquiry_cat2`問い合わせカテゴリ2（4）、`inquiry_cat3`問い合わせカテゴリ3（6）、`inquiry_cat4`問い合わせカテゴリ4（2）、`inquiry_cat5`問い合わせカテゴリ5（2）、`inspctn_flg`代替フラグ（3）、`kyotsuku_flg_ypf`きょうつくフラグ（3）、`lot_manag_cls_ypf`ロット管理（3）、`lot_manage_flg`製造ロット番号管理フラグ（3）、`mail_flg_ypf`メール便可能（3）、`mail_status`メール送信状態（4）、`mail_status_order`（4）、`mail_tag`メールタグ（51）、`mall_cd_order`モール区分(受注メール用)（4）、`mobile_domain`モバイル判定用ドメイン（33）、`mobile_flg`モバイルフラグ（3）、`nondisp_amt_flg`金額非表示フラグ（3）、`noshi_kbn_ypf`のし種類（9）、`npapi_stlmnt_type`NP後払い決済方法（3）、`number_of_payment`支払回数（15）、`okng`○×（3）、`order_ship_status`発送進捗（6）、`outbound_form`出荷形態（5）、`packing_break_ypf`同梱不可（3）、`packing_flg`独立梱包フラグ（3）、`pre_set_flg`事前セット組みフラグ（3）、`pref`都道府県名（48）、`print_mode`帳票名（27）、`rapi_ret_inst_div`返品指示区分（4）、`rapi_ret_inst_reason`返品指示理由（10）、`receipt_out_flg_ypf`納品書 同梱有無（4）、`repeater_flg`リピーターフラグ（3）、`sagawa_ng`佐川配送NG（8）、`sales_rsv_type`販売予約区分（2）、`seihin_kbn_ypf`商品区分（4）、`serial_manage_flg`シリアル番号管理フラグ（4）、`sex`性別（4）、`ship_eazy`（10）、`ship_inst`出荷指示種別（53）、`ship_limit_flg`出荷期限フラグ（3）、`ship_ng_reason`出荷キャンセル理由（5）、`shp_style_ypf`バラ/ケース区分（3）、`site_type`サイト区分（5）、`stock_type_cd`在庫ログタイプコード（6）、`storage_cd_ypf`保管区分（7）、`storage_form`保管形態（5）、`store_api_merchant`楽天物流連携ストア（10）⚠️、`store_customer_yaapi`ヤフオク連携ストア（10）、`store_customer_ypf`Yahoo物流連携ストア（10）、`store_rbank`楽天バンク決済手数料（10）⚠️、`store_smtp`ストアメールSMTP設定（11）⚠️、`store_smtp_auth`ストアメール認証設定（11）⚠️、`store_smtp_ssl`ストアメールSMTPSSL設定（11）⚠️、`store_url`ストアURL（10）⚠️、`tax_flg_ypf`課税フラグ（3）、`tax_rate`消費税率（6）、`temper_zone_cd`温度帯区分（4）、`their_consign`自社/委託（3）、`through_cd`スルー区分（3）、`warehouse_cd`倉庫コード（3）、`yaapi_advance_flg`ヤフオク繰り上げオプションフラグ（3）、`yaapi_cmt_template`ヤフオク評価コメントテンプレート（6）、`yaapi_pri_cipher`ヤフオク暗号化優先フラグ（3）⚠️、`yaapi_rating`ヤフオク評価コード（6）、`yaapi_reason`ヤフオク削除都合コード（3）、`yesno`はいいいえ（3）

> [!warning] `store_smtp*`・`store_api_merchant`・`store_rbank`・`store_url`・`yaapi_pri_cipher` などは読まない
> メールサーバやモールAPIの接続情報が `option` 列に入っている可能性がある。`m_system`（327行）も同様。調査でも中身は取得していない。

## 関連

- [[easyECS - 00 概要]] ／ [[easyECS - 01 DB接続（Tailscale・SQL Server）]] ／ [[easyECS - 03 受注テーブル（t_sell系）]]
