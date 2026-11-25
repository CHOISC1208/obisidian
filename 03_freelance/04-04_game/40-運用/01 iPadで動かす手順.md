---
tags:
  - game
  - unity
  - ios
  - 手順
created: 2026-11-25
updated: 2026-11-25
---

# iPad（iPhone）で動かす手順

親: [[00 MOC|game MOC]]

> [!success] 2026-11-25 に iPad Air（第4世代、iPadOS 27.2.1）で起動を確認

## 一度だけやる準備

1. **Xcode** を Mac App Store から入れる（十数GB）。一度起動して規約に同意。
2. 開発用ツールの向き先を Xcode にする（パスワードが必要）。
   ```bash
   sudo xcode-select -s /Applications/Xcode.app/Contents/Developer
   ```
3. **Unity Hub** → Installs → 6000.6.10f1 の歯車 → Add modules → **iOS Build Support**。
4. Xcode の `Settings > Accounts` に **Apple ID** を追加（無料でよい）。
5. iPad の **デベロッパモード**をオン（下の「つまずき」参照）。

## ビルドして入れる

1. Xcode プロジェクトを書き出す（Unity のメニュー `Tools > KidsChase > Build iOS`、またはコマンド）。
   ```bash
   /Applications/Unity/Hub/Editor/6000.6.10f1/Unity.app/Contents/MacOS/Unity -batchmode -projectPath ~/git/05_unity/carchase_game -buildTarget iOS -executeMethod BuildIOS.Build -quit
   ```
   出力先は `Builds/iOS`（Git の対象外、約1.2GB）。初回は iOS 用の取り込みで10分以上かかる。
2. Xcode で開く。
   ```bash
   open ~/git/05_unity/carchase_game/Builds/iOS/Unity-iPhone.xcodeproj
   ```
3. 初回だけ: 左の `Unity-iPhone` → `TARGETS` の **Unity-iPhone**（UnityFramework ではない）→ `Signing & Capabilities` → `Automatically manage signing` にチェック → `Team` に自分の Apple ID。
4. 実行先を自分の iPad にして、再生ボタン（▶）。確認が出たら Replace。
5. 初回だけ iPad で `設定 > 一般 > VPNとデバイス管理` → 自分の Apple ID を「信頼」。

## 直したあとの手順（2回目以降）

1. コードを直す（必要なら `Build All`）。
2. `Build iOS` で `Builds/iOS` を更新。
3. Xcode で開き、iPad をつないで ▶。Team の設定は `Builds/iOS` を消さない限り残る。
4. 入ったらケーブルは抜いてよい。

## 設定したこと

- アプリID: `com.kidschase.game2611`（他で使われていたら数字を変える）
- 向き: **横向き専用**（画面ボタンが横向き前提）
- 最低 iOS: 15.0 ／ 対象: iPhone と iPad

## つまずきメモ

| 症状 | 原因と対処 |
|---|---|
| `xcode-select` で `invalid developer directory` | Xcode が入っていない。コマンドラインツールだけでは不可。Xcode を入れる |
| iPad にデベロッパモードの項目がない | 項目は、Xcode が一度インストールを試みたあとに出る。▶ を押して `Developer Mode disabled` のエラーを出す → iPad の `設定 > プライバシーとセキュリティ` の**一番下**を見る。それでも出なければ再起動してもう一度 ▶。時間をおいて急に出ることもあった |
| `Developer Mode disabled`（`-28`） | 上と同じ。エラーは正常な動き |
| `Replace "KidsChaseGame"?` と聞かれる | すでに起動中。Cancel でよい（iPad 側を見る）|
| 起動しない / 信頼されていない | `設定 > 一般 > VPNとデバイス管理` で信頼 |
| アプリがホーム画面にない | 最後のページかアプリライブラリ（検索「Kids」）にある |
| Xcode の上部が `Copying OS library symbols` | 初めてつないだ iPad で必ず走る準備。待つ |

> [!warning] 7日で切れる
> 無料の Apple ID で入れたアプリは**7日で起動できなくなる**。iPad をつないで Xcode の ▶ で入れ直せばよい（再ビルドは不要）。

## 確認コマンド（Mac から iPad の状態を見る）

```bash
xcrun devicectl list devices                                     # つながっているか
xcrun devicectl device info apps --device <UDID> --include-all-apps | grep -i kids   # 入っているか
xcrun devicectl device process launch --device <UDID> com.kidschase.game2611         # 起動
```
