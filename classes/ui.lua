object = require ("libraries/classic")
anim8 = require("libraries/anim8")
Gamestate = require("libraries/hump/gamestate")
Timer = require("libraries/hump/timer")

level_ui = object:extend()

function level_ui:new(player)
  --PLAYER--
  self.player = player

  --GRAPHICS--
  self.background = love.graphics.newImage("assets/ui/background.png")
  self.capsule = love.graphics.newImage("assets/ui/capsule.png")
  self.capsule_x = 36
  self.capsule_y = 12
  self.tick = love.graphics.newImage("assets/ui/tick.png")

  --FLAME ANIMATIONS--
  self.flame_spritesheet = love.graphics.newImage("assets/ui/flame_spritesheet.png")
  self.frame_size = 16
  self.grid = anim8.newGrid(self.frame_size, self.frame_size, self.flame_spritesheet:getWidth(), self.flame_spritesheet:getHeight(), 0, 0, 0)

  self.flame_x = 40
  self.flame_y = 16
  self.large_flame = anim8.newAnimation(self.grid('1-3', 1, '2-2', 1), 0.15)
  self.medium_flame = anim8.newAnimation(self.grid('1-3', 2, '2-2', 2), 0.15)
  self.small_flame = anim8.newAnimation(self.grid('1-3', 3, '2-2', 3), 0.15)
  self.no_flame = anim8.newAnimation(self.grid('1-1', 4), 0.15)
  self.activeSprite = self.large_flame

  --TIMER--
  self.levelTimer = Timer.new()
  self.timer_rate = 1
  self.seconds_init = 60
  self.seconds_remaining = self.seconds_init
end

function level_ui:doLevelTimer()
  if self.seconds_remaining > 0 then
    self.levelTimer:every(1, function() self.seconds_remaining = self.seconds_remaining - 1 end, self.seconds_init)
  end
end

return ui
