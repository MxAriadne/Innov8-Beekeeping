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
local game_Data = require "game_data"
local DayCycle = require("dayCycleScript")

-- Initial setup
function MainState:enter()

    -- Load the tilemap
    Map = sti('maps/TilesForBeekeepingGameTopBoundaries.lua')

    -- Initialize dialog system
    DialogManager = Dialove.init({
        font = love.graphics.newFont('libraries/fonts/comic-neue/ComicNeue-Bold.ttf', 16)
    })

    -- Initialize everything if this is the first time opening the state.
    -- This stops everything from doubling when reverting state from menus.
    if FirstRun then
        -- Ensure entity table exist before inserting
        if not Entities then Entities = {} end

        -- Assign instances to globals for other modules to access
        hive = Hive()
        flower = Flower(500, 500)
        honeybadger = HoneyBadger()
        wasp = Wasp(600, 600)
        player = Player()
        bee = Bee(hive, 275, 300)

        World = wf.newWorld()
        -- Define collision categories
        World:addCollisionClass('Player')
        World:addCollisionClass('Wall')
        World:addCollisionClass('PlayerAttack')
        World:addCollisionClass('Enemy')
        World:addCollisionClass('Hive')

        -- Create a collider for the first hive
        local wall = World:newRectangleCollider(
            hive.x - hive.width/2,
            hive.y - hive.height/2,
            hive.width,
            hive.height
        )

        wall:setType('static')
        wall:setCollisionClass('Hive')

        hive.collider = wall

        -- Start tutorial dialog
        DialogManager:show(dialogs.startupM)

        -- Init honey total
        TotalHoney = 0

        -- Add created entities to their respective tables
        table.insert(Entities, hive)
        table.insert(Entities, bee)
        table.insert(Entities, flower)
        table.insert(Entities, wasp)
        table.insert(Entities, player)
        table.insert(Entities, honeybadger)
    else
    end

    -- Load HUD
    HUD:load()

    -- Set up player collider
    player.collider = World:newBSGRectangleCollider(480, 340, 20, 20, 14)
    player.collider:setFixedRotation(true)
    player.collider:setObject(player)
    player.collider:setCollisionClass('Player')

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

function round(num, numDecimalPlaces)
  return tonumber(string.format("%." .. (numDecimalPlaces or 0) .. "f", num))
end

function MainState:update(dt)
    DialogManager:update(dt)
    World:update(dt)

    -- Update all entities
    for _, e in ipairs(Entities) do
        e:update(dt)

        if e.type == "hive" and e.honey > 0 then
            TotalHoney = round(TotalHoney + e.honey, 2)
            PlayerMoney = round(PlayerMoney + e.honey, 2)
            e.honey = 0
        end

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
        -- Toggle day/night
        DayCycle:AdvanceDay()
        if not TintEnabled then
            DayCycle:NightSky()
            TintEnabled = true
        else
            DayCycle:DaySky()
            TintEnabled = false
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
    elseif k == "e" then
        -- Debug money cheat
        PlayerMoney = PlayerMoney + 5
        print(PlayerMoney)
    elseif k == "`" then
        -- Toggle debug mode
        DebugMode = not DebugMode
        print("Debug mode: " .. (DebugMode and "ON" or "OFF"))
    elseif k == "tab" then
        -- Open shop screen
        GameStateManager:setState(ShopScreen)
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
            h.height
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
            h.height
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
            h.height
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
    end
}

-- Called when mouse is clicked
function MainState:mousepressed(x, y, button)
    if button == 2 and BuildOptions[CurrentBuildMode] then  -- Right click
        BuildOptions[CurrentBuildMode](x, y)
        CurrentBuildMode = ""
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
        if e.type == "hive" or e.type ~= "player" then
            e:draw()
        end
    end
    -- Draw player underneath entities
    player:draw()
    -- Draw entities on top of hives
    for _, e in ipairs(Entities) do
        if e.type ~= "hive" and e.type ~= "player" then
            e:draw()
        end
    end

    -- Apply tint and draw HUD
    DayCycle:ApplyBGTint()
    HUD:draw()
    DialogManager:draw()
end

-- Functions to activate enemies via triggers
function TrigB()
    BadgerGo = true
end

function TrigW()
    WaspGo = true
end

-- Return the state
return MainState
