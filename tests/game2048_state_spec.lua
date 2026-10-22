local state = require("timekiller.game2048.state")

local function fixed_rng(value)
  return function()
    return value
  end
end

local function blank(size)
  local s = state.new({ size = size, rng = fixed_rng(0.99) })
  for r = 1, size do
    for c = 1, size do
      s.board[r][c] = 0
    end
  end
  return s
end

describe("timekiller.game2048.state", function()
  it("slides tiles and merges equal pairs once per move", function()
    local out, gained = state.slide({ 2, 2, 2, 2 })
    assert.are.same({ 4, 4, 0, 0 }, out)
    assert.are.equal(8, gained)
  end)

  it("does not merge a freshly merged tile again", function()
    local out = state.slide({ 4, 2, 2, 0 })
    assert.are.same({ 4, 4, 0, 0 }, out)
  end)

  it("starts with two tiles", function()
    local s = state.new({ rng = fixed_rng(0) })
    local count = 0
    for r = 1, s.size do
      for c = 1, s.size do
        if s.board[r][c] ~= 0 then
          count = count + 1
        end
      end
    end
    assert.are.equal(2, count)
  end)

  it("moves tiles toward the given direction and adds score", function()
    local s = blank(4)
    s.board[1][1] = 2
    s.board[1][2] = 2
    assert.is_true(state.move(s, "right"))
    assert.are.equal(4, s.board[1][4])
    assert.are.equal(4, s.score)
  end)

  it("does not spawn a tile when nothing moves", function()
    local s = blank(4)
    s.board[1][1] = 2
    assert.is_false(state.move(s, "left"))
    assert.are.equal(0, s.score)
  end)

  it("ends the game when the board is full with no merges", function()
    local s = blank(2)
    s.board = { { 2, 4 }, { 8, 0 } }
    state.move(s, "right")
    assert.is_true(s.game_over)
  end)

  it("records where each tile moved and which cells merged", function()
    local s = blank(4)
    s.board[1][1] = 2
    s.board[1][3] = 2
    state.move(s, "left")
    assert.are.equal(2, #s.last_move.moves)
    assert.are.same({ 1, 3 }, s.last_move.moves[2].from)
    assert.are.same({ 1, 1 }, s.last_move.moves[2].to)
    assert.are.same({ { 1, 1 } }, s.last_move.merged)
    assert.is_not_nil(s.last_move.spawned)
  end)

  it("marks the game won when a 2048 tile appears", function()
    local s = blank(4)
    s.board[1][1] = 1024
    s.board[1][2] = 1024
    state.move(s, "left")
    assert.is_true(s.won)
  end)
end)
