function love.load(arg)
    Object = require "classic"
    require "bee"
    require "flower"
    require "hive"

    hive = Hive()
    bee = Bee()
    flower = Flower()

    x = 100
    y = 50
end
--[[
function love.update(dt)
    if love.keyboard.isDown("right") then
        x = x + 100 * dt
    elseif love.keyboard.isDown("left") then
        x = x - 100 * dt
    elseif love.keyboard.isDown("up") then
        y = y - 100 * dt
    elseif love.keyboard.isDown("down") then
        y = y + 100 * dt
    end
end
--]]

function love.draw()
    love.graphics.setBackgroundColor(255, 105, 180)
    
    bee:draw()
    hive:draw()
    flower:draw()
end

