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

親: [[01_engineering/00 MOC|common/01_engineering]]

クライアントを問わず使う一般的な設定。特定の案件に紐づく内容ではない。

> [!warning] 2026-09-15 訂正
> 当初「Ignored Build Step にカスタムのbashスクリプトを書く」と案内したが誤り（古い情報）。
> **今は Behavior のプリセットを選ぶだけで良い。** 下記に差し替え。

## 設定場所

**Settings → Build and Deployment → Ignored Build Step**

Behavior のドロップダウンから選ぶ（2026-09-15 時点の選択肢）：

| 選択肢 | 内容 |
|---|---|
| Automatic | Vercel の既定挙動（同じSHAへのコミットはスキップ、など） |
| **Only build production** | **Production Branch（既定 `main`）以外は一切ビルドしない。プレビューデプロイも作られない** |
| Only build pre-production | 逆に本番以外だけビルドする |
| Only build if there are changes | 変更差分が無ければスキップ |
| Only build if there are changes in a folder | monorepo 向け。特定フォルダに差分が無ければスキップ |
| Don't build anything | 常にスキップ（一時的にデプロイを完全に止めたいとき） |
| Run my Bash script / Run my Node script / Custom | 独自のスクリプトで判定したいとき（プリセットで足りないケース用） |

**「mainだけデプロイしたい」は `Only build production` を選ぶだけで完了する。** カスタムスクリプトは不要。

Production Branch 自体（既定でどのブランチを「本番」とみなすか）は、接続した Git リポジトリの
デフォルトブランチが自動的に使われる（GitHub 側で `main` になっていればそのまま `main`）。

## （参考）カスタムスクリプトが要る場合

プリセットで表現できない条件（例：特定のパスの変更＋特定のブランチ、複数条件のAND/OR）のときは
「Run my Bash script」を選び、以下のように `exit 1`（ビルドする）／`exit 0`（スキップする）で判定する。

```bash
if [ "$VERCEL_GIT_COMMIT_REF" = "main" ]; then
  exit 1
else
  exit 0
fi
```

`$VERCEL_GIT_COMMIT_REF` はビルド時に自動で渡されるブランチ名の環境変数。

## 出典・使った案件

2026-09-15、[[03_freelance/03-03_緑茶園/30-プラットフォーム/platform - 00 概要|platform（統合コンソール）]] の段階5（EC の切り替え・初回デプロイ）で使った設定。
