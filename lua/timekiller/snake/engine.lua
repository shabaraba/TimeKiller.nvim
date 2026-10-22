local state_mod = require("timekiller.snake.state")
local renderer = require("timekiller.snake.renderer")

local M = {}

local TICK_MS = 150

local function make_tick(session)
  return function()
    state_mod.tick(session.state)
    renderer.render(session.buf, session.state)
    if session.state.game_over then
      session.timer:stop()
    end
  end
end

function M.start(buf, opts)
  local session = {
    buf = buf,
    opts = opts,
    state = state_mod.new(opts),
    timer = vim.uv.new_timer(),
  }
  renderer.render(session.buf, session.state)
  session.timer:start(TICK_MS, TICK_MS, vim.schedule_wrap(make_tick(session)))
  return session
end

function M.set_direction(session, dir)
  state_mod.set_direction(session.state, dir)
end

function M.restart(session)
  session.state = state_mod.new(session.opts)
  renderer.render(session.buf, session.state)
  session.timer:start(TICK_MS, TICK_MS, vim.schedule_wrap(make_tick(session)))
end

function M.stop(session)
  if session.timer and not session.timer:is_closing() then
    session.timer:stop()
    session.timer:close()
  end
end

return M
