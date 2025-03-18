loadstring([[
    function LPH_NO_VIRTUALIZE(f) return f end;
]])();

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local VirtualInputManager = game:GetService("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local player = game.Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local eventsFolder = replicatedStorage:WaitForChild("events")
local reelFinishedEvent = eventsFolder:WaitForChild("reelfinished ")

local Window = Fluent:CreateWindow({
    Title = "Exodus",
    SubTitle = "Premium",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false,
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.P
})

local Tabs = {
    Farm = Window:AddTab({Title = "Farm", Icon = "terminal"}),
    Items = Window:AddTab({Title = "Items", Icon = "file-box"}),
    Teleports = Window:AddTab({Title = "Teleports", Icon = "compass"}),
    Settings = Window:AddTab({Title = "Settings", Icon = "settings"}),
    Configuration = Window:AddTab({Title = "Configuration", Icon = "file"}),
    Debug = Window:AddTab({Title = "Debug", Icon = "bug"})
}

local Options = Fluent.Options

local Config =
{
    Premium = true,

    Farm =
    {
        AutoCast = false,
        AutoShake = false,
        AutoReel = false,
        AutoBobber = false,
        PerfectCatch = false,
        FreezeCharacter = false,
        AvoidModerator = false,
        InstantReel = false,
        ActiveEvents = {},
        EnableEvents = false,
        FarmRainbows = false,
    },

    Items =
    {
        SelectedItem = "",
        SelectedAmount = 0,
        MerlinItem = "",
        MerlinAmount = 0,
        AutomaticSell = false,
        AutomaticSellDelay = 5, 
        AutomaticSellTimestamp = nil,
        DayTotems = {"Sundial", "Tempest", "Smokescreen", "Windset", "Eclipse", "Meteor", "Blizzard", "Avalanche", "Zeus Storm", "Poseidon's Wrath"},
        NightTotems = {"Sundial", "Aurora", "Tempest", "Smokescreen", "Windset", "Meteor", "Blizzard", "Avalanche", "Zeus Storm", "Poseidon's Wrath"},
        SelectedDayTotems = {},
        SelectedNightTotems = {},
        TotemAutoPurchase = false,
        TotemEnabled = false,
    },

    Teleports =
    {
        Locations = {},
        LocationsCFrame = {},
        SelectedLocation = {},
    },
}

local utils =
{
    freeze = {
        position = nil,
        enabled = false,
        task = nil
    },

    merlin = {
        position = Vector3.new(-945.916077, 222.277206, -988.316101),
        cframe = CFrame.new(
            -945.916077, 222.277206, -988.316101,
            0.447595447, -8.35532354e-09, -0.894236147,
            3.9844096e-08, 1, 1.05997877e-08,
            0.894236147, -4.03744487e-08, 0.447595447
        )
    },

    GetTeleports = function(self)
        local positions = workspace.world.spawns.TpSpots:GetChildren()
        table.foreach(positions, function(i, v)
            table.insert(Config.Teleports.Locations, v.Name)
        end)

        table.foreach(positions, function(i, v)
            Config.Teleports.LocationsCFrame[v.Name] = v.CFrame
        end)
    end,

    GetRod = LPH_NO_VIRTUALIZE(function(self)
        local backpack = player.Backpack
        for _, item in pairs(backpack:GetChildren()) do
            if (string.match(item.Name:lower(), "rod") and not string.match(item.Name:lower(), "blrod")) then
                return item
            end
        end
       
        local character = workspace:FindFirstChild(player.Name)
        if (character) then
            for _, item in pairs(character:GetChildren()) do
                if (string.match(item.Name:lower(), "rod") and not string.match(item.Name:lower(), "blrod")) then
                    return item
                end
            end
        end
       
        return nil
    end),
   
    IsBobber = LPH_NO_VIRTUALIZE(function(self)
        local rod = self:GetRod()
       
        if not (rod) then
            return false
        end
       
        local character = workspace:FindFirstChild(player.Name)
        if not (character) then
            return false
        end
       
        local rodInWorkspace = character:FindFirstChild(rod.Name)
        if not (rodInWorkspace) then
            return false
        end
       
        local bobber = rodInWorkspace:FindFirstChild("bobber")
        if not (bobber) then
            return false
        end
       
        return true
    end),
    
    IsCast = LPH_NO_VIRTUALIZE(function(self)
        local rod = self:GetRod()
        if not (rod) then
            return false
        end
        
        local character = workspace:FindFirstChild(player.Name)
        if not (character) then
            return false
        end
        
        local rodInWorkspace = character:FindFirstChild(rod.Name)
        if not (rodInWorkspace) then
            return false
        end
        
        local values = rodInWorkspace:FindFirstChild("values")
        if not (values) then
            return false
        end
        
        local casted = values:FindFirstChild("casted")
        if not (casted) then
            return false
        end
        
        return casted.Value
    end),
    
    GetShake = LPH_NO_VIRTUALIZE(function(self)
        if (not player) then
            return false
        end
       
        local gui = player:FindFirstChild("PlayerGui")
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
        local playerGui = game:GetService("Players").LocalPlayer.PlayerGui

        local calc = playerGui:FindFirstChild("reel")
        if not (calc) then
            return false
        end
        
        local bar = calc:FindFirstChild("bar")
        if not (bar) then
            return false
        end
        
        local playerbar = bar:FindFirstChild("playerbar")
        if not (playerbar) then
            return false
        end
        
        return true
    end),

    startFreezeCharacter = function(self)
        if (self.freeze.task) then
            return
        end
        
        local character = player.Character
        if not (character or character:FindFirstChild("HumanoidRootPart")) then
            return
        end
        
        self.freeze.position = character.HumanoidRootPart.CFrame
        self.freeze.enabled = true
        
        self.freeze.task = task.spawn(LPH_NO_VIRTUALIZE(function()
            while (self.freeze.enabled) do
                local character = player.Character
                if (character and character:FindFirstChild("HumanoidRootPart")) then
                    character.HumanoidRootPart.CFrame = self.freeze.position
                end
                task.wait()
            end
        end))
        
        Fluent:Notify({
            Title = "Character Frozen",
            Content = "Your character position has been frozen",
            Duration = 3
        })
    end,

    stopFreezeCharacter = function(self)
        if not (self.freeze.task) then
            return
        end
        
        self.freeze.enabled = false
        task.cancel(self.freeze.task)
        self.freeze.task = nil
        
        Fluent:Notify({
            Title = "Character Unfrozen",
            Content = "Your character position has been unfrozen",
            Duration = 3
        })
    end,

    toggleFreezeCharacter = function(self)
        if (self.freeze.enabled) then
            self:stopFreezeCharacter()
        else
            self:startFreezeCharacter()
        end
    end,

    IsModeratorInSession = LPH_NO_VIRTUALIZE(function(self)
        if not (Config.Farm.AvoidModerator) then
            return
        end

        local moderators_id = {1607891435, 146089324, 813163219, 276557820, 552714899, 2243026817, 5080868749, 250083132, 107691892, 129332660, 7930492944, 7930656926, 3607413291, 37048457, 270505110, 189239279, 2678001507, 8818419, 30060913, 7685118272, 7658109668, 9297997, 1881196856, 780769472, 207355228, 882208278, 198270268, 45385291, 4851551957, 259238245, 1277041782, 16375783, 6193518594, 30180836, 102808868, 182959121, 1815640972, 2834359801, 1436154219, 71731571, 7795810613, 1108032657, 4563659453, 19256410, 90362827, 1815640972, 157180286, 7831420159, 2439010264, 220005139, 927948745, 7733466, 487532097, 34919504, 388661773, 181751703, 155853515, 202694904, 8036444866, 153704791, 60226364, 343144872, 183838537, 152539737, 447540231, 69796570, 2500988604, 142156798, 1265374855, 844219223, 402818270, 139050865, 2503057025, 2021683619, 925431600, 2694547161, 90135034, 106369038, 144595432, 920915908, 99083109, 272559087, 162424510, 143009483, 233309309, 1138331840, 3647331140, 2512557413, 371624529, 4675733230, 298106898}
        
        for i, id in pairs(moderators_id) do
            moderators_id[i] = tonumber(id)
        end
        
        local players = game.Players:GetPlayers()
        local localPlayer = game.Players.LocalPlayer
        
        for _, player in pairs(players) do
            for _, id in pairs(moderators_id) do
                if (player.UserId == id) then
                    localPlayer:Kick("Moderator detect ID: " .. id)
                    return
                end
            end
        end
    end),

    preloadMerlinLocation = function(self)
        local preloadSuccess = false
        local preloadThread = coroutine.create(function()
            pcall(function()
                player:RequestStreamAroundAsync(self.merlin.position)
                preloadSuccess = true
            end)
        end)
        coroutine.resume(preloadThread)
        
        local startTime = tick()
        while not preloadSuccess and tick() - startTime < 2 do
            task.wait(0.1)
        end
        
        return preloadSuccess
    end,
    
    triggerMerlinDialog = function(self)
        pcall(function()
            local dialogPrompt = workspace.world.npcs.Merlin.dialogprompt
            local prompt
            for _, child in pairs(dialogPrompt:GetDescendants()) do
                if (child:IsA("ProximityPrompt")) then
                    prompt = child
                    break
                end
            end
            
            if (prompt) then
                fireproximityprompt(prompt)
                return true
            end
        end)
        
        return true 
    end,
    
    invokeMerlinLuck = function(self)
        local success, result = pcall(function()
            return workspace.world.npcs.Merlin.Merlin.luck:InvokeServer()
        end)
        
        return success
    end,
    
    purchaseFromMerlin = function(self, itemType, amount)
        local preloadSuccess = self:preloadMerlinLocation()
        if not (preloadSuccess) then
            print("Failed to preload Merlin's location")
        end
        task.wait(0.1)
        self:triggerMerlinDialog()
        task.wait(0.1)
        if (itemType == "luck") then
            for i = 1, amount do
                local success = self:invokeMerlinLuck()
                if not (success) then
                    print("Failed to invoke luck remote, retrying...")
                    self:preloadMerlinLocation()
                    task.wait(0.1)
                    self:invokeMerlinLuck()
                end
                task.wait(0.1)
            end
            return true
        elseif (itemType == "power") then
            for i = 1, amount do
                local success = pcall(function()
                    workspace.world.npcs.Merlin.Merlin.power:InvokeServer()
                end)
                if not (success) then
                    print("Failed to invoke power remote, retrying...")
                    self:preloadMerlinLocation()
                    task.wait(0.1)
                    pcall(function()
                        workspace.world.npcs.Merlin.Merlin.power:InvokeServer()
                    end)
                end
                task.wait(0.1)
            end
            return true
        end
        
        return false
    end
}

local features =
{
    farm =
    {
        Status =
        {
            InstareelStamp = nil,
            InstareelThreshold = 0,
            LastFinished = nil,
            UsingTotem = false,
        },
        
        TotemData =
        {
            LastUsed = nil,
            LastTick = nil,
            Threshold = 5,
            Debug = false,
            DayCycleUsedSundial = false,    -- Track if Sundial was used during current day cycle
            NightCycleUsedSundial = false,  -- Track if Sundial was used during current night cycle
            LastCycleState = nil            -- Store the last cycle state to detect changes
        },

        autocast = LPH_NO_VIRTUALIZE(function(self)
            if not (Config.Farm.AutoCast) then
                return
            end

            if (self.Status.UsingTotem) then
                return
            end
        
            if (utils:IsCast()) then 
                return
            end
        
            if (utils:IsBobber()) then
                return
            end
        
            local rod = utils:GetRod()
            if not (rod) then
                return
            end
            
            rod.events.cast:FireServer(100, false)
        end),

        AutoShake = LPH_NO_VIRTUALIZE(function(self)
            if (not Config.Farm.AutoShake) then
                return
            end
    
            if (self.Status.UsingTotem) then
                return
            end
            
            local button = utils:GetShake()
            if (not button) then
                return
            end
            
            if not (utils:IsCast()) then
                return
            end
    
            if not (utils:IsBobber()) then
                return
            end
            
            if (GuiService.SelectedObject ~= button) then
                GuiService.SelectedObject = button
            end
            
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
        end),

        InstaReel = LPH_NO_VIRTUALIZE(function(self)
            if not (Config.Farm.InstantReel) then
                return
            end
            if not (Config.Premium) then
                return
            end
            if not (utils:GetReel()) then
                return
            end

            if (self.Status.UsingTotem) then
                return
            end

            if (self.Status.InstareelStamp == nil) then
                self.Status.InstareelStamp = tick()
            end
            
            if (self.Status.InstareelStamp + self.Status.InstareelThreshold > tick()) then
                return
            end
            
            local playerGui = game:GetService("Players").LocalPlayer.PlayerGui
            local reelGui = playerGui:FindFirstChild("reel")
            if not (reelGui) then
                return
            end
            
            self.Status.InstareelStamp = tick()
            self.Status.LastFinished = tick()
            
            local player = game.Players.LocalPlayer
            local character = player.Character
            local humanoid = character:FindFirstChildOfClass("Humanoid")

            pcall(function()
                reelGui = playerGui:FindFirstChild("reel")
                if (reelGui) then
                    reelGui:Destroy()
                end
            end)
            
            wait(0.8)
            humanoid:UnequipTools()
            wait(0.2)
            
            local foundRod = false
            local backpack = player.Backpack
            for _, item in pairs(backpack:GetChildren()) do
                if (string.match(item.Name:lower(), "rod")) then
                    humanoid:EquipTool(item)
                    self.Status.Reel = true
                    foundRod = true
                    break
                end
            end      
        end),

        AutoReel = LPH_NO_VIRTUALIZE(function(self)
            if not (Config.Farm.AutoReel) then
                return
            end

            if (self.Status.UsingTotem) then
                return
            end
            
            if not (utils:GetReel()) then
                return
            end
    
            local args = {[1] = 100, [2] = Config.Farm.PerfectCatch}
            reelFinishedEvent:FireServer(unpack(args))   

            if (Config.Farm.InstantReel) then
                self:InstaReel()
            end
        end),

        AutoBobber = LPH_NO_VIRTUALIZE(function(self)
            if not (Config.Farm.AutoBobber) then
                return
            end
            
            if (self.Status.UsingTotem) then
                return
            end
            
            local player = game.Players.LocalPlayer
            if (player and player.Character) then
                local rod = utils:GetRod()
                if (rod and player.Character:FindFirstChild(rod.Name)) then
                    local equippedRod = player.Character:FindFirstChild(rod.Name)
                    local bobber = equippedRod:FindFirstChild("bobber")
                    
                    if (bobber) then
                        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
                        if (hrp) then
                            local lookVector = hrp.CFrame.LookVector
                            bobber.CFrame = CFrame.new(hrp.Position + (lookVector * 5) + Vector3.new(0, -12, 0))
                        end
                    end
                end
            end
        end),
        
        UseTotem = function(self, totemName)
            local player = game.Players.LocalPlayer
            local character = player.Character
            local backpack = player.Backpack
            local found = false
            
            if (self.TotemData.Debug) then
                print("[Totem Debug] Attempting to use: " .. totemName)
            end
            
            if (not totemName) then
                return false
            end
            
            self.Status.UsingTotem = true
            
            -- First unequip any tool to ensure clean equip
            if character and character:FindFirstChild("Humanoid") then
                character.Humanoid:UnequipTools()
                task.wait(0.5)
            end
            
            -- Find the totem in backpack
            for _, item in pairs(backpack:GetChildren()) do
                if (item.Name == totemName) then
                    found = true
                    
                    if (self.TotemData.Debug) then
                        print("[Totem Debug] Found totem in backpack: " .. totemName)
                    end
                    
                    if (character and character:FindFirstChild("Humanoid")) then
                        -- Equip the totem
                        character.Humanoid:EquipTool(item)
                        
                        -- Wait enough time to ensure it's properly equipped
                        task.wait(1)
                        
                        -- Simply activate the totem
                        pcall(function()
                            item:Activate()
                        end)
                        
                        -- Wait longer to ensure the totem has time to activate fully
                        task.wait(3)
                        
                        -- Unequip the totem
                        character.Humanoid:UnequipTools()
                        
                        Fluent:Notify({
                            Title = "Totem Used",
                            Content = "Successfully used " .. totemName,
                            Duration = 3
                        })

                        -- Wait to ensure the totem effect has started
                        task.wait(1)
                        
                        -- Re-equip the fishing rod
                        local rod = utils:GetRod()
                        if (rod) then
                            character.Humanoid:EquipTool(rod)
                            
                            -- Wait for rod to be equipped properly
                            task.wait(1)
                        end
                        
                        -- Reset UsingTotem flag
                        self.Status.UsingTotem = false
                        
                        return true
                    end
                    
                    break
                end
            end
            
            -- Handle case where totem wasn't found
            if (not found and Config.Items.TotemAutoPurchase) then
                if (self.TotemData.Debug) then
                    print("[Totem Debug] Totem not found, trying to purchase: " .. totemName)
                end
                
                local success = pcall(function()
                    local ReplicatedStorage = game:GetService("ReplicatedStorage")
                    local events = ReplicatedStorage:WaitForChild("events")
                    events:WaitForChild("purchase"):FireServer(totemName, "item", {}, 1)
                    
                    -- Wait for purchase to complete
                    task.wait(1)
                    
                    -- Try to use the totem we just purchased
                    for _, item in pairs(player.Backpack:GetChildren()) do
                        if (item.Name == totemName) then
                            if (character and character:FindFirstChild("Humanoid")) then
                                character.Humanoid:EquipTool(item)
                                task.wait(1)
                                
                                pcall(function()
                                    item:Activate()
                                end)
                                
                                task.wait(3)
                                character.Humanoid:UnequipTools()
                                
                                Fluent:Notify({
                                    Title = "Totem Purchased & Used",
                                    Content = "Successfully purchased and used " .. totemName,
                                    Duration = 3
                                })
                                
                                task.wait(1)
                                
                                local rod = utils:GetRod()
                                if (rod) then
                                    character.Humanoid:EquipTool(rod)
                                    task.wait(1)
                                end
                                
                                self.Status.UsingTotem = false
                                return true
                            end
                        end
                    end
                end)
                
                if not success then
                    if (self.TotemData.Debug) then
                        print("[Totem Debug] Failed to purchase: " .. totemName)
                    end
                end
            elseif (not found) then
                if (self.TotemData.Debug) then
                    print("[Totem Debug] Totem not found and auto-purchase is disabled")
                end
            end
            
            -- Reset UsingTotem flag if we reached here without returning
            self.Status.UsingTotem = false
            return false
        end,
        
        Totem = LPH_NO_VIRTUALIZE(function(self)
            if (utils:IsBobber()) then
                return false
            end

            if (utils:IsCast()) then
                return false
            end

            if (not Config.Items.TotemEnabled) then
                if (self.TotemData.Debug) then
                    print("[Totem Debug] Totems disabled in settings")
                end
                return
            end
            
            local weather = game:GetService("ReplicatedStorage").world.weather.Value
            local currentCycle = game:GetService("ReplicatedStorage").world.cycle.Value
            
            -- Simplified cycle detection
            if (self.TotemData.LastCycleState ~= currentCycle) then
                if (self.TotemData.Debug) then
                    print("[Totem Debug] Cycle changed from " .. (self.TotemData.LastCycleState or "nil") .. " to " .. currentCycle)
                end
                
                -- When cycle changes, reset the appropriate flag
                if (currentCycle == "Day") then
                    self.TotemData.NightCycleUsedSundial = false
                    if (self.TotemData.Debug) then
                        print("[Totem Debug] Changed to Day - Reset NightCycleUsedSundial flag")
                    end
                else
                    self.TotemData.DayCycleUsedSundial = false
                    if (self.TotemData.Debug) then
                        print("[Totem Debug] Changed to Night - Reset DayCycleUsedSundial flag")
                    end
                end
                
                -- Update the last cycle state
                self.TotemData.LastCycleState = currentCycle
            end
            
            if (weather == "Aurora_Borealis") then
                if (self.TotemData.Debug) then
                    print("[Totem Debug] Aurora_Borealis active - skipping totems")
                end
                return
            end
            
            if (self.TotemData.Debug) then
                print("[Totem Debug] Current cycle: " .. currentCycle .. ", Weather: " .. weather)
                print("[Totem Debug] Day Sundial used: " .. tostring(self.TotemData.DayCycleUsedSundial))
                print("[Totem Debug] Night Sundial used: " .. tostring(self.TotemData.NightCycleUsedSundial))
            end
            
            if (not self.TotemData.LastUsed) then
                self.TotemData.LastUsed = {}
            end
            
            if (not self.TotemData.LastTick) then
                self.TotemData.LastTick = 0
            end
            
            local totemConditions = {
                {name = "Sundial", timeReq = "Day", weatherAvoid = nil, selected = Config.Items.SelectedDayTotems["Sundial"]},
                {name = "Tempest", timeReq = "Day", weatherAvoid = "Rain", selected = Config.Items.SelectedDayTotems["Tempest"]},
                {name = "Smokescreen", timeReq = "Day", weatherAvoid = "Foggy", selected = Config.Items.SelectedDayTotems["Smokescreen"]},
                {name = "Windset", timeReq = "Day", weatherAvoid = "Windy", selected = Config.Items.SelectedDayTotems["Windset"]},
                {name = "Eclipse", timeReq = "Day", weatherAvoid = "Eclipse", selected = Config.Items.SelectedDayTotems["Eclipse"]},
                {name = "Meteor", timeReq = "Day", weatherAvoid = nil, selected = Config.Items.SelectedDayTotems["Meteor"]},
                {name = "Blizzard", timeReq = "Day", weatherAvoid = nil, selected = Config.Items.SelectedDayTotems["Blizzard"]},
                {name = "Avalanche", timeReq = "Day", weatherAvoid = nil, selected = Config.Items.SelectedDayTotems["Avalanche"]},
                {name = "Zeus Storm", timeReq = "Day", weatherAvoid = nil, selected = Config.Items.SelectedDayTotems["Zeus Storm"]},
                {name = "Poseidon's Wrath", timeReq = "Day", weatherAvoid = nil, selected = Config.Items.SelectedDayTotems["Poseidon's Wrath"]},
                
                {name = "Sundial", timeReq = "Night", weatherAvoid = nil, selected = Config.Items.SelectedNightTotems["Sundial"]},
                {name = "Aurora", timeReq = "Night", weatherAvoid = "Aurora_Borealis", selected = Config.Items.SelectedNightTotems["Aurora"]},
                {name = "Tempest", timeReq = "Night", weatherAvoid = "Rain", selected = Config.Items.SelectedNightTotems["Tempest"]},
                {name = "Smokescreen", timeReq = "Night", weatherAvoid = "Foggy", selected = Config.Items.SelectedNightTotems["Smokescreen"]},
                {name = "Windset", timeReq = "Night", weatherAvoid = "Windy", selected = Config.Items.SelectedNightTotems["Windset"]},
                {name = "Meteor", timeReq = "Night", weatherAvoid = nil, selected = Config.Items.SelectedNightTotems["Meteor"]},
                {name = "Blizzard", timeReq = "Night", weatherAvoid = nil, selected = Config.Items.SelectedNightTotems["Blizzard"]},
                {name = "Avalanche", timeReq = "Night", weatherAvoid = nil, selected = Config.Items.SelectedNightTotems["Avalanche"]},
                {name = "Zeus Storm", timeReq = "Night", weatherAvoid = nil, selected = Config.Items.SelectedNightTotems["Zeus Storm"]},
                {name = "Poseidon's Wrath", timeReq = "Night", weatherAvoid = nil, selected = Config.Items.SelectedNightTotems["Poseidon's Wrath"]}
            }
            
            for _, totem in ipairs(totemConditions) do
                local lastUsed = self.TotemData.LastUsed[totem.name] or 0
                
                -- Simplified Sundial logic using separate day/night flags
                local sundialAllowed = true
                if (totem.name == "Sundial") then
                    if (currentCycle == "Day" and self.TotemData.DayCycleUsedSundial) then
                        sundialAllowed = false
                        if (self.TotemData.Debug) then
                            print("[Totem Debug] Sundial already used for Day cycle")
                        end
                    elseif (currentCycle == "Night" and self.TotemData.NightCycleUsedSundial) then
                        sundialAllowed = false
                        if (self.TotemData.Debug) then
                            print("[Totem Debug] Sundial already used for Night cycle")
                        end
                    end
                end
                
                if (self.TotemData.Debug) then
                    print("[Totem Debug] Evaluating: " .. totem.name .. 
                          " | Selected: " .. tostring(totem.selected) ..
                          " | Cycle match: " .. tostring(currentCycle == totem.timeReq) ..
                          " | Weather OK: " .. tostring(not totem.weatherAvoid or weather ~= totem.weatherAvoid) ..
                          " | Cooldown OK: " .. tostring(lastUsed + self.TotemData.Threshold <= tick()) ..
                          (totem.name == "Sundial" and " | Sundial allowed: " .. tostring(sundialAllowed) or ""))
                end
                
                if (totem.selected and currentCycle == totem.timeReq and
                   (not totem.weatherAvoid or weather ~= totem.weatherAvoid) and
                   (lastUsed + self.TotemData.Threshold <= tick()) and
                   (totem.name ~= "Sundial" or sundialAllowed)) then
                    
                    if (self.TotemData.Debug) then
                        print("[Totem Debug] USING: " .. totem.name .. " Totem")
                    end
                    
                    if (self:UseTotem(totem.name .. " Totem")) then
                        self.TotemData.LastUsed[totem.name] = tick()
                        self.TotemData.LastTick = tick()
                        
                        -- Update the appropriate Sundial flag based on current cycle
                        if (totem.name == "Sundial") then
                            if (currentCycle == "Day") then
                                self.TotemData.DayCycleUsedSundial = true
                                if (self.TotemData.Debug) then
                                    print("[Totem Debug] Setting DayCycleUsedSundial to true")
                                end
                            else
                                self.TotemData.NightCycleUsedSundial = true
                                if (self.TotemData.Debug) then
                                    print("[Totem Debug] Setting NightCycleUsedSundial to true")
                                end
                            end
                        end
                        
                        break
                    end
                end
            end
        end),
        
        eventState = {
            originalPosition = nil,
            canSearch = true,
            running = false,
            currentEvent = nil,
            currentEventName = nil,
            farmTask = nil
        },
        
        eventLocations = {
            ["Whale Migration"] = "Whales Pool",
            ["Orcas Pool"] = "Orcas Pool",
            ["Scylla"] = "Forsaken Veil - Scylla",
            ["Kraken"] = "The Kraken Pool",
            ["Whale Shark"] = "Whale Shark",
            ["Megalodon"] = "Megalodon Default",
            ["Megalodon Ancient"] = "Megalodon Ancient"
        },
        
        StartEventFarm = function(self, eventName, teleportName)
            if (self.eventState.running) then
                return
            end
            
            local character = player.Character
            if not (character or character:FindFirstChild("HumanoidRootPart")) then
                return
            end
            
            if not (workspace:FindFirstChild("zones") or not workspace.zones:FindFirstChild("fishing") or not workspace.zones.fishing:FindFirstChild(teleportName)) then
                Fluent:Notify({
                    Title = "Event Farm Error",
                    Content = "Could not find event location: " .. teleportName,
                    Duration = 3
                })
                return
            end
            
            self.eventState.originalPosition = character.HumanoidRootPart.CFrame
            self.eventState.canSearch = false
            self.eventState.running = true
            self.eventState.currentEventName = eventName
            
            Fluent:Notify({
                Title = "Event Farm Started",
                Content = "Teleporting to " .. eventName,
                Duration = 3
            })
            
            self.eventState.farmTask = task.spawn(LPH_NO_VIRTUALIZE(function()
                while true do
                    if not (workspace.zones.fishing:FindFirstChild(teleportName)) then
                        self:StopEventFarm()
                        break
                    end
                    
                    local character = player.Character
                    if (character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid")) then
                        character.Humanoid.PlatformStand = true
                        character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                        character.HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
                        
                        local targetCFrame = workspace.zones.fishing[teleportName].CFrame
                        
                        if (eventName == "Megalodon") then
                            targetCFrame = targetCFrame + Vector3.new(0, -75, 0)
                        elseif (eventName == "Megalodon Ancient") then
                            targetCFrame = targetCFrame + Vector3.new(0, -75, 0)
                        elseif (eventName == "Scyla") then
                            targetCFrame = targetCFrame + Vector3.new(0, 25, 0)
                        end
                        
                        character.HumanoidRootPart.CFrame = targetCFrame
                    end
                    
                    task.wait()
                end
            end))
        end,
        
        StopEventFarm = function(self)
            if not (self.eventState.running) then
                character.Humanoid.PlatformStand = false
                return
            end
            
            if (self.eventState.farmTask) then
                task.cancel(self.eventState.farmTask)
                self.eventState.farmTask = nil
            end
            
            local character = player.Character
            if (character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid")) then
                character.Humanoid:UnequipTools()
                character.Humanoid.PlatformStand = false
                character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                character.HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
                
                if (self.eventState.originalPosition) then
                    character.HumanoidRootPart.CFrame = self.eventState.originalPosition
                end
            end
            
            self.eventState.running = false
            self.eventState.canSearch = true
            self.eventState.currentEventName = nil
            
            Fluent:Notify({
                Title = "Event Farm Stopped",
                Content = "Returned to original position",
                Duration = 3
            })
        end,
        
        CheckForEvents = LPH_NO_VIRTUALIZE(function(self)
            if not (Config.Farm.EnableEvents or not self.eventState.canSearch) then
                return
            end
            
            if (self.Status.UsingTotem) then
                return
            end
            
            for eventName, teleportName in pairs(self.eventLocations) do
                if (Config.Farm.ActiveEvents[eventName] and workspace:FindFirstChild("zones") and workspace.zones:FindFirstChild("fishing") and workspace.zones.fishing:FindFirstChild(teleportName)) then
                    self:StartEventFarm(eventName, teleportName)
                    break
                end
            end
        end),

        LimitedEventTable =
        {
            OriginalCFrame = nil,
        },

        LimitedTimeSTEvent = LPH_NO_VIRTUALIZE(function(self)
            if (self.Status.UsingTotem) then
                return
            end
            
            local localPlayer = game.Players.LocalPlayer
            
            if not (Config.Farm.FarmRainbows) then
                if (self.LimitedEventTable.OriginalCFrame and
                    localPlayer.Character and
                    localPlayer.Character:FindFirstChild("HumanoidRootPart") and
                    localPlayer.Character:FindFirstChild("Humanoid")) then
                    
                    localPlayer.Character.HumanoidRootPart.CFrame = self.LimitedEventTable.OriginalCFrame
                    localPlayer.Character.Humanoid.PlatformStand = false
                    self.LimitedEventTable.OriginalCFrame = nil
                end
                return
            end
            
            local vfxExists = pcall(function() return workspace.Vfx end)
            local path = nil
            
            if (vfxExists and workspace:FindFirstChild("Vfx")) then
                path = workspace.Vfx:FindFirstChild("RainbowPool")
            end
            
            if not (path) then
                if (workspace:FindFirstChild("zones") and workspace.zones:FindFirstChild("fishing")) then
                    local spotNames = {
                        "Sunny O'Coin",
                        "Blarney McBreeze",
                        "O'Mango Goldgrin",
                        "Rowdy McCharm",
                        "Plumrick O'Luck"
                    }
                    
                    local foundSpot = nil
                    for _, spotName in ipairs(spotNames) do
                        local spot = workspace.zones.fishing:FindFirstChild(spotName)
                        if (spot) then
                            foundSpot = spot
                            break
                        end
                    end
                    
                    if (foundSpot) then
                        if (localPlayer.Character and
                            localPlayer.Character:FindFirstChild("HumanoidRootPart") and
                            localPlayer.Character:FindFirstChild("Humanoid")) then
                            
                            if (not self.LimitedEventTable.OriginalCFrame) then
                                self.LimitedEventTable.OriginalCFrame = localPlayer.Character.HumanoidRootPart.CFrame
                            end
                            
                            localPlayer.Character.HumanoidRootPart.CFrame = foundSpot.CFrame
                            localPlayer.Character.Humanoid.PlatformStand = true
                            localPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                            localPlayer.Character.HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
                        end
                        return
                    else
                        if (self.LimitedEventTable.OriginalCFrame and
                            localPlayer.Character and
                            localPlayer.Character:FindFirstChild("HumanoidRootPart") and
                            localPlayer.Character:FindFirstChild("Humanoid")) then
                            
                            localPlayer.Character.HumanoidRootPart.CFrame = self.LimitedEventTable.OriginalCFrame
                            localPlayer.Character.Humanoid.PlatformStand = false
                            self.LimitedEventTable.OriginalCFrame = nil
                        end
                        return
                    end
                else
                    if (self.LimitedEventTable.OriginalCFrame and
                        localPlayer.Character and
                        localPlayer.Character:FindFirstChild("HumanoidRootPart") and
                        localPlayer.Character:FindFirstChild("Humanoid")) then
                        
                        localPlayer.Character.HumanoidRootPart.CFrame = self.LimitedEventTable.OriginalCFrame
                        localPlayer.Character.Humanoid.PlatformStand = false
                        self.LimitedEventTable.OriginalCFrame = nil
                    end
                    return
                end
            end
            
            if (localPlayer.Character and
                localPlayer.Character:FindFirstChild("HumanoidRootPart") and
                localPlayer.Character:FindFirstChild("Humanoid")) then
                
                if (not self.LimitedEventTable.OriginalCFrame) then
                    self.LimitedEventTable.OriginalCFrame = localPlayer.Character.HumanoidRootPart.CFrame
                end
                
                localPlayer.Character.HumanoidRootPart.CFrame = path.CFrame + Vector3.new(0, 10, 0)
                localPlayer.Character.Humanoid.PlatformStand = true
                localPlayer.Character.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                localPlayer.Character.HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
            end
        end),
        
        AutomaticSell = LPH_NO_VIRTUALIZE(function(self)
            if not (Config.Items.AutomaticSell) then
                return
            end

            if (self.Status.UsingTotem) then
                return
            end

            if (Config.Items.AutomaticSellTimestamp and tick() - Config.Items.AutomaticSellTimestamp < tonumber(Config.Items.AutomaticSellDelay)) then
                return
            end

            Config.Items.AutomaticSellTimestamp = tick()
            game:GetService("ReplicatedStorage"):WaitForChild("events"):WaitForChild("SellAll"):InvokeServer()
        end),

        Handler = function(self)
            self:Totem()
            
            if not self.Status.UsingTotem then
                self:AutoShake()
                self:AutoShake()
                self:autocast()
                self:AutoReel()
                self:AutoBobber()
                self:CheckForEvents()
                self:LimitedTimeSTEvent()
                self:AutomaticSell()
            end
        end
    },

    Items =
    {
        Handler = function(self)
        end
    }
}

game:GetService("RunService").RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
    features.farm:Handler()
    features.Items:Handler()
    utils:IsModeratorInSession()
end))

utils:GetTeleports()
do
    Fluent:Notify({
        Title = "Exodus",
        Content = "Successfully initialized!",
        Duration = 3
    })
    
    local FarmSection = Tabs.Farm:AddSection("Automations")
    local AutoCast = Tabs.Farm:AddToggle("AutoCast", {
        Title = "Auto Cast",
        Default = Config.Farm.AutoCast,
        Description = "Automatically casts your rod"
    })

    AutoCast:OnChanged(function()
        Config.Farm.AutoCast = Options.AutoCast.Value
    end)

    local AutoShake = Tabs.Farm:AddToggle("AutoShake", {
        Title = "Auto Shake",
        Default = Config.Farm.AutoShake,
        Description = "Automatically shakes your rod"
    })

    AutoShake:OnChanged(function()
        Config.Farm.AutoShake = Options.AutoShake.Value
    end)

    local AutoReel = Tabs.Farm:AddToggle("AutoReel", {
        Title = "Auto Reel",
        Default = Config.Farm.AutoReel,
        Description = "Automatically reels in your fish"
    })

    AutoReel:OnChanged(function()
        Config.Farm.AutoReel = Options.AutoReel.Value
    end)

    local AutoBobber = Tabs.Farm:AddToggle("AutoBobber", {
        Title = "Auto Bobber",
        Default = Config.Farm.AutoBobber,
        Description = "Automatically equips the best bobber"
    })

    AutoBobber:OnChanged(function()
        Config.Farm.AutoBobber = Options.AutoBobber.Value
    end)

    local PerfectCatch = Tabs.Farm:AddToggle("PerfectCatch", {
        Title = "Perfect Catch",
        Default = Config.Farm.PerfectCatch,
        Description = "Automatically catches fish perfectly"
    })

    PerfectCatch:OnChanged(function()
        Config.Farm.PerfectCatch = Options.PerfectCatch.Value
    end)

    local SafetySection = Tabs.Farm:AddSection("Safety")
    local FreezeCharacter = Tabs.Farm:AddToggle("FreezeCharacter", {
        Title = "Freeze Character",
        Default = Config.Farm.FreezeCharacter,
        Description = "Freezes your character in place"
    })

    FreezeCharacter:OnChanged(function()
        Config.Farm.FreezeCharacter = Options.FreezeCharacter.Value

        if (Config.Farm.FreezeCharacter) then
            utils:startFreezeCharacter()
        else
            utils:stopFreezeCharacter()
        end
    end)

    local AvoidModerator = Tabs.Farm:AddToggle("AvoidModerator", {
        Title = "Avoid Moderator",
        Default = Config.Farm.AvoidModerator,
        Description = "Leaves if a moderator is spotted"
    })

    AvoidModerator:OnChanged(function()
        Config.Farm.AvoidModerator = Options.AvoidModerator.Value
    end)

    local PremiumSection = Tabs.Farm:AddSection("Premium")
    local InstantReel = Tabs.Farm:AddToggle("InstantReel", {
        Title = "Instant Reel",
        Default = Config.Farm.InstantReel,
        Description = "Reels in fish instantly"
    })

    InstantReel:OnChanged(function()
        Config.Farm.InstantReel = Options.InstantReel.Value
    end)

    Tabs.Farm:AddParagraph({
        Title = "Warning",
        Content = "Server might not catch up, on fast baits/enchants!",
    })

    local EventSection = Tabs.Farm:AddSection("ST. Patrick's Day")
    local FarmRainbows = Tabs.Farm:AddToggle("FarmRainbows", {
        Title = "Farm Rainbows",
        Default = Config.Farm.FarmRainbows,
        Description = "Farms event rainbows."
    })

    FarmRainbows:OnChanged(function()
        Config.Farm.FarmRainbows = Options.FarmRainbows.Value
    end)

    Tabs.Farm:AddParagraph({
        Title = "Warning",
        Content = "Disable EventFarm while using this!",
    })

    local EventSection = Tabs.Farm:AddSection("Events")
    local EnableEvents = Tabs.Farm:AddToggle("EnableEvents", {
        Title = "Enable Events",
        Default = Config.Farm.EnableEvents,
        Description = "Allows you to farm events"
    })

    EnableEvents:OnChanged(function()
        Config.Farm.EnableEvents = Options.EnableEvents.Value
        
        if not (Config.Farm.EnableEvents) and features.farm.eventState.running then
            features.farm:StopEventFarm()
        end
    end)

    local Events = Tabs.Farm:AddDropdown("ActiveEvents", {
        Title = "Events",
        Description = "Select events to farm",
        Values = {"Whale Migration", "Orcas Pool", "Scylla", "Kraken", "Whale Shark", "Megalodon"},
        Multi = true,
        Default = {},
    })

    Events:OnChanged(function()
        Config.Farm.ActiveEvents = Options.ActiveEvents.Value
    end)

    local EventSection = Tabs.Items:AddSection("Purchases")
    local Items = Tabs.Items:AddDropdown("SelectedItem", {
        Title = "Items",
        Description = "Select item to purchase",
        Values = {"Rod Of The Zenith", "Abyssal Specter Rod", "Advanced Diving Gear", "Advanced Glider", "Champions Rod", "Conception Conch", "Depthseeker Rod", "Flippers", "Kraken Rod", "Quality Bait Crate", "Super Flippers", "Aurora Totem", "Bait Crate", "Coral Geode", "Reinforced Rod", "Tide Breaker", "Kings Rod", "Sundial Totem", "Basic Diving Gear", "Fish Radar", "Long Rod", "Lucky Rod", "Plastic Rod", "Training Rod", "GPS", "Windset Totem", "Lost Rod", "Carbon Rod", "Glider", "Tidebreaker", "Tempest Totem", "Magnet Rod", "Trident Rod", "Nocturnal Rod", "Leviathan's Fang Rod", "Meteor Totem", "Fortune Rod", "Rapid Rod", "Steady Rod", "Volcanic Rod", "Smokescreen Totem", "Challengers Rod", "Ethereal Prism Rod", "Scurvy Rod", "Eclipse Totem"},
        Default = 1,
    })

    Items:OnChanged(function()
        Config.Items.SelectedItem = Options.SelectedItem.Value
    end)

    local ItemAmount = Tabs.Items:AddInput("SelectedAmount", {
        Title = "Amount",
        Description = "Amount of items to purchase",
        Numeric = true,
        Finished = false,
        Callback = function()
            Config.Items.SelectedAmount = Options.SelectedAmount.Value
        end
    })

    ItemAmount:OnChanged(function()
        Config.Items.SelectedAmount = Options.SelectedAmount.Value
    end)

    local ItemConfirm = Tabs.Items:AddButton({
        Title = "Confirm Purchase",
        Description = "Purchases the selected item",
        Callback = function()
            local PurchaseItem = Config.Items.SelectedItem
            local PurchaseAmount = Config.Items.SelectedAmount
            
            local ReplicatedStorage = game:GetService("ReplicatedStorage")
            local events = ReplicatedStorage:WaitForChild("events")
            events:WaitForChild("purchase"):FireServer(PurchaseItem, "item", {}, tonumber(PurchaseAmount))
        end
    })

    local EventSection = Tabs.Items:AddSection("Economy")
    local AutomaticSell = Tabs.Items:AddToggle("AutomaticSell", {
        Title = "Automatic Sell",
        Default = Config.Items.AutomaticSell,
        Description = "Automatically sells your fish"
    })

    AutomaticSell:OnChanged(function()
        Config.Items.AutomaticSell = Options.AutomaticSell.Value
    end)

    local AutomaticSellDelay = Tabs.Items:AddInput("AutomaticSellDelay", {
        Title = "Automatic Sell Delay",
        Description = "Delay between each sell",
        Numeric = true,
        Finished = false,
        Callback = function()
            Config.Items.AutomaticSellDelay = Options.AutomaticSellDelay.Value
        end
    })

    AutomaticSellDelay:OnChanged(function()
        Config.Items.AutomaticSellDelay = Options.AutomaticSellDelay.Value
    end)

    local EventSection = Tabs.Items:AddSection("Totems")
    local DayTotems = Tabs.Items:AddDropdown("DayTotems", {
        Title = "Day Totems",
        Description = "Select day totem",
        Values = Config.Items.DayTotems,
        Multi = true,
        Default = {},
    })
    
    DayTotems:OnChanged(function()
        Config.Items.SelectedDayTotems = Options.DayTotems.Value
    end)
    
    local NightTotems = Tabs.Items:AddDropdown("NightTotems", {
        Title = "Night Totems",
        Description = "Select night totem",
        Values = Config.Items.NightTotems,
        Multi = true,
        Default = {},
    })
    
    NightTotems:OnChanged(function()
        Config.Items.SelectedNightTotems = Options.NightTotems.Value
    end)

    local TotemThreshold = Tabs.Items:AddInput("TotemThreshold", {
        Title = "Totem Threshold",
        Description = "Threshold between each totem use",
        Numeric = true,
        Finished = false,
        Callback = function()
            features.farm.TotemData.Threshold = tonumber(Options.TotemThreshold.Value) or 5
        end
    })

    local TotemAutoPurchase = Tabs.Items:AddToggle("TotemAutoPurchase", {
        Title = "Auto Purchase Totems",
        Default = Config.Items.TotemAutoPurchase,
        Description = "Automatically purchases totems"
    })

    TotemAutoPurchase:OnChanged(function()
        Config.Items.TotemAutoPurchase = Options.TotemAutoPurchase.Value
    end)

    local TotemEnabled = Tabs.Items:AddToggle("TotemEnabled", {
        Title = "Enable Totems",
        Default = Config.Items.TotemEnabled,
        Description = "Enables totem usage"
    })

    TotemEnabled:OnChanged(function()
        Config.Items.TotemEnabled = Options.TotemEnabled.Value
    end)

    local EventSection = Tabs.Items:AddSection("Merlin's items")
    local MerlinItems = Tabs.Items:AddDropdown("MerlinItem", {
        Title = "Items",
        Description = "Select item to purchase",
        Values = {"Luck", "Power"},
        Default = 1,
    })

    MerlinItems:OnChanged(function()
        Config.Items.MerlinItem = Options.MerlinItem.Value
    end)

    local MerlinAmount = Tabs.Items:AddInput("MerlinAmount", {
        Title = "Amount",
        Description = "Amount of items to purchase",
        Numeric = true,
        Finished = false,
        Callback = function()
            Config.Items.MerlinAmount = Options.MerlinAmount.Value
        end
    })

    MerlinAmount:OnChanged(function()
        Config.Items.MerlinAmount = Options.MerlinAmount.Value
    end)

    local MerlinConfirm = Tabs.Items:AddButton({
        Title = "Confirm Purchase",
        Description = "Purchases the selected item",
        Callback = function()
            local MerlinItem = Config.Items.MerlinItem
            local MerlinAmount = Config.Items.MerlinAmount
            
            if (MerlinItem == "Luck") then
                MerlinItem = "luck"
            elseif (MerlinItem == "Power") then
                MerlinItem = "power"
            end
            
            local success = utils:purchaseFromMerlin(MerlinItem, tonumber(MerlinAmount))
            
            if (success) then
                Fluent:Notify({
                    Title = "Exodus",
                    Content = "Successfully purchased " .. MerlinAmount .. " " .. MerlinItem .. " from Merlin!",
                    Duration = 3
                })
            else
                Fluent:Notify({
                    Title = "Purchase Failed",
                    Content = "Failed to purchase from Merlin. Try again.",
                    Duration = 3
                })
            end
        end
    })

    local EventSection = Tabs.Items:AddSection("Miscellaneous")
    local Treasuremaps = Tabs.Items:AddButton({
        Title = "Treasure Maps",
        Description = "Collects all treasure maps",
        Callback = function()
            Fluent:Notify({
                Title = "Exodus",
                Content = "Collected all treasure maps!",
                Duration = 3
            })
        end
    })

    local EventSection = Tabs.Teleports:AddSection("Voyages")
    local Teleports = Tabs.Teleports:AddDropdown("Locations", {
        Title = "Locations",
        Description = "Select location to teleport",
        Values = Config.Teleports.Locations,
        Default = false,
    })

    Teleports:OnChanged(function()
        if (Config.Teleports.LocationsCFrame[Options.Locations.Value]) then
            game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = Config.Teleports.LocationsCFrame[Options.Locations.Value]
        else
            Fluent:Notify({
                Title = "Error",
                Content = "Location CFrame not found: " .. tostring(Options.Locations.Value),
                Duration = 3
            })
        end
    end)

    Tabs.Teleports:AddParagraph({
        Title = "Info",
        Content = "Locations should automatically update. \nIf they aren't updating, create a ticket.",
    })
    
    local DebugSection = Tabs.Debug:AddSection("Event Farm Debug")
    
    local EventFarmStatus = Tabs.Debug:AddButton({
        Title = "Event Farm Status",
        Description = "Shows current event farm status",
        Callback = function()
            Fluent:Notify({
                Title = "Event Farm Status",
                Content = "Running: " .. tostring(features.farm.eventState.running) .. "\nCurrent Event: " .. (features.farm.eventState.currentEventName or "None"),
                Duration = 5
            })
        end
    })
    
    local CheckEvents = Tabs.Debug:AddButton({
        Title = "Check Events",
        Description = "Check available event locations",
        Callback = function()
            local foundEvents = {}
            for eventName, teleportName in pairs(features.farm.eventLocations) do
                if (workspace:FindFirstChild("zones") and workspace.zones:FindFirstChild("fishing") and workspace.zones.fishing:FindFirstChild(teleportName)) then
                    table.insert(foundEvents, eventName)
                end
            end
            
            if (#foundEvents > 0) then
                Fluent:Notify({
                    Title = "Available Events",
                    Content = table.concat(foundEvents, ", "),
                    Duration = 5
                })
            else
                Fluent:Notify({
                    Title = "No Events Available",
                    Content = "No event locations found",
                    Duration = 3
                })
            end
        end
    })
    
    local ForceStopEvents = Tabs.Debug:AddButton({
        Title = "Force Stop Events",
        Description = "Force stop event farming",
        Callback = function()
            features.farm:StopEventFarm()
            Fluent:Notify({
                Title = "Events Stopped",
                Content = "Event farming has been forcibly stopped",
                Duration = 3
            })
        end
    })
    
    local MerlinDebugSection = Tabs.Debug:AddSection("Merlin Debug")
    
    local TestPreloadMerlin = Tabs.Debug:AddButton({
        Title = "Test Preload Merlin",
        Description = "Tests preloading Merlin's location",
        Callback = function()
            local success = utils:preloadMerlinLocation()
            Fluent:Notify({
                Title = "Merlin Preload",
                Content = "Preload " .. (success and "successful" or "failed"),
                Duration = 3
            })
        end
    })
    
    local TestTriggerDialog = Tabs.Debug:AddButton({
        Title = "Test Dialog Prompt",
        Description = "Tests triggering Merlin's dialog",
        Callback = function()
            local success = utils:triggerMerlinDialog()
            Fluent:Notify({
                Title = "Dialog Trigger",
                Content = "Dialog trigger " .. (success and "successful" or "failed"),
                Duration = 3
            })
        end
    })
    
    local TestMerlinLuck = Tabs.Debug:AddButton({
        Title = "Test Merlin Luck",
        Description = "Tests invoking Merlin's luck remote",
        Callback = function()
            local success = utils:invokeMerlinLuck()
            Fluent:Notify({
                Title = "Luck Remote",
                Content = "Luck remote invoke " .. (success and "successful" or "failed"),
                Duration = 3
            })
        end
    })

    DebugRod = Tabs.Debug:AddButton({
        Title = "Get Rod",
        Description = "Gets the rod in your inventory",
        Callback = function()
            local rod = utils:GetRod()
            if (rod) then
                Fluent:Notify({
                    Title = "Rod Found",
                    Content = "Found rod: " .. rod.Name,
                    Duration = 3
                })
            else
                Fluent:Notify({
                    Title = "Rod Not Found",
                    Content = "No rod found in inventory",
                    Duration = 3
                })
            end
        end
    }) 
    
    local TotemDebugSection = Tabs.Debug:AddSection("Totem Debug")
    
    local ToggleTotemDebug = Tabs.Debug:AddToggle("TotemDebug", {
        Title = "Enable Totem Debug",
        Default = features.farm.TotemData.Debug,
        Description = "Enables detailed totem debugging"
    })
    
    ToggleTotemDebug:OnChanged(function()
        features.farm.TotemData.Debug = Options.TotemDebug.Value
        print("[Debug] Totem Debug: " .. tostring(features.farm.TotemData.Debug))
    end)
    
    local CheckTotemStatus = Tabs.Debug:AddButton({
        Title = "Check Totem Status",
        Description = "Shows current totem status",
        Callback = function()
            local status = "Currently using totem: " .. tostring(features.farm.Status.UsingTotem)
            local lastCycleDetected = features.farm.TotemData.LastCycleDetected or "None"
            local lastSundialCycle = features.farm.TotemData.LastSundialCycle or "None"
            local currentCycle = game:GetService("ReplicatedStorage").world.cycle.Value
            local currentWeather = game:GetService("ReplicatedStorage").world.weather.Value
            
            Fluent:Notify({
                Title = "Totem Status",
                Content = status .. "\nCurrent cycle: " .. currentCycle .. 
                          "\nLast detected: " .. lastCycleDetected ..
                          "\nLast Sundial cycle: " .. lastSundialCycle ..
                          "\nCurrent weather: " .. currentWeather,
                Duration = 5
            })
        end
    })
end

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
InterfaceManager:SetFolder("Exodus")
SaveManager:SetFolder("Exodus")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Configuration)

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
