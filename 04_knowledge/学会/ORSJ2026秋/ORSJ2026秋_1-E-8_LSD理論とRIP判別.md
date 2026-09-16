---
type: paper
event: ORSJ2026秋
session: 機械学習(2)
id: 1-E-8
title: "間違った判別理論に代る世界初のLSD(Linier Separable Data）理論 -RIPによるLSDは、量子計算機とIPソフトの検証に最適-"
authors: [新村秀一]
organizations: [成蹊大学]
affiliation_type: 大学
domain: [医療]
problem: []
method: [MILP, 分枝限定]
solver: [LINGO]
maturity: 理論
pages: 114-115
tags: [ORSJ2026秋]
source_type: abstract
---

# 間違った判別理論に代る世界初のLSD理論

> [!abstract] 一言で
> 線形判別関数（LDF）による誤分類数最小化を組合せ最適化問題として定式化した整数計画RIP（LINGOのB&Bで求解）により、最小誤分類数（MNM）が0となる線形分離可能データ（LSD: Linearly Separable Data）を特定する理論を提案し、Iris、スイス紙幣、試験合否判定、癌の遺伝子診断等の実例に適用した。

## 問題設定
- Fisherが開発した線形判別関数（LDF）は2群が異なる平均を持つ正規分布という仮説に基づくが、著者はMNM（Minimum Number of Misclassification、最小誤分類数）=0となるLSD（線形分離可能データ）を統計的に正しく発見する唯一の統計量と位置づける。
- 分散共分散行列を使った通来のLDFやSVM等はMNMが1より大きくなりLSDを発見できず、同じデータでも手法によって異なるMNMが得られ信頼性に欠けるという「判別理論の問題1」を指摘する。

## 手法
- RIP（整数計画による線形判別関数）をIPとして定式化し、LINGOのB&B法でMNM=MIN(Σe_i); y_i*(t_xb+1)≥1-1000*e_i の制約下で解く。誤分類数kが1以上ならデータ固有の誤分類を特定し、k個を除けば全データがLSDになる。
- H-SVM（誤分類があると計算できず終了する）やS-SVM（誤分類を許容するQPで2目的最適化）と比較し、RIPのみが2^n通りの組み合わせでデータ固有のkを一意に決定できるとする。
- LINGOでRIP・H-SVM・S-SVM・LP-OLDFを実行する4つのProgramを構築：Program1（RIPでMNM=kを特定）、Program3（LSDをSmall Matryoshka: SMへ連続的に分割）、Program4（各SMからBasic Gene Set: BGSを特定）、Program2（k重クロスバリデーションでモデルを評価しM2最小のモデルをBestモデルとする）。

## 結果
- Fisherの3種のIrisデータで(x1,x2), x3, x4の3組のBasic Gene SetがMNM=0のLSDになることを示した。
- 自然分娩180例・帝王切開60例のCPD診断データでは、SASのRSQUAREプロシジャによる19変数の分散共分散行列分析（343のR2値、37モデル）に対し、RIPは14変数の多重共線性のないBGS1を求め、MNM=2（2人の妊婦を除けば238例がLSD）を発見。10重CVでMNM=0かつM2=2.44のBGS1を選択した。
- スイス紙幣真贋データ（各100枚6変数）ではRIPのみが下枠内長（X4）・対角長（X6）の2変数のBGSを特定し、63モデル中47がLSDでないことをMNMの単調減少性から示した。
- 169のMicroarray癌遺伝子診断データ（300例程度、3万個以上の遺伝子）は全てLSDであり、Program1〜4で検証標本M2=0のBGSが多くの場合5個以下の遺伝子から成ることを確認した。

## 難しさ・工夫
- LDF=0の判定が容易でないためLDF≥1に変更する等、組み合わせ最適化としての実装上の工夫が述べられている。

## 参照価値
- 判別分析・機械学習で「完全に分離可能なデータかどうか」を厳密に特定したい場面（試験合否判定、医療診断、遺伝子診断等）で、整数計画による誤分類数の厳密な最小化アプローチとして参照できる。

## [要確認]
- 論文中の記述は著者独自の理論体系・用語（LSD, RIP, BGS, SM等）に基づき、一般的なOR用語との対応関係の一部（特に統計的検証手続きの詳細）は本文の記述のみでは完全には追いきれない。

## 関連
- [[ORSJ2026秋_カタログ]]
