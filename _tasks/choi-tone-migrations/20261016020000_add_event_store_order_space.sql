-- 催事用スペース（R14）。催事（イベント）のたびにアプリを作るのではなく、店舗別受発注_ver2 と
-- 同じ形のアプリを先にダミーで20個作っておき、使うときに名前だけ変えて使う（アプリ名は
-- アプリの画面の見出しから変更できる）。
--
-- ・スペースは固定 ID で作る（環境間で ID をそろえるため。cost_calc と同じやり方）。
-- ・アプリは店舗別受発注_ver2 と同じ設定（is_store_order / store_order_use_master = true）。
--   テーブルは複製せず app_id で分かれる。store_id は店舗に紐づかないので null。
-- ・slug は event_01 .. event_NN の固定。名前を変えても slug は変わらない。
-- ・受発注管理_ver2（store_order_use_master = true を横断集計）の対象に、催事アプリも自動で入る
--   （店舗名の欄にはアプリ名が出るので、名前を変えると集計にも反映される）。
-- ・権限は、店舗別受発注_ver2 のスペース（e42def06-...）と同じ権限グループ・ロールをそのまま写す。
-- ・冪等：何度流しても、足りない分だけ作る。件数を増やすときは
--   supabase/scripts/ensure_event_store_order_apps.sql の target_count を変えて流す。

insert into choi_tone.spaces (id, name)
values ('7c1f2d3e-4a5b-4c6d-8e9f-0a1b2c3d4e5f', '催事用')
on conflict (id) do nothing;

insert into choi_tone.permission_group_spaces (group_id, space_id, role)
select group_id, '7c1f2d3e-4a5b-4c6d-8e9f-0a1b2c3d4e5f', role
from choi_tone.permission_group_spaces
where space_id = 'e42def06-c82f-4261-bf49-f8d026532ab1'
on conflict do nothing;

do $$
declare
  target_count int := 20;
  event_space constant uuid := '7c1f2d3e-4a5b-4c6d-8e9f-0a1b2c3d4e5f';
begin
  insert into choi_tone.apps (space_id, name, slug, is_store_order, store_order_use_master)
  select event_space, '催事' || lpad(n::text, 2, '0'), 'event_' || lpad(n::text, 2, '0'), true, true
  from generate_series(1, target_count) as n
  where not exists (
    select 1 from choi_tone.apps a
    where a.space_id = event_space and a.slug = 'event_' || lpad(n::text, 2, '0')
  );
end $$;
