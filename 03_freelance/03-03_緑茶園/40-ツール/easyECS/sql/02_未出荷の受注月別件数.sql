-- ============================================================
-- easyECS（ecsdb_esy）未出荷の配送先を受注月別に数える
--
-- 作成：2026-09-17 ／ 状態：案・未実行
-- 接続：読み取り専用ログイン `read` のみ
--
-- 目的：01_受注残の明細.sql の期間 @from を決める。
--   order_date で期間を切ると、それより前の受注で未出荷のまま残っているものが漏れるため、
--   未出荷がどの受注月に分布しているかを先に見る。
--   何年も前の「未出荷」が残っていれば放置データの可能性が高い。受注残に含めるかは先方に確認する。
--
-- 注意：索引が効かず t_sell_delivery（約53万行）を全部読む。初回に1回だけ、easyECS が空いている時間に流す。
--       スキーマ名 dbo は仮定。
-- ============================================================

SELECT YEAR(s.order_date) AS y, MONTH(s.order_date) AS m,
       COUNT(*) AS delivery_count
FROM dbo.t_sell_delivery d WITH (NOLOCK)
JOIN dbo.t_sell s WITH (NOLOCK) ON s.order_no = d.order_no
WHERE d.delivery_status = '01'
  AND (s.cancel_date IS NULL OR s.cancel_date = '19000101')
GROUP BY YEAR(s.order_date), MONTH(s.order_date)
ORDER BY y, m;
