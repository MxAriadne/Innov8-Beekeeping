-- Create the MainState table to act as the game state object
local MainState = {}

-- Importing external libraries and modules used in the game
Object = require("libraries.classic")
local sti = require 'libraries/sti'
local wf = require 'libraries/windfield'
local HUD = require "UI/HUD"
local Dialove = require("libraries/Dialove.dialove")
local DayCycle = require("dayCycleScript")
local Beehive = require("libraries/beehive")
local Jumper = require("libraries/jumper")
local dialogs = require("dialogs")
local Player = require "entities.player"
local SaveManager = require "save_manager"
local game_Data = require "game_data"

-- Initial setup
function MainState:enter()

    -- Load the tilemap
    Map = sti('maps/TilesForBeekeepingGameTopBoundaries.lua')

    -- Set game window resolution
    love.window.setMode(960, 640)

    -- Load music
    Music = love.audio.newSource("tunes/Flowers.mp3", "stream")

    -- Initialize dialog system
    DialogManager = Dialove.init({
        font = love.graphics.newFont('libraries/fonts/comic-neue/ComicNeue-Bold.ttf', 16)
    })

    -- Assign instances to globals for other modules to access
    hive = Hive()
    bee = Bee(hive, 275, 300)
    flower = Flower()
    honeybadger = HoneyBadger()
    wasp = Wasp()
    player = Player()

    -- Ensure entity tables exist before inserting
    if not Hives then Hives = {} end
    if not Bees then Bees = {} end
    if not Flowers then Flowers = {} end

    -- Initialize everything if this is the first time opening the state.
    -- This stops everything from doubling when reverting state from menus.
    if FirstRun then
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

        -- Load and play background music
        Music:setVolume(0.3)
        Music:setLooping(true)
        Music:play()

        -- Start tutorial dialog
        DialogManager:show(dialogs.startupM)

        -- Init honey total
        TotalHoney = 0

        -- Add created entities to their respective tables
        table.insert(Hives, hive)
        table.insert(Bees, bee)
        table.insert(Flowers, flower)
    else
        Music:stop()
        Music:setVolume(0.3)
        Music:setLooping(true)
        Music:play()
    end

    -- Load HUD
    HUD:load()

    -- Set up player collider
    player.collider = World:newBSGRectangleCollider(480, 340, 20, 20, 14)
    player.collider:setFixedRotation(true)
    player.collider:setObject(player)
    player.collider:setCollisionClass('Player')

    -- Create colliders for each wall tile
    walls = {}
    if Map.layers["Walls"] then
        for i, obj in pairs(Map.layers["Walls"].objects) do
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

    -- Update player if init worked
    if player then player:update(dt) end

    -- Update all hives
    local sum = 0
    for _, h in ipairs(Hives) do
        h:update(dt)
        if not h.visible then
            h = nil
        end
    end

    -- Update all flowers
    for _, f in ipairs(Flowers) do
        if f.update then
            f:update(dt)
        end

        if not f.visible then
            f = nil
        end

    end

    -- Update all bees
    for _, b in ipairs(Bees) do
        b:update(dt)
    end

    -- Press escape to save and quit
    if love.keyboard.isDown("escape") then
        Music:stop()
        SaveManager.save(game_Data.gameData)
        GameStateManager:setState(MainMenu)
    end

    --converts honey to money
    for _, h in ipairs(Hives) do
        if h.honey > 0 then
            TotalHoney = round(TotalHoney + h.honey, 2)
            PlayerMoney = round(PlayerMoney + h.honey, 2)
            h.honey = 0
        end
    end
end

-- Called when a key is pressed
function MainState:keypressed(k)
    if k == "space" then
        -- Toggle day/night
        AdvanceDay()
        if not TintEnabled then
            NightSky()
            TintEnabled = true
        else
            DaySky()
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
        Music:stop()
        -- Open shop screen
        GameStateManager:setState(shopScreen)
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

        table.insert(Hives, h)
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

        table.insert(Hives, h)
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

        table.insert(Hives, h)
    end,
    Orchid = function(x, y)
        local f = Flower(); f.x = x; f.y = y; table.insert(Flowers, f)
    end,
    GoldenDewdrops = function(x, y)
        local f = GoldenDewdrops(); f.x = x; f.y = y; table.insert(Flowers, f)
    end,
    CommonLantana = function(x, y)
        local f = CommonLantana(); f.x = x; f.y = y; table.insert(Flowers, f)
    end,
    Bee = function(x, y)
        local closestHive = nil
        for _, hive in pairs(Hives) do
            if closestHive == nil then
                closestHive = hive
            else
                if (x - hive.x) * (x - hive.x) + (y - hive.y) * (y - hive.y) < (x - closestHive.x) * (x - closestHive.x) + (y - closestHive.y) * (y - closestHive.y) then
                    closestHive = hive
                end
            end
        end

        if closestHive then
             closestHive:updateHoneyProduction()
             local b = Bee(closestHive, x, y); table.insert(Bees, b)
             closestHive.beeCount = closestHive.beeCount + 1
        end
    end,
    QueenBee = function(x, y)
        local closestHive = nil
        for _, hive in pairs(Hives) do
            if closestHive == nil then
                closestHive = hive
            else
                if (x - hive.x) * (x - hive.x) + (y - hive.y) * (y - hive.y) < (x - closestHive.x) * (x - closestHive.x) + (y - closestHive.y) * (y - closestHive.y) then
                    closestHive = hive
                end
            end
        end

        if closestHive then
             closestHive:updateHoneyProduction()
             local b = QueenBee(closestHive, x, y); table.insert(Bees, b)
             closestHive.beeCount = closestHive.beeCount + 1
        end
    end
}

-- Called when mouse is clicked
function MainState:mousepressed(x, y, button)
    if button == 2 and BuildOptions[CurrentBuildMode] then  -- Right click
        BuildOptions[CurrentBuildMode](x, y)
        CurrentBuildMode = nil
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

    -- Draw hives
    for _, h in ipairs(Hives) do
        h:draw()
    end

    -- Draw bees
    for _, b in ipairs(Bees) do
        b:draw()
    end

    -- Draw flowers
    for _, f in ipairs(Flowers) do
        f:draw()
    end

    -- Draw enemies if they exist
    if wasp then wasp:draw() end
    if honeybadger then honeybadger:draw() end

    -- Draw the player
    if player then player:draw() end

    -- Apply tint and draw HUD
    ApplyBGTint()
    HUD:draw()
    DialogManager:draw()
end

-- Functions to activate enemies via triggers
function TrigB()
    badgerGo = true
end

function TrigW()
    waspGo = true
end

-- Return the state
return MainState
