-- Shop screen implementation
-- Author: Amelia Reiss

local ShopScreen = {}

-- Import relevant files
local ShopItems = require "ShopItems"
local button = require "UI/button"
local design = require "UI/design"
local modal  = require "UI/modal"

-- Setup
local itemsPerPage = 3
local pages = {"Hives", "Tools", "Flowers", "Bees"}
local pageKeys = {"ShopHives", "ShopTools", "ShopFlowers", "ShopBees"}
local selectedPage = "ShopHives"
local currentPage = 1

-- UI elements
local buttons = {}
local tabButtons = {}
local scrollButtons = {}
local exitButton = nil
local canvases = {}

-- Constants
local tabBaseX = 100
local tabSpacing = 200
local itemBaseY = 180
local itemSpacing = 160
local buyButtonX = 700
local canvasSize = 100

-- Preload canvases for item thumbnails
local function cacheItemCanvases()
    canvases = {}
    local page = ShopItems[selectedPage]
    for key, item in pairs(page) do
        if item.image and not canvases[item.name] then
            local canvas = love.graphics.newCanvas(canvasSize, canvasSize)
            love.graphics.setCanvas(canvas)
            love.graphics.clear()
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(item.image, 0, 0, 0, canvasSize / item.image:getWidth(), canvasSize / item.image:getHeight())
            love.graphics.setCanvas()
            canvases[item.name] = canvas
        end
    end
end

function ShopScreen:refreshItems()
    buttons = {}

    local page = ShopItems[selectedPage]
    local keys = {}
    for key in pairs(page) do table.insert(keys, key) end

    local startIndex = (currentPage - 1) * itemsPerPage + 1
    local endIndex = math.min(startIndex + itemsPerPage - 1, #keys)

    for i = startIndex, endIndex do
        local item = page[keys[i]]
        local y = itemBaseY + (i - startIndex) * itemSpacing

        local buyButton = button:new(item.price .. " KSh",
            function()
                BuyItem(item, selectedPage)
            end, 150, 50, buyButtonX, y + 30)

        table.insert(buttons, buyButton)
    end
end

-- Function to load UI elements for shop screen
function ShopScreen:enter()
    tabButtons = {}
    scrollButtons = {}
    cacheItemCanvases()

    -- Create exit button
    exitButton = button:new("X", CloseShop, 30, 30, 10, 10)

    -- Create page tabs
    for i, pageName in ipairs(pageKeys) do
        local x = tabBaseX + (i - 1) * tabSpacing
        tabButtons[i] = button:new(pages[i], function()
            selectedPage = pageKeys[i]
            currentPage = 1
            ShopScreen:refreshItems()
            cacheItemCanvases()
        end, 150, 50, x, 60)
    end

    -- Scroll buttons
    scrollButtons.up = button:new("^", function()
        currentPage = math.max(currentPage - 1, 1)
        ShopScreen:refreshItems()
    end, 40, 40, 700, 440)

    scrollButtons.down = button:new("v", function()
        currentPage = currentPage + 1
        ShopScreen:refreshItems()
    end, 40, 40, 700, 490)

    ShopScreen:refreshItems()
end

function ShopScreen:update(dt)
    if love.keyboard.isDown("escape") then
        GameStateManager:revertState() -- THIS RESETS THE WORLD EVERYTME YOU LEAVE
    end
end

function ShopScreen:draw()
    love.graphics.setBackgroundColor(colors.tan)
    exitButton:draw(colors.red, SmallFont, colors.black)

    love.graphics.setColor(0, 0, 0)
    love.graphics.setFont(SmallFont)
    love.graphics.print("Money: " .. tostring(PlayerMoney) .. " KSh", 700, 10)

    for i, tab in ipairs(tabButtons) do
        local isSelected = selectedPage == pageKeys[i]
        local bgColor = isSelected and colors.darkYellow or colors.yellow
        tab:draw(bgColor, MediumFont, colors.black)
        if isSelected then
            love.graphics.setColor(colors.black)
            love.graphics.rectangle("fill", tab.xPos, tab.yPos + tab.height - 5, tab.width, 5)
        end
    end

    local page = ShopItems[selectedPage]
    local keys = {}
    for key in pairs(page) do table.insert(keys, key) end
    local startIndex = (currentPage - 1) * itemsPerPage + 1
    local endIndex = math.min(startIndex + itemsPerPage - 1, #keys)

    for i = startIndex, endIndex do
        local item = page[keys[i]]
        local y = itemBaseY + (i - startIndex) * itemSpacing

        love.graphics.setFont(SmallFont)
        love.graphics.setColor(0, 0, 0)
        love.graphics.print(item.name, 50, y - 35)

        local canvas = canvases[item.name]
        if canvas then
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(canvas, 50, y)
        end

        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("line", 220, y, 400, 100)
        love.graphics.setFont(XSfont)
        love.graphics.printf(item.description .. "\n\n" .. item.extra, 230, y + 10, 340)

        buttons[i - startIndex + 1]:draw(colors.yellow, SmallFont, colors.black)
    end

    if currentPage > 1 then scrollButtons.up:draw() end
    if endIndex < #keys then scrollButtons.down:draw() end
end

function ShopScreen:mousepressed(x, y, b)
    if exitButton then exitButton:mousepressed(x, y, b) end
    for _, page in ipairs(tabButtons) do page:mousepressed(x, y, b) end
    for _, button in ipairs(buttons) do button:mousepressed(x, y, b) end
    for _, scroll in pairs(scrollButtons) do scroll:mousepressed(x, y, b) end
end

function CloseShop()
    print("Closed Shop Screen")
    GameStateManager:revertState() -- THIS RESETS THE WORLD EVERTIME YOU LEAVE
end

function BuyItem(item, selectedPage)
    if PlayerMoney >= item.price then
        PlayerMoney = PlayerMoney - item.price

        local message = selectedPage == "ShopTools" and item.name ~= "Wire Mesh"
            and item.name .. " is now in your inventory!"
            or "Press RIGHT-CLICK to place!"

        if selectedPage == "ShopTools" and item.name ~= "Wire Mesh" then
            table.insert(player.items, item)
        else
            CurrentBuildMode = string.gsub(item.name, "%s+", "")
        end

        modal:show("Success!", "You've bought a " .. item.name .. "!\n" .. message, {
            { label = "Continue", action = function() GameStateManager:revertState() end } -- THIS RESETS THE WORLD EVERYTIME YOU LEAVE
        })
    else
        modal:show("Not Enough Money!", "You don't have enough to buy this!", {
            { label = "Continue", action = function() print("Closed") end }
        })
    end
end

return ShopScreen