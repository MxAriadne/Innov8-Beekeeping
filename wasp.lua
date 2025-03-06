local Pathfinding = require("pathfinding")

Wasp = Object:extend()

function Wasp:new()
    self.image = love.graphics.newImage("sprites/wasp.png")
    self.x = 700
    self.y = 250
    self.scale = 0.08
    self.width = self.image:getWidth() * self.scale
    self.height = self.image:getHeight() * self.scale
    self.speed = 70 --learned that wasps are more aerodynamic thans bees tmyk
    self.state = "idle"
    
    --initializing pathfinding
    self.pathfinding = Pathfinding
    self.pathfinding:initialize()
    self.current_path = nil
    self.current_path_index = 1
end

--might move this to code to findPath? and use update() for when taking damage/dead state
function Wasp:update(dt)
    --getting the path to the hive if it doesnt have one
    if not self.current_path then
        self.current_path = self.pathfinding:findPathToHive(self.x, self.y) --storing path in current_path
        self.current_path_index = 1 --starting at first index
    end

    --traveling from first point in path to last
    if self.current_path and self.current_path_index <= #self.current_path then
        local target = self.current_path[self.current_path_index]
        
        --calculating difference between wasp's and targets position and moving towards target
        local dx = target.x - self.x
        local dy = target.y - self.y
        local distance = math.sqrt(dx * dx + dy * dy) --the distance between them
        
        --when the wasp reaches its target (the distance is less than 2 pixels), it will travel to the next target in the list
        if distance > 2 then
            local angle = math.atan2(dy, dx)
            self.x = self.x + math.cos(angle) * self.speed * dt
            self.y = self.y + math.sin(angle) * self.speed * dt
        else
            self.current_path_index = self.current_path_index + 1
        end
    end
end

function Wasp:findPath()
    -- empty
end

--had plans for this being for attack scripts
function Wasp:targetHive()
    -- empty
end

function Wasp:draw()
    love.graphics.draw(self.image, self.x, self.y, 0, self.scale, self.scale)

    --debug, draws the wasp's path
    if self.current_path then
        love.graphics.setColor(1, 0, 0, 0.5) --red path
        for i = 1, #self.current_path - 1 do
            local current = self.current_path[i]
            local next = self.current_path[i + 1]
            love.graphics.line(current.x, current.y, next.x, next.y)
        end
        love.graphics.setColor(1, 1, 1, 1)
    end
end
