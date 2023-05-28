local Entity  = require("Assets.Entities.entity")

-- ---------------------------------------------------------------------------------------------------------------------
-- Health object --
-- ---------------------------------------------------------------------------------------------------------------------
local Health = Class("enemy", Entity)
Health._inGameElement = true

-- Initialization ------------------------------------------------------------------------------------------------------

function Health:create(params)
    Entity.create(self, params.parent, screen.edgeX - 5, screen.originY + 5)

    self.group.anchorChildren = true
    self.group.anchorX = 1
    self.group.anchorY = 0

    local width = 140
    local height = 30
    local frameSize = 4

    self._background = display.newRect(self.group, 0, -2, width + frameSize, height + frameSize)
    self._background:setFillColor(0, 0, 0, 0.5)
    self._background.anchorX = 0

    self._foreground = display.newRect(self.group, 0, 0, width, height)
    self._foreground:setFillColor(.6, .9, .2)
    self._foreground.anchorX = 0

    self.player = params.player

    game.time.subscribe(self)
end


function Health:enterFrame()
    local health = self.player.health
    local maxHealth = self.player.maxHealth

    self._foreground.xScale = health / maxHealth + 0.001
end

return Health
