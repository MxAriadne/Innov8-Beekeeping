-- Create the MainState table to act as the game state object
local MainState = {}

-- Importing external libraries and modules used in the game
Object = require("libraries.classic")
local sti = require 'libraries/sti'
local wf = require 'libraries/windfield'
local HUD = require "UI/HUD"
local Dialove = require("libraries/Dialove.dialove")
local dialogs = require("dialogs")
local Player = require "entities.player"
local SaveManager = require "save_manager"
local DayCycle = require("dayCycleScript")

-- Initial setup
function MainState:enter()

    -- Load the tilemap
    Map = sti('maps/TilesForBeekeepingGameTopBoundaries.lua')

    -- Initialize dialog system
    DialogManager = Dialove.init({
        font = love.graphics.newFont('libraries/fonts/comic-neue/ComicNeue-Bold.ttf', 16),
        horizontalOffset = 300 -- Add offset to shift dialog box to the right
    })

    --Setting Typing Sound Volume
    if Dialove:getTypingVolume() then
        DialogManager:setTypingVolume(Dialove:getTypingVolume())
    end
    
    --intializing dayCycle to have reference to DialogManager
    DayCycle:init(DialogManager)

    -- Initialize everything if this is the first time opening the state.
    -- This stops everything from doubling when reverting state from menus.
    if FirstRun then
        World = wf.newWorld(0, 0, 100)
        -- Define collision categories
        World:addCollisionClass('Wall')
        World:addCollisionClass('Hive')
        World:addCollisionClass('Fence')
        World:addCollisionClass('Flying', {ignores = {'Fence', 'Wall'}})
        World:addCollisionClass('Bee', {ignores = {'Fence', 'Wall'}})
        World:addCollisionClass('Enemy', {ignores = {'Enemy'}})
        World:addCollisionClass('Player', {ignores = {'Player', 'Bee', 'Enemy', 'Flying'}})

        -- Ensure entity table exist before inserting
        if not Entities then Entities = {} end

        -- Assign instances to globals for other modules to access
        hive = Hive()
        flower = Flower(500, 500)
        player = Player()
        bee = Bee(hive, 275, 300)
        chest = Chest()

        -- Create a collider for the first hive
        local wall = World:newRectangleCollider(
            hive.x - hive.width/2,
            hive.y - hive.height/2,
            hive.width,
            hive.height-32
        )

        wall:setType('static')
        wall:setCollisionClass('Hive')

        hive.collider = wall

        -- Set up player collider
        player.collider = World:newRectangleCollider(480, 340, player.width/2, player.height/2)
        player.collider:setFixedRotation(true)
        player.collider:setObject(player)
        player.collider:setCollisionClass('Player')

        --making sure volume is correctly set before entering the startupM
        local dialove = require "libraries/Dialove/dialove"
        DialogManager:setTypingVolume(dialove:getTypingVolume())
        
        -- Start tutorial dialog
        DialogManager:show(dialogs.startupM)

        -- Init honey total
        TotalHoney = 0

        -- Add created entities to their respective tables
        table.insert(Entities, hive)
        table.insert(Entities, bee)
        table.insert(Entities, flower)
        table.insert(Entities, player)
        table.insert(Entities, chest)
    else
        --making sure DayCycle has the DialogManager reference
        DayCycle:init(DialogManager)
    end

    -- Load HUD
    HUD:load()

    -- Create colliders for each wall tile
    local walls = {}
    if Map.layers["Walls"] then
        for _, obj in pairs(Map.layers["Walls"].objects) do
            local wall = World:newRectangleCollider(obj.x*2, obj.y*2, obj.width*2, obj.height*2)
            wall:setType('static')
            wall:setCollisionClass('Wall')
            table.insert(walls, wall)
        end
    end
end

function MainState:update(dt)
    DialogManager:update(dt)
    World:update(dt)
    HUD:update(dt)
    chest:update(dt)

    -- Update all entities
    for _, e in ipairs(Entities) do
        e:update(dt)

        if not e.visible then
            e = nil
        end

    end

    -- Press escape to save and quit
    if love.keyboard.isDown("escape") then
        SaveManager.save()
        GameStateManager:setState(PauseMenu)
    end
end

-- Called when a key is pressed
function MainState:keypressed(k)
    if k == "space" then
        if PressSpaceAllowed then
            -- Toggle day/night
            DayCycle:AdvanceDay()
            if not TintEnabled then
                DayCycle:NightSky()
                TintEnabled = true
            else
                DayCycle:DaySky()
                TintEnabled = false
            end
        end
    elseif k == 'return' then
        -- Close dialogue box
        DialogManager:pop()
    elseif k == 'c' then
        -- Complete dialogue instantly
        DialogManager:complete()
    elseif k == 'b' then
        -- Next dialogue option
        DialogManager:changeOption(1)
    elseif k == 'n' then
        -- Previous dialogue option
        DialogManager:changeOption(-1)
    elseif k == "`" then
        -- Toggle debug mode
        DebugMode = not DebugMode
        print("Debug mode: " .. (DebugMode and "ON" or "OFF"))
    elseif k == "tab" then
        -- Open shop screen
        GameStateManager:setState(ShopScreen)
    elseif k == "f" then
        -- DEBUG
        CurrentBuildMode = "Fence"
    elseif k == "1" then
        InventoryPosition = 1
        player.itemInHand = player.items[1]
    elseif k == "2" then
        InventoryPosition = 2
        player.itemInHand = player.items[2]
    elseif k == "3" then
        InventoryPosition = 3
        player.itemInHand = player.items[3]
    elseif k == "4" then
        InventoryPosition = 4
        player.itemInHand = player.items[4]
    elseif k == "5" then
        InventoryPosition = 5
        player.itemInHand = player.items[5]
    end
    
end

-- Called when a key is released
function MainState:keyreleased(k)
    print("State Key released:", k)

    -- Pass key release to player
    player:keyreleased(k)

    -- Dialogue slowdown
    if k == 's' then
        DialogManager:slower()
    end
end

BuildOptions = {
    LangstrothHive = function(x, y)
        local h = LangstrothHive(); h.x = x; h.y = y;
        -- Create a collider for the hive
        local wall = World:newRectangleCollider(
            h.x - h.width/2,
            h.y - h.height/2,
            h.width,
            h.height-32
        )

        wall:setType('static')
        wall:setCollisionClass('Hive')

        h.collider = wall

        table.insert(Entities, h)
    end,
    LogHive = function(x, y)
        local h = Hive(); h.x = x; h.y = y;
        -- Create a collider for the hive
        local wall = World:newRectangleCollider(
            h.x - h.width/2,
            h.y - h.height/2,
            h.width,
            h.height-32
        )

        wall:setType('static')
        wall:setCollisionClass('Hive')

        h.collider = wall

        table.insert(Entities, h)
    end,
    TopBarHive = function(x, y)
        local h = TopBarHive(); h.x = x; h.y = y;
        -- Create a collider for the hive
        local wall = World:newRectangleCollider(
            h.x - h.width/2,
            h.y - h.height/2,
            h.width,
            h.height-32
        )

        wall:setType('static')
        wall:setCollisionClass('Hive')

        h.collider = wall

        table.insert(Entities, h)
    end,
    Orchid = function(x, y)
        local f = Flower(); f.x = x; f.y = y; table.insert(Entities, f)
    end,
    GoldenDewdrops = function(x, y)
        local f = GoldenDewdrops(); f.x = x; f.y = y; table.insert(Entities, f)
    end,
    CommonLantana = function(x, y)
        local f = CommonLantana(); f.x = x; f.y = y; table.insert(Entities, f)
    end,
    Bee = function(x, y)
        local closestHive = nil
        for _, e in ipairs(Entities) do
            if e.type == "hive" then
                if closestHive == nil then
                    closestHive = e
                else
                    if (x - e.x) * (x - e.x) + (y - e.y) * (y - e.y) < (x - closestHive.x) * (x - closestHive.x) + (y - closestHive.y) * (y - closestHive.y) then
                        closestHive = e
                    end
                end
            end
        end

        if closestHive then
            closestHive:updateHoneyProduction()
            local b = Bee(closestHive, x, y); table.insert(Entities, b)
            closestHive.beeCount = closestHive.beeCount + 1
        else
            local b = Bee(nil, x, y); table.insert(Entities, b)
        end
    end,
    QueenBee = function(x, y)
        local closestHive = nil
        for _, e in ipairs(Entities) do
            if e.type == "hive" then
                if closestHive == nil then
                    closestHive = e
                else
                    if (x - e.x) * (x - e.x) + (y - e.y) * (y - e.y) < (x - closestHive.x) * (x - closestHive.x) + (y - closestHive.y) * (y - closestHive.y) then
                        closestHive = e
                    end
                end
            end
        end

        if closestHive then
            closestHive:updateHoneyProduction()
            local b = QueenBee(closestHive, x, y); table.insert(Entities, b)
            closestHive.hasQueen = true
            closestHive.QueenBee = b
        else 
            local b = QueenBee(nil, x, y); table.insert(Entities, b)
        end
    end,
    Fence = function(x, y)
        print("X: " .. x .. " Y: " .. y)
        for _, e in ipairs(Entities) do
            if e.type == "fence" then
                local snappedX, snappedY = e:snapToGrid(x, y)
                if snappedX == e.x and snappedY == e.y then
                    modal:show("", "There is already a fence here!", {
                        { label = "Continue", action = function() print("Closed") end }
                    })
                    return
                end
            end
        end
        local f = Fence(x, y); table.insert(Entities, f)
    end
}

function MainState:entityAtPosition(x, y)
    for _, e in ipairs(Entities) do
        if e.type ~= "player" then
            if e.x > x - 64 and e.x < x + 64 and e.y > y - 64 and e.y < y + 64 then
                return e
            end
        end
    end
    return nil
end

-- Called when mouse is clicked
function MainState:mousepressed(x, y, button)
    print("Mouse pressed at: " .. x .. ", " .. y)
    if button == 2 and BuildOptions[CurrentBuildMode] then  -- Right click
        BuildOptions[CurrentBuildMode](x, y)
        CurrentBuildMode = ""
        return
    end

    -- If the player is right clicking on an object...
    if button == 2 and player.itemInHand ~= nil then
        -- Get the entity at the clicked position
        local e = self:entityAtPosition(x, y)
        -- If its a hive and they're holding a harvesting bucket...
        if e and e.type == "hive" and player.itemInHand == ShopTools.bucket then
            -- Check if theres enough honey to harvest
            if e.honey >= 10 then
                -- Check if they have enough space in their inventory
                for i = 1, HUD.hotbarSize+1, 1 do
                    -- If there's an empty slot
                    if player.items[i] == nil then
                        -- Add a honey jar to their inventory
                        table.insert(player.items,
                        {
                            name = "Honey Jar",
                            image = love.graphics.newImage("sprites/honey_jar.png"),
                        })
                        e.honey = e.honey - 10
                        print("Added honey jar to inventory at position " .. i)
                        break
                    -- Else, inventory is full, display an error
                    elseif i == HUD.hotbarSize+1 then
                        modal:show("", "Your inventory is full!", {
                            { label = "Continue", action = function() print("Closed") end }
                        })
                    end
                end
            else
                -- If not enough honey, display an error
                modal:show("", "This Hive is too low on honey to harvest!", {
                    { label = "Continue", action = function() print("Closed") end }
                })
            end
        elseif e and e.type == "Chest" then
            -- If the chest is open and the player is holding a honey jar...
            if e.opening then
                if player.itemInHand.name == "Honey Jar" then
                    -- Remove the honey jar from the player's inventory
                    table.remove(player.items, InventoryPosition)
                    -- Set the player's current item to nil
                    player.itemInHand = nil
                    -- Give the player money
                    PlayerMoney = PlayerMoney + 500
                else
                    -- If not holding a honey jar, display an error
                    modal:show("You aren't holding a honey jar!", "Use the number keys to select a honey jar in your inventory!", {
                        { label = "Continue", action = function() print("Closed") end }
                    })
                end
            end
        elseif e and e.type == "hive" and CurrentBuildMode == "WireMesh" then
            CurrentBuildMode = ""
            e.maxHealth = e.maxHealth * 1.5
            e.health = e.maxHealth
        end
    end

    if button == 1 then
        player:attack()
    end
end

-- Called every frame to draw the screen
function MainState:draw()
    -- Set background and drawing color
    love.graphics.setBackgroundColor(1, 1, 1, 1)
    love.graphics.setColor(1, 1, 1, 1)

    -- Draw the tile map
    Map:draw(0, 0, 2, 2)

    -- THIS NEEDS ORDERED LIKE THIS FOR Z-DEPTH
    -- Draw hives on bottom layer
    for _, e in ipairs(Entities) do
        if e.type == "hive" or e.type == "fence" or e.type == "Chest" then
            e:draw()
        end
    end
    -- Draw player underneath entities
    player:draw()
    -- Draw entities on top of hives
    for _, e in ipairs(Entities) do
        if e.type ~= "hive" and e.type ~= "player" and e.type ~= "fence" and e.type ~= "Chest" then
            e:draw()
        end
    end

    -- Apply tint and draw HUD
    DayCycle:ApplyBGTint()
    HUD:draw()
    DialogManager:draw()
end

-- Return the state
return MainState
