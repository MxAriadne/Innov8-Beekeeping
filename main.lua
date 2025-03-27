-- Game State Manager
GameStateManager = require("libraries/gamestateManager")

Object = require "classic"
local DayCycle = require("dayCycleScript")
local Beehive = require("libraries/beehive")
local Jumper = require("libraries/jumper")
local MenuState = require("states/MenuState")
local MainState = require("states/MainState")

GameConfig = {}

-------------------------------------------------------
 -- Money system + cost config
 -------------------------------------------------------
playerMoney = 50
hiveCost = 20
beeCost = 5
flowerCost = 3

 -------------------------------------------------------
 -- Arrays to store multiple objects
 -------------------------------------------------------
hives = {}
bees = {}
flowers = {}

-- Current build mode: "hive", "bee", "flower", or nil
currentBuildMode = nil

function love.load()
    require "bee"
    require "flower"
    require "hive"
    require "wasp"
    require "honeybadger"
    require "player"

    --default flower, to be compatible with current implementation of enemy-behavior
    flower = Flower()
    table.insert(flowers, flower)

    love.window.setMode(960, 640)

    -- Update GameConfig after setting the window mode
    GameConfig.windowW = love.graphics.getWidth()
    GameConfig.windowH = love.graphics.getHeight()

    love.graphics.setDefaultFilter("nearest", "nearest")

    GameStateManager:setState(MenuState)
end

function love.update(dt)
    GameStateManager:update(dt)
    --converts honey to money
    for _, h in ipairs(hives) do
        if h.honey > 0 then
            playerMoney = playerMoney + h.honey
            h.honey = 0
        end
    end
end

function love.draw()
    GameStateManager:draw()
end
