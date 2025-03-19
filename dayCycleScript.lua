--dayCycleScript.lua file
--author: Elaina Vogel

-- TODO: update appropiate variables to show progression

--[[This file handles the day cycle aspect of the game]]

--quick read
--[[
    check days passed
    if a certain num, change bool for specific attack
        triggers event
    update everything
    
    outside fucntion decides to call night v day to show appropiate message

    correct tint is applied
]]

--local wasp = require("wasp")

daysPassed = 0.0;
bgTint = {0.1, 0, .2} -- tint for background(r, g, b)

-- days for attacks
waspDay = 5
waspGo = false
badgerDay = 10
badgerGo = false


--this function changes the day counter and triggers updates
--after user is done updating their hive for the day
function AdvanceDay()
    daysPassed = daysPassed + 0.5

    --dialogManager:show(daysPassed)


    -- tigger nightly updates
    TriggerUpdates()

end

--method to change to night
function NightSky()
    
    -- Show a night message using Dialove
    -- Push the night message to the dialog manager
    dialogManager:show('Good night, the day has ended!') -- stores dialog
    --dialogManager:show('days passed')
    --dialogManager:pop() -- requests the first pushed dialog to be shown on screen

    --add sleeping emotes?
end

--method to change to day
function DaySky()

    --day message
    dialogManager:show('Good morning!') -- stores dialog
    --dialogManager:push(daysPassed) -- requests the first pushed dialog to be shown on screen

    --flash any urgent messages
end

--method to update things throughout the night
function TriggerUpdates(dt)

    --check for attack
    if daysPassed == waspDay then
        --trigger wasp event
        waspGo = true
    elseif daysPassed == badgerDay then
        --trigger badger eent
        badgerGo = true
    
    end
    --update bee count
    --update hive
    --update flowers
    --update pollen
    --update health meters
    --update tools integrity
    --update...
end

-- applys a tint over everything using a transparent rectangle
function ApplyBGTint()
    if not tintEnabled then return end -- If tint is disabled, do nothing

    love.graphics.setColor(bgTint[1], bgTint[2], bgTint[3], 0.5) -- Add semi-transparent tint

    -- Disable blending issues by using "alpha" mode explicitly
    love.graphics.setBlendMode("alpha")

    -- Full-screen rectangle to overlay everything
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Reset blend mode and color to prevent issues
    love.graphics.setBlendMode("alpha") 
    love.graphics.setColor(1, 1, 1, 1) 
end
