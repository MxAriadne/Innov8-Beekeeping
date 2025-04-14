BeeEater = Entity:extend()

function BeeEater:new(x, y)
    -- Parent constructor
    Entity.new(self)

    -- Health variables
    self.health = 30
    self.maxHealth = 30

    -- Dimensions of the entity
    self.width = 64
    self.height = 64
    self.x_offset = 32
    self.y_offset = 32

    -- Image holder
    self.image = love.graphics.newImage("sprites/beeeater.png")

    -- List of entities that this one will try to fight
    -- THIS IS IN ORDER OF PRIORITY
    self.enemies = {"bee", "queenBee", "player"}

    -- Animation duration
    self.animationDuration = 2

    -- Animation holder
    self.animation = self:animate()

    -- Position of the entity
    self.x = x or 970
    self.y = y or math.random(100, 500)

    -- Scale of the entity
    self.scale = 0.7

    -- Type check
    self.type = "bee_eater"

    -- Target holder variable for movement
    self.target = nil or bee

    -- Pathfinding variables
    self.pathfinding = Pathfinding
    self.pathfinding:initialize()
    self.current_path = nil
    self.current_path_index = 1
    self.state = "hunting"

    -- Speed variables
    self.movementSpeed = 100
    self.retreatSpeed = 200
    self.speed = self.movementSpeed

    -- Is entity under attack?
    self.isUnderAttack = false

    -- Holder for last entity that attacked this one
    self.lastAttacker = nil

    -- Hits taken before retaliating
    self.aggressionThreshold = 2

    -- Hit tracker for retaliating
    self.hitsTaken = 0

    -- Amount of attacks before fleeing
    self.maxAttacks = 2

    -- Range at which entity will attack
    self.combatEngagementRange = 500

    -- Health threshold for retreat
    self.retreatHealthThreshold = 5

    -- Tracker for time since last attack
    self.attackTimer = 0

    -- Attack cooldown
    self.attackCooldown = 1

    -- Attack damage
    self.attackDamage = 1

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
end

function BeeEater:draw()
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

function BeeEater:attack()
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

    -- Regular attack, bee eaters will try to eat the bee itself
    -- So they don't try to steal honey.
    self.target:takeDamage(self.attackDamage, self)
    --self:addHitFeedback(self.target.x, self.target.y)
    self.isAggressive = true
end

return BeeEater