--dayCycleScript.lua file
--author: Elaina Vogel

-- TODO: dialog library, update appropiate variables

--[[This file handles the day cycle aspent of the game]]

--include appropiate files
--local Dialove = require "Dialove.dialove"

--quick read
--[[
    check days passed
    if a certain num, change bool for specific attack
        triggers event
    update everything
    repeat

]]

daysPassed = 0;
bgTint = {0.1, 0, .2} -- tint for background(r, g, b)

--this function changes the day counter
--called: after user is done updating their hive for the day
--output: changes the scenery to night/day and triggers events
    --this method is assuming the night graphics can be handled here 
    --and has no other functionality besides aesthetics.
function AdvanceDay()
    daysPassed = daysPassed + 1

    --either use the global variable daysPassed to change the graphics to indicate day/night
        --or do so here

  

    -- tigger nightly updates
    TriggerUpdates()



end

--method to change to night
function NightSky()
    
    -- Show a night message using Dialove
    -- Push the night message to the dialog manager
    dialogManager:show('Good night, the day has ended!') -- stores dialog
    --dialogManager:pop() -- requests the first pushed dialog to be shown on screen

    --add sleeping emotes?
end

--method to change to day
function DaySky()

    --day message
    dialogManager:show('Good morning!') -- stores dialog
    --dialogManager:pop() -- requests the first pushed dialog to be shown on screen

    --flash any urgent messages
end

--method to update things throughout the night
function TriggerUpdates(dt)

    --check for attack
    --[[
    if daysPassed == badgerDay
        BadgerAttackFunction()
    elseif daysPassed == 
    ]]

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
