local Pathfinding = require("libraries.pathfinding")

Wasp = Object:extend()

function Wasp:new()
	--setting sprite png, location, scale, and state
    self.image = love.graphics.newImage("sprites/wasp.png")
    self.x = 700
    self.y = 250
    self.scale = 0.08
    self.width = self.image:getWidth() * self.scale
    self.height = self.image:getHeight() * self.scale
    self.speed = 70 --learned that wasps are more aerodynamic thans bees tmyk
    self.state = "hunting" --setting default wasp state to "hunting"
    self.stateTimer = 0 --timer for states, used for transitions
    self.idleTime = math.random(2, 4)  --a random amount of idle time before determining next state
                                       --want to implement an entity 'wandering' while idling
    
    --combat and loot variables
    self.isAggressive = true
    self.attackDamage = 1     --default 1
    self.attackCooldown = 1.5 --default 1.5
    self.attackTimer = 0
    self.attackRange = 30
    self.hasLoot = false
    self.stealingTime = 3  --seconds it takes to steal from hive
    self.stealingTimer = 0
    self.maxLootCapacity = 3  --how much honey the wasp can carry away from the hive
    self.currentLoot = 0
    
    --target selection
    self.target = nil
    self.targetType = nil  --"hive" or "bee"
    
    --initializing pathfinding
    self.pathfinding = Pathfinding
    self.pathfinding:initialize()
    self.current_path = nil
    self.current_path_index = 1
    
    --return position, on the far right
    self.homeX = 960
    self.homeY = math.random(100, 540)
    
    self.visible = true
    
    --health and speed
    self.health = 2    --default 3
    self.maxHealth = 2 --default 3
    self.fleeingSpeed = 150  --faster than normal speed
    self.normalSpeed = 70
    self.speed = self.normalSpeed
    
    --additional combat properties
    self.isUnderAttack = false
    self.lastAttacker = nil
    self.aggressionThreshold = 1  --hits before retaliating 
    self.hitsTaken = 0
    self.combatEngagementRange = 50
    self.retreatHealthThreshold = 1  --lowest health at which a wasp will flee
    
    --type check
    self.is_wasp = true
    
    --add player combat properties
    self.stingCount = 0
    self.maxStings = math.random(1, 4)  --random number of stings before fleeing
    self.playerAttackRange = 50
    self.playerAttackCooldown = 2  --cooldown between attacks
    self.playerAttackTimer = 0
end

function Wasp:update(dt)
    self:updateState(dt)
    self:updateCombat(dt)
    self:move(dt)
end

--function that performs timer checking and transitioning between entity states
function Wasp:updateState(dt)
    --wasp checks health and flees if not already and is at the min health threshold
    if self.health <= self.retreatHealthThreshold and self.state ~= "fleeing" then
        self.state = "fleeing"
        self.speed = self.fleeingSpeed
        self.current_path = nil --clearing the wasps current path so that the wasps can flee instead 
        return
    end

    --handling fleeing
    if self.state == "fleeing" then
        --calculate distance to "return" location and moving there
        local dx = self.homeX - self.x
        local dy = self.homeY - self.y
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance > 2 then
            local angle = math.atan2(dy, dx)
            self.x = self.x + math.cos(angle) * self.speed * dt
            self.y = self.y + math.sin(angle) * self.speed * dt
        else
            self.visible = false --hiding to appear 'off-screen'
            self.health = self.maxHealth  --resetting health, might be neccessary later, might not
        end
        return  --skip other state checks when fleeing
    end

    --wasp checks if under attack and if aggressionThreshold has been met
    if self.isUnderAttack and self.hitsTaken >= self.aggressionThreshold 
        and self.state ~= "fleeing" and self.lastAttacker then
        --interrupt current state to fight back
        self.state = "fighting"
        self.target = self.lastAttacker
        self.targetType = "bee"
        self.current_path = nil --clear current path
        self.isUnderAttack = false
        self.hitsTaken = 0
    end

    --handling other states
    self.stateTimer = self.stateTimer + dt
    
    if self.state == "fighting" then
        if not self.target or not self.target.visible or self.target.state == "retreating" then
            --resuming activity if target is gone
            self:chooseNewState()
        else
            local dist = math.sqrt((self.x - self.target.x)^2 + (self.y - self.target.y)^2)
            if dist > self.attackRange then
                --moving towards the target
                local angle = math.atan2(self.target.y - self.y, self.target.x - self.x)
                self.x = self.x + math.cos(angle) * self.speed * dt
                self.y = self.y + math.sin(angle) * self.speed * dt
            end
        end
    elseif self.state == "idle" then
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
        --wasp will interrupt stealing if under attack
        if self.isUnderAttack and math.random() < 0.7 then  --70% chance to react to attack
            self.state = "fighting"
            self.target = self.lastAttacker
            self.targetType = "bee"
            self.current_path = nil
        else
            self.stealingTimer = self.stealingTimer + dt
            if self.stealingTimer >= self.stealingTime then
                self.currentLoot = self.currentLoot + 1 --incrementing loot
                if self.currentLoot >= self.maxLootCapacity then
                    self.hasLoot = true
                    self.state = "returning" --returning when loot is full
                    self:updatePath()
                else
                    self.stealingTimer = 0  --reset timer to continue stealing
                end
            end
        end
    elseif self.state == "returning" then
        --when returning, move to edge, pathfinding becomes problematic when trying move 'offscreen'
        local dx = self.homeX - self.x
        local dy = self.homeY - self.y
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance > 2 then
            local angle = math.atan2(dy, dx)
            self.x = self.x + math.cos(angle) * self.speed * dt
            self.y = self.y + math.sin(angle) * self.speed * dt
        else
            self.visible = false
        end
    end

    --comabt logic for attacking player
    if player and self.state ~= "fleeing" and self.state ~= "returning" then
        local dist = math.sqrt((self.x - player.x)^2 + (self.y - player.y)^2)
        
        if dist <= self.playerAttackRange then
            self.playerAttackTimer = self.playerAttackTimer + dt
            if self.playerAttackTimer >= self.playerAttackCooldown and self.stingCount < self.maxStings then
                self:attackPlayer()
            end
        end
    end
end

function Wasp:chooseNewState()
    self.stateTimer = 0
    
    --if aggressive, prioritize attacking
    if self.isAggressive then
        --finding the nearest target (hive or bee)
        local target, targetType = self:findNearestTarget()
        if target then
            self.target = target
            self.targetType = targetType
            self.state = "hunting"
            self:updatePath()
            return
        end
    end
    
    --if there are no targets, go idle
    self.state = "idle"
    self.idleTime = math.random(2, 4)
end

--function for finding the nearest target
function Wasp:findNearestTarget()
    local nearestDist = math.huge
    local nearestTarget = nil
    local targetType = nil
    
    --targeting bee if its near hive
    if hive and bee and bee.alive then
        local beeToHiveDist = math.sqrt((bee.x - hive.x)^2 + (bee.y - hive.y)^2)
        if beeToHiveDist < 100 then  -- If bee is near hive
            local beeDist = math.sqrt((self.x - bee.x)^2 + (self.y - bee.y)^2)
            nearestDist = beeDist
            nearestTarget = bee
            targetType = "bee"
        end
    end
    
    --targeting hive if there is no bee near
    if hive and not nearestTarget then
        local hiveDist = math.sqrt((self.x - hive.x)^2 + (self.y - hive.y)^2)
        if hiveDist < nearestDist then
            nearestDist = hiveDist
            nearestTarget = hive
            targetType = "hive"
        end
    end
    
    --if cant find hive (just in case), target bee
    if bee and bee.alive and not nearestTarget then
        local beeDist = math.sqrt((self.x - bee.x)^2 + (self.y - bee.y)^2)
        if beeDist < nearestDist then
            nearestDist = beeDist
            nearestTarget = bee
            targetType = "bee"
        end
    end
    return nearestTarget, targetType
end

function Wasp:updateCombat(dt)
    self.attackTimer = self.attackTimer + dt
    
    if self.state == "hunting" and self.target then
        local dist = math.sqrt((self.x - self.target.x)^2 + (self.y - self.target.y)^2)
        
        if dist <= self.attackRange and self.attackTimer >= self.attackCooldown then
            self:attack()
        end
    end
end

function Wasp:attack()
    self.attackTimer = 0
    
    --showing wasp attacks at yellow
    love.graphics.setColor(1, 1, 0, 0.2)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1, 1)
    
    if self.targetType == "hive" then
        hive.honey = math.max(0, hive.honey - 1)
    elseif self.targetType == "bee" then
        if self.target and self.target.health then
            self.target.health = self.target.health - self.attackDamage
        end
    end
end

function Wasp:updatePath()
    if self.state == "hunting" and self.target then
        if self.targetType == "hive" then
            self.current_path = self.pathfinding:findPathToHive(self.x, self.y)
        else
            self.current_path = self.pathfinding:findPathToTarget(self.x, self.y, self.target.x, self.target.y)
        end
        self.current_path_index = 1
    end
end

function Wasp:move(dt)
    --traveling from first point in path to last
    if self.current_path and self.current_path_index <= #self.current_path then
        local target = self.current_path[self.current_path_index]
        
        --calculating difference between wasp's and targets position and moving towards target
        local dx = target.x - self.x
        local dy = target.y - self.y
        local distance = math.sqrt(dx * dx + dy * dy) --the distance between them
        
        --when the wasp reaches its target (the distance is less than 2 pixels), it will travel to the next target in the list
        if distance > 2 then
            local angle = math.atan2(dy, dx)
            self.x = self.x + math.cos(angle) * self.speed * dt
            self.y = self.y + math.sin(angle) * self.speed * dt
        else
            self.current_path_index = self.current_path_index + 1
        end
    end
end

--function to check if wasp is in range of target
function Wasp:isInRange(target)
    local dist = math.sqrt((self.x - target.x)^2 + (self.y - target.y)^2)
    return dist <= self.attackRange
end

--function to check wether wasp is at 'return' position
function Wasp:isAtHomePosition()
    local dist = math.sqrt((self.x - self.homeX)^2 + (self.y - self.homeY)^2)
    return dist < 10
end

function Wasp:draw()
    if self.visible then  --draw if visible = true
        --draw around center of png, could have probably done this a better way
        love.graphics.draw(self.image, self.x, self.y, 0, self.scale, self.scale, self.image:getWidth() / 2, self.image:getHeight() / 2)

        if debugMode then
            --draw path
            if self.current_path then
                love.graphics.setColor(1, 0, 0, 0.5)
                for i = 1, #self.current_path - 1 do
                    local current = self.current_path[i]
                    local next = self.current_path[i + 1]
                    love.graphics.line(current.x, current.y, next.x, next.y)
                end
                love.graphics.setColor(1, 1, 1, 1)
            end
            
            --debug info includes the current state and how much has been taken from the hive
            love.graphics.print(string.format("State: %s\nAggressive: %s\nLoot: %d/%d", self.state, tostring(self.isAggressive), self.currentLoot, self.maxLootCapacity), self.x - 30, self.y - 40)
        end
    end
end

--function for wasp taking damage
function Wasp:takeDamage(damage, attacker)
    self.health = self.health - damage
    self.isUnderAttack = true
    self.lastAttacker = attacker
    self.hitsTaken = self.hitsTaken + 1
end

--wasp function for attacking player
function Wasp:attackPlayer()
    if player then
        player:takeDamage(1)  --dealing 1 damage per sting
        self.stingCount = self.stingCount + 1
        self.playerAttackTimer = 0
        
        if self.stingCount >= self.maxStings then --will sting a random amount of times between 1 and 4
            self.state = "fleeing"                --flee after maxStings or when health is depleted
            self.speed = self.fleeingSpeed
        end
    end
end