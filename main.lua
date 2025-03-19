-- Game State Manager
GameStateManager = require("libraries/gamestateManager")

local MenuState = require("states/MenuState")
local MainState = require("states/MainState")

GameConfig = {}

function love.load()
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
