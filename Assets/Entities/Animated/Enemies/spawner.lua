local random        = math.random
local ObjectPool    = _G.ObjectPool
local spawnPoints, mainGroup, topGroup

------------------------------------------------------------------------------------------------------------------------
-- Spawner --
------------------------------------------------------------------------------------------------------------------------
local Spawner = {}
Spawner.livingChildren = 0
Spawner.deadChildren   = 0

local totalWeight = 0
local timeElapsed
local spawnTask
local subscribers = List.new()
local newRandomEnemy, scheduleNextSpawn
local childDied
local performWithDelay = _G.game.time.performWithDelay

local Configs = require("Configs.configs")
local HordeCategories = Configs.get("hordeCategories")
local HordeTypes      = Configs.get("hordeTypes")
local durations = {
  short  = 30*1000,
  normal = 60*1000,
  long   = 90*1000,
}


function Spawner.start(params, onComplete)
  if params.type then
    local typeData = HordeTypes[params.type]
    Spawner.spawnInterval = typeData.spawnInterval
    Spawner.enemyWeights  = typeData.enemies

    local categoryData = HordeCategories[params.category]
    Spawner.maxDensity = categoryData.maxDensity
    Spawner.enemyLevels = categoryData.enemies

    Spawner.time        = durations[params.duration]
    Spawner.count       = 0

  else
    Spawner.enemyWeights      = params.enemyWeights or Spawner.enemyWeights
    Spawner.enemyLevels       = params.enemyLevels or Spawner.enemyLevels
    Spawner.maxDensity        = params.maxDensity
    Spawner.spawnInterval     = params.spawnInterval or Spawner.spawnInterval
    Spawner.time              = params.time*1000
    Spawner.count             = params.count

  end

  totalWeight = 0
  for _, w in pairs(Spawner.enemyWeights) do
    totalWeight = totalWeight + w
  end

  Spawner.onComplete  = onComplete or params.onComplete
  Spawner.totalSpawned = 0

  timeElapsed = 0
  Spawner.spawning = true
  Spawner.children = {}

  scheduleNextSpawn()
end


function Spawner.subscribe(subscriber)
  if subscribers:contains(subscriber) then return false end
  subscribers:append(subscriber)
  return true
end


function Spawner.unsubscribe(subscriber)
  return subscribers:remove_value(subscriber)
end


function Spawner.setData(mg, tg, sp)
  mainGroup   = mg
  topGroup    = tg
  spawnPoints = sp
end


function Spawner.spawn()
  local child, id = newRandomEnemy()

  local spawnPoint = spawnPoints[random(1, #spawnPoints)]
  local w = spawnPoint.width
  local h = spawnPoint.height
  child:init{
    parent        = child:isAerial() and topGroup or mainGroup,
    controller    = "default",
    level         = Spawner.enemyLevels[id],
    x             = spawnPoint.x + random()*w - w/2,
    y             = spawnPoint.y + random()*h - h/2,
  }
  child:addEventListener("died", childDied)
  Spawner.livingChildren  = Spawner.livingChildren +1
  Spawner.totalSpawned    = Spawner.totalSpawned +1
  Spawner.children[child] = child

  for i = 1, #subscribers do
    subscribers[i]:onSpawn(child)
  end
end


function Spawner.addFakeSpawn(child)
  child:addEventListener("died", childDied)
  Spawner.livingChildren = Spawner.livingChildren +1
  Spawner.children[child] = child

  for i = 1, #subscribers do
    subscribers[i]:onSpawn(child)
  end
end


function Spawner.pause()
  Spawner.spawning = false
  if spawnTask then spawnTask:pause() end

  return true
end


function Spawner:resume()
  Spawner.spawning = true
  if spawnTask then spawnTask:resume() end

  return true
end


function Spawner.stop(successful)
  if spawnTask then spawnTask:cancel() end
  spawnTask = nil
  Spawner.spawning = false

  if successful and Spawner.onComplete then
    local cb = Spawner.onComplete
    Spawner.onComplete = nil
    if cb then cb() end
  end

  if Spawner.livingChildren == 0 then
    Runtime:dispatchEvent{
      name     = "mapCleaned",
      target   = Spawner,
    }
  end

  return true
end


function Spawner.clear()
  Spawner.stop()

  if not Spawner.children then return false end

  for _, child in pairs(Spawner.children) do
    child:clear()
  end
  Spawner.children = {}
end


-- Event listeners ---------------------------------------------------------------------------------------------------------------------------

function Spawner:timer(e) -- SpawnNext
  spawnTask = nil

  if not Spawner.maxDensity or (Spawner.livingChildren < Spawner.maxDensity) then
    Spawner.spawn()
    if Spawner.totalSpawned >= Spawner.count and Spawner.count > 0 then
      Spawner.stop(true)
      return
    end
  end

  scheduleNextSpawn()
end

-- Private -----------------------------------------------------------------------------------------------------------------------------

function scheduleNextSpawn()
  if spawnTask then spawnTask:cancel() end

  local d    = Spawner.spawnInterval.time
  local v    = Spawner.spawnInterval.variation
  local time = math.decimalRandom(d-v, d+v)
  if Spawner.time > 0 and Spawner.time <= timeElapsed + time then
    spawnTask = performWithDelay(Spawner.time-timeElapsed, function()
      Spawner.stop(true)
    end)
    timeElapsed = Spawner.time

  else
    timeElapsed = timeElapsed + time
    spawnTask = performWithDelay(time, Spawner)

  end

end


function newRandomEnemy()
  local weight = random(totalWeight)
  for id, w in pairs(Spawner.enemyWeights) do
    weight = weight - w
    if weight <= 0 then
      return ObjectPool.getObject(id), id
    end
  end
end



function childDied(e)
  assert(not e.target.object)
  e.target:removeEventListener("died", childDied)
  Spawner.children[e.target] = nil
  Spawner.livingChildren = Spawner.livingChildren -1
  if Spawner.livingChildren == 0 and not Spawner.spawning then
    Runtime:dispatchEvent{
      name     = "mapCleaned",
      target   = Spawner,
    }
  end
end


return Spawner
