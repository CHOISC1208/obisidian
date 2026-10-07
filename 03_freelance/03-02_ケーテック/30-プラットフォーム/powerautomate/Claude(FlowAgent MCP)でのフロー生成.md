---
tags:
  - ケーテック
  - プラットフォーム
  - PowerAutomate
  - FlowAgent
  - 運用
client: ケーテック株式会社
created: 2026-10-07
updated: 2026-10-07
---

# Claude(FlowAgent MCP)でのフロー生成

親: [[00 MOC|ケーテック株式会社 MOC]] ／ 設計図: [[30-プラットフォーム/powerautomate/Power Automate フロー設計図（簡易承認方式）]] ／ 列名: [[30-プラットフォーム/powerautomate/リスト別 列名対応表(Power Automate用)]]

> [!info] このノートの役割
> Power Automate のフローを **GUIで手作りする代わりに、Claude Code + FlowAgent MCP Server で生成する**ための
> 前提・運用ルール・環境の状態をまとめる。2026-10-07 に方針転換した(従来は「GUI作成のみ・AIは生成しない」)。
> 新しいセッションはまずこのノートとリポジトリの `CLAUDE.md` を読むこと。

## 1. 方針転換の経緯(2026-10-07)

- 参考にした記事: Qiita「Claude CodeでPower Automateフローを自然言語で構築する手法」(FlowAgent MCP Server、Microsoft製OSS)。
- 自然言語の指示から、クラウドフローの生成・公開・テスト実行・修正まで行える。標準コネクタのみ(プレミアム不要)。
- 簡易承認方式は全APP共通の3ステップ構造なので、生成・横展開と相性が良い。
- 決定: リポジトリ `CLAUDE.md` のフロー生成ルールを改訂済み(コミット `4a5fdc4` / `f282539`)。
  Copilot で GUI を組む前提のプロンプト集は不要になり削除した。

## 2. 運用ルール(`CLAUDE.md` と同内容。正は `CLAUDE.md`)

- 生成・公開は **dev(自前ミニテナント)、または先方テナント内の隔離したテスト環境のみ**。
- 先方テナントで生成する場合の必須条件:
  1. テスト用のサイト/リストを別に用意し、本番の申請リストには触れない
  2. `Approver` は自分のアカウントのみ
  3. フロー名に `[TEST]` を付け、確認が済むまで公開しない(オフのまま)
  4. 既存フローの変更・削除・上書きはしない(新規作成のみ)
- 生成したフローは **ソリューションzipとして `flows/solution/` に取り込み、リポジトリを正にする**。
- 採用前に人が Power Automate ポータルで宛先・分岐・エラー処理を確認する。
  確認項目: 宛先が `Approver` 列(2段なら `LeaderApprover` → `Approver`)/失敗時フォールバック(管理者アラート+`Status=要手動対応`)/プレミアムコネクタの混入なし。
- 本番反映は従来どおりソリューションzipのインポート。接続参照はインポート先で作り直す。

## 3. セットアップの状態(2026-10-07 時点)

| 項目 | 状態 |
|---|---|
| プラグイン | `power-automate@power-platform-skills`(marketplace: `microsoft/power-platform-skills`)。ユーザー単位でインストール済み |
| 前提ツール | Node.js 18以上、Azure CLI(Homebrew)。導入済み |
| 認証 | `az login --allow-no-subscriptions`。M365のみのテナントはサブスクリプションが無いため `--allow-no-subscriptions` が必要 |
| 環境 | 先方テナントの Default 環境の1つのみ。**セッションごとに既定環境が未設定**なので最初に `set_current_env` が要る |
| 既存フロー | 0本(2026-10-07 時点) |
| 接続 | SharePoint / 承認(Standard approvals)/ Office 365 / Office 365 Users / Teams。いずれも検証用アカウントで接続済み |

注意点(ハマりどころ):

- `claude plugin ...` や `/power-automate:setup` は **Claude Code の会話内ではなく、通常のターミナルのコマンド/スラッシュコマンド**として使い分ける。会話に素で打つとただのメッセージになる。
- Claude Code が Vercel AI Gateway 経由になっていると `403 BYOK` で動かない。`ANTHROPIC_BASE_URL` 等の環境変数を確認する。
- 認証は `az`(Azure CLI)と FlowAgent の接続管理(MSAL)で別セッション。アカウントを切り替えたいときは `list_accounts` / `switch_account` を使う。

## 4. 最初の対象

- サイト: `https://ktec19950401.sharepoint.com/sites/s-portal_ver11.0.2` の **年休申請**(リスト内部名 `LeaveRequests`、課題No.7)。
- 年休申請は **2段承認**(1次=リーダー・任意、2次=マネージャー・必須)。1次は固有列 `LeaderApprover`、2次は共通列 `Approver`。
- 設計案(トリガー: 項目の作成時):
  1. 起票設定: `Applicant`(本人申請=作成者、代理申請=`TargetEmployee`)、`Status=申請中`、権限を申請者の読み取り専用へ
  2. `LeaderApprover` が空でなければ「承認の開始と待機」(宛先=`LeaderApprover`、本文=`ApprovalMessage`)。却下ならここで終了
  3. 2次「承認の開始と待機」(宛先=`Approver`)
  4. 結果の書き戻し: `Status`(承認済/却下)・`ApprovedAt`・`ApproverComment`
  5. 失敗時: 管理者へ通知+`Status=要手動対応`(却下にしない)
- 承認カードの本文は共通列 `ApprovalMessage` をそのまま使う(フローで列を連結しない)。空のとき(リスト標準フォームからの登録)は簡易な文面にする。

## 5. 未決事項

- 管理者への通知先(Teamsチャネル or メール)。テスト中は自分宛メールで足りる想定。
- 1次承認が却下の場合は2次へ進めず却下で確定、で良いか。
- 対象リストが検証用で、実在の社員のデータが入っていないことの確認。
- FlowAgent が「承認の開始と待機」を含むフローを正しく生成できるか(**最初の検証項目**)。
- `ApplicantDepartment` の扱い(取得方式が未確定。設計図§6参照)。

## 6. 最初のタスク(新セッション向け)

小さく検証してから本番設計に進む。

1. `set_current_env` で既定環境を設定する(`list_environments` で名前を確認)。
2. `[TEST]` 付き・公開しない・新規作成のみで、**最小フロー**(項目作成トリガー → 承認の開始と待機 → `Status` 更新)を作る。
3. 生成結果を `get_flow` で読み、ポータルでも確認する。うまくいけば年休申請の2段承認フローに進む。
4. うまくいかない場合は、この方式自体を見直す(GUI作成へ戻す判断も可)。

## 7. 関連

- リポジトリ: `k-tec_spo_simple`(`CLAUDE.md`、`flows/README.md`、`flows/solution/`)。
  `flows/README.md` は中央承認エンジン・GUI作成前提のままで、フロー生成の結果が出てから書き直す(未着手)。
