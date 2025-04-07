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
local shopScreen = require "states/shopScreen"
local MainMenu = require "states/MainMenu"
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

    -- Create instances of main entities
    self.hive = Hive()
    self.bee = Bee()
    self.flower = Flower()
    self.honeybadger = HoneyBadger()
    self.wasp = Wasp()

    -- Assign instances to globals for other modules to access
    hive = self.hive
    bee = self.bee
    flower = self.flower
    honeybadger = self.honeybadger
    wasp = self.wasp

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

        -- Load and play background music
        Music:setVolume(0.3)
        Music:setLooping(true)
        Music:play()

        -- Start tutorial dialog
        DialogManager:show(dialogs.startupM)

        -- Add created entities to their respective tables
        table.insert(Hives, self.hive)
        table.insert(Bees, self.bee)
        table.insert(Flowers, self.flower)
    else
        Music:stop()
        Music:setVolume(0.3)
        Music:setLooping(true)
        Music:play()
    end

    -- Load HUD
    HUD:load()

    -- Create a player instance and make it global
    self.player = Player()
    player = self.player

    -- Set up player collider
    self.player.collider = World:newBSGRectangleCollider(480, 340, 20, 20, 14)
    self.player.collider:setFixedRotation(true)
    self.player.collider:setObject(self.player)
    self.player.collider:setCollisionClass('Player')

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

    -- Create a collider for the hive
    local wall = World:newRectangleCollider(
        self.hive.x - self.hive.width/2,
        self.hive.y - self.hive.height/2,
        self.hive.width,
        self.hive.height
    )

    wall:setType('static')
    wall:setCollisionClass('Hive')
end

function MainState:update(dt)
    DialogManager:update(dt)
    World:update(dt)

    if self.player then
        self.player:update(dt)

        -- Left-click to attack
        if love.mouse.isDown(1) then
            self.player:attack()
        end
    end

    -- Update enemies if they exist
    if self.wasp then self.wasp:update(dt) end
    if self.honeybadger then self.honeybadger:update(dt) end

    -- Update all hives
    for _, h in ipairs(Hives) do
        h:update(dt)
    end

    -- Update all flowers
    for _, f in ipairs(Flowers) do
        if f.update then
            f:update(dt)
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

    -- Re-update enemies (this appears to be a redundant block)
    if self.wasp then self.wasp:update(dt) end
    if self.bee then self.bee:update(dt) end
    if self.honeybadger then self.honeybadger:update(dt) end
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
        local h = Hive(); h.x = x; h.y = y; table.insert(Hives, h)
    end,
    LogHive = function(x, y)
        local h = Hive(); h.x = x; h.y = y; table.insert(Hives, h)
    end,
    TopBarHive = function(x, y)
        local h = Hive(); h.x = x; h.y = y; table.insert(Hives, h)
    end,
    Orchid = function(x, y)
        local f = Flower(); f.x = x; f.y = y; table.insert(Flowers, f)
    end,
    Bee = function(x, y)
        local b = Bee(); b.x = x; b.y = y; table.insert(Bees, b)
    end,
    QueenBee = function(x, y)
        local b = QueenBee(); b.x = x; b.y = y; table.insert(Bees, b)
        if hive then
             hive:updateHoneyProduction()
             hive.beeCount = hive.beeCount + 1
        end
    end
}

-- Called when mouse is clicked
function MainState:mousepressed(x, y, button)
    if button == 2 and BuildOptions[CurrentBuildMode] then  -- Right click
        BuildOptions[CurrentBuildMode](x, y)
        CurrentBuildMode = nil
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
    if self.wasp then self.wasp:draw() end
    if self.honeybadger then self.honeybadger:draw() end

    -- Draw the player
    if self.player then self.player:draw() end

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
