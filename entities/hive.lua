Hive = Object:extend()

function Hive:new(x, y)
    self.id = #Entities + 1
    self.image = love.graphics.newImage("sprites/log_hive.png")
    self.x = x or 200
    self.y = y or 315
    self.scale = 0.3
    self.width = (self.image:getWidth() * self.scale)-10
    self.height = (self.image:getHeight() * self.scale)-10
    self.honey = 10
    self.beeCount = 1 --set to 1 for now, for the 'default' main state hard spawned bee
    self.maxBeeCount = 5  --maximum number of bees - could be level dependent? or might remove later?
    self.hasQueen = false

    --hive health variables
    self.health = 100
    self.maxHealth = 100

    --type check flag
    self.type = "hive"
    self.visible = true

    --taking damage effect
    self.flashTimer = 0
    self.flashDuration = 0.2

    --collider data
    self.collider = nil

    --added
    return self
end

function Hive:update(dt)
    -- If hive is hidden, skip update
    if not self.visible or self == nil then return end

    self:updateHoneyProduction()

    --update damage flash effect
    if self.flashTimer > 0 then
        self.flashTimer = self.flashTimer - dt
        if self.flashTimer <= 0 then
            self.flashTimer = 0
        end
    end

    if self.health <= 0 then
        -- For each bee that has this hive as their homeHive, set to nil
        for _, b in ipairs(Entities) do
            if b.type == "bee" and b.homeHive == self then
                b.homeHive = nil
            end
        end

        -- If there is a queen bee, remove it from the hive
        if self.QueenBee ~= nil then
            self.QueenBee.homeHive = nil
        end

        self.visible = false

        if self.collider ~= nil then
            self.collider:destroy()
            self.collider = nil
        end
        -- Find the current index of this hive in the Entities table
        for i, entity in ipairs(Entities) do
            if entity == self then
                table.remove(Entities, i)
                break
            end
        end

        self = nil

    end

end

function Hive:draw()
    if not self.visible or self == nil then return end
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
    --if there is a queen, calculate the production rate
    if self.hasQueen then
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
    if self.QueenBee then
        self.QueenBee:takeDamage(damage, attacker)
    end
end

-- ********* DELETE AFTER ENTITIES CAN BE LOADED *********
--added functions to save/load
-- added function to serialize
--[[function Hive:serialize()
    return {
        type = self.type,
        x = self.x,
        y = self.y,
        health = self.health,
        honey = self.honey,
        hasQueen = self.hasQueen,
        beeCount = self.beeCount,
    }
end

-- deserilize for loading purposes
function Hive.deserialize(data)
    -- constructor shoudl reintialize its functionality but its not!
    local hive = Hive(data.x, data.y)
    hive.health = data.health
    hive.honey = data.honey
    hive.hasQueen = data.hasQueen
    hive.beeCount = data.beeCount
    return hive
end]]

return Hive