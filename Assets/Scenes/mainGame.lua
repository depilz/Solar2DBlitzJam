local composer = require("composer")

local gameShortcuts = _G.game.shortcuts

local Grid = require("Assets.Scenes.MainGame.grid")
local Grey = require("Assets.Scenes.MainGame.grey")
local Enemy = require("Assets.Scenes.MainGame.enemy")
local Health = require("Assets.Scenes.MainGame.health")

-- ---------------------------------------------------------------------------------------------------------------------
-- ------  -----  ---- -- --                - -- --- Main Game --- -- -                   -- -- ---  ----  -------------
-- ---------------------------------------------------------------------------------------------------------------------

local scene = composer.newScene()

function scene:create( event, params )
    self:__addBackground()
    self:__addGrid()
    self:__addPlayer()
    self:__addEnemies()
    self:__addHealth()
end


function scene:__addBackground()
    self.background = display.newGroup()
    self.view:insert(self.background)
    
    self.backgroundImage = display.newImageRect(self.background, "Assets/Art/bg.png", screen.width, screen.height)
    self.backgroundImage.x = screen.centerX
    self.backgroundImage.y = screen.centerY
    --self.backgroundImage:setFillColor(0.2, 0.1, 0.2)
end

function scene:__addGrid()
    self.grid = Grid:new{
        parent = self.background,
        x      = screen.centerX,
        y      = screen.centerY,

        rows       = 10,
        columns    = 10,
        width      = 700,
        height     = 600,
    }
end

function scene:__addPlayer()
    self.grey = Grey:new{
        parent = self.grid.group,
        
        grid   = self.grid,
        col    = 5,
        row    = 5,
    }
end

function scene:__addHealth()
    self.health = Health:new{
        parent = self.view,
        player = self.grey,
    }
end

function scene:__addEnemies()
    self._whites = List()
    self._blacks = List()
    
    local numberOfEnemies = self.grid.numRows
    for i = 1, numberOfEnemies do
        local white = Enemy:new{
            parent = self.grid.group,
            color = "white",
            grid   = self.grid,
            col    = 1,
            row    = i,
        }
        local black = Enemy:new{
            parent = self.grid.group,
            color  = "black",
            grid   = self.grid,
            col    = self.grid.numCols,
            row    = i,
        }

        self._whites:append(white)
        self._blacks:append(black)
    end
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
