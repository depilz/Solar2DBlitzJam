------------------------------------------------------------------------------------------------------------------------
-- Loading Screen --
------------------------------------------------------------------------------------------------------------------------

local LoadingScreen = {}

local loadingScreen
local splashScreen

local function nextFrame(cb)
  if not cb then return end

  return function()
    timer.performWithDelay(1,cb)
  end
end

function LoadingScreen.show(onComplete)
  if loadingScreen then return false end

  loadingScreen = display.newGroup()
  local background = display.newRect(loadingScreen, screen.centerX, screen.centerY, screen.edgeX-screen.originX, screen.edgeY-screen.originY)
  background:setFillColor(0)
  background.isHitTestable = true
  background:addEventListener( "touch", function() return true end )
  background:addEventListener( "tap", function() return true end )
  -- display.newText(loadingScreen, "Loading...", screen.centerX, screen.centerY-9, native.systemFontBold, 18)
  loadingScreen.alpha = 0

  transition.to(loadingScreen, {
    time       = 200,
    alpha      = 1,
    transition = easing.outQuad,
    onComplete = nextFrame(onComplete)
  })

  if splashScreen then splashScreen:toFront() end

  return true
end


function LoadingScreen.showSplashScreen()
  if splashScreen then return false end

  splashScreen = display.newGroup()

  local image = display.newImage(splashScreen, "singnCo_logo.png")
  local scale = math.max(screen.width/image.width, screen.height/image.height)*1.01
  image.xScale,image.yScale = scale, scale
  image.x, image.y = screen.centerX, screen.centerY
  splashScreen:addEventListener( "touch", function() return true end )
  splashScreen:addEventListener( "tap", function() return true end )

  return true
end


function LoadingScreen.hide(time, onComplete)
  transition.to(loadingScreen, {
    time       = time or 800,
    alpha      = 0,
    transition = easing.outQuad,
    onCancel   = function()
      loadingScreen:removeSelf()
      loadingScreen = nil
    end,
    onComplete    = function()
      if onComplete then onComplete() end
      loadingScreen:removeSelf()
      loadingScreen = nil
    end
  })
end


function LoadingScreen.hideSplashScreen(time)
  transition.to(splashScreen, {
    time     = time or 0,
    alpha    = 0,
    onCancel = function()
      splashScreen:removeSelf()
      splashScreen = nil
    end,
    onComplete = function()
      splashScreen:removeSelf()
      splashScreen = nil
    end
  })
end


function LoadingScreen.toFront()
  loadingScreen:toFront()
end


function LoadingScreen.splashScreenToFront()
  splashScreen:toFront()
end


return LoadingScreen
