local Super  = require("Assets.Entities.Animated.Enemies.enemy")
local Spawner = require("Assets.Entities.Animated.Enemies.spawner")
local Grid    = require("Assets.Scenes.MainGame.grid")

------------------------------------------------------------------------------------------------------------------------
-- Enemy --
------------------------------------------------------------------------------------------------------------------------
local Enemy = Class('splitting-enemy', Super)

Enemy.breed = "splitting"
Enemy.__aim = true
Enemy.__animationFile = require("Assets.Entities.Animated.Enemies.Splitting.animation")

local function getValidSpot(x, y, rotation)
  local dx, dy = math.legs(rotation, 8)
  local dist = .5

  while Grid.getCellByCoordinates(x+dx, y+dy) < 0 do
    dx = math.random()*dist
    dy = (dist-dx)*math.randomSign()
    dx = dx*math.randomSign()
    dist = dist+.15
  end

  return dx, dy
end

local toPi = math.pi/180

function Enemy:die(reachedGoal)
  if not reachedGoal then
    local selfRot = self.group.rotation
    for i = 1, 3   do
      local rot = (i-1)*32 +self.group.rotation

      local ox = self.group.x + math.sin((rot-selfRot)*toPi)*8 - math.sin(-selfRot*toPi)*3
      local oy = self.group.y + math.cos((rot-selfRot)*toPi)*8 - math.cos(-selfRot*toPi)*3

      local child = ObjectPool.getObject("splittingChild")
      local dx, dy = getValidSpot(ox, oy, rot)
      child:init{
        parent     = self.group.parent,
        controller = "default",
        level      = self.level,
        x          = ox,
        y          = oy,
        destX      = ox + dx,
        destY      = oy + dy,
        rotation   = rot,
      }
      Spawner.addFakeSpawn(child)
    end
  end
  Super.die(self, reachedGoal)
end


return Enemy
