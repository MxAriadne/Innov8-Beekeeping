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
    red = {1, 0, 0},
}

-- Space between buttons on menu
margin = 10

-- Fonts used on main menu screen
XSfont = love.graphics.newFont(12) -- Font for item descriptions
XSfont:setFilter(GameConfig.filter, GameConfig.filter)
SmallFont = love.graphics.newFont(24) -- Font for text and notes
SmallFont:setFilter(GameConfig.filter, GameConfig.filter)
MediumFont = love.graphics.newFont(36) -- Font for button text
MediumFont:setFilter(GameConfig.filter, GameConfig.filter)
LargeFont = love.graphics.newFont(84) -- Font for game title
LargeFont:setFilter(GameConfig.filter, GameConfig.filter)


-- Main menu colors
MenuBackgroundColor = colors.tan
GameTitleColor = colors.brown
MenuButtonColor = colors.yellow
HighlightedButtonColor = colors.darkYellow
MenuTextColor = colors.brown
