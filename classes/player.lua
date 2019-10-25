object = require ("libraries/classic")
anim8 = require("libraries/anim8")
bump = require("libraries/bump")

player = object:extend()

function player:new(world)
  --SIZE AND POSITION--
  self.x = nil
  self.y = nil

  --SPRITES--
  self.spritesheet = love.graphics.newImage("sprites/spritesheet.png")
  self.baseFrame = love.graphics.newImage("sprites/4th_position.png")
  self.width = self.baseFrame:getWidth()
  self.height = self.baseFrame:getHeight()

  self.grid = anim8.newGrid(self.baseFrame:getWidth(), self.baseFrame:getHeight(), self.spritesheet:getWidth(), self.spritesheet:getHeight(), 0, 0, 1)
  self.stand = anim8.newAnimation(self.grid('1-1',1), 1)
  self.walk = anim8.newAnimation(self.grid('1-4',1), 0.15)
  self.crouch = anim8.newAnimation(self.grid('1-1',2), 1)
  self.jump = anim8.newAnimation(self.grid('2-2',2), 1)
  self.doublejump = anim8.newAnimation(self.grid('1-4',3), 0.15)
  self.sprint = anim8.newAnimation(self.grid('5-8',1), 0.05)
  self.sprintjump = anim8.newAnimation(self.grid('3-3',2), 1)

  self.activeSprite = stand

  --STATS--
  self.lives = 5
  self.health = 10

  --STATES--
  self.direction = -1 --Where -1 is right and 1 is left.
  self.state = "stand"
  self.isGrounded = true
  self.isAirborne = true
  self.canDoubleJump = true
  self.isSprint = false
  self.sprintTimer = 0

  --PHYSICS--
  self.x_velocity = 0
  self.y_velocity = 0
  self.jump_velocity = -4
  self.sprintjump_velocity = -5
  self.walk_speed = 1
  self.sprint_speed = 2
  self.gravity = 0.25
  self.friction = 0.1
end

function player:setLocation(x, y)
  self.x = x
  self.y = y
end

function player:movement(dt, canvas)
  --BASIC MOVEMENT--
  local goalY = self.y + self.y_velocity
  local goalX = self.x + self.x_velocity
  self.x, self.y, cols, len = world:move(player, goalX, goalY)




  --LANDING LOGIC--
  player.isAirborne = true

  for i, col in ipairs(cols) do
    if col.normal.y < 0 then
      if player.isGrounded == false then
        player.isGrounded = true
        player.state = "stand"
        player.x_velocity = 0
        player.canDoubleJump = true
      end
        player.y_velocity = 0
        player.isAirborne = false
    elseif col.normal.y > 0 then
      player.y_velocity = 0.25
    end
  end



  --GRAVITY LOGIC--
  self.y_velocity = self.y_velocity + self.gravity
  if player.y_velocity > 0.25 then
    player.isGrounded = false
  end

  --STATE TIMER--
  if player.sprintTimer > 0 then
    player.sprintTimer = player.sprintTimer - 1
  end
  if player.sprintTimer == 0 then
    if player.isSprint == true then
      player.isSprint = false
    end
    if player.isGrounded == true then
      player.state = "stand"
      player.x_velocity = 0
    end
  end

  --MOVE RIGHT--
  if love.keyboard.isDown("d") and player.state ~= "sprintjump" then
    --WALK RIGHT STATE LOGIC--
    if player.isGrounded == true then
      player.state = "walk"
      if player.isSprint == false then
        --TURNAROUND LOGIC--
        if player.direction == 1 then
          player.direction = -1
        end
        --WALK RIGHT MOVEMENT LOGIC--
        player.x_velocity = -player.walk_speed * player.direction
      end
    --[[elseif player.isGrounded == false and player.state == "doublejump" then
      --TURNAROUND LOGIC--
      if player.direction == 1 then
        player.direction = -1
      end
      --WALK RIGHT MOVEMENT LOGIC--
      player.x_velocity = -player.walk_speed * player.direction]]
    end
  end

  --MOVE LEFT--
  if love.keyboard.isDown("a") and player.state ~= "sprintjump" then
    --WALK LEFT STATE LOGIC--
    if player.isGrounded == true then
      player.state = "walk"
      if player.isSprint == false then
        --TURNAROUND LOGIC--
        if player.direction == -1 then
          player.direction = 1
        end
        --WALK LEFT MOVEMENT LOGIC--
        player.x_velocity = -player.walk_speed * player.direction
      end
    --[[elseif player.isGrounded == false and player.state == "doublejump" then
      --TURNAROUND LOGIC--
      if player.direction == -1 then
        player.direction = 1
      end
      --WALK LEFT MOVEMENT LOGIC--
      player.x_velocity = -player.walk_speed * player.direction]]
    end
  end


  --CROUCH--
  if love.keyboard.isDown("s") then
    if player.isGrounded == true then
      player.state = "crouch"
      if player.isSprint == true then
        player.isSprint = false
        player.sprintTimer = 0
      end
    end
  end

  --MORE STATE LOGIC DSFJGHSDSDKGHS--
  if player.state == "crouch" then
    player.x_velocity = 0
  end


  function  love.keypressed(key)
    --JUMP LOGIC--
    if key == "j" then
      if player.isGrounded == true then
        player.isGrounded = false
        if player.isSprint == false then
          player.y_velocity = player.jump_velocity
          player.state = "jump"
        else
          player.isSprint = false
          player.y_velocity = player.sprintjump_velocity
          player.state = "sprintjump"
          if player.direction == 1 then
            player.x_velocity = -player.sprint_speed
          else
            player.x_velocity = player.sprint_speed
          end
        end
      elseif player.isGrounded == false and player.canDoubleJump == true then
        player.y_velocity = player.jump_velocity
        if math.abs(player.x_velocity) > 1 then
          player.x_velocity = player.x_velocity/2
        end
        player.state = "doublejump"

        if love.keyboard.isDown("a") then
          if player.direction == -1 then
            player.direction = 1
          end
          player.x_velocity = -player.walk_speed * player.direction
        elseif love.keyboard.isDown("d") then
          if player.direction == 1 then
            player.direction = -1
          end
          player.x_velocity = -player.walk_speed * player.direction
        else player.x_velocity = 0
        end
        player.canDoubleJump = false
      end
    elseif key == "k" then
      if player.isGrounded == true and player.state == "walk" then
        player.isSprint = true
        player.sprintTimer = 30
        player.x_velocity = -player.sprint_speed * player.direction
      end
    end
  end

  function love.keyreleased(key)

    --WALK LOGIC--
    if player.state == "walk" and player.sprintTimer == 0 then
      if key == "a" or key == "d" then
        player.state = "stand"
        player.x_velocity = 0
      end
    end

    --CROUCH LOGIC--
    if player.state == "crouch" then
      if key == "s" then
        player.state = "stand"
      end
    end


  end

  --ANIMATED SPRITES--
  function player:animate()
    if player.state == "stand" then
      self.activeSprite = self.stand
    elseif player.state == "walk" then
      if player.isSprint == false then
        self.activeSprite = self.walk
      else
        self.activeSprite = self.sprint
      end
    elseif player.state == "crouch" then
      self.activeSprite = self.crouch
    elseif player.state == "jump" then
      self.activeSprite = self.jump
    elseif player.state == "doublejump" then
      self.activeSprite = self.doublejump
    elseif player.state == "sprintjump" then
      self.activeSprite = self.sprintjump
    end
  end

end

return player
