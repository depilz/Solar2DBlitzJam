local Entity  = require("Assets.Entities.entity")

local ObjectPool = ObjectPool

local BulletSpawner = Class("bulletSpawner", Entity)
local insert, remove = table.insert, table.remove

function BulletSpawner:initialize(parentTower, x, y, bulletType)
  Entity.initialize(self, parentTower.group, x, y)
  
  bulletType = bulletType or "basic"

  self.bullets = {}
  self._parentTower = parentTower
  self:setBulletType(bulletType)
end


function BulletSpawner:setTower(tower)
  self:setParent(tower.group)
  self._parentTower = tower
end



function BulletSpawner:clear(bulletType)
  for i = 1, #self.bullets do
    self.bullets[i]:clear()
  end
  self.bullets = {}
  Entity.clear(self)
end


return BulletSpawner