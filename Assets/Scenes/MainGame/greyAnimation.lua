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

  self.group.x = 18
  self.group.y = -4

  self:playNextAnimation("idle")
end

function Animation:dash()
  self:playAnimation("dash", { onComplete = function()
    self:playAnimation("idle")
  end
})
end

return Animation
