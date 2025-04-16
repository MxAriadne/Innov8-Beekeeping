local CharacterSelector = {}

-- Global variable to store the selected character index
Character = 1

local MainState = require("states/MainState")

local arrowLeft, arrowRight
local image, quads, currentIndex

local button = require("UI/button")

function CharacterSelector:enter()
    -- Load the character spritesheet
    image = love.graphics.newImage("sprites/spritesheet.png")

    -- Set frame dimensions
    local frameWidth, frameHeight = 64, 64

    -- Calculate how many frames horizontally and vertically
    local sheetWidth = image:getWidth() / frameWidth
    local sheetHeight = image:getHeight() / frameHeight

    -- Generate quads for each sprite frame
    quads = {}
    for y = 0, sheetHeight - 1 do
        for x = 0, sheetWidth - 1 do
            table.insert(quads, love.graphics.newQuad(
                x * frameWidth,
                y * frameHeight,
                frameWidth,
                frameHeight,
                image:getDimensions()
            ))
        end
    end

    -- Initialize name input text to empty
    --textInput = ""

    -- Start with the first character
    currentIndex = 1

    -- Create the left arrow button to go to the previous character
    arrowLeft = button:new("<", function()
        currentIndex = (currentIndex - 2) % #quads + 1
        Character = Character - 1
        if Character < 0 then
            Character = 8
        end
    end, 60, 60, 100, GameConfig.windowH / 2 - 30)

    -- Create the right arrow button to go to the next character
    arrowRight = button:new(">", function()
        currentIndex = currentIndex % #quads + 1
        Character = Character + 1
        if Character > 8 then
            Character = 0
        end
    end, 60, 60, GameConfig.windowW - 160, GameConfig.windowH / 2 - 30)

    -- Create a continue button to proceed to the main game state
    continueButton = button:new("Continue", function()
        GameStateManager:setState(MainState)
        FirstRun = false
    end, 150, 50, GameConfig.windowW / 2 - 75, GameConfig.windowH - 100)
end

function CharacterSelector:draw()
    -- Draw navigation buttons
    arrowLeft:draw(colors.yellow)
    arrowRight:draw(colors.yellow)

    -- Display prompt to enter player's name
    --love.graphics.setFont(love.graphics.newFont(18))
    love.graphics.setColor(0, 0, 0)  -- Set text color to black
    love.graphics.print("Enter your name:", GameConfig.windowW / 2 - 100, 30)

    -- Draw text input box
    love.graphics.rectangle("line", GameConfig.windowW / 2 - 100, 60, 200, 30)
    love.graphics.print(textInput, GameConfig.windowW / 2 - 95, 65)

    -- Draw the continue button
    continueButton:draw(colors.yellow, love.graphics.newFont(24), {0, 0, 0})

    -- Reset drawing color for full opacity, without this the character is blank.
    love.graphics.setColor(1, 1, 1, 1)

    -- Draw the currently selected character sprite
    local quad = quads[currentIndex]
    if quad then
        local scale = 4
        local x = (GameConfig.windowW - 64 * scale) / 2
        local y = (GameConfig.windowH - 64 * scale) / 2
        love.graphics.draw(image, quad, x, y, 0, scale, scale)
    end
end

function CharacterSelector:keypressed(key)
    if nameInputActive then
        if key == "backspace" then
            -- Remove last character from input
            textInput = textInput:sub(1, -2)
        elseif key == "return" then
            -- Exit name input mode
            nameInputActive = false
        end
    end
end

-- Handle text input for name entry
function CharacterSelector:textinput(text)
    if nameInputActive then
        -- Append typed character to input string
        textInput = textInput .. text
    end
end

function CharacterSelector:mousepressed(x, y, b)
    -- Pass click to arrow and continue buttons
    arrowLeft:mousepressed(x, y, b)
    arrowRight:mousepressed(x, y, b)
    continueButton:mousepressed(x, y, b)

    -- Detect if the name input box was clicked
    if x >= GameConfig.windowW / 2 - 100 and x <= GameConfig.windowW / 2 + 100 and y >= 60 and y <= 90 then
        nameInputActive = true  -- Activate text input
    else
        nameInputActive = false  -- Deactivate text input if clicked outside
    end
end

return CharacterSelector
