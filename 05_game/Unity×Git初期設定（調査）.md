---
tags:
  - game
  - research
  - unity
  - git
created: 2026-11-27
updated: 2026-11-27
---

# Unity×Git初期設定（調査）

親: [[05_game/00 MOC|05_game]]

企画の話は [[企画と設計のポイント（調査）]]。ここは技術の初期設定だけ。

## 設定

> 出典：Edit > Project Settings > Editor で Version Control を **Visible Meta Files**、Asset Serialization を **Force Text** にする。Unity 6000.0 のドキュメントでは、どちらも既定値（レビュー指摘。公式ドキュメント未確認）。

> 出典：`.gitignore` は `Library` `Temp` `Obj` `Build` などの生成物を除外する。**`.meta` は除外しない。**

> 出典：Git LFS は**フォルダ単位ではなく拡張子単位**で指定する。フォルダ指定だとテキストの `.meta` までLFS対象になる。`.asset` は Terrain など別物が混ざるので注意。

> 解釈：既定値でも、プロジェクトを作ったら設定画面で一度確認する。

## 選択肢

- Git は唯一の選択肢ではない。Unity は独自のバージョン管理 UVCS（旧 Plastic SCM）も用意している。このVaultは Git＋GitHub で統一する前提。
- **Git LFS は課金対象。** GitHub は無料枠を超えるとストレージ課金になる。枠の数字は変わるので、公式で確認する。
- 解釈：1本目は、画像・音声を最初から全部 LFS に入れない。容量を測ってから拡張子を指定すれば足りる。
- 任意：UnityYAMLMerge でシーン・プレハブの衝突を解消できる。ソロ開発では優先度が低い。

## 出典

- [How to Git with Unity（thoughtbot）](https://thoughtbot.com/blog/how-to-git-with-unity)
- [Unity Git Config（NYU Game Center）](https://github.com/NYUGameCenter/Unity-Git-Config)
- [Version Control for Unity Projects（uhiyama-lab）](https://uhiyama-lab.com/en/notes/unity/unity-version-control-git-lfs-team-workflow/)
