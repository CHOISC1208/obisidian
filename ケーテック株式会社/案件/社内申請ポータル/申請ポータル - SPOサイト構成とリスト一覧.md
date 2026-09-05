---
tags:
  - ケーテック
  - 案件
  - データ設計
client: ケーテック株式会社
親論点: テーマ1 - 電子化をどこまで広げるか
フェーズ: 開発中
created: 2026-09-05
updated: 2026-09-05
---

# 申請ポータル - SPOサイト構成とリスト一覧

親: [[申請ポータル - 00 概要]] ／ [[00 MOC|ケーテック株式会社 MOC]]

## サイト構成の考え方

**申請系をすべて1つの SPO サイトに集約する。** リスト・フロー・SPFxアプリ・マニュアルをここに集める。
`config/{env}.json` の `SiteUrl` がそのサイトを指す。

理由: 権限グループの管理が1箇所で済み、SPFx の Webパーツも1つのサイトコレクション
アプリカタログに置けば全APPで共有できるため。

## 番号規約（このプロジェクトの背骨）

**リスト番号 = 課題No（`issues/` の番号）**。3つの場所で同じ番号を使う。

| 使う場所 | 例（No.7 年休申請） |
|---|---|
| テンプレートのファイル名接頭辞 | `template/20_requests/07_leave-request.xml` |
| 固有列 GUID の第2グループ | `{........-2007-....-....-............}` |
| 要件定義書のファイル名 | `issues/07_要件定義書_年休申請.md` |

> [!important] 適用順序はファイル名では表さない
> **`template/apply-order.json` が唯一の正**。上から順に `Invoke-PnPSiteTemplate` する。
> Lookup や FieldRef の参照先を先に作る必要があるため、順序は `00_common` → `10_masters` → `20_requests`。
> ファイル名の数字は課題Noであって適用順ではない。

## リスト一覧（適用順）

| # | パス | リスト内部名 | 表示名 | 有効 | 備考 |
|---|---|---|---|---|---|
| 1 | `00_common/01_site-columns.xml` | — | — | ✅ | 共通サイト列7本 → [[申請ポータル - 共通列とコンテンツタイプ]] |
| 2 | `00_common/02_content-types.xml` | — | 申請共通 | ✅ | 基底コンテンツタイプ（親: アイテム `0x01`） |
| 3 | `10_masters/12_keicho-master.xml` | `KeichoMaster` | 慶弔マスタ | ✅ | 制度種別×対象者×雇用区分×同居×業務上 → 金額 |
| 4 | `10_masters/13_menu-master.xml` | `MenuMaster` | メニューマスタ | ✅ | メニュー名＋価格の単純表（2026-08-22 に簡素化） |
| 5 | `10_masters/14_business-calendar.xml` | `BusinessCalendar` | 営業日カレンダー | ✅ | 督促フローの経過日数判定用。**現状どこからも参照されていない** |
| 6 | `10_masters/15_reminder-config.xml` | `ReminderConfig` | 督促対象設定 | ❌ | 中央承認エンジン専用。廃止済みだがファイルは残置 |
| 7 | `10_masters/16_destination-master.xml` | `DestinationMaster` | 渡航先マスタ | ✅ | 2026-08-17 新設。表記ブレ防止のため No.3 が Lookup 参照 |
| 8 | `20_requests/07_leave-request.xml` | `LeaveRequests` | 年休申請 | ✅ | **雛形**。最初に完成させ他へ横展開 |
| 9 | `20_requests/01_advance-payment.xml` | `AdvancePayments` | 仮払金申請 | ✅ | |
| 10 | `20_requests/02_keicho-report.xml` | `KeichoReports` | 慶弔連絡 | ✅ | 項目レベル権限の対象（総務人事のみ閲覧） |
| 11 | `20_requests/03_overseas-insurance.xml` | `OverseasInsurance` | 海外保険加入依頼 | ✅ | 唯一の2段承認APP |
| 12 | `20_requests/06_lunch-order.xml` | `LunchOrders` | 昼食申込 | ✅ | 承認不要（客専用時のみ論点あり） |
| 13 | `20_requests/09_kintai-submission.xml` | `KintaiSubmissions` | 勤怠データ提出状況 | ❌ | 2026-08-17 取り下げ。復活に備え残置 |
| 14 | `_pending/08_seal-request.xml` | `SealRequests` | 実印申請 | ❌ | 2026-08-17 取り下げ |
| 15 | `_pending/11_permission-request.xml` | `PermissionRequests` | 許可申請 | ✅ | **別紙未入手のまま仮組みで適用中** |
| 16 | `_pending/12_travel-expense.xml` | `TravelExpenses` | 旅費申請 | ❌ | 2026-08-27 保留（紙運用継続） |
| 17 | `_pending/14_grant-standard.xml` | `GrantStandards` | 付与基準確認 | ❌ | 2026-08-27 取り下げ |

**適用されるのは 12 本**（共通2 ＋ マスタ4 ＋ 申請6）。

> [!warning] `_pending/` の扱いに注意
> `_pending/` は「ヒアリング/別紙待ちで、一般的な業務知識から仮組みした骨子」を置くフォルダ。
> **`11_permission-request.xml` だけ `enabled:true` のまま適用されている**。要件と乖離している
> 可能性が高く、別紙入手後は列定義ごと作り直す前提で扱うこと。
> → [[申請ポータル - APP No.11 許可申請（仮組み）]]

## 廃止したリスト（中央承認エンジンの残骸）

簡易承認方式への転換（2026-08-10）で削除された。**`docs/conventions.md` にはまだ定義が残っている**。

| リスト | 何だったか | なぜ不要になったか |
|---|---|---|
| `ApproverMaster` | 部署→所属長・代理承認者・上位承認者のマスタ | 承認者を申請時に選ぶ方式にしたため → [[テーマ2 - 承認者をどう決めるか]] |
| `RequestTypeSettings` | 種別ごとの承認段数・承認者解決方法・督促日数 | 中央フローが読む設定だったが、中央フロー自体が無くなった |
| `ApprovalTransactions` | 承認トランザクション（スナップショット・段階管理） | 同上 |
| `AuditLog` | 追記専用の監査ログ（ハッシュチェーン用の列付き） | 簡易承認方式では必須にしない方針に変更 |
| `ReminderConfig` | 督促対象設定 | `RequestTypeSettings` へ統合後、まとめて廃止 |

> [!tip] 削除しても消えないもの
> **XML から列定義やリストを消しても、テナント側の列・リストは消えない**（サイト列とコンテンツタイプの
> 両方に残る）。先方環境に旧リストが残っている可能性があり、その場合は `Remove-PnPField` や
> リスト削除の手作業が必要。→ [[申請ポータル - PnPテンプレートの落とし穴]]

## 既定ビューの制御

共通列（コンテンツタイプ経由で入る列）は、個々の `Field` 定義がリスト内に無いため
`AddToDefaultView="true"` では制御できない。そこで **`ListInstance` 直下に `pnp:Views` を明示**し、
`RemoveExistingViews="true"` で既存ビューを削除してから新規ビューだけにしている。

理由: 既定ビューの表示名は環境のロケールで変わる（日本語UIでは「すべてのアイテム」）ため、
表示名を合わせてマージさせる方法は locale 依存で脆い。

各リストの既定ビューには、`Applicant`（申請者）と並べて**組み込みの `Author`（作成者）を表示**している。
フローが動く前・失敗したときに `Applicant` が空になるが、`Author` は SharePoint が必ず設定し
書き換えもできないため、誰が起票したかは常に追える。

## 関連

- 列の詳細 → [[申請ポータル - 共通列とコンテンツタイプ]] ／ 各APPノート
- 権限 → [[申請ポータル - 権限設計とデータ保護]]
- 適用の実行方法 → [[申請ポータル - デプロイ経路]]
