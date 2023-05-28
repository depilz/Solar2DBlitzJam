local Super  = require("Assets.Entities.Animated.Enemies.enemy")

------------------------------------------------------------------------------------------------------------------------
-- Enemy --
------------------------------------------------------------------------------------------------------------------------

local Enemy = Class('Runner-enemy', Super)

Enemy.breed = "runner"
Enemy.__aim = true
Enemy.__animationFile = require("Assets.Entities.Animated.Enemies.Runner.animation")

return Enemy
