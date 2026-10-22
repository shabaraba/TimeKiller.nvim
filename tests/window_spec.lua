local config = require("timekiller.config")
local window = require("timekiller.window")

local SIZE = { width = 41, height = 15, title = " test " }

describe("timekiller.config", function()
  after_each(function()
    config.setup({})
  end)

  it("defaults to the float layout", function()
    config.setup({})
    assert.are.equal("float", config.get().layout)
  end)

  it("falls back to the default when the layout is unknown", function()
    config.setup({ layout = "bogus" })
    assert.are.equal("float", config.get().layout)
  end)

  it("accepts every documented layout", function()
    for _, layout in ipairs(config.LAYOUTS) do
      config.setup({ layout = layout })
      assert.are.equal(layout, config.get().layout)
    end
  end)
end)

describe("timekiller.window", function()
  for _, layout in ipairs(config.LAYOUTS) do
    it("opens and closes the " .. layout .. " layout, returning focus", function()
      local prev = vim.api.nvim_get_current_win()
      local buf = vim.api.nvim_create_buf(false, true)
      vim.bo[buf].bufhidden = "wipe"

      local handle = window.open(buf, SIZE, layout)
      assert.is_true(vim.api.nvim_win_is_valid(handle.win))
      assert.are.equal(buf, vim.api.nvim_win_get_buf(handle.win))
      assert.are.equal(layout == "float", vim.api.nvim_win_get_config(handle.win).relative == "editor")

      window.close(handle)
      assert.is_false(vim.api.nvim_win_is_valid(handle.win))
      assert.are.equal(prev, vim.api.nvim_get_current_win())
      assert.is_false(vim.api.nvim_buf_is_valid(buf))
    end)
  end

  it("uses the configured layout when none is given", function()
    config.setup({ layout = "split" })
    local buf = vim.api.nvim_create_buf(false, true)
    vim.bo[buf].bufhidden = "wipe"
    local handle = window.open(buf, SIZE)
    assert.are.equal("split", handle.layout)
    window.close(handle)
    config.setup({})
  end)
end)
