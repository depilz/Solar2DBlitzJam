local idleImageSheet = graphics.newImageSheet( "Assets/Entities/Enemy/Light_Enemy_1.png", {
  width              =  28,
  height             =  20,
  numFrames          =   5,
  sheetContentWidth  = 140,
  sheetContentHeight =  20,
})

local darkIdleImageSheet = graphics.newImageSheet( "Assets/Entities/Enemy/Dark_Enemy_1.png", {
  width              =  28,
  height             =  20,
  numFrames          =   5,
  sheetContentWidth  = 140,
  sheetContentHeight =  20,
})

local lightDeathImageSheet = graphics.newImageSheet( "Assets/Entities/Enemy/Light_Enemy_1_Death.png", {
  width              =  32,
  height             =  20,
  numFrames          =   6,
  sheetContentWidth  = 192,
  sheetContentHeight =  20,
})

local darkDeathImageSheet = graphics.newImageSheet( "Assets/Entities/Enemy/Dark_Enemy_1_Death.png", {
  width              =  32,
  height             =  20,
  numFrames          =   6,
  sheetContentWidth  = 192,
  sheetContentHeight =  20,
})

return {
  imageSheet   = idleImageSheet,
  sequenceData =
  {
    { name = "lightidle", sheet = lightIdleImageSheet, start=1, count=5, time = 16/15*1000, loopCount = 0},
    { name = "darkidle", sheet = darkIdleImageSheet, start=1, count=5, time = 16/15*1000, loopCount = 0},
    { name = "lightdeath", sheet = darkIdleImageSheet, start=1, count=6, time = 16/15*1000, loopCount = 1},
    { name = "darkdeath", sheet = darkIdleImageSheet, start=1, count=6, time = 16/15*1000, loopCount = 1},
  }
}
