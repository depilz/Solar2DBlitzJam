local Super = require("Assets.Entities.entity")

local MapGroup        = require("Assets.Scenes.MainGame.map").middleGroup
local subscribeTime   = _G.game.time.subscribe
local unsubscribeTime = _G.game.time.unsubscribe

local sqrt = math.sqrt
local atan = math.atan2
local pi   = math.pi

------------------------------------------------------------------------------------------------------------------------
-- Bullet --
------------------------------------------------------------------------------------------------------------------------
local Bullet = Class("Bullet", Super)
Bullet._inGameElement = true

local bulletSizes = {
  basic         = {35*.7, 35*.7},
  sniper        = {20*.7, 17*.7},
  machineGun    = {10*1.2, 10*1.2},
  antiAir       = {70.892857143*.35, 40*.35},
}

function Bullet:initialize(bulletType)
  Super.initialize(self)

  self.bulletType = bulletType
  self._img = display.newImageRect(self.group, "Assets/Entities/Animated/Towers/Bullets/"..bulletType..".png", bulletSizes[bulletType][1], bulletSizes[bulletType][2])
end


function Bullet:init(parent, x, y, time)
  parent:insert(self.group)
  self:setPosition(x, y)
  self:_showUp(time)
end


function Bullet:_showUp(time)
  self.group.xScale, self.group.yScale = .05, .05

  self._ready = false
  self:transitionTo{
    time       = time or 100,
    xScale     = 1,
    yScale     = 1,
    transition = easing.outBack,
    onComplete = function()
      self._ready = true
    end
  }

end


function Bullet:isReady()
  return self._ready
end


function Bullet:aim(target, distance2)
  local d = math.min(distance2/90000, 1)

  local dX, dY = target:localToWorld(0, 0, self.group.parent)
  local ang = atan(dY, dX)/pi*180

  self.group.rotation = self.group.rotation*d + ang*(1-d)
end


function Bullet:fire(target, damage)
  self._target    = target
  self._damage    = damage
  self._speed     = .6
  self:setParent(MapGroup)
  target:addEventListener("died", self)

  subscribeTime(self)
end


function Bullet:_updatePosition(time, total)
  local dX, dY = self._target.group.x - self.group.x, self._target.group.y - self.group.y

  local targetDistance = sqrt(dX*dX+dY*dY)

  local delta = self._speed*time/targetDistance

  if delta >= 1 then
    self._target:takeDamage(self._damage)
    self:explode()

  else
    self.group.rotation = self.group.rotation*.7 + atan(dY, dX)*.3/pi*180
    self.group.x, self.group.y = self.group.x+dX*delta, self.group.y+dY*delta

  end
end


function Bullet:enterFrame(time, total)
  self:_updatePosition(time, total)
end


function Bullet:died(e) -- Target Died
  self:vanish()
end


function Bullet:vanish()
  if not self._target then return end
  unsubscribeTime(self)
  self._target:removeEventListener("died", self)
  self._target = nil

  self:transitionTo{
    time     = 150,
    alpha    = 0,
    onCancel = function()
      self:clear()
    end,
    onComplete = function()
      self:clear()
    end
  }
end


function Bullet:explode()
  if not self._target then return end
  unsubscribeTime(self)
  self._target:removeEventListener("died", self)
  self._target = nil
  self:clear()
end


function Bullet:stop()
  unsubscribeTime(self)
  Super.stop(self)
end


return Bullet