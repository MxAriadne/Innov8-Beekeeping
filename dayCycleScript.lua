--dayCycleScript.lua file

--[[This file handles the day cycle aspent of the game]]

--include appropiate files

daysPassed = 0;

--this function changes the day counter
--called: after user is done updating their hive for the day
--output: changes the scenery to night/day and triggers events
    --this method is assuming the night graphics can be handled here 
    --and has no other functionality besides aesthetics.
function AdvanceDay()
    daysPassed = daysPassed + 1

    --either use the global variable daysPassed to change the graphics to indicate day/night
        --or do so here

    --night message
    isNight = true

    --change to NightSky()

    TriggerUpdates()

    --morning message
    isNight = false

    --change to DaySky()

end

--method to change to night
function NightSky()
    --change background to night sky
    --change lighting to darker
    --add sleeping emotes?
end

--method to change to day
function DaySky()
    --change background to day
    --change lighting back to light
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
