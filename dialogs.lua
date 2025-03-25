-- dialogs.lua: file contains the scripts for the dialogs
-- author: Elaina Vogel

--TODO: fix ref to hive so that it pulls correct info

Object = require "classic" 
Hive = require("hive")  -- Loads the Hive classh
hive = Hive()        -- Creates an instance


return {
    goodnight = {
        text = "Time to go to bed! Tomorrow is a new day!",
        options = {} -- no choices, signals end of dialogue
    },
    goodmorning = {
        text = "The sun is up! Let's work hard today!",
        options = {} -- no choices, signals end of dialogue
    },
    morningstats = {
        text = string.format("Check out your stats:\nYour hive's health is at %d.\nYour hive's honey count is at %d.\nYour bee count is %d.\nYour fences are at %d strength.", hive.health, hive.honey, hive.beeCount, 0),
        options = {} -- no choices, signals end of dialogue
    },
    waspmessage = {
        text = "Oh no! Wasps are attacking!\nWasps are a natural predator to honey bees. Paper wasps build open-comb in paper nests in trees. They attack weak hives and hunt bees mid-flight.",
        options = {} -- no choices, signals end of dialogue
    },
    badgermessage = {
        text = "Oh no! A honey badger is attacking!\nBadgers are tough and aggresive predators. They attack can tear open bee hives with their powerful claws in order to feast on the honey, wax, and bee larvae. They withstand any bee stings through their thick, loose skin.",
        options = {} -- no choices, signals end of dialogue
    }
}