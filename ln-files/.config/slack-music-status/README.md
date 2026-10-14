# Slack Music Status

Slack のユーザートークンは `~/.config/slack-music-status/.env` に保存します。
`.env.example` をコピーし、`SLACK_USER_TOKEN` にトークンを設定してください。
`.env` は Git の管理対象外です。ファイルのアクセス権は `600` にします。

```sh
cp ~/.config/slack-music-status/.env.example ~/.config/slack-music-status/.env
chmod 600 ~/.config/slack-music-status/.env
```

常駐実行には `jp.sendocorp.slack-music-status.plist` を
`~/Library/LaunchAgents/` に配置します。このジョブは `.env` を読み込み、
`SLACK_USER_TOKEN` を環境変数として CLI に渡します。

手動で一度実行する場合も、先に `.env` を読み込みます。

```sh
/bin/sh -c 'set -a; . "$HOME/.config/slack-music-status/.env"; exec "$HOME/dotfiles/bin/slack-music-status" --once'
```
