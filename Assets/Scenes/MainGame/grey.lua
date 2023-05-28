local Entity  = require("Assets.Entities.entity")

local Animation  = require("Assets.Scenes.MainGame.greyAnimation")

-- ---------------------------------------------------------------------------------------------------------------------
-- Grey object --
-- ---------------------------------------------------------------------------------------------------------------------
local Grey = Class("grey", Entity)
Grey._inGameElement = true

-- Initialization ------------------------------------------------------------------------------------------------------

function Grey:create(params)
    Entity.create(self, params.parent)

    self._animation = Animation:new(self.group)

    self.grid = params.grid

    self:locateAt(params.col, params.row)

    Runtime:addEventListener("key", self)
end


function Grey:init(params)

end



function Grey:locateAt(col, row)
    self.col = col
    self.row = row

    local cell = self.grid:getCell(col, row)
    self.group.x = cell.x
    self.group.y = cell.y
end

function Grey:move(dx, dy)
    local col = self.col + dx
    local row = self.row + dy

    if col < 1 or col > self.grid.numCols or row < 1 or row > self.grid.numRows then
        return
    end

    self:locateAt(col, row)
    --self._animation:dash()
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
    end
end


return Grey
