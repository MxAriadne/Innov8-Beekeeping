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

    -- Update GameConfig after setting the window mode
    GameConfig.windowW = love.graphics.getWidth()
    GameConfig.windowH = love.graphics.getHeight()

    love.graphics.setDefaultFilter("nearest", "nearest")

    --commenting out menu state for now while working on the main state
    --GameStateManager:setState(MenuState)
    GameStateManager:setState(MainState)
end


function love.update(dt)
    GameStateManager:update(dt)
    --dia:update(dt) -- update dia system
end

function love.draw()
    GameStateManager:draw()
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

-- trigger event for day cycle
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
