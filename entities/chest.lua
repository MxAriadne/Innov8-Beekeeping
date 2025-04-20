local anim8 = require 'libraries.anim8'

Chest = Object:extend()

function Chest:new()
    self.id = #Entities + 1
    self.image = love.graphics.newImage("maps/Sprout Lands - Sprites - Basic pack/Objects/Chest.png")
    self.x = 95
    self.y = 75
    self.scale = 3.5
    self.width = 48
    self.height = 48

    self.x_offset = 80
    self.y_offset = 80

    self.visible = true

    --collider data
    self.collider = nil

    self.type = "Chest"

    self.opening = false

    self.grid = anim8.newGrid(48, 48, self.image:getWidth(), self.image:getHeight())
    self.openFrames = self.grid('1-5', 1)
    self.closeFrames = self.grid('5-1', 1)

    self.openAnimation = anim8.newAnimation(self.openFrames, 0.15, 'pauseAtEnd')
    self.closeAnimation = anim8.newAnimation(self.closeFrames, 0.15, 'pauseAtEnd')

    self.animation = self.closeAnimation

    self.animation:gotoFrame(5)

    --added
    return self

end

function Chest:update(dt)
    if not self.visible or self == nil then return end

    if player:distanceTo(self) < 150 then
        if not self.opening then
            self.opening = true
            self.animation = self.openAnimation
            self.animation:gotoFrame(1)
            self.animation:resume()
        end
    else
        if self.opening then
            self.opening = false
            self.animation = self.closeAnimation
            self.animation:gotoFrame(1)
            self.animation:resume()
        end
    end

    self.animation:update(dt)


    if self.collider == nil then
        --change World to Level
        self.collider = Level:newRectangleCollider(self.x - self.x_offset/self.scale, self.y, self.width, self.height/2)
        self.collider:setType('static')
        self.collider:setCollisionClass('Wall')
    end
end

function Chest:draw()
    if not self.visible or self == nil then return end
    
    self.animation:draw(self.image, self.x - self.x_offset, self.y - self.y_offset, 0, self.scale)
    love.graphics.setColor(1, 1, 1, 1)

end


return Chest