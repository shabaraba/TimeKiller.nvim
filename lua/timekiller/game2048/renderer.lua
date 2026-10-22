local M = {}

M.ns = vim.api.nvim_create_namespace("game2048_renderer")

local CELL_WIDTH = 9
local CELL_HEIGHT = 3
local BOARD_BG = "#bbada0"
local DARK_FG = "#776e65"
local LIGHT_FG = "#f9f6f2"

local TILE_BG = {
  [0] = "#cdc1b4",
  [2] = "#eee4da",
  [4] = "#ede0c8",
  [8] = "#f2b179",
  [16] = "#f59563",
  [32] = "#f67c5f",
  [64] = "#f65e3b",
  [128] = "#edcf72",
  [256] = "#edcc61",
  [512] = "#edc850",
  [1024] = "#edc53f",
  [2048] = "#edc22e",
}

local hl_defined = {}

local function ensure_hl(name, fg, bg)
  if not hl_defined[name] then
    vim.api.nvim_set_hl(0, name, { fg = fg, bg = bg })
    hl_defined[name] = true
  end
  return name
end

local function tile_hl(value)
  local bg = TILE_BG[value] or "#3c3a32"
  local fg = value <= 4 and DARK_FG or LIGHT_FG
  return ensure_hl("Game2048Tile" .. value, fg, bg)
end

-- 盤のセル(r, c)の左上を、0始まりの文字座標 (y, x) で返す
function M.origin(r, c)
  return (r - 1) * CELL_HEIGHT, 1 + (c - 1) * (CELL_WIDTH + 1)
end

function M.board_tiles(state, inset_cells)
  local tiles = {}
  for r = 1, state.size do
    for c = 1, state.size do
      local value = state.board[r][c]
      if value ~= 0 then
        local y, x = M.origin(r, c)
        tiles[#tiles + 1] = { y = y, x = x, value = value, inset = inset_cells and inset_cells[r .. "," .. c] }
      end
    end
  end
  return tiles
end

local function new_canvas(size)
  local rows, cols = size * CELL_HEIGHT, 1 + size * (CELL_WIDTH + 1)
  local board_hl = ensure_hl("Game2048Board", DARK_FG, BOARD_BG)
  local canvas = { rows = rows, cols = cols, chars = {}, hls = {} }
  for y = 1, rows do
    canvas.chars[y], canvas.hls[y] = {}, {}
    for x = 1, cols do
      canvas.chars[y][x] = " "
      canvas.hls[y][x] = board_hl
    end
  end
  return canvas
end

local function draw_tile(canvas, tile)
  local w, h, dy, dx = CELL_WIDTH, CELL_HEIGHT, 0, 0
  if tile.inset then
    w, h, dy, dx = CELL_WIDTH - 2, 1, 1, 1
  end
  local group = tile_hl(tile.value)
  for y = tile.y + dy, tile.y + dy + h - 1 do
    for x = tile.x + dx, tile.x + dx + w - 1 do
      canvas.hls[y + 1][x + 1] = group
      canvas.chars[y + 1][x + 1] = " "
    end
  end
  if tile.value ~= 0 then
    local label = tostring(tile.value)
    local lx = tile.x + dx + math.floor((w - #label) / 2)
    local ly = tile.y + dy + math.floor(h / 2)
    for i = 1, #label do
      canvas.chars[ly + 1][lx + i] = label:sub(i, i)
    end
  end
end

local function draw_slots(canvas, size)
  for r = 1, size do
    for c = 1, size do
      local y, x = M.origin(r, c)
      draw_tile(canvas, { y = y, x = x, value = 0 })
    end
  end
end

local function highlight_canvas(buf, canvas)
  for y = 1, canvas.rows do
    local hls, start = canvas.hls[y], 1
    for x = 2, canvas.cols + 1 do
      if x > canvas.cols or hls[x] ~= hls[start] then
        vim.api.nvim_buf_set_extmark(buf, M.ns, y - 1, start - 1, { end_col = x - 1, hl_group = hls[start] })
        start = x
      end
    end
  end
end

function M.render(buf, state, tiles)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  local canvas = new_canvas(state.size)
  draw_slots(canvas, state.size)
  for _, tile in ipairs(tiles or M.board_tiles(state)) do
    draw_tile(canvas, tile)
  end

  local lines = {}
  for y = 1, canvas.rows do
    lines[y] = table.concat(canvas.chars[y])
  end
  lines[#lines + 1] = ""
  lines[#lines + 1] = string.format("Score: %d", state.score)
  if state.game_over then
    lines[#lines + 1] = "Game Over - q: 終了  r: 再挑戦"
  elseif state.won then
    lines[#lines + 1] = "2048 達成！ そのまま続けられます"
  end

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_clear_namespace(buf, M.ns, 0, -1)
  highlight_canvas(buf, canvas)
  vim.bo[buf].modifiable = false
end

return M
