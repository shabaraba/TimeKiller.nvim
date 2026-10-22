local M = {}

local DIRECTION_KEYS = {
  ["h"] = "left",
  ["<Left>"] = "left",
  ["l"] = "right",
  ["<Right>"] = "right",
  ["k"] = "up",
  ["<Up>"] = "up",
  ["j"] = "down",
  ["<Down>"] = "down",
}

function M.setup(buf, callbacks)
  local opts = { buffer = buf, nowait = true, silent = true }

  for key, dir in pairs(DIRECTION_KEYS) do
    vim.keymap.set("n", key, function()
      callbacks.on_direction(dir)
    end, opts)
  end

  vim.keymap.set("n", "q", callbacks.on_quit, opts)
  vim.keymap.set("n", "r", callbacks.on_restart, opts)
end

return M
