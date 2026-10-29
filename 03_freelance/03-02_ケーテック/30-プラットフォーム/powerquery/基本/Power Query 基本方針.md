---
tags:
  - ケーテック
  - プラットフォーム
  - PowerQuery
client: ケーテック株式会社
created: 2026-10-29
updated: 2026-10-29
---

# Power Query 基本方針

親: [[30-プラットフォーム/powerquery/Power Query MOC|Power Query MOC]] ／ 列名の元表: [[30-プラットフォーム/powerautomate/リスト別 列名対応表(Power Automate用)]]

> [!info] このノートの役割
> Power Query でSPOのリストを取得するときの共通の前提。リスト別の M コードは [[30-プラットフォーム/powerquery/Power Query MOC|MOC]] から辿る。
> 検証できたのは慶弔マスタのみ。

## 1. 基本方針(検証で分かったこと)

- 取得は `SharePoint.Tables(url, [Implementation = null, ApiVersion = 15])`(1.0)を使う。
  列名は**内部名(英語)**で返る。リストの表示名は使われない。
- `Implementation = "2.0"` は使わない。2.0 では `ApiVersion` オプションを渡せず(渡すとエラー)、
  `ViewMode` / `Implementation` / `DisableAppendNoteColumns` のみ有効。さらに `RenderListDataAsStream` が 500 を返して取得できなかった。
- リストは **GUID でなくリスト名**(`[Title = "慶弔マスタ"]`)で選ぶ。GUID はテナントごとに変わるため、納品先でも流用できる。
  「見つかりません」になったら `[Name = "KeichoMaster"]`(内部名)に変える。
- 日本語見出しにするのは `Table.RenameColumns`。内部名は固定なので壊れにくい。
- `Table.SelectColumns` には `MissingField.UseNull` を付けてある(2026-10-29)。**行が0件のリストは、列が0個のテーブルで返る**ことがあり、
  厳格だと「列が見つかりません」で止まるため(休日出勤などで実際に空のテーブルになった)。
  欠けた列は `null` の列になるので、リネーム以降のステップは通る。
  代わりに、列名の違いを**エラーで気づけなくなる**。列が全部 `null` のときは、リストが空か、内部名が違うかを確認する。

## 2. サイトURL

パラメーターにせず、**各クエリに直書き**する(ファイルを他人に共有するため、パラメーター定義が無くても開けるようにする)。
現在の対象は ver11.0.7 のサイト。

```
https://ktec19950401.sharepoint.com/sites/s-portal_ver11.0.7
```

サイトを切り替える(ミニテナント⇔先方、ver更新)ときは、各クエリの `SharePoint.Tables("…", …)` の URL を書き換える。
全クエリを置換するときは、Power Query エディターの「高度なエディター」を開いて一括で直すか、旧URLを検索して置換する。

## 3. 型変換と日時(2026-10-29追加)

各クエリの末尾で、列の型を XML の定義どおりに付ける(数値・通貨・はい/いいえ・テキスト・日付・日時)。

- **日時はUTCで返る**。実データで確認: 作成日時が `03:57` なら日本時間は `12:57`。日付のみの列(支払希望日など)も
  日本時間の0時が前日15時のUTCで入っているため、そのまま日付にすると**1日ずれる**。
- そのため各クエリの先頭に `JST = (x) => DateTime.From(x) + #duration(0, 9, 0, 0)` を置き、+9時間してから型を付ける。
  日付のみの列(`Format="DateOnly"`)は日付型、`承認日時`・`作成日時` は日時型。
- `DateTime.From` は日時・数値(Excelのシリアル値)・テキストのどれでも受けるので、取得時に列が型なしでも動く。
- サイトの地域設定が日本標準時でない場合は、`#duration(0, 9, 0, 0)` の 9 を直す。
- 複数値になりうる選択肢列は型を付けていない(List のまま)。

## 4. Person列と Lookup列

- `Applicant` / `Approver` / `LeaderApprover` などの **Person列**は Record で返る(`[Record]` と表示される)。
  各クエリで `人名` 関数により、**氏名(Record の `Title`、無ければ `DisplayName`)の文字列**に置き換えている。
  複数人の列は「、」区切りにする。メールアドレスは出していない(必要なら `EMail` を取る列を足す)。
- Record の項目名(`Title` が氏名か)は**実機で確認していない**。氏名が空(`null`)になるときは、その列を手で展開して項目名を見て、
  `人名` 関数の `"Title"` を合わせる。確認できたら本ノートに追記すること。
- `MenuItem` / `EmployeeMasterRef` / `TravelerEmployeeRef` などの **Lookup列**も Record で返る想定。
  各クエリで `参照値` 関数により、**表示値(参照列の `ShowField`)の文字列**に置き換えている
  (`Id` を除いた Record の `Value` → `Title` → 先頭の項目、の順で取る)。
  ShowField は `MenuItem`=メニュー名、`EmployeeMasterRef`=氏名、`TravelerEmployeeRef`=従業員番号。
  Record の項目名は実機で未確認。名前が出ないときは、その列を手で展開して項目名を見て、`参照値` を合わせる。
  マスタの他の列(価格・ご飯の量など)まで付けたいときは、応用([[30-プラットフォーム/powerquery/Power Query MOC|MOC]])で結合する。
- 複数値になりうる選択肢列は List で返ることがある(型は付けていない)。
- 申請系は共通列(`Applicant` ~ `ApprovalMessage`)をすべて含む。不要な列は `必要列` の列名リストから消す。
- `作成日時`(`Created`)は全リストに付けてある。

## 5. 対象外

- `督促対象設定`(`ReminderConfig`、`apply-order.json` で enabled=false)
- `勤怠データ提出状況`(`KintaiSubmissions`、システム化取り下げ)
- `_pending/` 配下の4リスト(No.8 / 11 / 12 / 14、enabled=false)

## 6. 未確定・次にやること

- 慶弔マスタ以外の取得確認(列名の食い違い、`Title` でのリスト名指定が通るか)
- Person / Lookup 列の展開項目の確認
- 海外保険加入依頼の `TravelerName`(旧・Person)は過去環境の名残で、新規データでは空。不要なら列名リストから消す
- 申請リスト間の結合(申請者×勤怠など)や集計の型は未整理
