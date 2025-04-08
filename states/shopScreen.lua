-- Shop screen implementation
-- Author: Amelia Reiss

local shopScreen = {}

-- Import relevant files
local shop = require "shopItems"
local button = require "UI/button"
local design = require "UI/design"
local modal  = require "UI/modal"

-- ***** Import player info here *******
local player = {
    items =
    {
         shop.tools.basicSword
    }
}

-- Setup
local itemsPerPage = 3
local pages = {"Hives", "Tools", "Flowers", "Bees"}
local pageKeys = {"hives", "tools", "flowers", "bees"}
local selectedPage = "hives"
local currentPage = 1

-- UI elements
local buttons = {}
local tabButtons = {}
local scrollButtons = {}
local exitButton = nil
local canvases = {}

-- Function to load UI elements for shop screen
function shopScreen:enter()
    -- Create buttons used on screen
    buttons = {}
    tabButtons = {}
    scrollButtons = {}
    canvases = {}

    -- Create exit button
    exitButton = button:new("X", CloseShop, 30, 30, 10, 10)

    -- Create page tabs
    for i, pageName in ipairs(pageKeys) do
        local x = 100 + (i-1) * 200
        tabButtons[i] = button:new(pages[i],
                                    function()
                                        selectedPage = pageKeys[i]
                                        currentPage = 1
                                        shopScreen:enter()
                                    end, 150, 50, x, 60)
    end

    -- Create scroll buttons
    scrollButtons.up = button:new("^",
                                    function()
                                        currentPage = math.max(currentPage - 1, 1)
                                        shopScreen:enter()
                                    end, 40, 40, 700, 440)
    scrollButtons.down = button:new("v",
                                    function()
                                        currentPage = currentPage + 1
                                        shopScreen:enter()
                                    end, 40, 40, 700, 440)


    -- Create item Buy buttons
    local page = shop[selectedPage]
    local keys = {}
    for key in pairs(page) do table.insert(keys, key) end

    local startIndex = (currentPage - 1) * itemsPerPage + 1
    local endIndex = math.min(startIndex + itemsPerPage - 1, #keys)
    local displayY = 180
    local spacing = 160

    for i = startIndex, endIndex do
        local item = page[keys[i]]
        local y = displayY + (i - startIndex) * spacing

        local buyButton = button:new(item.price .. " KSh",
            function()
                BuyItem(item, selectedPage)
            end, 150, 50, 700, y + 30)

        table.insert(buttons, buyButton)
    end

end

function shopScreen:update(dt)
    if love.keyboard.isDown("escape") then
        GameStateManager:revertState()
    end
end

-- Function to draw screen
function shopScreen:draw()
    -- Set background
    love.graphics.setBackgroundColor(colors.tan)

    -- Draw header
    exitButton:draw(colors.red, smallFont, colors.black)
    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(smallFont)
    love.graphics.print("Money: " .. tostring(PlayerMoney) .. " KSh", 700, 10)

    -- Draw page tabs
    for i, tab in ipairs(tabButtons) do
        local isSelected = selectedPage == pageKeys[i]
        local bgColor = isSelected and colors.darkYellow or colors.yellow
        tab:draw(bgColor, mediumFont, colors.black)

        -- Underline current tab
        if isSelected then
            love.graphics.setColor(colors.black)
            love.graphics.rectangle("fill", tab.xPos, tab.yPos + tab.height-5, tab.width, 5)
        end
    end

    -- Get items available in shop
    local page = shop[selectedPage]
    local keys = {}
    for key in pairs(page) do table.insert(keys, key) end

    -- Positioning for item images
    local startIndex = (currentPage - 1) * itemsPerPage + 1
    local endIndex = math.min(startIndex + itemsPerPage - 1, #keys)
    local displayY = 180
    local spacing = 160

    for i = startIndex, endIndex do
        local item = page[keys[i]]
        local y = displayY + (i - startIndex) * spacing

        -- Write item name
        love.graphics.setFont(smallFont)
        love.graphics.print(item.name, 50, y - 35)

        -- Draw image
        local canvas = love.graphics.newCanvas(100, 100)
        love.graphics.setCanvas(canvas)
        love.graphics.clear()
        love.graphics.setColor(1, 1, 1)
        love.graphics.draw(item.image, 0, 0, 0, 100/item.image:getWidth(), 100/item.image:getHeight())
        love.graphics.setCanvas()
        love.graphics.draw(canvas, 50, y)

        -- Draw description
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("line", 220, y, 400, 100)
        love.graphics.setFont(XSfont)
        love.graphics.printf(item.description .. "\n\n" .. item.extra, 230, y+10, 340)

        -- Buy button
        buttons[i - startIndex + 1]:draw(colors.yellow, smallFont, colors.black)

    end

    -- Draw scroll buttons
    if currentPage > 1 then scrollButtons.up:draw() end
    if endIndex < #keys then scrollButtons.down:draw() end

end

-- Check if any buttons were clicked
function shopScreen:mousepressed(x, y, b)
    if exitButton then exitButton:mousepressed(x, y, b) end
    for _, page in ipairs(tabButtons) do page:mousepressed(x, y, b) end
    for _, button in ipairs(buttons) do
        button:mousepressed(x, y, b)
    end
    for _, scrolls in pairs(scrollButtons) do scrolls:mousepressed(x, y, b) end
end

-- ***** CLOSE SHOP SCREEN *****
function CloseShop()
    print("Closed Shop Screen")
    GameStateManager:revertState()

end

-- ****** BUY ITEM ******
function BuyItem(item, selectedPage)
    if PlayerMoney >= item.price and selectedPage ~= "tools" then
        PlayerMoney = PlayerMoney - item.price
        CurrentBuildMode = string.gsub(item.name, "%s+", "")

        modal:show("Success!", "You've bought a " .. item.name .. "!\nPress RIGHT-CLICK to place!", {
            { label = "Continue", action = function() GameStateManager:revertState() end }
        })
    elseif PlayerMoney >= item.price then
        PlayerMoney = PlayerMoney - item.price
        table.insert(player.items, item)

        modal:show("Success!", "You've bought a " .. item.name .. "!\nIt is now in your inventory", {
          { label = "Continue", action = function() GameStateManager:revertState() end }
        })
    else
        modal:show("Not Enough Money!", "You don't have enough to buy this!", {
            { label = "Continue", action = function() print("Closed") end }
        })
    end
end

return shopScreen
