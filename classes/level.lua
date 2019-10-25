object = require ("libraries/classic")

level = object:extend()

function level:new(totalscreens)
  self.screen_count = totalscreens or 1
  self.screens = {}
end

function addScreen(screen)
  self.screens.insert(screen)
end


return level
