-- This file contains design elements for the UI of the game
-- Colors, fonts, dimensions, etc. are all accessed here

-- Table of color options
colors = {
    tan = {.784, .663, .553},
    yellow = {.902, .714, .333},
    darkYellow = {.702, .514, .133},
    brown = {.302, .173, .114},
    grey = {.83, .83, .83},
    white = {1, 1, 1},
    black = {0, 0, 0},
}

-- Space between buttons on menu
margin = 10

-- Fonts used on main menu screen
smallFont = love.graphics.newFont(24) -- Font for text and notes
mediumFont = love.graphics.newFont(32) -- Font for button text
largeFont = love.graphics.newFont(72) -- Font for game title

-- Main menu colors
menuBackgroundColor = colors.tan
gameTitleColor = colors.brown
menuButtonColor = colors.yellow
highlightedButtonColor = colors.darkYellow
menuTextColor = colors.brown
