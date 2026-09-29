---
title: amazon-sp-api（jrl84）
tags:
  - type/リポジトリ
  - topic/OSS調査
repo: jrl84/amazon-sp-api
url: https://github.com/jrl84/amazon-sp-api
stars: 265
language: JavaScript
last_pushed: 2026-03-30
license: MIT
status: README読了（コード未読）
created: 2026-09-30
updated: 2026-09-30
info_freshness: 2026-09-30 時点。★・更新日は GitHub、概要は README、ディレクトリは GitHub API で確認
---

# amazon-sp-api（jrl84）

親: [[リポジトリ調査 MOC]] ／ 分類: [[リポジトリ調査 - EC受注管理（OMS）]]

[jrl84/amazon-sp-api](https://github.com/jrl84/amazon-sp-api) ／ ★265 ／ JavaScript ／ 最終更新 2026-03-30 ／ **MIT**

Amazon SP-API の JavaScript／Node.js クライアント。アクセストークン取得と API 呼び出しを簡素化する。

## READMEの要点

- 認証情報は環境変数・ファイル（`~/.amzspapi/credentials`）・コンストラクタのいずれかで渡す
- リージョン指定（eu／na／fe）とリフレッシュトークンでクライアントを作る
- エンドポイントのバージョン指定とフォールバック、レート制限（restore rate）、タイムアウト、サンドボックスモード
- レポートのダウンロード（ストリーム対応）とフィードのアップロード
- TypeScript 対応

## 効く課題

緑茶園の Node／TypeScript スタックで SP-API を呼ぶときの候補。**日本は `fe` リージョン**（要確認）。

## 読む場所

- `lib/`（クライアント本体）
- `README.md` の Call the API／Restore rates／Sandbox mode の節
- `test/`

## 注意

- 最終更新が 2026-03 で、Python 版より古い。採用前に直近の Issue と対応状況を確認する
- README が長大（約58KB）。必要な節だけ読む

## 次に読むもの

Orders API のバージョン指定（v0 など）と PII 取得の扱いを確認する

## 読書メモ

（コードを読んだら書く）
