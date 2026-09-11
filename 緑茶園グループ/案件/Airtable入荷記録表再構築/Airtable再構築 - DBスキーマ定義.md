---
tags:
  - 緑茶園
  - 案件
  - Airtable
  - データモデル
  - スキーマ定義
client: 緑茶園グループ
created: 2026-09-11
updated: 2026-09-11
aliases:
  - Airtable再構築 DDL
  - 入荷記録表 新DBスキーマ
---

# DBスキーマ定義：Airtable「入荷記録表」再構築（第1弾＝仕入側）

親: [[Airtable再構築 - 00 概要|案件概要]] ／ 要件: [[Airtable再構築 - 要件定義ドラフト]] ／ AS-IS調査: [[Airtable再構築 - データモデル設計比較]]

> [!info] 本書の位置づけ
> 全23テーブルをAirtable APIで棚卸しした結果に基づく、Supabase（Postgres）向けの実装用スキーマ定義（2026-09-11）。[[Airtable再構築 - データモデル設計比較]] が「現行の何が問題か」を扱うのに対し、本書は「新しく何を作るか」だけを扱う。対象は第1弾＝仕入側（→ [[Airtable再構築 - 要件定義ドラフト]] の第1弾／第2弾の切り分け）。

## 棚卸しサマリ

| | 現行Airtable | 新スキーマ |
|---|---|---|
| テーブル | 23 | **13**（第1弾） |
| フィールド／カラム | **640** | **約90** |

現行640フィールドの内訳と処遇：

| 処遇 | 対象 | フィールド数の目安 |
|---|---|---|
| 🗑️ 第2弾へ | ☑請求書作成・☑納品書作成・☑取引内容一覧・☑顧客リスト・☑販売商品マスタ・☑販売価格履歴 | 138 |
| 🗑️ 廃止（SQLで代替） | 販売規格(86)・月統計(38)・年統計(33) | 157 |
| 🗑️ アーカイブのみ | 【8】旧・入荷記録表 | 17 |
| 🗑️ 廃止（rollup／formula／lookup／copy残骸） | 各テーブルに分散 | 約240 |
| ✅ 移行 | 実データを持つフィールド | **約90** |

## 設計原則

1. **導出できる値は保存しない。** rollup・集計formulaは全廃し、SQLで都度計算する。「取引先が増えるたびに列を足す」構造を根絶する
2. **同じ属性を二重に持たない。** 現行の商品マスタは等級・階級・量目・入数・玉数・荷姿を「singleSelect」と「マスタへのリンク」の両方で保持しており、乖離しうる（実際に`等級emptyチェック``量目emptyチェック`という手作りの検知用フィールドが存在する）。新設計では外部キー1本に統一する
3. **入力補助のための構造をデータに持ち込まない。** 現行はマスタ間に「品種（紐付け）」「荷姿（紐付け）」といった候補絞り込み用リンクを張っているが、これは「この品種でこの等級が使われたことがある」という情報であり、`SELECT DISTINCT` で商品データから導出できる。専用テーブルは作らない
4. **ハードコードされた業務ルールをデータにする。** 税率（÷1.08の直書き）と支払サイト（取引先マスタのテキスト）を構造化する
5. **マスタを消してもトランザクションが消えない。** 全外部キーを `ON DELETE RESTRICT` にする（2026-07のデータ破損の直接の再発防止策 → [[Airtable再構築 - ヒアリング回答ログ]] Q2）

## DDL

```sql
create extension if not exists btree_gist;   -- 原価履歴の期間重複排除に使用

-- ============================================================
-- マスタ
-- ============================================================

create table partners (                        -- 【3】取引先（35件）
  id                bigserial primary key,
  name              text not null,
  name_for_print    text,                      -- 帳票用の表記
  name_kana         text,
  partner_type      text not null
                      check (partner_type in ('producer','wholesaler','other')),
  status            text not null default 'active'
                      check (status in ('active','ended')),
  invoice_reg_no    text,                      -- 適格請求書発行事業者登録番号（現行35件中2件のみ登録）
  payment_method    text
                      check (payment_method in ('bank_transfer','cash','cash_collect')),
  -- 支払サイト：現行は「当月末締め/翌月25日払い」等のテキスト。35件すべて当月末締め
  closing_type      text not null default 'month_end'
                      check (closing_type in ('month_end')),
  payment_day_type  text not null default 'fixed'
                      check (payment_day_type in ('fixed','month_end','negotiable')),
  payment_day       smallint check (payment_day between 1 and 31),
  postal_code       text,
  address1          text,
  address2          text,
  phone             text,
  fax               text,
  email             text,
  note              text,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  check (payment_day_type <> 'fixed' or payment_day is not null)
);

create table species (                         -- 【6】種別（りんご・さくらんぼ等）
  id bigserial primary key,
  name text not null unique,
  sort_order int not null default 0
);

create table varieties (                       -- 【7】品種（99件）
  id bigserial primary key,
  species_id bigint not null references species(id) on delete restrict,
  name text not null,
  sort_order int not null default 0,
  unique (species_id, name)
);

-- 以下6つは同じ形。個別テーブルにするのは外部キーで取り違えを防ぐため
create table grades       (id bigserial primary key, name text not null unique, sort_order int not null default 0); -- 【9】等級
create table classes      (id bigserial primary key, name text not null unique, sort_order int not null default 0); -- 【11】階級
create table weights      (id bigserial primary key, name text not null unique, sort_order int not null default 0); -- 【10】量目
create table pack_counts  (id bigserial primary key, name text not null unique, sort_order int not null default 0); -- 【12】入数
create table piece_counts (id bigserial primary key, name text not null unique, sort_order int not null default 0); -- 【13】玉数・房数
create table packagings   (id bigserial primary key, name text not null unique, sort_order int not null default 0); -- 【14】荷姿

create table tax_rates (                       -- 新設：現行は÷1.08の直書き
  id bigserial primary key,
  rate           numeric(4,3) not null,        -- 0.080 / 0.100
  label          text not null,                -- 軽減税率 / 標準税率
  effective_from date not null,
  effective_to   date,
  unique (rate, effective_from)
);

-- ============================================================
-- 商品
-- ============================================================

create table products (                        -- 【4】商品マスタ（2,894件）
  id             bigserial primary key,
  product_code   text not null unique,         -- 現行SKU「0014-XXXX」を引き継ぐ
  partner_id     bigint not null references partners(id)   on delete restrict,
  species_id     bigint not null references species(id)    on delete restrict,
  variety_id     bigint references varieties(id)     on delete restrict,
  grade_id       bigint references grades(id)        on delete restrict,
  class_id       bigint references classes(id)       on delete restrict,
  weight_id      bigint references weights(id)       on delete restrict,
  pack_count_id  bigint references pack_counts(id)   on delete restrict,
  piece_count_id bigint references piece_counts(id)  on delete restrict,
  packaging_id   bigint references packagings(id)    on delete restrict,
  tax_rate_id    bigint not null references tax_rates(id)  on delete restrict,
  status         text not null default 'active'
                   check (status in ('active','discontinued','on_hold')),
  note           text,
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now(),
  -- 現行の「商品タイトル」formulaが暗黙に担っていた一意性をDB制約に格上げする。
  -- 8要素のうち商品によってNULLの要素があるため nulls not distinct が必須（PG15以降）
  unique nulls not distinct
    (partner_id, variety_id, grade_id, class_id, weight_id,
     pack_count_id, piece_count_id, packaging_id)
);

create index on products (partner_id) where status = 'active';
create index on products (variety_id);

create table product_prices (                  -- 【5】原価履歴（639件、うち空レコードあり）
  id             bigserial primary key,
  product_id     bigint not null references products(id) on delete restrict,
  purchase_price integer not null,             -- 税込
  effective_from date not null,
  effective_to   date,                         -- NULL = 現在有効
  created_at     timestamptz not null default now(),
  check (effective_to is null or effective_to >= effective_from),
  -- 現行テーブルの説明文に「必ず過去の価格の適用終了日を設定してください」と
  -- 書かれている＝設定漏れが起きる前提の運用。DB制約で期間の重複を弾く
  exclude using gist (
    product_id with =,
    daterange(effective_from, coalesce(effective_to, 'infinity'::date), '[]') with &&
  )
);

create table marketplace_codes (               -- 新設：外部モールの商品販売コード
  id         bigserial primary key,
  product_id bigint not null references products(id) on delete cascade,
  channel    text not null,                    -- 楽天 / Amazon / crossmall 等
  code       text not null,
  created_at timestamptz not null default now(),
  unique (channel, code)
);

-- ============================================================
-- 取引・支払明細
-- ============================================================

create table payment_statements (              -- 【1】月締め入荷記録＝支払明細書（80件）
  id             bigserial primary key,
  statement_seq  integer not null unique,      -- 現行autoNumberを引き継ぐ（欠番あり）
  statement_no   text generated always as (
                   extract(month from closing_date)::int::text
                   || '-' || (10000 + statement_seq)::text
                 ) stored,
  partner_id     bigint not null references partners(id) on delete restrict,
  closing_date   date not null,                -- 締め日（月末とは限らない。月中締めが実在）
  due_date       date,                         -- 支払期日（partnersから自動計算＋手動上書き可）
  is_sent        boolean not null default false,
  note           text,
  pdf_path       text,                         -- Supabase Storageのパス
  created_at     timestamptz not null default now(),
  updated_at     timestamptz not null default now()
);

create index on payment_statements (partner_id, closing_date desc);

create table transactions (                    -- 【2】取引内容一覧（5,642件）
  id                   bigserial primary key,
  transaction_seq      integer not null unique,   -- 現行「取引ID」の連番
  transaction_date     date not null,
  product_id           bigint not null references products(id) on delete restrict,
  quantity             integer not null check (quantity > 0),
  unit_price           integer not null,          -- 税込単価（現行運用どおり）
  tax_rate             numeric(4,3) not null,     -- 取引時点の税率を固定保持
  payment_status       text not null default 'awaiting'
                         check (payment_status in
                           ('awaiting','statement_issued','excluded','completed')),
  payment_statement_id bigint references payment_statements(id) on delete restrict,
  note                 text,
  created_at           timestamptz not null default now(),
  created_by           uuid references auth.users(id),
  updated_at           timestamptz not null default now()
);

create index on transactions (transaction_date);
create index on transactions (payment_statement_id);
create index on transactions (product_id);
create index on transactions (payment_status) where payment_status = 'awaiting';

-- ============================================================
-- 監査（2026-07のデータ破損の再発防止）
-- ============================================================

create table audit_logs (
  id          bigserial primary key,
  table_name  text not null,
  record_id   bigint not null,
  action      text not null check (action in ('insert','update','delete')),
  changed_by  uuid,
  changed_at  timestamptz not null default now(),
  before_data jsonb,
  after_data  jsonb
);

create index on audit_logs (table_name, record_id, changed_at desc);
```

## 集計ビュー：現行の rollup 157フィールドを置き換える

```sql
-- 支払明細書の税率別集計。インボイス制度が求める「税率ごとに1回の端数処理」と同じ粒度。
-- 現行の ÷1.08 直書きを置き換える本体
create view v_statement_totals as
select
  t.payment_statement_id,
  t.tax_rate,
  sum(t.quantity * t.unit_price)                                        as amount_incl_tax,
  round(sum(t.quantity * t.unit_price) * t.tax_rate / (1 + t.tax_rate)) as tax_amount,
  sum(t.quantity * t.unit_price)
    - round(sum(t.quantity * t.unit_price) * t.tax_rate / (1 + t.tax_rate)) as amount_ex_tax
from transactions t
where t.payment_statement_id is not null
group by t.payment_statement_id, t.tax_rate;
```

検証：支払明細書 8-10109（阿部大介、2026-08-31）は税込合計 51,071。`round(51071 × 0.08 ÷ 1.08)` = 3,783、税抜 = 47,288 で**現行PDFと一致**。

現行の統計テーブル（販売規格86・月統計38・年統計33フィールド）は、すべて下記の形のクエリ1本に置き換わる。取引先や年が増えても列を足す必要がない。

```sql
select date_trunc('month', t.transaction_date) as month,
       p.partner_id, sum(t.quantity), sum(t.quantity * t.unit_price)
from transactions t join products p on p.id = t.product_id
group by 1, 2;
```

## 廃止するものと理由

| 現行 | 廃止理由 |
|---|---|
| 商品マスタの月別rollup 12個＋`12月取引数量 copy` | `GROUP BY date_trunc('month', …)` |
| 商品マスタの年別rollup（24年/25年/26年） | 年が変わるたびに列追加する構造そのものが不要 |
| 商品マスタの singleSelect 版 等級・階級・量目・入数・玉数・荷姿 | リンク版と二重管理。外部キー1本に統一 |
| `等級emptyチェック` `量目emptyチェック` | 上の二重管理を検知するための手作りフィールド。原因ごと消える |
| 商品マスタの `販売規格名組合せ` `商品` formula | 目的不明・未使用。移植せず廃棄（2026-09-11決定） |
| 商品マスタの `【集計用】商品タイトル` `【集計用】荷姿＊等級＊…` | 未使用。集計はCSV→Excelピボットに移行済み |
| 取引内容一覧の 9つの `【商品マスタ参照】` lookup | 商品経由でJOINすれば取れる |
| 取引内容一覧の 8マスタへの直リンク | 入力時の候補絞り込み用。UIの責務であってデータではない |
| 取引内容一覧の `年統計` `月統計` `販売規格` リンク | 集計テーブルごと廃止 |
| マスタ間の `品種（紐付け）` `荷姿（紐付け）` 等 | `SELECT DISTINCT` で商品データから導出 |
| 品種テーブルの等級×荷姿別rollup 11個＋年別集計 | 同上 |
| 各テーブルの `copy` `copy copy` `copy 2` `Field 31` 等の残骸 | 【9】等級だけで10個以上。すべて削除 |
| DocsAutomator呼び出しボタン（APIキーが平文で埋まっている） | 自前PDF生成またはAPIキーをサーバ側の環境変数へ |

## 移行時の注意

1. 🔴 **原価履歴の税区分**：2025-11-01の価格改定が「8%値上げ」か「税抜→税込への表記統一」か未確定。後者なら2025-10-31以前のレコードは税抜で、同じ列に混在している（→ [[08 要確認事項]]）。**確定するまで移行スクリプトを書かない**
2. **空レコードのクレンジング**：原価履歴639件に、商品リンクも価格も持たない空レコード（例 PH0-616）が混在
3. **番号の欠番を保つ**：支払明細書番号・商品コード・取引IDはいずれも `固定プレフィックス＋オフセット＋autoNumber` 形式で、削除による欠番がある。番号を引き継ぐなら連番を明示カラムとして移行し、新システム側のシーケンスは既存の最大値から開始する
4. **商品の重複**：`unique nulls not distinct` を張ると既存データが弾かれる可能性がある。移行前に重複チェックを走らせる
5. **添付ファイル**：支払明細書PDF 80件をSupabase Storageへ移す

## 関連ノート

- [[Airtable再構築 - 00 概要]]
- [[Airtable再構築 - 要件定義ドラフト]] — スコープとマイルストーン
- [[Airtable再構築 - データモデル設計比較]] — 現行の何が問題かのAS-IS分析
- [[Airtable再構築 - ヒアリング回答ログ]] — 設計判断の根拠となった回答
- [[08 要確認事項]] — 移行前に潰すべき確認事項
