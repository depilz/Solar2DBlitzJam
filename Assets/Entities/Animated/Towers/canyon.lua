local Entity = require("Assets.Entities.entity")

local Map = require("Assets.Scenes.MainGame.map")
local Grid = require("Assets.Scenes.MainGame.grid")
local rayCast = Grid.rayCast
local cellSize = _G.cellSize

------------------------------------------------------------------------------------------------------------------------
-- Canyon --                                                                                                           --
------------------------------------------------------------------------------------------------------------------------
local Canyon = Class('tower-canyon', Entity)
Canyon._inGameElement = true

Canyon.__sfx = {
  fire = {"fire"},
}


-- Creation ------------------------------------------------------------------------------------------------------------

function Canyon:create(...)
  Entity.create(self, ...)
  self._bullets = {}
end


function Canyon:init()
  self._initialized = true
  self._active = true

  self._stats = {
    range  = 0,
    damage = 0,
    rps    = 0,
  }

  self:setBulletVisual("basic")
  self:_spawnWithDelay(400)

  _G.game.time.subscribe(self)
end


function Canyon:setBulletVisual(bulletType)
  if self.bulletType == bulletType then return end
  self.bulletType = bulletType

  for i = #self._bullets, 1, -1 do
    table.remove(self._bullets, i):clear()
    self:_spawnBullet()
  end
end


function Canyon:setRange(range)
  self._stats.range = range
end


function Canyon:setDamage(damage)
  self._stats.damage = damage
end


function Canyon:setRPS(rps)
  self._stats.rps = rps
end


function Canyon:setAntiAir(bool)
  self._stats.isAntiAir = bool
end


-- Actions -------------------------------------------------------------------------------------------------------------

function Canyon:canShoot()
  return #self._bullets > 0 and self._bullets[1]:isReady()
end


function Canyon:fire(target)
  if not self:canShoot() then return false end

  local bullet = table.remove(self._bullets, 1)
  bullet:fire(target, self._stats.damage)

  self:playSound("fire")

  local cycleTime = 1000/self._stats.rps
  local bulletSpawnTime = math.min(cycleTime, 500)
  local delay = math.max(cycleTime - bulletSpawnTime, 0)
  self:_spawnWithDelay(delay)

  return true
end


function Canyon:_spawnWithDelay(delay)
  if self._spawnTask then
    self._spawnTask:cancel()
    self._spawnTask = nil
  end

  self._spawnTask = self:performWithDelay(delay, function()
    self:_spawnBullet()
  end)
end


function Canyon:_spawnBullet()
  if self._spawnTask then
    self._spawnTask:cancel()
    self._spawnTask = nil
  end


  local bullet = ObjectPool.getObject(self.bulletType.."Bullet")

  local cycleTime = 1000/self._stats.rps
  local bulletSpawnTime = math.min(cycleTime, 500)

  bullet:init(self.group, 0, 0, bulletSpawnTime)

  self._bullets[#self._bullets+1] = bullet
end


function Canyon:enterFrame()
  if not self._active or not self:canShoot() then return end

  local tower        = self.group.parent.object
  local selfX, selfY = tower.group.x, tower.group.y
  local enemies      = Map.getSortedEnemies(selfX, selfY)

  local range = (self._stats.range*cellSize)^2

  for i = 1, #enemies do
    local e = enemies[i][1]

    if enemies[i][2] <= range
    and (self._stats.isAntiAir or not e.object:isAerial())
    and (e.object:isAerial() or rayCast(selfX/cellSize, selfY/cellSize, e.x/cellSize, e.y/cellSize, -1))
    then
      self:fire(e.object)
      break
    end
  end
end


function Canyon:isActive()
  return self._active
end


function Canyon:activate()
  if self._active then return false end
  self._active = true

  self:_spawnBullet()
end


function Canyon:deactivate()
  if not self._active then return false end
  self._active = false

  self:_clearBullets()
end


-- Upgrading --------------------------------------------------------------------------------------------

function Canyon:_clearBullets()
  for i = #self._bullets, 1, -1 do
    table.remove(self._bullets, i):clear()
  end
end

--- Destroying --------------------------------------------------------------------------------------------

function Canyon:hardReset()
  Entity.hardReset(self)
  self._active = false
  self:_clearBullets()
  self.bulletType = nil
end


function Canyon:stop()
  _G.game.time.unsubscribe(self)
  if self._spawnTask then
    self._spawnTask:cancel()
    self._spawnTask = nil
  end
  self._initialized = false
  Entity.stop(self)
end


return Canyon