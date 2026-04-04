# Spotify TUI — 実装プラン

## Context

Spotify アプリを開くのが面倒なので、ターミナルから操作できる TUI ツールを作る。
音声再生は spotifyd（バックグラウンドデーモン、Dock不要）に任せ、TUI は Spotify Web API 経由で操作するリモコンとして機能する。dotfiles の `tools/spotify-tui/` に配置する。

---

## プロジェクト配置

```
dotfiles/tools/spotify-tui/
├── Cargo.toml
├── Cargo.lock
├── .gitignore
└── src/
    ├── main.rs      # エントリポイント、config読み込み、auth、イベントループ起動
    ├── app.rs       # App状態struct、Action enum、状態遷移
    ├── auth.rs      # OAuth2 PKCE フロー、トークンキャッシュのI/O
    ├── client.rs    # rspotifyラッパー、全API呼び出しをここに集約
    ├── config.rs    # ~/.config/spotify-tui/config.toml のデシリアライズ
    ├── event.rs     # Event enum、mpsc channel、input/tickタスクのspawn
    ├── handler.rs   # KeyEvent → app.pending_actions.push() のマッピング
    ├── tui.rs       # Terminal setup/teardown（alternate screen、raw mode）
    └── ui.rs        # ratatui レンダリング関数
```

---

## 主要クレート

```toml
[dependencies]
ratatui     = "0.30"
crossterm   = "0.29"
rspotify    = { version = "0.16", features = ["client-reqwest"] }
tokio       = { version = "1", features = ["full"] }
serde       = { version = "1", features = ["derive"] }
toml        = "1"
serde_json  = "1"
anyhow      = "1"
thiserror   = "2"
open        = "5"    # OAuthコールバックURLをブラウザで開く
dirs        = "5"    # ~/.config のパス解決
```

---

## 認証フロー（PKCE）

- `client_secret` 不要（PKCE = クライアントシークレットなし）
- config: `~/.config/spotify-tui/config.toml`

```toml
client_id   = "your_client_id"
device_name = "My MacBook"   # spotifyd.conf の device_name と一致させる
```

起動時フロー:
1. `~/.config/spotify-tui/token_cache.json` を読む
2. 有効なら使う / 期限切れなら refresh_token で更新
3. なければ PKCE フローを開始 → ブラウザを開く → localhost:8888 でコールバック受信 → トークンをキャッシュに書く

必要スコープ: `user-read-playback-state`, `user-modify-playback-state`, `user-read-currently-playing`

---

## イベントループ設計

```
tokio::spawn: input_task   → crossterm::event::poll() → Event::Key(k) を送信
tokio::spawn: tick_task    → 500ms interval → Event::Tick を送信

app loop:
  match rx.recv().await {
    Event::Key(k) => handler::handle_key(k, &mut app),
    Event::Tick   => {
      // API は 2秒に1回ポーリング（tick 4回に1回）
      if tick_counter % 4 == 0 { client.current_playback().await で状態更新 }
      tick_counter += 1;
      // progress_ms は stored + elapsed で補間 → なめらかなプログレスバー
    }
  }
  tui.draw(|f| ui::render(f, &app))?;
  if app.should_quit { break; }
```

---

## TUI レイアウト

```
┌─────────────────────────────────────────────────────┐
│  Now Playing                                        │
│                                                     │
│  Track Name                          Artist Name    │
│                                                     │
│  ████████████████░░░░░░░░░░  1:23 / 3:45           │
│                                                     │
│  [◀◀]  [▶ / ▐▐]  [▶▶]         Vol: ████░░  65%    │
│                                                     │
├─────────────────────────────────────────────────────┤
│  q: quit  space: play/pause  ←/→: prev/next        │
│  ↑/↓: volume  r: refresh device                    │
└─────────────────────────────────────────────────────┘
```

- プログレスバー・音量バー: `Gauge` widget
- トラック/アーティスト: `Paragraph` (中央揃え)
- ヘルプバー: `Paragraph` (dim スタイル)
- spotifyd が見つからない場合: メインブロックに赤文字で警告表示

---

## App 状態

```rust
pub struct App {
    pub track_name:      Option<String>,
    pub artist_name:     Option<String>,
    pub is_playing:      bool,
    pub progress_ms:     u64,
    pub duration_ms:     u64,
    pub last_tick_at:    std::time::Instant,
    pub volume_percent:  u8,
    pub device_id:       Option<String>,
    pub device_active:   bool,
    pub status_msg:      Option<(String, StatusLevel)>,
    pub should_quit:     bool,
    pub pending_actions: Vec<Action>,
}

pub enum Action {
    TogglePlayPause, SkipNext, SkipPrev,
    VolumeUp, VolumeDown, RefreshDevice, Quit,
}
```

---

## spotifyd デバイスの紐付け

起動時に `spotify.device()` で一覧を取得し、`config.device_name` と一致するデバイスIDを保持。
`r` キーで再取得・再紐付け可能（spotifyd 再起動後のリカバリ用）。

---

## deploy.sh への追記

```bash
# spotify-tui wrapper
link "$DOTFILES_DIR/tools/spotify-tui/bin/spotify-tui" "$HOME/.local/bin/spotify-tui"
```

`tools/spotify-tui/bin/spotify-tui` は shell wrapper:
```bash
#!/usr/bin/env bash
exec "$HOME/dotfiles/tools/spotify-tui/target/release/spotify-tui" "$@"
```

ビルドは手動で `cargo build --release` を実行。

---

## 検証手順

1. `cargo build --release` が通ること
2. spotifyd を起動し、Spotify アプリで一度再生しておく
3. `./target/release/spotify-tui` を起動 → ブラウザで OAuth 認証
4. TUI が起動し、現在の再生状態が表示されること
5. space/←/→/↑/↓ で操作できること
6. `q` で終了し、ターミナルが正常に戻ること
