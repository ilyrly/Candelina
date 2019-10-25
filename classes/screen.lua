object = require ("libraries/classic")

screen = object:extend()

function screen:new(length, background, leftNeighbor, rightNeighbor)
  self.width = 16*length
  self.height = 15
  self.background = background or nil
  self.neighbor_left = leftNeighbor or nil
  self.neighbor_right = rightNeighbor or nil

  --Collision map constructor--
  self.map = {}
  for row = 1, self.width do
    local column = {}
    self.map[row] = column
  end

end

function addTiles(world, x1, y1, x2, y2)
  for col = x1, x2 do
    for row = y1, y2 do
      self.map[col][row] = "tile"
      world:add({}, col*tile_size-tile_size, row*tile_size-tile_size, tile_size, tile_size)
    end
  end
end

function addNeighbor(side, screen)
  if side == "left" then
    self.neighbor_left = screen
  elseif side == "right" then
    self.neigbor_right = screen
  end
end

function drawTiles(tile)
  for col = x1, x2 do
    for row = y1, y2 do
      if screen.map[col][row] == "tile" then
        love.graphics.draw(tile, col*tile_size-tile_size, row*tile_size-tile_size)
      end
    end
  end
end

return screen
