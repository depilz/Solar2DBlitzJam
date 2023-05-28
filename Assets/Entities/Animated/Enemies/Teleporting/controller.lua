local Grid  = require("Assets.Scenes.MainGame.grid")

local rayCast  = Grid.rayCast
local cellSize = _G.cellSize

---------------------------------------------------------------------------------------------------------------------------------------

local Controller = Class("teleportingEnemy-Controller")

function Controller:initialize(entity)
  self._entity = entity
  self._updateRate = 1/entity:getSpeed()
end


function Controller:start()
  self._updateCount = 0
  self:updatePath()
end


function Controller:enterFrame(time, total)
  if not self._entity.isAttackable then return end
  self._updateCount = self._updateCount + 1
  if self:_isInGoal() then
    self._entity:die(true)

  elseif self._updateCount >= self._updateRate then
    self:updatePath()

  end
end


function Controller:updatePath()
  self._updateCount = 0
  local path = self:_findBestPath()

  self._entity:rotate(path.angle)
  if path.teleport then
    self._entity:teleportTo(path.x, path.y)
  end
end


function Controller:_isInGoal()
  local group       = self._entity.group

  local initCol     = group.x/cellSize
  local initRow     = group.y/cellSize
  local initColRnd  = initCol - initCol%1+1
  local initRowRnd  = initRow - initRow%1+1
  local current     = (Grid[initColRnd] or {})[initRowRnd]

  return current == 0
end

local s = 0
local rs = math.randomSign
function Controller:_getRandomCell(distance)
  local group       = self._entity.group

  local dx  = group.x/cellSize
  local dy  = group.y/cellSize
  local col = dx - dx%1+1
  local row = dy - dy%1+1

  local dc, dr
  repeat
    dc = math.random(1, distance)
    dr = (distance - dc)*rs()
    dc = dc*rs()
    s = s + rs()
  until (Grid[col+dc] or {})[row+dr]

  return col+dc, row+dr, Grid[col+dc][row+dr]
end

function Controller:_getCurrentCell()
  local group = self._entity.group

  local dx  = group.x/cellSize
  local dy  = group.y/cellSize
  local col = dx - dx%1+1
  local row = dy - dy%1+1

  return dx, dy, (Grid[col] or {})[row] or math.huge
end


local function isBetween(x, a, b)
  return x >= a and x <= b
end

local function canTeleportTo(current, hasAWall,dc, dr)
  local cell = (Grid[dc+.5] or {})[dr+.5] or math.huge
  return hasAWall and isBetween(cell, 0, current-2) and math.random(4) == 1
end


local r = math.random
function Controller:_findBestPath()
  local dx, dy, current = self:_getCurrentCell()
  dx, dy = dx, dy
  current = current < 0 and math.huge or current
  local distance = math.min(4, current+1)
  local dr, dc, cell
  local tries = 5

  -- for i = #(self._tries or {}), 1, -1 do
  --   self._tries[i]:removeSelf()
  -- end
  -- self._tries = {}


  local hasAWall, teleport, valid
  local currentAngle = self._entity:getRotation()
  local angle, rotation

  repeat
    dc, dr, cell = self:_getRandomCell(distance)
    dc, dr = dc-.5, dr-.5
    tries = tries - 1
    if tries == 0 then
      tries = 5
      distance = distance -1
    end

    -- self._tries[#self._tries+1] = display.newLine(self._entity.group.parent, dx*cellSize, dy*cellSize, dc*cellSize, dr*cellSize)
    -- self._tries[#self._tries].strokeWidth = 3
    -- if cell > current then
    --   self._tries[#self._tries]:setStrokeColor(1,0,0)
    -- elseif not (ignoreWalls or rayCast(dx, dy, dc, dr)) then
    --   self._tries[#self._tries]:setStrokeColor(1,1,0)
    -- elseif distance == 1 then
    --   self._tries[#self._tries]:setStrokeColor(1,0,1)
    -- else
    --   self._tries[#self._tries]:setStrokeColor(0,0,1)
    -- end

    angle = math.getAngle(dc-dx, dr-dy)
    angle = currentAngle and math.getClosestEquivalentAngle(currentAngle, angle) or angle
    rotation = (angle-(currentAngle or angle))

    valid    = cell <= current+1-distance/2.5 and rotation*rotation/35000 < math.random()
    hasAWall = not rayCast(dx, dy, dc, dr)
    teleport = canTeleportTo(current, hasAWall, dc, dr)

  until valid and (not hasAWall or teleport)
    or distance == 0

  -- if self._r then self._r:removeSelf() end
  -- self._r = display.newLine(self._entity.group.parent, dx*cellSize, dy*cellSize, dc*cellSize, dr*cellSize)
  -- self._r.strokeWidth = 5
  -- self._r:setStrokeColor(0)

  return {
    angle    = angle,
    teleport = teleport,
    x        = dc*cellSize,
    y        = dr*cellSize,
  }
end


function Controller:stop()

end


return Controller
