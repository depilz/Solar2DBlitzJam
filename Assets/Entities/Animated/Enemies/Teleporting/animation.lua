local Entity = require("Assets.Entities.entity")

-- ---------------------------------------------------------------------------------------------------------------------
-- Enemy - Animation --
-- ---------------------------------------------------------------------------------------------------------------------

local Animation = Class("enemy-animation", Entity)

function Animation:create(parent, x, y)
  Entity.create(self, parent, x, y)

  self._enemy = display.newImageRect(self.group, "Assets/Entities/Animated/Enemies/Basic/basic.png", 20, 20)
end


function Animation:showUp()
  self.group.xScale, self.group.yScale = .01, .01
  self:transitionTo{
    time          = 400,
    xScale        = 1,
    yScale        = 1,
    transition    = easing.outBack,
   onComplete    = function()
      self:_pump()
    end
  }
  self:_rotate()
  self:_float()
end


function Animation:_pump()
  local fx2
  function fx2()
    self:transitionLoop{
      delay      = 400,
      time       = 1000,
      xScale     = .9,
      yScale     = .9,
      transition = easing.inQuad,
      onComplete = fx2
    }
  end
  fx2()
end


function Animation:_rotate()
  self.group.rotation = 0
  self:transitionTo{
    time       = 6000,
    rotation   = 360*math.randomSign(),
    iterations = -1,
  }
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
