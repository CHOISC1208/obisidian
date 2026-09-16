---
type: paper
event: ORSJ2026秋
session: スケジューリング(1)
id: 1-B-9
title: Metaheuristics for Personalized Theme Park Orienteering with Time-Dependent Waiting Times
authors: [森山里咲, 胡艶楠, 橋本英樹]
organizations: [東京理科大学, 東京海洋大学]
affiliation_type: 大学
domain: [観光]
problem: []
method: [メタヒューリスティクス（ILS, GA）, 構築型ヒューリスティクス]
solver: []
maturity: 数値実験
pages: 60-61
tags: [ORSJ2026秋]
source_type: abstract
---

# Metaheuristics for Personalized Theme Park Orienteering with Time-Dependent Waiting Times

> [!abstract] 一言で
> 個人化された選好・待ち時間感度と、時間依存の待ち時間・移動満足度（区分線形関数）を考慮したテーマパーク周遊問題（PTPO-TDW）に対し、貪欲構築法・反復局所探索（ILS）・遺伝的アルゴリズム（GA）を組み合わせた解法を提案し、東京ディズニーシーのデータで検証した。

## 問題設定
- 施設集合F（開始・終了ダミーを含む）、各施設の人気度・滞在時間・時間依存待ち時間、施設間の移動時間・時間依存移動満足度（いずれも区分線形関数）が与えられる。訪問者が選択した施設集合Sと待ち時間感度αに基づく満足度関数を用い、営業時間[OT,CT]内で各施設を高々1回訪問するルートのうち、経験と移動からの総満足度を最大化するものを求める。

## 手法
- 貪欲構築アルゴリズムで初期解を生成し、ILSの初期解に用いる。
- ILSはペナルティ関数（時間制約の一時的違反を許容）と3つの近傍操作（one-insert, one-delete, one-delete-one-insert）、局所最適からのキック操作を用いる。
- GAはILSで得た高品質な訪問順列を活用し、時間を意識した交叉（Parent1：DPで待ち時間最小化した選択施設の順列、Parent2：ILS探索中に得たサブ施設列）でオフスプリングを生成。ILSを1800秒実行後にGAを起動し、5回連続で改善しないILS反復後にGAを再起動するハイブリッド枠組み。

## 結果
- 東京ディズニーシー（9:00-21:00、計算時間上限3600秒、C言語実装、Apple M1・16GB RAM）でα=0.05,0.2,0.5、選択施設数0〜9の5ケースを評価。
- ILSはα=0.5のCase2を除く全ケースでGreedyを上回り、GAは全テストケースでILSと同等以上の性能を示した。

## 参照価値
- 個人の選好と時間依存の待ち時間・移動満足度を同時に扱う周遊型ルーティング問題（テーマパーク以外の観光・イベント周遊も含む）の解法設計時に参照価値がある。

## [要確認]
- 特になし

## 関連
- [[ORSJ2026秋_カタログ]]
- 同一研究の可能性が高い（著者一致）：[[SS2026_GS2-1_テーマパークOrienteering]]
