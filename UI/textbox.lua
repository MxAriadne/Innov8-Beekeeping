-- This file contains the implementation for a custom text box
-- Author: Amelia Reiss

local textbox = {}

-- This function creates a new textbox
function textbox:new(width, height, x, y)
    local newTextbox = {
        text = "",
        width = width,
        height = height,
        xPos = x or GameConfig.windowW / 2 - width / 2,
        yPos = y or GameConfig.windowH / 2 - height / 2,
        active = false,
        blinkTimer = 0,
        showCursor = true,
    }
    setmetatable(newTextbox, {__index = self})
    return newTextbox
end

-- This function makes the cursos blink every half second
function textbox:update(dt)
    if self.active then
        self.blinkTimer = self.blinkTimer + dt
        if self.blinkTimer >= .5 then
            self.blinkTimer = 0
            self.showCursor = not self.showCursor
        end
    end
end

function textbox:draw(font)
    -- Set font
    font = font or smallFont
    love.graphics.setFont(font)

    -- Set background
    love.graphics.setColor(colors.grey)
    love.graphics.rectangle("fill", self.xPos, self.yPos, self.width, self.height, 10, 10)

    -- Draw text
    love.graphics.setColor(0, 0, 0)
    local displayText = self.text
    if self.active and self.showCursor then
        displayText = displayText .. "|"
    end
    love.graphics.print(displayText, self.xPos + 10, self.yPos + (self.height - font:getHeight()) / 2)
end

-- Set textbox to active if clicked
function textbox:mousepressed(x, y, b)
    if b == 1 then
        self.active = x > self.xPos and x < self.xPos + self.width 
        and y > self.yPos and y < self.yPos + self.height
    end
end

-- Update text with input
function textbox:textinput(t)
    if self.active and #self.text < 20 then
        self.text = self.text .. t
    end
end

-- Allow backspace key to delete text
function textbox:keypressed(k)
    if self.active and k == "backspace" then
        self.text = self.text:sub(1, -2)
    end
end

return textbox