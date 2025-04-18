-- This file contains all shop items available for purchase in game

-- Tools
local tools = { 
    honeyDipper = {name = "Honey Dipper",
                    image = love.graphics.newImage("sprites/honey_dipper.png"),
                    price = 100,
                    description = "Collect more honey.",
                    },
    basicSword = {name = "Basic Sword",
                    image = love.graphics.newImage("sprites/basic_sword.png"),
                    price = 100,
                    description = "Do more damage.",
                    },
}

-- Hives
local hives = {
    log = {name = "Log Hive",
            image = love.graphics.newImage("sprites/log_hive.png"),
            price = 50,
            description = "Simple, but prone to pests.",
            },
    topBar = {name = "Top-Bar Hive",
                image = love.graphics.newImage("sprites/top_bar_hive.png"),
                price = 100,
                description = "Sturdier than the Log Hive, but yields less honey.",
                },
    langstroth = {name = "Langstroth Hive",
                    image = love.graphics.newImage("sprites/langstroth_hive.png"),
                    price = 500,
                    description = "Well-protected and produces a lot of honey.",
                    },
}

-- Flowers
local flowers = {
    flameLily = {name = "Flame Lily",
                image = love.graphics.newImage("sprites/flame_lily.png"),
                price = 10,
                description = "Known for its distinct shape and color pattern"
                .. "that resembles fire, the flame lily is a highly poisonous flower.",
                },
    orchid = {name = "Orchid",
                image = love.graphics.newImage("sprites/orchid.png"),
                price = 15,
                description = "There are over 25,000 species of orchids in the world, and"
                            .. "they can be found on every continent, except Antarctica.",
            },
}

local shopItems = {tools = tools, hives = hives , flowers = flowers}
return shopItems