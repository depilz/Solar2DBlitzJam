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

end


return Animation
