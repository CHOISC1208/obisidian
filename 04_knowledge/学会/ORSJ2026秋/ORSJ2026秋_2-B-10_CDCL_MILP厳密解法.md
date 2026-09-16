---
type: paper
event: ORSJ2026秋
session: 離散最適化(4)
id: 2-B-10
title: CDCLを用いたMILPの厳密解法
authors: [今井義弥]
organizations: [フリーランス]
affiliation_type: 企業
domain: []
problem: []
method: [MILP, CDCL]
solver: []
maturity: 数値実験
pages: 216-217
tags: [ORSJ2026秋]
source_type: abstract
---

# CDCLを用いたMILPの厳密解法

> [!abstract] 一言で
> 分枝限定法における「不適切な分枝変数選択を取り消せない」という問題を解消するため、Conflict-Driven Constraint Learning（CDCL）と連続緩和（単体法）を組み合わせたMILP厳密解法を提案し、一部インスタンスで既存の分枝限定法ソルバーを超える性能を確認した。

## 問題設定
- 整数変数を0-1変数に限定した問題P（min c_I^T x+c_R^T y s.t. A_I x≥b_I, A_M x+A_R y≥b_M, x∈{0,1}^m, y∈R^n）を対象とする。整数変数の上下限制約集合Sを「仮定」と呼び、分枝限定法の子問題に相当するが、本手法では仮定はただ一つである点が異なる。

## 手法
- 0-1変数と1つの連続変数zを扱えるように拡張したPB（Pseudo-Boolean）ソルバーで仮定Sを満たす実行可能解の有無を判定し（MayBeFeasible/Infeasible/PartiallyMayBeFeasibleの3分類）、存在し得ない場合はSから要素を削除。
- 単体法ソルバーで仮定Sを満たす緩和問題P̃(T)を解き、Bender's Cutを生成（Optimal/Infeasibleの2分類）。
- Bender's Cutを追加してもSを縮小できない場合はSに新たな上下限制約を追加する、という3操作（Algorithm 1）を仮定Sを修正しながら反復する。分枝操作を原則取り消せない分枝限定法と異なり、PBソルバーによる判定でSから要素を削除できる点が特徴。

## 結果
- 提案手法を実装し、一部のインスタンスで既存の分枝限定法ソルバーを超える性能が得られたことを確認した。数値実験結果の詳細は当日口頭発表で報告予定。

## 参照価値
- 分枝限定法の分枝変数選択が不適切だった場合に手戻りできないという構造的な弱点に対し、SATソルバー分野のCDCL・Bender's Cutを組み合わせた別解法の設計例として参照価値がある。

## [要確認]
- 数値実験の詳細（対象インスタンス、既存ソルバーとの具体的な性能差）は当日口頭発表で報告予定であり、本稿には記載なし。著者所属は「フリーランス」と記載されており、org_type（企業/大学等の分類）は暫定的な判断である。

## 関連
- [[ORSJ2026秋_カタログ]]
