-- dialogs.lua: file contains the scripts for the dialogs
-- author: Elaina Vogel

--TODO: update tutorial

local dialog = {
    goodnight = {
        text = "Time to go to bed! Tomorrow is a new day!",
        options = {} -- no choices, signals end of dialogue
    },
    goodmorning = {
        text = "The sun is up! Let's work hard today!",
        options = {} -- no choices, signals end of dialogue
    },
    waspmessage = {
        text = "Oh no! Wasps are attacking! Wasps are a natural predator to honey bees. Paper wasps build open-comb in paper nests in trees. They attack weak hives and hunt bees mid-flight.",
        options = {
            {"Time to defend the hive!", function () for _, e in ipairs(Entities) do if e.type == "wasp" then e.visible = true end end end}
        }
    },
    bee_eatermessage = {
        text = "Oh no! A bee eater is attacking! Bee eaters are a natural predator to honey bees. They hunt bees mid-flight!",
        options = {
            {"Time to defend the hive!", function () for _, e in ipairs(Entities) do if e.type == "bee_eater" then e.visible = true end end end}
        }
    },
    mothmessage = {
        text = "Oh no! A wax moth is attacking! They invade hives and feed on the wax and larvae!",
        options = {
            {"Time to defend the hive!", function () for _, e in ipairs(Entities) do if e.type == "moth" then e.visible = true end end end}
        }
    },
    badgermessage = {
        text = "Oh no! A honey badger is attacking! Badgers are tough and aggressive predators. They can tear open bee hives with their powerful claws in order to feast on the honey, wax, and bee larvae. They withstand any bee stings through their thick, loose skin.",
        options = {
            {"Time to defend the hive!", function () for _, e in ipairs(Entities) do if e.type == "honey_badger" then e.visible = true end end end}
        }
    },
}

dialog.startup0 = {
    text = "To play, use the money earned from collecting honey to buy new tools. Press TAB to view the shop. Use LEFT CLICK to buy the listed items. Once you buy something, RIGHT CLICK to place the object where the mouse is. To move, use the arrow keys or WASD in the respective direction. These new hives, flowers, or bees will increase your productivity and help you against predator attacks.",
    options = {}
}

dialog.startup1 = {
    text = "A day lasts 60 seconds, or if you want to speed up the day, press SPACE. Be careful! Sometimes predators like to attack through the night! When predators attack, get near the predator, aim at them, and LEFT CLICK to fight. Press SPACE again after nightime. In the morning you will get see your updated stats. Press ENTER to continue.",
    options = {}
}

dialog.startup2 = {
    text = "Different types of flowers will help produce honey quicker. The more hives you have, the more honey you can make. More details for each flower and hive can be found in the shop.",
    options = {}
}

dialog.startup3 = {
    text = "To harvest honey, RIGHT CLICK on a hive while holding your bucket! To select an item in your inventory, press the NUMBER KEY for the item!",
    options = {}
}

dialog.startup4 = {
    text = "To sell honey, select the jar in your inventory using the NUMBER KEYS and RIGHT CLICK on the chest!",
    options = {}
}

dialog.startup5 = {
    text = "More dialogue boxes will show up through out the game. Quick tip: pressing 'C' will finish typing the message. Pressing ENTER will exit the dialogue box. Don't forget to exit the dialogue box before continuing to the next day.",
    options = {}
}

dialog.startupM = {
    text = "Welcome! The goal of this game is to build a good enviroment for your bees in order to collect money! Quick Tip: Press 'B' or 'N' to select an option. Then press ENTER to continue.",
    options = {
        { 'Tell Me How To Play!', function() 
            local dialove = require "libraries/Dialove/dialove"
            DialogManager:setTypingVolume(dialove:getTypingVolume())
            
            DialogManager:show(dialog.startup0) 
            DialogManager:push(dialog.startup1) 
            DialogManager:push(dialog.startup2) 
            DialogManager:push(dialog.startup3) 
            DialogManager:push(dialog.startup4) 
            DialogManager:push(dialog.startup5) 
        end },
        { 'Skip Tutorial!', function() DialogManager:pop() end }
    }
}


return dialog