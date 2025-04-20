HoneyBadger = Entity:extend()

function HoneyBadger:new(x, y)
    -- Parent constructor
    Entity.new(self)

    -- Health variables
    local buff = self:getDayBuff()
    self.health = 20 + (2 * buff)
    self.maxHealth = self.health

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
    self.y = y or math.random(100, 500)

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
    self.attackDamage = 5 + self:getDayBuff(0.1)

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

return HoneyBadger