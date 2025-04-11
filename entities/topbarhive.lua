TopBarHive = Hive:extend()

function TopBarHive:new()
    self.id = #Entities + 1
    self.image = love.graphics.newImage("sprites/top_bar_hive.png")

    self.x = 200
    self.y = 315
    self.scale = 0.3
    self.width = self.image:getWidth() * self.scale
    self.height = self.image:getHeight() * self.scale
    self.honey = 10
    self.beeCount = 1 --set to 1 for now, for the 'default' main state hard spawned bee
    self.maxBeeCount = 5  --maximum number of bees - could be level dependent? or might remove later?

    --hive health variables
    self.health = 150
    self.maxHealth = 150

    --type check flag
    self.type = "hive"
    self.visible = true

    --taking damage effect
    self.flashTimer = 0
    self.flashDuration = 0.2

    self.hasQueen = false
end

function TopBarHive:updateHoneyProduction()
    --if there is a queen, calculate the production rate
    if self.hasQueen then
        self.honeyProductionRate = 1.5
        --basing productivity off queen's health and age
        local queenHealthFactor = self.QueenBee.health * 0.5
        local queenAgeFactor = math.max(0, 100 - self.QueenBee.age) * 0.2

        local healthPercentage = self.QueenBee.health / self.QueenBee.maxHealth
        local ageImpact = 1 - (self.QueenBee.age / self.QueenBee.maxAge) * 0.5
        self.honeyProductionRate = 1.0 * healthPercentage * ageImpact
    else
        self.honeyProductionRate = 0.8 --decreased production rate without queen
    end
end

function TopBarHive:depositNectar()
    self.honey = self.honey + (1 * (self.honeyProductionRate or 1.0))
    return false
end

return TopBarHive
