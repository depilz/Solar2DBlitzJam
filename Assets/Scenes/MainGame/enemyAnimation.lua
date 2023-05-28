local Entity  = require("Assets.Entities.entity")

-- ---------------------------------------------------------------------------------------------------------------------
-- Animation object --
-- ---------------------------------------------------------------------------------------------------------------------
local Animation = Class("grey", Entity)
Animation._inGameElement = true

-- Initialization ------------------------------------------------------------------------------------------------------

function Animation:create(parent, color)
    Entity.create(self, parent)

    self.color = color
    
    self._enemyForm = display.newRect(self.group, 0, 0, 20, 40)
    self._essence = display.newCircle(self.group, 0, 0, 10)

    if self.color == "white" then
        self._enemyForm:setFillColor(1)
        self._essence:setFillColor(1)
    elseif self.color == "black" then
        self._enemyForm:setFillColor(0)
        self._essence:setFillColor(0)
    end

    self._essence.isVisible = false
end


function Animation:turnEssence()
    self:transitionTo{
      table      = self._enemyForm,
        time       = 1000,
        alpha      = 0,
        xScale     = 0.1,
        yScale     = 0.1,
        transition = easing.OutQuad,
        onComplete = function()
            self._enemyForm.isVisible = false
        end
    }

    self._essence.alpha = 0
    self._essence.xScale = 0.1
    self._essence.yScale = 0.1
    self._essence.isVisible = true

    self:transitionTo{
        table      = self._essence,
        time       = 1000,
        alpha      = 1,
        xScale     = 1,
        yScale     = 1,
        transition = easing.OutQuad,
        onComplete = function()
        end
    }
end

function Animation:turnEnemy()
    self._enemyForm.isVisible = true
    self:transitionTo{
        table      = self._enemyForm,
        time       = 1000,
        alpha      = 1,
        xScale     = 1,
        yScale     = 1,
        transition = easing.OutQuad,
        onComplete = function()
        end
    }

    self:transitionTo{
        table      = self._essence,
        time       = 1000,
        alpha      = 0,
        xScale     = 0.1,
        yScale     = 0.1,
        transition = easing.OutQuad,
        onComplete = function()
            self._essence.isVisible = false
        end
    }
end

return Animation
