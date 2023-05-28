local Entity = require("Assets.Entities.entity")

-- ---------------------------------------------------------------------------------------------------------------------
-- Enemy - Animation --
-- ---------------------------------------------------------------------------------------------------------------------

local Animation = Class("enemy-animation", Entity)

function Animation:create(parent, x, y)
  Entity.create(self, parent, x, y)

  local s = .06
  self._img = display.newImageRect(self.group, "Assets/Entities/Animated/Enemies/Splitting/parent.png", 344*s, 406*s)
end


function Animation:showUp()
  self.group.xScale, self.group.yScale = .01, .01
  self:transitionTo{
    time          = 400,
    xScale        = 1,
    yScale        = 1,
    transition    = easing.outBack,
  }
  self:_float()
end


function Animation:_pump()
  local fx2
  function fx2()
    self:transitionLoop{
      delay      = 400,
      time       = 1000,
      xScale     = .85,
      yScale     = .85,
      transition = easing.inQuad,
      onComplete = fx2
    }
  end
  fx2()
end


function Animation:_float()
  local fx
  function fx()
    self:transitionTo{
      time       = math.random(1000, 3000),
      x          = math.random(-4, 4),
      transition = easing.inOutQuad,
      onComplete = fx
    }
  end
  fx()
  local fy
  function fy()
    self:transitionTo{
      time       = math.random(1000, 3000),
      y          = math.random(-4, 4),
      transition = easing.inOutQuad,
      onComplete = fy
    }
  end
  fy()
end


function Animation:playAnimation(animation, params)
  if animation == "reachedGoal" then
    self:transitionTo{
      time          = 800,
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
    params.onComplete()
  end
end


return Animation
