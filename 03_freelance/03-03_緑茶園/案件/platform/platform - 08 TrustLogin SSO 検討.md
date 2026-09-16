---
tags:
  - 緑茶園
  - 案件
  - platform
  - 認証
  - SSO
client: 緑茶園グループ
created: 2026-09-16
updated: 2026-09-16
aliases:
  - TrustLogin SSO
  - platform SSO
---

# TrustLogin（GMO）での SSO ログイン — 検討

親: [[platform - 00 概要]] ／ 現状の認証: [[platform - 02 Supabase・認証・環境変数]] ／ 権限モデル: [[platform - 05 統合方針（決定事項と設計）]] の4章

> [!info] 本書の位置づけ
> 2026-09-16、統合コンソール（`ryokuchaen-platform`）に **TrustLogin（GMO）経由のログイン**を足したいという要望が出た。持ち込まれた6ステップの手順案を、Supabase の公式ドキュメントと本番プロジェクトの実状に突き合わせて検証した記録。
> **まだ実装していない。** 下の「決めること」が埋まるまで着手しない。手順の詳細（コマンド・URL）は実装時にリポジトリ側の `docs/` に置く。ここに残すのは**前提が合っているかの判断**だけ。

## 手順案は大筋で成立する。ただし順番が2つ逆

持ち込まれた案は「SPメタデータ取得 → TrustLogin でアプリ作成 → `supabase sso add` → 属性マッピング → アプリ側の導線 → プラン確認」の順だった。

- **プラン確認（案では最後）は前提条件**。SAML 2.0 は Pro 以上。→ 確認済み、**組織は Pro なので追加手配は不要**（2026-09-16、MCPで確認）
- **SAML の有効化（案には無い）が最初に要る**。公式ドキュメントに「SAML 2.0 support is disabled by default on Supabase projects」とあり、ダッシュボードの Auth Providers で有効化するまで **SPメタデータのURL自体が引けない**。案の手順1はここで止まる

裏取りした前提：

| 項目 | 確認結果（2026-09-16） |
|---|---|
| プラン | 組織 `CHOISC1208's Org` は **pro**。SAML 利用可 |
| 課金 | SSO MAU は $0.015／人（プラン枠の超過分のみ） |
| SAML の初期状態 | **既定で無効**。ダッシュボードで有効化が必要 |
| CLI | `supabase sso add --type saml --project-ref ... --metadata-file ... --domains ...` は案のとおりで正しい（CLI v1.46.4 以上） |
| 属性マッピング | `--attribute-mapping-file <JSON>` でファイル指定。インラインのオプションではない。未指定なら Supabase 既定の email 検出順が使われる |
| IdP-initiated | **PKCE と非互換**。TrustLogin のポータルからアイコン起動させたい場合は、アプリ側に起点URLを作って「ブックマークアプリ」として登録する回避策が要る |

## 効いてくるのは手順ではなく、このアプリ固有の3点

> [!warning] 1. SSO で入った人は「別人」になる可能性がある
> 権限は `core.user_roles`・`core.user_permissions`・`core.superusers` がすべて `auth.users.id`（uuid）で紐付いている（[[platform - 05 統合方針（決定事項と設計）]] 4章）。SSO の初回ログインで新しい uuid が発行されると、**既定が拒否なので何も見えない人が増えるだけ**になる。既存のメールアドレスと一致したときに既存アカウントへ identity が紐付くのかは、実機で `auth.identities` を見て確認するしかない。
>
> さらに、**現在の3アカウントのメールドメインは `gmail.com`・`yamagata-elab.com`・`multi-channel-order-fetcher.local` で、`ryokuchaen.co.jp` のユーザーは1人もいない**（2026-09-16 確認）。案が前提にしていた「会社ドメインで束ねる」形が、今のユーザー構成とそのままでは噛み合わない。superuser（`nieve.n.cook1208@gmail.com`）は SSO の対象外になるため、パスワードログインを残すかどうかの判断が要る。

> [!warning] 2. `proxy.ts` がコールバックを横取りする
> 現在の `proxy.ts` は `/login` と静的アセット以外の全パスで未ログインを弾く（[[platform - 02 Supabase・認証・環境変数]]）。IdP から `?code=...` で戻った時点ではまだセッションが無いので、`/login` にリダイレクトされて `exchangeCodeForSession` まで届かない。**コールバックの除外が必須**。あわせて Supabase 側の Redirect URLs 許可リストへの登録も手順案には入っていない。

> [!warning] 3. 導線はゼロから作る
> ログイン画面は `signInWithPassword` だけで、コールバックのルートも無い。案の手順5は「既存の OAuth ログインと同じパターン」と書いているが、**このアプリには OAuth ログインの実装は存在しない**。新規実装。

## 決めること

- [ ] **SSO に載せるメールドメイン**。既存3アカウントのどれとも一致しないので、ここが決まらないと `supabase sso add` まで進めない。そもそも先方が TrustLogin 上でどのドメインのアカウントを配っているかの確認から
- [ ] **既存のパスワードログインを残すか、SSO に一本化するか**。superuser が SSO 対象外のドメインなら残すしかない。SSO 対象ドメインのユーザーがパスワードでも入れてしまうかは実機で確認する
- [ ] **EC検証用ボット（`test-bot@multi-channel-order-fetcher.local`、Bearer トークン運用）の扱い**。SSO 一本化と両立しない（`test:mock` 相当の作り直しと同じ判断 → [[platform - 05 統合方針（決定事項と設計）]]「未決・要確認」）
- [ ] **TrustLogin のポータルからアイコン起動させるか**（する場合はブックマークアプリ方式の起点URLが要る）
- [ ] **TrustLogin 側が SP メタデータXMLのアップロードに対応しているか**〔未確認。手入力になる前提で ACS URL・Entity ID を控える〕

## なぜ今これを検討するか

[[platform - 05 統合方針（決定事項と設計）]] の権限モデルは「superuser が `/settings/access` でユーザーを作り、初期パスワードを直接伝える」という運用になっている（custom SMTP が無く招待メールを送れないため、2026-09-15 決定）。SSO が入ると**アカウントの作成元が TrustLogin 側に移る**ので、この運用と権限の割り当て手順を見直す必要が出る。SSO は「ログイン方法の追加」ではなく、**ユーザー管理の持ち主を誰にするかの決定**として扱う。
