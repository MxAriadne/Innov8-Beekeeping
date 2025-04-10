local Settings = {}

require "UI/design"
local slider = require "UI/simple-slider"

function Settings:enter()
    volumeSlider = newSlider(400, 100, 300, love.audio.getVolume(), 0, 1, function (v) love.audio.setVolume(v) end)


end

function Settings:update(dt)
    if love.keyboard.isDown("escape") then
        GameStateManager:revertState()
    end
    volumeSlider:update()
    sliderValue = volumeSlider:getValue()
end

function Settings:draw()
  love.graphics.setLineWidth(4)
  love.graphics.setColor(254, 67, 101)

  -- draw slider, set color and line style before calling
  volumeSlider:draw()
end


return Settings
