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
        text = "Oh no! Wasps are attacking!\nWasps are a natural predator to honey bees. Paper wasps build open-comb in paper nests in trees. They attack weak hives and hunt bees mid-flight.",
        options = { --[['Time to defend the hive!', function() TriggerWasp() end ]]}
    },
    badgermessage = {
        text = "Oh no! A honey badger is attacking!\nBadgers are tough and aggresive predators. They attack can tear open bee hives with their powerful claws in order to feast on the honey, wax, and bee larvae. They withstand any bee stings through their thick, loose skin.",
        options = { --[['Time to defend the hive!', function() dbadger = true end ]]} -- no choices, signals end of dialogue
    }
}

dialog.startup1 = {
    text = "When you are ready for the next day, press SPACE. Be careful! Sometimes bee predators like to attack through the night! Press SPACE again after nightime. In the morning you will get see your updated stats. Press RETURN to continue.",
    options = {}
}

dialog.startup2 = {
    text = "More dialogue boxes will show up through out the game. Quick tip: pressing 'c' will finish typing the message. Pressing RETURN will exit the dialogue box. Don't forget to ext the dialogue box before continuing to the next day.",
    options = {}
}

dialog.startupM = {
    text = "Welcome! The goal of this game is to build a good enviroment for your bees in order to collect money! To play EXPLAIN HOW TO USE INVENTORY. When predators attack, get near the predator and RIGHT CLICK to fight them. Press 'b' and 'n' to select an option. Then press RETURN.",
    options = {
        { 'Got it!', function() dialogManager:show(dialog.startup1) dialogManager:push(dialog.startup2) end },
        { 'Skip Tutorial!', function() dialogManager:pop() end }
    }
}

return dialog