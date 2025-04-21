-- This file defines functions used for implementing the UI buttons
-- Author: Amelia Reiss

local button = {}

-- This function creates a new button
function button:new(text, func, width, height, x, y)
    local newButton = {
        text = text, -- text on button
        func = func, -- function called when clicked
        width = width,
        height = height,
        -- by default, center button to window
        xPos = x or GameConfig.windowW / 2 - width / 2,
        yPos = y or GameConfig.windowH / 2 - height / 2, 
    }

    -- Allow button to inherit other functions defined
    setmetatable(newButton, {__index = self})

    return newButton
end

-- This function draws the button with the given design specifications
function button:draw(buttonColor, font, textColor)
    -- Set design parameters or assign default values
    local buttonColor = buttonColor or colors.white
    local font = font or MediumFont
    local textColor = textColor or colors.black

    -- Highlight button when hovered
    local cursorX, cursorY = love.mouse.getPosition()
    if self:hovering(cursorX, cursorY) then
        buttonColor = HighlightedButtonColor or colors.yellow
    end

    -- Draw the button
    love.graphics.setColor(buttonColor)
    love.graphics.rectangle("fill", self.xPos, self.yPos, self.width, self.height, 15, 15)

    -- Draw text
    love.graphics.setColor(textColor)
    local textW = font:getWidth(self.text)
    local textH = font:getHeight(self.text)
    love.graphics.print(self.text, font,
                        self.xPos + (self.width - textW) / 2,
                        self.yPos + (self.height - textH) / 2)
end

-- This function returns true if the cursor is hovering over the button and false otherwise
function button:hovering(cursorX, cursorY)
    -- local hovering = cursorX > self.xPos and cursorX < self.xPos + self.width and
    --             cursorY > self.yPos and cursorY < self.yPos + self.height
    -- return hovering
    return cursorX > self.xPos and cursorX < self.xPos + self.width and
            cursorY > self.yPos and cursorY < self.yPos + self.height
end

function button:mousepressed(x, y, mouseButton)
    if mouseButton == 1 and self:hovering(x, y) then
        self.func()
    end
end

-- This is a placeholder function
function temp()
    print("temp function called")
end

return button
