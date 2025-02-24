require "dayCycleScript" --includes script that handles night and day transitions

local cycleKey = "space" --for testing purposes, will change to what needs to trigger daycycle

function love.load(arg)
    -- require "dayCycleScript" --includes script that handles night and day transitions
    print("game loaded")
    
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
    -- apply current bg tint
    ApplyBGTint()

    -- testing purposes
    love.graphics.setColor(1,1,1)
    love.graphics.print("Days Passed: " .. daysPassed, 10, 10)
    local timeState = isNight and "Night" or "Day"
    love.graphics.print("Current Time: " .. timeState, 10, 30)


    love.graphics.rectangle("line", x, y, 200, 150)

    
end

-- trigger event for day cycle
function love.keypressed(key)
    -- Check if the key for advancing the day was pressed
    if key == cycleKey then
        print("advancing day")
        AdvanceDay()  -- Call the day/night cycle function from dayCycleScript.lua
    end
end
