local engine = require("timekiller.snake.engine")
local input = require("timekiller.input")
local window = require("timekiller.window")

local M = {}

local session
local handle

local function cleanup()
  if not session then
    return
  end
  engine.stop(session)
  session = nil
  handle = nil
end

function M.start(opts)
  if session then
    vim.notify("TimeKiller.nvim: snake is already running", vim.log.levels.WARN)
    return
  end
  opts = opts or {}

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "snake"

  local rows = math.ceil((opts.height or 24) / 2)
  handle = window.open(buf, { width = opts.width or 40, height = rows + 2, title = " Snake " }, opts.layout)

  session = engine.start(buf, opts)

  input.setup(buf, {
    on_direction = function(dir)
      engine.set_direction(session, dir)
    end,
    on_quit = M.stop,
    on_restart = function()
      engine.restart(session)
    end,
  })

  vim.api.nvim_create_autocmd("BufWipeout", {
    buffer = buf,
    once = true,
    callback = cleanup,
  })
end

function M.stop()
  window.close(handle)
end

return M
