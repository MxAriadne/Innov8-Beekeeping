local MainState = {}

--libraries import from libraries folder
local sti = require 'libraries/sti'
local wf = require 'libraries/windfield'
local HUD = require "UI/HUD"
local Player = require "player"

function MainState:enter()
    --base size for the game right now
    --will put everything into variables later so it can be more easily resized
    money = 0
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
    world:update(dt)
    
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
    
    for _, b in ipairs(bees) do
        b:update(dt)
    end
    
    for _, f in ipairs(flowers) do
        if f.update then
            f:update(dt)
        end
    end
    
    if love.keyboard.isDown("escape") then
        GameStateManager:revertState()
    end
end

--still making this
function MainState:keypressed(key)
   if (key == "e") then
      playerMoney = playerMoney + 5
      print(playerMoney)
   elseif (key == "`") then
      --toggle debug mode
      debugMode = not debugMode
   end
end

function MainState:draw()
    love.graphics.setBackgroundColor(1, 1, 1, 1)
    love.graphics.setColor(1, 1, 1, 1)

    map:draw(0, 0, 2, 2)
    
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

    if debugMode then
        world:draw()  --draw colliders in debug mode
    end

    -- Draw HUD overlay
    HUD:draw()
end

return MainState
