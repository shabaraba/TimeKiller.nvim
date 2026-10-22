local state = require("timekiller.snake.state")

local function fixed_rng(value)
  return function()
    return value
  end
end

describe("timekiller.snake.state", function()
  it("starts with a length-3 snake and no game over", function()
    local s = state.new({ width = 10, height = 10, rng = fixed_rng(0) })
    assert.are.equal(3, #s.snake)
    assert.are.equal(0, s.score)
    assert.is_false(s.game_over)
  end)

  it("moves the head forward and drops the tail each tick", function()
    local s = state.new({ width = 10, height = 10, rng = fixed_rng(0.99) })
    local head_before = { x = s.snake[1].x, y = s.snake[1].y }
    state.tick(s)
    assert.are.equal(head_before.x + 1, s.snake[1].x)
    assert.are.equal(3, #s.snake)
  end)

  it("ignores a direction change that reverses onto itself", function()
    local s = state.new({ width = 10, height = 10, rng = fixed_rng(0.99) })
    state.set_direction(s, "left")
    assert.is_nil(s.pending_dir)
  end)

  it("ends the game when the head crosses the wall", function()
    local s = state.new({ width = 3, height = 3, rng = fixed_rng(0.99) })
    s.snake = { { x = 2, y = 1 }, { x = 1, y = 1 }, { x = 0, y = 1 } }
    s.dir = state.DIRECTIONS.right
    state.tick(s)
    assert.is_true(s.game_over)
  end)

  it("ends the game when the head hits its own body", function()
    local s = state.new({ width = 10, height = 10, rng = fixed_rng(0.99) })
    -- head が1マス進んだ先(2,1)に、尾ではない体の一部(index4)がある配置
    s.snake = {
      { x = 2, y = 2 },
      { x = 1, y = 2 },
      { x = 1, y = 1 },
      { x = 2, y = 1 },
      { x = 3, y = 1 },
    }
    s.dir = state.DIRECTIONS.up
    state.tick(s)
    assert.is_true(s.game_over)
  end)

  it("grows and respawns food when the head reaches it", function()
    local s = state.new({ width = 10, height = 10, rng = fixed_rng(0) })
    s.food = { x = s.snake[1].x + 1, y = s.snake[1].y }
    state.tick(s)
    assert.are.equal(1, s.score)
    assert.are.equal(4, #s.snake)
    assert.is_not_nil(s.food)
  end)
end)
