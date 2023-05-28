local Entity  = require("Assets.Entities.entity")
local SpriteSheetAnimation = require("Assets.Entities.Animated.spriteSheetAnimation")
local SpriteData = require("Assets.Scenes.MainGame.enemySprite")

-- ---------------------------------------------------------------------------------------------------------------------
-- Animation
-- ---------------------------------------------------------------------------------------------------------------------

local Animation = Class("animation", SpriteSheetAnimation)

Animation.__imageSheet   = SpriteData.imageSheet
Animation.__sequenceData = SpriteData.sequenceData
Animation._inGameElement = true

-- Initialization ------------------------------------------------------------------------------------------------------

function Animation:create(parent, color)
    self.color = color

    if self.color == "black" then
        self.__flipX = true
    end

    Entity.create(self, parent)
    SpriteSheetAnimation.create(self, parent)

    self.group:scale(2, 2)

    if self.color == "white" then
        self:playNextAnimation("lightidle")
        self._essence = display.newImageRect(self.group, "Assets/Entities/Enemy/lightessence.png", 16, 16)
    elseif self.color == "black" then
        self:playNextAnimation("darkidle")
        self._essence = display.newImageRect(self.group, "Assets/Entities/Enemy/darkessence.png", 16, 16)
    end

    self._essence.isVisible = false
end

function Animation:turnEssence()
    self:transitionTo{
      table      = self._spriteSheet,
        time       = 1000,
        alpha      = 0,
        xScale     = 0.1,
        yScale     = 0.1,
        transition = easing.OutQuad,
        onComplete = function()
            self._spriteSheet.isVisible = false
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
    self._spriteSheet.isVisible = true
    self:transitionTo{
        table      = self._spriteSheet,
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
