local Grid  = require("Assets.Scenes.MainGame.grid")

local rayCast  = Grid.rayCast
local cellSize = _G.cellSize

---------------------------------------------------------------------------------------------------------------------------------------

local Controller = Class("enemyController")

function Controller:initialize(entity)
  self._entity = entity
  self._distance = entity:isAerial() and 8 or 6
  self._updateRate = (entity:isAerial() and 3 or 1)/entity:getSpeed()
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
  local ignoreWalls = self._entity:isAerial()
  local angle = self:_findBestPath(ignoreWalls)

  self._entity:rotate(angle)
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
    dc = math.random(0, distance)
    dr = (distance - dc)*rs()
    dc = dc*rs()
    s = s + rs()
  until (Grid[col+dc] or {})[row+dr]

  return col+dc, row+dr, Grid[col+dc][row+dr]
end


local function getClosestValid(dx, dy)
  local col = dx - dx%1+1
  local row = dy - dy%1+1

  local cell = math.huge
  local dist = 1

  local function get(dc, dr)
    local cell = (Grid[col+dc] or {})[row+dr] or math.huge
    return cell < 0 and math.huge or cell
  end


  local function tryWith(dist)
    local hDist = dist/2 + (dist/2)%1
    return math.min(get(0, dist), get(dist, 0), get(-dist, 0), get(0, -dist),
                    get(hDist, hDist), get(hDist, -hDist), get(-hDist, hDist), get(-hDist, -hDist))
  end

  while cell == math.huge do
    cell = tryWith(dist)
    dist = dist+1
  end

  return cell
end


function Controller:_getCurrentCell()
  local group = self._entity.group

  local dx  = group.x/cellSize
  local dy  = group.y/cellSize
  local col = dx - dx%1+1
  local row = dy - dy%1+1

  local current = (Grid[col] or {})[row] or -3
  if current < 0 then
    current = getClosestValid(dx, dy)
  end

  return dx, dy, current
end


local r = math.random
function Controller:_findBestPath(ignoreWalls)
  local dx, dy, current = self:_getCurrentCell()
  dx, dy = dx, dy

  local distance = math.min(self._distance, current+2)
  local dr, dc, cell
  local tries = 5

  -- NOTE: The commented code is to debug the algorithm
  -- for i = #(self._tries or {}), 1, -1 do
  --   self._tries[i]:removeSelf()
  -- end
  -- self._tries = {}

  local angle
  local currentAngle = self._entity:getRotation()
  local rotation

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

  until cell <= current+1-distance/2.5
    and rotation*rotation/35000 < math.random()
    and (ignoreWalls or rayCast(dx, dy, dc, dr))
    or distance == 1

  -- if self._r then self._r:removeSelf() end
  -- self._r = display.newLine(self._entity.group.parent, dx*cellSize, dy*cellSize, dc*cellSize, dr*cellSize)
  -- self._r.strokeWidth = 5
  -- self._r:setStrokeColor(0)

  return angle
end


function Controller:stop()

end

return Controller
