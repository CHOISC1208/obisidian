---
tags:
  - ケーテック
  - プラットフォーム
  - PowerQuery
client: ケーテック株式会社
created: 2026-10-29
updated: 2026-10-29
---

# Power Query MOC

親: [[00 MOC|ケーテック株式会社 MOC]] ／ 列名の元表: [[30-プラットフォーム/powerautomate/リスト別 列名対応表(Power Automate用)]]

SPOサイトのリストを Power Query(Excel / Power BI)で取得する M コードの入口。
基本は1リスト=1ノート、応用は複数リストを結合したもの。まず [[30-プラットフォーム/powerquery/基本/Power Query 基本方針|基本方針]] を読む。

> [!info] 状況(2026-10-29)
> 実機で取得確認済みは [[30-プラットフォーム/powerquery/基本/PQ 慶弔マスタ]] のみ。他は XML からの機械生成で未検証。確認できたらノートの注記を更新する。

## 基本

単体のリストを取得して列名を日本語にする。1リスト=1ノート。

### 方針

- [[30-プラットフォーム/powerquery/基本/Power Query 基本方針]] — `ApiVersion = 15` の 1.0 を使う理由、サイトURLは各クエリに直書き、Person/Lookup 列の扱い

### マスタ

- [[30-プラットフォーム/powerquery/基本/PQ 慶弔マスタ]] — `KeichoMaster`
- [[30-プラットフォーム/powerquery/基本/PQ メニューマスタ]] — `MenuMaster`
- [[30-プラットフォーム/powerquery/基本/PQ 営業日カレンダー]] — `BusinessCalendar`
- [[30-プラットフォーム/powerquery/基本/PQ 従業員マスタ]] — `EmployeeMaster`

### 申請リスト

- [[30-プラットフォーム/powerquery/基本/PQ 勤怠申請]] — `LeaveRequests`
- [[30-プラットフォーム/powerquery/基本/PQ 仮払金申請]] — `AdvancePayments`
- [[30-プラットフォーム/powerquery/基本/PQ 慶弔連絡]] — `KeichoReports`
- [[30-プラットフォーム/powerquery/基本/PQ 海外保険加入依頼]] — `OverseasInsurance`
- [[30-プラットフォーム/powerquery/基本/PQ 昼食申込]] — `LunchOrders`
- [[30-プラットフォーム/powerquery/基本/PQ 休日出勤・振休・代休申請]] — `HolidayWorkRequests`
- [[30-プラットフォーム/powerquery/基本/PQ 夜勤申請]] — `NightShiftRequests`

## 応用

マスタ参照(Lookup)列にマスタの中身を結合するなど、複数リストをつなげたクエリ。置き場は `応用/`。

- [[30-プラットフォーム/powerquery/応用/PQ応用 昼食申込+メニューマスタ]] — メニュー(ID)をメニュー名・価格に展開(未検証)

**候補**(まだ作っていない): 慶弔連絡→従業員マスタ(`EmployeeMasterRef`)、海外保険加入依頼→従業員マスタ(`TravelerEmployeeRef`)

## 対象外

督促対象設定・勤怠データ提出状況・`_pending/` の4リストは、`apply-order.json` で無効のため作っていない。
