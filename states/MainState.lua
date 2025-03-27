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
local Player = require "player"

-- global variables
tintEnabled = false
debugMode = false

GameConfig = {}

function MainState:enter()
    Object = require "classic"

    --table for flowers
    flowers = {flower}

    music = love.audio.newSource("tunes/Flowers.mp3", "stream")
    music:setVolume(0.3)
    music:setLooping(true)  --music loop
    music:play()  --playing the music

    --dialog library initilization
    dialogManager = Dialove.init({
        font = love.graphics.newFont('libraries/fonts/comic-neue/ComicNeue-Bold.ttf', 16)
    })

    --setup tutorial dialogue at beginning of game.
    dialogManager:show(dialogs.startupM);

    --base size for the game right now
    --will put everything into variables later so it can be more easily resized
    money = 0
    --hive = love.graphics.newImage('sprites/hive.png')
    map = sti('maps/TilesForBeekeepingGameTopBoundaries.lua')
    love.window.setMode(960, 640)

    world = wf.newWorld()

    --defining collision classes
    world:addCollisionClass('Player')
    world:addCollisionClass('Wall')
    world:addCollisionClass('PlayerAttack')
    world:addCollisionClass('Enemy')
    world:addCollisionClass('Hive')

    -- Load HUD overlay
    HUD:load()

    --player instance and global reference
    self.player = Player()
    player = self.player

    --player collider configuration
    self.player.collider = world:newBSGRectangleCollider(480, 340, 20, 20, 14)
    self.player.collider:setFixedRotation(true)
    self.player.collider:setObject(self.player)
    self.player.collider:setCollisionClass('Player')

    --auto-getting and making the colliders from the objects created in Tiled
    walls = {}
    if map.layers["Walls"] then
        for i, obj in pairs(map.layers["Walls"].objects) do
            local wall = world:newRectangleCollider(obj.x*2, obj.y*2, obj.width*2, obj.height*2)
            wall:setType('static')
            wall:setCollisionClass('Wall')
            table.insert(walls, wall)
        end
    end

    --initializing entity tables if they don't exist
    if not hives then hives = {} end
    if not bees then bees = {} end
    if not flowers then flowers = {} end

    --creating the entities instance variables for initial game state
    self.hive = Hive()
    self.bee = Bee()
    self.flower = Flower()
    self.honeybadger = HoneyBadger()
    self.wasp = Wasp()

    --making the hive collider using values in hive.lua instead of hardcoding
    local wall = world:newRectangleCollider(self.hive.x - self.hive.width/2, self.hive.y - self.hive.height/2, self.hive.width, self.hive.height)
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
    table.insert(flowers, self.flower)
end

function MainState:update(dt)
    dialogManager:update(dt) -- update dia system
    world:update(dt) --player movement with colliders

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

    for _, f in ipairs(flowers) do
        if f.update then
            f:update(dt)
        end
    end

    for _, b in ipairs(bees) do
        b:update(dt)
    end

    if love.keyboard.isDown("escape") then
        music:stop()
        GameStateManager:revertState()
    end

    --updating the entities (making them move) IF they exist
    if self.wasp then self.wasp:update(dt) end
    if self.bee then self.bee:update(dt) end
    if self.honeybadger then self.honeybadger:update(dt) end

end

function love.keypressed(k)
    -- Handle spacebar for day cycle
    if k == "space" then
        AdvanceDay()  -- Call the trigger updates function from dayCycleScript.lua
        if tintEnabled == false then --tintEnabled
            NightSky()
            tintEnabled = true
        else
            DaySky()
            tintEnabled = false
        end
    -- Handle dialog flow controls
    elseif k == 'return' then
    -- exit dialogue box
        dialogManager:pop()
        --dialogManager.queue = {} -- Force empty
    elseif k == 'c' then
        dialogManager:complete()
    -- elseif k == 'f' then
    --     dialogManager:faster()
    elseif k == 'b' then
        dialogManager:changeOption(1)
    elseif k == 'n' then
        dialogManager:changeOption(-1) -- previous one
        --pathfinding debug toggle
    --f key to build hive
    elseif k == "f" then
        if playerMoney >= hiveCost then
            playerMoney = playerMoney - hiveCost
            currentBuildMode = "hive"
            print("You purchased a hive blueprint. Right-click to place!")
        else
            print("Not enough money for a hive!")
        end

    --g key to build bee
    elseif k == "g" then
        if playerMoney >= beeCost then
            playerMoney = playerMoney - beeCost
            currentBuildMode = "bee"
            print("You purchased a bee. Right-click to place!")
        else
            print("Not enough money for a bee!")
        end
    --h key to build flower
    elseif k == "h" then
        if playerMoney >= flowerCost then
            playerMoney = playerMoney - flowerCost
            currentBuildMode = "flower"
            print("You purchased a flower seed. Right-click to plant!")
        else
            print("Not enough money for a flower!")
        end

    elseif (key == "e") then
        playerMoney = playerMoney + 5
        print(playerMoney)

    elseif (key == "`") then
        --toggle debug mode
        debugMode = not debugMode
    end
end

function love.keyreleased(k)
    -- Handle spacebar to adjust dialog speed
    if k == 's' then
        dialogManager:slower()
    end
end

-- build mode, right click
function love.mousepressed(x, y, button)
    if button == 2 then
        if currentBuildMode == "hive" then
            local newHive = Hive()
            newHive.x, newHive.y = x, y
            table.insert(hives, newHive)
            hive = newHive
            print("Placed a new hive at (" .. x .. ", " .. y .. ")")
        elseif currentBuildMode == "bee" then
            local newBee = Bee()
            newBee.x, newBee.y = x, y
            table.insert(bees, newBee)
            bee = newBee
            print("Placed a new bee at (" .. x .. ", " .. y .. ")")
        elseif currentBuildMode == "flower" then
            local newFlower = Flower()
            newFlower.x, newFlower.y = x, y
            table.insert(flowers, newFlower)
            flower = newFlower
            print("Placed a new flower at (" .. x .. ", " .. y .. ")")
        end
        currentBuildMode = nil
    end
end

function MainState:draw()
    love.graphics.setBackgroundColor(1, 1, 1, 1)
    love.graphics.setColor(1, 1, 1, 1)

    map:draw(0, 0, 2, 2)

    --drawing the entities if they exist
    --draw all hives, bees, and flowers
    for _, h in ipairs(hives) do
        h:draw()
    end

    for _, b in ipairs(bees) do
        b:draw()
    end

    for _, f in ipairs(flowers) do
        f:draw()
    end

    --drawing the special entities
    if self.wasp then self.wasp:draw() end
    if self.honeybadger then self.honeybadger:draw() end

    --draw player
    if self.player then self.player:draw() end



    -- Draw HUD overlay
    HUD:draw()
    dialogManager:draw()
    ApplyBGTint()
end

return MainState
