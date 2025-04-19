local Settings = {}

require "UI/design"
local slider = require "UI/simple-slider"
local dialove = require "libraries/Dialove/dialove"

function Settings:enter()
    volumeSlider = newSlider(600, 100, 300, love.audio.getVolume(), 0, 1, function (v) love.audio.setVolume(v) end)

    local savedTypingVolume = dialove:getTypingVolume()
    typingVolumeSlider = newSlider(600, 200, 300, savedTypingVolume, 0, 1, function (v) 
        dialove:setTypingVolume(v) 
    end)
end

function Settings:update(dt)
    if love.keyboard.isDown("escape") then
        GameStateManager:revertState()
    end
    volumeSlider:update()
    sliderValue = volumeSlider:getValue()

    typingVolumeSlider:update()
end

function Settings:draw()
    love.graphics.clear(MenuBackgroundColor or 0.1, 0.1, 0.1)
    love.graphics.setFont(MediumFont)
    love.graphics.setColor(1,1,1,1)

    love.graphics.print("Volume", 100, 80)
    love.graphics.print("Typing Sound", 100, 180)

    love.graphics.setLineWidth(4)
    love.graphics.setColor(254, 67, 101)

    -- draw slider, set color and line style before calling
    volumeSlider:draw()
    typingVolumeSlider:draw()
end

return Settings