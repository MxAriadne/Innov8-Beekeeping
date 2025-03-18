local Dialove = require("libraries/Dialove.dialove")
local DayCycle = require("dayCycleScript")
local Beehive = require("libraries/beehive")
local Jumper = require("libraries/jumper")
local MenuState = require("states/MenuState")
local MainState = require("states/MainState")
GameStateManager = require("libraries/gamestateManager")

-- global variables
tintEnabled = false
debugMode = false

GameConfig = {}

function love.load()
    Object = require "classic"
    require "bee"
    require "flower"
    require "hive"
    require "wasp"
    require "honeybadger"
    
    --table for flowers
    flowers = {flower}

    music = love.audio.newSource("tunes/Flowers.mp3", "stream")
    music:setLooping(true)  --music loop
    music:play()  --playing the music

    dialogManager = Dialove.init({
        font = love.graphics.newFont('libraries/fonts/comic-neue/ComicNeue-Bold.ttf', 16)
      })

    -- Update GameConfig after setting the window mode
    GameConfig.windowW = love.graphics.getWidth()
    GameConfig.windowH = love.graphics.getHeight()

    --commenting out menu state for now while working on the main state
    --GameStateManager:setState(MenuState)
    GameStateManager:setState(MainState)
end


function love.update(dt)
    GameStateManager:update(dt)
    dialogManager:update(dt) -- update dia system
end

function love.draw()
    GameStateManager:draw()
    dialogManager:draw()
    ApplyBGTint()
end

-- helper functions from Poultry Profits
function checkCollision(a, b)
    return a.x < b.x + (b.width or b.size) and
           a.x + (a.width or a.size) > b.x and
           a.y < b.y + (b.height or b.size) and
           a.y + (a.height or a.size) > b.y
end

function isInPickupRange(a, b)
    local aCenterX = a.x + (a.width or a.size) / 2
    local aCenterY = a.y + (a.height or a.size) / 2
    local bCenterX = b.x + (b.width or b.size) / 2
    local bCenterY = b.y + (b.height or b.size) / 2
    local distance = math.sqrt((aCenterX - bCenterX)^2 + (aCenterY - bCenterY)^2)
    local range = 50  -- Adjusted pickup range
    return distance <= range
end

--[[ trigger event for day cycle
function love.keypressed(key)
    -- Check if the key for advancing the day was pressed
    if key == "space" then
        AdvanceDay()  -- Call the trigger updates function from dayCycleScript.lua
        if tintEnabled then
            NightSky()
            tintEnabled = false
        else
            DaySky()
            tintEnabled = true
        end

    --pathfinding debug toggle
    elseif key == "`" then  --tilde key
        debugMode = not debugMode
    end
end

function love.keypressed(k)
    -- Handle key presses to control the dialog flow
    if k == 'return' then
        dialogManager:pop()
    elseif k == 'c' then
        dialogManager:complete()
    elseif k == 'f' then
        dialogManager:faster()
    elseif k == 'b' then
        dialogManager:changeOption(1)  -- next one
    elseif k == 'n' then
        dialogManager:changeOption(-1) -- previous one
    end
end


function love.keyreleased(k)
    -- Handle the spacebar to adjust dialog speed
    if k == 's' then
        dialogManager:slower()
    end
end
]]

function love.keypressed(k)
    -- Handle spacebar for day cycle
    if k == "space" then
        AdvanceDay()  -- Call the trigger updates function from dayCycleScript.lua
        if tintEnabled then
            NightSky()
            tintEnabled = false
        else
            DaySky()
            tintEnabled = true
        end
    -- Handle dialog flow controls
    elseif k == 'return' then
        dialogManager:pop()
    elseif k == 'c' then
        dialogManager:complete()
    elseif k == 'f' then
        dialogManager:faster()
    elseif k == 'b' then
        dialogManager:changeOption(1)  -- next one
    elseif k == 'n' then
        dialogManager:changeOption(-1) -- previous one
    end
end

function love.keyreleased(k)
    -- Handle spacebar to adjust dialog speed
    if k == 's' then
        dialogManager:slower()
    end
end
