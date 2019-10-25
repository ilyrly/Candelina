object = require("libraries/classic")
anim8 = require("libraries/anim8")

animatedSprite = object:extend()

function animatedSprite:new(spritesheet, frameCount, frameWidth, frameHeight, x, y) --Takes: spritesheet file, total frames in animation, width of each frame, height of each frame, and x and y of starting frame.
  self.spritesheet = spritesheet
  self.frameCount = frameCount or 1
  self.frameWidth = width
  self.frameHeight = height
  self.frames = {}

  for frame = 1, frameCount do
    self.frames[frame] = love.graphics.newQuad(x + (frame - 1) * (1 + frameWidth), y, frameWidth, frameHeight, self.spritesheet:getWidth(), self.spritesheet:getHeight())
  end
end


return animatedSprite
