---
type: platform
role: 案件・タスク管理（社内ツール）
url: https://req-navi.vercel.app
tags: [platform]
---

# reqnavi

> 案件・マイルストーン・カード（看板タスク）・議事録・要件定義を管理する自作ツール。

## Obsidian との役割分担

**reqnavi がタスク管理の正。** この Vault には、タスクの現況（マイルストーン・カードのステータス）を転記しない。同期されないため必ず古くなるため。

| | reqnavi | この Vault |
|---|---|---|
| 持つもの | 動くもの（タスク・進捗・期限） | 動かないもの（議事録・判断の理由・調査結果・課題の構造） |
| 更新頻度 | 日次 | 打ち合わせのたび、判断のたび |

## スキーマ（把握できている範囲）

`companies` / `projects` → `milestones` → `cards` / `card_notes` / `company_documents`（議事録・メモ）/ `requirements` / `hearings` / `company_folders` / `company_files`

- スキーマ名: `req_navi`
- 株式会社Green Earth の company_id: `a55a1dc6-0550-4b1e-ae9d-583c137e77b0`
- `projects.status` は4値: `in_progress` / `on_hold` / `completed` / `archived`

## 既知の制約

- **案件と議事録を紐づけるデータがない。** `company_documents` は会社単位で紐づくのみで `project_id` 相当の列がない。この Vault のリンクはすべて本文内容からの推測
- **議事録に出席者フィールドがない**
- 「未着手」に対応するステータス値がない。新規案件も既定値が `in_progress` になるため、実態として未着手の案件も進行中に含まれる
- Green Earth 所属ユーザー4名全員の `display_name` が未設定

## 他社データ

緑茶園（案件2件）、ケーテック（議事録1件）も入っている。この Vault は Green Earth 専用のため対象外。
