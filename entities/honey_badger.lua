HoneyBadger = Entity:extend()

function HoneyBadger:new(x, y)
    -- Parent constructor
    Entity.new(self)

    -- Health variables
    self.health = 25
    self.maxHealth = 20

    -- Dimensions of the entity
    self.width = 64
    self.height = 64
    self.x_offset = 32
    self.y_offset = 32

    -- Image holder
    self.image = love.graphics.newImage("sprites/honey_badger_spritesheet.png")

    -- List of entities that this one will try to fight
    -- THIS IS IN ORDER OF PRIORITY
    self.enemies = {"hive", "bee", "queenBee", "player"}

    -- Animation duration
    self.animationDuration = 2

    -- Animation holder
    self.animation = self:animate()

    -- Position of the entity
    self.x = x or 970
    self.y = y or 150

    -- Scale of the entity
    self.scale = 1

    -- Type check
    self.type = "honey_badger"

    -- Pathfinding variables
    self.state = "hunting"

    -- Speed variables
    self.movementSpeed = 45
    self.retreatSpeed = 150
    self.speed = self.movementSpeed

    -- Amount of attacks before fleeing
    self.maxAttacks = 10

    -- Range at which entity will attack
    self.combatEngagementRange = 1000

    -- Health threshold for retreat
    self.retreatHealthThreshold = 5

    -- Aggression threshold
    self.aggressionThreshold = 10

    -- Attack cooldown
    self.attackCooldown = 3

    -- Attack damage
    self.attackDamage = 5

    -- Attack range
    self.attackRadius = 60

    -- Time it take to harvest or steal honey
    self.harvestingTime = 4

    -- Timer to track time spent harvesting or stealing
    self.harvestingTimer = 0

    -- Max amount of honey that can be stolen (in grams)
    self.maxLootCapacity = 5

    -- Previous state holder
    self.previousState = "hunting"

    self.attackTimer = 0
    self.attackRange = self.attackRadius
    self.targetType = nil
    self.attackedByPlayer = false
    self.lastAttackTime = 0
end

function HoneyBadger:draw()
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

function HoneyBadger:takeDamage(damage, attacker)
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
    -- Additional small chance for them to attack bees nearby
    if self.hitsTaken >= self.aggressionThreshold and self.state ~= "fleeing" and math.random() < 0.1 and attacker.type == "bee" then
        self.isUnderAttack = true
        self.target = attacker
        self.state = "attacking"
    end

    self:updateState()
end

function HoneyBadger:updateState(dt)
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
    
    if self.attackedByPlayer and self.state ~= "fleeing" then
        --honey badgers attack rather than flee
        self.state = "attacking"
        self.target = player
        self.targetType = "player"
        
        self.attackedByPlayer = false
    end
    
    if self.state == "attacking" and self.targetType == "player" and player then
        --calculate distance to player
        local dx = player.x - self.x
        local dy = player.y - self.y
        local distance = math.sqrt(dx*dx + dy*dy)
        
        --approach if not in attack range
        if distance > self.attackRange then
            local angle = math.atan2(dy, dx)
            self.x = self.x + math.cos(angle) * self.speed * dt
            self.y = self.y + math.sin(angle) * self.speed * dt
        else
            --check attack cooldown --- trying to prevent bug where multiples of the same enemy attack the player??
            local currentTime = love.timer.getTime()
            if currentTime - self.lastAttackTime >= self.attackCooldown then
                self:attackPlayer()
                self.lastAttackTime = currentTime
                
                if DebugMode then
                    print("Honey badger attacked player - damage dealt: " .. self.attackDamage)
                end
            end
        end
    end
end

function HoneyBadger:attackPlayer()
    if player and player.takeDamage then
        player:takeDamage(self.attackDamage)
        self.attackTimer = 0
        
        love.graphics.setColor(0.7, 0.4, 0, 0.3)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1, 1)
    end
end

return HoneyBadger