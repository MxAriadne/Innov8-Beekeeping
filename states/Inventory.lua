-- This file contains implementation for the inventory screen
-- Author: Amelia Reiss

local inventory = {}
local button = require "UI/button"

local pages = {"Hives", "Tools"}
-- CHANGE IF ALLOWING CHARACTER SPRITE SELECTION
local characterSprite = love.graphics.newImage("sprites/front.png")

function inventory:enter()
    self.page = 1
    self.maxItemsPerPage = 3
    self.selectedTab = "Hives"

    -- Tabs
    self.toolsTab = button:new("Tools", function()
        self.selectedTab = "Tools"
    end, 150, 50, 400, 40)

    self.hivesTab = button:new("Hives", function()
        self.selectedTab = "Hives"
    end, 150, 50, 600, 40)

    -- Exit button
    self.exitButton = button:new("X", function()
        GameStateManager:revertState()
    end,  30, 30, 10, 10)
end

function inventory:draw()
    love.graphics.setBackgroundColor(colors.tan)

    -- Exit button
    self.exitButton:draw(colors.red, SmallFont, colors.black)

    -- Page buttons
    local tabButtons = {self.hivesTab, self.toolsTab}
    for i, tab in ipairs(tabButtons) do
        local isSelected = self.selectedTab == pages[i]
        local bgColor = isSelected and colors.darkYellow or colors.yellow
        tab:draw(bgColor, MediumFont, colors.black)
        if isSelected then
            love.graphics.setColor(colors.black)
            love.graphics.rectangle("fill", tab.xPos, tab.yPos + tab.height - 5, tab.width, 5)
        end
    end

    -- Character sprite
    love.graphics.setColor(colors.black)
    love.graphics.rectangle("line", 100, 150, 200, 400)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.draw(characterSprite, 75, 230, 0, 0.5)


    -- Username
    love.graphics.setColor(colors.black)
    love.graphics.setFont(SmallFont)
    love.graphics.printf(PlayerName or "Name", 100, 90, 100)
    love.graphics.setFont(XSfont)

    -- Get player's current items and hives
    local items = {}
    if self.selectedTab == "Tools" then
        items = player.items or {}
    elseif self.selectedTab == "Hives" then
        for _, e in ipairs(Entities) do
            if e.type == "hive" then
                table.insert(items, e)
            end
        end
    end

    -- Draw 3 items per page
    local startIndex = (self.page - 1) * self.maxItemsPerPage + 1

    for i = startIndex, math.min(#items, startIndex + self.maxItemsPerPage - 1) do
        local item = items[i]
        if item then
            local slotY = 150 + (i - startIndex) * 120

            -- Draw image
            love.graphics.setColor(1, 1, 1)
            local canvasSize = 280
            if item.image then
                local canvas = love.graphics.newCanvas(canvasSize, canvasSize)
                love.graphics.setCanvas(canvas)
                love.graphics.clear()
                love.graphics.setColor(1, 1, 1)
                love.graphics.draw(item.image, 0, 0, 0, canvasSize / item.image:getWidth(), canvasSize / item.image:getHeight())
                love.graphics.setCanvas()
                love.graphics.draw(canvas, 400, slotY - 20, 0, 0.5, 0.5)
            else
                love.graphics.rectangle("line", 400, slotY, 64, 64)
            end

            -- Draw description/stat box
            love.graphics.setColor(colors.tan)
            love.graphics.rectangle("fill", 600, slotY, 300, 100)
            love.graphics.setColor(colors.black)
            love.graphics.rectangle("line", 600, slotY, 300, 100)

            if self.selectedTab == "Tools" then
                love.graphics.printf(item.description or "No description.", 610, slotY + 20, 280, "left")
            else
                love.graphics.printf("Bees: " .. tostring(item.bees or 0), 610, slotY + 20, 280, "left")
                love.graphics.printf("Honey: " .. tostring(item.honey or 0), 610, slotY + 40, 280, "left")
                love.graphics.printf("Health: " .. tostring(item.health or 0), 610, slotY + 60, 280, "left")
            end
        end
    end
end

function inventory:mousepressed(x, y, button)
    self.exitButton:mousepressed(x, y, button)
    self.toolsTab:mousepressed(x, y, button)
    self.hivesTab:mousepressed(x, y, button)
end

return inventory