local composer = require("composer")

local LoadingScreen = require("Utils.loadingScreen")

local stories = {
  levelController = "Assets.GameLogic.levelController",
}

-- ---------------------------------------------------------------------------------------------------------------------
-- ------  -----  ---- -- --               - -- ---   My Game   --- -- -                  -- -- ---  ----  -------------
-- ---------------------------------------------------------------------------------------------------------------------

local Game = {}
_G.game = Game

Game.shortcuts = {}

Game.time  = require("Utils.time")
Game.music = require("Assets.Audio.music")

_G.transition2    = require("Utils.transition2")

function Game.start()
  Game.time.start()

  display.setDefault("background", 0)

  Game.layers = {}
  Game.goTo("mainGame")
end


function Game.run(controller, params)
  Game.controller = require(stories[controller]).start(params)
  return Game.controller
end


function Game.getScene(scene)
  return composer.getScene("Assets.Scenes."..(scene or Game._currentScene))
end


function Game.load(loader, onComplete)
  local cb = function()
    loader()
    LoadingScreen.hide(nil, onComplete)
  end
  LoadingScreen.show(cb)
end


function Game.goTo(scene, params)
  Game._currentScene = scene
  composer.gotoScene("Assets.Scenes."..scene, {params = params})
  Game.currentScene = composer.getScene("Assets.Scenes."..scene)

  return Game.shortcuts
end


function Game.resume()
  Game.isPaused = false
  return Game.time.resume()
end


function Game.pause()
  Game.isPaused = true
  return Game.time.pause()
end


function Game.save()
  _G.savedData.setValue("state", Game.state:getData())
  _G.savedData.save()
end


-- System events -------------------------------------------------------------------------------------------------------

function Game.onSystemEvent(e)
  if e.type == "applicationSuspend" then
    Game.suspend()
  end
end
Runtime:addEventListener( "system", Game.onSystemEvent )


function Game.suspend()
  if Game.pauseOnSuspend then
    Game.time.pause()
  end
end


return Game
