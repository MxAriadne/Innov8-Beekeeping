-- This file contains functions to implement the main menu screen


-- This function creates a new button on the screen
function newButton(text, action)
    -- return the button 
    return{
        text = text, -- text on button
        action = action, -- function called when clicked
        clicked = false, -- true if button is clicked
        last = false
    }
end

-- This function generates the buttons. 
-- It will be called in love.load()
function loadMainMenu()
    buttons = {} -- Table of buttons for menu screen
    buttonFont = love.graphics.newFont(32) -- Font for button text
    titleFont = love.graphics.newFont(72) -- Font for title

    -- Table of colors used
    colors = {
        tan = {.784, .663, .553},
        yellow = {.902, .714, .333},
        darkYellow = {.702, .514, .133},
        brown = {.302, .173, .114}
    }

    -- Create the buttons and add them to the table
    table.insert(buttons, newButton("New Game", newGame))
    table.insert(buttons, newButton("Load Game", loadGameSaves))
    table.insert(buttons, newButton("Settings", loadSettings))
    table.insert(buttons, newButton("Exit", exitGame))

    return {buttons}
end

-- This function draws the created buttons on the screen. 
-- It will be called in love.draw()
function drawMainMenu()
    -- Variables for button placement and dimensions
    local windowW = love.graphics.getWidth()
    local windowH = love.graphics.getHeight()
    local buttonW = windowW / 3
    local buttonH = windowH / 10
    local margin = 16
    local totalButtonsHeight = (buttonH + margin) * #buttons

    -- Set background color
    love.graphics.setBackgroundColor(colors.tan)

    -- Draw title
    title = "Bizzy Beez"
    love.graphics.setColor(colors.brown)
    local titleW = windowW / 2 - love.graphics.getWidth() / 2
    local titleH = windowH / 2 - love.graphics.getHeight() / 2
    love.graphics.print(title, titleFont, titleW, titleH)


    -- Draw the buttons
    for i, button in ipairs(buttons) do
        button.last = button.clicked

        -- Button positions
        local buttonX = windowW / 2 - buttonW / 2
        local buttonY = windowH / 2 - totalButtonsHeight / 3 + i * (buttonH + margin)

        -- Highlight button if mouse is hovering
        local buttonColor = colors.yellow
        local mouseX, mouseY = love.mouse.getPosition()
        local hovering = mouseX > buttonX and mouseX < buttonX + buttonW and
                         mouseY > buttonY and mouseY < buttonY + buttonH
        if hovering then
            buttonColor = colors.darkYellow
        end

        -- Execute function if the button is clicked
        button.clicked = love.mouse.isDown(1)
        if button.clicked and not button.last and hovering then
            button.action()
        end

        -- Draw the buttons
        love.graphics.setColor(buttonColor)
        love.graphics.rectangle(
                            "fill", 
                            buttonX,
                            buttonY,
                            buttonW,
                            buttonH)

        -- Add text to the buttons
        love.graphics.setColor(colors.brown)
        local textWidth = buttonFont:getWidth(button.text)
        local textHeight = buttonFont:getHeight(button.text)
        love.graphics.print(
                        button.text, 
                        buttonFont, 
                        buttonX + (buttonW - textWidth) / 2, 
                        buttonY + (buttonH - textHeight) / 2)
    end
end


-- This function displays the screen for the player to select their save file.
function loadGameSaves()
    -- TODO
    print("Loading save files")
end

-- This function displays the settings screen
function loadSettings()
    -- TODO
    print ("Loading settings")
end

-- This function exits the game
function exitGame()
    print("Exiting game")
    love.event.quit(0)
end

-- This temp function starts a new game
function newGame()
    print("Starting a new game")
end