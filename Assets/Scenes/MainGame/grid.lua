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
    local ox = -(params.columns - 1) * cellWidth / 2
    local oy = -(params.rows - 1) * cellHeight / 2

    for r = 1, params.rows do
        self._rows[r] = {}
        for c = 1, params.columns do
            self._rows[r][c] = display.newRect(self.group, 0, 0, cellWidth - 3, cellHeight- 3)
            self._rows[r][c]:setFillColor(0.5, 0.2, 0.5)
            self._rows[r][c].x = (c-1) * cellWidth -3 + ox
            self._rows[r][c].y = (r-1) * cellHeight -3 + oy
        end
    end
end


function Grid:getCell(col, row)
    return self._rows[row][col]
end

function Grid:init(params)
    params.parent:insert(self.group)

end

return Grid
