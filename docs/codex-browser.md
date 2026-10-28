# Codex browser lifecycle

Codexの親スレッドごとにChrome DevTools CLIの専用セッションを割り当てる。ブラウザは最初の操作で起動し、同じ親スレッドのサブエージェントはタブを分けて再利用する。親セッションが終了したら、管理対象のブラウザとデーモンを停止する。

macOS、Python 3、インストール済みの `chrome-devtools` と専用配置したChrome for Testingが必要。追加のPythonパッケージや常駐管理サーバーは使用しない。

## 操作

コマンドを単独で直接実行する。開始フックで登録されていないスレッドも、初回利用時に自動登録する。

```sh
codex-browser list_pages
codex-browser new_page 'http://localhost:3000'
codex-browser take_screenshot 1 --filePath /tmp/page.png
```

通常はheadlessを使用する。画面を共有する共同操作では、各コマンドに `--headed` を付ける。headless用と画面表示用は別のセッションを使う。

```sh
codex-browser --headed new_page 'http://localhost:3000'
```

共同操作の画面をセッション終了後も利用者に残す場合は、`--keep-open` を付ける。指定はその画面表示セッションに保持される。

```sh
codex-browser --headed --keep-open new_page 'http://localhost:3000'
codex-browser sessions
codex-browser release '<root-thread-id>'
```

`release` は指定した親スレッドの管理対象を明示的に終了する。通常の作業終了には不要。`status` はブラウザを起動しない。`start` は起動済みのセッションを再起動しない。手動の `--sessionId`、接続先、プロファイル、ブラウザの変更は受け付けない。リポジトリの正式な検査・撮影CLIは引き続き優先する。

## AI専用Chrome

headlessと画面表示の両方で、次のChrome for Testingを使用する。

```text
~/.local/share/codex-browser/chrome/current/chrome-mac-arm64/Google Chrome for Testing.app
```

通常版のGoogle Chrome.appとアプリ識別子が異なるため、AIのheadless起動と利用者のChrome起動を分けられる。プロファイルも一時ディレクトリに分離する。専用バイナリがない場合は配置先を示して終了し、通常版Chromeを代わりに起動しない。

Chrome for TestingはGoogle公式のStable版をバージョン別ディレクトリへ展開し、`current` シンボリックリンクで選択する。自動更新は行われないため、更新時は新しい版を別ディレクトリに配置してからリンクを切り替える。実行中のブラウザは切り替えず、次の起動から新しい版を使う。

## フックと終了処理

個人共通の `~/.codex/hooks.json` から、次のイベントで `codex-browser hook` を呼ぶ。

| イベント | 処理 |
|---|---|
| `SessionStart` | 親セッションと実行元Codexプロセスを登録する |
| `SubagentStart` | 子エージェントを親のブラウザに対応付ける |
| `SessionEnd` | 終了を記録し、停止処理を別プロセスへ引き渡す |

`SessionEnd` は主スレッドの正常終了やアーカイブなどで実行される。単に表示を切り替えたり接続を外した場合は、Codex側の終了判定まで遅れる場合がある。終了フックは時間制限があるため、Chromeの停止完了をフック内で待たない。

管理記録は `~/Library/Caches/codex-browser` に保存する。停止前には専用セッションのPIDと起動日時を照合する。起動の競合は親スレッド単位のファイルロックで防ぐ。存在確認が権限不足の場合、新しいデーモンを追加起動しない。

開始フックを通らない既存スレッドも、利用時に登録・再登録する。子エージェントの対応付けがなければ、Codexのローカルデータベースから親情報を読み取る。親情報を取得できない場合は、そのスレッドを独立した所有者として扱う。

`codex-browser reap` は、終了記録のあるセッション、Codex側でアーカイブ済みのセッション、または実行元Codexプロセスが終了・入れ替わったセッションだけを回収する。macOSのLaunchAgentから5分ごとに実行し、終了フックを通らなかった場合も回収できるようにする。`--keep-open` の画面は自動回収しない。

Codexのデータベースを読めない場合は、通常のフック記録とプロセス情報で動作を続ける。親情報が不明な場合も、別のスレッドのブラウザを推測で共有・停止しない。

既存のChrome、手動で起動したDevToolsセッション、管理記録のないプロセスは対象にしない。

## 設定

`~/.local/bin/codex-browser` は、このリポジトリの `bin/codex-browser` へのシンボリックリンクにする。

`~/.codex/rules/default.rules` に、単独コマンドのサンドボックス外実行を許可する。

```python
prefix_rule(pattern=[["codex-browser", "/Users/masashiaso/.local/bin/codex-browser"]], decision="allow")
```

個人用フックにはコマンドを追加し、Codexのフック一覧でその定義を信頼する。既存のフックは保持する。開始登録は利用時にも行えるため、利用のためだけにCLIを再起動する必要はない。

LaunchAgentのラベルは `com.masasam.codex-browser-cleanup`、実行間隔は300秒。実行対象は `codex-browser reap` とする。

## 検証

```sh
python3 -m unittest discover -s tests -p 'test_codex_browser.py' -v
```

テストでは親子の対応付け、起動後の再利用、別スレッドの保護、プロセス識別情報の不一致、共同操作の表示維持、権限不足、終了処理を確認する。実ブラウザで検証する際は、専用の `CODEX_BROWSER_STATE_DIR` と新規テストスレッドを使用する。
