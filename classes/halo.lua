object = require("libraries/classic")
anim8 = require("libraries/anim8")

halo = object:extend()

function halo:new(scale)
  self.spritesheet = love.graphics.newImage("assets/halo/player_halo.png")
  self.scale = scale
  self.frame_width = 256
  self.frame_height = 240
  self.origin_x = self.frame_width/2
  self.origin_y = self.frame_height/2
  self.grid = anim8.newGrid(self.frame_width, self.frame_height, self.spritesheet:getWidth(), self.spritesheet:getHeight(),0,0,0)
  self.activeSprite = anim8.newAnimation(self.grid('1-3',1, '2-2',1), 0.4)
end

function halo:setScale(scale)
  self.scale = scale
end

return halo
