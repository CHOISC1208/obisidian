---
id: FOOD-003
kind: 食材
status: 完了
source: AI
filename: Assets/Art/Resources/Food/tofu_face.png
license: Meshy AI（生成時のプラン：〔要確認〕。無料ならCC BY 4.0でクレジット表記が要る。公開前に有料プランで作り直す）
drive: 
tags:
  - asset
---

# FOOD-003 豆腐（ふつうの顔）

親: [[料理大砲 - 素材リスト]]

塔のブロック。笑顔。大きさはゲーム内で0.9×0.56。顔なしの絵（`tofu.png`）も書き出してある。

## 生成

- ツール：Meshy AI（Text to Image → Image to 3D）。元データ（FBX）は `Assets/Models/` にあり、Git管理外
- 書き出し：`ModelBaker`（[[料理大砲 - 技術構成]] の「素材の流れ」）。`-view pz -ortho 1.3 -ppu 831`（顔なしは `-view py`）

### プロンプト

```text
A cute toy-like block of tofu, a rectangular cuboid with soft rounded corners, proportions width 3 height 2 depth 2, cartoon style, smooth matte pale ivory white surface, subtle soft shading, simple clean shape, single object, centered, game asset, kid-friendly
（生成された豆腐には、プロンプトにない顔が付いた）
```
