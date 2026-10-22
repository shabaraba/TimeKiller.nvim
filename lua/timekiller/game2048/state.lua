local M = {}

local TARGET = 2048

function M.slide_moves(line)
  local tiles = {}
  for idx, v in ipairs(line) do
    if v ~= 0 then
      tiles[#tiles + 1] = { idx = idx, value = v }
    end
  end

  local out, moves, gained, i, dest = {}, {}, 0, 1, 0
  while i <= #tiles do
    dest = dest + 1
    local tile, nxt = tiles[i], tiles[i + 1]
    if nxt and nxt.value == tile.value then
      out[dest] = tile.value * 2
      gained = gained + out[dest]
      moves[#moves + 1] = { from = tile.idx, to = dest, value = tile.value, merged = true }
      moves[#moves + 1] = { from = nxt.idx, to = dest, value = tile.value, merged = true }
      i = i + 2
    else
      out[dest] = tile.value
      moves[#moves + 1] = { from = tile.idx, to = dest, value = tile.value }
      i = i + 1
    end
  end
  for j = dest + 1, #line do
    out[j] = 0
  end
  return out, gained, moves
end

function M.slide(line)
  local out, gained = M.slide_moves(line)
  return out, gained
end

local function line_coords(n, dir)
  local lines = {}
  for a = 1, n do
    local coords = {}
    for b = 1, n do
      if dir == "left" then
        coords[b] = { a, b }
      elseif dir == "right" then
        coords[b] = { a, n + 1 - b }
      elseif dir == "up" then
        coords[b] = { b, a }
      else
        coords[b] = { n + 1 - b, a }
      end
    end
    lines[a] = coords
  end
  return lines
end

local function empty_cells(state)
  local cells = {}
  for r = 1, state.size do
    for c = 1, state.size do
      if state.board[r][c] == 0 then
        cells[#cells + 1] = { r, c }
      end
    end
  end
  return cells
end

function M.spawn(state)
  local cells = empty_cells(state)
  if #cells == 0 then
    return
  end
  local cell = cells[math.min(math.floor(state.rng() * #cells) + 1, #cells)]
  state.board[cell[1]][cell[2]] = state.rng() < 0.9 and 2 or 4
  return cell
end

local function can_move(state)
  if #empty_cells(state) > 0 then
    return true
  end
  local n, b = state.size, state.board
  for r = 1, n do
    for c = 1, n do
      if (c < n and b[r][c] == b[r][c + 1]) or (r < n and b[r][c] == b[r + 1][c]) then
        return true
      end
    end
  end
  return false
end

function M.new(opts)
  opts = opts or {}
  local size = opts.size or 4
  local board = {}
  for r = 1, size do
    board[r] = {}
    for c = 1, size do
      board[r][c] = 0
    end
  end

  local state = {
    size = size,
    board = board,
    score = 0,
    won = false,
    game_over = false,
    rng = opts.rng or math.random,
  }
  M.spawn(state)
  M.spawn(state)
  return state
end

function M.move(state, dir)
  if state.game_over then
    return false
  end

  local changed, gained_total = false, 0
  local moves, merged, merged_seen = {}, {}, {}
  for _, coords in ipairs(line_coords(state.size, dir)) do
    local line = {}
    for i, rc in ipairs(coords) do
      line[i] = state.board[rc[1]][rc[2]]
    end
    local out, gained, line_moves = M.slide_moves(line)
    gained_total = gained_total + gained
    for _, m in ipairs(line_moves) do
      moves[#moves + 1] = { from = coords[m.from], to = coords[m.to], value = m.value }
      local to = coords[m.to]
      local key = to[1] .. "," .. to[2]
      if m.merged and not merged_seen[key] then
        merged_seen[key] = true
        merged[#merged + 1] = to
      end
    end
    for i, rc in ipairs(coords) do
      if state.board[rc[1]][rc[2]] ~= out[i] then
        changed = true
        state.board[rc[1]][rc[2]] = out[i]
      end
    end
  end

  if not changed then
    return false
  end

  state.score = state.score + gained_total
  state.last_move = { moves = moves, merged = merged, spawned = M.spawn(state) }
  for r = 1, state.size do
    for c = 1, state.size do
      if state.board[r][c] >= TARGET then
        state.won = true
      end
    end
  end
  state.game_over = not can_move(state)
  return true
end

return M
