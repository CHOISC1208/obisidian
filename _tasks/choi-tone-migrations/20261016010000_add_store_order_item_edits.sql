-- 店舗別受発注: 納品完了後の修正履歴（R12）。
--
-- 従来は納品完了にすると確定数量・納品数量を動かせなかった。「納品完了にした人（delivered_by）」
-- なら完了後も修正できるようにし、そのときの「誰が・いつ・どの品目の何を 前→後」をここに残す。
-- 確定数量の修正は追加発注（store_order_item_additions）の差分として積むので、
-- 受発注管理（store_order_report）の集計は既存のまま修正後の値になる。
--
-- delivered_by が null の既存レコード（記録者が不明）は、そのスペースの editor なら誰でも修正できる扱い
-- （アプリ側の判定。ここでは制限しない）。

create table choi_tone.store_order_item_edits (
  id uuid primary key default gen_random_uuid(),
  store_order_record_id uuid not null references choi_tone.store_order_records (id) on delete cascade,
  -- 品目が消えても履歴は残したいので on delete set null。商品名は修正時点の値をコピーして持つ。
  store_order_item_id uuid references choi_tone.store_order_items (id) on delete set null,
  product_name text not null,
  -- 'confirmed_quantity'（確定数量）／'delivered_quantity'（納品数量）
  field text not null check (field in ('confirmed_quantity', 'delivered_quantity')),
  old_value numeric,
  new_value numeric,
  edited_at timestamptz not null default now(),
  edited_by uuid references auth.users (id)
);

create index store_order_item_edits_record_id_idx
  on choi_tone.store_order_item_edits (store_order_record_id, edited_at);

alter table choi_tone.store_order_item_edits enable row level security;

create policy "store_order_item_edits_select" on choi_tone.store_order_item_edits
  for select using (
    exists (
      select 1 from choi_tone.store_order_records r
      join choi_tone.apps a on a.id = r.app_id
      join choi_tone.space_members sm on sm.space_id = a.space_id
      where r.id = store_order_item_edits.store_order_record_id and sm.user_id = auth.uid()
    )
    or exists (select 1 from choi_tone.system_owners so where so.user_id = auth.uid())
  );

create policy "store_order_item_edits_insert" on choi_tone.store_order_item_edits
  for insert with check (
    exists (
      select 1 from choi_tone.store_order_records r
      join choi_tone.apps a on a.id = r.app_id
      join choi_tone.space_members sm on sm.space_id = a.space_id
      where r.id = store_order_item_edits.store_order_record_id
        and sm.user_id = auth.uid() and sm.role = 'editor'
    )
    or exists (select 1 from choi_tone.system_owners so where so.user_id = auth.uid())
  );
-- 履歴なので update / delete のポリシーは作らない（レコード削除時の cascade のみ）。

grant select, insert on choi_tone.store_order_item_edits to authenticated;
