---
type: platform
client: green-earth
repo: /Users/choiseoncheol/git/choi_tone
role: 入力の窓口（フロントエンド／収集レイヤー）
created: 2026-09-16
updated: 2026-09-16
tags:
  - platform
---

# choi-tone

> 散らばったExcel入力を1画面に集約するデータ収集基盤。

⚠️ **このノートはまだ設計方針だけです。** リポジトリ調査の結果を反映してください。

## 位置づけ

人が入力して貯めることが目的。複数組織・複数スペースを横断して同じ仕組みを使い回せる。「入りやすさ」を優先した設計。

対になるのが [[green-earth-platform]]。

## スタック・構造

- `spaces`（テナント／組織単位）→ `members` → `apps` の3階層
- `APP_DEFINITIONS` に `table / titleField / fields` を定義するだけで CRUD＋CSV出力ができる汎用データ入力ジェネレーター
- 認証: Google OAuth（許可ドメイン制限）。追加のMFAなし
- バージョニング: コミット毎に自動PATCHインクリメント

## マスタの重複について

`store_master` / `employee_master` は [[green-earth-platform]] の `master/stores` / `master/staff` と概念的に重複するが、**意図的な棲み分け**。

- choi-tone 側: 現場からの一次入力・簡易記録用の軽量マスタ
- green-earth-platform 側: 業務判断の基準となる正式なマスタ

将来的な統合は前提にしていない。

## Green Earth 案件との関係

**店舗別受発注 ver2**（[[PRJ-06-直営店・FC店受発注の自社システム化によるインフォマートコスト削減|PRJ-06]]）が載っている。2026-10 の改善要望は [[PRJ-10-店舗別受発注v2とマスタの改善（2026-10要望）]]、レジデータの取り込みは [[PRJ-11-レジデータ（SJL）取込]] に計画がある。

（以前の記述）現時点で choi-tone に載っている Green Earth 案件はない。ドメイン設定のメモ（[[choi-toneドメイン設定]]）のみ存在するが、本文が未入力。

## 実装状況

（リポジトリ調査の結果をここに貼る）
