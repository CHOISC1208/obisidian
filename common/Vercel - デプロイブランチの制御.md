---
tags:
  - common
  - Vercel
  - インフラ
  - デプロイ
created: 2026-09-15
updated: 2026-09-15
---

# Vercel：デプロイするブランチを絞る

親: [[common/00 MOC|common]]

クライアントを問わず使う一般的な設定。特定の案件に紐づく内容ではない。

## 2つの設定は役割が違う

| 設定 | 場所 | 効果 |
|---|---|---|
| Production Branch | Project Settings → Git → Production Branch | そのブランチへの push だけが**本番ドメイン**に反映される（既定は `main`）。他のブランチは本番に影響しないプレビューURLのまま |
| Ignored Build Step | Project Settings → Git → Ignored Build Step | 条件を満たさないブランチは**ビルドそのものをスキップ**する。プレビューURLも作られなくなる |

**「本番ドメインさえ守れればよい」なら Production Branch の設定だけで足りる。**
**「作業ブランチのビルドも走らせたくない（ビルド時間・コストの節約）」なら Ignored Build Step も設定する。**

## Ignored Build Step の設定例

`main` へのpushだけをビルドし、他のブランチは全てスキップする。

```bash
if [ "$VERCEL_GIT_COMMIT_REF" = "main" ]; then
  exit 1
else
  echo "main 以外なのでビルドをスキップします"
  exit 0
fi
```

- `exit 1` → ビルドを実行する（"ignored" ではない）
- `exit 0` → ビルドをスキップする（"ignored"）

`$VERCEL_GIT_COMMIT_REF` は Vercel がビルド時に自動で渡すブランチ名の環境変数。他の変数と組み合わせて
「特定のディレクトリに差分が無ければスキップ」（monorepo）のような条件にも応用できる。

## 出典・使った案件

2026-09-15、[[緑茶園グループ/案件/platform/platform - 00 概要|platform（統合コンソール）]] の段階5（EC の切り替え・初回デプロイ）で使った設定。
