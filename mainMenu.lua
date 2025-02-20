-- This file contains functions to implement the main menu screen


-- This function creates a new button on the screen
-- text: the text displayed on the button
-- action: the function called when the button is clicked
function newButton(text, action)
    -- return the button 
    return{
        text = text,
        action = action,
    }
end

-- This function 
function loadMainMenu()
    -- Table of buttons for menu screen
    buttons = {}

    -- create the buttons and add them to the table
    table.insert(buttons, newButton("Start Game", temp()))
    table.insert(buttons, newButton("Load Game", loadGameSaves()))
    table.insert(buttons, newButton("Settings", loadSettings()))
    table.insert(buttons, newButton("Exit", exitGame))

    return {buttons}
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


-- temp placement function
function temp()
    print("this is a dummy function")
end