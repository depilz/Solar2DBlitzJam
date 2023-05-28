------------------------------------------------------------------------------------------------------------------------
-- Constants and variables --
------------------------------------------------------------------------------------------------------------------------

_G.device = require "Utils.device"

------------------------------------------------------------------------------------------------------------------------
-- Libraries --
------------------------------------------------------------------------------------------------------------------------

require "pl.init"
_G.List = pl.List

_G.Class     = require("Utils.middleclass")
_G.screen    = require("Utils.screen")
_G.Log       = require("Utils.logger")
_G.inspect   = require("Utils.inspect")

-- Game Globals ---


-- Check if not Nan nor infinite
local math = math
math.isANumber = function(n)
  return not (n ~= n or n*n == math.huge)
end

math.decimalRandom = function(a, b)
  return math.random()*(b-a)+a
end

math.sign = function(a)
  return a > 0 and 1 or a < 0 and -1 or 0
end

math.randomSign = function(a, b)
  return math.random(0, 1)*2-1
end

-- Bi-directional random: Gives a random number between the range: -b, -a and a, b
math.bidirRandom = function(a, b)
  local r = b*(math.random()*2-1)
  return r >= 0 and r+a or r-a
end

math.legs = function(angle, hypotenuse)
  return  math.cos(angle/180*math.pi)*hypotenuse,
          math.sin(angle/180*math.pi)*hypotenuse
end

math.hypotenuse = function(dx, dy, dz)
  dz = dz or 0
  return math.sqrt(dx*dx + dy*dy + dz*dz)
end

math.getAngle = function(dx, dy)
  return math.atan(dy/dx)*180/math.pi + (dx<0 and 180 or 0)
end


math.rotate = function(x, y, angle)
  local sin = math.sin(angle)
  local cos = math.cos(angle)
  return cos*x + sin*y, cos*y + sin*x
end

math.getClosestEquivalentAngle = function(orig, dest)
  local d = orig/360 - (orig/360)%1
  orig = orig%360

  if dest - orig >  180 then dest = dest-360 end
  if dest - orig < -180 then dest = dest+360 end

  return dest + 360*d
end

math.pair = function(number)
  number = number or math.random(1, 2)
  return (number%2)*2-1
end

math.randomSign = function()
  return (math.random(2)-1)*2-1
end

math.clamp = function(x, min, max)
  return x < min and min or x > max and max or x
end

_G.textFormat = {}
_G.textFormat.time = function(remainingTime)
  local time = math.ceil(remainingTime)%60
  local t
  if remainingTime >= 59 then
    if time < 10 then time = "0"..time end
    t = math.floor(((remainingTime+1)/60)%60)
    time = t..":"..time
  end
  if remainingTime >= 3599 then
    if t < 10 then time = "0"..time end
    t = math.floor(((remainingTime+1)/3600)%24)
    time = t..":"..time
  end
  if remainingTime >= 86399 then
    if t < 10 then time = "0"..time end
    time = math.floor((remainingTime+1)/86400)..":"..time
  end

  return time
end

local equals; equals = function(o1, o2)
  if o1 == o2 then return true end
  local o1Type = type(o1)
  local o2Type = type(o2)
  if o1Type ~= o2Type then return false end
  if o1Type ~= 'table' then return false end

  local keySet = {}

  for key1, value1 in pairs(o1) do
    local value2 = o2[key1]
    if value2 == nil or equals(value1, value2) == false then
      return false
    end
    keySet[key1] = true
  end

  for key2, _ in pairs(o2) do
    if not keySet[key2] then return false end
  end

  return true
end
_G.equals = equals

------------------------------------------------------------------------------------------------------------------------
-- Functions --
------------------------------------------------------------------------------------------------------------------------

local function shuffle(table)
  for i = 1, #table do
    local ndx0 = math.random( 1, #table )
    table[ ndx0 ], table[ i ] = table[ i ], table[ ndx0 ]
  end
  return table
end
_G.shuffle = shuffle

local getDepth; getDepth = function(group, c)
  local depth = c
  if group.numChildren then
    for i = 1,group.numChildren do
      local d = getDepth(group[i], c+1)
      depth = depth < d and d or depth
    end
  end
  return depth
end
_G.getDepth = getDepth


local jsonParser = require("json")
function _G.jsonImport(fileName, directory)
	local path = system.pathForFile(fileName, directory)
  local file = path and io.open( path, "r" )

  if file then
    -- print( "Loading JSON file: "..fileName )
    local settingsImport = file:read( "*a")
    io.close(file)
    return jsonParser.decode(settingsImport)
  end

  -- print( "Could not find file: "..fileName)
  return nil
end


function _G.jsonExport(fileName, content)
  local jsonContent = jsonParser.encode(content)
  local path = system.pathForFile( fileName..".json", system.DocumentsDirectory )
  local file = path and io.open( path, "w+" )

  if file then
    file:write(jsonContent)
    io.close(file)
    -- print( "Saved JSON file: "..fileName )
    return true
  end

  -- print("Error: Could not save file: "..fileName..".json")
  return false
end


function string:capitalize()
  if type(self) ~= "string" then error("String expected, got "..type(self)) end
  return (self:gsub("^%l", string.upper))
end


function string:split(sep)
   local sep, fields = sep or ":", {}
   local pattern = string.format("([^%s]+)", sep)
   self:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
end


local fcomp_default = function( a,b ) return a < b end
function table.bininsert(t, value, fcomp)
   -- Initialize compare function
   local fcomp = fcomp or fcomp_default
   --  Initialize numbers
   local iStart,iEnd,iMid,iState = 1,#t,1,0
   -- Get insert position
   while iStart <= iEnd do
      -- calculate middle
      iMid = math.floor( (iStart+iEnd)/2 )
      -- compare
      if fcomp( value,t[iMid] ) then
         iEnd,iState = iMid - 1,0
      else
         iStart,iState = iMid + 1,1
      end
   end
   table.insert( t,(iMid+iState),value )
   return (iMid+iState)
end

local defComp = function(a, b)
  return a.y < b.y
end

function _G.sortGroup(group, comp)
  comp = comp or defComp
  local objects = {}
  for i = 1, group.numChildren do
    objects[#objects+1] = group[i]
  end
  table.sort( objects, comp)
  for i = 1, #objects do
    group:insert( objects[i] )
  end
end

------------------------------------------------------------------------------------------------
--object.fill.effect = "filter.custom.glint"
--object.fill.effect.intensity = 1.0 -- how bright the glint is
--object.fill.effect.size = 0.1 -- how wide the glint is as a percent of the object
--object.fill.effect.tilt = 0.2 -- tilt the direction of the glint
--object.fill.effect.speed = 1.0 -- how fast the glint moves across the object

local kernel = {}

kernel.language = "glsl"
kernel.category = "filter"
-- By default, the group is "custom"
--kernel.group = "custom"
kernel.name = "glint"
kernel.isTimeDependent = true

-- Expose effect parameters using vertex data
kernel.vertexData   = {
  {
    name = "intensity",
    default = 0.65,
    min = 0,
    max = 1,
    index = 0,  -- This corresponds to "CoronaVertexUserData.x"
  },
  {
    name = "size",
    default = 0.1,
    min = 0,
    max = 1,
    index = 1,  -- This corresponds to "CoronaVertexUserData.y"
  },
  {
    name = "tilt",
    default = 0.2,
    min = 0.0,
    max = 2.0,
    index = 2,  -- This corresponds to "CoronaVertexUserData.z"
  },
  {
    name = "speed",
    default = 1.0,
    min = 0.1,
    max = 10.0,
    index = 3,  -- This corresponds to "CoronaVertexUserData.w"
  },
}

kernel.fragment =
[[
P_COLOR vec4 FragmentKernel( P_UV vec2 texCoord )
{
    P_COLOR float intensity = CoronaVertexUserData.x;
    P_COLOR vec4 texColor = texture2D( CoronaSampler0, texCoord );

    // Grab a float from the total time * speed
    P_COLOR float glint = floor(20.0 * mod(CoronaVertexUserData.w * CoronaTotalTime, 4.0)) * 0.05;
    glint = glint + (CoronaVertexUserData.z * sin(texCoord.y - 0.5));

    // Calculate where the glint is at
    P_COLOR float size = CoronaVertexUserData.y * 0.5;
    intensity = (step(texCoord.x, glint + size) - step(texCoord.x, glint - size)) * intensity * texColor.a;

    // Add the intensity
    texColor.rgb += intensity;

    // Modulate by the display object's combined alpha/tint.
    return CoronaColorScale( texColor );
}
]]

graphics.defineEffect( kernel )