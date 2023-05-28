local Entity  = require("Assets.Entities.entity")

-- ---------------------------------------------------------------------------------------------------------------------
-- Grid object --
-- ---------------------------------------------------------------------------------------------------------------------
local Grid = Class("grid", Entity)
Grid._inGameElement = true

-- Initialization ------------------------------------------------------------------------------------------------------

function Grid:create(params)
    Entity.create(self, params.parent, params.x, params.y)

    self.numCols = params.columns
    self.numRows = params.rows

    local cellWidth = params.width / params.columns
    local cellHeight = params.height / params.rows

    self._rows = {}
    self._objects = {}
    local ox = -(params.columns - 1) * cellWidth / 2
    local oy = -(params.rows - 1) * cellHeight / 2

    for r = 1, params.rows do
        self._rows[r] = {}
        self._objects[r] = {}
        for c = 1, params.columns do
            self._rows[r][c] = display.newRect(self.group, 0, 0, cellWidth - 3, cellHeight- 3)
            self._rows[r][c].x = (c-1) * cellWidth -3 + ox
            self._rows[r][c].y = (r-1) * cellHeight -3 + oy

            Runtime:addEventListener("enterFrame", function()
                self._rows[r][c]:setFillColor(0.5, 0.2, 0.5)
                if self._objects[r][c] then
                    if self._objects[r][c].isEnemy then
                        self._rows[r][c]:setFillColor(0.2, 0.5, 0.5)
                    elseif self._objects[r][c].isPlayer then
                        self._rows[r][c]:setFillColor(0.5, 0.2, 0.2)
                    elseif self._objects[r][c].isEssence then
                        self._rows[r][c]:setFillColor(0.5, 0.5, 0.2)
                    end
                end
            end)
        end
    end
end


function Grid:addObject(col, row, object)
    self._objects[row][col] = object

    self._rows[row][col]:setFillColor(0.2, 0.5, 0.2)
end


function Grid:removeObject(col, row)
    self._objects[row][col] = nil
end


function Grid:moveObject(fromCol, fromRow, toCol, toRow)
    if not (self._rows[toRow] or {})[toCol] or self._objects[toRow][toCol] then return false end

    self._objects[toRow][toCol] = self._objects[fromRow][fromCol]
    self._objects[fromRow][fromCol] = nil

end

function Grid:getCell(col, row)
    return self._rows[row][col]
end

function Grid:doesCellExist(col, row)
    return self._rows[row] and self._rows[row][col]
end

function Grid:getCellByCoordinates(x, y)
    local cellWidth = self.group.width / self.numCols
    local cellHeight = self.group.height / self.numRows
    local col = math.ceil((x + self.group.width / 2) / cellWidth)
    local row = math.ceil((y + self.group.height / 2) / cellHeight)

    return col, row
end

function Grid:getObject(col, row)
    return self._objects[row] and self._objects[row][col]
end

return Grid
