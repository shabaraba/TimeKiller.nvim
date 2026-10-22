local animation = require("timekiller.game2048.animation")
local input = require("timekiller.input")
local renderer = require("timekiller.game2048.renderer")
local state_mod = require("timekiller.game2048.state")
local window = require("timekiller.window")

local M = {}

local session
local handle

function M.start(opts)
  if session then
    vim.notify("TimeKiller.nvim: 2048 is already running", vim.log.levels.WARN)
    return
  end
  opts = opts or {}

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "game2048"

  local size = opts.size or 4
  handle = window.open(buf, { width = 1 + size * 10, height = size * 3 + 3, title = " 2048 " }, opts.layout)

  session = { buf = buf, opts = opts, state = state_mod.new(opts) }
  renderer.render(buf, session.state)

  input.setup(buf, {
    on_direction = function(dir)
      animation.cancel(session.anim)
      if state_mod.move(session.state, dir) then
        session.anim = animation.play(buf, session.state)
      else
        renderer.render(buf, session.state)
      end
    end,
    on_quit = M.stop,
    on_restart = function()
      animation.cancel(session.anim)
      session.state = state_mod.new(session.opts)
      renderer.render(buf, session.state)
    end,
  })

  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buf,
    once = true,
    callback = function()
      animation.cancel(session.anim)
      session = nil
      handle = nil
    end,
  })
end

function M.stop()
  window.close(handle)
end

return M
