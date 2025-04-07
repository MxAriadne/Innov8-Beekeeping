local MainState = {}

--libraries import from libraries folder
Object = require("classic")
local sti = require 'libraries/sti'
local wf = require 'libraries/windfield'
local HUD = require "UI/HUD"
local Dialove = require("libraries/Dialove.dialove")
local DayCycle = require("dayCycleScript")
local Beehive = require("libraries/beehive")
local Jumper = require("libraries/jumper")
local dialogs = require("dialogs")
local Player = require "entities.player"

function MainState:enter()
    --base size for the game right now
    --will put everything into variables later so it can be more easily resized
    Map = sti('maps/TilesForBeekeepingGameTopBoundaries.lua')
    love.window.setMode(960, 640)

    World = wf.newWorld()

    --defining collision classes
    World:addCollisionClass('Player')
    World:addCollisionClass('Wall')
    World:addCollisionClass('PlayerAttack')
    World:addCollisionClass('Enemy')
    World:addCollisionClass('Hive')


    --table for flowers
    Flowers = {flower}

    Music = love.audio.newSource("tunes/Flowers.mp3", "stream")
    Music:setVolume(0.3)
    Music:setLooping(true)  --music loop
    Music:play()  --playing the music

    --dialog library initilization
    DialogManager = Dialove.init({
        font = love.graphics.newFont('libraries/fonts/comic-neue/ComicNeue-Bold.ttf', 16)
    })

    --setup tutorial dialogue at beginning of game.
    if FirstRun then
        DialogManager:show(dialogs.startupM);
    end

    -- Load HUD overlay
    HUD:load()

    --player instance and global reference
    self.player = Player()
    player = self.player

    --player collider configuration
    self.player.collider = World:newBSGRectangleCollider(480, 340, 20, 20, 14)
    self.player.collider:setFixedRotation(true)
    self.player.collider:setObject(self.player)
    self.player.collider:setCollisionClass('Player')

    --auto-getting and making the colliders from the objects created in Tiled
    walls = {}
    if Map.layers["Walls"] then
        for i, obj in pairs(Map.layers["Walls"].objects) do
            local wall = World:newRectangleCollider(obj.x*2, obj.y*2, obj.width*2, obj.height*2)
            wall:setType('static')
            wall:setCollisionClass('Wall')
            table.insert(walls, wall)
        end
    end

    --initializing entity tables if they don't exist
    if not hives then hives = {} end
    if not bees then bees = {} end
    if not Flowers then Flowers = {} end

    --creating the entities instance variables for initial game state
    self.hive = Hive()
    self.bee = Bee()
    self.flower = Flower()
    self.honeybadger = HoneyBadger()
    self.wasp = Wasp()

    --making the hive collider using values in hive.lua instead of hardcoding
    local wall = World:newRectangleCollider(self.hive.x - self.hive.width/2, self.hive.y - self.hive.height/2, self.hive.width, self.hive.height)
    wall:setType('static')
    wall:setCollisionClass('Hive')

    --assigning the instances to global variables for accessibility
    hive = self.hive
    bee = self.bee
    flower = self.flower
    honeybadger = self.honeybadger
    wasp = self.wasp

    --adding the initial entities to their arrays
    table.insert(hives, self.hive)
    table.insert(bees, self.bee)
    table.insert(Flowers, self.flower)
end

function MainState:update(dt)
    DialogManager:update(dt) -- update dia system
    World:update(dt) --player movement with colliders

    --update player
    if self.player then
        self.player:update(dt)

        if love.mouse.isDown(1) then  --left click to attack
            self.player:attack()

        end
    end

    --update enemy entities
    if self.wasp then self.wasp:update(dt) end
    if self.honeybadger then self.honeybadger:update(dt) end

    --update all hives, bees, and flowers
    for _, h in ipairs(hives) do
        h:update(dt)
    end

    for _, f in ipairs(Flowers) do
        if f.update then
            f:update(dt)
        end
    end

    for _, b in ipairs(bees) do
        b:update(dt)
    end

    if love.keyboard.isDown("escape") then
        Music:stop()
        GameStateManager:revertState()
    end

    --updating the entities (making them move) IF they exist
    if self.wasp then self.wasp:update(dt) end
    if self.bee then self.bee:update(dt) end
    if self.honeybadger then self.honeybadger:update(dt) end

end

function MainState:keypressed(k)
    -- Handle spacebar for day cycle
    if k == "space" then
        AdvanceDay()  -- Call the trigger updates function from dayCycleScript.lua
        if TintEnabled == false then --tintEnabled
            NightSky()
            TintEnabled = true
        else
            DaySky()
            TintEnabled = false
        end
    -- Handle dialog flow controls
    elseif k == 'return' then
    -- exit dialogue box
        DialogManager:pop()
        --dialogManager.queue = {} -- Force empty
    elseif k == 'c' then
        DialogManager:complete()
    -- elseif k == 'f' then
    --     dialogManager:faster()
    elseif k == 'b' then
        DialogManager:changeOption(1)
    elseif k == 'n' then
        DialogManager:changeOption(-1) -- previous one
        --pathfinding debug toggle
    --f key to build hive
    elseif k == "f" then
        if PlayerMoney >= HiveCost then
            PlayerMoney = PlayerMoney - HiveCost
            CurrentBuildMode = "hive"
            print("You purchased a hive blueprint. Right-click to place!")
        else
            print("Not enough money for a hive!")
        end

    --g key to build bee
    elseif k == "g" then
        if PlayerMoney >= BeeCost then
            PlayerMoney = PlayerMoney - BeeCost
            CurrentBuildMode = "bee"
            print("You purchased a bee. Right-click to place!")
        else
            print("Not enough money for a bee!")
        end
    --g key to build bee
    elseif k == "q" then
        if PlayerMoney >= QueenBeeCost then
            PlayerMoney = PlayerMoney - QueenBeeCost
            CurrentBuildMode = "queenbee"
            print("You purchased a queen bee. Right-click to place!")
        else
            print("Not enough money for a queen bee!")
        end
    --h key to build flower
    elseif k == "h" then
        if PlayerMoney >= FlowerCost then
            PlayerMoney = PlayerMoney - FlowerCost
            CurrentBuildMode = "flower"
            print("You purchased a flower seed. Right-click to plant!")
        else
            print("Not enough money for a flower!")
        end

    elseif (k == "e") then
        PlayerMoney = PlayerMoney + 5
        print(PlayerMoney)

    elseif (k == "`") then
        --toggle debug mode
        DebugMode = not DebugMode
        print("Debug mode: " .. (DebugMode and "ON" or "OFF"))

    -- Press "tab" to open shop screen
    elseif (k == "tab") then
        GameStateManager:setState(shopScreen)
    end
end

function MainState:keyreleased(k)
    print("State Key released:", k)

    player:keyreleased(k)
    -- Handle spacebar to adjust dialog speed
    if k == 's' then
        DialogManager:slower()
    end
end

-- build mode, right click
function MainState:mousepressed(x, y, button)
    if button == 2 then
        if CurrentBuildMode == "hive" then
            local newHive = Hive()
            newHive.x, newHive.y = x, y
            table.insert(hives, newHive)
            hive = newHive
            print("Placed a new hive at (" .. x .. ", " .. y .. ")")
        elseif CurrentBuildMode == "bee" then
            local newBee = Bee()
            newBee.x, newBee.y = x, y
            table.insert(bees, newBee)
            bee = newBee
            print("Placed a new bee at (" .. x .. ", " .. y .. ")")
        elseif CurrentBuildMode == "flower" then
            local newFlower = Flower()
            newFlower.x, newFlower.y = x, y
            table.insert(Flowers, newFlower)
            flower = newFlower
            print("Placed a new flower at (" .. x .. ", " .. y .. ")")
        elseif CurrentBuildMode == "queenbee" then
            local newQueenBee = QueenBee()
            newQueenBee.x = x
            newQueenBee.y = y
            table.insert(bees, newQueenBee)

            queenBee = newQueenBee

            if hive then
                  hive:updateHoneyProduction()
                  hive.beeCount = hive.beeCount + 1
            end

            print("placed a new queen bee at (" .. x .. "," .. y .. ")")
            CurrentBuildMode = nil
        end
        CurrentBuildMode = nil
    end
end

function MainState:draw()
    love.graphics.setBackgroundColor(1, 1, 1, 1)
    love.graphics.setColor(1, 1, 1, 1)

    Map:draw(0, 0, 2, 2)

    --drawing the entities if they exist
    --draw all hives, bees, and flowers
    for _, h in ipairs(hives) do
        h:draw()
    end

    for _, b in ipairs(bees) do
        b:draw()
    end

    for _, f in ipairs(Flowers) do
        f:draw()
    end

    --drawing the special entities
    if self.wasp then self.wasp:draw() end
    if self.honeybadger then self.honeybadger:draw() end

    --draw player
    if self.player then self.player:draw() end

    -- Draw HUD overlay
    ApplyBGTint()
    HUD:draw()
    DialogManager:draw()
end

return MainState
