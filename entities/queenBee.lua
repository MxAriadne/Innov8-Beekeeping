QueenBee = Bee:extend()

function QueenBee:new(hive, x, y)
    Entity.new(self) --the bee constructor was doing somthing undesirable?
    
    -- Image holder
    self.image = love.graphics.newImage("sprites/queen_bee.png")

    -- Queen specific properties
    self.type = "queen_bee"
    self.is_queen = true
    
    -- scale and dimension
    self.scale = 1
    self.width = 64
    self.height = 64
    self.x_offset = 32
    self.y_offset = 32
    
    -- Animation holder
    self.animation = self:animate()
    
    -- Combat
    self.attackDamage = 3
    self.attackRadius = 15
    self.attackCooldown = 1.0
    self.attackTimer = 0
    
    -- Queen specific
    self.age = 0
    self.maxAge = 100 -- Max age, reached at 20 ingame minutes
    self.agingRate = 100 / (20 * 60)
    self.wanderRadius = 50
    self.speed = 40
    
    -- Home hive
    self.homeHive = hive
    
    -- Initial state
    self.state = "guarding"
    self.stateTimer = 0
    
    -- No foraging
    self.hasNectar = false
    self.canForage = false
    
    -- Health
    self.health = 50
    self.maxHealth = 50
    
    -- Other properties
    self.visible = true
    self.threatDetectionRange = 100
    
    return self
end

function QueenBee:update(dt)
    if not self.visible then return end
    
    --damage indicator
    for i = #self.damageIndicator, 1, -1 do
        local hit = self.damageIndicator[i]
        hit.timer = hit.timer - dt
        if hit.timer <= 0 then
            table.remove(self.damageIndicator, i)
        end
    end
    self:updateState(dt) 
end

function QueenBee:updateState(dt)
    --debug stuff
    if DebugMode then
        print("Queen Bee current state:", self.state)
    end
    
    if self.state ~= "guarding" and self.state ~= "moving" and self.state ~= "attacking" then
        print("Forcing queen bee state from", self.state, "to guarding")
        self.state = "guarding"
    end
    
    self.stateTimer = (self.stateTimer or 0) + dt
    self.age = (self.age or 0) + (dt * (self.agingRate or 0.001))

    if self.state == "guarding" then
        self.target = nil
        
        if self.stateTimer > 5 then
            if self.homeHive then
                local angle = math.random() * math.pi * 2
                local distance = math.random(10, self.wanderRadius or 50)
                self.targetX = self.homeHive.x + math.cos(angle) * distance
                self.targetY = self.homeHive.y + math.sin(angle) * distance
                
                print("Queen Bee moving to:", self.targetX, self.targetY)
                self.state = "moving"
                self.stateTimer = 0
            else
                self:findNearestHive()
            end
        end
    elseif self.state == "moving" then
        if not self.targetX or not self.targetY then
            print("Queen Bee has no target position")
            self.state = "guarding"
            self.stateTimer = 0
            return
        end
        
        local dx = self.targetX - self.x
        local dy = self.targetY - self.y
        local distance = math.sqrt(dx * dx + dy * dy)
        
        --debug
        if distance < 5 then
            print("Queen Bee reached target")
            self.state = "guarding"
            self.stateTimer = 0
            return
        end
        
        --moving to target
        local angle = math.atan2(dy, dx)
        self.x = self.x + math.cos(angle) * (self.speed or 40) * dt
        self.y = self.y + math.sin(angle) * (self.speed or 40) * dt
        
        --was having an issue where the bee didnt recognize the hive? i think this is left over now
        if self.stateTimer > 10 then
            print("Queen Bee movement timed out")
            self.state = "guarding"
            self.stateTimer = 0
        end
    elseif self.state == "attacking" then
        if not self.target or not self.target.visible then
            print("Queen Bee target lost")
            self.state = "guarding"
            return
        end
        
        self.attackTimer = (self.attackTimer or 0) + dt
        
        local dx = self.target.x - self.x
        local dy = self.target.y - self.y
        local distance = math.sqrt(dx * dx + dy * dy)
        
        if distance <= (self.attackRadius or 15) and self.attackTimer >= (self.attackCooldown or 1.0) then
            if self.target.takeDamage then
                self.target:takeDamage((self.attackDamage or 3), self)
                print("Queen Bee attacked target")
            end
            self.attackTimer = 0
        else
            -- Move toward target
            local angle = math.atan2(dy, dx)
            self.x = self.x + math.cos(angle) * (self.speed or 40) * dt
            self.y = self.y + math.sin(angle) * (self.speed or 40) * dt
        end
    end
    
    self:checkForThreats()
end

function QueenBee:findNearestHive()
    local closestHive = nil
    local minDist = math.huge
    
    for _, entity in ipairs(Entities) do
        if entity.type == "hive" then
            local dx = entity.x - self.x
            local dy = entity.y - self.y
            local dist = math.sqrt(dx*dx + dy*dy)
            
            if dist < minDist then
                minDist = dist
                closestHive = entity
            end
        end
    end
    
    if closestHive then
        self.homeHive = closestHive
        print("Queen Bee found hive at:", closestHive.x, closestHive.y)
    end
end

function QueenBee:move(dt)
    --handled in updateState
end

function QueenBee:checkForThreats()
    local threatDistance = self.threatDetectionRange or 100

    for _, entity in ipairs(Entities) do
        if (entity.type == "wasp" or entity.type == "honey_badger") and entity.visible then
            local dx = entity.x - self.x
            local dy = entity.y - self.y
            local dist = math.sqrt(dx*dx + dy*dy)
            
            if dist < threatDistance then
                print("Queen Bee detected threat:", entity.type)
                self.state = "attacking"
                self.target = entity
                self.stateTimer = 0
                return
            end
        end
    end
end

return QueenBee