Hive = Object:extend()

function Hive:new()
    self.image = love.graphics.newImage("sprites/log_hive.png")
    self.x = 200
    self.y = 315
    self.scale = 0.3
    self.width = self.image:getWidth() * self.scale
    self.height = self.image:getHeight() * self.scale
    self.honey = 10
    self.beeCount = 1 --set to 1 for now, for the 'default' main state hard spawned bee
    self.maxBeeCount = 5  --maximum number of bees - could be level dependent? or might remove later?

    --hive health variables
    self.health = 100
    self.maxHealth = 100

    --type check flag
    self.is_hive = true
    self.visible = true

    --taking damage effect
    self.flashTimer = 0
    self.flashDuration = 0.2

    --collider data
    self.collider = nil
end

function Hive:update(dt)

    self:updateHoneyProduction()

    --update damage flash effect
    if self.flashTimer > 0 then
        self.flashTimer = self.flashTimer - dt
        if self.flashTimer <= 0 then
            self.flashTimer = 0
        end
    end

    if self.health <= 0 then
        self.visible = false
        if self.collider ~= nil then
            self.collider:destroy()
            self.collider = nil
        end
        table.remove(Hives, Hives[self])

    end

end

function Hive:draw()
    if not self.visible then return end
    --draw with damage flash effect if being damaged
    if self.flashTimer > 0 then
        love.graphics.setColor(1, 0.5, 0.5, 1)  --reddish tint
    else
        love.graphics.setColor(1, 1, 1, 1)
    end

    --drawing hive on the center of its png
    love.graphics.draw(self.image, self.x, self.y, 0, self.scale, self.scale, self.image:getWidth() / 2, self.image:getHeight() / 2)
    love.graphics.setColor(1, 1, 1, 1)

    if DebugMode then
        --drawing the health bar
        local barWidth = 50
        local barHeight = 5
        local healthPercentage = self.health / self.maxHealth

        --red background
        love.graphics.setColor(1, 0, 0, 0.7)
        love.graphics.rectangle("fill", self.x - barWidth/2, self.y - 10 - self.height/2, barWidth, barHeight)

        --green foreground
        love.graphics.setColor(0, 1, 0, 0.7)
        love.graphics.rectangle("fill", self.x - barWidth/2, self.y - 10 - self.height/2, barWidth * healthPercentage, barHeight)

        --printing hive's debug info
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(string.format("Health: %d/%d\nHoney: %d\nBees: %d", self.health, self.maxHealth, self.honey, self.beeCount), self.x - 30, self.y - 40 - self.height/2)
    end
end

function Hive:updateHoneyProduction()
    --if queen bee
    local hasQueen = false
    for _, b in ipairs(Bees) do
        if b.is_queen then
            hasQueen = true
            self.QueenBee = b
            break
        end
    end

    --if there is a queen, calculate the production rate
    if hasQueen then
        self.honeyProductionRate = 1.0
        --basing productivity off queen's health and age
        local queenHealthFactor = self.QueenBee.health * 0.5
        local queenAgeFactor = math.max(0, 100 - self.QueenBee.age) * 0.2

        local healthPercentage = self.QueenBee.health / self.QueenBee.maxHealth
        local ageImpact = 1 - (self.QueenBee.age / self.QueenBee.maxAge) * 0.5
        self.honeyProductionRate = 1.0 * healthPercentage * ageImpact
    else
        self.honeyProductionRate = 0.4 --decreased production rate without queen
    end
end

function Hive:depositNectar(flowerHarvested)
    self.honey = self.honey + (flowerHarvested.modifier * (self.honeyProductionRate or 1.0))
    return false
end

--function that handles taking damage
function Hive:takeDamage(damage, attacker)
    self.health = math.max(0, self.health - damage)
    self.flashTimer = self.flashDuration
    --print("Hive took " .. damage .. " damage, health now: " .. self.health)
end

return Hive