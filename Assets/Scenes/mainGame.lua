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
    self:displayControls()

    game.time.subscribe(self)

    self.grey:addEventListener("onGreyDie", self)
end


function scene:onGreyDie()
    display.newText(self.view, "You lose!", screen.centerX, screen.centerY, native.systemFont, 100)
    game.time.unsubscribe(self)
end

function scene:onEnemyDied(params)
    if params.target.color == "white" then
        whites:remove_value(params.target)
    else
        blacks:remove_value(params.target)
    end
end

function scene:enterFrame()
    local whiteWins = true
    local blackWins = true
    for k, enemy in pairs(blacks) do
        if enemy.isEnemy then
            whiteWins = false
            break
        end
    end
    
    for k, enemy in pairs(whites) do
        if enemy.isEnemy then
            blackWins = false
            break
        end
    end

    if whiteWins then
        display.newText(self.view, "the good guys win!", screen.centerX, screen.centerY, native.systemFont, 100)
        game.time.unsubscribe(self)
    elseif blackWins then
        display.newText(self.view, "the evil guys win!", screen.centerX, screen.centerY, native.systemFont, 100)
        game.time.unsubscribe(self)
    end
end

function scene:__addBackground()
    self.background = display.newGroup()
    self.view:insert(self.background)
    
    self.backgroundImage = display.newImageRect(self.background, "Assets/Art/bg.png", screen.width, screen.height)
    self.backgroundImage.x = screen.centerX
    self.backgroundImage.y = screen.centerY
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

    _G.whites = self._whites
    _G.blacks = self._blacks

    local numberOfEnemies = self.grid.numRows
    for i = 1, numberOfEnemies do
        local white = Enemy:new{
            parent = self.grid.group,
            color = "white",
            grid   = self.grid,
            col    = 1,
            row    = i,
        }
        white:addEventListener("onEnemyDied", self)

        local black = Enemy:new{
            parent = self.grid.group,
            color  = "black",
            grid   = self.grid,
            col    = self.grid.numCols,
            row    = i,
        }
        black:addEventListener("onEnemyDied", self)

        self._whites:append(white)
        self._blacks:append(black)
    end
end


function scene:displayControls()
    local text = display.newText{
        text = [[
↑ - move up
→ - move right
← - move left
↓ - move down

When you collect an essence 
you can use it to:
A - Attack
H - Heal

]],
    fontSize = 50,
    parent = self.view,
    x = screen.centerX,
    y = screen.centerY,
    }

    transition.to(text, {
        delay = 6000,
        time = 1000,
        alpha = 0,
        onComplete = function()
            text:removeSelf()
        end
    })
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
