loadstring([[
    function LPH_NO_VIRTUALIZE(f) return f end;
]])();

local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local repo = 'https://raw.githubusercontent.com/violin-suzutsuki/LinoriaLib/refs/heads/main/'
local Library = loadstring(game:HttpGet(repo .. 'Library.lua'))()
local ThemeManager = loadstring(game:HttpGet(repo .. 'addons/ThemeManager.lua'))()
local SaveManager = loadstring(game:HttpGet(repo .. 'addons/SaveManager.lua'))()
local replicatedStorage = game:GetService("ReplicatedStorage")
local eventsFolder = replicatedStorage:WaitForChild("events")
local reelFinishedEvent = eventsFolder:WaitForChild("reelfinished ")

local teleportLocations = {
    ancientarcives = {name = "Ancient Arcives", CFrame = CFrame.new(-3155.02222, -754.818115, 2193.13696, 1, -4.34576686e-09, -4.751973e-15, 4.34576686e-09, 1, 6.18270164e-08, 4.48328737e-15, -6.18270164e-08, 1)},
    ancientisle = {name = "Ancient Isle", CFrame = CFrame.new(6056.05322, 195.280151, 278.566803, 0.573598862, -5.25042978e-08, 0.819136322, 3.08235357e-08, 1, 4.25130118e-08, -0.819136322, 8.63263794e-10, 0.573598862)},
    abyssalzenithpond = {name = "Abyssal Zenith Pond", CFrame = CFrame.new(-13527.3955, -11050.1885, 118.069931, -0.0310397707, 1.70327397e-09, 0.999518156, 3.23999885e-08, 1, -6.97921942e-10, -0.999518156, 3.23627134e-08, -0.0310397707)},
    arch = {name = "Arch", CFrame = CFrame.new(998.966797, 131.320236, -1237.14343, 3.12243492e-15, -1.22214405e-09, -1, 2.32352875e-08, 1, -1.22214405e-09, 1, -2.32352875e-08, 3.15083191e-15)},
    atlantis = {name = "Atlantis", CFrame = CFrame.new(-4265.13086, -603.403931, 1830.80737, -0.998844087, -4.74763917e-09, -0.048067458, -4.01612077e-10, 1, -9.04248267e-08, 0.048067458, -9.03010005e-08, -0.998844087)},
    forsakenveil = {name = "Forsaken Veil", CFrame = CFrame.new(-2373.34717, -11186.4043, 7122.69336, 1, 1.74519654e-09, -3.49131692e-15, -1.74519654e-09, 1, -3.31945351e-08, 3.43338601e-15, 3.31945351e-08, 1)},
    brine = {name = "Brine Pool", CFrame = CFrame.new(-1794.10596, -142.849976, -3302.92163, -6.3212552e-05, -3.18203519e-10, 1, -7.82197702e-08, 1, 3.1325903e-10, -1, -7.8219756e-08, -6.3212552e-05)},
    chesspuzzle = {name = "Chess Puzzle", CFrame = CFrame.new(-4312.79053, -11172.4707, 4102.43359, -1, -8.348712e-11, -2.22509547e-16, -8.348712e-11, 1, -2.05973265e-08, 2.24229156e-16, -2.05973265e-08, -1)},
    crafting = {name = "Ancient Arcives Crafting", CFrame = CFrame.new(-3159.99512, -745.614014, 1684.16797, 1, -1.21779961e-10, -5.67299522e-16, 1.21779961e-10, 1, 3.00249141e-08, 5.63643093e-16, -3.00249141e-08, 1)},
    desolatedeep = {name = "Desolate Deep", CFrame = CFrame.new(-1510.88696, -234.710205, -2852.90674, 0.573598862, 2.16122089e-08, 0.819136322, -1.26273259e-08, 1, -1.75418773e-08, -0.819136322, -2.81499712e-10, 0.573598862)},
    desolateshop = {name = "Desolate Shop", CFrame = CFrame.new(-1510.88696, -234.710205, -2852.90674, 0.573598862, 2.16122089e-08, 0.819136322, -1.26273259e-08, 1, -1.75418773e-08, -0.819136322, -2.81499712e-10, 0.573598862)},
    keepersalter = {name = "Keepers Alter", CFrame = CFrame.new(1310.73328, -805.292236, -103.465141, 0.0660791993, -2.23277596e-09, -0.997814357, -2.56381139e-08, 1, -3.93552346e-09, 0.997814357, 2.58421355e-08, 0.0660791993)},
    forsaken = {name = "Forsaken Shores", CFrame = CFrame.new(-2500.87549, 133.799469, 1563.52747, 0.999994636, -5.31127782e-08, -0.00328367297, 5.29274153e-08, 1, -5.65370506e-08, 0.00328367297, 5.63629499e-08, 0.999994636)},
    grandreef = {name = "Grand Reef", CFrame = CFrame.new(-3577.31812, 151.059967, 522.965393, 0.512457371, 1.60415468e-08, 0.858712673, -8.42765715e-08, 1, 3.1613137e-08, -0.858712673, -8.85697418e-08, 0.512457371)},
    merlin = {name = "Merlin's Hud", CFrame = CFrame.new(-949.014587, 222.05545, -985.975403, -0.34193182, -1.49588892e-08, -0.939724743, 5.62292835e-09, 1, -1.79643518e-08, 0.939724743, -1.14265886e-08, -0.34193182)},
    moosewood = {name = "Moosewood", CFrame = CFrame.new(383.101135, 134.500519, 243.933853, -0.457844615, 6.40537081e-08, -0.889032245, -1.41802667e-08, 1, 7.93515298e-08, 0.889032245, 4.89373839e-08, -0.457844615)},
    mushgrove = {name = "Mushgrove", CFrame = CFrame.new(2501.48584, 131.000015, -720.699463, 6.17755426e-14, -3.91777135e-08, -1, 2.99326359e-08, 1, -3.91777135e-08, 1, -2.99326359e-08, 6.2948236e-14)},
    oilrig = {name = "Oil Rig", CFrame = CFrame.new(-1914.82117, 224.690887, -461.420471, -0.896638751, 2.09963638e-08, -0.442762882, 7.50530837e-09, 1, 3.22222427e-08, 0.442762882, 2.55686405e-08, -0.896638751)},
    roslit = {name = "Roslit", CFrame = CFrame.new(-1476.51147, 133.5, 671.685303, 8.17535194e-15, -4.32666845e-08, -1, 5.26757233e-08, 1, -4.32666845e-08, 1, -5.26757233e-08, 1.04544559e-14)},
    snowcap = {name = "Snowcap", CFrame = CFrame.new(2648.67578, 142.283829, 2521.29736, 0.4648332, -7.9386254e-08, 0.885398269, -4.8671037e-08, 1, 1.15213879e-07, -0.885398269, -9.66484919e-08, 0.4648332)},
    spike = {name = "Harvesters Spike", CFrame = CFrame.new(180, -81.77899932861328, 180)},
    statue = {name = "Soverign Statue", CFrame = CFrame.new(72.883667, 141.929993, -1028.41931, 0.0735510588, -1.94882883e-08, -0.997291446, 3.3903568e-08, 1, -1.70408008e-08, 0.997291446, -3.25583684e-08, 0.0735510588)},
    sunstone = {name = "Sunstone", CFrame = CFrame.new(-933.259705, 131.874741, -1119.52063, -0.342042685, 3.46985267e-08, -0.939684391, -4.25889972e-08, 1, 5.24280104e-08, 0.939684391, 5.79528354e-08, -0.342042685)},
    terrapin = {name = "Terrapin", CFrame = CFrame.new(-166.553711, 145.05423, 1937.92114, -0.273773521, -1.86391915e-08, 0.961794198, 2.85754922e-08, 1, 2.75135825e-08, -0.961794198, 3.50162317e-08, -0.273773521)},
    trident = {name = "Trident Room", CFrame = CFrame.new(-1479.44971, -225.710632, -2388.19458, -0.960970938, -8.83329179e-08, 0.276649415, -9.60530144e-08, 1, -1.43547636e-08, -0.276649415, -4.03675209e-08, -0.960970938)},
    vertigo = {name = "Vertigo", CFrame = CFrame.new(-112.007278, -515.299377, 1040.32788, -1, -1.57867817e-08, 2.39495398e-14, -1.57867817e-08, 1, -6.21667473e-09, -2.38513975e-14, -6.21667473e-09, -1)},
    volcano = {name = "Roslit Volcano", CFrame = CFrame.new(-1888.52319, 167.78244, 329.238281, 1, -5.98080803e-08, -1.88335828e-14, 5.98080803e-08, 1, 2.35482585e-08, 1.74252058e-14, -2.35482585e-08, 1)},
    volcanicvents = {name = "Volanic Vents", CFrame = CFrame.new(-3176.98486, -2036.87378, 4028.52026, 0.152929783, 7.89456465e-08, -0.988237083, -8.23108479e-08, 1, 6.71477167e-08, 0.988237083, 7.10737496e-08, 0.152929783)},
    challangersdeep = {name = "Challangers Deep", CFrame = CFrame.new(722.191772, -3360.5, -1581.11462, 0.776097536, -5.76849892e-08, -0.63061291, 6.74396929e-08, 1, -8.47621262e-09, 0.63061291, -3.59499737e-08, 0.776097536)},
    calmzone = {name = "Calm Zone", CFrame = CFrame.new(-4327.96289, -11174.2666, 3699.45825, 0.942729831, -7.33702663e-08, -0.333557218, 5.6046499e-08, 1, -6.15593265e-08, 0.333557218, 3.93391026e-08, 0.942729831)},
}

local locationNames = {}
local nameToLocation = {} 
for key, location in pairs(teleportLocations) do
    table.insert(locationNames, location.name)
    nameToLocation[location.name] = location
end

local interactables = {
    "Rod Of The Zenith",
    "Abyssal Specter Rod",
    "Advanced Diving Gear",
    "Advanced Glider",
    "Champions Rod",
    "Conception Conch",
    "Depthseeker Rod",
    "Flippers",
    "Kraken Rod",
    "Quality Bait Crate",
    "Super Flippers",
    "Aurora Totem",
    "Bait Crate",
    "Coral Geode",
    "Reinforced Rod",
    "Tide Breaker",
    "Kings Rod",
    "Sundial Totem",
    "Basic Diving Gear",
    "Fish Radar",
    "Long Rod",
    "Lucky Rod",
    "Plastic Rod",
    "Training Rod",
    "GPS",
    "Windset Totem",
    "Lost Rod",
    "Carbon Rod",
    "Glider",
    "Tidebreaker",
    "Tempest Totem",
    "Magnet Rod",
    "Trident Rod",
    "Nocturnal Rod",
    "Leviathan's Fang Rod",
    "Meteor Totem",
    "Fortune Rod",
    "Rapid Rod",
    "Steady Rod",
    "Volcanic Rod",
    "Smokescreen Totem",
    "Challengers Rod",
    "Ethereal Prism Rod",
    "Scurvy Rod",
    "Eclipse Totem",
}

local EventsFarm_Events = 
{
    {
        Name = "Whale Migration",
        Teleport = "Whales Pool"
    },
    {
        Name = "Orcas Pool",
        Teleport = "Orcas Pool"
    },
    {
        Name = "Scylla",
        Teleport = "Forsaken Veil - Scylla"
    },
    {
        Name = "Kraken",
        Teleport = "The Kraken Pool"
    },
    {
        Name = "Whale Shark",
        Teleport = "Whale Shark"
    },
    {
        Name = "Megalodon",
        Teleport = "Megalodon Default"
    }
}

local Userinterface = {}
local config =
{
    Farm =
    {
        DisableEquippingRod = false,
        AutoCast = false,
        AutoShake = false,
        AutoReel = false,
        InstaBobber = false,
        InstaReel = false,
        CastDistance = 100,
        PerfectCatchChance = 100,
        Eventfarm = false,
        AuroraOnVent = {"Megalodon","Scylla", "Whale Migration", "Orcas Pool", "Kraken", "Whale Shark"},
        SelectableEvents = {"Megalodon","Scylla", "Whale Migration", "Orcas Pool", "Kraken", "Whale Shark"},
        SelectableTotemsDay = {"Aurora", "Sundial", "Tempest", "Windset", "Eclipse", "Smokescreen"},
        SelectableTotemsNight = {"Aurora", "Sundial", "Tempest", "Windset", "Eclipse", "Smokescreen"},
        EnableTotems = false,
        DisableTotemsOnEvent = false,
        DisableOxygen = false,
        DisableTemperature = false,
        FreezeCharacter = false,
        AutoGlimmerFinsBoots = false,
    },

    Items =
    {
        InteractablesAmount = 0,
        AutomaticSell = false,
        AutoDelay = 35,
        MerlinsItems = {"Power", "Luck"},
        MerlinsItemsAmount = 0,
        CollectTreasaureMaps = false,
        Appraisal = false,
        WantedName = {"Mythical", "Greedy", "Abyssal", "Fossilized", "Lunar", "Midas", "Glossy", "Silver", "Mosaic"},
        WantedExtra = {"Sparkling", "Shiny", "Big", "Giant"},
    },

    Teleports =
    {

    },

    Settings =
    {
        walkspeed = 16,
        jumpPower = 50,
    },
}

local wantedItemNames = {}
for _, name in pairs(config.Items.WantedName) do
    table.insert(wantedItemNames, name)
end

local wantedExtraItemNames = {}
for _, name in pairs(config.Items.WantedExtra) do
    table.insert(wantedExtraItemNames, name)
end

local utils = {
    contains = LPH_NO_VIRTUALIZE(function(self, table, value)
        for i, v in ipairs(table) do
            if (v == value) then
                return true
            end
        end
        return false
    end),

    printtable = LPH_NO_VIRTUALIZE(function(self, table)
        for i, v in ipairs(table) do
            print(i, v)
        end
    end),

    teleport = function(self, locationName)
        local location = teleportLocations[locationName]
        if not location then
            for key, loc in pairs(teleportLocations) do
                if loc.name == locationName then
                    location = loc
                    break
                end
            end
        end

        if (not location) then
            return
        end
           
        local player = game.Players.LocalPlayer
        if not player or not player.Character then
            Library:Notify("Teleport Error: Player or character not found", 3)
            return
        end
        
        local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then
            Library:Notify("Teleport Error: HumanoidRootPart not found", 3)
            return
        end
        
        humanoidRootPart.CFrame = location.CFrame
        Library:Notify("Teleported to " .. location.name, 3)
    end,

    teleportToPlayer = function(self, playerName)
        if not playerName or playerName == "" then
            Library:Notify("Teleport Error: No player selected", 3)
            return
        end
        
        local targetPlayer = game.Players:FindFirstChild(playerName)
        if not targetPlayer then
            Library:Notify("Teleport Error: Player not found: " .. playerName, 3)
            return
        end
        
        local targetCharacter = targetPlayer.Character
        if not targetCharacter then
            Library:Notify("Teleport Error: Target player's character not found", 3)
            return
        end
        
        local targetHRP = targetCharacter:FindFirstChild("HumanoidRootPart")
        if not targetHRP then
            Library:Notify("Teleport Error: Target player's HumanoidRootPart not found", 3)
            return
        end
        
        local player = game.Players.LocalPlayer
        if not player or not player.Character then
            Library:Notify("Teleport Error: Your character not found", 3)
            return
        end
        
        local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then
            Library:Notify("Teleport Error: Your HumanoidRootPart not found", 3)
            return
        end
        
        humanoidRootPart.CFrame = targetHRP.CFrame
        Library:Notify("Teleported to " .. playerName, 3)
    end,

    simulateVIMClick = LPH_NO_VIRTUALIZE(function(self, button)
        local success, position
        success = pcall(function()
            position = button.AbsolutePosition + button.AbsoluteSize/2
        end)
        
        if (not success or not position) then
            return false
        end
        
        VirtualInputManager:SendMouseButtonEvent(
            position.X, 
            position.Y, 
            0,
            true, 
            nil, 
            0 
        )
        
        VirtualInputManager:SendMouseButtonEvent(
            position.X,
            position.Y,
            0,
            false,
            nil,
            0
        )
        
        return true
    end),

    GetRod = LPH_NO_VIRTUALIZE(function(self)
        local player = game.Players.LocalPlayer
        if not player then 
            return nil 
        end
        
        local character = player.Character
        if character then
            for _, v in pairs(character:GetChildren()) do
                if v:IsA("Tool") and string.find(v.Name:lower(), "rod") then
                    return v
                end
            end
        end
        
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, v in pairs(backpack:GetChildren()) do
                if v:IsA("Tool") and string.find(v.Name:lower(), "rod") then
                    return v
                end
            end
        end
        
        return nil
    end),

    RodBackpack = LPH_NO_VIRTUALIZE(function(self)
        local player = game.Players.LocalPlayer
        if not player then 
            return nil 
        end
        
        local backpack = player:FindFirstChild("Backpack")
        if backpack then
            for _, v in pairs(backpack:GetChildren()) do
                if v:IsA("Tool") and string.find(v.Name:lower(), "rod") then
                    return v
                end
            end
        end
        
        return nil
    end),

    GetBite = LPH_NO_VIRTUALIZE(function(self)
        local rod = self:GetRod()
        if not rod then 
            return false 
        end
        
        local player = game.Players.LocalPlayer
        if not player or not player.Character then 
            return false 
        end
        
        local rodInCharacter = player.Character:FindFirstChild(rod.Name)
        if not rodInCharacter then 
            return false 
        end
        
        local values = rodInCharacter:FindFirstChild("values")
        if not values then 
            return false 
        end
        
        local bite = values:FindFirstChild("bite")
        if not bite then 
            return false 
        end
        
        return bite.Value
    end),

    GetLure = LPH_NO_VIRTUALIZE(function(self)
        local rod = self:GetRod()
        if not rod then 
            return false 
        end
        
        local player = game.Players.LocalPlayer
        if not player or not player.Character then 
            return false 
        end
        
        local rodInCharacter = player.Character:FindFirstChild(rod.Name)
        if not rodInCharacter then 
            return false 
        end
        
        local values = rodInCharacter:FindFirstChild("values")
        if not values then 
            return false 
        end
        
        local lure = values:FindFirstChild("lure")
        if not lure then 
            return false 
        end
        
        return lure.Value
    end),

    GetCast = LPH_NO_VIRTUALIZE(function(self)
        local rod = self:GetRod()
        if not rod then 
            return false 
        end
        
        local player = game.Players.LocalPlayer
        if not player or not player.Character then 
            return false 
        end
        
        local rodInCharacter = player.Character:FindFirstChild(rod.Name)
        if not rodInCharacter then 
            return false 
        end
        
        local values = rodInCharacter:FindFirstChild("values")
        if not values then 
            return false 
        end
        
        local casted = values:FindFirstChild("casted")
        if not casted then 
            return false 
        end
        
        return casted.Value
    end),

    GetBobber = LPH_NO_VIRTUALIZE(function(self)
        local rod = self:GetRod()
        if not rod then 
            return false 
        end
        
        local player = game.Players.LocalPlayer
        if not player or not player.Character then 
            return false 
        end
        
        local rodInCharacter = player.Character:FindFirstChild(rod.Name)
        if not rodInCharacter then 
            return false 
        end
        
        local bobber = rodInCharacter:FindFirstChild("bobber")
        if bobber then
            return true
        end
        
        return false
    end),

    GetShake = LPH_NO_VIRTUALIZE(function(self)
        local LocalPlayer = game.Players.LocalPlayer

        if (not LocalPlayer) then 
            return false 
        end
        
        local gui = LocalPlayer:FindFirstChild("PlayerGui")
        if (not gui) then
            return false
        end
        
        local shakeui = gui:FindFirstChild("shakeui")
        if (not shakeui) then
            return false
        end
        
        local safezone = shakeui:FindFirstChild("safezone")
        if (not safezone) then
            return false
        end
        
        local button = safezone:FindFirstChild("button")
        return button
    end),

    GetReel = LPH_NO_VIRTUALIZE(function(self)
        local rod = self:GetRod()
        if not rod then 
            return false 
        end
        
        local player = game.Players.LocalPlayer
        if not player or not player.Character then 
            return false 
        end
        
        local rodInCharacter = player.Character:FindFirstChild(rod.Name)
        if not rodInCharacter then 
            return false 
        end
        
        local values = rodInCharacter:FindFirstChild("values")
        if not values then 
            return false 
        end
        
        local bite = values:FindFirstChild("bite")
        if not bite then 
            return false 
        end
        
        return bite.Value
    end),

    GetCycle = LPH_NO_VIRTUALIZE(function(self)
        local world = game:GetService("ReplicatedStorage"):WaitForChild("world")
        if (world:WaitForChild("cycle").Value == "Day") then
            return "Day"
        else
            return "Night"
        end
    end),

    ShouldTotem = LPH_NO_VIRTUALIZE(function(self)
        local cycle = self:GetCycle()
        if (cycle == "Day" and config.Farm.SelectableTotemsDay["Sundial"] and config.Farm.EnableTotems) then
            return true
        end
    
        if (cycle == "Night" and config.Farm.SelectableTotemsNight["Aurora"] and config.Farm.EnableTotems) then
            return true
        end
    
        return false
    end),

    return_all_players = LPH_NO_VIRTUALIZE(function(self)
        local players = {}
        for _, v in pairs(game.Players:GetPlayers()) do
            table.insert(players, v.Name)
        end
        return players
    end),

    is_calc = LPH_NO_VIRTUALIZE(function(self)
        local calc = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("reel")
        local canrun = calc:WaitForChild("bar").playerbar.Position
        return canrun
    end),
}

local Farm =
{
    globalfarm = {
        EventFarm_Running = false,
        EventFarm_CanSearch = true,
        originalPosition = nil,
        DelayRodEquip = false,
        DelayRodEquipTime = 0,
        DelayRodEquipTimeout = 5,
        currentEventName = nil,
        currentEvent = nil,
        currentFarmTask = nil,
        lastCastTime = nil,
        castTimeout = 5,
        freezeEnabled = false,
        freezePosition = nil,
        freezeTask = nil,
        instaReelInProgress = false,
        fishingTimeout = nil,
        reelAnimationComplete = false,
    },

    autocast = LPH_NO_VIRTUALIZE(function(self)
        if (not config.Farm.AutoCast) then
            return
        end
        
        local player = game.Players.LocalPlayer
        local reelUI = player.PlayerGui:FindFirstChild("reel")
        
        -- Check fishing state
        local isCast = utils:GetCast()
        local hasBobber = utils:GetBobber()

        if (self.globalfarm.DelayRodEquip) then return end
        
        local player = game.Players.LocalPlayer
        local backpack = player:FindFirstChild("Backpack")
        local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
        
        if (not backpack or not humanoid) then
            return
        end
        
        local rodInBackpack = false
        for _, item in pairs(backpack:GetChildren()) do
            if (item:IsA("Tool") and string.find(item.Name:lower(), "rod")) then
                rodInBackpack = true
                humanoid:EquipTool(item)
                task.wait(0.5)  -- 
                break
            end
        end
        
        local rod = utils:GetRod()
        if (not rod) then
            return
        end
        
        -- Make sure we're not already casting
        if (not utils:GetCast() and not utils:GetBobber()) then
            local catchpercentage = config.Farm.PerfectCatchChance
            local shouldperfect = math.random(0, 100) <= catchpercentage
            
            print("Casting rod...")
            rod.events.cast:FireServer(config.Farm.CastDistance, shouldperfect)
            self.globalfarm.lastCastTime = tick()
        end
    end),

    autobobber = LPH_NO_VIRTUALIZE(function(self)
        if (config.Farm.InstaBobber) then
            local player = game.Players.LocalPlayer
            if (player and player.Character) then
                local rod = utils:GetRod()
                if (rod and player.Character:FindFirstChild(rod.Name)) then
                    local equippedRod = player.Character:FindFirstChild(rod.Name)
                    local bobber = equippedRod:FindFirstChild("bobber")
                    
                    if (bobber) then
                        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                        if (hrp) then
                            bobber.CFrame = hrp.CFrame + Vector3.new(0, -15, 0)
                            print("InstaBobber")
                        end
                    end
                end
            end
        end
    end),

    autoshake = LPH_NO_VIRTUALIZE(function(self)
        if (not config.Farm.AutoShake) then
            return
        end

        local button = utils:GetShake()
        if (not button) then
            return
        end
        
        if (not utils:GetCast() or not utils:GetBobber()) then
            return
        end
        
        if (GuiService.SelectedObject ~= button) then
            GuiService.SelectedObject = button
        end
        
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    end),

    instareel = LPH_NO_VIRTUALIZE(function(self)
        self.globalfarm.DelayRodEquip = true
        local player = game.Players.LocalPlayer
        local perfectCatchChance = config.Farm.PerfectCatchChance
        local isPerfectCatch = math.random(0, 100) <= perfectCatchChance
        local args = {
            [1] = 100,
            [2] = isPerfectCatch
        }
        
        -- Fire the event directly using cached reference
        reelFinishedEvent:FireServer(unpack(args))

        -- Unequip tools immediately
        if (player.Character and player.Character:FindFirstChild("Humanoid")) then
            player.Character.Humanoid:UnequipTools()
        end

        task.wait(0.5)
        self.globalfarm.DelayRodEquip = false
    end),
    
    autoreel = LPH_NO_VIRTUALIZE(function(self)
        -- Cache the player reference
        local player = game.Players.LocalPlayer

        if not (utils:GetBobber() and utils:GetCast()) then
            return
        end
        
        -- Check reel UI - this could be a source of delay
        local reelUI = player.PlayerGui:FindFirstChild("reel")
        if (not reelUI or not reelUI:IsA("ScreenGui") or not reelUI:FindFirstChild("bar")) then
            return
        end
    
        -- If InstaReel is enabled, call it directly and return
        if (config.Farm.InstaReel) then
            self:instareel()
            return
        end
    
        -- Standard reel if not using InstaReel
        local perfectCatchChance = config.Farm.PerfectCatchChance
        local isPerfectCatch = math.random(0, 100) <= perfectCatchChance
    
        local args = {
            [1] = 100,
            [2] = isPerfectCatch
        }
    
        -- Use the cached event reference
        reelFinishedEvent:FireServer(unpack(args))
    end),

    stopFreezeCharacter = function(self)
        if not self.globalfarm.freezeTask then
            return
        end
        
        self.globalfarm.freezeEnabled = false
        task.cancel(self.globalfarm.freezeTask)
        self.globalfarm.freezeTask = nil
        
        Library:Notify("Character position unfrozen", 3)
    end,
    
    toggleFreezeCharacter = function(self)
        if self.globalfarm.freezeEnabled then
            self:stopFreezeCharacter()
        else
            self:startFreezeCharacter()
        end
    end,
    
    EventFarm = function(self, Event, GoBackCF)
        self.globalfarm.originalPosition = GoBackCF
        self.globalfarm.EventFarm_CanSearch = false
        self.globalfarm.EventFarm_Running = true
        self.globalfarm.currentEvent = Event
        self.globalfarm.currentEventName = Event.Name
       
        local farmTask = task.spawn(function()
            while true do
                local LP = game.Players.LocalPlayer
                local character = LP.Character
               
                if (not workspace.zones.fishing:FindFirstChild(Event.Teleport)) then
                    if (character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid")) then
                        local LP = game.Players.LocalPlayer
                        local character = LP.Character
                        character.Humanoid:UnequipTools()
                        
                        self.globalfarm.DelayRodEquip = true
                        self.globalfarm.DelayRodEquipTime = tick()
                        
                        task.wait(0.5)
                        character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                        character.HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
                        character.Humanoid.PlatformStand = false
                        character.HumanoidRootPart.CFrame = self.globalfarm.originalPosition
                        character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                        character.HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
                        task.wait(1)
                        
                        self.globalfarm.DelayRodEquip = false
                    else
                        self.globalfarm.DelayRodEquip = false
                    end
                    
                    self.globalfarm.EventFarm_CanSearch = true
                    self.globalfarm.EventFarm_Running = false
                    self.globalfarm.currentEvent = nil
                    self.globalfarm.currentEventName = nil
                    return
                end
                
                if (character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid")) then
                    character.Humanoid.PlatformStand = true
                    character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                    character.HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
                    
                    local targetCFrame = workspace.zones.fishing[Event.Teleport].CFrame
                    
                    if Event.Name == "Megalodon" then
                        targetCFrame = targetCFrame + Vector3.new(0, -155, 0)
                    end
                    
                    if Event.Name == "Scylla" then
                        targetCFrame = targetCFrame + Vector3.new(0, -85, 0)
                    end

                    character.HumanoidRootPart.CFrame = targetCFrame
                end
               
                task.wait()
            end
        end)
       
        self.globalfarm.currentFarmTask = farmTask
        return farmTask
    end,
   
    StopEventFarm = function(self)
        if (self.globalfarm.currentFarmTask) then
            local LP = game.Players.LocalPlayer

            task.cancel(self.globalfarm.currentFarmTask)
            self.globalfarm.currentFarmTask = nil
           
            local LP = game.Players.LocalPlayer
            local character = LP.Character
            
            if (not character or not character:FindFirstChild("HumanoidRootPart") or not character:FindFirstChild("Humanoid")) then
                self.globalfarm.EventFarm_CanSearch = true
                self.globalfarm.EventFarm_Running = false
                self.globalfarm.currentEvent = nil
                self.globalfarm.currentEventName = nil
                self.globalfarm.DelayRodEquip = false
                return
            end

            character.Humanoid:UnequipTools()
            
            self.globalfarm.DelayRodEquip = true
            self.globalfarm.DelayRodEquipTime = tick()
            
            task.wait(0.5)
            character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            character.HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
            character.Humanoid.PlatformStand = false
            character.HumanoidRootPart.CFrame = self.globalfarm.originalPosition
            character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
            character.HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
            
            self.globalfarm.EventFarm_CanSearch = true
            self.globalfarm.EventFarm_Running = false
            self.globalfarm.currentEvent = nil
            self.globalfarm.currentEventName = nil
            
            task.wait(0.5)
            self.globalfarm.DelayRodEquip = false
        end
    end,
   
    EventFarmLook = function(self, selectedEvents)
        if (not self.globalfarm.EventFarm_CanSearch) then
            return
        end
        
        if (not selectedEvents or #selectedEvents == 0) then
            return
        end
       
        for _, Event in ipairs(EventsFarm_Events) do
            for __, eventName in ipairs(selectedEvents) do
                if (Event.Name == eventName and workspace.zones.fishing:FindFirstChild(Event.Teleport)) then
                    local character = game.Players.LocalPlayer.Character
                    
                    if (character and character:FindFirstChild("HumanoidRootPart")) then
                        local oldc = character.HumanoidRootPart.CFrame
                        self:EventFarm(Event, oldc)
                        return Event
                    end
                end
            end
        end
        
        return nil
    end,

    Disablers = LPH_NO_VIRTUALIZE(function(self)
        local LP = game.Players.LocalPlayer
        local PlayerName = LP.Name
        
        local PlayerResources = workspace:FindFirstChild(PlayerName) and workspace[PlayerName]:FindFirstChild("Resources")
        if (not PlayerResources) then
            return
        end
        
        local Res = {
            Oxygen = PlayerResources:FindFirstChild("oxygen"),
            OxygenPeaks = PlayerResources:FindFirstChild("oxygen(peaks)"),
            Temp = PlayerResources:FindFirstChild("temperature"),
            TempPeaks = PlayerResources:FindFirstChild("temperature(heat)")
        }
        
        if (Res.Oxygen) then
            Res.Oxygen.Enabled = not config.Farm.DisableOxygen
        end
        
        if (Res.OxygenPeaks) then
            Res.OxygenPeaks.Enabled = not config.Farm.DisableOxygen
        end
        
        if (Res.Temp) then
            Res.Temp.Enabled = not config.Farm.DisableTemperature
        end
        
        if (Res.TempPeaks) then
            Res.TempPeaks.Enabled = not config.Farm.DisableTemperature
        end
    end),

    autototem_data = {
        in_progress = false,
        last_used = {
            ["Sundial"] = 0,
            ["Aurora"] = 0,
            ["Tempest"] = 0,
            ["Windset"] = 0,
            ["Eclipse"] = 0,
            ["Meteor"] = 0,
            ["Smokescreen"] = 0
        }
    },
    
    Totem = LPH_NO_VIRTUALIZE(function(self, totemname)
        if (self.autototem_data.in_progress) then
            return false
        end

        local weather = game:GetService("ReplicatedStorage").world.weather.Value
        local time = game:GetService("ReplicatedStorage").world.cycle.Value

        if (weather == "Aurora_Borealis") then
            return
        end
        
        if (not self.autototem_data.last_used[totemname]) then
            self.autototem_data.last_used[totemname] = 0
        end
        
        if (tick() - self.autototem_data.last_used[totemname] < 5) then
            return false
        end
        
        local player = game.Players.LocalPlayer
        if (not player or not player.Character) then
            return false
        end
        
        local backpack = player:FindFirstChild("Backpack")
        if (not backpack) then
            return false
        end
        
        local fullTotemName = totemname .. " Totem"
        local item = backpack:FindFirstChild(fullTotemName)
        if (not item) then
            return false
        end
        
        self.autototem_data.in_progress = true
        self.globalfarm.DelayRodEquip = true
        self.globalfarm.DelayRodEquipTime = tick()
        
        local character = player.Character
        if (not character or not character:FindFirstChild("Humanoid")) then
            self.autototem_data.in_progress = false
            self.globalfarm.DelayRodEquip = false
            return false
        end
        
        character.Humanoid:EquipTool(item)
        
        task.spawn(function()
            task.wait(0.5)
            if (item and item.Parent == character) then
                item:Activate()
                self.autototem_data.last_used[totemname] = tick()
            end
            
            task.wait(3.5)
            self.autototem_data.in_progress = false
            self.globalfarm.DelayRodEquip = false
        end)
        
        return true
    end),
    
    AutoTotem = LPH_NO_VIRTUALIZE(function(self)
        if (utils:GetBobber() or utils:GetCast() or utils:GetShake()) then
            return 
        end
        
        if (not config.Farm.EnableTotems) then
            return 
        end
        
        if (self.autototem_data.in_progress) then
            return
        end
        
        local weather = game:GetService("ReplicatedStorage").world.weather.Value
        local time = game:GetService("ReplicatedStorage").world.cycle.Value

        if (weather == Aurora_Borealis) then
            return
        end
        
        if (self.globalfarm.EventFarm_Running and config.Farm.DisableTotemsOnEvent) then
            local currentEvent = self.globalfarm.currentEventName
            local eventSelection = Options.AuroraOnVent.Value
            
            if currentEvent and eventSelection[currentEvent] == true then
                if time == "Day" and weather ~= "Aurora_Borealis" then
                    self:Totem("Sundial")
                elseif time == "Night" and weather ~= "Aurora_Borealis" then
                    self:Totem("Aurora")
                end
            end
            return
        end
        
        local totemUsed = false
        
        if (time == "Day") then
            for i, v in pairs(config.Farm.SelectableTotemsDay) do
                if totemUsed then
                    break
                end

                if (weather == "Aurora_Borealis") then
                    break
                end
                
                if (v == true) then
                    local totemName = i
                    
                    if (totemName == "Sundial" and time ~= "Night") then
                        totemUsed = self:Totem("Sundial")
                    elseif (totemName == "Aurora" and weather ~= "Aurora_Borealis") then
                        totemUsed = self:Totem("Aurora")
                    elseif (totemName == "Tempest" and weather ~= "Rain") then
                        totemUsed = self:Totem("Tempest")
                    elseif (totemName == "Windset" and weather ~= "Foggy") then
                        totemUsed = self:Totem("Windset")
                    elseif (totemName == "Eclipse" and weather ~= "Eclipse") then
                        totemUsed = self:Totem("Eclipse")
                    elseif (totemName == "Meteor" and weather ~= "Meteor") then
                        totemUsed = self:Totem("Meteor")
                    elseif (totemName == "Smokescreen" and weather ~= "Smokescreen") then
                        totemUsed = self:Totem("Smokescreen")
                    end
                    
                    if totemUsed then
                        break
                    end
                end
            end
        elseif (time == "Night") then
            for i, v in pairs(config.Farm.SelectableTotemsNight) do
                if totemUsed then
                    break
                end
                
                if (v == true) then
                    local totemName = i
                    
                    if (totemName == "Sundial" and time ~= "Day") then
                        totemUsed = self:Totem("Sundial")
                    elseif (totemName == "Aurora" and weather ~= "Aurora_Borealis") then
                        totemUsed = self:Totem("Aurora")
                    elseif (totemName == "Tempest" and weather ~= "Rain") then
                        totemUsed = self:Totem("Tempest")
                    elseif (totemName == "Windset" and weather ~= "Foggy") then
                        totemUsed = self:Totem("Windset")
                    elseif (totemName == "Eclipse" and weather ~= "Eclipse") then
                        totemUsed = self:Totem("Eclipse")
                    elseif (totemName == "Meteor" and weather ~= "Meteor") then
                        totemUsed = self:Totem("Meteor")
                    elseif (totemName == "Smokescreen" and weather ~= "Smokescreen") then
                        totemUsed = self:Totem("Smokescreen")
                    end
                    
                    if totemUsed then
                        break
                    end
                end
            end
        end
    end),

    FarmHandler = LPH_NO_VIRTUALIZE(function(self)
        if config.Farm.FreezeCharacter and not self.globalfarm.freezeEnabled then
            self:startFreezeCharacter()
        elseif not config.Farm.FreezeCharacter and self.globalfarm.freezeEnabled then
            self:stopFreezeCharacter()
        end
        
        self:autocast()
        self:autoreel()
        self:autoshake()
        self:autoshake()
        self:Disablers()
        self:autobobber()

        local weather = game:GetService("ReplicatedStorage").world.weather.Value
        local time = game:GetService("ReplicatedStorage").world.cycle.Value
        if (weather ~= "Aurora_Borealis") then
            self:AutoTotem()
        end

        if (config.Farm.AutoGlimmerFinsBoots) then
            self:AutoGlimmerfinBoots()
        end

        if (config.Farm.Eventfarm) then
            local selectedEvents = {}
            local selectionData = Options.SelectableEvents.Value
            
            if (type(selectionData) == "table") then
                for eventName, isSelected in pairs(selectionData) do
                    if (isSelected) then
                        table.insert(selectedEvents, eventName)
                    end
                end
                
                if (#selectedEvents > 0) then
                    self:EventFarmLook(selectedEvents)
                end
            end
        else
            if (self.globalfarm.EventFarm_Running) then
                self:StopEventFarm()
            end
        end
    end),

    GlimmerfinData =
    {
        HasBoots = false,
        HasRocketFuel = false,
        HasSpeedCore = false,
        HasCreatedPlatform = false,
    },
    
    AutoGlimmerfinBoots = LPH_NO_VIRTUALIZE(function(self)
        self.GlimmerfinData.HasBoots = false
        self.GlimmerfinData.HasRocketFuel = false
        self.GlimmerfinData.HasSpeedCore = false
        
        local player = game.Players.LocalPlayer
        local backpack = player:FindFirstChild("Backpack")
        
        if (backpack) then
            for _, item in pairs(backpack:GetChildren()) do
                if (item:IsA("Tool")) then
                    if (item.Name == "Boots") then
                        self.GlimmerfinData.HasBoots = true
                    elseif (item.Name == "RocketFuel") then
                        self.GlimmerfinData.HasRocketFuel = true
                    elseif (item.Name == "Speed Core") then
                        self.GlimmerfinData.HasSpeedCore = true
                    end
                end
            end
        end
        
        if (player.Character) then
            for _, item in pairs(player.Character:GetChildren()) do
                if (item:IsA("Tool")) then
                    if (item.Name == "Boots") then
                        self.GlimmerfinData.HasBoots = true
                    elseif (item.Name == "RocketFuel") then
                        self.GlimmerfinData.HasRocketFuel = true
                    elseif (item.Name == "Speed Core") then
                        self.GlimmerfinData.HasSpeedCore = true
                    end
                end
            end
        end
        
        if (self.GlimmerfinData.HasBoots and self.GlimmerfinData.HasRocketFuel and self.GlimmerfinData.HasSpeedCore) then
            local platform = workspace:FindFirstChild("GlimmerfinPlatform")
            if (platform) then
                platform:Destroy()
            end
            
            config.Farm.FreezeCharacter = false
            self.GlimmerfinData.HasCreatedPlatform = false
            
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-1914.82117, 224.690887, -461.420471, -0.896638751, 2.09963638e-08, -0.442762882, 7.50530837e-09, 1, 3.22222427e-08, 0.442762882, 2.55686405e-08, -0.896638751)
            config.Farm.AutoGlimmerFinsBoots = false
            return
        end
        
        if not (self.GlimmerfinData.HasRocketFuel) then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(2494.56982, 131.500015, -692.572144, -0.0844169855, 4.50856641e-09, 0.996430516, 1.24242117e-09, 1, -4.41946035e-09, -0.996430516, 8.64908867e-10, -0.0844169855)
            return
        end
        
        if (self.GlimmerfinData.HasRocketFuel and not self.GlimmerfinData.HasSpeedCore) then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-939.188171, 131.51181, -1106.35193, -0.927945971, -1.52026498e-08, 0.372714728, -1.27003483e-08, 1, 9.16897847e-09, -0.372714728, 3.77470943e-09, -0.927945971)
            return
        end
        
        if (self.GlimmerfinData.HasRocketFuel and self.GlimmerfinData.HasSpeedCore and not self.GlimmerfinData.HasBoots) then
            local platform
            
            if not self.GlimmerfinData.HasCreatedPlatform then
                platform = Instance.new("Part")
                platform.Name = "GlimmerfinPlatform"
                platform.Size = Vector3.new(10, 1, 10)
                platform.Anchored = true
                platform.CanCollide = true
                platform.CFrame = CFrame.new(5589.17676, 132.336502, 3759.37476, -0.860510528, -5.10935152e-08, -0.509432614, -9.16899552e-08, 1, 5.45835839e-08, 0.509432614, 9.36796027e-08, -0.860510528)
                platform.Transparency = 0.5
                platform.Parent = workspace
                
                self.GlimmerfinData.HasCreatedPlatform = true
            else
                platform = workspace:FindFirstChild("GlimmerfinPlatform")
                if not platform then
                    self.GlimmerfinData.HasCreatedPlatform = false
                    return
                end
            end
            
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = platform.CFrame + Vector3.new(0, 3, 0)
            config.Farm.FreezeCharacter = true
            return
        end
    end),
}

local Items =
{
    globalitems =
    {
        LastSoldTimestamp = nil,
    },

    AutomaticSell = LPH_NO_VIRTUALIZE(function(self)
        if (self.globalitems.LastSoldTimestamp == nil) then
            self.globalitems.LastSoldTimestamp = tick()
        end

        if (self.globalitems.LastSoldTimestamp + config.Items.AutoDelay < tick()) then
            game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("SellAll"):InvokeServer()
            self.globalitems.LastSoldTimestamp = tick()
        end
    end),

    TreasureMaps = LPH_NO_VIRTUALIZE(function(self)
        local me = game.Players.LocalPlayer
        local backpack = me:FindFirstChild("Backpack")
        local mapCount = 0
        local originalpos = me.Character.HumanoidRootPart.CFrame
        
        for _, item in pairs(backpack:GetChildren()) do
            if (string.find(item.Name, "Treasure Map")) then
                mapCount = mapCount + 1
                
                game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-2825.97168, 214.668106, 1515.68689, -0.419284374, -3.09877528e-08, 0.907854974, 4.23330953e-08, 1, 5.36840794e-08, -0.907854974, 6.09412041e-08, -0.419284374)
                wait(0.5)
                
                local jackMarrow = workspace:WaitForChild("world", 5):WaitForChild("npcs", 5):WaitForChild("Jack Marrow", 5)
                if (jackMarrow and jackMarrow:FindFirstChild("dialogprompt")) then
                    fireproximityprompt(jackMarrow.dialogprompt)
                end
                
                wait(0.5)
                
                local humanoid = me.Character:FindFirstChild("Humanoid")
                if (not humanoid) then
                    return
                end
                
                humanoid:EquipTool(item)
                wait(0.5)
                
                local success, result = pcall(function()
                    return workspace:WaitForChild("world", 5):WaitForChild("npcs", 5):WaitForChild("Jack Marrow", 5):WaitForChild("treasure", 5):WaitForChild("repairmap", 5):InvokeServer()
                end)
                
                if (success) then
                    wait(0.5)
                    
                    local chests = workspace:WaitForChild("world", 5):WaitForChild("chests", 5):GetChildren()
                    local chestCount = 0
                    for _, chest in pairs(chests) do
                        if (string.find(chest.Name, "TreasureChest")) then
                            local x, y, z = chest.Name:match("TreasureChest_(%-?%d+%.?%d*)_(%-?%d+%.?%d*)_(%-?%d+%.?%d*)")
                            
                            if (x and y and z) then
                                x = tonumber(x)
                                y = tonumber(y)
                                z = tonumber(z)
                                
                                local args = {
                                    [1] = {
                                        ["y"] = y,
                                        ["x"] = x,
                                        ["z"] = z
                                    }
                                }
                                
                                local success, result = pcall(function()
                                    game:GetService("ReplicatedStorage"):WaitForChild("events", 5):WaitForChild("open_treasure", 5):FireServer(unpack(args))
                                end)
                                
                                if (success) then
                                    chestCount = chestCount + 1
                                end
                                
                                wait(0.5)
                            end
                        end
                    end
                    
                    wait(0.5)
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = originalpos
                    wait(1)
                end
            end
        end
    end),

    ItemHandler = LPH_NO_VIRTUALIZE(function(self)
        if (config.Items.AutomaticSell) then
            self:AutomaticSell()
        end
    end),
}

Userinterface.Window = Library:CreateWindow({
    Title = 'Exodus v0.8 | https://discord.gg/H958VpDEmN',
    Center = true,
    AutoShow = true,
})

Userinterface.Tabs = {
    Farm = Userinterface.Window:AddTab('Farm'),
    Items = Userinterface.Window:AddTab('Items'),
    Teleports = Userinterface.Window:AddTab('Teleports'),
    Settings = Userinterface.Window:AddTab('Settings'),
    ['UI Settings'] = Userinterface.Window:AddTab('UI Settings'),
}

Userinterface.Groups = {
    Farm = {
        Left = Userinterface.Tabs.Farm:AddLeftGroupbox('Autofarm'),
        Right = Userinterface.Tabs.Farm:AddRightGroupbox('Eventfarm'),
        Left2 = Userinterface.Tabs.Farm:AddLeftGroupbox('Settings'),
        Right2 = Userinterface.Tabs.Farm:AddRightGroupbox('Totems'),
        Left3 = Userinterface.Tabs.Farm:AddLeftGroupbox('Player Modifications'),
        Right3 = Userinterface.Tabs.Farm:AddRightGroupbox('Automation'),
    },
    Items = {
        Left = Userinterface.Tabs.Items:AddLeftGroupbox('Interactables'),
        Right = Userinterface.Tabs.Items:AddRightGroupbox('Sell Items'),
        Left2 = Userinterface.Tabs.Items:AddLeftGroupbox('Merlins Items'),
        Right2 = Userinterface.Tabs.Items:AddRightGroupbox('Miscellaneous'),
        Left3 = Userinterface.Tabs.Items:AddLeftGroupbox('Appraisal'),
    },
    Teleports = {
        Left = Userinterface.Tabs.Teleports:AddLeftGroupbox('Locations'),
    },
    Settings = {
        Left = Userinterface.Tabs.Settings:AddLeftGroupbox('Player Settings'),
    },
    UI = {
        Left = Userinterface.Tabs['UI Settings']:AddLeftGroupbox('Menu'),
    },
}
Userinterface.Elements = {

    AutoCast = Userinterface.Groups.Farm.Left:AddToggle('AutoCast', {
        Text = "Auto Cast",
        Default = config.Farm.AutoCast,
        Tooltip = "Automatically casts the rod.",
    }),

    AutoShake = Userinterface.Groups.Farm.Left:AddToggle('AutoShake', {
        Text = "Auto Shake",
        Default = config.Farm.AutoShake,
        Tooltip = "Automatically plays the shake minigame.",
    }),

    AutoReel = Userinterface.Groups.Farm.Left:AddToggle('AutoReel', {
        Text = "Auto Reel",
        Default = config.Farm.AutoReel,
        Tooltip = "Automatically reels in the fish.",
    }),

    InstaBobber = Userinterface.Groups.Farm.Left:AddToggle('InstaBobber', {
        Text = "Instant Bobber",
        Default = config.Farm.InstaBobber,
        Tooltip = "Instantly casts the bobber.",
    }),

    InstaReel = Userinterface.Groups.Farm.Left:AddToggle('InstaReel', {
        Text = "Instant Reel",
        Default = config.Farm.InstaReel,
        Tooltip = "Instantly reels in the fish.",
    }),

    CastDistance = Userinterface.Groups.Farm.Left2:AddSlider('CastDistance', {
        Text = 'Cast Distance',
        Default = config.Farm.CastDistance,
        Min = 0,
        Max = 100,
        Rounding = 1,
        Tooltip = 'How far your rod casts, lower = faster',
    }),

    PerfectCatchChance = Userinterface.Groups.Farm.Left2:AddSlider('PerfectCatchChance', {
        Text = 'Perfect Catch Chance',
        Default = config.Farm.PerfectCatchChance,
        Min = 0,
        Max = 100,
        Rounding = 1,
        Tooltip = 'The chance of a perfect catch.',
    }),

    Eventfarm = Userinterface.Groups.Farm.Right:AddToggle('Eventfarm', {
        Text = "Event Farm",
        Default = config.Farm.Eventfarm,
        Tooltip = "Automatically teleports to events.",
    }),

    SelectableEvents = Userinterface.Groups.Farm.Right:AddDropdown('SelectableEvents', {
        Values = config.Farm.SelectableEvents,
        Default = 0,
        Text = false,
        Multi = true,
        Tooltip = 'Select an event to override',
    }),

    SelectableTotemsDay = Userinterface.Groups.Farm.Right2:AddDropdown('SelectableTotemsDay', {
        Values = config.Farm.SelectableTotemsDay,
        Default = 0,
        Text = "Day Cycle",
        Multi = true,
        Tooltip = 'Select a totem for the day cycle',
    }),

    SelectableTotemsNight = Userinterface.Groups.Farm.Right2:AddDropdown('SelectableTotemsNight', {
        Values = config.Farm.SelectableTotemsNight,
        Default = 0,
        Text = "Night Cycle",
        Multi = true,
        Tooltip = 'Select a totem for the night cycle',
    }),

    AuroraOnVent = Userinterface.Groups.Farm.Right2:AddDropdown('AuroraOnVent', {
        Values = config.Farm.AuroraOnVent,
        Default = 0,
        Text = "Aurora Totem on Event",
        Multi = true,
        Tooltip = 'Select an event to use Aurora totem on.',
    }),

    DisableTotemsOnEvent = Userinterface.Groups.Farm.Right2:AddToggle('DisableTotemsOnEvent', {
        Text = "Disable Totems On Event",
        Default = config.Farm.DisableTotemsOnEvent,
        Tooltip = "Disables totems when an event is active (except for Aurora).",
    }),

    EnableTotems = Userinterface.Groups.Farm.Right2:AddToggle('EnableTotems', {
        Text = "Enable Totems",
        Default = config.Farm.EnableTotems,
        Tooltip = "Automatically uses, totems.",
    }),

    DisableOxygen = Userinterface.Groups.Farm.Left3:AddToggle('DisableOxygen', {
        Text = "Disable Oxygen",
        Default = config.Farm.DisableOxygen,
        Tooltip = "Disables the oxygen bar.",
    }),

    DisableTemperature = Userinterface.Groups.Farm.Left3:AddToggle('DisableTemperature', {
        Text = "Disable Temperature",
        Default = config.Farm.DisableTemperature,
        Tooltip = "Disables the temperature bar.",
    }),

    FreezeCharacter = Userinterface.Groups.Farm.Left3:AddToggle('FreezeCharacter', {
        Text = "Freeze Character",
        Default = config.Farm.FreezeCharacter,
        Tooltip = "Freeze your character's position.",
    }),

    Interactables = Userinterface.Groups.Items.Left:AddDropdown('Interactables', {
        Values = interactables,
        Default = 0,
        Text = false,
        Multi = false,
        Tooltip = 'Select an item to interact with',
    }),

    InteractablesAmount = Userinterface.Groups.Items.Left:AddInput('InteractablesAmount', {
        Default = "1",
        Numeric = true,
        Finished = false,
        Text = "Amount to purchase.",
        Tooltip = "Will purchase, the amount of the item selected.",
        Placeholder = false,
    
        Callback = function(Value)
            config.Items.InteractablesAmount = Value
        end
    }),

    InteractablesConfirm = Userinterface.Groups.Items.Left:AddButton('Confirm', function()
        local amount = tonumber(Userinterface.Elements.InteractablesAmount.Value)
        local selected = Userinterface.Elements.Interactables.Value
        if (not selected) then
            return
        end
        local ReplicatedStorage = game:GetService("ReplicatedStorage")
        local events = ReplicatedStorage:WaitForChild("events")
        events:WaitForChild("purchase"):FireServer(selected, "item", {}, tonumber(amount))
    end),

    AutomaticSell = Userinterface.Groups.Items.Right:AddToggle('AutomaticSell', {
        Text = "Automatic Sell",
        Default = config.Items.AutomaticSell,
        Tooltip = "Automatically sells all items.",
    }),

    AutoDelay = Userinterface.Groups.Items.Right:AddSlider('AutoDelay', {
        Text = 'Auto Delay',
        Default = config.Items.AutoDelay,
        Min = 1,
        Max = 100,
        Rounding = 1,
        Tooltip = 'How long to wait before selling again.',
    }),

    SellItems = Userinterface.Groups.Items.Right:AddButton('Sell Items', function()
        game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("SellAll"):InvokeServer()
    end),

    MerlinsItems = Userinterface.Groups.Items.Left2:AddDropdown('MerlinsItems', {
        Values = config.Items.MerlinsItems,
        Default = 0,
        Text = false,
        Multi = false,
        Tooltip = 'Select an item to purchase from Merlin.'
    }),
    
    MerlinsItemsAmount = Userinterface.Groups.Items.Left2:AddInput('MerlinsItemsAmount', {
        Default = "1",
        Numeric = true,
        Finished = false,
        Text = "Amount to purchase.",
        Tooltip = "Will purchase, the amount of the item selected.",
        Placeholder = false,
    
        Callback = function(Value)
            config.Items.MerlinsItemsAmount = Value
        end
    }),

    MerlinsItemsConfirm = Userinterface.Groups.Items.Left2:AddButton('Confirm', function()
        local amount = tonumber(config.Items.MerlinsItemsAmount) or 1
        local selectedItem = Options.MerlinsItems.Value
        if (not selectedItem or selectedItem == "") then
            return
        end
        
        local originalpos = game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-931.322876, 223.783524, -987.698425, 0.97989291, -2.47481674e-10, -0.199524015, -6.53734011e-11, 1, -1.56141911e-09, 0.199524015, 1.54306712e-09, 0.97989291)
        
        wait(0.5)
        
        local merlinNPC = workspace:WaitForChild("world", 5):WaitForChild("npcs", 5):WaitForChild("Merlin", 5)
        if (not merlinNPC) then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = originalpos
            return
        end
        
        local dialogPrompt = merlinNPC:FindFirstChild("dialogprompt")
        if (dialogPrompt) then
            fireproximityprompt(dialogPrompt)
        end
        
        wait(0.3)
        
        for i = 1, amount do
            if (selectedItem == "Power") then
                pcall(function()
                    workspace.world.npcs.Merlin.Merlin.power:InvokeServer()
                end)
            elseif (selectedItem == "Luck") then
                pcall(function()
                    workspace.world.npcs.Merlin.Merlin.luck:InvokeServer()
                end)
            end
            task.wait(0.2)
        end
        
        wait(0.3)
        game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = originalpos
    end),

    CollectTreasureMaps = Userinterface.Groups.Items.Right2:AddButton('Collect Treasure Maps', function()
        Items:TreasureMaps()
    end),

    Location = Userinterface.Groups.Teleports.Left:AddDropdown('Location', {
        Values = locationNames,
        Default = 0,
        Text = false,
        Multi = false,
        Tooltip = 'Select a location to teleport to',
    }),

    -- glimmerfin boots
    GlimmerfinBoots = Userinterface.Groups.Farm.Right3:AddToggle('GlimmerfinBoots', {
        Text = "Glimmerfin Boots",
        Default = false,
        Tooltip = "Automatically gets the glimmerfin boots.",
    }),

    -- Player Settings
    walkspeed = Userinterface.Groups.Settings.Left:AddSlider('walkspeed', {
        Text = 'Walkspeed',
        Default = 16,
        Min = 0,
        Max = 100,
        Rounding = 1,
        Tooltip = 'How fast your character moves.',
    }),

    jumpPower = Userinterface.Groups.Settings.Left:AddSlider('jumpPower', {
        Text = 'Jump Power',
        Default = 50,
        Min = 0,
        Max = 100,
        Rounding = 1,
        Tooltip = 'How high your character jumps.',
    }),

    resetwsjp = Userinterface.Groups.Settings.Left:AddButton('Reset', function()
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
    end),

    CanRun = Userinterface.Groups.UI.Left:AddButton('CanRun', function()
        print(tostring(utils:is_calc()))
    end),
}

Userinterface.Elements.AutoCast:OnChanged(function()
    config.Farm.AutoCast = Toggles.AutoCast.Value
end)

Userinterface.Elements.AutoShake:OnChanged(function()
    config.Farm.AutoShake = Toggles.AutoShake.Value
end)

Userinterface.Elements.AutoReel:OnChanged(function()
    config.Farm.AutoReel = Toggles.AutoReel.Value
end)

Userinterface.Elements.InstaReel:OnChanged(function()
    config.Farm.InstaReel = Toggles.InstaReel.Value
end)

Userinterface.Elements.CastDistance:OnChanged(function()
    config.Farm.CastDistance = Options.CastDistance.Value
end)

Userinterface.Elements.PerfectCatchChance:OnChanged(function()
    config.Farm.PerfectCatchChance = Options.PerfectCatchChance.Value
end)

Userinterface.Elements.Eventfarm:OnChanged(function()
    config.Farm.Eventfarm = Toggles.Eventfarm.Value
end)

Userinterface.Elements.SelectableEvents:OnChanged(function()
    config.Farm.SelectableEvents = Options.SelectableEvents.Value
end)

Userinterface.Elements.SelectableTotemsDay:OnChanged(function()
    config.Farm.SelectableTotemsDay = Options.SelectableTotemsDay.Value
end)

Userinterface.Elements.SelectableTotemsNight:OnChanged(function()
    config.Farm.SelectableTotemsNight = Options.SelectableTotemsNight.Value
end)

Userinterface.Elements.DisableTotemsOnEvent:OnChanged(function()
    config.Farm.DisableTotemsOnEvent = Toggles.DisableTotemsOnEvent.Value
end)

Userinterface.Elements.EnableTotems:OnChanged(function()
    config.Farm.EnableTotems = Toggles.EnableTotems.Value
end)

Userinterface.Elements.Interactables:OnChanged(function()
    config.Items.Interactables = Options.Interactables.Value
end)

Userinterface.Elements.InteractablesAmount:OnChanged(function()
    config.Items.InteractablesAmount = Options.InteractablesAmount.Value
end)

Userinterface.Elements.AutomaticSell:OnChanged(function()
    config.Items.AutomaticSell = Toggles.AutomaticSell.Value
end)

Userinterface.Elements.AutoDelay:OnChanged(function()
    config.Items.AutoDelay = Options.AutoDelay.Value
end)

Userinterface.Elements.Location:OnChanged(function()
    utils:teleport(Options.Location.Value)
end)

Userinterface.Elements.AuroraOnVent:OnChanged(function()
    config.Farm.AuroraOnVent = Options.AuroraOnVent.Value
end)

Userinterface.Elements.DisableOxygen:OnChanged(function()
    config.Farm.DisableOxygen = Toggles.DisableOxygen.Value
end)

Userinterface.Elements.DisableTemperature:OnChanged(function()
    config.Farm.DisableTemperature = Toggles.DisableTemperature.Value
end)

Userinterface.Elements.FreezeCharacter:OnChanged(function()
    config.Farm.FreezeCharacter = Toggles.FreezeCharacter.Value
end)

Userinterface.Elements.MerlinsItems:OnChanged(function()
    config.Items.MerlinsItems = Options.MerlinsItems.Value
end)

Userinterface.Elements.MerlinsItemsAmount:OnChanged(function()
    config.Items.MerlinsItemsAmount = Options.MerlinsItemsAmount.Value
end)

Userinterface.Elements.GlimmerfinBoots:OnChanged(function()
    config.Farm.AutoGlimmerFinsBoots = Toggles.GlimmerfinBoots.Value
end)

Userinterface.Elements.walkspeed:OnChanged(function()
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Options.walkspeed.Value
end)

Userinterface.Elements.jumpPower:OnChanged(function()
    game.Players.LocalPlayer.Character.Humanoid.JumpPower = Options.jumpPower.Value
end)

Userinterface.Elements.InstaBobber:OnChanged(function()
    config.Farm.InstaBobber = Toggles.InstaBobber.Value
end)

Userinterface.Groups.UI.Left:AddButton('Unload', function() Library:Unload() end)
Userinterface.Groups.UI.Left:AddLabel('Menu bind'):AddKeyPicker('MenuKeybind', { Default = 'P', NoUI = true, Text = 'Menu keybind' })
Library.KeybindFrame.Visible = false
Library.ToggleKeybind = Options.MenuKeybind
ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({ 'MenuKeybind' })
ThemeManager:SetFolder('Exodus')
SaveManager:SetFolder('Exodus/configs')
SaveManager:BuildConfigSection(Userinterface.Tabs['UI Settings'])
ThemeManager:ApplyToTab(Userinterface.Tabs['UI Settings'])
Library:OnUnload(function()
    Library.Unloaded = true
end)

local LocalPlayer = game.Players.LocalPlayer
for _, v in pairs(getconnections(LocalPlayer.Idled)) do
    v:Disable()
end

local function masterswitch()
    Farm:FarmHandler()
    Items:ItemHandler()
end

local renderSteppedConnection = RunService.RenderStepped:Connect(masterswitch)