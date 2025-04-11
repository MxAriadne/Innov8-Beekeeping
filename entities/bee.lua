Bee = Entity:extend()

function Bee:new(home, x, y)
    -- Call parent constructor
    Entity.new(self)

    -- ID is the index of the entity in the parent table
    self.id = #Entities + 1

    -- Default values
    self.visible = true

    -- Health variables
    self.health = 3
    self.maxHealth = 3

    -- Dimensions of the entity
    self.width = 64
    self.height = 64
    self.x_offset = 64
    self.y_offset = 48

    -- Image holder
    self.image = love.graphics.newImage("sprites/Bee_Walk.png")

    -- Animation duration
    self.animationDuration = 1

    -- Animation holder
    self.animation = self:animate()

    -- The hive closest to the Bee when placed is calculated and assigned.
    -- This means the bee will always return nectar here.
    self.homeHive = home

    -- The closest flower to the Bee is calculated on update based on the path they take.
    self.closestFlower = nil

    -- The last flower they harvested.
    -- We keep this value so we can determine how much honey should be produced since flower type impacts rate.
    self.lastFlower = flower

    -- Position of the entity
    self.x = x or 0
    self.y = y or 0

    -- Scale of the entity
    self.scale = 2

    -- Collider holder
    self.collider = nil

    -- Type check
    self.type = "bee"

    -- Target holder variable for movement
    self.target = nil

    -- Pathfinding variables
    self.pathfinding = Pathfinding
    self.pathfinding:initialize()
    self.current_path = nil
    self.current_path_index = 1
    self.state = "foraging"

    -- Speed variables
    self.movementSpeed = 40
    self.retreatSpeed = 100
    self.speed = self.movementSpeed

    -- Is this entity naturally hostile?
    self.isAggressive = false

    -- List of entities that this one will try to fight
    self.enemies = {"wasp", "honey_badger"}

    -- Is entity under attack?
    self.isUnderAttack = false

    -- Holder for last entity that attacked this one
    self.lastAttacker = nil

    -- Hits taken before retaliating
    self.aggressionThreshold = 1

    -- Hit tracker for retaliating
    self.hitsTaken = 0

    -- Amount of attacks before fleeing
    self.maxAttacks = math.huge

    -- Range at which entity will attack
    self.combatEngagementRange = 150

    -- Health threshold for retreat
    self.retreatHealthThreshold = 1

    -- Tracker for time since last attack
    self.attackTimer = 0

    -- Attack cooldown
    self.attackCooldown = 1.5

    -- Attack damage
    self.attackDamage = 1

    -- Attack range
    self.attackRadius = 10

    -- Time it take to harvest or steal honey
    self.harvestingTime = 2

    -- Timer to track time spent harvesting or stealing
    self.harvestingTimer = 0

    -- Max amount of honey that can be stolen (in grams)
    self.maxLootCapacity = 3

    -- Current amount of honey held
    self.currentLoot = 0

    -- Boolean to track if entity has honey
    self.hasLoot = false

    -- Previous state holder
    self.previousState = "foraging"
end

function Bee:update(dt)
    -- If entity is hidden, skip update
    if not self.visible or self == nil then return end
    if not self.homeHive then
        print("Home hive not found, making wander.")
        self.state = "wandering"
    end

    -- Update animations
    if self.animation then
        self.animation.currentTime = self.animation.currentTime + dt
        if self.animation.currentTime >= self.animation.duration then
            self.animation.currentTime = self.animation.currentTime - self.animation.duration
        end
    end

    -- Bee specific state check
    self:uniqueUpdate(dt)

    -- Run a check on the state
    self:updateState(dt)

    -- Check if we need to move
    self:move(dt)
end

function Bee:uniqueUpdate(dt)
    self.previousState = self.state
    -- If state is foraging, find nearest flower
    if self.state == "foraging" then
        -- Reset flower since the state is reset to foraging after depositing nectar
        self.closestFlower = nil
        -- Loop through entities
        for _, f in ipairs(Entities) do
            -- Check if the flower is a flower, visible, closer than the current closest, and not on harvesting cooldown
            if f.type == "flower" then
                -- If no closest flower is found, set the first flower as the closest
                if not self.closestFlower then self.closestFlower = f end

                -- If the flower is closer than the current closest and not on cooldown, set it as the closest
                if f.visible and self:distanceFromObject(f) < self:distanceFromObject(self.closestFlower) and f.onCooldown == false then
                    self.closestFlower = f
                end
            end
        end

        -- If a closest flower is found, set it as the target
        if self.closestFlower then
            self.target = self.closestFlower
        end
    end

    -- If state is wandering, look for newly placed hive
    if self.state == "wandering" then
        print(self.id .. " " .. self.type .. ": " .. "Missing hive...wandering...")
        -- Loop through entities
        for _, h in ipairs(Entities) do
            -- Check if the hive is a hive, visible, closer than the current closest, and not on harvesting cooldown
            if h.type == "hive" then
                self.homeHive = h
                self.state = "returning"
                break
            end
        end
    end

    -- If state is foraging and closest flower is found, move to it
    if self.state == "foraging" and self.closestFlower then
        self:move(dt)
    end

    -- If state is collecting, check if we have enough nectar
    if self.state == "collecting" then
        -- If we're maxed out
        if self.currentLoot >= self.maxLootCapacity then
            -- Return to hive
            self.state = "returning"
        end
        -- If we're not maxed out, keep harvesting
        self.harvestingTimer = self.harvestingTimer + dt
        -- If we've been harvesting long enough, return to hive
        if self.harvestingTimer >= self.harvestingTime then
            -- Set nectar flag and return to hive
            self.hasLoot = true
            -- Returning state
            self.state = "returning"
            -- Find path to hive
            self.current_path = self.pathfinding:findPathToHive(self.x, self.y, self.homeHive.x, self.homeHive.y)
            -- Reset path index
            self.current_path_index = 1
        end
    end

    -- If state is returning, move to hive
    if self.state == "returning" then
        self.target = self.homeHive
        self:move(dt)
    end

end

return Bee