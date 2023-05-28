local Entity  = require("Assets.Entities.entity")

local time = _G.game.time

-- ---------------------------------------------------------------------------------------------------------------------
-- Animated object --
-- ---------------------------------------------------------------------------------------------------------------------
local Animated = Class("animated", Entity)
Animated._inGameElement = true

-- Initialization ------------------------------------------------------------------------------------------------------

function Animated:create(stateObject)
  Entity.create(self, stateObject)

  self._animation = self.__animationFile:new(self.group, self.__animationParams)
  self._hp = 3
end


function Animated:init(params)
  params.parent:insert(self.group)
  self:setPosition(params.x, params.y)
  self:setController(params.controller or "default")

  time.addPausable(self)
  time.subscribe(self)

  self._controller:start()

  self._initialized = true
end


function Animated:takeDamage(damage)
  if not self.isAttackable then return false end
  self._hp = self._hp - damage
  if self._hp <= 0 then
    self:die()
  end
end


function Animated:setController(controller)
  if self._controller then self._controller:stop() end

  self._controller = nil
  if controller then
    self._controller = controller and require(self.__controllers[controller]):new(self)
    if self._initialized then
      self._controller:start()
    end
  end
end


function Animated:_canGotoState(state)
  error("unknown state "..tostring(state).." for "..self.class.name)
end


function Animated:gotoState(state, params)
  if not self:_canGotoState(state) then return false end

  if self._state then
    local exitState = "_exit"..self._state:capitalize().."State"
    if self[exitState] then
      self[exitState](self)
    end
  end

  self._state = state

  if state then
    local enterState = "_entry"..state:capitalize().."State"
    if self[enterState] then
      self[enterState](self, params)
    end
  end

  return true
end


function Animated:enterFrame(time, total)
  if self._controller and self._controller.enterFrame then
    self._controller:enterFrame(time, total)
  end
end


function Animated:resume()
  Entity.resume(self)
  self._animation:resume()
end


function Animated:pause()
  Entity.pause(self)
  self._animation:pause()
end


function Animated:stop()
  Entity.stop(self)
  time.unsubscribe(self)
  time.removePausable(self)
  self._controller:stop()
  self._controller = nil
  self._animation:stop()
end


function Animated:reset()
  Entity.reset(self)
  self._animation:reset()
end


function Animated:hardReset()
  Entity.hardReset(self)
  self._animation:hardReset()
end


return Animated
