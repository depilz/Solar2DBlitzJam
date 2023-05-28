local Entity  = require("Assets.Entities.entity")

local Animation  = require("Assets.Scenes.MainGame.enemyAnimation")

-- ---------------------------------------------------------------------------------------------------------------------
-- Enemy object --
-- ---------------------------------------------------------------------------------------------------------------------
local Enemy = Class("enemy", Entity)
Enemy._inGameElement = true

-- Initialization ------------------------------------------------------------------------------------------------------

function Enemy:create(params)
    Entity.create(self, params.parent, params.x, params.y)

    self.color = params.color

    self._animation = Animation:new(self.group, self.color)

    self.grid = params.grid
    self.grid:addObject(params.col, params.row, self)

    self:locateAt(params.col, params.row)
end


function Enemy:init(params)

end


function Enemy:locateAt(col, row)
    self.col = col
    self.row = row

    local cell = self.grid:getCell(col, row)
    self.group.x = cell.x
    self.group.y = cell.y

    return true
end

function Enemy:move(dx, dy)
    local col = self.col + dx
    local row = self.row + dy

    return self:locateAt(col, row)
end


function Enemy:die()
    self._animation:turnEssence()
end


function Enemy:heal()
    self._animation:turnEnemy()
end



return Enemy
