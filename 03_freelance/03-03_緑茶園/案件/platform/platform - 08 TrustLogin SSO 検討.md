---
tags:
  - 緑茶園
  - 案件
  - platform
  - 認証
  - SSO
client: 緑茶園グループ
created: 2026-09-16
updated: 2026-09-17
aliases:
  - TrustLogin SSO
  - platform SSO
---

# TrustLogin（GMO）での SSO ログイン — 検討

親: [[platform - 00 概要]] ／ 現状の認証: [[platform - 02 Supabase・認証・環境変数]] ／ 権限モデル: [[platform - 05 統合方針（決定事項と設計）]] の4章

> [!info] 本書の位置づけ
> 2026-09-16、統合コンソール（`ryokuchaen-platform`）に **TrustLogin（GMO）経由のログイン**を足したいという要望が出た。持ち込まれた6ステップの手順案を、Supabase の公式ドキュメントと本番プロジェクトの実状に突き合わせて検証した記録。
> **まだ実装していない。** 下の「決めること」が埋まるまで着手しない。
> **手順の正本は [[platform - TrustLogin SSO 導入手順]]**（SP情報の表・先方への依頼文・`sso add` 以降の作業・検証手順）。ここに残すのは**前提が合っているかの判断**だけ。

> [!success] 2026-09-16：Supabase 側の SAML を有効化し、先方への依頼待ちになった
> - プロジェクトで SAML 2.0 を有効化し、SP メタデータが返ることを確認（有効化するまでメタデータ URL 自体が 404 で、案の手順1はここで止まる想定どおりだった）
> - 先方に渡す値は確定（ACS・Entity ID・SLO・NameID は `emailAddress` と `persistent` の両対応・**アサーション署名は必須**）。メタデータの `validUntil` が取得の約2日後までしか無いため、XML ファイルではなく**メタデータ URL で登録してもらう**方針にした
> - 依頼文は [[platform - TrustLogin SSO 導入手順]] に用意済み。**IdP メタデータが返ってくるまでこちらの作業は無い**

> [!info] 2026-09-17：SSO が入るまで、2段階認証（TOTP）で代わりにする
> SSO は先方待ちで時間がかかる見込みのため、先に Supabase Auth の TOTP を全員に必須にした（判断の経緯 → [[platform - 05 統合方針（決定事項と設計）]] 3章）。SSO を入れるときは、下の「決めること」に足した **TOTP の扱い**を決める。
> - `proxy.ts` は2段階目がまだの人を `/login/mfa`・`/login/mfa/setup` にしか通さなくなった。SSO のコールバックを除外するとき、この判定とも合わせる必要がある

## 手順案は大筋で成立する。ただし順番が2つ逆

持ち込まれた案は「SPメタデータ取得 → TrustLogin でアプリ作成 → `supabase sso add` → 属性マッピング → アプリ側の導線 → プラン確認」の順だった。

> [!warning] 2026-09-16 訂正：案にあった「メールドメインで束ねる」は不要
> 案は `--domains ryokuchaen.co.jp` を前提にしていたが、**TrustLogin 側は利用者のメールドメインを問わない**（先方は `gmail.com` と `yamagata-elab.com` の両方を TrustLogin に登録済み）。ドメインは Supabase が IdP を引くための任意設定にすぎないので、**指定せず `signInWithSSO({ providerId })` でボタン1つにする**のが素直。混在ドメインのままで通る。

- **プラン確認（案では最後）は前提条件**。SAML 2.0 は Pro 以上。→ 確認済み、**組織は Pro なので追加手配は不要**（2026-09-16、MCPで確認）
- **SAML の有効化（案には無い）が最初に要る**。公式ドキュメントに「SAML 2.0 support is disabled by default on Supabase projects」とあり、ダッシュボードの Auth Providers で有効化するまで **SPメタデータのURL自体が引けない**。案の手順1はここで止まる

裏取りした前提：

| 項目 | 確認結果（2026-09-16） |
|---|---|
| プラン | 組織 `CHOISC1208's Org` は **pro**。SAML 利用可 |
| 課金 | SSO MAU は $0.015／人（プラン枠の超過分のみ） |
| SAML の初期状態 | **既定で無効**。ダッシュボードで有効化が必要 |
| CLI | `supabase sso add --type saml --project-ref ... --metadata-file ...`（CLI v1.46.4 以上） |
| メールドメイン | **任意**。「(Optional) Email domains that the organization's IdP uses」。指定しない場合は `signInWithSSO({ providerId })` で IdP を直接指定する（公式の例も「Sign in with Okta ボタン」の形） |
| 属性マッピング | `--attribute-mapping-file <JSON>` でファイル指定。インラインのオプションではない。未指定なら Supabase 既定の email 検出順が使われる |
| IdP-initiated | **PKCE と非互換**。TrustLogin のポータルからアイコン起動させたい場合は、アプリ側に起点URLを作って「ブックマークアプリ」として登録する回避策が要る |

## 効いてくるのは手順ではなく、このアプリ固有の3点

> [!warning] 1. SSO で入った人が「別人」になると権限が効かない
> 権限は `core.user_roles`・`core.user_permissions`・`core.superusers` がすべて `auth.users.id`（uuid）で紐付いている（[[platform - 05 統合方針（決定事項と設計）]] 4章）。SSO の初回ログインで**新しい uuid** が発行されると、既定が拒否なので「ログインはできるが何も見えない人」が増えるだけになる。既存のメールアドレスと一致したときに既存アカウントへ identity が紐付くのかは、実機で `auth.identities` を見て確認するしかない。
>
> 現在の人のアカウントは superuser（`nieve.n.cook1208@gmail.com`）と `info@yamagata-elab.com` の2つで、**どちらも TrustLogin に登録済み**。つまり SSO を入れると、この2人がそのまま SSO 経路に移る。ここで uuid が変わると **superuser 権限と4ロールの割り当てが両方とも外れる**ので、切り替え前に片方で試し、`core` 側の再割り当てが要るかを確かめる。

> [!warning] 2. `proxy.ts` がコールバックを横取りする
> 現在の `proxy.ts` は `/login` と静的アセット以外の全パスで未ログインを弾く（[[platform - 02 Supabase・認証・環境変数]]）。IdP から `?code=...` で戻った時点ではまだセッションが無いので、`/login` にリダイレクトされて `exchangeCodeForSession` まで届かない。**コールバックの除外が必須**。あわせて Supabase 側の Redirect URLs 許可リストへの登録も手順案には入っていない。

> [!warning] 3. 導線はゼロから作る
> ログイン画面は `signInWithPassword` だけで、コールバックのルートも無い。案の手順5は「既存の OAuth ログインと同じパターン」と書いているが、**このアプリには OAuth ログインの実装は存在しない**。新規実装。

## 先方への依頼とボールの所在

**2026-09-16 時点：依頼文は用意済み、まだ送っていない。** 送付後は先方待ちで、こちらの作業は止まる。

| | 内容 |
|---|---|
| 依頼する相手 | TrustLogin の管理画面を操作できる人〔未確定。→ [[08 要確認事項]]〕 |
| 依頼すること | ① SAML アプリの作成 ② SP 情報の登録（メタデータ URL で） ③ NameID にメールアドレスを割り当て ④ **アサーションへの署名を有効化** ⑤ IdP メタデータ（XML）の共有 ⑥ まず検証用に1アカウントだけ割り当て |
| 返ってくるもの | **IdP メタデータ（XML）**。これが来るまで `supabase sso add` 以降に進めない |
| 併せて確認すること | 管理者が誰か／契約プランで SAML アプリが使えるか／ポータルからのアイコン起動を使うか → [[08 要確認事項]] |

依頼文の実物（URL・値を含む完全版）は [[platform - TrustLogin SSO 導入手順]]。**値の二重管理を避けるため、ここには転記しない。**

## 決めること

- [ ] **既存ユーザーの uuid が維持されるか**（最優先）。維持されないなら、切り替え手順に `core` の再割り当てを組み込む。ドメイン指定は不要と判明したので、残る技術的な未決はここだけ
- [ ] **既存のパスワードログインを残すか、SSO に一本化するか**。公式も「SSO を使わない管理者アカウントを最低1つ残す」ことを安全要件に挙げている。TrustLogin 側が落ちたときに誰も入れなくなる形は避ける
- [ ] **SSO を入れた後、TOTP をどう扱うか**（2026-09-17 追加）。SSO で入る人の多要素は TrustLogin 側に任せ、Supabase の TOTP は残すパスワードログイン（管理者用）にだけ求める形が素直。SSO で入った人に `aal2` が付くかは実機で確認する（付かなければ `proxy.ts` の判定を SSO 経路で分ける）
- [ ] **EC検証用ボット（`test-bot@multi-channel-order-fetcher.local`、Bearer トークン運用）の扱い**。2026-09-17 以降は2段階認証でも止まる。SSO 一本化と両立しない（`test:mock` 相当の作り直しと同じ判断 → [[platform - 05 統合方針（決定事項と設計）]]「未決・要確認」）
- [ ] **TrustLogin のポータルからアイコン起動させるか**（する場合はブックマークアプリ方式の起点URLが要る）
- [ ] **TrustLogin 側が SP メタデータXMLのアップロードに対応しているか**〔未確認。手入力になる前提で ACS URL・Entity ID を控える〕

## なぜ今これを検討するか

[[platform - 05 統合方針（決定事項と設計）]] の権限モデルは「superuser が `/settings/access` でユーザーを作り、初期パスワードを直接伝える」という運用になっている（custom SMTP が無く招待メールを送れないため、2026-09-15 決定）。SSO が入ると**アカウントの作成元が TrustLogin 側に移る**ので、この運用と権限の割り当て手順を見直す必要が出る。SSO は「ログイン方法の追加」ではなく、**ユーザー管理の持ち主を誰にするかの決定**として扱う。
