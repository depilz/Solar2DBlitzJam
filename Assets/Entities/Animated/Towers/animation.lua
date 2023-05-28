local SpriteSheetAnimation = require("Assets.Entities.Animated.spriteSheetAnimation")

local SpriteData =  require("Assets.Entities.Animated.Towers.Animation.sprite")

-- ---------------------------------------------------------------------------------------------------------------------
-- Animation
-- ---------------------------------------------------------------------------------------------------------------------

local Animation = Class("BasicTower-animation", SpriteSheetAnimation)

Animation.__imageSheet   = SpriteData.imageSheet
Animation.__sequenceData = SpriteData.sequenceData

Animation.__imageOffsets = {
  idle                = { x = 0, y = 0 },
  merging             = { x = 0, y = 0 },
  merging_end         = { x = 0, y = 0 },
}

-- ---------------------------------------------------------------------------------------------------------------------
-- Enemy - Animation --
-- ---------------------------------------------------------------------------------------------------------------------

function Animation:create(parent, size)
  SpriteSheetAnimation.create(self, parent)

  self:setSize(size or 1)

  self._bubbles = display.newImageRect(self.group, "Assets/Entities/Animated/Towers/Animation/bubbles.png", 230, 230)
  self._bubbles.rotation = math.random(0, 360)
  self._bubbles:toBack()
  self.isCharged = false

  self._highlight = display.newCircle(self.group, 0, 0, 170/2)
  self._spriteSheet:toFront()
  self._highlight.alpha = 0
end


function Animation:showUp()
  self:playNextAnimation("idle")

  self.isCharged = false
  self._spriteSheet.xScale, self._spriteSheet.yScale = .01, .01
  self.group.alpha = 0
  self:transitionTo{
    time          = 700,
    alpha         = 1,
    transition    = easing.outQuad,
  }
  self:transitionTo{
    time          = 700,
    table         = self._spriteSheet,
    xScale        = 1,
    yScale        = 1,
    transition    = easing.outQuad,
  }

  self._spriteSheet:setFillColor(1, 1, 1)
end


function Animation:idle()
  self:playNextAnimation("idle")
end


function Animation:setSize(size, time)
  local scale = (2^(size-1))/4

  if time then
    transition.to(self.group, {
      time       = time,
      xScale     = scale,
      yScale     = scale,
      transition = easing.inOutCubic,
    })
  else
    self.group.xScale, self.group.yScale = scale, scale
  end

end


function Animation:merge(rot, onComplete)
  self._spriteSheet.rotation = rot
  local params = {onComplete = function()
    self._spriteSheet.rotation = 0
    if onComplete then onComplete() end
  end}

  self:_cancel("charging")
  self:playNextAnimation("merging", params)
end


function Animation:mergeEnd(size, onComplete)
  self:setSize(size, 14/15*1000)
  self:playNextAnimation("merging_end", {onComplete = onComplete})
end


function Animation:charge(time, onComplete)
  self.isCharged = true
  self:_cancel("charging")
  self:transitionTo{
    tag        = "charging",
    table      = self._spriteSheet,
    time       = time,
    xScale     = 1.15,
    yScale     = 1.15,
    transition = easing.inOutQuad,
  }
  self:transitionTo{
    tag        = "charging",
    table      = self._spriteSheet.fill,
    time       = time,
    r          = 1,
    g          = 1,
    b          = .2,
    transition = easing.outQuad,
    onComplete = onComplete
  }
end


function Animation:implode(onComplete)
  local time = 120
  self.isCharged = false
  self:_cancel("charging")
  self:transitionTo{
    tag        = "charging",
    table      = self._spriteSheet,
    time       = time,
    transition = easing.outBack,
    xScale     = 1,
    yScale     = 1,
  }
  self:transitionTo{
    tag        = "charging",
    table      = self._spriteSheet.fill,
    time       = time,
    transition = easing.outQuad,
    r          = 1,
    g          = 1,
    b          = 1,
    onComplete = onComplete and function()
      onComplete(time)
    end
  }
end


function Animation:highlight()
  self:_cancel("highlighting")

  self:transitionTo{
    tag         = "highlighting",
    table       = self._highlight,
    time        = 300,
    alpha       = 0.3,
    transition  = easing.outQuad,
  }
end


function Animation:unhighlight(noEffect)
  self:_cancel("highlighting")
  if noEffect then
    self._highlight.alpha = 0
  else
    self:transitionTo{
      tag         = "highlighting",
      table       = self._highlight,
      time        = 700,
      alpha       = 0,
      transition  = easing.outQuad,
    }
  end
end


function Animation:fire(dX, dY, onStart)
  if self._spriteSheet.rotation == 360 then self._spriteSheet.rotation = 0 end
  local rotation = math.atan(dY/dX)/math.pi*180
  rotation = dX>=0 and rotation+180 or rotation

  self._spriteSheet.rotation = self._spriteSheet.rotation%360

  if rotation - self._spriteSheet.rotation > 180 then
    rotation = rotation-360
  end
  if rotation - self._spriteSheet.rotation < -180 then
    rotation = rotation+360
  end

  self:transitionTo{
    time        = math.sqrt(math.abs(rotation-self._spriteSheet.rotation))*20,
    table       = self._spriteSheet,
    rotation    = rotation,
    onComplete  = function()
      self:playNextAnimation("fire")
      onStart()
    end,
  }
end


return Animation
