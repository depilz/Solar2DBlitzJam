local Entity  = require("Assets.Entities.entity")

local Animation  = require("Assets.Scenes.MainGame.greyAnimation")

local Bullet  = require("Assets.Scenes.MainGame.bullet")

-- ---------------------------------------------------------------------------------------------------------------------
-- Grey object --
-- ---------------------------------------------------------------------------------------------------------------------
local Grey = Class("grey", Entity)
Grey._inGameElement = true
Grey.maxHealth = 100

-- Initialization ------------------------------------------------------------------------------------------------------

function Grey:create(params)
    Entity.create(self, params.parent)

    self._animation = Animation:new(self.group)

    self.grid = params.grid

    self.col = params.col
    self.row = params.row

    local cell = self.grid:getCell(self.col, self.row)
    self.group.x = cell.x
    self.group.y = cell.y

    self.health = self.maxHealth

    self.grid:moveObject(self.col, self.row, self.col, self.row)

    Runtime:addEventListener("key", self)
end


function Grey:collectEssence()
    local essence = self.grid:getObject(self.col, self.row)
    essence:destroy()
    
    self.essence = essence.color
end

function Grey:takeDamage()
    if not self.essence then return end

    self.health = self.health - 10
    if self.health <= 0 then
        self:die()
    end
end

function Grey:attack()
    self._animation:dash()

    if not self.essence then return end

    Bullet:new{
        parent    = self.group.parent,
        source    = self,
        grid      = self.grid,
        x         = self.group.x,
        y         = self.group.y,
        color     = self.essence,
        direction = self.essence == "white" and 1 or -1
    }

    self.essence = nil
end


function Grey:heal()
    if not self.essence then return end

    self.health = self.health + 10

    self.essence = nil
end

function Grey:locateAt(col, row)
    if not self.grid:doesCellExist(col, row) then return false end

    local object = self.grid:getObject(col, row)
    if object and (
        object.isEnemy or
        object.isEssence and self.essence
    ) then return false end

    self.col = col
    self.row = row

    local cell = self.grid:getCell(col, row)
    self.group.x = cell.x
    self.group.y = cell.y

    self.grid:moveObject(self.col, self.row, col, row)

    if object and object.isEssence then
        self:collectEssence()
    end

    return true
end

function Grey:move(dx, dy)
    local col = self.col + dx
    local row = self.row + dy

    return self:locateAt(col, row)
end


-- Listen to key events -------------------------------------------------------------------------------------------------

function Grey:key(e)
    if e.phase == "up" then return end

    if e.keyName == "left" then
        self:move(-1, 0)
    elseif e.keyName == "right" then
        self:move(1, 0)
    elseif e.keyName == "up" then
        self:move(0, -1)
    elseif e.keyName == "down" then
        self:move(0, 1)
    elseif e.keyName == "a" then
        self:attack()
    elseif e.keyName == "h" then
        self:heal()
    end

end


return Grey
