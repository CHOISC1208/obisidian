# リスト別 列名対応表(Power Automate用)

Power Automate で各APPのフローを組むときに、列の**内部名**と**表示名**を引くための表。
出典は `k-tec_spo_simple` の `template/00_common` と `template/20_requests` のXML(2026-10-06 時点)。テナントの実物は未確認。

## 1. 全リスト共通の列(コンテンツタイプ「申請共通」)

5リストとも内部名・表示名が同じ。フローの式は全APPで使い回せる。

| 内部名 | 表示名 | 型 | 入力者 | フローでの参照 |
|---|---|---|---|---|
| `Title` | 件名 | 1行テキスト | 申請者 | `Title` |
| `Applicant` | 申請者 | Person | フロー | `Applicant Email` |
| `RequestDate` | 申請日 | 日付 | 申請者 | `RequestDate` |
| `ApplicantDepartment` | 所属部署 | 選択肢 | フロー | `ApplicantDepartment Value` |
| `Status` | ステータス | 選択肢 | フロー | `Status Value` |
| `Approver` | 承認者(2次・マネージャー、必須) | Person | 申請者 | `Approver Email` |
| `ApprovedAt` | 承認日時 | 日時 | フロー | `ApprovedAt` |
| `ApproverComment` | 承認者コメント | 複数行 | フロー | `ApproverComment` |

- `Status` の選択肢: 申請中 / 承認済 / 却下 / 要手動対応 / 精算済 / 取消(全リスト共通。APP専用の値も全リストに入っている)
- `ApplicantDepartment` の選択肢: 経営SPG / 購買G / 営業 / 設計 / 製造 / その他(仮置き)
- `Approver` は提出後に変えられないよう、編集フォームから隠している。

## 2. 1次承認者 `LeaderApprover`

| リスト | `LeaderApprover` |
|---|---|
| 年休申請 | あり |
| 仮払金申請 | あり |
| 慶弔連絡 | あり |
| 海外保険加入依頼 | あり |
| 昼食申込 | **なし**(承認不要) |

- 表示名は「1次承認者(リーダー)」、型は Person、任意。
- 空欄ならリーダー承認を飛ばして `Approver` へ直接進む。
- 2段承認の順序は 1次 `LeaderApprover` → 2次 `Approver`。

## 3. リスト別の固有列

### 年休申請(07)

| 内部名 | 表示名 | 型 |
|---|---|---|
| `InitiatorType` | 起票区分 | 選択肢 |
| `TargetEmployee` | 対象者(代理申請) | Person |
| `LeaveType` | 休暇区分 | 選択肢 |
| `StartDate` | 取得日(開始) | 日付 |
| `EndDate` | 取得日(終了) | 日付 |
| `LeaveDays` | 取得日数 | 数値 |
| `Reason` | 事由 | 選択肢 |
| `SpecialLeaveDetail` | 内容 | 選択肢 |
| `StartTime` | 時刻(開始) | 1行テキスト |
| `EndTime` | 時刻(終了) | 1行テキスト |

### 仮払金申請(01)

| 内部名 | 表示名 | 型 |
|---|---|---|
| `ExpenseCategory` | 区分 | 選択肢 |
| `Amount` | 仮払金額 | 通貨 |
| `Purpose` | 用途・目的 | 複数行 |
| `PaymentDueDate` | 支払希望日 | 日付 |
| `SettlementDueDate` | 精算予定日 | 日付 |

### 慶弔連絡(02)

| 内部名 | 表示名 | 型 |
|---|---|---|
| `EmployeeMasterRef` | 対象者(従業員台帳から検索) | Lookup |
| `InitiatorType` | 起票区分 | 選択肢 |
| `TargetEmployee` | 対象者(代理申請) | Person |
| `RequestType` | 制度種別 | 選択肢 |
| `TargetPerson` | 対象者 | 選択肢 |
| `EmploymentType` | 雇用形態 | 選択肢 |
| `YearsOfService` | 勤続年数 | 数値 |
| `IsSecondMarriage` | 入社後2回目以降の結婚 | はい/いいえ |
| `SpouseName` | 配偶者氏名 | 1行テキスト |
| `HasCeremony` | 挙式あり | はい/いいえ |
| `CeremonyDate` | 挙式日 | 日付 |
| `VenueName` | 結婚式場名 | 1行テキスト |
| `ChildName` | 子女氏名/お子様のお名前 | 1行テキスト |
| `ChildNameKana` | 子女氏名(フリガナ) | 1行テキスト |
| `ChildRelationship` | お子様の続柄 | 選択肢 |
| `DeceasedName` | 死亡者氏名 | 1行テキスト |
| `IsWorkRelated` | 対象(業務上の傷病) | はい/いいえ |
| `Diagnosis` | 病名 | 1行テキスト |
| `Symptoms` | 症状 | 複数行 |
| `ReturnToWorkDate` | 出社予定日 | 日付 |
| `EventDate` | 事実発生日 | 日付 |
| `Remarks` | 備考 | 複数行 |
| `PlannedAmount` | 支給予定額 | 通貨 |

### 海外保険加入依頼(03)

| 内部名 | 表示名 | 型 |
|---|---|---|
| `TravelerName` | 渡航者 | Person |
| `TravelerLastNameRoman` | 氏名(姓)※半角ローマ字 | 1行テキスト |
| `TravelerFirstNameRoman` | 氏名(名)※半角ローマ字 | 1行テキスト |
| `TravelerEmail` | メールアドレス | 1行テキスト |
| `TravelerBirthDate` | 生年月日 | 日付 |
| `TravelerGender` | 性別 | 選択肢 |
| `Destination` | 渡航先 | 選択肢 |
| `TravelPurpose` | 渡航目的 | 選択肢 |
| `DepartureDate` | 出発日 | 日付 |
| `ReturnDate` | 帰宅日 | 日付 |
| `Companions` | 同行者 | 複数行 |
| `IsRetroactive` | 事後申請(緊急時の後追い) | はい/いいえ |

### 昼食申込(06)

| 内部名 | 表示名 | 型 |
|---|---|---|
| `SubmissionMode` | 申込方法 | 選択肢 |
| `OrderDate` | 喫食日 | 日付 |
| `PeriodStartDate` | 対象期間(開始) | 日付 |
| `PeriodEndDate` | 対象期間(終了) | 日付 |
| `OrderType` | 区分 | 選択肢 |
| `MenuItem` | メニュー | Lookup |
| `Quantity` | 数量 | 数値 |
| `CostDepartment` | 費用負担部署 | 選択肢 |
| `Amount` | 金額 | 通貨 |

## 4. 同名でも意味が違う列(注意)

| 内部名 | 使われるリスト | 備考 |
|---|---|---|
| `Amount` | 仮払金(仮払金額・通貨) / 昼食(金額・通貨) | 表示名がリストで違う |
| `InitiatorType` / `TargetEmployee` | 年休・慶弔 | 起票区分=代理申請のときだけ対象者を使う |
| `TargetPerson` | 慶弔 | 「対象者(選択肢)」。`TargetEmployee`(Person)とは別物 |

## 5. 既存環境での落とし穴

- XMLから列定義を消しても、テナント側のサイト列・コンテンツタイプには残る。
- 海外保険の `FinalApprover`(旧・社長用)が過去環境に残っている可能性がある。Power Automate の列選択で似た名前が出たら、上の表の内部名か確認する。
- Person 列は `Email` / `DisplayName` などのサブ項目を選んで使う。「承認の開始と待機」の宛先には `Approver Email` を渡す。

## 関連

- [[Power Automate フロー設計図（簡易承認方式）]]
