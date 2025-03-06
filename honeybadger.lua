local Pathfinding = require("pathfinding")

HoneyBadger = Object:extend()

function HoneyBadger:new()
    self.image = love.graphics.newImage("sprites/honey-badger.png")
    self.x = 600
    self.y = 150
    self.scale = 0.5
    self.width = self.image:getWidth() * self.scale
    self.height = self.image:getHeight() * self.scale
    
    --initializing the pathfinding
    self.pathfinding = Pathfinding
    self.pathfinding:initialize()
    self.current_path = nil
    self.current_path_index = 1
    self.speed = 100
end

function HoneyBadger:draw()
    love.graphics.draw(self.image, self.x, self.y, 0, self.scale, self.scale)

    --debug, draws the honey badger's path
    if self.current_path then
        love.graphics.setColor(0.7, 0.4, 0, 0.5)  --brown path for hb
        for i = 1, #self.current_path - 1 do
            local current = self.current_path[i]
            local next = self.current_path[i + 1]
            love.graphics.line(current.x, current.y, next.x, next.y)
        end
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function HoneyBadger:update(dt)
    --getting path to hive
    if not self.current_path then
        self.current_path = self.pathfinding:findPathToHive(self.x, self.y)
        self.current_path_index = 1
    end

    --following path
    if self.current_path and self.current_path_index <= #self.current_path then
        local target = self.current_path[self.current_path_index]
        
        --approaching target
        local dx = target.x - self.x
        local dy = target.y - self.y
        local distance = math.sqrt(dx * dx + dy * dy)
        
        --moving onto the next coordinate pair when close enough to current pair
        if distance > 2 then
            local angle = math.atan2(dy, dx)
            self.x = self.x + math.cos(angle) * self.speed * dt
            self.y = self.y + math.sin(angle) * self.speed * dt
        else
            self.current_path_index = self.current_path_index + 1
        end
    end
end
