local Screen = {}


local function update()
    Screen.width         = display.actualContentWidth
    Screen.height        = display.actualContentHeight
    Screen.contentWidth  = display.contentWidth
    Screen.contentHeight = display.contentHeight
    Screen.centerX       = display.contentWidth*0.5
    Screen.centerY       = display.contentHeight*0.5
    Screen.originX       = display.screenOriginX
    Screen.originY       = display.screenOriginY
    Screen.edgeX         = display.screenOriginX+display.actualContentWidth
    Screen.edgeY         = display.screenOriginY+display.actualContentHeight
    Screen.safeX         = display.safeScreenOriginX
    Screen.safeY         = display.safeScreenOriginY
    Screen.safeEdgeX     = display.safeScreenOriginX+display.safeActualContentWidth
    Screen.safeEdgeY     = display.safeScreenOriginX+display.safeActualContentWidth
    Screen.safeWidth     = display.safeActualContentWidth
    Screen.safeHeight    = display.safeActualContentHeight
end

Runtime:addEventListener("orientation", update)

update()

return Screen