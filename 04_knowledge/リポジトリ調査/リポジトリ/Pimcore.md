---
title: Pimcore
tags:
  - type/リポジトリ
  - topic/OSS調査
repo: pimcore/pimcore
url: https://github.com/pimcore/pimcore
stars: 3.9k
language: PHP
last_pushed: 2026-09-29
license: POCL（Pimcore Open Core License）
status: README読了（コード未読）
created: 2026-09-30
updated: 2026-09-30
info_freshness: 2026-09-30 時点。★・更新日は GitHub、概要は README、ディレクトリは GitHub API で確認
---

# Pimcore

親: [[リポジトリ調査 MOC]] ／ 分類: [[リポジトリ調査 - マスタ・在庫・PSI]]

[pimcore/pimcore](https://github.com/pimcore/pimcore) ／ ★3.9k ／ PHP ／ 最終更新 2026-09-29 ／ **POCL（Pimcore Open Core License）**

商品体験管理（PXM）のオープンコア・プラットフォーム。PIM、MDM、DAM、CDP、DXP／CMS、デジタルコマースを、共通のコアフレームワークと拡張で提供する。

## READMEの要点

- データを **Data Objects**（クラスエディタで定義した構造化データ）、アセット、ドキュメントの3要素で扱う
- チャネルに依存せずデータを保持し、REST／GraphQL で任意の出力先へ配信
- データモデルを自分で定義でき、テンプレートも API 利用も選べる
- 管理画面は Pimcore Studio

## 効く課題

**マスタデータ管理（MDM）の思想**：商品も顧客も注文も同じ枠組みのデータオブジェクトとして定義する。マスタを増やすか（[[テーマ4 - マスタを増やすか]]）を考える材料。

## 読む場所

- `models/`
- `bundles/`
- `doc/`

## 注意

- ライセンスは独自の **POCL**（オープンコア）。利用条件を確認してから使う
- 多機能で重く、優先度は [[UnoPIM]] より低い

## 次に読むもの

必要になったときに `doc/` から入る

## 読書メモ

（コードを読んだら書く）
