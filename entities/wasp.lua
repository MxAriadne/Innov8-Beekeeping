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
    self.x = x or 970
    self.y = y or math.random(100, 500)

    -- Scale of the entity
    self.scale = 0.6

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
    self.combatEngagementRange = 1000

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

    -- Set isFlying to true
    self.isFlying = true

    -- Set collision class
    self.collider:setCollisionClass("Flying")
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

return Wasp