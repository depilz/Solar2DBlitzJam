local Entity = require("Assets.Entities.entity")

-- ---------------------------------------------------------------------------------------------------------------------
-- Enemy - Animation --
-- ---------------------------------------------------------------------------------------------------------------------

local Animation = Class("enemy-animation", Entity)

function Animation:create(parent, x, y)
  Entity.create(self, parent, x, y)

  self._enemy = display.newImageRect(self.group, "Assets/Entities/Animated/Enemies/Runner/runner.png", 242*0.05, 550*0.05)
end


function Animation:showUp()
  self.group.xScale, self.group.yScale = .01, .01
  self:transitionTo{
    time          = 400,
    xScale        = 1,
    yScale        = 1,
    transition    = easing.outBack,
  }
end


function Animation:playAnimation(animation, params)
  if animation == "reachedGoal" then
    self:transitionTo{
      time          = 400,
      xScale        = 3,
      yScale        = 3,
      alpha         = 0,
      transition    = easing.outQuad,
      onComplete    = function()
        self.group.xScale   = 1
        self.group.yScale   = 1
        self.group.alpha    = 1
        params.onComplete()
      end
    }

  elseif animation == "death" then
    self:transitionTo{
      time          = 250,
      xScale        = .01,
      yScale        = .01,
      transition    = easing.inBack,
      onComplete    = function()
        self.group.xScale   = 1
        self.group.yScale   = 1
        params.onComplete()
      end
    }
  end
end

return Animation
