--dayCycleScript.lua file
--author: Elaina Vogel

-- TODO: dialog library, update appropiate variables

--[[This file handles the day cycle aspent of the game]]

--include appropiate files

daysPassed = 0;
isNight = false -- tracks time of day
bgTint = {1, 1, 1} -- tint for background(r, g, b)

--this function changes the day counter
--called: after user is done updating their hive for the day
--output: changes the scenery to night/day and triggers events
    --this method is assuming the night graphics can be handled here 
    --and has no other functionality besides aesthetics.
function AdvanceDay()
    daysPassed = daysPassed + 1

    --either use the global variable daysPassed to change the graphics to indicate day/night
        --or do so here

    --change to NightSky()
    NightSky()

    -- tigger nightly updates
    TriggerUpdates()

    --morning message
    isNight = false

    --change to DaySky()
    DaySky()

end

--method to change to night
function NightSky()
    --change background to night sky
    isNight = true
    bgTint = {0.2, 0.2, 0.5} -- dark blue tint
    
    -- show night mesage
    --ShowMessage("Good night!")

    --add sleeping emotes?
end

--method to change to day
function DaySky()
    --change background to day
    isNight = false
    bgTint = {1, 1, 1}

    --day message
    --ShowMessage("Morning!")

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

function ApplyBGTint()
    love.graphics.setColor(bgTint)

    -- TODO: change this later
    -- effect rectangle over entire screen
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
    love.graphics.setColor(1, 1, 1) -- reset color
end