local engine = require("timekiller.snake.engine")
local input = require("timekiller.input")

local M = {}

local session

local function close()
  if not session then
    return
  end
  engine.stop(session)
  session = nil
end

function M.start(opts)
  if session then
    vim.notify("TimeKiller.nvim: already running", vim.log.levels.WARN)
    return
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "snake"

  vim.cmd("tabnew")
  vim.api.nvim_win_set_buf(0, buf)

  session = engine.start(buf, opts)

  input.setup(buf, {
    on_direction = function(dir)
      engine.set_direction(session, dir)
    end,
    on_quit = function()
      vim.cmd("tabclose")
    end,
    on_restart = function()
      engine.restart(session)
    end,
  })

  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buf,
    once = true,
    callback = close,
  })
end

function M.stop()
  if session then
    vim.cmd("tabclose")
  end
end

return M
