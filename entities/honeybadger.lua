local Pathfinding = require("libraries.pathfinding")

HoneyBadger = Object:extend()

function HoneyBadger:new()
    self.image = love.graphics.newImage("sprites/honey_badger.png")
    self.x = 970
    self.y = 150
    self.scale = 0.2
    self.width = self.image:getWidth() * self.scale
    self.height = self.image:getHeight() * self.scale
    self.speed = 45  --slower than wasps
    self.state = "hunting" --"hunting" default state
    self.stateTimer = 0
    self.idleTime = math.random(3, 6)

    --combat properties
    self.isAggressive = true
    self.attackDamage = 3  --does more damage than wasps
    self.attackCooldown = 2.0  --slower attacks
    self.attackTimer = 0
    self.attackRange = 40  --larger attack range
    self.hasLoot = false
    self.stealingTime = 4
    self.stealingTimer = 0
    self.maxLootCapacity = 5  --can carry more honey/larvae than wasps
    self.currentLoot = 0

    self.is_honeybadger = true

    --combat variables
    self.playerAttackRange = 60
    self.playerAttackCooldown = 3
    self.playerAttackTimer = 0
    self.playerDamage = 5  --default 5

    --target selection
    self.target = nil
    self.targetType = nil  -- "hive" or "bee"

    --pathfinding initialization
    self.pathfinding = Pathfinding
    self.pathfinding:initialize()
    self.current_path = nil
    self.current_path_index = 1

    --home position (off-screen), at the left edge
    self.homeX = 0
    self.homeY = math.random(100, 540)

    self.visible = false

    self.health = 10
    self.maxHealth = 10 --default 10, might not be balanced?
    self.fleeingSpeed = 100
    self.normalSpeed = 45
    self.speed = self.normalSpeed

    --honey badgers properties
    --playing with the idea that honey badgers can withstand bee stings due to their fur/skin
    --not making the honey badgers focus on fighting back but rather just stealing from the hive
    self.isUnderAttack = false
    self.stealingFocus = 10  --how many bee stings before considering leaving, default 10
    self.stingsReceived = 0
    self.lootPriority = true  --prioritize stealing over fighting
end

function HoneyBadger:update(dt)
    if BadgerGo then
        self.visible = true
        self:updateState(dt)
        self:updateCombat(dt)
        self:move(dt)
    end
end

function HoneyBadger:updateState(dt)
    --only flee if health is low
    if self.health <= 0 and self.state ~= "fleeing" then
        self.state = "fleeing"
        self.speed = self.fleeingSpeed
        self.current_path = nil

        -- IMPORTANT ADDITION: unlock space to skip
        pressSpaceAllowed = true

        return
    end
    --honey badger will leave if it has enough loot or has been stung too many times
    if (self.currentLoot >= self.maxLootCapacity or self.stingsReceived >= self.stealingFocus)
        and self.state ~= "fleeing" then
        self.state = "returning"
        self.current_path = nil
    end
    self.stateTimer = self.stateTimer + dt

    if self.state == "fleeing" then
        --moving to edge of screen when fleeing
        local dx = self.homeX - self.x
        local dy = self.homeY - self.y
        local distance = math.sqrt(dx * dx + dy * dy)

        if distance > 2 then
            local angle = math.atan2(dy, dx)
            self.x = self.x + math.cos(angle) * self.speed * dt
            self.y = self.y + math.sin(angle) * self.speed * dt
        else
            self.visible = false
            self.health = self.maxHealth  --reset health for next time it appears
        end
        return  --skip other state checks when fleeing
    end
    if self.state == "idle" then
        if self.stateTimer >= self.idleTime then
            self:chooseNewState()
        end
    elseif self.state == "hunting" then
        if not self.target then
            self:chooseNewState()
        elseif self.targetType == "hive" and self:isInRange(self.target) then
            self.state = "stealing"
            self.stealingTimer = 0
        elseif self.targetType == "bee" and not self.target.alive then
            self:chooseNewState()
        end
    elseif self.state == "stealing" then
        self.stealingTimer = self.stealingTimer + dt
        if self.stealingTimer >= self.stealingTime then
            self.currentLoot = self.currentLoot + 2  --honey badger takes more honey
            --dealing damage to hive while stealing
            if hive then
                hive.honey = math.max(0, hive.honey - 5)  --stealing honey, default 5
                if hive.health then
                    hive.health = math.max(0, hive.health - 5)  --dealing damage, default 5
                end
            end

            if self.currentLoot >= self.maxLootCapacity then
                self.hasLoot = true
                self.state = "returning"
                self.current_path = nil  --clearing path
            else
                self.stealingTimer = 0
            end
        end
    elseif self.state == "returning" then
        --move to edge when returning, similar to fleeing
        local dx = self.homeX - self.x
        local dy = self.homeY - self.y
        local distance = math.sqrt(dx * dx + dy * dy)

        if distance > 2 then
            local angle = math.atan2(dy, dx)
            self.x = self.x + math.cos(angle) * self.speed * dt
            self.y = self.y + math.sin(angle) * self.speed * dt
        else
            self.visible = false
            self.hasLoot = false
            self.currentLoot = 0
            self.x = 50
            self.y = math.random(100, 540)
            self:chooseNewState()
        end
    end

    --combat logic for attacking player if within range and hb not fleeing
    if player and self.state ~= "fleeing" and self.state ~= "returning" then
        local dist = math.sqrt((self.x - player.x)^2 + (self.y - player.y)^2)

        if dist <= self.playerAttackRange then
            self.playerAttackTimer = self.playerAttackTimer + dt
            if self.playerAttackTimer >= self.playerAttackCooldown then
                self:attackPlayer()
            end
        end
    end
end

function HoneyBadger:chooseNewState()
    self.stateTimer = 0

    if self.isAggressive then
        local target, targetType = self:findNearestTarget()
        if target then
            self.target = target
            self.targetType = targetType
            self.state = "hunting"
            self:updatePath()
            return
        end
    end

    self.state = "idle"
    self.idleTime = math.random(3, 6)
end

function HoneyBadger:findNearestTarget()
    local nearestDist = math.huge
    local nearestTarget = nil
    local targetType = nil

    --honey badgers prioritize the hive rather than targeting bees
    if hive then
        local hiveDist = math.sqrt((self.x - hive.x)^2 + (self.y - hive.y)^2)
        nearestDist = hiveDist
        nearestTarget = hive
        targetType = "hive"
    end

    --only target bees that are very close to badger
    if bee and bee.alive then
        local beeDist = math.sqrt((self.x - bee.x)^2 + (self.y - bee.y)^2)
        if beeDist < 60 then
            nearestTarget = bee
            targetType = "bee"
        end
    end

    return nearestTarget, targetType
end

function HoneyBadger:updateCombat(dt)
    self.attackTimer = self.attackTimer + dt

    if self.state == "hunting" and self.target then
        local dist = math.sqrt((self.x - self.target.x)^2 + (self.y - self.target.y)^2)

        if dist <= self.attackRange and self.attackTimer >= self.attackCooldown then
            self:attack()
        end
    end
end

function HoneyBadger:attack()
    self.attackTimer = 0

    --brown indicator for hb attacks
    love.graphics.setColor(0.7, 0.4, 0, 0.3)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)

    if self.targetType == "hive" then
        hive.honey = math.max(0, hive.honey - 2)
    elseif self.targetType == "bee" then
        bee.health = bee.health - self.attackDamage
    end
end

function HoneyBadger:updatePath()
    if self.state == "hunting" and self.target then
        if self.targetType == "hive" then
            self.current_path = self.pathfinding:findPathToHive(self.x, self.y)
        else
            self.current_path = self.pathfinding:findPathToTarget(self.x, self.y, self.target.x, self.target.y)
        end
        self.current_path_index = 1
    end
end

function HoneyBadger:move(dt)
    if self.current_path and self.current_path_index <= #self.current_path then
        local target = self.current_path[self.current_path_index]

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
    end
end

function HoneyBadger:isInRange(target)
    local dist = math.sqrt((self.x - target.x)^2 + (self.y - target.y)^2)
    return dist <= self.attackRange
end

function HoneyBadger:isAtHomePosition()
    local dist = math.sqrt((self.x - self.homeX)^2 + (self.y - self.homeY)^2)
    return dist < 10
end

function HoneyBadger:draw()
    if self.visible then  --drawing if visible
    love.graphics.draw(self.image, self.x-48, self.y-48, 0, self.scale, self.scale)

        if DebugMode then
            --draw path
            if self.current_path then
                love.graphics.setColor(0.7, 0.4, 0, 0.5)  --brown path for honey badger
                for i = 1, #self.current_path - 1 do
                    local current = self.current_path[i]
                    local next = self.current_path[i + 1]
                    love.graphics.line(current.x, current.y, next.x, next.y)
                end
                love.graphics.setColor(1, 1, 1, 1)
            end

            --debug info including current state, aggression, and loot count
            love.graphics.print(string.format("State: %s\nAggressive: %s\nLoot: %d/%d", self.state, tostring(self.isAggressive), self.currentLoot, self.maxLootCapacity), self.x - 30, self.y - 40)
        end
    end
end

--method for dealing damage to player and resetting attack timer after
function HoneyBadger:attackPlayer()
    if player then
        player:takeDamage(self.playerDamage)
        self.playerAttackTimer = 0
    end
end

--hb function for taking damage, WIP
function HoneyBadger:takeDamage(damage, attacker)
    --honey badger takes reduced damage from bees
    self.health = self.health - (damage * 0.5)  --honey badger takes half damage from bees
    self.stingsReceived = self.stingsReceived + 1

    --small chance to target bees
    if math.random() < 0.1 and self.state == "stealing" then
        self.state = "fighting"
        self.target = attacker
        self.targetType = "bee"
        self.current_path = nil

        self.stateTimer = 0
        self.idleTime = 1
    end
end
