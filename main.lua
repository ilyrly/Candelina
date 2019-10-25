
Gamestate = require 'libraries/hump/gamestate'

local gameLevel1 = require 'gamestates/gameLevel'

function love.load()
  Gamestate.registerEvents()
  Gamestate.switch(gameLevel1)


end

function love.keypressed(key)
  if key == "escape" then
    love.event.push("quit")
  end
end
