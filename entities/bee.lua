local Pathfinding = require("libraries.pathfinding")

Bee = Object:extend()

function Bee:new(home, x, y)
    --self.image = love.graphics.newImage("sprites/bee.png")
    self.animation = beeAnimation()
    self.x = x
    self.y = y
    self.scale = 1
    self.width = 40
    self.height = 40
    self.speed = 60      --slower than wasps and honey badgers
    self.state = "foraging"
    self.hasNectar = false
    self.visible = true

    -- The hive closest to the Bee when placed is calculated and assigned.
    -- This means the bee will always return nectar here.
    self.homeHive = home or hive
    -- The closest flower to the Bee is calculated on update based on the path they take.
    self.closestFlower = flower
    -- The last flower they harvested.
    -- We keep this value so we can determine how much honey should be produced since flower type impacts rate.
    self.lastFlower = nil

    -- Class identifier
    self.is_bee = true

    --initalizing pathfinding
    self.pathfinding = Pathfinding
    self.pathfinding:initialize()
    self.current_path = nil
    self.current_path_index = 1

    --nectar variables
    self.nectarCollectionTime = 2  --time to collect from flower
    self.nectarTimer = 0

    --health and speed properties
    self.health = 3
    self.maxHealth = 3
    self.isRetreating = false
    self.retreatSpeed = 120   --faster when retreating
    self.normalSpeed = 60     --normal speed for foraging
    self.speed = self.normalSpeed

    --combat stats
    self.attackDamage = 0.5  --default 0.5
    self.attackRange = 25
    self.attackCooldown = 1.5 --default 1.5
    self.attackTimer = 0
    self.isAggressive = false  --changes based on hive threat

    --awareness radius
    self.threatDetectionRange = 150  --how far bee can detect enemies
    self.hiveProtectionRange = 100   --how far from hive the bee will defend
end

function Bee:update(dt)

    self.animation.currentTime = self.animation.currentTime + dt
    if self.animation.currentTime >= self.animation.duration then
        self.animation.currentTime = self.animation.currentTime - self.animation.duration
    end

    self:updateCombat(dt)
    self:updateState(dt)
    self:checkThreatLevel()
end

function Bee:updateState(dt)
    --setting the bee's state to 'retreating' when its health is low
    if self.health <= 0 and not self.isRetreating then
        self.isRetreating = true
        self.speed = self.retreatSpeed
        self.state = "retreating"
        self.current_path = nil
        return
    end

    --returning to the hive
    if self.state == "retreating" then
        self:moveToHive(dt)
        return
    end

    --becoming defensive if there are threats near the hive
    if self.state ~= "defending" and self.homeHive then
        local distToHive = math.sqrt((self.x - self.homeHive.x)^2 + (self.y - self.homeHive.y)^2)
        if distToHive < self.hiveProtectionRange then
            local threat = self:findNearestThreat()
            if threat then
                self.state = "defending"
                self.target = threat
                self.isAggressive = true
                return
            end
        end
    end

    --check for if current target is fleeing
    if self.state == "defending" and self.target and self.target.state == "fleeing" then
        self.target = nil
        self.isAggressive = false --becoming unaggressive and recalculating path if target is fleeing
        self.current_path = nil
        self.current_path_index = 1

        --returning to interrupted task
        if self.hasNectar then
            self.state = "returning"
        else
            self.state = "foraging"
        end
        return
    end

    if self.state == "foraging" then
        if self:isAtFlower() then
            self.lastFlower = self.closestFlower
            self.state = "collecting"
            self.nectarTimer = 0
            self.current_path = nil  --clearing path
            --print("collecting nectar") --debug
        else
            self:followPath(dt)
        end

    elseif self.state == "collecting" then
        self.nectarTimer = self.nectarTimer + dt
        if self.nectarTimer >= self.nectarCollectionTime then
            self.hasNectar = true
            self.state = "returning"
            self.current_path = self.pathfinding:findPathToHive(self.x, self.y)
            self.current_path_index = 1
        end

    elseif self.state == "returning" then
        if self:isAtHive() then
            --deposit nectar, default 1
            if self.homeHive then
                self.homeHive:depositNectar(self.lastFlower)
            end
            self.hasNectar = false
            self.state = "foraging"
            self.current_path = nil
        else
            self:followPath(dt)
        end

    elseif self.state == "defending" then
        if self.target then
            local dist = math.sqrt((self.x - self.target.x)^2 + (self.y - self.target.y)^2)

            --check if target is at a valid position for pathfinding
            local targetGridX = math.floor(self.target.x / 23)
            local targetGridY = math.floor(self.target.y / 22)
            local isValidTarget = targetGridX >= 1 and targetGridX <= 42 and targetGridY >= 1 and targetGridY <= 30

            if not isValidTarget then
                --if bee target is outside valid grid, stop following
                self.state = self.hasNectar and "returning" or "foraging"
                self.isAggressive = false
                self.target = nil
                return
            end

            if dist > self.attackRange then
                --moving towards target
                local angle = math.atan2(self.target.y - self.y, self.target.x - self.x)
                self.x = self.x + math.cos(angle) * self.speed * dt
                self.y = self.y + math.sin(angle) * self.speed * dt
            end
        else
            --if there is no target, return to previous state
            self.state = self.hasNectar and "returning" or "foraging"
            self.isAggressive = false
        end
    end
end

function Bee:checkThreatLevel()
    if not self.homeHive then return end

    --checking if hive is being attacked
    local threats = self:findThreats()
    local hiveUnderAttack = false

    for _, threat in ipairs(threats) do
        if threat.state == "stealing" then
            hiveUnderAttack = true
            break
        end
    end

    --become aggressive if hive is under attack
    if hiveUnderAttack and self.state ~= "defending" and self.state ~= "retreating" then
        self.state = "defending"
        self.isAggressive = true
        --find closest threat
        self.target = self:findNearestThreat()
    end
end

function Bee:findThreats()
    local threats = {}
    --check for wasps and honey badgers within detection range
    if wasp and wasp.visible and wasp.state ~= "fleeing" then
        local dist = math.sqrt((self.x - wasp.x)^2 + (self.y - wasp.y)^2)
        if dist < self.threatDetectionRange then
            table.insert(threats, wasp)
        end
    end
    if honeybadger and honeybadger.visible and honeybadger.state ~= "fleeing" then
        local dist = math.sqrt((self.x - honeybadger.x)^2 + (self.y - honeybadger.y)^2)
        if dist < self.threatDetectionRange then
            table.insert(threats, honeybadger)
        end
    end
    return threats
end

function Bee:findNearestThreat()
    local threats = self:findThreats()
    local nearestDist = math.huge
    local nearestThreat = nil

    for _, threat in ipairs(threats) do
        local dist = math.sqrt((self.x - threat.x)^2 + (self.y - threat.y)^2)
        if dist < nearestDist then
            nearestDist = dist
            nearestThreat = threat
        end
    end

    return nearestThreat
end

function Bee:updateCombat(dt)
    self.attackTimer = self.attackTimer + dt

    if self.state == "defending" and self.target and self.attackTimer >= self.attackCooldown then
        local dist = math.sqrt((self.x - self.target.x)^2 + (self.y - self.target.y)^2)
        if dist <= self.attackRange then
            self:attack(self.target)
        end
    end
end

function Bee:attack(target)
    self.attackTimer = 0

    --yellow flash for bee attack
    love.graphics.setColor(1, 1, 0, 0.1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)

    if target.takeDamage then
        target:takeDamage(self.attackDamage, self)
    else
        target.health = target.health - self.attackDamage
    end
end

function Bee:isAtFlower()
    if not self.closestFlower then return false end
    local dist = math.sqrt((self.x - self.closestFlower.x)^2 + (self.y - self.closestFlower.y)^2)
    return dist < 5
end

function Bee:isAtHive()
    if not self.homeHive then return false end
    local dist = math.sqrt((self.x - self.homeHive.x)^2 + (self.y - self.homeHive.y)^2)

    return dist < 5
end

--bee moves to hive when they are 'retreating' and they will despawn here/'die'
function Bee:moveToHive(dt)
    if not self.homeHive then return end

    local dx = self.homeHive.x - self.x
    local dy = (self.homeHive.y - 30) - self.y
    local distance = math.sqrt(dx * dx + dy * dy)

    if distance > 2 then
        local angle = math.atan2(dy, dx)
        self.x = self.x + math.cos(angle) * self.speed * dt
        self.y = self.y + math.sin(angle) * self.speed * dt
    else
        --there was a bug with the bee dying and decrementing the bee count indefinitely
        if self.visible then
            --making the bee disappear
            self.visible = false

            if self.homeHive and self.homeHive.beeCount then
                --beeCount can't be below 0
                self.homeHive.beeCount = math.max(0, self.homeHive.beeCount - 1)
            end
        end
    end
end

function Bee:followPath(dt)
    if not self.current_path then
        if self.state == "foraging" and self.closestFlower then
            --check if flower is in valid grid position
            local flowerGridX = math.floor(self.closestFlower.x / 23)
            local flowerGridY = math.floor(self.closestFlower.y / 22)
            if flowerGridX >= 1 and flowerGridX <= 42 and flowerGridY >= 1 and flowerGridY <= 30 then
                self.current_path = self.pathfinding:findPathToFlower(self.x, self.y, self.closestFlower.x, self.closestFlower.y)
                self.current_path_index = 1
            else
                return
            end
        elseif self.state == "returning" and hive then
            --check if hive is in valid grid position
            local hiveGridX = math.floor(self.homeHive.x / 23)
            local hiveGridY = math.floor(self.homeHive.y / 22)
            if hiveGridX >= 1 and hiveGridX <= 42 and hiveGridY >= 1 and hiveGridY <= 30 then
                self.current_path = self.pathfinding:findPathToHive(self.x, self.y)
                self.current_path_index = 1
            else
                self:moveToHive(dt)
                return
            end
        end
        return
    end

    if self.current_path_index >= #self.current_path then
        self.closestFlower = nil
        for _, f in pairs(Flowers) do
            if self.closestFlower == nil then
                self.closestFlower = f
            else
                if (self.x - f.x) * (self.x - f.x) + (self.y - f.y) * (self.y - f.y) < (self.x - self.closestFlower.x) * (self.x - self.closestFlower.x) + (self.y - self.closestFlower.y) * (self.y - self.closestFlower.y) then
                    self.closestFlower = f
                end
            end
        end

        local finalX, finalY
        if self.state == "foraging" and self.closestFlower then
            finalX, finalY = self.closestFlower.x, self.closestFlower.y
        elseif self.state == "returning" and self.homeHive then
            finalX, finalY = self.homeHive.x, self.homeHive.y
        else
            self.current_path = nil
            self.current_path_index = 1
            return
        end

        local dx = finalX - self.x
        local dy = finalY - self.y
        local distance = math.sqrt(dx * dx + dy * dy)

        if distance > 2 then
            local angle = math.atan2(dy, dx)
            self.x = self.x + math.cos(angle) * self.speed * dt
            self.y = self.y + math.sin(angle) * self.speed * dt
        end

        if dx > 0 then
            self.direction = "right"
        elseif dx < 0 then
            self.direction = "left"
        elseif dy > 0 then
            self.direction = "down"
        elseif dy < 0 then
            self.direction = "up"
        end

        return
    end

    local target = self.current_path[self.current_path_index]
    if not target then
        self.current_path = nil
        self.current_path_index = 1
        return
    end

    local dx = target.x - self.x
    local dy = target.y - self.y

    local distance = math.sqrt(dx * dx + dy * dy)

    if distance > 2 then
        local angle = math.atan2(dy, dx)
        self.x = self.x + math.cos(angle) * self.speed * dt
        self.y = self.y + math.sin(angle) * self.speed * dt
    else
        self.current_path_index = self.current_path_index + 1
    end

    if dx > 0 then
        self.direction = "right"
    elseif dx < 0 then
        self.direction = "left"
    elseif dy > 0 then
        self.direction = "down"
    elseif dy < 0 then
        self.direction = "up"
    end
end

function Bee:draw()
    if not self.isRetreating then
        --love.graphics.draw(self.image, self.x, self.y, 0, self.scale, self.scale)

        local row = 0
        if self.direction == "left" then row = 1
        elseif self.direction == "right" then row = 2 end

        local spriteNum = math.floor(self.animation.currentTime / self.animation.duration * 4) + 1 + row * 4
        love.graphics.draw(self.animation.spritesheet, self.animation.quads[spriteNum], self.x-48, self.y-48, 0, 2)

        --debug, drawing the bee's path
        if DebugMode then
            -- Draw the bee's path
            if self.current_path then
                love.graphics.setColor(0, 1, 0, 0.5)
                for i = 1, #self.current_path - 1 do
                    local current = self.current_path[i]
                    local next = self.current_path[i + 1]
                    love.graphics.line(current.x, current.y, next.x, next.y)
                end
            end

            -- Draw the bee's hitbox
            love.graphics.setColor(1, 0, 0, 0.3)
            love.graphics.rectangle("fill", self.x - self.width / 2, self.y - self.height / 2, self.width, self.height)

            -- Draw the threat detection range
            love.graphics.setColor(1, 1, 0, 0.2)
            love.graphics.circle("fill", self.x, self.y, self.threatDetectionRange)

            -- Reset color
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
end

--bee's take damage function
function Bee:takeDamage(damage, attacker)
    self.health = math.max(0, self.health - damage)
    --print("bee dealt " .. damage .. " damage, health is now: " .. self.health)

    --switching to defensive state if attacked
    if self.state ~= "defending" and self.state ~= "retreating" then
        self.previousState = self.state
        self.state = "defending"
        self.target = attacker
        self.isAggressive = true
    end

    --retreating if health is low
    if self.health <= 2 and self.state ~= "retreating" then
        self.state = "retreating"
        self.target = nil
    end

    if self.health <= 0 then
        self.visible = false
    end
end

function beeAnimation()
    local animation = {}
    local height = 64
    local width = 64
    local duration = 2
    animation.spritesheet = love.graphics.newImage("sprites/Bee_Walk.png")
    animation.quads = {};

    for y = 0, animation.spritesheet:getHeight() - height, height do
        for x = 0, animation.spritesheet:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, animation.spritesheet:getDimensions()))
        end
    end

    animation.duration = duration
    animation.currentTime = 0

    return animation
end