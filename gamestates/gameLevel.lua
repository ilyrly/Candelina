player = require ("classes/player")
player_flame = require ("classes/flame")
dynamic_ui = require ("classes/ui")
halo = require ("classes/halo")
camera = require("classes/camera")

sti = require("libraries/sti")
Gamestate = require("libraries/hump/gamestate")
Timer = require("libraries/hump/timer")
bump = require("libraries/bump")

gameLevel = Gamestate.new()

world = nil


function gameLevel:enter()

  --WINDOW SETTINGS--
  screen_width = 256
  screen_height = 240
  window_scale = 3.25 --This is the factor that the original canvas will be scaled by.
  tile_size = 16 --The width and height, in pixels, of each tile.
  love.window.setMode((window_scale*screen_width), (window_scale*screen_height), {msaa=0, fullscreentype="desktop", centered="true"}) --The original window is 256x240, consistent with NES screen size. It must be upscaled to be visible.
  love.window.setFullscreen(false)
  love.graphics.setDefaultFilter("nearest", "nearest", 0) --Filter is set to "nearest neighbor" to avoid blurring as the pixel art is upscaled.
  love.window.setTitle("Candelina (Pre-Alpha)")

  canvas = love.graphics.newCanvas(screen_width*2, screen_height)
  overlay = love.graphics.newCanvas(screen_width*2, screen_height)
  parallax = love.graphics.newCanvas(screen_width, screen_height)
  ui = love.graphics.newCanvas(screen_width, tile_size*3)
  master_canvas = love.graphics.newCanvas(screen_width*2, screen_height)

  --SETUP BUMP--
  world = bump.newWorld(tile_size)

  --SETUP MAP--
  map = sti("levels/level_0b/level_0b.lua", {"bump"})
  background = love.graphics.newImage("levels/level_0b/library_background_2.png")
  map:bump_init(world)

  --SETUP CAMERA--
  camera = camera()

  --PLAYER CONSTRUCTOR--
  player = player(world)
  spawn_x = tile_size*5
  spawn_y = canvas:getHeight()-tile_size*5
  player:setLocation(spawn_x, spawn_y)
  world:add(player, player.x+3, player.y, player.width-3, player.height)

  --FLAME CONSRUCTOR--
  player_flame = flame(player)
  player_halo = halo(1)

  --UI CONSTRUCTOR--
  dynamic_ui = level_ui(player)
  dynamic_ui:doLevelTimer()

  font = love.graphics.newFont("assets/yoster.ttf", 12)
end

function gameLevel:update(dt)
  --HALO AND TIMER--
  dynamic_ui.levelTimer:update(dt * dynamic_ui.timer_rate)
  player_halo:setScale(dynamic_ui.seconds_remaining/dynamic_ui.seconds_init)

  if dynamic_ui.seconds_remaining <= 2/3*(dynamic_ui.seconds_init) then
    dynamic_ui.activeSprite = dynamic_ui.medium_flame
  end
  if dynamic_ui.seconds_remaining <= 1/3*(dynamic_ui.seconds_init) then
    dynamic_ui.activeSprite = dynamic_ui.small_flame
  end
  if dynamic_ui.seconds_remaining <= 0 then
    dynamic_ui.activeSprite = dynamic_ui.no_flame
  end

  --DECREMENT TIMER FASTER WHILE SPRINTING--
  if player.isSprint == true then
    dynamic_ui.timer_rate = dynamic_ui.timer_rate + dynamic_ui.timer_rate * 0.1
  elseif player.isSprint == false then
    dynamic_ui.timer_rate = 1
  end

  --PLAYER MOVEMENT AND ANIMATION--
  player:movement(dt, canvas)
  player:animate()
  player.activeSprite:update(dt)

  player_flame:track()
  player_flame.activeSprite:update(dt)
  player_halo.activeSprite:update(dt)

  dynamic_ui.activeSprite:update(dt)

  --CAMERA SCROLLING--
  camera:setPosition(player.x-(screen_width/2), camera._y)
  camera:setBounds(0, 0, screen_width, screen_height)
end

function gameLevel.draw()
  --PARALLAX CANVAS--
  love.graphics.setCanvas(parallax)
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(background)
  love.graphics.setCanvas()


  --GAMEWORLD CANVAS--
  love.graphics.setCanvas(canvas)
    --CANVAS LOGIC--
    love.graphics.clear()
    love.graphics.setColor(1, 1, 1, 1)
    --BACKGROUND LOGIC--
    map:draw()
    --PLAYER LOGIC--
    if player.direction == -1 then
      player.activeSprite:draw(player.spritesheet, player.x+player.width, player.y, 0, player.direction, 1)
    end
    if player.direction == 1 then
      player.activeSprite:draw(player.spritesheet, player.x, player.y, 0, player.direction, 1)
    end
    --FLAME LOGIC--
    player_flame.activeSprite:draw(player_flame.spritesheet, player_flame.x, player_flame.y, 0, player.direction, 1)
  love.graphics.setCanvas()

  --OVERLAY CANVAS--
  love.graphics.setCanvas(overlay)
    love.graphics.clear()
    player_halo.activeSprite:draw(player_halo.spritesheet, player.x + player.width/2, player.y + player.height/2, 0, player_halo.scale, player_halo.scale, player_halo.origin_x, player_halo.origin_y)
  love.graphics.setCanvas()

  --UI CANVAS--
  love.graphics.setCanvas(ui)
    love.graphics.clear()
    love.graphics.setColor(1,1,1)
    love.graphics.draw(dynamic_ui.background)
    dynamic_ui.activeSprite:draw(dynamic_ui.flame_spritesheet, dynamic_ui.flame_x, dynamic_ui.flame_y)
    love.graphics.draw(dynamic_ui.capsule, dynamic_ui.capsule_x, dynamic_ui.capsule_y)
    love.graphics.setFont(font)
    love.graphics.printf(dynamic_ui.seconds_remaining, -18, 13, 52, "right")
    love.graphics.printf({"Lives: ", player.lives}, 175, 13, 68, "right")
    --love.graphics.printf("03-a", 190, 25, 52, "right")
    --love.graphics.printf(tostring(player.isAirborne), 190, 25, 52, "right")
  love.graphics.setCanvas()

  --MASTER CANVAS--
  love.graphics.setCanvas(master_canvas)
    love.graphics.draw(parallax)
    camera:set()
    love.graphics.setBlendMode("alpha")
    love.graphics.draw(canvas)
    love.graphics.setBlendMode("multiply", "premultiplied")
    love.graphics.draw(overlay)
    camera:unset()
    love.graphics.setBlendMode("alpha")
    love.graphics.draw(ui)
  love.graphics.setCanvas()
  love.graphics.scale(window_scale, window_scale)
  love.graphics.draw(master_canvas)
  --love.graphics.draw(master_canvas, (384-screen_width)/2)


end

function math.clamp(x, min, max)
  if x < min then
    return min
  elseif x > max then
    return max
  else
    return x
  end
end

return gameLevel
