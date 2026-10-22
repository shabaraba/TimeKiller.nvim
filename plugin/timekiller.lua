if vim.g.loaded_timekiller then
  return
end
vim.g.loaded_timekiller = true

local function complete_layout()
  return require("timekiller.config").LAYOUTS
end

local function define(name, module, desc)
  vim.api.nvim_create_user_command(name, function(args)
    local layout = args.args ~= "" and args.args or nil
    if layout and not require("timekiller.config").is_valid_layout(layout) then
      vim.notify("TimeKiller.nvim: unknown layout '" .. layout .. "'", vim.log.levels.ERROR)
      return
    end
    require(module).start({ layout = layout })
  end, { nargs = "?", complete = complete_layout, desc = desc })
end

define("TimeKillerSnake", "timekiller.snake", "Start snake game ([layout]: float|split|vsplit|tab)")
define("TimeKiller2048", "timekiller.game2048", "Start 2048 game ([layout]: float|split|vsplit|tab)")
