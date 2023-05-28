local Animated  = require("Assets.Entities.Animated.animated")

local Tools = require('Assets.GameLogic.tools')

local Map    = require("Assets.Scenes.MainGame.map")
local Waves  = require("Assets.Entities.Animated.Towers.waves")
local Canyon = require("Assets.Entities.Animated.Towers.canyon")

local cellSize = _G.cellSize
local comboData
local Stats = require("Configs.towerStats")

------------------------------------------------------------------------------------------------------------------------
-- Tower --                                                                                                           --
------------------------------------------------------------------------------------------------------------------------
local Tower = Class('tower', Animated)

Tower.__sfx = {
  implosion = {"implosion"},
  onPress   = {"button"},
}

Tower.__animationFile = require("Assets.Entities.Animated.Towers.animation")
Tower.__controllers = {
  default = "Assets.Entities.Animated.Towers.controller",
}

local rangeColor = {1,1,1}
local antiAirRangeColor = {1,0,1}
local areaDamageRangeColor = {0,1,.1}

-- Creation --------------------------------------------------------------------------------------------

function Tower:create(...)
  Animated.create(self, ...)

  self.stats = {}
  self.powerUps = {}
  self.connections = {}
  self._neighbors = {}
  self._canyon = Canyon:new(self.group, 0, 0)

  self._touchGroup = display.newRect(self.group, 0, 0, cellSize*2, cellSize*2)
  self._touchGroup.isVisible = false
  self._touchGroup.isHitTestable = true
  self._touchGroup:addEventListener("touch", self)
end


function Tower:init(col, row)
  self:_spawn(col, row)
  self._touchGroup.xScale, self._touchGroup.yScale = self.size, self.size

  self._canyon:init()

  self:_updateStats()

  self:_notifyPlacement()
end


function Tower:_notifyPlacement(noListener)
  Runtime:dispatchEvent{
    name   = "towerPlaced",
    target = self,
    col0   = self._col0,
    col1   = self._col1,
    row0   = self._row0,
    row1   = self._row1,
  }
  if not noListener then
    Runtime:addEventListener("towerPlaced", self)
    Runtime:addEventListener("towerRemoved", self)
  end
end


local function getCombinationArea(towers)
  local t1, t2 = towers[1], towers[3]
  return math.min(t1._col0, t2._col0), math.max(t1._col1, t2._col1),
         math.min(t1._row0, t2._row0), math.max(t1._row1, t2._row1)
end


function Tower:merge(towers)
  self.isCharged = false
  self:_disconnectFromAll()

  self.size = self.size+1
  self._col0, self._col1, self._row0, self._row1 = getCombinationArea(towers)


  local rot = 180
  for i = #towers, 2, -1 do
    towers[i]:_merge(self, rot)
    rot = rot + 90
  end


  self._animation:merge(rot, function()
    self:_completeMerging()
  end)
end


function Tower:_completeMerging()
  self.group.x = (self._col1+self._col0-1)*cellSize/2
  self.group.y = (self._row1+self._row0-1)*cellSize/2

  self._touchGroup.xScale, self._touchGroup.yScale = self.size, self.size
  self._animation:setSize(self.size-1)

  Runtime:dispatchEvent{name = "towerRemoved", target = self}

  self._canyon:deactivate()

  local function onComplete()
    self._animation:idle()
    self:_updateStats()

    if self._powerUps.areaDamage > 0 then
      self:_charge(300)
    end

    if self._powerUps.buff > 0 then
      self:_serveAsBuffer()
    end

    self:_notifyPlacement(true)
  end

  self._animation:mergeEnd(self.size, onComplete)
end



function Tower:_merge(tower, rot)
  self.isCharged = false

  for powerUp, level in pairs(self._powerUps) do
    tower._powerUps[powerUp] = tower._powerUps[powerUp]+level
  end

  self._animation:merge(rot, function()
    self:clear()
  end)
end


function Tower:_spawn(col, row)
  Animated.init(self, {
    parent = Map.middleGroup,
    x      = col*cellSize,
    y      = row*cellSize,
  })

  self.size       = 1
  self.bulletType = "basic"

  self._col0, self._row0 = col, row
  self._col1, self._row1 = col+1, row+1

  self._animation:setSize(1)
  self._animation:showUp()
end


function Tower:_updateStats()
  self.stats = Stats.calculate(self._powerUps, self._buffers, self.size)

  self._canyon:setRange(self.stats.range)
  self._canyon:setDamage(self.stats.damage)
  self._canyon:setRPS(self.stats.rps)
  self._canyon:setAntiAir(self._powerUps.antiAir > 0)

  self:_updateBulletType()
  self:_updateRanges()
end


function Tower:_updateBulletType()
  local bulletType  = "basic"
  local bulletCount = 0
  local isUpgraded = false

  for _, p in ipairs{"sniper", "machineGun", "antiAir"} do
    if self._powerUps[p] > bulletCount then
      isUpgraded = true
      bulletCount = self._powerUps[p]
      bulletType  = p
    end
  end

  if isUpgraded or (self._powerUps.buff + self._powerUps.areaDamage < 4^(self.size-1)) then
    self._canyon:setBulletVisual(bulletType)
    self._canyon:activate()
  else
    self._canyon:deactivate()
  end
end


-- Actions --------------------------------------------------------------------------------------------

function Tower:implode(targets)
  local range = self.stats.implosionRange*cellSize

  Waves:new(Map.bottomGroup, self.group.x, self.group.y, range, targets)
  self.charged = false

  self:playSound("implosion")

  self._animation:implode(function(time)
    local chargeTime = math.max(1000/self.stats.ips-time, 0)
    self:_charge(chargeTime)
  end)
end


function Tower:_charge(time)
  if self.charged then return end

  self._animation:charge(time, function()
    self.charged = true
  end)
end


function Tower:highlight()
  self.isActive = true
  self._animation:highlight()
end


function Tower:unhighlight(noEffect)
  self.isActive = false
  self._animation:unhighlight(noEffect)
  self:_hideRanges()
end


function Tower:_showRange()
  if not self._range then
    self._range = display.newCircle(Map.bottomGroup, self.group.x, self.group.y, .01)
    self._range:setFillColor(0,0,0)
    self._range.stroke = {.7,0,0,.5}
    self._range.strokeWidth = 4

    self._rangeAD = display.newCircle(Map.bottomGroup, self.group.x, self.group.y, .01)
    self._rangeAD:setFillColor(0,0,0)
    self._rangeAD.stroke = {0,.7,0,.5}
    self._rangeAD.strokeWidth = 4
  end

  self:_updateRanges()
end


function Tower:_updateRange(target, range, color)
  self:transitionTo{
    table      = target.path,
    time       = 300,
    tag        = "range",
    radius     = range*cellSize,
    transition = easing.outQuad,
  }

  self:transitionTo{
    table      = target.fill,
    time       = 300,
    tag        = "range",
    r          = color[1],
    g          = color[2],
    b          = color[3],
    a          = .35,
    transition = easing.outQuad,
  }

  target.stroke = {color[1],color[2],color[3],.5}
end


function Tower:_updateRanges()
  if not self._range then return end
  self:_cancel("range")

  local radius = self._canyon:isActive() and self.stats.range or 0
  local color = self._powerUps.antiAir > 0 and antiAirRangeColor or rangeColor
  self:_updateRange(self._range, radius, color)

  self:_updateRange(self._rangeAD, self.stats.implosionRange, areaDamageRangeColor)
end


function Tower:_hideRange(target, onComplete)
  self:transitionTo{
    table      = target.path,
    time       = 300,
    tag        = "range",
    radius     = 0,
    transition = easing.inQuad,
    onCancel   = function()
      self._hiding = false
    end,
    onComplete = function()
      self._hiding = false
    end,
  }

  self:transitionTo{
    table      = target.fill,
    time       = 300,
    tag        = "range",
    r          = 0,
    g          = 0,
    b          = 0,
    onComplete = onComplete
  }
  target.stroke = {0,0,0,0}
end


function Tower:_hideRanges()
  if not self._range or self._hiding then return end
  self._hiding = true
  self:_cancel("range")

  self:_hideRange(self._range, function()
    self._range:removeSelf()
    self._range = nil
  end)
  self:_hideRange(self._rangeAD, function()
    self._rangeAD:removeSelf()
    self._rangeAD = nil
  end)
end

-- Upgrading --------------------------------------------------------------------------------------------

function Tower:canUpgrade(powerUp)
  local maxUpgrade = _G.game.state:getValue("towers."..powerUp..".level")
  return self.size == 1 and powerUp == (self.powerUp or powerUp) and self._powerUps[powerUp] < maxUpgrade
end


function Tower:isUpgraded()
  return self.powerUp
end


function Tower:getLevel(powerUp)
  return self._powerUps[powerUp]
end


function Tower:upgrade(powerUp)
  if not self:canUpgrade(powerUp) then return false end

  if self.powerUp ~= powerUp then
    if powerUp == "areaDamage" then
      self:_activatePressurizer()

    elseif powerUp == "buff" then
      self:_serveAsBuffer()

    end
  end

  self.powerUp = powerUp
  self._powerUps[powerUp] = self._powerUps[powerUp]+1

  self:_updateStats()

  return true
end


function Tower:_activatePressurizer()
  self:_charge(300)
  self:_updateBulletType()
end


function Tower:_serveAsBuffer()
  for tower, _ in pairs(self._neighbors) do
    self:_buff(tower)
  end
  self:_updateBulletType()
end


-- Buff tower --------------------------------------------------------------------------------------------

function Tower:_buff(tower)
  self:_connect(tower)
  tower:addBuffer(self)
end


function Tower:addBuffer(tower)
  self._buffers[tower] = tower.buff
end


function Tower:removeBuffer(tower)
  self._buffers[tower] = nil
end


function Tower:towerPlaced(e) -- Event Listener
  local isNeighbor = e.col1+1 >= self._col0 and e.col0-1 <= self._col1
                 and e.row1+1 >= self._row0 and e.row0-1 <= self._row1

  if isNeighbor then
    self:addNeighbor(e.target, true)
  end
end


function Tower:towerRemoved(e)  -- Event Listener
  self:_removeNeighbor(e.target)
  self:_disconnect(e.target)
  if self._range then self._range:removeSelf(); self._range = nil end
  if self._rangeAD then self._rangeAD:removeSelf(); self._rangeAD = nil end
end


function Tower:addNeighbor(tower, doubleLink)
  if self._neighbors[tower] then return false end
  self._neighbors[tower] = true

  if doubleLink then
    tower:addNeighbor(self)
  end

  if self._powerUps.buff > 0 then
    self:_buff(tower)
  end
end


function Tower:_removeNeighbor(tower)
  self._neighbors[tower] = nil
  if self._buffers[tower] then
    self:removeBuffer(tower)
  end
end


local s = .035
local newBuffSide = function (parent, size)
  local img = size == 1 and display.newImageRect(parent, "Assets/Entities/Animated/Towers/Animation/buff_sides.png",     776*s, 863*s)
                        or  display.newImageRect(parent, "Assets/Entities/Animated/Towers/Animation/buff_sides_big.png", 776*s, 863*s)
  img.anchorX = 0
  return img
end
function Tower:_connect(tower)
  if self.connections[tower] then return false end

  local dx, dy = tower.group.x - self.group.x, tower.group.y - self.group.y

  local group = display.newGroup()
  group.rotation = math.getAngle(dx, dy)
  self.group:insert(group)

  self.connections[tower] = group
  tower.connections[self] = group

  local distance = math.sqrt(dx*dx + dy*dy)
  group.x, group.y = dx/distance*22*self.size, dy/distance*22*self.size
  distance = distance-22*self.size - 22*tower.size

  group.left = newBuffSide(group, self.size)
  group.left.rotation = 180

  group.center = display.newImageRect(group, "Assets/Entities/Animated/Towers/Animation/buff_center.png", 82*s, 221*s)
  group.center.anchorX = 0
  group.center.xScale  = distance/(82*s)

  group.right = newBuffSide(group, tower.size)
  group.right.x = group.center.width*group.center.xScale
end


function Tower:_disconnectFromAll()
  for tower, _ in pairs(self.connections) do
    self:_disconnect(tower)
  end
end


function Tower:_disconnect(tower)
  if not self.connections[tower] then return false end
  self.connections[tower]:removeSelf()
  self.connections[tower] = nil
  tower.connections[self] = nil
end


local function validateTowerCombination(tower)
  if comboData.size ~= tower.size then return false end

  if #comboData.selectedTowers == 1 then
    local t1 = comboData.selectedTowers[1]
    if     tower._col0 == t1._col0 then
      return math.abs(tower._row0 - t1._row0)/2 == t1.size
    elseif tower._row0 == t1._row0 then
      return math.abs(tower._col0 - t1._col0)/2 == t1.size
    end

  elseif #comboData.selectedTowers == 2 then
    local t1 = comboData.selectedTowers[1]
    local t2 = comboData.selectedTowers[2]
    if     t1._col0 == t2._col0 then
      return tower._row0 == t2._row0 and math.abs(tower._col0 - t1._col0)/2 == t1.size
    else
      return tower._col0 == t2._col0 and math.abs(tower._row0 - t1._row0)/2 == t1.size
    end

  elseif #comboData.selectedTowers == 3 then
    local t1 = comboData.selectedTowers[1]
    local t3 = comboData.selectedTowers[3]

    if     t1._col0 == tower._col0 then
      return t3._row0 == tower._row0
    elseif t3._col0 == tower._col0 then
      return t1._row0 == tower._row0
    end

  end

  return false
end


-- Touch event --------------------------------------------------------------------------------------------

local cancelTouchEvent
local prevTarget = nil
local isPressing = false

local touchBackground = function(e)
  if (not isPressing or isPressing == e.id) and comboData then
    cancelTouchEvent()
  end
end


function Tower:validateTouch(e)
  return not isPressing and e.phase == "began" or isPressing == e.id
end


function Tower:onPress(e)
  prevTarget = comboData and comboData.selectedTowers[1]
  cancelTouchEvent()

  self:highlight()

  self:playSound("onPress")

  isPressing = e.id

  Map.content:addEventListener("touch", touchBackground)
  Map.group:addEventListener("touch", touchBackground)

  comboData = {
    selectedTowers = List.new{self},
    c1             = self._col0,
    r1             = self._row0,
    size           = self.size,
  }
end


function Tower:onMove(e)
  if comboData.selectedTowers:contains(self) then return end

  if validateTowerCombination(self) then
    comboData.selectedTowers:append(self)

    self:highlight()

    if #comboData.selectedTowers == 4 then
      Map.mergeTowers(comboData.selectedTowers)

      cancelTouchEvent()
    end

  else
    cancelTouchEvent()

  end
end


function Tower:onRelease(e)
  if #comboData.selectedTowers ~= 1 or prevTarget == self then
    return cancelTouchEvent()
  end

  local panel = Tools.gui:get("towerUpgrades")
  local dir = panel.dir
  if panel.hidden then
    dir = self:localToContent(0,0) > screen.centerX and 1 or -1
  end
  panel:show(self, dir)
  self:_showRange()

  isPressing = false
end


function Tower:onCancel(e)
  cancelTouchEvent()
end


function Tower:touch(e)
  if not self:validateTouch(e) then return false end

  if e.phase == "began" then self:onPress(e)
  elseif e.phase == "moved" then  self:onMove(e)
  elseif e.phase == "ended" then  self:onRelease(e)
  elseif e.phase == "cancelled" then  self:onCancel(e)
  end

  return true
end


function cancelTouchEvent()
  if not comboData then return false end

  for _, tower in ipairs(comboData.selectedTowers) do
    tower:unhighlight()
  end

  Tools.gui:get("towerUpgrades"):hide()

  isPressing = false
  comboData  = nil
  Map.content:removeEventListener("touch", touchBackground)
  Map.group:removeEventListener("touch", touchBackground)
end


--- Destroying --------------------------------------------------------------------------------------------

function Tower:destroy()
  Runtime:dispatchEvent{name = "towerRemoved", target = self}
  self:clear()
end


function Tower:stop()
  self._initialized = false

  cancelTouchEvent()

  Runtime:removeEventListener("towerPlaced", self)
  Runtime:removeEventListener("towerRemoved", self)
  Runtime:dispatchEvent{name = "towerRemoved", target = self}

  for n, _ in pairs(self._neighbors) do
    self:_removeNeighbor(n)
  end

  self._canyon:stop()
  Animated.stop(self)
end


function Tower:hardReset()
  Animated.hardReset(self)

  self._initialized = false

  self.powerUp = nil
  self._powerUps = {
    areaDamage = 0,
    sniper     = 0,
    machineGun = 0,
    antiAir    = 0,
    buff       = 0,
  }
  self._buffers = {}


  self._animation:unhighlight(true)

  self._canyon:hardReset()
end


function Tower:remove()
  self._canyon:clear()
  Animated.remove(self)
end


return Tower