---
title: pgrls
tags:
  - type/リポジトリ
  - topic/OSS調査
repo: pgrls/pgrls
url: https://github.com/pgrls/pgrls
stars: 27
language: Python
last_pushed: 2026-09-26
license: MIT
status: README読了（コード未読）
created: 2026-09-30
updated: 2026-09-30
info_freshness: 2026-09-30 時点。★・更新日は GitHub、概要は README、ディレクトリは GitHub API で確認
---

# pgrls

親: [[リポジトリ調査 MOC]] ／ 分類: [[リポジトリ調査 - Next.js×Supabaseの権限とRLS]]

[pgrls/pgrls](https://github.com/pgrls/pgrls) ／ ★27 ／ Python ／ 最終更新 2026-09-26 ／ **MIT**

Postgres の Row-Level Security を**静的解析**する CLI。テナント間・同一テナントのユーザー間の行スコープ漏れ、認可チェックの反転、書き込み側の穴を検出する。

## READMEの要点

- `pgrls lint`：68ルールで検査（うち19本は自動修正可）。出力は text／JSON／SARIF／Markdown／HTML／GitHub PR コメントなど
- `pgrls generate`：RLS 未設定のテーブルに、`tenant_id` 単位または `auth.uid()` 単位の**RLS の雛形を生成**
- `pgrls snapshot`／`diff`：マイグレーション前後のポリシー差分を SAFE／BREAKING／REQUIRES_REVIEW／DANGEROUS に分類
- `pgrls verify`（テナント分離の証明）、`matrix`（誰が何にアクセスできるか）、`report`
- `--supabase` オプションで `./supabase/migrations` を検査。DB 不要の `--sql-file` も可（Docker があればエフェメラル DB で実行）
- pytest プラグイン（RLS の分離テスト）と、TypeScript 版 `pgrls-test`
- PostgreSQL 15〜17 で CI テスト。ベータ版

## 効く課題

緑茶園の `public`（EC）／`inventory`（仕入）スキーマの RLS 点検。**権限モデルを作る前の現状把握**と、作った後の**回帰防止（CI）**。

## 読む場所

- `docs/QUICKSTART.md`
- `docs/RULES.md`（ルール一覧。RLS の落とし穴集として読む）
- README の「Real-world bugs pgrls catches」の節
- `examples/`

## 注意

- ベータ版・★27 と小規模。**検出結果は鵜呑みにせず、指摘を人が確認する**
- Python 3.11+ が必要
- `inventory` スキーマは PostgREST から見えない構成なので、RLS の要否自体を先に整理する必要がある

## 次に読むもの

[[platform - 00 概要]] のマイグレーション（`supabase/migrations` 相当）に `pgrls lint` を当ててみる

## 読書メモ

（コードを読んだら書く）
