local CharacterSelector = {}

Character = 1

local MainState = require("states/MainState")

local arrowLeft, arrowRight
local image, quads, currentIndex
local button = require("UI/button") -- assumes you have a button module

function CharacterSelector:enter()
    -- Load spritesheet and generate quads
    image = love.graphics.newImage("sprites/spritesheet.png")
    local frameWidth, frameHeight = 64, 64
    local sheetWidth = image:getWidth() / frameWidth
    local sheetHeight = image:getHeight() / frameHeight

    quads = {}
    for y = 0, sheetHeight - 1 do
        for x = 0, sheetWidth - 1 do
            table.insert(quads, love.graphics.newQuad(x * frameWidth, y * frameHeight, frameWidth, frameHeight, image:getDimensions()))
        end
    end

    -- Initialize textInput to an empty string
    textInput = ""

    currentIndex = 1

    arrowLeft = button:new("<", function()
        currentIndex = (currentIndex - 2) % #quads + 1
        Character = Character - 1
    end, 60, 60, 100, love.graphics.getHeight() / 2 - 30)
    arrowRight = button:new(">", function()
        currentIndex = currentIndex % #quads + 1
        Character = Character + 1
    end, 60, 60, love.graphics.getWidth() - 160, love.graphics.getHeight() / 2 - 30)
    continueButton = button:new("Continue", function()
        GameStateManager:setState(MainState)
        FirstRun = false

        end, 150, 50, love.graphics.getWidth() / 2 - 75, love.graphics.getHeight() - 100)
end

function CharacterSelector:draw()
    arrowLeft:draw()
    arrowRight:draw()

    -- Draw the name input field at the top center
    love.graphics.setFont(love.graphics.newFont(18))
    love.graphics.setColor(0, 0, 0)  -- Black text color
    love.graphics.print("Enter your name:", love.graphics.getWidth() / 2 - 100, 30)

    -- Draw text input box
    love.graphics.rectangle("line", love.graphics.getWidth() / 2 - 100, 60, 200, 30)
    love.graphics.print(textInput, love.graphics.getWidth() / 2 - 95, 65)

    -- Draw continue button
    continueButton:draw({1, 1, 1}, love.graphics.newFont(24), {0, 0, 0})

    -- Allow full transparency
    love.graphics.setColor(1, 1, 1, 1)

    -- Draw central quad
    local quad = quads[currentIndex]
    if quad then
        local scale = 4
        local x = (love.graphics.getWidth() - 64 * scale) / 2
        local y = (love.graphics.getHeight() - 64 * scale) / 2
        love.graphics.draw(image, quad, x, y, 0, scale, scale)
    end
end

function CharacterSelector:keypressed(key)
    if nameInputActive then
        if key == "backspace" then
            textInput = textInput:sub(1, -2)
        elseif key == "return" then
            nameInputActive = false
        end
    end
end

function CharacterSelector:textinput(text)
    if nameInputActive then
        textInput = textInput .. text
    end
end

function CharacterSelector:mousepressed(x, y, b)
    arrowLeft:mousepressed(x, y, b)
    arrowRight:mousepressed(x, y, b)
    continueButton:mousepressed(x, y, b)

    -- Handle click on the text input box
    if x >= love.graphics.getWidth() / 2 - 100 and x <= love.graphics.getWidth() / 2 + 100 and y >= 60 and y <= 90 then
        nameInputActive = true  -- Activate name input
    else
        nameInputActive = false  -- Deactivate if clicked outside the box
    end

end

return CharacterSelector