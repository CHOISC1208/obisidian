-- ============================================================
-- easyECS（ecsdb_esy）未出荷の配送先をモール・ストア別に数える（ストア名の照合）
--
-- 作成：2026-09-17 ／ 状態：案・未実行
-- 接続：読み取り専用ログイン `read` のみ
--
-- 目的：統合コンソールの受注残ボードが、取り込み時のストア名 trim で
--   楽天（store_cd 07・末尾スペースあり）と Amazon（store_cd 05）を1つに混ぜていないかを確かめる。
--   9/8 の受注CSVで「末尾スペースの有無で 1,742件と138件に分裂」していた比率と、
--   07（楽天Pay）・05（AMAZON）の比率が揃えば確定。
--   → platform - 10 変換器構想とMDC出力 の warning ／ easyECS - 03 受注テーブル（t_sell系）
--
-- 注意：m_name は name_value だけ読む（option 列は読まない）。スキーマ名 dbo は仮定。
-- ============================================================

SELECT s.mall_cd, s.store_cd,
       '[' + st.name_value + ']' AS store_name_bracketed,  -- 末尾スペースを見えるように
       COUNT(*) AS delivery_count
FROM dbo.t_sell s WITH (NOLOCK)
JOIN dbo.t_sell_delivery d WITH (NOLOCK) ON d.order_no = s.order_no
LEFT JOIN dbo.m_name st WITH (NOLOCK) ON st.name_id = 'store_cd' AND st.name_cd = s.store_cd
WHERE s.order_date >= DATEADD(month, -6, GETDATE()) AND d.delivery_status = '01'
GROUP BY s.mall_cd, s.store_cd, st.name_value
ORDER BY delivery_count DESC;
