local Super  = require("Assets.Entities.Animated.Enemies.enemy")

------------------------------------------------------------------------------------------------------------------------
-- Enemy --
------------------------------------------------------------------------------------------------------------------------

local Enemy = Class('teleporting-enemy', Super)

Enemy.breed = "teleporting"

Enemy.__animationFile = require("Assets.Entities.Animated.Enemies.Teleporting.animation")
Enemy.__controllers = {
  default = "Assets.Entities.Animated.Enemies.Teleporting.controller",
}

function Enemy:teleportTo(x, y, onComplete)
  self.isAttackable = false
  self:transitionTo{
    time          = 500,
    yScale        = .6,
    xScale        = .6,
    alpha         = .5,
    transition    = easing.outQuad,
    onComplete    = function()
      local dx, dy = x-self.group.x, y-self.group.y
      self:setPosition(x, y, {
        time          = (dx*dx+dy*dy)/50,
        transition    = easing.inOutQuad,
        onComplete    = function()
          self:transitionTo{
            time          = 500,
            yScale        = 1,
            xScale        = 1,
            alpha         = 1,
            transition    = easing.inQuad,
            onComplete    = function()
              self.isAttackable = true

              if onComplete then onComplete() end
            end
          }
        end
      })
    end
  }
end


return Enemy