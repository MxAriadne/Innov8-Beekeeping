local Settings = {}

require "UI/design"
local slider = require "UI/simple-slider"
local dialove = require "libraries/Dialove/dialove"

scroll = 0
menuBottom = -300
menuTop = 0

function love.wheelmoved(x, y)
  if scroll > menuBottom  and scroll <=menuTop then
    scroll = scroll + y*15
    volumeSlider:updatescroll(y*15)
    typingVolumeSlider:updatescroll(y*15)
  elseif scroll > menuTop then
    scroll = 0
    volumeSlider:updatescroll(-15)
    typingVolumeSlider:updatescroll(-15)
  else
    scroll = scroll +15
    volumeSlider:updatescroll(15)
    typingVolumeSlider:updatescroll(15)
  end
end

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

    love.graphics.print("Volume", 100, 80+scroll)
    love.graphics.print("Typing Sound", 100, 180+scroll)
    love.graphics.print("Move Up", 100, 280+scroll)
      love.graphics.print("W", 580, 280+scroll)
    love.graphics.print("Move Left", 100, 380+scroll)
      love.graphics.print("A", 580, 380+scroll)
    love.graphics.print("Move Down", 100, 480+scroll)
      love.graphics.print("S", 580, 480+scroll)
    love.graphics.print("Move Left", 100, 580+scroll)
      love.graphics.print("D", 580, 580+scroll)
    love.graphics.print("Attack", 100, 680+scroll)
      love.graphics.print("Left Click", 580, 680+scroll)
    love.graphics.print("Place", 100, 780+scroll)
      love.graphics.print("F", 580, 780+scroll)

    love.graphics.setLineWidth(4)
    love.graphics.setColor(254, 67, 101)

    -- draw slider, set color and line style before calling
    volumeSlider:draw()
    typingVolumeSlider:draw()
end


return Settings
