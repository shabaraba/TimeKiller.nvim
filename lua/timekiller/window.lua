local config = require("timekiller.config")

local M = {}

local WINDOW_OPTIONS = {
  number = false,
  relativenumber = false,
  signcolumn = "no",
  foldcolumn = "0",
  statuscolumn = "",
  colorcolumn = "",
  cursorline = false,
  cursorcolumn = false,
  wrap = false,
  list = false,
  spell = false,
}

local function apply_window_options(win)
  for name, value in pairs(WINDOW_OPTIONS) do
    vim.wo[win][name] = value
  end
end

local function open_float(buf, size)
  local border_size = 2
  local width = math.min(size.width, vim.o.columns - border_size)
  local height = math.min(size.height, vim.o.lines - vim.o.cmdheight - border_size)
  return vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width - border_size) / 2),
    row = math.floor((vim.o.lines - height - border_size) / 2),
    style = "minimal",
    border = "rounded",
    title = size.title,
    title_pos = "center",
  })
end

local function open_split(buf, size, layout)
  if layout == "split" then
    vim.cmd(("botright %dsplit"):format(size.height))
    vim.wo.winfixheight = true
  elseif layout == "vsplit" then
    vim.cmd(("botright %dvsplit"):format(size.width))
    vim.wo.winfixwidth = true
  else
    vim.cmd("tabnew")
  end
  local win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(win, buf)
  return win
end

-- size: { width, height, title } はバッファ内容が必要とする文字数
function M.open(buf, size, layout)
  layout = layout or config.get().layout
  if not config.is_valid_layout(layout) then
    layout = config.get().layout
  end

  local prev = vim.api.nvim_get_current_win()
  local win
  if layout == "float" then
    win = open_float(buf, size)
  else
    win = open_split(buf, size, layout)
  end
  apply_window_options(win)
  return { win = win, prev = prev, layout = layout }
end

function M.close(handle)
  if not handle then
    return
  end
  if vim.api.nvim_win_is_valid(handle.win) then
    pcall(vim.api.nvim_win_close, handle.win, true)
  end
  if vim.api.nvim_win_is_valid(handle.prev) then
    vim.api.nvim_set_current_win(handle.prev)
  end
end

return M
