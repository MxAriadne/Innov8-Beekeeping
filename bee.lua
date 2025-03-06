local Pathfinding = require("pathfinding")

Bee = Object:extend()

function Bee:new()
    self.image = love.graphics.newImage("sprites/bee.png")
    self.x = 275
    self.y = 300
    self.scale = 0.4
    self.width = self.image:getWidth() * self.scale
    self.height = self.image:getHeight() * self.scale
    self.speed = 60      --slower than wasps and honey badgers
    self.state = "idle"
    self.hasNectar = false
    
    --initalizing pathfinding
    self.pathfinding = Pathfinding
    self.pathfinding:initialize()
    self.current_path = nil
    self.current_path_index = 1
end

function Bee:update(dt)
    --getting a path to a flower (if there is one)
    if not self.current_path and flower then
        self.current_path = self.pathfinding:findPathToFlower(self.x, self.y, flower.x, flower.y)
        self.current_path_index = 1
    end

    --following path
    if self.current_path and self.current_path_index <= #self.current_path then
        local target = self.current_path[self.current_path_index]
        
        --moving towards target
        local dx = target.x - self.x
        local dy = target.y - self.y
        local distance = math.sqrt(dx * dx + dy * dy)
        
        --moving onto next coord pair in list when close enough to current pair
        if distance > 2 then
            local angle = math.atan2(dy, dx)
            self.x = self.x + math.cos(angle) * self.speed * dt
            self.y = self.y + math.sin(angle) * self.speed * dt
        else
            self.current_path_index = self.current_path_index + 1
        end
    end
end

function Bee:draw()
    love.graphics.draw(self.image, self.x, self.y, 0, self.scale, self.scale)

    --debug, drawing the bee's path
    if debugMode and self.current_path then
        love.graphics.setColor(0, 1, 0, 0.5) -- bee has a green colored path
        for i = 1, #self.current_path - 1 do
            local current = self.current_path[i]
            local next = self.current_path[i + 1]
            love.graphics.line(current.x, current.y, next.x, next.y)
        end
        love.graphics.setColor(1, 1, 1, 1)
    end
end
