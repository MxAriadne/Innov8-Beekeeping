Object = require "classic"
local DayCycle = require("dayCycleScript")
local Beehive = require("libraries/beehive")
local Jumper = require("libraries/jumper")
local MenuState = require("states/MenuState")
local MainState = require("states/MainState")
local mainMenu = require("states/mainMenu")

-- Game State Manager
GameStateManager = require("libraries/gamestateManager")

GameConfig = {}

-------------------------------------------------------
 -- Money system + cost config
 -------------------------------------------------------
PlayerMoney = 100
HiveCost = 20
BeeCost = 5
FlowerCost = 3

 -------------------------------------------------------
 -- Arrays to store multiple objects
 -------------------------------------------------------
local hives = {}
local bees = {}
local flowers = {}

-- global variables
tintEnabled = false
debugMode = false

-- Current build mode: "hive", "bee", "flower", or nil
CurrentBuildMode = nil

function love.load()
    require "bee"
    require "flower"
    require "hive"
    require "wasp"
    require "honeybadger"
    require "player"

    --default flower, to be compatible with current implementation of enemy-behavior
    local flower = Flower()
    table.insert(flowers, flower)

    love.window.setMode(960, 640)

    -- Update GameConfig after setting the window mode
    GameConfig.windowW = love.graphics.getWidth()
    GameConfig.windowH = love.graphics.getHeight()

    love.graphics.setDefaultFilter("nearest", "nearest")

    GameStateManager:setState(mainMenu)
end

function love.update(dt)
    GameStateManager:update(dt)
    --converts honey to money
    for _, h in ipairs(hives) do
        if h.honey > 0 then
            PlayerMoney = PlayerMoney + h.honey
            h.honey = 0
        end
    end
end

function love.draw()
    GameStateManager:draw()
end

function love.mousepressed(x, y, b)
    local current = GameStateManager:getState()
    if current and current.mousepressed then
        current:mousepressed(x, y, b)
    end
end