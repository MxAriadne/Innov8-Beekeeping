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
            {
                "Time to defend the hive!",  -- Option label (text displayed to the player)
                function() TrigW() end 
            }}
    },badgermessage = {
        text = "Oh no! A honey badger is attacking! Badgers are tough and aggressive predators. They can tear open bee hives with their powerful claws in order to feast on the honey, wax, and bee larvae. They withstand any bee stings through their thick, loose skin.",
        options = {
            {
                "Time to defend the hive!",  -- Option label (text displayed to the player)
                function() TrigB() end 
            }
        }
    }
}

dialog.startup0 = {
    text = [[To play use the money earned from collecting honey to buy new tools. 
    Type 'f' to buy a hive. 'g' to buy a bee. And 'h' to buy a flower.
    Once you buy something, RIGHT CLICK to place the object where the mouse is.
    These new hives, flowers, or bees will increase your productivity and help you withstand predator attacks. 
     ]],
    options = {}
}

dialog.startup1 = {
    text = "When you are ready for the next day, press SPACE. Be careful! Sometimes bee predators like to attack through the night! When predators attack, get near the predator and LEFT CLICK to fight them. Press SPACE again after nightime. In the morning you will get see your updated stats. Press RETURN to continue.",
    options = {}
}

dialog.startup2 = {
    text = "More dialogue boxes will show up through out the game. Quick tip: pressing 'c' will finish typing the message. Pressing RETURN will exit the dialogue box. Don't forget to exit the dialogue box before continuing to the next day.",
    options = {}
}

dialog.startupM = {
    text = [[Welcome! The goal of this game is to build a good enviroment for your bees in order to collect money! 
    Quick Tip: Press 'b' or 'n' to select an option. Then press RETURN.]],
    options = {
        { 'Tell Me How To Play!', function() dialogManager:show(dialog.startup0) dialogManager:push(dialog.startup1) dialogManager:push(dialog.startup2) end },
        { 'Skip Tutorial!', function() dialogManager:pop() end }
    }
}


return dialog