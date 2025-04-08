-- This file contains all shop items available for purchase in game
-- Author: Amelia Reiss

-- Tools
local tools = { 
    honeyDipper = {name = "Honey Brush",
                    image = love.graphics.newImage("sprites/honey_brush.png"),
                    price = 100,
                    description = "Used to gently extract honey from hives.\nCollect more honey.",
                    extra = ""
                    },
    basicSword = {name = "Basic Sword",
                    image = love.graphics.newImage("sprites/basic_sword.png"),
                    price = 100,
                    description = "Do more damage.",
                    extra = ""
                    },
}

-- Hives
local hives = {
    log = {name = "Log Hive",
            image = love.graphics.newImage("sprites/log_hive.png"),
            price = 50,
            description = "Cheap and simple, offers decent protection from pests.",
            extra = ""
            },
    topBar = {name = "Top Bar Hive",
                image = love.graphics.newImage("sprites/top_bar_hive.png"),
                price = 100,
                description = "Sturdier than the Log Hive, but yields less honey.",
                extra = ""
                },
    langstroth = {name = "Langstroth Hive",
                    image = love.graphics.newImage("sprites/langstroth_hive.png"),
                    price = 500,
                    description = "Well-protected and produces a lot of honey.",
                    extra = ""
                    },
}

-- Flowers
local flowers = {
    CommonLantana = {name = "Common Lantana",
                image = love.graphics.newImage("sprites/lantana.png"),
                price = 60,
                description = "Boosts honey production substantially in numbers!",
                extra = "The Common Lantana is a flowering plant common in Kenya, and every part of it is poisonous so be careful!"
                .. "\nDespite this, its famous for its unique coloring that attracts pollinators like no other!"
                },
    GoldenDewdrops = {name = "Golden Dewdrops",
                image = love.graphics.newImage("sprites/golden_dewdrops.png"),
                price = 30,
                description = "A common shrub with bright flowers! Attracts more bees because of its vibrancy!",
                extra = "Golden Dewdrops are commonly considered a weed, but are commonly used in decoration!"
                      .. "\nA very good source of pollen!",
              },
    Orchid = {name = "Orchid",
                image = love.graphics.newImage("sprites/orchid.png"),
                price = 15,
                description = "Kenya's unofficial National flower. Attracts many bees!",
                extra = "There are over 25,000 species of orchids in the world, and"
                      .. "they can be found on every continent, except Antarctica.",
              }
}

local bees = {
     queenBee = {name = "Queen Bee",
                 image = love.graphics.newImage("sprites/bee.png"),
                 price = 50,
                 description = "Rules the hive.",
                 extra = "Having a Queen Bee in your hive produces more honey!"

                 },
     basicBee = {name = "Bee",
                 image = love.graphics.newImage("sprites/bee.png"),
                 price = 10,
                 description = "Classic worker bee.",
                 extra = ""
                 }
    }

local shopItems = {tools = tools, hives = hives , flowers = flowers, bees = bees}

return shopItems