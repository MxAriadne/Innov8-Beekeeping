Bee = Object:extend()

function Bee:new()
    self.image = love.graphics.newImage("sprites/bee.png")
<<<<<<< Updated upstream
    self.x = 325
    self.y = 450
end


function Bee:draw()
    love.graphics.draw(self.image, self.x, self.y)
=======
    self.x = 275
    self.y = 300
    self.scale = 0.4
    self.width = self.image:getWidth() * self.scale
    self.height= self.image:getHeight()* self.scale
    self.speed = 60
    self.state = "foraging"
    self.hasNectar = false
    
    -- initializing pathfinding
    self.pathfinding = Pathfinding
    self.pathfinding:initialize()
    self.current_path       = nil
    self.current_path_index = 1

    -- nectar variables
    self.nectarCollectionTime = 2
    self.nectarTimer          = 0

    -- health & speed
    self.health       = 3
    self.maxHealth    = 3
    self.isRetreating = false
    self.retreatSpeed = 120
    self.normalSpeed  = 60
    self.speed        = self.normalSpeed
    
    -- combat stats
    self.attackDamage   = 0.5
    self.attackRange    = 25
    self.attackCooldown = 1.5
    self.attackTimer    = 0
    self.isAggressive   = false
    
    -- awareness
    self.threatDetectionRange = 150
    self.hiveProtectionRange  = 100
end

function Bee:update(dt)
    self:updateCombat(dt)
    self:updateState(dt)
    self:checkThreatLevel()
end

function Bee:updateState(dt)
    -- die => retreat
    if self.health <= 0 and not self.isRetreating then
        self.isRetreating= true
        self.speed       = self.retreatSpeed
        self.state       = "retreating"
        self.current_path= nil
        return
    end
    
    if self.state == "retreating" then
        self:moveToHive(dt)
        return
    end

    -- defend if threats near the hive
    if self.state ~= "defending" and hive then
        local distToHive = math.sqrt((self.x - hive.x)^2 + (self.y - hive.y)^2)
        if distToHive < self.hiveProtectionRange then
            local threat = self:findNearestThreat()
            if threat then
                self.state        = "defending"
                self.target       = threat
                self.isAggressive = true
                return
            end
        end
    end

    -- if target flees
    if self.state == "defending" and self.target and self.target.state == "fleeing" then
        self.target       = nil
        self.isAggressive = false
        self.current_path = nil
        self.current_path_index = 1

        if self.hasNectar then
            self.state = "returning"
        else
            self.state = "foraging"
        end
        return
    end

    if self.state == "foraging" then
        if self:isAtFlower() then
            self.state       = "collecting"
            self.nectarTimer = 0
            self.current_path= nil
            print("collecting nectar") -- debug
        else
            self:followPath(dt)
        end

    elseif self.state == "collecting" then
        self.nectarTimer = self.nectarTimer + dt
        if self.nectarTimer >= self.nectarCollectionTime then
            self.hasNectar = true
            self.state     = "returning"
            if hive then
                self.current_path = self.pathfinding:findPathToHive(self.x, self.y)
                self.current_path_index = 1
            end
        end

    elseif self.state == "returning" then
        if self:isAtHive() then
            if hive then
                hive.honey = hive.honey + 1
            end
            self.hasNectar   = false
            self.state       = "foraging"
            self.current_path= nil
        else
            self:followPath(dt)
        end

    elseif self.state == "defending" then
        if self.target then
            local dist = math.sqrt((self.x - self.target.x)^2 + (self.y - self.target.y)^2)
            local targetGridX = math.floor(self.target.x / 23)
            local targetGridY = math.floor(self.target.y / 22)
            local isValid     = (targetGridX >= 1 and targetGridX<=42 and targetGridY>=1 and targetGridY<=30)
            
            if not isValid then
                self.state       = (self.hasNectar and "returning") or "foraging"
                self.isAggressive= false
                self.target      = nil
                return
            end
            if dist > self.attackRange then
                local angle = math.atan2(self.target.y - self.y, self.target.x - self.x)
                self.x = self.x + math.cos(angle)*self.speed*dt
                self.y = self.y + math.sin(angle)*self.speed*dt
            end
        else
            self.state       = (self.hasNectar and "returning") or "foraging"
            self.isAggressive= false
        end
    end
end

function Bee:checkThreatLevel()
    if not hive then return end
    local threats = self:findThreats()
    local hiveUnderAttack = false
    for _, threat in ipairs(threats) do
        if threat.state == "stealing" then
            hiveUnderAttack = true
            break
        end
    end
    if hiveUnderAttack and self.state~="defending" and self.state~="retreating" then
        self.state        = "defending"
        self.isAggressive = true
        self.target       = self:findNearestThreat()
    end
end

function Bee:findThreats()
    local threats = {}
    if wasp and wasp.visible and wasp.state ~= "fleeing" then
        local dist = math.sqrt((self.x - wasp.x)^2 + (self.y - wasp.y)^2)
        if dist < self.threatDetectionRange then
            table.insert(threats, wasp)
        end
    end
    if honeybadger and honeybadger.visible and honeybadger.state ~= "fleeing" then
        local dist = math.sqrt((self.x - honeybadger.x)^2 + (self.y - honeybadger.y)^2)
        if dist < self.threatDetectionRange then
            table.insert(threats, honeybadger)
        end
    end
    return threats
end

function Bee:findNearestThreat()
    local threats = self:findThreats()
    local nearestDist   = math.huge
    local nearestThreat = nil
    for _, t in ipairs(threats) do
        local dist = math.sqrt((self.x - t.x)^2 + (self.y - t.y)^2)
        if dist < nearestDist then
            nearestDist   = dist
            nearestThreat = t
        end
    end
    return nearestThreat
end

function Bee:updateCombat(dt)
    self.attackTimer = self.attackTimer + dt
    if self.state == "defending" and self.target and (self.attackTimer >= self.attackCooldown) then
        local dist = math.sqrt((self.x - self.target.x)^2 + (self.y - self.target.y)^2)
        if dist <= self.attackRange then
            self:attack(self.target)
        end
    end
end

function Bee:attack(target)
    self.attackTimer = 0
    love.graphics.setColor(1,1,0,0.1)
    love.graphics.rectangle("fill", 0,0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1,1,1,1)

    if target.takeDamage then
        target:takeDamage(self.attackDamage, self)
    else
        target.health = (target.health or 1) - self.attackDamage
    end
end

function Bee:isAtFlower()
    if not flower then return false end
    local dist = math.sqrt((self.x - flower.x)^2 + (self.y - flower.y)^2)
    return dist < 5
end

function Bee:isAtHive()
    if not hive then return false end
    local dist = math.sqrt((self.x - hive.x)^2 + (self.y - hive.y)^2)
    return dist < 5
end

function Bee:moveToHive(dt)
    if not hive then return end
    local dx = hive.x - self.x
    local dy = (hive.y - 30) - self.y
    local distance = math.sqrt(dx*dx + dy*dy)
    if distance > 2 then
        local angle = math.atan2(dy, dx)
        self.x = self.x + math.cos(angle)*self.speed*dt
        self.y = self.y + math.sin(angle)*self.speed*dt
    else
        self.visible = false
        if hive.beeCount then
            hive.beeCount = hive.beeCount - 1
        end
    end
end

function Bee:followPath(dt)
    if not self.current_path then
        if self.state=="foraging" and flower then
            local gx = math.floor(flower.x/23)
            local gy = math.floor(flower.y/22)
            if gx>=1 and gx<=42 and gy>=1 and gy<=30 then
                self.current_path = self.pathfinding:findPathToFlower(self.x,self.y, flower.x,flower.y)
                self.current_path_index=1
            end
        elseif self.state=="returning" and hive then
            local gx = math.floor(hive.x/23)
            local gy = math.floor(hive.y/22)
            if gx>=1 and gx<=42 and gy>=1 and gy<=30 then
                self.current_path = self.pathfinding:findPathToHive(self.x,self.y)
                self.current_path_index=1
            else
                self:moveToHive(dt)
                return
            end
        end
        return
    end

    if self.current_path_index >= #self.current_path then
        local finalX, finalY
        if self.state=="foraging" and flower then
            finalX, finalY = flower.x, flower.y
        elseif self.state=="returning" and hive then
            finalX, finalY = hive.x, hive.y
        else
            self.current_path = nil
            self.current_path_index=1
            return
        end

        local dx = finalX - self.x
        local dy = finalY - self.y
        local dist= math.sqrt(dx*dx + dy*dy)
        if dist > 2 then
            local angle= math.atan2(dy, dx)
            self.x= self.x + math.cos(angle)*self.speed*dt
            self.y= self.y + math.sin(angle)*self.speed*dt
        end
        return
    end

    local targetNode = self.current_path[self.current_path_index]
    if not targetNode then
        self.current_path= nil
        self.current_path_index=1
        return
    end

    local dx = targetNode.x - self.x
    local dy = targetNode.y - self.y
    local dist= math.sqrt(dx*dx + dy*dy)
    if dist>2 then
        local angle= math.atan2(dy, dx)
        self.x= self.x + math.cos(angle)*self.speed*dt
        self.y= self.y + math.sin(angle)*self.speed*dt
    else
        self.current_path_index= self.current_path_index+1
    end
end

function Bee:draw()
    if not self.isRetreating then
        love.graphics.draw(self.image, self.x, self.y, 0, self.scale, self.scale)
        if debugMode then
            if self.current_path then
                love.graphics.setColor(0,1,0,0.5)
                for i=1, (#self.current_path-1) do
                    local c    = self.current_path[i]
                    local nxt  = self.current_path[i+1]
                    love.graphics.line(c.x,c.y, nxt.x,nxt.y)
                end
            end
            if self.isAggressive then
                love.graphics.setColor(1,0,0,0.2)
                love.graphics.circle("line", self.x, self.y, self.threatDetectionRange)
            end
            love.graphics.setColor(1,1,1,1)
            love.graphics.print(string.format(
                "State: %s\nHealth: %d/%d\nHas Nectar: %s",
                self.state, self.health, self.maxHealth, tostring(self.hasNectar)
            ), self.x-30, self.y-40)
        end
    end
>>>>>>> Stashed changes
end
