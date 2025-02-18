function love.load(arg)
    require "dayCycleScript" --includes script that handles night and day transitions
    x = 100
    y = 50
end

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

function love.draw()
    love.graphics.rectangle("line", x, y, 200, 150)

    --print day/night messages
    if isNight then
        love.graphics.print("Good night!", 100, 50)
    else
        love.graphics.print("Good morning!", 100, 50)
    end
end
