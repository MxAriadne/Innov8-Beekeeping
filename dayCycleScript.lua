--dayCycleScript.lua file
--author: Elaina Vogel

-- TODO: update appropiate variables to show progression (tool and fence integrity), add shop trigger in daycycle

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

local DayCycle = {}

local d = require("dialogs")
local tips = require("tips")

local daysPassed = 0.0;
local bgTint = {0.1, 0, .2} -- tint for background(r, g, b)

-- days for attacks
local waspDay = 1 --5
WaspGo = false
BadgerDay = 3 --10
BadgerGo = false

--this function changes the day counter
--after user is done updating their hive for the day
function DayCycle:AdvanceDay()
    daysPassed = daysPassed + 0.5
end

--method to change to night
function DayCycle:NightSky()
    HoneyTemp = TotalHoney

    -- lock space
    PressSpaceAllowed = false
    print("before update")
    print(PressSpaceAllowed)

    -- update timer
    Timer = 0;

    -- pop any old messages
    DialogManager:clearDialogs()

    --stop shop keys functionality?

    -- Show a night message using Dialove
    -- Push the night message to the dialog manager
    DialogManager:show(d.goodnight) -- stores dialog

    -- tigger nightly updates
    self:TriggerUpdates()

end

--method to change to day
function DayCycle:DaySky()
    -- lock space
    PressSpaceAllowed = false

    -- update timer
    Timer = 0;

    -- pop any old messages
    DialogManager:clearDialogs()

    --day message
    DialogManager:show(d.goodmorning) -- stores dialog

    --load stat message with variables
    local morningstats = {
        text = string.format("Check out your stats: You have %d KSh.\nYour hive's health is at %d.\nYour hive's honey count is at %d. \nYour bee count is %d. \nYour sword is at %d strength. \nYour fences are at %d strength.", PlayerMoney, hive.health, hive.honey, #Bees, 0, 0),
        options = {} -- no choices, signals end of dialogue
    }

    modal:show("Dawn of Day " .. daysPassed .. "!", string.format(
                                                        "You have %d KSh!\n" ..
                                                        "Remember to press TAB to purchase new equipment!\n\n\n" ..
                                                        "Your bees produced " .. (TotalHoney - HoneyTemp) .. " grams of honey today!\n\n\n" ..
                                                        "Check out your stats:\n\n" ..
                                                        "%-25s %5d\n" ..
                                                        "%-25s %5d\n" ..
                                                        "%-25s %5d\n" ..
                                                        "%-25s %5d",
                                                        PlayerMoney,
                                                        "Honey Count:", TotalHoney,
                                                        "Bee Count:", #Bees,
                                                        "Sword Strength:", 0,
                                                        "Fence Strength:", 0
                                                    ) .. "\n\n\n" .. tips[math.random(1, #tips)],
    {
        {
            label = "Continue", action =
            function()
                modal:close()
            end
        }
    }, 512, 512)

    --send update message
    --DialogManager:push(morningstats)

    --shop populates

    -- tigger nightly updates
    self:TriggerUpdates()


end

--method to update things throughout the night
function DayCycle:TriggerUpdates(dt)

    --check for attack
    if daysPassed == waspDay then
        TintEnabled = true
        DialogManager:push(d.waspmessage)


    elseif daysPassed == BadgerDay+0.5 then

        DialogManager:push(d.badgermessage)

    else
        PressSpaceAllowed = true
    end


end

-- applys a tint over everything using a transparent rectangle
function DayCycle:ApplyBGTint()
    if not TintEnabled then return end -- If tint is disabled, do nothing

    love.graphics.setColor(bgTint[1], bgTint[2], bgTint[3], 0.5) -- Add semi-transparent tint

    -- Disable blending issues by using "alpha" mode explicitly
    love.graphics.setBlendMode("alpha")

    -- Full-screen rectangle to overlay everything
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    -- Reset blend mode and color to prevent issues
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(1, 1, 1, 1)
end

return DayCycle
