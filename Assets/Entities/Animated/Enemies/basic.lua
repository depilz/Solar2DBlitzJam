local Super  = require("Assets.Entities.Animated.Enemies.enemy")

------------------------------------------------------------------------------------------------------------------------
-- Enemy --
------------------------------------------------------------------------------------------------------------------------

local Enemy = Class('basic-enemy', Super)

Enemy.breed = "basic"
Enemy.__animationFile   = require("Assets.Entities.Animated.Enemies.Basic.animation")
Enemy._avoidWalkRotation = true

return Enemy
