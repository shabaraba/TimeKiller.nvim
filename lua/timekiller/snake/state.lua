local M = {}

M.DIRECTIONS = {
  up = { x = 0, y = -1 },
  down = { x = 0, y = 1 },
  left = { x = -1, y = 0 },
  right = { x = 1, y = 0 },
}

local function is_occupied(state, x, y)
  for _, seg in ipairs(state.snake) do
    if seg.x == x and seg.y == y then
      return true
    end
  end
  return false
end

function M.spawn_food(state)
  local free = {}
  for y = 0, state.height - 1 do
    for x = 0, state.width - 1 do
      if not is_occupied(state, x, y) then
        free[#free + 1] = { x = x, y = y }
      end
    end
  end
  if #free == 0 then
    state.food = nil
    return
  end
  local idx = math.floor(state.rng() * #free) + 1
  state.food = free[math.min(idx, #free)]
end

function M.new(opts)
  opts = opts or {}
  local width = opts.width or 40
  local height = opts.height or 24
  local start_x = math.floor(width / 2)
  local start_y = math.floor(height / 2)

  local state = {
    width = width,
    height = height,
    snake = {
      { x = start_x, y = start_y },
      { x = start_x - 1, y = start_y },
      { x = start_x - 2, y = start_y },
    },
    dir = M.DIRECTIONS.right,
    pending_dir = nil,
    food = nil,
    score = 0,
    game_over = false,
    rng = opts.rng or math.random,
  }
  M.spawn_food(state)
  return state
end

function M.set_direction(state, dir_name)
  local dir = M.DIRECTIONS[dir_name]
  if not dir then
    return
  end
  if dir.x == -state.dir.x and dir.y == -state.dir.y then
    return
  end
  state.pending_dir = dir
end

function M.tick(state)
  if state.game_over then
    return
  end

  if state.pending_dir then
    state.dir = state.pending_dir
    state.pending_dir = nil
  end

  local head = state.snake[1]
  local new_head = { x = head.x + state.dir.x, y = head.y + state.dir.y }

  if new_head.x < 0 or new_head.x >= state.width or new_head.y < 0 or new_head.y >= state.height then
    state.game_over = true
    return
  end

  local ate_food = state.food ~= nil and new_head.x == state.food.x and new_head.y == state.food.y

  -- 食べない限り尾は同じtickで消えるので、衝突判定の対象から外す
  local check_len = ate_food and #state.snake or (#state.snake - 1)
  for i = 1, check_len do
    local seg = state.snake[i]
    if seg.x == new_head.x and seg.y == new_head.y then
      state.game_over = true
      return
    end
  end

  table.insert(state.snake, 1, new_head)
  if ate_food then
    state.score = state.score + 1
    M.spawn_food(state)
  else
    table.remove(state.snake)
  end
end

return M
