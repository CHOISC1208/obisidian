-- ============================================================
-- easyECS（ecsdb_esy）受注残の明細（受注残ボードの基礎データ）
--
-- 作成：2026-09-17 ／ 状態：案・未実行（件数・性能・結果の妥当性は未確認）
-- 接続：読み取り専用ログイン `read` のみ（sa は使わない）
-- 参照：easyECS - 03 受注テーブル（t_sell系）
--
-- 1行＝t_sell_goods の明細1件（受注CSV「受注タイプ1」と同じ粒度）。
-- 受注CSVの一意キー（システム受注番号・配送番号・商品番号）＝ t_sell_goods の主キー。
--
-- 前提
--   - 受注残の判定は t_sell_delivery.delivery_status = '01'（未出荷）
--   - 未キャンセルの cancel_date は NULL ではなく 1900-01-01
--   - t_sell_delivery・t_sell_goods には delivery_status などの索引が無い。
--     t_sell.order_date（索引あり）で先に絞ってから結合する
--   - easyECS の処理を止めないよう WITH (NOLOCK) で読む
--   - m_name は name_value（表示名）だけ読む。option 列は読まない（認証情報が入っている可能性）
--   - スキーマ名 dbo は仮定
--   - isOpen・plannedDate・junKey・hasDateConflict は SQL で計算しない。
--     platform リポジトリの lib/ec/backlog/parse.ts に通して CSV 版と結果を揃える
--
-- 受注残ボードの項目 ／ CSV の列 ／ この SQL
--   orderNo       ／ システム受注番号 ／ t_sell.order_no
--   shipmentNo    ／ 配送番号         ／ t_sell_delivery.delivery_no
--   lineNo        ／ 商品番号         ／ t_sell_goods.goods_no
--   productName   ／ 商品名           ／ t_sell_goods.goods_name（未決：商品名の出どころ）
--   sku           ／ 商品コード       ／ t_sell_goods.goods_cd
--   qty           ／ 数量             ／ t_sell_goods.amount
--   rawStatus     ／ 配送進捗名       ／ m_name.delivery_status の表示名
--   shipDate      ／ 出荷日           ／ t_sell_delivery.ship_date
--   deliveryDate  ／ 配送日           ／ t_sell_delivery.delivery_date
--   store         ／ ストア名         ／ t_sell.store_cd ／ m_name.store_cd の表示名（未決：どちらで持つか）
--   category      ／ 受注進捗名       ／ m_name.order_status の表示名（900番台＝先方が追加した商品分類）
--   deliverySlot  ／ 配送時間名       ／ m_name.delivery_time の表示名
--   orderDatetime ／ 受注日時         ／ t_sell.order_date
--
-- 未決・要確認
--   [ ] 受注CSV（受注タイプ1）を出すときの検索条件（9/7 の CSV は未出荷 2,899／出荷済 312／キャンセル 0）。
--       同じ時刻に CSV を出してもらい、この SQL の行数・数量合計・SKU数と突き合わせる
--   [ ] 商品名の出どころ。goods_name はモールの商品ページのタイトルそのもので時期により変わり、
--       ボードの SKU 別集計（商品名＋SKU）で同じ SKU が複数行に割れる。m_goods の商品名を使う案（m_goods は未調査）
--   [ ] ストアを store_cd と trim しない表示名のどちらで持つか（03_ストア名の照合.sql の結果を見て決める）
--   [ ] 数量 0 の明細（直近サンプルで9件）を受注残に含めるか
--   [ ] 期間 @from（02_未出荷の受注月別件数.sql の結果で決める）
--   [ ] スキーマ名が dbo で合っているか
--   [ ] 定期実行の負荷を先方が許容するか
-- ============================================================

DECLARE @from datetime = DATEADD(month, -6, CAST(GETDATE() AS date));  -- 期間は 02 の結果で決める

SELECT
  s.order_no                                          AS order_no,       -- システム受注番号
  CAST(d.delivery_no AS varchar(10))                  AS shipment_no,    -- 配送番号
  g.goods_no                                          AS line_no,        -- 商品番号
  ISNULL(g.goods_name, '')                            AS product_name,
  g.goods_cd                                          AS sku,
  g.amount                                            AS qty,
  ds.name_value                                       AS raw_status,     -- 「未出荷」
  NULLIF(CONVERT(date, d.ship_date),     '19000101')  AS ship_date,      -- 出荷予定日
  NULLIF(CONVERT(date, d.delivery_date), '19000101')  AS delivery_date,  -- お届け予定日
  s.mall_cd,
  s.store_cd,
  st.name_value                                       AS store_name,     -- trim しない
  os.name_value                                       AS category,       -- 受注進捗名（900番台＝商品分類）
  dt.name_value                                       AS delivery_slot,
  s.order_date                                        AS order_datetime
FROM dbo.t_sell s WITH (NOLOCK)
JOIN dbo.t_sell_delivery d WITH (NOLOCK)
  ON d.order_no = s.order_no
JOIN dbo.t_sell_goods g WITH (NOLOCK)
  ON g.order_no = d.order_no AND g.delivery_no = d.delivery_no
LEFT JOIN dbo.m_name ds WITH (NOLOCK) ON ds.name_id = 'delivery_status' AND ds.name_cd = d.delivery_status
LEFT JOIN dbo.m_name st WITH (NOLOCK) ON st.name_id = 'store_cd'        AND st.name_cd = s.store_cd
LEFT JOIN dbo.m_name os WITH (NOLOCK) ON os.name_id = 'order_status'    AND os.name_cd = s.order_status
LEFT JOIN dbo.m_name dt WITH (NOLOCK) ON dt.name_id = 'delivery_time'   AND dt.name_cd = d.delivery_time
WHERE s.order_date >= @from
  AND d.delivery_status = '01'                                   -- 未出荷（出荷不可 90・出荷キャンセル 91 も除く）
  AND (s.cancel_date IS NULL OR s.cancel_date = '19000101')      -- キャンセルされていない
  AND s.order_status NOT IN ('99', '95')                         -- キャンセル・削除済み受注進捗
ORDER BY s.order_no, d.delivery_no, g.goods_no;
