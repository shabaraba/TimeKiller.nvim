local M = {}

M.ns = vim.api.nvim_create_namespace("timekiller_snake_renderer")

local COLORS = {
  bg = "#1e1e2e",
  body = "#4caf50",
  head = "#8bc34a",
  food = "#e53935",
}

local hl_cache = {}

local function hl_name(fg, bg)
  local key = fg .. "_" .. bg
  local name = hl_cache[key]
  if not name then
    name = "SnakePx" .. vim.tbl_count(hl_cache)
    vim.api.nvim_set_hl(0, name, { fg = fg, bg = bg })
    hl_cache[key] = name
  end
  return name
end

local function pixel_color(state, x, y)
  if state.food and state.food.x == x and state.food.y == y then
    return COLORS.food
  end
  for i, seg in ipairs(state.snake) do
    if seg.x == x and seg.y == y then
      return i == 1 and COLORS.head or COLORS.body
    end
  end
  return COLORS.bg
end

function M.render(buf, state)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  local lines = {}
  local line_highlights = {}

  for row = 0, state.height - 1, 2 do
    local chars = {}
    local highlights = {}
    for x = 0, state.width - 1 do
      local top = pixel_color(state, x, row)
      local bottom = row + 1 < state.height and pixel_color(state, x, row + 1) or COLORS.bg
      chars[#chars + 1] = "▀"
      highlights[#highlights + 1] = hl_name(top, bottom)
    end
    lines[#lines + 1] = table.concat(chars)
    line_highlights[#line_highlights + 1] = highlights
  end

  lines[#lines + 1] = string.format("Score: %d", state.score)
  if state.game_over then
    lines[#lines + 1] = "Game Over - q: 終了  r: 再挑戦"
  end

  vim.bo[buf].modifiable = true
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_clear_namespace(buf, M.ns, 0, -1)

  for row_idx, highlights in ipairs(line_highlights) do
    for col_idx, group in ipairs(highlights) do
      -- "▀" (U+2580) はUTF-8で3バイト固定
      local byte_col = (col_idx - 1) * 3
      vim.api.nvim_buf_add_highlight(buf, M.ns, group, row_idx - 1, byte_col, byte_col + 3)
    end
  end

  vim.bo[buf].modifiable = false
end

return M
