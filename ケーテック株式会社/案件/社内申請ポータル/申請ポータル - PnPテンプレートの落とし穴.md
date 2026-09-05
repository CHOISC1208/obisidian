---
tags:
  - ケーテック
  - 案件
  - 実装知見
client: ケーテック株式会社
親論点: テーマ1 - 電子化をどこまで広げるか
フェーズ: 開発中
created: 2026-09-05
updated: 2026-09-05
---

# 申請ポータル - PnPテンプレートの落とし穴

親: [[申請ポータル - 00 概要]] ／ [[00 MOC|ケーテック株式会社 MOC]]

出典: `CLAUDE.md` の「PnP Provisioning Schema の既知の落とし穴」。
**いずれも実際に `Invoke-PnPSiteTemplate` でエラーになった実績がある。**
新規XML作成・修正時は必ず確認すること。

> [!info] このノートの価値
> ここに書かれているのは一般論ではなく、**このプロジェクトで実際に踏んだ**もの。
> 他のSPO案件でも同じ地雷を踏むので、クライアントをまたいで再利用できる知見。

## 名前空間まわり

### 1. ルートにデフォルト名前空間を書いてはいけない

ルート `<pnp:Provisioning>` は `xmlns:pnp="..."` の**プレフィックス宣言のみ**にする。

```xml
<!-- ○ 正しい -->
<pnp:Provisioning xmlns:pnp="http://schemas.dev.office.com/PnP/2022/09/ProvisioningSchema">

<!-- ✕ これをやるとCAML生成エラー -->
<pnp:Provisioning xmlns="..." xmlns:pnp="...">
```

デフォルト名前空間を足すと `Field` 要素（サイト列/リスト固有列の生CAML定義。スキーマ上は
`xsd:any` で名前空間を問わない）にまで意図せず継承され、実行時に
`The ':' character ... cannot be included in a name` のようなCAML生成エラーになる。

### 2. `pnp:` を付ける要素と付けない要素がある

| `pnp:` を**付ける**（スキーマ上、名前空間修飾必須） | `pnp:` を**付けない**（生CAML） |
|---|---|
| `pnp:ListInstance` | `Field` |
| `pnp:ContentTypeBindings` / `pnp:ContentTypeBinding` | `CHOICES` |
| `pnp:Fields`（ListInstance直下のラッパー） | `CHOICE` |
| `pnp:SiteFields` | `Default` |
| `pnp:FieldRefs` / `pnp:FieldRef` | |
| `pnp:ContentType` | |

判断根拠: `PnP.Framework.dll` に埋め込まれた `ProvisioningSchema-2022-09.xsd` を実際に確認した。

## 属性まわり

### 3. 真偽値は小文字のみ

`Required` / `EnableVersioning` / `Overwrite` / `RichText` 等は **`true` / `false`**。
`TRUE` / `FALSE` は XSD boolean 違反でエラーになる。

### 4. `ContentType` の `FieldRef` には `ID`（GUID）が必須

`Name` だけでは不可。

### 5. `ListInstance` に `EnableContentTypes` 属性は存在しない

このスキーマでは無効な属性。`ContentTypeBindings` を指定すれば十分。

### 6. `AddToDefaultView="true"` を付けないと既定ビューに出ない

列は作成されるが表示されない（Titleしか出ない状態になる）。

ただし**コンテンツタイプ経由で入る共通列（`RequestDate` 等）はこの属性では対応できない**
（個々の `Field` 定義がその場に無いため）。

### 7. `ContentType` の `Overwrite` は既定 `false` のままにする

`true` にすると既存コンテンツタイプを削除して作り直そうとするため、
既にリストにバインド済みだと「**別のサイトまたはリストでまだ使用中**」エラーで失敗する。
再適用（PDCA）前提の運用では既定のままにする。

## ビューまわり

### 8. 既定ビューの制御は `pnp:Views` + `RemoveExistingViews="true"`

共通列も含めて表示列を制御するには `ListInstance` 直下に `pnp:Views` を明示する。

```xml
<View Url="AllItems.aspx" DisplayName="..." Type="HTML" Default="true">
```

- **`View` には `DisplayName` が必須**（無いと `Invalid View element` エラー）
- 既存の既定ビューの表示名は**環境のロケールで変わる**（日本語UIでは通常「すべてのアイテム」）ため、
  表示名を合わせてマージさせるのは脆い
- **`RemoveExistingViews="true"` で既存ビューを削除してから新規ビューだけにする**方が確実

## 列名まわり

### 9. 一般的すぎる内部名は組み込み列と衝突する

`Department` のような語は SharePoint 組み込みの隠しサイト列と衝突し、適用時に
`重複するフィールド名 "..." が見つかりました` エラーになる。

**新規列名は業務文脈をつけた名前にする**（実例: `ApplicantDepartment`）。
XMLを書いたら `grep` で日本語内部名が混入していないかも自己検証すること。

## 適用が「成功しても」正しいとは限らないもの

### 10. サイト列の `<Default>` は検証されない

SharePoint 側で検証されず、そのまま `DefaultValue` に保存される。
**値が有効かどうかはフォームを開いて確認するまで分からない。**

実例: **Person（User）列の既定値に `[Me]` は使えない**（2026-08-07 dev テナントで実機確認）。
適用は成功し `DefaultValue` に文字列 `[Me]` が入るだけで、新規フォームは空のまま。

### 11. 計算列（Calculated）が扱える型は限られる

数式が扱えるのは **1行テキスト・数値・日付・通貨・選択肢・はい/いいえ だけ**。
Person 列も、組み込みの `作成者` / `更新者` / `ID` / `登録日時` も参照できない。

→ 「作成者と申請者を IF で振り分ける」計算列は実現できず、フローで実列に書き込むしかない。

## 既存サイトへの再適用の限界（最も重い制約）

2026-08-07 に実地確認。

| やったこと | 起きたこと |
|---|---|
| 共通コンテンツタイプに列を追加 | サイト列とコンテンツタイプには反映されるが、**既にバインド済みのリストには伝播しない**（`Overwrite="false"` のため） |
| その状態で `pnp:Views` の `ViewFields` に新しい列を書いた | `列 '...' が存在しません。他のユーザーが削除した可能性があります。` で適用が失敗 |
| XML から列定義を削除 | **テナント側の列は消えない**（サイト列・コンテンツタイプの両方に残り、表示名が重複した状態になる） |

> [!important] 結論
> **共通列の追加・削除を伴う変更は、新しいサイトを作って先頭から適用し直すのが最も確実**
> （納品時と同じ経路の検証にもなる）。既存サイトで続ける場合は `Remove-PnPField` や
> リスト削除の手作業が必要になる。

## 検証手順（適用を依頼する前に必ず3段階）

| # | コマンド | 何が分かるか |
|---|---|---|
| ① | `xmllint --noout <file>` | 整形式かどうか |
| ② | `xmllint --schema <抽出したxsd> --noout <file>` | スキーマ準拠かどうか |
| ③ | `pwsh -Command "Read-PnPSiteTemplate -Path <file>"` | 未接続でもパース確認できる（**エラーストリームの警告を見逃さないこと**） |

②の XSD は `PnP.PowerShell` モジュールの `Core/PnP.Framework.dll` に埋め込みリソースとして入っており、
.NET の `Assembly.GetManifestResourceStream` で取り出せる。

> [!warning] ③でも拾いきれない実行時エラーがある
> 最終的には**実際の適用結果で確認する**しかない。特に上記10（`<Default>` の検証なし）は
> 3段階すべてを通過してしまう。
