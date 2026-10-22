local renderer = require("timekiller.game2048.renderer")

local M = {}

local SLIDE_FRAMES = 5
local FRAME_MS = 20

local function slide_tiles(info, t)
  local tiles = {}
  for _, m in ipairs(info.moves) do
    local fy, fx = renderer.origin(m.from[1], m.from[2])
    local ty, tx = renderer.origin(m.to[1], m.to[2])
    tiles[#tiles + 1] = {
      y = math.floor(fy + (ty - fy) * t + 0.5),
      x = math.floor(fx + (tx - fx) * t + 0.5),
      value = m.value,
    }
  end
  return tiles
end

local function pop_tiles(state, info)
  local popping = {}
  for _, rc in ipairs(info.merged) do
    popping[rc[1] .. "," .. rc[2]] = true
  end
  if info.spawned then
    popping[info.spawned[1] .. "," .. info.spawned[2]] = true
  end
  return renderer.board_tiles(state, popping)
end

function M.cancel(anim)
  if not anim or anim.cancelled then
    return
  end
  anim.cancelled = true
  if not anim.timer:is_closing() then
    anim.timer:stop()
    anim.timer:close()
  end
end

function M.play(buf, state)
  local info = state.last_move
  local anim = { timer = vim.uv.new_timer(), cancelled = false }
  local step = 0

  anim.timer:start(
    FRAME_MS,
    FRAME_MS,
    vim.schedule_wrap(function()
      if anim.cancelled then
        return
      end
      step = step + 1
      if step <= SLIDE_FRAMES then
        renderer.render(buf, state, slide_tiles(info, step / SLIDE_FRAMES))
      elseif step == SLIDE_FRAMES + 1 then
        renderer.render(buf, state, pop_tiles(state, info))
      else
        renderer.render(buf, state)
        M.cancel(anim)
      end
    end)
  )
  return anim
end

return M
