# TimeKiller.nvim

Neovimのバッファ内で遊べる暇つぶしミニゲーム集。Neovim RPG の前段技術検証（バッファ内描画・タイマーによるゲームループ・入力処理・リソース解放）を兼ねる。

## コマンド

| コマンド | 内容 |
|---|---|
| `:TimeKillerSnake` | スネークゲーム |
| `:TimeKiller2048` | 2048 |

どちらも専用タブで起動する。

共通操作:

- `h`/`j`/`k`/`l` または矢印キー: 移動
- `q`: 終了（タブ・バッファ・タイマーを解放する）
- `r`: リスタート

## インストール (lazy.nvim)

```lua
{
  "shabaraba/TimeKiller.nvim",
  cmd = { "TimeKillerSnake", "TimeKiller2048" },
}
```

## 描画

- Snake: 半ブロック文字 (`▀`) + True Color で、1セルに上下2ピクセルを表現する
- 2048: 数字を表示するため背景色付きテキストで描画し、スライド・ポップをタイマーでコマ送りする

## 構成

- `lua/timekiller/input.lua` — バッファローカルキーマップ（共通）
- `lua/timekiller/snake/` — `state`(純粋ロジック) / `renderer` / `engine`(`vim.uv`タイマー) / `init`(ライフサイクル)
- `lua/timekiller/game2048/` — `state` / `renderer`(キャンバス描画) / `animation` / `init`

## テスト

```sh
make test
```

`state.lua` のロジックを plenary.nvim でユニットテストする。乱数は `rng` オプションで差し替え可能。
