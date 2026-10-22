local M = {}

M.LAYOUTS = { "float", "split", "vsplit", "tab" }

local defaults = { layout = "float" }

local current = vim.deepcopy(defaults)

function M.is_valid_layout(layout)
  return vim.tbl_contains(M.LAYOUTS, layout)
end

function M.setup(opts)
  opts = opts or {}
  if opts.layout ~= nil and not M.is_valid_layout(opts.layout) then
    vim.notify(
      ("TimeKiller.nvim: unknown layout '%s' (available: %s)"):format(opts.layout, table.concat(M.LAYOUTS, ", ")),
      vim.log.levels.WARN
    )
    opts = vim.deepcopy(opts)
    opts.layout = nil
  end
  current = vim.tbl_extend("force", defaults, opts)
end

function M.get()
  return current
end

return M
