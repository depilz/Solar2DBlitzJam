
local fireImageSheet = graphics.newImageSheet( "Assets/Entities/Animated/Towers/Animation/fire.png", {
  width              = 509,
  height             = 688,
  numFrames          = 1,
  sheetContentWidth  = 509,
  sheetContentHeight = 688,
})
local idleImageSheet = graphics.newImageSheet( "Assets/Entities/Animated/Towers/Animation/idle.png", {
  width              = 200,
  height             = 200,
  numFrames          = 16,
  sheetContentWidth  = 800,
  sheetContentHeight = 800,
})
local idle_area_damageImageSheet = graphics.newImageSheet( "Assets/Entities/Animated/Towers/Animation/idle_area_damage.png", {
  width              = 200,
  height             = 200,
  numFrames          = 2,
  sheetContentWidth  = 400,
  sheetContentHeight = 200,
})
local mergingImageSheet = graphics.newImageSheet( "Assets/Entities/Animated/Towers/Animation/merging.png", {
  width              = 200,
  height             = 200,
  numFrames          = 9,
  sheetContentWidth  = 600,
  sheetContentHeight = 600,
})
local merging_area_damageImageSheet = graphics.newImageSheet( "Assets/Entities/Animated/Towers/Animation/merging_area_damage.png", {
  width              = 200,
  height             = 200,
  numFrames          = 9,
  sheetContentWidth  = 600,
  sheetContentHeight = 600,
})
local merging_endImageSheet = graphics.newImageSheet( "Assets/Entities/Animated/Towers/Animation/merging_end.png", {
  width              = 400,
  height             = 400,
  numFrames          = 14,
  sheetContentWidth  = 1600,
  sheetContentHeight = 1600,
})

return {
  imageSheet   = idleImageSheet,
  sequenceData = {
    { name = "fire", sheet = fireImageSheet, start=1, count=1, time = 1/15*1000, loopCount = 0},
    { name = "idle", sheet = idleImageSheet, start=1, count=16, time = 16/15*1000, loopCount = 0},
    { name = "idle_area_damage", sheet = idle_area_damageImageSheet, start=1, count=2, time = 2/2*1000, loopCount = 0},
    { name = "merging", sheet = mergingImageSheet, start=1, count=9, time = 9/15*1000, loopCount = 1},
    { name = "merging_end", sheet = merging_endImageSheet, start=1, count=14, time = 14/15*1000, loopCount = 1},
  }
}
