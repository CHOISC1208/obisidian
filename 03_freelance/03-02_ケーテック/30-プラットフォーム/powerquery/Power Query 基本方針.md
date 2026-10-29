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
- `Table.SelectColumns` は厳格(列が無いとエラー)。XML から列を消してもテナントには残るため、通常は問題ない。
  新しい環境で列が無いときは、そのエラーが「列が足りない」というサインになる。

## 2. サイトURL

パラメーターにせず、**各クエリに直書き**する(ファイルを他人に共有するため、パラメーター定義が無くても開けるようにする)。
現在の対象は ver11.0.7 のサイト。

```
https://ktec19950401.sharepoint.com/sites/s-portal_ver11.0.7
```

サイトを切り替える(ミニテナント⇔先方、ver更新)ときは、各クエリの `SharePoint.Tables("…", …)` の URL を書き換える。
全クエリを置換するときは、Power Query エディターの「高度なエディター」を開いて一括で直すか、旧URLを検索して置換する。

## 3. 注意(Person / Lookup 列)

- `Applicant` / `Approver` / `LeaderApprover` などの **Person 列**、`MenuItem` / `EmployeeMasterRef` などの **Lookup 列**は、
  Record で返る。各ノートではリネームだけして、展開(`Table.ExpandRecordColumn`)は**入れていない**。
  展開できる項目名(`Title` / `EMail` など)は実機で確認してから足す。確認できたら本ノートに追記すること。
- 選択肢列(複数選択)は List で返ることがある。
- 申請系は共通列(`Applicant` ~ `ApprovalMessage`)をすべて含む。不要な列は `必要列` の列名リストから消す。
- `作成日時`(`Created`)は全リストに付けてある。

## 4. 対象外

- `督促対象設定`(`ReminderConfig`、`apply-order.json` で enabled=false)
- `勤怠データ提出状況`(`KintaiSubmissions`、システム化取り下げ)
- `_pending/` 配下の4リスト(No.8 / 11 / 12 / 14、enabled=false)

## 5. 未確定・次にやること

- 慶弔マスタ以外の取得確認(列名の食い違い、`Title` でのリスト名指定が通るか)
- Person / Lookup 列の展開項目の確認
- 海外保険加入依頼の `TravelerName`(旧・Person)は過去環境の名残で、新規データでは空。不要なら列名リストから消す
- 申請リスト間の結合(申請者×勤怠など)や集計の型は未整理
