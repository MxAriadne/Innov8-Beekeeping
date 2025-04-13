Wasp = Entity:extend()

function Wasp:new(x, y)
    -- Parent constructor
    Entity.new(self)

    -- Health variables
    local buff = self:getDayBuff()
    self.health = 10 + (1.5 * buff)
    self.maxHealth = self.health

    -- Dimensions of the entity
    self.width = 64
    self.height = 64
    self.x_offset = 32
    self.y_offset = 32

    -- Image holder
    self.image = love.graphics.newImage("sprites/wasp.png")

    -- List of entities that this one will try to fight
    -- THIS IS IN ORDER OF PRIORITY
    self.enemies = {"bee", "hive", "queenBee", "player"}

    -- Animation duration
    self.animationDuration = 2

    -- Animation holder
    self.animation = self:animate()

    -- Position of the entity
    self.x = x or 0
    self.y = y or 0

    -- Scale of the entity
    self.scale = 0.75

    -- Type check
    self.type = "wasp"

    -- Target holder variable for movement
    self.target = nil

    -- Pathfinding variables
    self.pathfinding = Pathfinding
    self.pathfinding:initialize()
    self.current_path = nil
    self.current_path_index = 1
    self.state = "hunting"

    -- Speed variables
    self.movementSpeed = 70
    self.retreatSpeed = 150
    self.speed = self.movementSpeed

    -- Is entity under attack?
    self.isUnderAttack = false

    -- Holder for last entity that attacked this one
    self.lastAttacker = nil

    -- Hits taken before retaliating
    self.aggressionThreshold = 1

    -- Hit tracker for retaliating
    self.hitsTaken = 0

    -- Amount of attacks before fleeing
    self.maxAttacks = 5

    -- Range at which entity will attack
    self.combatEngagementRange = 175

    -- Health threshold for retreat
    self.retreatHealthThreshold = 1

    -- Tracker for time since last attack
    self.attackTimer = 0

    -- Attack cooldown
    self.attackCooldown = 1.5

    -- Attack damage
    self.attackDamage = 1 + self:getDayBuff(0.1)

    -- Attack range
    self.attackRadius = 50

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

    -- Previous state holder
    self.previousState = "hunting"

    --unique wasp player attack variables
    self.attackedByPlayer = false
    self.targetType = nil
    self.stingCount = 0
    self.maxStings = 3
    self.fleeingSpeed = 100
    self.lastAttackTime = 0
    self.attackRange = self.attackRadius
    self.attackTimer = 0
end

function Wasp:draw()
    -- Default draw function
    if not self.visible or self == nil then return end

    -- Draw animation
    if self.animation then
        local row = 0
        if self.direction == "left" then row = 1
        elseif self.direction == "right" then row = 2 end

        local spriteNum = math.floor(self.animation.currentTime / self.animation.duration * 4) + 1 + row * 2
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

function Wasp:updateState(dt)
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

    if self.attackedByPlayer and self.state ~= "fleeing" and self.state ~= "returning" then
        if self.health > self.retreatHealthThreshold then
            self.state = "attacking"
            self.target = player
            self.targetType = "player"
            self.current_path = nil
            
            self.attackedByPlayer = false
        else
            self.state = "fleeing"
            self.speed = self.fleeingSpeed
            self.current_path = nil
        end
    end
    
    --attacking player state
    if self.state == "attacking" and self.targetType == "player" and player then
        --calculating distance to player
        local dx = player.x - self.x
        local dy = player.y - self.y
        local distance = math.sqrt(dx*dx + dy*dy)
        
        if distance <= self.attackRange then
            --incrementing attack timer
            self.attackTimer = self.attackTimer + dt
            
            if self.attackTimer >= self.attackCooldown then
                self:attackPlayer()
                
                --better off commented out
                if DebugMode then
                    --print("Wasp attacked player! Stings: " .. self.stingCount .. "/" .. self.maxStings)
                end
            end
        else
            local angle = math.atan2(dy, dx)
            self.x = self.x + math.cos(angle) * self.speed * dt
            self.y = self.y + math.sin(angle) * self.speed * dt
        end
    end
end

function Wasp:attackPlayer()
    if player and player.takeDamage then
        player:takeDamage(self.attackDamage)
        
        self.attackTimer = 0
        
        self.stingCount = self.stingCount + 1
        
        if self.stingCount >= self.maxStings then
            self.state = "fleeing"
            self.speed = self.fleeingSpeed
        end   
    end
end

function Wasp:takeDamage(damage, attacker)
    self.health = self.health - damage
    
    self.isUnderAttack = true
    self.lastAttacker = attacker
    self.hitsTaken = self.hitsTaken + 1
    
    self.damageFlashTimer = 0.3
    
    --fleeing if health is low
    if self.health <= self.retreatHealthThreshold then
        self.state = "fleeing"
        self.speed = self.fleeingSpeed
        return
    end
    
    --target attacker
    if self.hitsTaken >= self.aggressionThreshold then
        self.state = "attacking"
        self.target = attacker
        self.targetType = attacker.type
    end
end

return Wasp