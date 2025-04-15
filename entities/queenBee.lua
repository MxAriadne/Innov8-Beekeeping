QueenBee = Bee:extend()

function QueenBee:new(home, x, y)
    -- Call parent constructor
    Bee.new(self, home, x, y)

    -- Queen specific properties
    self.is_queen = true

    -- Image holder
    self.image = love.graphics.newImage("sprites/queen_bee.png")

    -- Dimensions of the entity
    self.width = 64
    self.height = 64
    self.x_offset = 32
    self.y_offset = 32

    -- Scale
    self.scale = 1

    -- Animation holder
    self.animation = self:animate()

    -- Aging properties
    self.age = 0
    self.maxAge = 100 -- Max age, reached at 20 ingame minutes
    self.ageTimer = 0
    self.agingRate = 100 / (20 * 60)

    -- Health
    self.health = 50
    self.maxHealth = 50

    -- Range at which entity will attack.
    -- Queen doesn't leave the hive.
    self.combatEngagementRange = 80

    -- Movement
    self.state = "moving" -- Initially moves to hive
    self.previousState = "moving" -- Queen doesn't forage
    self.wanderRadius = 50 -- Stays close to hive

    -- Type check
    self.type = "queenBee"

    -- Set isFlying to true
    self.isFlying = true

    -- Hive holder
    self.target = self.homeHive
end

-- Override parent update function
function QueenBee:update(dt)
    -- Call parent update
    Bee.update(self, dt)

    -- Aging
    self.ageTimer = self.ageTimer + dt
    if self.ageTimer >= 1 then
        self.age = self.age + self.agingRate
        self.ageTimer = 0

        if self.age > self.maxAge then
            self.age = self.maxAge
        end
    end

    -- Starts losing health when age is 80
    if self.age > 80 then
        self.healthTimer = (self.healthTimer or 0) + dt
        if self.healthTimer >= 10 then
            self.health = math.max(1, self.health - 1)
            self.healthTimer = 0
        end
    end
end

function QueenBee:uniqueUpdate(dt)
    if self.state == "foraging" then self.state = "guarding" self.target = self.homeHive end
    if self.state == "fleeing" then self.state = "guarding" self.target = self.homeHive end
    if self.state == "hunting" then self.state = "guarding" self.target = self.homeHive end

    -- If state is wandering, look for newly placed hive
    if self.state == "wandering" then
        print(self.id .. " " .. self.type .. ": " .. "Missing hive...wandering...")
        -- Loop through entities
        for _, h in ipairs(Entities) do
            -- Check if the hive is a hive, visible, closer than the current closest, and not on harvesting cooldown
            if h.type == "hive" then
                self.homeHive = h
                self.target = self.homeHive
                self.state = "moving"
                break
            end
        end
    end

    self.stateTimer = (self.stateTimer or 0) + dt

    -- If state is guarding, check for threats
    if self.state == "guarding" then
        for _, e in ipairs(Entities) do
            if contains(self.enemies, e.type) then
                if self:distanceFromObject(e) < self.combatEngagementRange then
                    self.state = "attacking"
                    self.isAggressive = true
                    self.target = e
                    break
                else
                    self.state = "moving"
                    self.isAggressive = false
                    self.target = self.homeHive
                end
            end
        end
    end

    -- If state is moving, move to target
    if self.state == "moving" then
        local dx = self.target.x - self.x
        local dy = self.target.y - self.y
        local dist = math.sqrt(dx * dx + dy * dy)

        if dist < 2 then
            self.state = "guarding"
            self.stateTimer = 0
        end
    end

    -- If state is attacking, move to target
    if self.state == "attacking" then
        self:move(dt)
        self.state = "guarding"
    end
end

return QueenBee
