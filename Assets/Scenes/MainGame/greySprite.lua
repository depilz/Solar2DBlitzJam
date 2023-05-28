local idleImageSheet = graphics.newImageSheet( "Assets/Entities/Player/grey_idle.png", {
  width              =  90,
  height             =  37,
  numFrames          =   9,
  sheetContentWidth  = 810,
  sheetContentHeight =  37,
})
local dashImageSheet = graphics.newImageSheet( "Assets/Entities/Player/grey_dash.png", {
  width              = 108,
  height             =  37,
  numFrames          =   5,
  sheetContentWidth  = 540,
  sheetContentHeight =  37,
})
local deathImageSheet = graphics.newImageSheet( "Assets/Entities/Player/grey_death.png", {
  width              = 90,
  height             =  37,
  numFrames          =   6,
  sheetContentWidth  = 540,
  sheetContentHeight =  37,
})

return {
  imageSheet   = idleImageSheet,
  sequenceData = {
    { name = "idle", sheet = idleImageSheet, start=1, count=9, time = 16/15*1000, loopCount = 0},
    { name = "dash", sheet = dashImageSheet, start=1, count=5, time = 500, loopCount = 1},
    { name = "death", sheet = deathImageSheet, start=1, count=6, time = 500, loopCount = 1},
  }
}
