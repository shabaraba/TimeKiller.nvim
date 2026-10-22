# TimeKiller.nvim

Neovimのバッファ内で遊べる暇つぶしミニゲーム集。Neovim RPG の前段技術検証（バッファ内描画・タイマーによるゲームループ・入力処理・リソース解放）を兼ねる。

## コマンド

| コマンド | 内容 |
|---|---|
| `:TimeKillerSnake` | スネークゲーム |
| `:TimeKiller2048` | 2048 |

引数で表示先を指定できる（例: `:TimeKillerSnake split`）。省略時は `setup()` の `layout`（既定は `float`）。

| layout | 表示先 |
|---|---|
| `float` | 画面中央のフローティングウィンドウ |
| `split` | 画面下部の横分割 |
| `vsplit` | 画面右端の縦分割 |
| `tab` | 専用タブ |

終了すると、起動前のウィンドウへ戻る。

共通操作:

- `h`/`j`/`k`/`l` または矢印キー: 移動
- `q`: 終了（タブ・バッファ・タイマーを解放する）
- `r`: リスタート

## インストール (lazy.nvim)

```lua
{
  "shabaraba/TimeKiller.nvim",
  main = "timekiller",
  cmd = { "TimeKillerSnake", "TimeKiller2048" },
  opts = { layout = "float" }, -- float | split | vsplit | tab
}
```

## 描画

- Snake: 半ブロック文字 (`▀`) + True Color で、1セルに上下2ピクセルを表現する
- 2048: 数字を表示するため背景色付きテキストで描画し、スライド・ポップをタイマーでコマ送りする

## 構成

- `lua/timekiller/config.lua` — 設定（`layout`）
- `lua/timekiller/window.lua` — 表示先(float/split/vsplit/tab)の生成と破棄（共通）
- `lua/timekiller/input.lua` — バッファローカルキーマップ（共通）
- `lua/timekiller/snake/` — `state`(純粋ロジック) / `renderer` / `engine`(`vim.uv`タイマー) / `init`(ライフサイクル)
- `lua/timekiller/game2048/` — `state` / `renderer`(キャンバス描画) / `animation` / `init`

## テスト

```sh
make test
```

`state.lua` のロジックを plenary.nvim でユニットテストする。乱数は `rng` オプションで差し替え可能。
