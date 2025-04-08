local Pathfinding = require("libraries.pathfinding")
require "entities.bee"
QueenBee = Bee:extend()

function QueenBee:new(home, x, y)
    Bee.new(self) --parent constructor

    --overriding
    self.image = love.graphics.newImage("sprites/bee.png") --different sprite
    self.x = x
    self.y = y
    self.scale = 0.5 --queen bee is larger
    self.width = self.image:getWidth() * self.scale
    self.height = self.image:getHeight() * self.scale

    self.homeHive = home or hive

    --combat properties
    self.attackDamage = 3 --more damage than worker bees
    self.attackRange = 15 --smaller attack radius, needs to be very close

    --queen specific properties
    self.is_queen = true
    self.is_bee = true --for enemies and the like
    self.age = 0 --starts  at 0
    self.maxAge = 100 --max age, reached at 20 ingame minutes
    self.ageTimer = 0
    self.agingRate = 100 / (20 * 60)

    --queen doesn't forage
    self.hasNectar = false
    self.canForage = false

    --health
    self.health = 10
    self.maxHealth = 10

    --movement
    self.state = "moving" --initially moves to hive
    self.wanderRadius = 50 --stays close to hive
    self.targetX = self.homeHive.x
    self.targetY = self.homeHive.y
end

function QueenBee:update(dt)
    --queen aging
    self.ageTimer = self.ageTimer + dt
    if self.ageTimer >= 1 then
        self.age = self.age + self.agingRate
        self.ageTimer = 0

        if self.age > self.maxAge then
            self.age = self.maxAge
        end
    end

    self:updateState(dt)
    self:move(dt)

    --starts losing health when age is 80
    if self.age > 80 then
        self.healthTimer = (self.healthTimer or 0) + dt
        if self.healthTimer >= 10 then
            self.health = math.max(1, self.health - 1)
            self.healthTimer = 0
        end
    end
end

function QueenBee:updateState(dt)
    if not self.homeHive then return end

    self.stateTimer = (self.stateTimer or 0) + dt

    if self.state == "guarding" then
        --moves around hive but doesnt leave
        if self.stateTimer > 5 then
            local angle = math.random() * math.pi * 2
            local distance = math.random() * self.wanderRadius
            self.targetX = self.homeHive.x + math.cos(angle) * distance
            self.targetY = self.homeHive.y + math.sin(angle) * distance
            self.state = "moving"
            self.stateTimer = 0
        end
    elseif self.state == "moving" then
        local dx = self.targetX - self.x
        local dy = self.targetY - self.y
        local distance = math.sqrt(dx * dx + dy * dy)

        if distance < 2 then
            self.state = "guarding"
            self.stateTimer = 0
        end
    end

    --check for threats
    if wasp and wasp.visible and self:isInRange(wasp) then
        self.state = "attacking"
        self.target = wasp
    elseif honeybadger and honeybadger.visible and self:isInRange(honeybadger) then
        self.state = "attacking"
        self.target = honeybadger
    else
        --returning to guarding
        if self.state == "attacking" then
            self.state = "guarding"
            self.stateTimer = 0
        end
    end
end

function QueenBee:isInRange(target)
    local dist = math.sqrt((self.x - target.x)^2 + (self.y - target.y)^2)
    return dist <= self.attackRange
end

function QueenBee:move(dt)
    if self.state == "moving" and self.targetX and self.targetY then
        local dx = self.targetX - self.x
        local dy = self.targetY - self.y
        local distance = math.sqrt(dx * dx + dy * dy)

        if distance > 2 then
            local angle = math.atan2(dy, dx)
            self.x = self.x + math.cos(angle) * self.speed * dt
            self.y = self.y + math.sin(angle) * self.speed * dt
        end
    elseif self.state == "attacking" and self.target then
        local dx = self.target.x - self.x
        local dy = self.target.y - self.y
        local distance = math.sqrt(dx * dx + dy * dy)

        if distance > self.attackRange then
            local angle = math.atan2(dy, dx)
            self.x = self.x + math.cos(angle) * self.speed * dt
            self.y = self.y + math.sin(angle) * self.speed * dt
        else if self.attackTimer >= self.attackCooldown then
            self.attackTimer = 0
            if self.target.takeDamage then
                self.target:takeDamage(self.attackDamage, self)
            end
        end
    end
end

function QueenBee:draw()
    love.graphics.draw(self.image, self.x, self.y, 0, self.scale, self.scale, self.image:getWidth()/2, self.image:getHeight()/2)

    if debugMode then
        --health bar
        local barWidth = 40
        local barHeight = 5
        local healthPercentage = self.health / self.maxHealth

        love.graphics.setColor(1, 0, 0, 0.7)
        love.graphics.rectangle("fill", self.x - barWidth/2, self.y - 20, barWidth, barHeight)

        love.graphics.setColor(0, 1, 0, 0.7)
        love.graphics.rectangle("fill", self.x - barWidth/2, self.y - 20, barWidth * healthPercentage, barHeight)

        --age bar
        local agePercentage = self.age / self.maxAge

        love.graphics.setColor(0, 0, 1, 0.7)
        love.graphics.rectangle("fill", self.x - barWidth/2, self.y - 15, barWidth, barHeight)

        love.graphics.setColor(1, 1 - agePercentage, 0, 0.7)
        love.graphics.rectangle("fill", self.x - barWidth/2, self.y - 15, barWidth * agePercentage, barHeight)

        --debug info
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print(string.format("Queen\nHealth: %d/%d\nAge: %.1f%%\nState: %s", self.health, self.maxHealth, self.age, self.state), self.x + 20, self.y - 30)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

end