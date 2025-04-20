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

local daysPassed = 0.0
local bgTint = {0.1, 0, .2} -- tint for background(r, g, b)

-- days for attacks
local eventDay = 1.0
local cycle = "day"
local dialogManager = nil -- LOCAL DIALOG MANAGER REFERENCE

--intializing dayCycle with the dialogManager
function DayCycle:init(dialogMgr)
    dialogManager = dialogMgr
end

--this function changes the day counter
--after user is done updating their hive for the day
function DayCycle:AdvanceDay()
    daysPassed = daysPassed + 0.5
end

--method to change to night
function DayCycle:NightSky()
    --dialogManager check
    if not dialogManager then 
        print("dm not initialized, intializing")
        if DialogManager then
            dialogManager = DialogManager
        else
            local Dialove = require("libraries/Dialove/dialove")
            dialogManager = Dialove.init({
                font = love.graphics.newFont('libraries/fonts/comic-neue/ComicNeue-Bold.ttf', 16),
                horizontalOffset = 300
            })
            DialogManager = dialogManager
        end
    end

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
    dialogManager:clearDialogs()

    --stop shop keys functionality?

    local dialove = require "libraries/Dialove/dialove"
    dialogManager:setTypingVolume(dialove:getTypingVolume())

    -- Show a night message using Dialove
    -- Push the night message to the dialog manager
    dialogManager:show(d.goodnight) -- stores dialog

    -- tigger nightly updates
    self:TriggerUpdates()
end

--method to change to day
function DayCycle:DaySky()
    if not dialogManager then 
        print("dm not initialized, intializing")
        if DialogManager then
            dialogManager = DialogManager
        else
            --if necessary
            local Dialove = require("libraries/Dialove/dialove")
            dialogManager = Dialove.init({
                font = love.graphics.newFont('libraries/fonts/comic-neue/ComicNeue-Bold.ttf', 16),
                horizontalOffset = 300
            })
            DialogManager = dialogManager
        end
    end

    -- lock space
    PressSpaceAllowed = false

    -- Update timer
    Timer = 0;

    -- Update cycle
    cycle = "day"

    --resetting player health back to max every morning
    if player then
        player.health = player.maxHealth
    end

    -- pop any old messages
    dialogManager:clearDialogs()

    local dialove = require "libraries/Dialove/dialove"
    dialogManager:setTypingVolume(dialove:getTypingVolume())

    --day message
    dialogManager:show(d.goodmorning) -- stores dialog

    modal:show("Dawn of Day " .. daysPassed .. "!", string.format(
                                                        "You have %d KSh!\n" ..
                                                        "Remember to press TAB to purchase new equipment!\n\n\n" ..
                                                        "Your bees produced %.2f grams of honey today!\n\n\n" ..
                                                        "Check out your stats:\n\n" ..
                                                        "%-25s %5d\n" ..
                                                        "%-25s %5d\n" ..
                                                        "%-25s %5d\n" ..
                                                        "%-25s %5d",
                                                        PlayerMoney,
                                                        (TotalHoney - HoneyTemp),
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
    --making sure DM is available
    if not dialogManager then 
        print("DialogManager not initialized")
        return
    end

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

    if daysPassed == eventDay then
        -- Update event day randomly
        eventDay = eventDay + math.random(0.5, 2)

        if cycle == "night" then
            TintEnabled = true
            local event = nightEvents[math.random(1, #nightEvents)]

            local entity = entities[event]()
            entity.visible = false
            table.insert(Entities, entity)

            dialogManager:push(d[event .. "message"])
        else
            local event = dayEvents[math.random(1, #dayEvents)]

            local entity = entities[event]()
            entity.visible = false
            table.insert(Entities, entity)

            dialogManager:push(d[event .. "message"])
        end
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

function DayCycle.getDaysPassed()
    return daysPassed
end

--getter for DialogManager
function DayCycle:getDialogManager()
    return dialogManager
end

return DayCycle
