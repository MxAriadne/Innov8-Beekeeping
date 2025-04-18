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
local SaveManager = require "save_manager"

--local DaysPassed = 0.0
local bgTint = {0.1, 0, .2} -- tint for background(r, g, b)

-- days for attacks
local eventDay = 1.0
local cycle = "day"

--this function changes the day counter
--after user is done updating their hive for the day
function DayCycle:AdvanceDay()
    DaysPassed = DaysPassed + 0.5
    print("DaysPassed: "..DaysPassed)
end

--method to change to night
function DayCycle:NightSky()
    HoneyTemp = TotalHoney

    -- Update cycle
    cycle = "night"

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

    -- Update timer
    Timer = 0;

    -- Update cycle
    cycle = "day"

    -- pop any old messages
    DialogManager:clearDialogs()

    --day message
    DialogManager:show(d.goodmorning) -- stores dialog

    modal:show("Dawn of Day " .. DaysPassed .. "!", string.format(
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
                                                        "Bee Count:", #ShopBees,
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

    -- tigger nightly updates
    self:TriggerUpdates()
end

--method to update things throughout the night
function DayCycle:TriggerUpdates(dt)

    local dayEvents = {
        [1] = "wasp",
        [2] = "bee_eater",
    }

    local nightEvents = {
        [1] = "badger",
        [2] = "moth",
    }

    local entities = {
        ["wasp"] = Wasp,
        ["bee_eater"] = BeeEater,
        ["badger"] = HoneyBadger,
        ["moth"] = Moth,
    }

    if DaysPassed == eventDay then
        -- Update event day randomly
        eventDay = eventDay + math.random(0.5, 2)

        if cycle == "night" then
            TintEnabled = true
            local event = nightEvents[math.random(1, #nightEvents)]

            local entity = entities[event]()
            entity.visible = false
            table.insert(Entities, entity)

            DialogManager:push(d[event .. "message"])
        else
            local event = dayEvents[math.random(1, #dayEvents)]

            local entity = entities[event]()
            entity.visible = false
            table.insert(Entities, entity)

            DialogManager:push(d[event .. "message"])
        end
    else
        PressSpaceAllowed = true
    end

    -- update save
    SaveManager.save()
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
