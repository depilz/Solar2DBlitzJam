local composer = require("composer")

local gameShortcuts = _G.game.shortcuts

-- ---------------------------------------------------------------------------------------------------------------------
-- ------  -----  ---- -- --                - -- --- Main Game --- -- -                   -- -- ---  ----  -------------
-- ---------------------------------------------------------------------------------------------------------------------

local scene = composer.newScene()

function scene:create( event, params )
  self.background = display.newRect(self.view, screen.centerX, screen.centerY, screen.width, screen.height)
  self.background:setFillColor(0)
end


function scene:show( e, params )
  if e.phase == "will"  then

  elseif e.phase == "did"  then

  end
end


function scene:hide(e)
  if e.phase == "will" then
  
  end
end


function scene:destroy( event )

end


scene:addEventListener( "create",  scene )
scene:addEventListener( "show",    scene )
scene:addEventListener( "hide",    scene )
scene:addEventListener( "destroy", scene )

return scene
