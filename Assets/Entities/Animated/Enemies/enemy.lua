local Animated  = require("Assets.Entities.Animated.animated")

local AnimatedText = require("Utils.animatedText")
local Grid = require("Assets.Scenes.MainGame.grid")

local sqrt = math.sqrt

------------------------------------------------------------------------------------------------------------------------
-- Enemy --
------------------------------------------------------------------------------------------------------------------------
local Enemy = Class('enemy', Animated)

local Stats = require("Configs.enemies")

Enemy.__controllers = {
  default = "Assets.Entities.Animated.Enemies.controller",
}

Enemy.__sfx = {
  death = {"death1", "death2", "death3", "death4", "death5"},
}

function Enemy:init(params)
  Animated.init(self, params)

  self.isAttackable = true
  self._animation:showUp()
end


function Enemy:isAerial()
  return Stats[self.breed].isAerial
end


function Enemy:getSpeed()
  return Stats[self.breed].speed
end


function Enemy:idle()
  if not self:_canGotoState("idle") then return false end

  assert(self:gotoState("idle"), "Something went wrong here: "..(self._state:getValue("state") or "nil"))

  return true
end


function Enemy:isAlive()
  return self:_getStatsValue("hp") > 0
end


function Enemy:dropPoints(points)
  if not points or points == 0 then return false end

  game.levelState:add("points", points)
  AnimatedText.new{
    parent   = self.group.parent,
    text     = points.." ".."pts",
    x        = self.group.x,
    y        = self.group.y,

    font     = "Arial Rounded Bold",
    fontSize = 25,
    color1   = { 1,.25,0,1},
    color2   = { 1,.95,0,1},

    animate  = true,
  }

  return true
end


function Enemy:moveTo(x, y, onComplete)
  self:_cancel("walk")

  local dX, dY = x-self.group.x, y-self.group.y
  local t = sqrt(dX*dX + dY*dY)/self:getSpeed()
    self:transitionTo{
      tag           = "walk",
      time          = t,
      x             = x,
      y             = y,
      -- transition    = easing.inOutQuad,
      onComplete    = onComplete
    }

  if not self._avoidWalkRotation then
    local rotation = math.getAngle(dX, dY)+90
    self:transitionTo{
      tag           = "walk",
      time          = t*.12,
      rotation      = math.getClosestEquivalentAngle(self.group.rotation, rotation),
      transition    = easing.inOutQuad,
    }
  end
end


-- Enemy -----------------------------------------------------------------------------------------------------------

function Enemy:rotate(angle)
  self._angle = self._angle or angle
  self._destAngle = angle
end


function Enemy:getRotation()
  return self._angle
end


function Enemy:_updateRotation(time)
  local angle1 = self._angle
  local angle2 = math.getClosestEquivalentAngle(angle1, self._destAngle)
  local direction = angle2 > angle1 and 1 or -1
  local movSpeed = self:getSpeed()


  local angleSpeed = math.pow(angle2-angle1, 2)*direction*movSpeed*.001*time
  local isAccelerating = math.abs(angleSpeed) > math.abs(self._angleSpeed)
  local stepLimit = (isAccelerating and 3.5 or 5)*time*movSpeed
  angleSpeed = self._angleSpeed+math.clamp(angleSpeed-self._angleSpeed, -stepLimit, stepLimit)

  self._angleSpeed = angleSpeed
  self._angle = (self._angle+angleSpeed)%360

  local accDelta = isAccelerating and -.00001*time or .00001*time
  self._movementDeacceleration = math.clamp(self._movementDeacceleration+accDelta, 0, movSpeed*.5)

  if self.__aim then
    self.group.rotation = self._angle+90
  end
end


function Enemy:_getRightSpeed(dx, dy)
  if self:isAerial() then return 1 end

  local slowDown
  if Grid.getCellByCoordinates(self.group.x, self.group.y) < 0 then
    slowDown = slowDown or Grid.getCellByCoordinates(self.group.x+dx, self.group.y+dy)       >= 0 and 1
    slowDown = slowDown or Grid.getCellByCoordinates(self.group.x+dx*3, self.group.y+dy*3)   >= 0 and 1.5
    slowDown = slowDown or Grid.getCellByCoordinates(self.group.x+dx*6, self.group.y+dy*6)   >= 0 and 3
    slowDown = slowDown or 0
  else
    slowDown = slowDown or Grid.getCellByCoordinates(self.group.x+dx*5, self.group.y+dy*5)   < 0 and 0
    slowDown = slowDown or Grid.getCellByCoordinates(self.group.x+dx*9, self.group.y+dy*9)   < 0 and .06
    slowDown = slowDown or Grid.getCellByCoordinates(self.group.x+dx*12, self.group.y+dy*12) < 0 and .15
    slowDown = slowDown or Grid.getCellByCoordinates(self.group.x+dx*18, self.group.y+dy*18) < 0 and .5
    slowDown = slowDown or Grid.getCellByCoordinates(self.group.x+dx*23, self.group.y+dy*23) < 0 and .85

    slowDown = slowDown or Grid.getCellByCoordinates(self.group.x-dx*1, self.group.y-dy*1)   < 0 and 8
    slowDown = slowDown or Grid.getCellByCoordinates(self.group.x-dx*3, self.group.y-dy*3)   < 0 and 5
    slowDown = slowDown or Grid.getCellByCoordinates(self.group.x-dx*6, self.group.y-dy*6)   < 0 and 2
    slowDown = slowDown or Grid.getCellByCoordinates(self.group.x-dx*12, self.group.y-dy*12)   < 0 and 1.3
    slowDown = slowDown or Grid.getCellByCoordinates(self.group.x-dx*25, self.group.y-dy*25) < 0 and 1.08
  end

  return slowDown or 1
end


function Enemy:_updatePosition(time)
  local speed = math.max(self:getSpeed()-self._movementDeacceleration, .005)
  local dx = math.cos(self._angle*math.pi/180)*speed*time
  local dy = math.sin(self._angle*math.pi/180)*speed*time

  local speedDelta = self:_getRightSpeed(dx, dy)

  self.group.x = self.group.x + dx*speedDelta
  self.group.y = self.group.y + dy*speedDelta

  local angle1 = self._angle
  local angle2 = math.getClosestEquivalentAngle(angle1, self._destAngle)

  if speedDelta < .8 and math.abs(angle2-angle1) <= 20 then
    self._controller:updatePath()
  end
end


function Enemy:enterFrame(time, total)
  self:_updateRotation(time)
  self:_updatePosition(time)
  Animated.enterFrame(self, time, total)
end


function Enemy:_canGotoState(state)
  if self._state:getValue("state") == state then return false end

  if state == nil then
    return true

  elseif state == "idle" then
    return self:isAlive()

  elseif state == "moving" then
    return self:isAlive()

  elseif state == "dead" then
    return self:isAlive()

  end

  error("unknown state "..state.." for "..self.class.name)
end


function Enemy:move()
  if not self:_canGotoState("moving") then return false end

  assert(self:gotoState("moving"), "Something went wrong here: "..(self._state:getValue("state") or "nil"))

  return true
end


function Enemy:die(reachedGoal)
  self.isAttackable = false

  if reachedGoal then
    Runtime:dispatchEvent{ name = "goalReached", target = self }
    self:playSound("death")
  else
    self:playSound("death")
  end

  self:dispatchEvent{ name = "died", target = self}

  if reachedGoal then
    self._animation:playAnimation("reachedGoal", {
      onComplete = function()
        self:clear()
      end
    })

  else
    self:dropPoints(Stats[self.breed].rewardPoints)
    self._animation:playAnimation("death", {
      onComplete = function()
        self:clear()
      end
    })
  end
end


function Enemy:_getStatsValue(value)
  local ret = Stats[self.breed][value]
  return type(ret) == "function" and ret(self.level) or ret
end


function Enemy:hardReset()
  self.isAttackable = false
  self._hp = self:_getStatsValue("hp")
  self._angle = nil
  self._angleSpeed = 0
  self._movementDeacceleration = 0
end


function Enemy:clear()
  if not self._initialized then return false end
  self:dispatchEvent{ name = "died", target = self}
  self._initialized = false
  Animated.clear(self)
end


return Enemy
