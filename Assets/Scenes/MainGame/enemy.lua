local Entity  = require("Assets.Entities.entity")

local Animation  = require("Assets.Scenes.MainGame.enemyAnimation")
local Bullet  = require("Assets.Scenes.MainGame.bullet")

-- ---------------------------------------------------------------------------------------------------------------------
-- Enemy object --
-- ---------------------------------------------------------------------------------------------------------------------
local Enemy = Class("enemy", Entity)
Enemy._inGameElement = true

local minAttackDelay = 1000
local maxAttackDelay = 15000

-- Initialization ------------------------------------------------------------------------------------------------------

function Enemy:create(params)
    Entity.create(self, params.parent, params.x, params.y)

    self.color = params.color
    self.isEnemy = true
    self.nextAttack = math.random(minAttackDelay, maxAttackDelay)

    self._animation = Animation:new(self.group, self.color)

    self.grid = params.grid
    self.grid:addObject(params.col, params.row, self)

    self:locateAt(params.col, params.row)

    game.time.subscribe(self)
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


function Enemy:attack()
    self.nextAttack = math.random(minAttackDelay, maxAttackDelay)

    Bullet:new{
        parent    = self.group.parent,
        source    = self,
        grid      = self.grid,
        x         = self.group.x,
        y         = self.group.y,
        direction = self.color == "white" and 1 or -1,
        color     = self.color
    }
end

function Enemy:takeDamage()
    self:die()
end

function Enemy:die()
    self:interrupt()

    self.isEssence = true
    self.isEnemy = false
    self._animation:turnEssence()

    self:performWithDelay(5000, function()
        self:heal()
    end)
end

function Enemy:enterFrame(timeElapsed)
    if self.isEnemy then
        self.nextAttack = self.nextAttack - timeElapsed
        if self.nextAttack <= 0 then
            self:attack()
        end
    end
end


function Enemy:heal()
    self.nextAttack = math.random(minAttackDelay, maxAttackDelay)
    self:interrupt()

    self.isEnemy = true
    self.isEssence = false
    self._animation:turnEnemy()
end

function Enemy:destroy()
    self:interrupt()

    game.time.unsubscribe(self)

    self.grid:removeObject(self.col, self.row)
    self.group:removeSelf()
end


return Enemy
