local Map = require("Assets.Scenes.MainGame.map")
local cellSize = _G.cellSize
---------------------------------------------------------------------------------------------------------------------------------------

local Controller = Class("towerController")

function Controller:initialize(entity)
  self._entity = entity
end


function Controller:start()
  _G.game.time.subscribe(self)
end


function Controller:enterFrame()
  local tower        = self._entity
  if not tower.charged then return end
  local selfX, selfY = tower.group.x, tower.group.y
  local enemies      = Map.getSortedEnemies(selfX, selfY)

  local range = tower.stats.implosionRange*tower.stats.implosionRange*cellSize*cellSize

  local i = 1
  while enemies[i] do
    local enemy = enemies[i][1].object
    if enemies[i][2] <= range and enemy.isAttackable and not enemy:isAerial() then
      i = i + 1
    else
      table.remove(enemies, i)
    end
  end

  if #enemies > 0 then
    tower:implode(enemies)
  end
end


function Controller:stop()
  _G.game.time.unsubscribe(self)
end


return Controller
