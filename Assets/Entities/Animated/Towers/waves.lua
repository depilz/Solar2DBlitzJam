local Super = require("Assets.Entities.entity")

local Wave = Class("Wave", Super)
local subscribeTime = _G.game.time.subscribe
local unsubscribeTime = _G.game.time.unsubscribe

local sqrt = math.sqrt

function Wave:initialize(parent, x, y, radius, targets)
  Super.initialize(self, parent, x, y)
  -- self.group:toBack()

  self._img = display.newCircle(self.group, 0, 0, 27)
  self._img:setFillColor(0,0,0,0)
  self._img.stroke = {1,1,1}
  self._img.strokeWidth = 8

  self._damage = 30
  self._range2 = radius*radius
  self._targets = targets

  self:transitionTo{
    table         = self._img.path,
    time          = 750,
    radius        = radius,
    transition    = easing.outCubic,
  }

  self:transitionTo{
    table         = self._img.group,
    alpha         = 0,
    time          = 750,
    transition    = easing.outQuad,
    onComplete    = function()
      self:update()
      self:clear()
    end
  }


  subscribeTime(self)
end


function Wave:update()
  local targets = self._targets
  local radius2 = self._img.path.radius^2

  while (targets[1] and targets[1][2] or math.huge) <= radius2 do
    local data = table.remove(targets, 1)
    data[1].object:takeDamage(self._damage*(1 - data[2]/self._range2))
  end
end


function Wave:enterFrame(time, total)
  self:update()
end


function Wave:clear()
  unsubscribeTime(self)

  Super.clear(self)
end


return Wave