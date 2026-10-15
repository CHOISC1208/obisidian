-- レジデータ（レジ電子ジャーナル .sjl の取込）
--
-- 新しいスペース「レジデータ」（d89ca692-5f7b-4f6b-aa66-46f1e1f08167）に、店舗ごとのアプリを置く。
-- アップロードする人が自分の店舗のアプリを開いて .sjl を上げる運用なので、
-- 取り込んだ行はどの店舗のアプリ（app_id）に属するかで分ける。
-- 店舗アプリの作り方は受発注・棚卸しと同じ（apps.store_id に店舗マスタの id、slug も同じ id）。
--
-- テーブルは解析仕様書 §4 の receipts / receipt_items / ingest_log に、店舗（app_id / store_id）の列と、
-- 日別一覧用の register_days を足したもの。
--   register_days          … 1店舗・1営業日で1行。日別一覧と「検算結果」の置き場（アップロードで1行できる）
--   register_receipts      … 1取引1行。(app_id, business_date, j_no) で一意 = 再アップロードは upsert
--   register_receipt_items … 1明細1行。PLU は文字列（先頭ゼロ保持）
--   register_ingest_log    … 取込1回ごとのログ（検算NGで取り込まなかった記録も残す）
-- 仕様書の receipts.change は予約語に近いので change_amount、payment_method / payment_service は
-- 併用払いに備えて payments（jsonb の配列）にまとめた。

alter table choi_tone.apps add column is_register_data boolean not null default false;

create table choi_tone.register_days (
  id uuid primary key default gen_random_uuid(),
  app_id uuid not null references choi_tone.apps (id) on delete cascade,
  -- apps.store_id と同じ値。platform 側と店舗で突き合わせるときのために持つ。
  store_id uuid,
  business_date date not null,
  -- レシートの「000001 店舗」の行の番号。別の店舗のファイルを上げたときの検知に使う。
  shop_code text,
  source_file text,
  -- 通常の取引から集計した値（検算に通ったもの）
  customers integer not null default 0,
  tax_included_total integer not null default 0,
  gross_sales integer not null default 0,
  net_sales integer not null default 0,
  item_count integer not null default 0,
  discount_total integer not null default 0,
  cash_sales integer not null default 0,
  credit_sales integer not null default 0,
  emoney_sales integer not null default 0,
  code_sales integer not null default 0,
  cancel_count integer not null default 0,
  -- 状態を問わない取引レコード数（取消・訓練・釣準備を含む）
  receipt_count integer not null default 0,
  check_result text not null default 'OK' check (check_result in ('OK', 'NG', 'NONE')),
  check_detail jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users (id),
  unique (app_id, business_date)
);

create table choi_tone.register_receipts (
  id uuid primary key default gen_random_uuid(),
  app_id uuid not null references choi_tone.apps (id) on delete cascade,
  store_id uuid,
  business_date date not null,
  j_no integer not null,
  r_no integer,
  -- レジのローカル時刻（タイムゾーンなし）
  txn_at timestamp,
  status text not null default '通常' check (status in ('通常', '取消', '訓練', '釣準備', '訂正', 'その他')),
  subtotal integer,
  discount_rate integer,
  discount_amount integer,
  tax_8 integer,
  tax_10 integer,
  total integer,
  item_count integer,
  -- [{"method": "現金", "amount": 1000, "service": null}, ...]
  payments jsonb not null default '[]'::jsonb,
  tendered integer,
  change_amount integer,
  source_file text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users (id),
  unique (app_id, business_date, j_no)
);

create table choi_tone.register_receipt_items (
  id uuid primary key default gen_random_uuid(),
  receipt_id uuid not null references choi_tone.register_receipts (id) on delete cascade,
  -- RLS を親テーブルとの結合なしで判定できるよう、receipts と同じ app_id を持つ。
  app_id uuid not null references choi_tone.apps (id) on delete cascade,
  line_no integer not null,
  plu text not null,
  class_s text,
  -- ジャーナル上の名前。桁幅の都合で途中で切れていることがある（識別は PLU で行う）。
  item_name_raw text,
  qty integer not null default 1,
  unit_price integer,
  amount integer not null,
  tax_class text,
  original_price integer,
  unique (receipt_id, line_no)
);

create table choi_tone.register_ingest_log (
  id uuid primary key default gen_random_uuid(),
  app_id uuid not null references choi_tone.apps (id) on delete cascade,
  store_id uuid,
  business_date date,
  source_file text,
  ingested_at timestamptz not null default now(),
  ingested_by uuid references auth.users (id),
  record_count integer not null default 0,
  receipt_count integer not null default 0,
  inserted_count integer not null default 0,
  updated_count integer not null default 0,
  deleted_count integer not null default 0,
  -- imported = 取り込んだ / rejected = 検算NGなどで取り込まなかった
  outcome text not null check (outcome in ('imported', 'rejected')),
  check_result text not null check (check_result in ('OK', 'NG', 'NONE')),
  check_detail jsonb not null default '[]'::jsonb,
  warnings jsonb not null default '[]'::jsonb
);

create index register_days_app_date_idx on choi_tone.register_days (app_id, business_date desc);
create index register_receipts_app_date_idx on choi_tone.register_receipts (app_id, business_date, j_no);
create index register_receipt_items_receipt_idx on choi_tone.register_receipt_items (receipt_id);
create index register_receipt_items_plu_idx on choi_tone.register_receipt_items (app_id, plu);
create index register_ingest_log_app_idx on choi_tone.register_ingest_log (app_id, ingested_at desc);

alter table choi_tone.register_days enable row level security;
alter table choi_tone.register_receipts enable row level security;
alter table choi_tone.register_receipt_items enable row level security;
alter table choi_tone.register_ingest_log enable row level security;

create trigger register_days_set_updated
  before update on choi_tone.register_days
  for each row execute function choi_tone.set_updated_metadata();

create trigger register_receipts_set_updated
  before update on choi_tone.register_receipts
  for each row execute function choi_tone.set_updated_metadata();

-- RLS: 他の店舗別アプリと同じ（app のスペースのメンバーが閲覧、editor が編集）。
create policy "register_days_select" on choi_tone.register_days
  for select using (
    exists (
      select 1 from choi_tone.apps a
      join choi_tone.space_members sm on sm.space_id = a.space_id
      where a.id = register_days.app_id and sm.user_id = auth.uid()
    )
    or exists (select 1 from choi_tone.system_owners so where so.user_id = auth.uid())
  );

create policy "register_days_write" on choi_tone.register_days
  for all using (
    exists (
      select 1 from choi_tone.apps a
      join choi_tone.space_members sm on sm.space_id = a.space_id
      where a.id = register_days.app_id and sm.user_id = auth.uid() and sm.role = 'editor'
    )
    or exists (select 1 from choi_tone.system_owners so where so.user_id = auth.uid())
  )
  with check (
    exists (
      select 1 from choi_tone.apps a
      join choi_tone.space_members sm on sm.space_id = a.space_id
      where a.id = register_days.app_id and sm.user_id = auth.uid() and sm.role = 'editor'
    )
    or exists (select 1 from choi_tone.system_owners so where so.user_id = auth.uid())
  );

create policy "register_receipts_select" on choi_tone.register_receipts
  for select using (
    exists (
      select 1 from choi_tone.apps a
      join choi_tone.space_members sm on sm.space_id = a.space_id
      where a.id = register_receipts.app_id and sm.user_id = auth.uid()
    )
    or exists (select 1 from choi_tone.system_owners so where so.user_id = auth.uid())
  );

create policy "register_receipts_write" on choi_tone.register_receipts
  for all using (
    exists (
      select 1 from choi_tone.apps a
      join choi_tone.space_members sm on sm.space_id = a.space_id
      where a.id = register_receipts.app_id and sm.user_id = auth.uid() and sm.role = 'editor'
    )
    or exists (select 1 from choi_tone.system_owners so where so.user_id = auth.uid())
  )
  with check (
    exists (
      select 1 from choi_tone.apps a
      join choi_tone.space_members sm on sm.space_id = a.space_id
      where a.id = register_receipts.app_id and sm.user_id = auth.uid() and sm.role = 'editor'
    )
    or exists (select 1 from choi_tone.system_owners so where so.user_id = auth.uid())
  );

create policy "register_receipt_items_select" on choi_tone.register_receipt_items
  for select using (
    exists (
      select 1 from choi_tone.apps a
      join choi_tone.space_members sm on sm.space_id = a.space_id
      where a.id = register_receipt_items.app_id and sm.user_id = auth.uid()
    )
    or exists (select 1 from choi_tone.system_owners so where so.user_id = auth.uid())
  );

create policy "register_receipt_items_write" on choi_tone.register_receipt_items
  for all using (
    exists (
      select 1 from choi_tone.apps a
      join choi_tone.space_members sm on sm.space_id = a.space_id
      where a.id = register_receipt_items.app_id and sm.user_id = auth.uid() and sm.role = 'editor'
    )
    or exists (select 1 from choi_tone.system_owners so where so.user_id = auth.uid())
  )
  with check (
    exists (
      select 1 from choi_tone.apps a
      join choi_tone.space_members sm on sm.space_id = a.space_id
      where a.id = register_receipt_items.app_id and sm.user_id = auth.uid() and sm.role = 'editor'
    )
    or exists (select 1 from choi_tone.system_owners so where so.user_id = auth.uid())
  );

create policy "register_ingest_log_select" on choi_tone.register_ingest_log
  for select using (
    exists (
      select 1 from choi_tone.apps a
      join choi_tone.space_members sm on sm.space_id = a.space_id
      where a.id = register_ingest_log.app_id and sm.user_id = auth.uid()
    )
    or exists (select 1 from choi_tone.system_owners so where so.user_id = auth.uid())
  );

create policy "register_ingest_log_write" on choi_tone.register_ingest_log
  for all using (
    exists (
      select 1 from choi_tone.apps a
      join choi_tone.space_members sm on sm.space_id = a.space_id
      where a.id = register_ingest_log.app_id and sm.user_id = auth.uid() and sm.role = 'editor'
    )
    or exists (select 1 from choi_tone.system_owners so where so.user_id = auth.uid())
  )
  with check (
    exists (
      select 1 from choi_tone.apps a
      join choi_tone.space_members sm on sm.space_id = a.space_id
      where a.id = register_ingest_log.app_id and sm.user_id = auth.uid() and sm.role = 'editor'
    )
    or exists (select 1 from choi_tone.system_owners so where so.user_id = auth.uid())
  );

grant select, insert, update, delete on choi_tone.register_days to authenticated;
grant select on choi_tone.register_days to anon;
grant select, insert, update, delete on choi_tone.register_days to service_role;
grant select, insert, update, delete on choi_tone.register_receipts to authenticated;
grant select on choi_tone.register_receipts to anon;
grant select, insert, update, delete on choi_tone.register_receipts to service_role;
grant select, insert, update, delete on choi_tone.register_receipt_items to authenticated;
grant select on choi_tone.register_receipt_items to anon;
grant select, insert, update, delete on choi_tone.register_receipt_items to service_role;
grant select, insert, update, delete on choi_tone.register_ingest_log to authenticated;
grant select on choi_tone.register_ingest_log to anon;
grant select, insert, update, delete on choi_tone.register_ingest_log to service_role;

-- 「レジデータ」スペースと、店舗ごとのアプリ。
-- スペースは固定 ID で作る（環境間で ID をそろえるため。原材料計算と同じ）。
-- 店舗アプリは受発注・棚卸しと同じ本部・製造部を除く11店舗ぶん。店舗マスタに店舗が増えたら、
-- 同じ形の migration で足す（apps.store_id に店舗マスタの id、slug も同じ id）。
insert into choi_tone.spaces (id, name)
values ('d89ca692-5f7b-4f6b-aa66-46f1e1f08167', 'レジデータ')
on conflict (id) do nothing;

insert into choi_tone.apps (space_id, name, slug, store_id, is_register_data)
values
  ('d89ca692-5f7b-4f6b-aa66-46f1e1f08167', 'CheesePigeセノバ店', '575b8067-d67e-4528-b109-b13962900280', '575b8067-d67e-4528-b109-b13962900280', true),
  ('d89ca692-5f7b-4f6b-aa66-46f1e1f08167', 'CheesePige横浜ジョイナス店', 'ecf4009d-3db7-4b9a-b7c6-0865c3f4bad2', 'ecf4009d-3db7-4b9a-b7c6-0865c3f4bad2', true),
  ('d89ca692-5f7b-4f6b-aa66-46f1e1f08167', 'CheesePige浜松遠鉄店', 'd9eb4bbc-485c-4b7c-85e0-511c584207ef', 'd9eb4bbc-485c-4b7c-85e0-511c584207ef', true),
  ('d89ca692-5f7b-4f6b-aa66-46f1e1f08167', 'CheesePige焼津本店', 'be495a02-0bb3-484e-b894-b7b0614bf011', 'be495a02-0bb3-484e-b894-b7b0614bf011', true),
  ('d89ca692-5f7b-4f6b-aa66-46f1e1f08167', 'CookiePigeイオン石田店', '49c3dc22-63ab-49ca-93a1-d65b241d72d3', '49c3dc22-63ab-49ca-93a1-d65b241d72d3', true),
  ('d89ca692-5f7b-4f6b-aa66-46f1e1f08167', 'CookiePigeパルシェ店', '77ced42b-abb9-4144-99c6-82a2cb1d5d6c', '77ced42b-abb9-4144-99c6-82a2cb1d5d6c', true),
  ('d89ca692-5f7b-4f6b-aa66-46f1e1f08167', 'CookiePige用宗店', '134865ed-f931-4888-ad9d-55aa69d7bf24', '134865ed-f931-4888-ad9d-55aa69d7bf24', true),
  ('d89ca692-5f7b-4f6b-aa66-46f1e1f08167', 'PIGE CAFE焼津駅前店', '5632ec15-1dca-4cbe-833a-f9c9728331b5', '5632ec15-1dca-4cbe-833a-f9c9728331b5', true),
  ('d89ca692-5f7b-4f6b-aa66-46f1e1f08167', 'サントムーン店', 'd0dfe23c-b058-44f2-8274-daaf3cdb02b8', 'd0dfe23c-b058-44f2-8274-daaf3cdb02b8', true),
  ('d89ca692-5f7b-4f6b-aa66-46f1e1f08167', '南与野店', '61dac183-76cb-4b4d-8e8a-26b146c0b61a', '61dac183-76cb-4b4d-8e8a-26b146c0b61a', true),
  ('d89ca692-5f7b-4f6b-aa66-46f1e1f08167', '御殿場店', '02d6697b-3308-4eb6-addb-826a6bd3aa51', '02d6697b-3308-4eb6-addb-826a6bd3aa51', true);

-- 「管理者」権限グループ（ddb8ad6d-08f4-4c74-8416-49e28e90d0fd）に editor で持たせる。
-- これを入れないと、システムオーナー以外は誰もこのスペースを開けない。
-- 店舗スタッフに使わせるときは、画面の権限管理（/permissions）でこのスペースを付与する。
insert into choi_tone.permission_group_spaces (group_id, space_id, role)
values ('ddb8ad6d-08f4-4c74-8416-49e28e90d0fd', 'd89ca692-5f7b-4f6b-aa66-46f1e1f08167', 'editor')
on conflict do nothing;
