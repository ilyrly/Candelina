object = require("libraries/classic")
anim8 = require("libraries/anim8")

player = require("classes/player")

flame = object:extend()

function flame:new(player)
  self.x = player.x + 10
  self.y = player.y - 6

  --GRID CONSTRUCTOR--
  self.spritesheet = love.graphics.newImage("sprites/particles.png")
  self.frame_size = 20
  self.grid = anim8.newGrid(self.frame_size, self.frame_size, self.spritesheet:getWidth(), self.spritesheet:getHeight(), 0, 0, 1)

  --ANIMATION CONSTRUCTORS--
  self.stationary = anim8.newAnimation(self.grid('1-2', 2), 0.15)
  self.moving = anim8.newAnimation(self.grid('1-2', 1), 0.15)
  self.moving_walk = anim8.newAnimation(self.grid('3-4', 1), 0.15)
  self.moving_sprint = anim8.newAnimation(self.grid('1-6', 3), 0.05)

  --DEFAULT ACTIVE SPRITE--
  self.activeSprite = self.stationary
end


function flame:track()

  --FLAME DIRECTION LOGIC--
  if player.x_velocity ~= 0 then
    if player.state == "walk" and player.isSprint == false then
      self.activeSprite = self.moving_walk
    elseif player.state == "walk" and player.isSprint == true then
      self.activeSprite = self.moving_sprint
    else
      self.activeSprite = self.moving
    end
  else
    self.activeSprite = self.stationary
  end

  --FLAME OFFSET LOGIC--
  if player.state == "stand" then
    self.y = player.y - 6
    if player.direction == -1 then
      self.x = player.x + 10
    else
      self.x = player.x + 6
    end
  elseif player.state == "walk" then
    self.y = player.y - 7
    if player.isSprint == false then
      if player.direction == -1 then
        self.x = player.x + 10
      else
        self.x = player.x + 6
      end
    elseif player.isSprint == true then
      if player.direction == -1 then
        self.x = player.x + 11
      else
        self.x = player.x + 5
      end
    end
  elseif player.state == "crouch" then
    self.y = player.y - 4
    if player.direction == -1 then
      self.x = player.x + 10
    else
      self.x = player.x + 6
    end
  elseif player.state == "jump" then
    self.y = player.y - 6
    if player.direction == -1 then
      self.x = player.x + 10
    else
      self.x = player.x + 6
    end
  elseif player.state == "doublejump" then
    self.y = player.y - 6
    if player.direction == -1 then
      self.x = player.x + 10
    else
      self.x = player.x + 6
    end
  elseif player.state == "sprintjump" then
    self.y = player.y - 2
    if player.direction == -1 then
      self.x = player.x + 10
    else
      self.x = player.x + 6
    end
  end
end


return flame
