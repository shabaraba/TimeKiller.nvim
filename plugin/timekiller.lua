if vim.g.loaded_timekiller then
  return
end
vim.g.loaded_timekiller = true

vim.api.nvim_create_user_command("TimeKillerSnake", function()
  require("timekiller.snake").start()
end, { desc = "Start snake game" })

vim.api.nvim_create_user_command("TimeKiller2048", function()
  require("timekiller.game2048").start()
end, { desc = "Start 2048 game" })
