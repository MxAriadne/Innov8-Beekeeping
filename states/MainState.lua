local MainState = {}

--libraries import from libraries folder
local sti = require 'libraries/sti'
local wf = require 'libraries/windfield'
local HUD = require "UI/HUD"
local Dialove = require("libraries/Dialove.dialove")
local DayCycle = require("dayCycleScript")
local Beehive = require("libraries/beehive")
local Jumper = require("libraries/jumper")

-- global variables
tintEnabled = false
debugMode = false

GameConfig = {}

function MainState:enter()
    Object = require "classic"
    require "bee"
    require "flower"
    require "hive"
    require "wasp"
    require "honeybadger"

    --table for flowers
    flowers = {flower}

    music = love.audio.newSource("tunes/Flowers.mp3", "stream")
    music:setLooping(true)  --music loop
    music:play()  --playing the music

    dialogManager = Dialove.init({
        font = love.graphics.newFont('libraries/fonts/comic-neue/ComicNeue-Bold.ttf', 16)
    })


    --base size for the game right now
    --will put everything into variables later so it can be more easily resized
    money = 0
    hive = love.graphics.newImage('sprites/hive.png')
    map = sti('maps/TilesForBeekeepingGameTopBoundaries.lua')
    love.window.setMode(960, 640)

    world = wf.newWorld()

    -- Load HUD overlay
    HUD:load()

    --player creation and collider configuation
    player = {}
    player.collider = world:newBSGRectangleCollider(480, 340, 20, 20, 14)
    player.collider:setFixedRotation(true)
    player.x = 480
    player.y = 320
    player.speed = 300

    --auto-getting and making the colliders from the objects created in Tiled
    walls = {}
    if map.layers["Walls"] then
        for i, obj in pairs(map.layers["Walls"].objects) do
            local wall = world:newRectangleCollider(obj.x*2, obj.y*2, obj.width*2, obj.height*2)
            wall:setType('static')
            table.insert(walls, wall)
        end
    end

    --collider for the beehive itself
    local wall = world:newRectangleCollider(80, 225, 120, 135 )
    wall:setType('static')

end

-- helper functions from Poultry Profits
function checkCollision(a, b)
    return a.x < b.x + (b.width or b.size) and
           a.x + (a.width or a.size) > b.x and
           a.y < b.y + (b.height or b.size) and
           a.y + (a.height or a.size) > b.y
end

function isInPickupRange(a, b)
    local aCenterX = a.x + (a.width or a.size) / 2
    local aCenterY = a.y + (a.height or a.size) / 2
    local bCenterX = b.x + (b.width or b.size) / 2
    local bCenterY = b.y + (b.height or b.size) / 2
    local distance = math.sqrt((aCenterX - bCenterX)^2 + (aCenterY - bCenterY)^2)
    local range = 50  -- Adjusted pickup range
    return distance <= range
end

function MainState:update(dt)

    dialogManager:update(dt) -- update dia system

    --player movement with colliders
    world:update(dt)
    player.x = player.collider:getX()
    player.y = player.collider:getY()

    local vx = 0
    local vy = 0
    if love.keyboard.isDown("right", 'd') then
        vx = player.speed
    end

    if love.keyboard.isDown("left", 'a') then
        vx = player.speed * -1
    end

    if love.keyboard.isDown("up", 'w') then
        vy = player.speed * -1
    end

    if love.keyboard.isDown("down", 's') then
        vy = player.speed
    end

    if love.keyboard.isDown("escape") then
        music:stop()
        GameStateManager:revertState()
    end

    player.collider:setLinearVelocity(vx, vy)
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
    elseif k == 'f' then
        dialogManager:faster()
    elseif k == 'b' then
        dialogManager:changeOption(1)  -- next one
    elseif k == 'n' then
        dialogManager:changeOption(-1) -- previous one
    end
end

function love.keyreleased(k)
    -- Handle spacebar to adjust dialog speed
    if k == 's' then
        dialogManager:slower()
    end
end

--still making this
function MainState:keypressed(key)
   if (key == "e") then
      money = money + 5
      print(money)
   end
end

function MainState:draw()
    love.graphics.setBackgroundColor(1, 1, 1, 1)
    love.graphics.setColor(1, 1, 1, 1)

    map:draw(0, 0, 2, 2)
    love.graphics.draw(hive, 200, 225, 0, -1, 1)

    world:draw()--makes the colliders visible, for debugging - comment out later
    love.graphics.circle("line", player.x, player.y, 20)
    --hiveTagColor = {.3, 0, 0, 1}
    --love.graphics.print({hiveTagColor, "Beehive: Level 1"}, 70, 195, 0, 1.5, 1.5)

    -- Draw HUD overlay
    HUD:draw()
    dialogManager:draw()
    ApplyBGTint()
end

return MainState
