-- Load other files
local mainMenu = require "mainMenu"
local gameSaves = require "loadFilesScreen"

-- For nav testing: stateManager will handle later

function love.load(arg)
    -- Assuming window cannot be resized
    windowW, windowH = love.graphics.getDimensions()

    -- buttons = mainMenu:load()
    buttons = gameSaves:load()
end

function love.update(dt)
    
end

function love.draw()
    -- mainMenu:draw(buttons)
    gameSaves:draw(buttons)
end
