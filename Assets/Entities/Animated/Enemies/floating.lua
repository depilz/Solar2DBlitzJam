local Super  = require("Assets.Entities.Animated.Enemies.enemy")

------------------------------------------------------------------------------------------------------------------------
-- Enemy --
------------------------------------------------------------------------------------------------------------------------

local Enemy = Class('floating-enemy', Super)

Enemy.breed = "floating"
Enemy.__animationFile    = require("Assets.Entities.Animated.Enemies.Floating.animation")

return Enemy
