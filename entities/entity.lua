Pathfinding = require("libraries.pathfinding")

Entity = Object:extend()

function Entity:new()
    -- ID is the index of the entity in the parent table
    self.id = #Entities + 1

    -- Default values
    self.visible = true

    -- Health variables
    self.health = 100
    self.maxHealth = 100

    -- Dimensions of the entity
    self.width = 32
    self.height = 32
    self.x_offset = 0
    self.y_offset = 0

    -- Image holder
    self.image = nil

    -- Animation duration
    self.animationDuration = 2

    -- Animation holder
    self.animation = self:animate()

    -- Position of the entity
    self.x = GameConfig.windowW / 2
    self.y = GameConfig.windowH / 2

    -- Scale of the entity
    self.scale = 1

    -- Collider holder
    self.collider = nil

    -- Type check
    self.type = "entity"

    -- Target holder variable for movement
    self.target = nil

    -- Pathfinding variables
    self.pathfinding = Pathfinding
    self.pathfinding:initialize()
    self.current_path = nil
    self.current_path_index = 1
    self.state = "idle"

    -- Speed variables
    self.movementSpeed = 100
    self.retreatSpeed = 150
    self.speed = self.movementSpeed

    -- Is this entity naturally hostile?
    self.isAggressive = true

    -- List of entities that this one will try to fight
    -- THIS IS IN ORDER OF PRIORITY
    self.enemies = {"bee", "queenBee", "hive", "player"}

    -- Is entity under attack?
    self.isUnderAttack = false

    -- Holder for last entity that attacked this one
    self.lastAttacker = nil

    -- Hits taken before retaliating
    self.aggressionThreshold = 1

    -- Hit tracker for retaliating
    self.hitsTaken = 0

    -- Amount of attacks before fleeing
    self.maxAttacks = 3

    -- Damage indicator properties
    self.damageIndicator = {}

    -- Range at which entity will attack
    self.combatEngagementRange = 50

    -- Health threshold for retreat
    self.retreatHealthThreshold = 10

    -- Tracker for time since last attack
    self.attackTimer = 0

    -- Attack cooldown
    self.attackCooldown = 1.5

    -- Attack damage
    self.attackDamage = 1

    -- Attack range
    self.attackRadius = 10

    -- Time it take to harvest or steal honey
    self.harvestingTime = 3

    -- Timer to track time spent harvesting or stealing
    self.harvestingTimer = 0

    -- Max amount of honey that can be stolen (in grams)
    self.maxLootCapacity = 3

    -- Current amount of honey held
    self.currentLoot = 0

    -- Boolean to track if entity has honey
    self.hasLoot = false
end

function Entity:update(dt)
    -- If entity is hidden, skip update
    if not self.visible or self == nil then return end

    -- Show damage indicators
    for i = #self.damageIndicator, 1, -1 do
        local hit = self.damageIndicator[i]
        hit.timer = hit.timer - dt
        if hit.timer <= 0 then
            table.remove(self.damageIndicator, i)
        end
    end

    -- Update animations
    if self.animation then
        self.animation.currentTime = self.animation.currentTime + dt
        if self.animation.currentTime >= self.animation.duration then
            self.animation.currentTime = self.animation.currentTime - self.animation.duration
        end
    end

    -- Update attack timer
    self.attackTimer = math.max(0, self.attackTimer - dt)

    -- Run a check on the state
    self:updateState(dt)

    -- Check if we need to move
    self:move(dt)

end

function Entity:draw()
    -- Default draw function
    if not self.visible or self == nil then return end

    -- Draw animation
    if self.animation then
        local row = 0
        if self.direction == "left" then row = 1
        elseif self.direction == "right" then row = 2 end

        local spriteNum = math.floor(self.animation.currentTime / self.animation.duration * 4) + 1 + row * 4
        love.graphics.draw(self.animation.spritesheet, self.animation.quads[spriteNum], self.x-self.x_offset, self.y-self.y_offset, 0, self.scale)
    end

    -- Drawing damage effects
    for _, hit in ipairs(self.damageIndicator) do
        love.graphics.setColor(1, 0, 0, hit.timer / 0.2)
        love.graphics.circle("fill", hit.x, hit.y, 10)
    end

    -- Reset colors
    love.graphics.setColor(1, 1, 1, 1)

    -- Draw debug if enabled
    self:debug()
end

function Entity:destroy()
    -- Clear this entity as a target from other entities first
    for _, entity in ipairs(Entities) do
        if entity.target == self then
            entity.target = nil
            entity.state = "hunting"
            print(entity.id .. " " .. entity.type .. ": Target lost, resuming hunting")
        end
    end

    -- Find the current index of this entity in the Entities table
    for i, entity in ipairs(Entities) do
        if entity == self then
            table.remove(Entities, i)
            break
        end
    end

    -- Remove collider
    if self.collider ~= nil then
        self.collider:destroy()
        self.collider = nil
    end

    -- Set visibility to false
    self.visible = false
end

function Entity:takeDamage(damage, attacker)
    self.lastAttacker = attacker
    self.hitsTaken = self.hitsTaken + 1
    self.health = self.health - damage
    self.isUnderAttack = true

    -- If entity was killed...
    if self.health <= 0 then
        --self.attacker.target = nil
        self:destroy()
        return
    end

    -- If entity is still alive, check aggression
    if self.hitsTaken >= self.aggressionThreshold and self.state ~= "fleeing" then
        self.isUnderAttack = true
        self.target = attacker
        self.state = "attacking"
    end

    self:updateState()
end

function Entity:ensureGridLock()
    local targetGridX = math.floor(self.target.x / 23)
    local targetGridY = math.floor(self.target.y / 22)

    if targetGridX >= 1 and targetGridX <= 42 and targetGridY >= 1 and targetGridY <= 30 then
        self.current_path = self.pathfinding:findPathToTarget(self.x, self.y, self.target.x, self.target.y)
    end
end

function Entity:move(dt)
    -- If there is a target...
    if self.target then
        -- Ensure coordinates for path
        self:ensureGridLock()

        -- Follow path if available and valid
        if self.current_path and self.current_path_index and self.current_path_index <= #self.current_path then
            -- Get current node
            local node = self.current_path[self.current_path_index]

            -- Convert grid coords to center of tileSize
            local targetX = node.x + 11.5
            local targetY = node.y + 11

            -- Calculate distance to target
            local dx = targetX - self.x
            local dy = targetY - self.y
            local dist = math.sqrt(dx * dx + dy * dy)

            -- If target is out of combat range, return to previous state
            if self.isAggressive and dist > self.combatEngagementRange then
                self.isAggressive = false
                self.state = self.previousState
                return
            end

            -- If we're close enough, move to next node
            if dist < 2 then
                self.current_path_index = self.current_path_index + 1
            else
                -- Otherwise, move toward target
                local angle = math.atan2(dy, dx)
                self.x = self.x + math.cos(angle) * self.speed * dt
                self.y = self.y + math.sin(angle) * self.speed * dt

                -- Set direction based on target position
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
        end

        -- If not following a path, move directly toward the target
        local dx = self.target.x - self.x
        local dy = self.target.y - self.y
        local dist = math.sqrt(dx * dx + dy * dy)

        -- If target is out of combat range, return to previous state
        if self.isAggressive and dist > self.combatEngagementRange then
            self.isAggressive = false
            self.state = self.previousState
            return
        end

        if dist > 2 then
            local angle = math.atan2(dy, dx)
            self.x = self.x + math.cos(angle) * self.speed * dt
            self.y = self.y + math.sin(angle) * self.speed * dt

            -- Set direction based on target position
            if dx > 0 then
                self.direction = "right"
            elseif dx < 0 then
                self.direction = "left"
            elseif dy > 0 then
                self.direction = "down"
            elseif dy < 0 then
                self.direction = "up"
            end
        else
            if self.type == "bee" then
                if self.target.type == "hive" then
                    if self.homeHive then
                        self.homeHive:depositNectar(self.lastFlower)
                        self.closestFlower = nil
                        self.target = nil
                        self.harvestingTimer = 0
                        self.currentLoot = 0
                        self.hasNectar = false
                    end
                    self.state = "foraging"
                    return
                elseif self.target.type == "flower" then
                    self.lastFlower = self.target
                    self.state = "collecting"
                    self.target = nil
                    self.closestFlower = nil
                    return
                end
            else
                if self.isAggressive and self.target.type ~= nil then
                    self.state = "attacking"
                else
                    if self.state == "fleeing" then
                        self:destroy()
                        return
                    else
                        self.state = "hunting"
                    end
                end
            end
        end
    else
        self:findNearestObject()
    end
end

function Entity:stealHoney()
    -- If honey is available and we can still steal
    if self.attackTimer <= 0 and self.currentLoot < self.maxLootCapacity and self.target.honey > 0 then
        print(self.id .. " " .. self.type .. ": " .. "Stealing honey...")
        self.state = "stealing"
        self.hasLoot = true
        self.currentLoot = self.currentLoot + 1
        self.target.honey = self.target.honey - 1
        return
    end

    -- If honey is depleted but we still haven't maxed out on loot, return to fleeing
    if self.target.honey <= 0 and self.currentLoot <= self.maxLootCapacity then
        print(self.id .. " " .. self.type .. ": " .. "Honey depleted, fleeing.")
        self.isAggressive = false
        self.speed = self.retreatSpeed
        self.target = nil
        self.state = "fleeing"
        return
    end
end

function Entity:addHitFeedback(x, y)
    if self.target == nil then return end
    table.insert(self.damageIndicator, {
        x = x,
        y = y,
        timer = 0.2
    })
end

function Entity:attack()
    -- Early return if attack timer not up
    if self:distanceFromObject(self.target) > self.attackRadius then return end
    if self.attackTimer > 0 then
        return
    end

    -- Validate target
    if not self.target or not self.target.visible then
        self.target = nil
        self.state = "hunting"
        self.isAggressive = false
        return
    end

    -- Put attack on cooldown
    self.attackTimer = self.attackCooldown

    -- Try to get target type safely
    local targetType = self.target.type
    if not targetType then
        self.target = nil
        self.state = "hunting"
        self.isAggressive = false
        return
    end

    -- Attack based on target type
    if targetType == "hive" then
        -- If target is a hive, attempt to steal honey
        -- This will never trigger for bees because Hives are not registered enemies
        self:stealHoney()
    else
        -- Regular attack
        self.target:takeDamage(self.attackDamage, self)
        --self:addHitFeedback(self.target.x, self.target.y)
        self.isAggressive = true
    end
end

function Entity:updateState()
    if self.state == "fleeing" then return end
    self.previousState = self.state

    -- If current loot is greater than or equal to max capacity, set state to fleeing
    -- OR if hits taken is greater than or equal to max attacks, set state to fleeing
    if self.currentLoot >= self.maxLootCapacity or
       self.hitsTaken >= self.maxAttacks or
       self.health <= self.retreatHealthThreshold
    then
        self.isAggressive = false
        self.speed = self.retreatSpeed
        self.target = nil
        self.state = "fleeing"
    end

    -- If state is not idle, or attacking, find nearest object to go to
    if self.state ~= "idle" and
       self.state ~= "attacking"
    then
        self:findNearestObject()
    end

    -- If state is attacking, attack
    if self.state == "attacking" then
        self:attack()
    end
end

-- Helper function to check if a value exists in a table
function contains(table, value)
    for i = 1, #table do
      if (table[i] == value) then
        return true
      end
    end

    return false
end

-- Function to find the nearest object to attack or steal from
function Entity:findNearestObject()

    -- If fleeing, find a random location out of bounds to travel to
    if self.state == "fleeing" then
        if self.homeHive == nil then
            self.target =
            {
                -- Randomly choose an x based on the window width, either positive or negative.
                x = (math.random(2) == 1) and math.random(0, GameConfig.windowW+100) or math.random(0, GameConfig.windowW-(GameConfig.windowW*2+100)),
                -- Randomly choose a y based on the window height, either positive or negative.
                y = (math.random(2) == 1) and GameConfig.windowH+100 or GameConfig.windowH-(GameConfig.windowH*2+100)
            }
        else
            self.target = self.homeHive
        end
        return
    end

    -- If hunting, find the nearest object to attack or steal from
    if self.state == "hunting" then
        for _, enemy in ipairs(Entities) do
            local dist = math.sqrt((self.x - enemy.x)^2 + (self.y - enemy.y)^2)
            if contains(self.enemies, enemy.type) and
                        enemy.visible and
                        dist <= self.combatEngagementRange
            then
                self.target = enemy
                self.state = "attacking"
                return
            end
        end
    end


end

function Entity:debug()
    if DebugMode then
        -- Draw the current path of the entity if exists
        if self.current_path then

            -- If entity is aggressive outline path in red
            if self.isAggressive then
                love.graphics.setColor(1, 0, 0, 0.5)
            else
                -- If entity is not aggressive outline path in green
                love.graphics.setColor(0, 1, 0, 0.5)
            end

            -- Draw the path
            for i = 1, #self.current_path - 1 do
                local current = self.current_path[i]
                local next = self.current_path[i + 1]
                love.graphics.line(current.x, current.y, next.x, next.y)
            end

            -- Reset color
            love.graphics.setColor(1, 1, 1, 1)
        end

        -- Debug text over the entity to display stats.
        love.graphics.print(string.format("HP: %d / %d"..
                                         "\nState: %s"..
                                         "\nAggressive: %s"..
                                         "\nLoot: %d/%d",
                                         self.health,
                                         self.maxHealth,
                                         self.state,
                                         tostring(self.isAggressive),
                                         self.currentLoot,
                                         self.maxLootCapacity),
                                         self.x - self.width/2, self.y + self.height)

        -- Draw the threat detection range
        love.graphics.setColor(1, 1, 0, 0.2)
        love.graphics.circle("fill", self.x, self.y, self.combatEngagementRange)

        -- Reset color
        love.graphics.setColor(1, 1, 1, 1)

    end
end

function Entity:distanceFromObject(object)
    local dx = self.x - object.x
    local dy = self.y - object.y
    return math.sqrt(dx * dx + dy * dy)
end

function Entity:animate()
    if self.image == nil then return end
    local animation = {}
    animation.spritesheet = self.image
    animation.quads = {}

    for y = 0, animation.spritesheet:getHeight() - self.height, self.height do
        for x = 0, animation.spritesheet:getWidth() - self.width, self.width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, self.width, self.height, animation.spritesheet:getDimensions()))
        end
    end

    animation.duration = self.animationDuration
    animation.currentTime = 0

    return animation
end

return Entity
