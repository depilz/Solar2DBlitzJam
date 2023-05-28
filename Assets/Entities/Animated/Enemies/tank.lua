local Super  = require("Assets.Entities.Animated.Enemies.enemy")

------------------------------------------------------------------------------------------------------------------------
-- Enemy --
------------------------------------------------------------------------------------------------------------------------

local Enemy = Class('Tank-enemy', Super)

Enemy.breed = "tank"
Enemy.__animationFile = require("Assets.Entities.Animated.Enemies.Tank.animation")

return Enemy
