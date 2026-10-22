local animation = require("timekiller.game2048.animation")
local input = require("timekiller.input")
local renderer = require("timekiller.game2048.renderer")
local state_mod = require("timekiller.game2048.state")

local M = {}

local session

function M.start(opts)
  if session then
    vim.notify("TimeKiller.nvim: 2048 is already running", vim.log.levels.WARN)
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "game2048"

  vim.cmd("tabnew")
  vim.api.nvim_win_set_buf(0, buf)

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
    on_quit = function()
      vim.cmd("tabclose")
    end,
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
    end,
  })
end

return M
