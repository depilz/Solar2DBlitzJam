local Entity  = require("Assets.Entities.entity")

-- ---------------------------------------------------------------------------------------------------------------------
-- Grey object --
-- ---------------------------------------------------------------------------------------------------------------------
local Grey = Class("grey", Entity)
Grey._inGameElement = true

-- Initialization ------------------------------------------------------------------------------------------------------

function Grey:create(parent)
    Entity.create(self, parent)

    self._body = display.newRect(self.group, 0, 0, 20, 40):setFillColor(0.5)
end


return Grey
