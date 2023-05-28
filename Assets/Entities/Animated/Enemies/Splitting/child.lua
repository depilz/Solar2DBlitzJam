local Super  = require("Assets.Entities.Animated.Enemies.enemy")

local Animated = require("Assets.Entities.Animated.animated")

------------------------------------------------------------------------------------------------------------------------
-- Enemy --
------------------------------------------------------------------------------------------------------------------------
local Enemy = Class('enemy', Super)

Enemy.breed = "splittingChild"
Enemy.__aim = true
Enemy.__animationFile = require("Assets.Entities.Animated.Enemies.Splitting.childAnimation")

function Enemy:init(params)
  Animated.init(self, params)

  self._initialized = true

  self.group.rotation = params.rotation
  self._controller:stop()
  self.__aim = false
  self:transitionTo{
    time       = 1500,
    x          = params.destX,
    y          = params.destY,
    rotation   = params.rotation + math.bidirRandom(500, 1000),
    transition = easing.outQuad,
    onComplete = function()
      self.__aim = true
      self:rotate(self.group.rotation)
      self.isAttackable = true
      self._controller:start()
    end
  }
end

return Enemy
