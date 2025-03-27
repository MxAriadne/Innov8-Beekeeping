--dayCycleScript.lua file
--author: Elaina Vogel

-- TODO: update appropiate variables to show progression (money and fence integrity), delay wasp attack so user has time to defend

--[[This file handles the day cycle aspect of the game]]

--quick read
--[[
    update days passed
    call day/night function to match tint
        display appropiate message
        trigger events
        display updates stats

    in trigger:
    if a certain num, change bool for specific attack
        triggers event
    update everything
]]

local d = require("dialogs")

daysPassed = 0.0;
bgTint = {0.1, 0, .2} -- tint for background(r, g, b)

-- days for attacks
waspDay = 1 --5
waspGo = false
badgerDay = 2 --10
badgerGo = false

--this function changes the day counter
--after user is done updating their hive for the day
function AdvanceDay()
    daysPassed = daysPassed + 0.5


end

--method to change to night
function NightSky()

    -- Show a night message using Dialove
    -- Push the night message to the dialog manager
    dialogManager:show(d.goodnight) -- stores dialog

    -- tigger nightly updates
    TriggerUpdates()

    --add sleeping emotes?
end

--method to change to day
function DaySky()

    --day message
    dialogManager:show(d.goodmorning) -- stores dialog

    -- tigger nightly updates
    TriggerUpdates()

    --load stat message with variables
    local morningstats = {
        text = string.format("Check out your stats:\nYour hive's health is at %d.\nYour hive's honey count is at %d.\nYour bee count is %d.\nYour fences are at %d strength.", hive.health, hive.honey, hive.beeCount, 0),
        options = {} -- no choices, signals end of dialogue
    }
    --send update message
    dialogManager:push(morningstats)
end

--method to update things throughout the night
function TriggerUpdates(dt)

    --check for attack
    if daysPassed == waspDay+0.5 then
        --trigger wasp event
        waspGo = true
       dialogManager:push(d.waspmessage)

    elseif daysPassed == badgerDay+0.5 then
        --trigger badger eent
        badgerGo = true
        dialogManager:push(d.badgermessage)

    end

    --update health meters
    --[[
    if hive.beeCount >= 1 then
        
    end
]]
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
