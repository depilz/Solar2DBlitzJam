local Entity  = require("Assets.Entities.entity")

-- local Animation  = require("Assets.Scenes.MainGame.bulletAnimation")

-- ---------------------------------------------------------------------------------------------------------------------
-- Bullet object --
-- ---------------------------------------------------------------------------------------------------------------------
local Bullet = Class("bullet", Entity)
Bullet._inGameElement = true

-- Initialization ------------------------------------------------------------------------------------------------------

function Bullet:create(params)
    Entity.create(self, params.parent, params.x, params.y)

    self.source = params.source
    self.grid = params.grid
    self.color = params.color

    -- self._animation = Animation:new(self.group)
    if params.color == "white" then
        self._animation = display.newImageRect(self.group, "Assets/Entities/Enemy/Light_Enemy_1_Attack.png", 40, 40)
    elseif params.color == "black" then
        self._animation = display.newImageRect(self.group, "Assets/Entities/Enemy/Dark_Enemy_1_Attack.png", 40, 40)
        self._animation.xScale = -1
    end

    self.speed = .5
    self.direction = params.direction

    game.time.subscribe(self)

    self:performWithDelay(8000, function()
        self:destroy()
    end)
end


function Bullet:doCollide(obj1, obj2)
    local bounds1 = {xMin = obj1.group.x - 20, xMax = obj1.group.x + 20, yMin = obj1.group.y - 20, yMax = obj1.group.y + 20}
    local bounds2 = {xMin = obj2.group.x - 20, xMax = obj2.group.x + 20, yMin = obj2.group.y - 20, yMax = obj2.group.y + 20}

    return bounds1.xMin < bounds2.xMax and bounds1.xMax > bounds2.xMin and
           bounds1.yMin < bounds2.yMax and bounds1.yMax > bounds2.yMin
end

function Bullet:move(dx)
    self.group.x = self.group.x + dx
    local col, row = self.grid:getCellByCoordinates(self.group.x, self.group.y)
    local obj = self.grid:getObject(col, row)

    if obj and obj ~= self.source and obj.essence ~= self.color and self:doCollide(self, obj) then
        obj:takeDamage()
        self:destroy()
    else
        if self.color == "white" then
            for _, enemy in pairs(_G.blacks) do
                if self:doCollide(self, enemy) then
                    enemy:takeDamage()
                    self:destroy()
                    break
                end
            end
        else
            for _, enemy in pairs(_G.whites) do
                if self:doCollide(self, enemy) then
                    enemy:takeDamage()
                    self:destroy()
                    break
                end
            end
        end
    end
end


function Bullet:enterFrame(timeElapsed)
    self:move(timeElapsed * self.speed * self.direction)
end

function Bullet:destroy()
    self:interrupt()
    game.time.unsubscribe(self)
    self.group:removeSelf()
    self.group = nil
end

return Bullet
