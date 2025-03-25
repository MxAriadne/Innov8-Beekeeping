-- Game State Manager
GameStateManager = require("libraries/gamestateManager")

local DayCycle = require("dayCycleScript")
local Beehive = require("libraries/beehive")
local Jumper = require("libraries/jumper")
local MenuState = require("states/MenuState")
local MainState = require("states/MainState")

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

    love.window.setMode(960, 640)

    -- Update GameConfig after setting the window mode
    GameConfig.windowW = love.graphics.getWidth()
    GameConfig.windowH = love.graphics.getHeight()

    love.graphics.setDefaultFilter("nearest", "nearest")

    GameStateManager:setState(MenuState)
end

function love.update(dt)
    GameStateManager:update(dt)
end

function love.draw()
    GameStateManager:draw()
end
