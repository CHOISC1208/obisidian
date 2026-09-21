---
tags:
  - common
  - Vercel
  - Supabase
  - インフラ
  - パフォーマンス
created: 2026-09-15
updated: 2026-09-15
---

# Vercel：FunctionsのリージョンをDBに合わせる

親: [[01_engineering/00 MOC|common/01_engineering]]

クライアントを問わず使う一般的な設定。特定の案件に紐づく内容ではない。

## 症状

- 画面遷移・ページ読み込みが毎回 1〜3秒ほど遅い（体感でストレスになるレベル）
- 特定の操作だけでなく、**どの画面に行っても一律に遅い**
- DBが海外リージョン（Supabaseなら `ap-northeast-1` = 東京など）にある

## 原因：Vercel Functionsは既定で米国リージョン

**Vercel Functionsは、新規プロジェクトでは既定で `iad1`（米国ワシントンD.C.）で実行される。**
`vercel.json` でリージョンを指定していなければ、DBが東京にあっても関数は米国で動く。

サーバーコンポーネント・Server Action が1回のページ表示で複数回DBに問い合わせる設計
（例：権限確認 → 画面データ取得、を別クエリで行う）だと、**米国⇔東京の往復遅延（片道150〜200ms程度）が
クエリの回数だけ積み重なり**、1〜3秒の体感遅延になる。

## 直し方

`vercel.json` にDBと同じリージョンを指定する。

```json
{
  "$schema": "https://openapi.vercel.sh/vercel.json",
  "regions": ["hnd1"]
}
```

### リージョンコード対応表（よく使うもの）

| コード | 場所 | 対応する主要クラウドのリージョン名 |
|---|---|---|
| `hnd1` | 東京 | `ap-northeast-1`（Supabase・AWSの東京） |
| `kix1` | 大阪 | `ap-northeast-3` |
| `icn1` | ソウル | `ap-northeast-2` |
| `sin1` | シンガポール | `ap-southeast-1` |
| `iad1` | 米国ワシントンD.C.（**Vercelの既定**） | `us-east-1` |

全リージョン一覧は [Vercel Regions](https://vercel.com/docs/regions#region-list) を参照。

### 確認・反映の手順

1. DB（Supabase・Neon等）のリージョンを確認する（ダッシュボードのプロジェクト情報に出ている）
2. そのリージョンに対応する Vercel リージョンコードを調べる（上の表 or 公式一覧）
3. `vercel.json` に `regions` を追加してコミット・push
4. push で自動的に再デプロイされ、次のデプロイからそのリージョンで実行される

> [!info] プラン制限
> Hobbyプランは1リージョンのみ指定可能（今回のケースはこれで十分）。
> Proは最大5リージョン、Enterpriseは全リージョン指定可能（マルチリージョンにすると `functions` の
> per-function 設定でデータソースごとにリージョンを分けることもできる）。

## 出典・使った案件

2026-09-15、[[03_freelance/03-03_緑茶園/30-プラットフォーム/ryokuchaen-platform/platform - 00 概要|platform（統合コンソール）]] の段階5デプロイ後、
画面遷移が毎回1〜3秒遅いという報告から発覚。`vercel.json` が存在せず既定の `iad1` で動いていたことが原因と判明し、
`hnd1`（Supabaseと同じ東京）に固定して修正した。
