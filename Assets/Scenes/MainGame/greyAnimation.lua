local SpriteSheetAnimation = require("Assets.Entities.Animated.spriteSheetAnimation")

local SpriteData =  require("Assets.Scenes.MainGame.greySprite")

-- ---------------------------------------------------------------------------------------------------------------------
-- Animation
-- ---------------------------------------------------------------------------------------------------------------------

local Animation = Class("animation", SpriteSheetAnimation)

Animation.__imageSheet   = SpriteData.imageSheet
Animation.__sequenceData = SpriteData.sequenceData

-- ---------------------------------------------------------------------------------------------------------------------
-- Enemy - Animation --
-- ---------------------------------------------------------------------------------------------------------------------

function Animation:create(parent)
  SpriteSheetAnimation.create(self, parent)

  self.group:scale(2, 2)

  self.group.x = 36
  self.group.y = -4

  self:playNextAnimation("idle")
end

function Animation:dash()
  self:playAnimation("dash", { onComplete = function()
    self:playAnimation("idle")
  end
})
end

function Animation:die()
  self:pause()

  self:transitionTo{
    table      = self.group,
    time       = 1000,
    alpha      = 0,
    xScale     = 0.1,
    yScale     = 0.1,
    transition = easing.OutQuad,
    onComplete = function()
      self.group.isVisible = false
    end
  }
end

function Animation:faceLeft()
  self.group.x = -36
  self._spriteSheet.xScale = -1
end

function Animation:faceRight()
  self.group.x = 36
  self._spriteSheet.xScale = 1
end

return Animation
