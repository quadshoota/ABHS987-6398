loadstring([[
    function LPH_NO_VIRTUALIZE(f) return f end;
]])();

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

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
    Combat = Window:AddTab({Title = "Combat", Icon = "swords"}),
    Settings = Window:AddTab({Title = "Settings", Icon = "settings"}),
    Configuration = Window:AddTab({Title = "Configuration", Icon = "file"})
}

local Options = Fluent.Options

local Config = {
    Enabled = false,
    BaseParryDistance = 50,
    AdaptiveMode = true
}

local Visuals = {
    predictionUI = nil,
    successIndicator = nil,
    
    Setup = function(self)
        if (self.predictionUI) then 
            self.predictionUI:Destroy() 
        end
        
        if (self.successIndicator) then 
            self.successIndicator:Destroy() 
        end
        
        self.predictionUI = Instance.new("ScreenGui")
        self.predictionUI.Name = "PredictionBar"
        self.predictionUI.ResetOnSpawn = false
        self.predictionUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        self.predictionUI.Parent = player.PlayerGui
        
        local barContainer = Instance.new("Frame")
        barContainer.Name = "BarContainer"
        barContainer.Size = UDim2.new(0, 200, 0, 6)
        barContainer.Position = UDim2.new(0.5, -100, 0.8, 0)
        barContainer.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        barContainer.BackgroundTransparency = 0.3
        barContainer.BorderSizePixel = 0
        barContainer.Visible = false
        barContainer.Parent = self.predictionUI
        
        local barFill = Instance.new("Frame")
        barFill.Name = "BarFill"
        barFill.Size = UDim2.new(0, 0, 1, 0)
        barFill.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        barFill.BorderSizePixel = 0
        barFill.Parent = barContainer
        
        local cornerRadius = Instance.new("UICorner")
        cornerRadius.CornerRadius = UDim.new(0, 3)
        cornerRadius.Parent = barContainer
        
        local cornerRadius2 = Instance.new("UICorner")
        cornerRadius2.CornerRadius = UDim.new(0, 3)
        cornerRadius2.Parent = barFill
        
        self.successIndicator = Instance.new("ScreenGui")
        self.successIndicator.Name = "SuccessIndicator"
        self.successIndicator.ResetOnSpawn = false
        self.successIndicator.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        self.successIndicator.Parent = player.PlayerGui
        
        local flashFrame = Instance.new("Frame")
        flashFrame.Name = "SuccessFlash"
        flashFrame.Size = UDim2.new(1, 0, 1, 0)
        flashFrame.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        flashFrame.BackgroundTransparency = 1
        flashFrame.BorderSizePixel = 0
        flashFrame.Parent = self.successIndicator
    end,
    
    ShowPrediction = function(self, timeToImpact)
        local barContainer = self.predictionUI.BarContainer
        barContainer.Visible = true
        
        local barFill = barContainer.BarFill
        barFill.Size = UDim2.new(1, 0, 1, 0)
        
        local fillTween = TweenService:Create(
            barFill,
            TweenInfo.new(timeToImpact, Enum.EasingStyle.Linear),
            {Size = UDim2.new(0, 0, 1, 0)}
        )
        
        fillTween:Play()
        
        task.delay(timeToImpact + 0.1, function()
            barContainer.Visible = false
        end)
    end,
    
    ShowSuccess = function(self)
        local flash = self.successIndicator.SuccessFlash
        flash.BackgroundTransparency = 0.7
        
        TweenService:Create(
            flash,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundTransparency = 1}
        ):Play()
    end,
    
    SetupParryDetection = function(self)
        for _, remote in pairs(game:GetDescendants()) do
            if (remote:IsA("RemoteEvent") and remote.Name == "ParrySuccess") then
                remote.OnClientEvent:Connect(function(...)
                    self:ShowSuccess()
                    Combat:OnParrySuccess()
                end)
                break
            end
        end
    end
}

local Combat = {
    LastParryTime = 0,
    ParryDebounce = 0.05,
    BallHistory = {},
    SpeedToDistanceMultiplier = 0.5,
    SuccessCount = 0,
    FailCount = 0,
    LastBallSpeed = 0,
    
    CalculateParryDistance = function(self, ballSpeed)
        if (not Config.AdaptiveMode) then
            return Config.BaseParryDistance
        end
        
        local baseDistance = Config.BaseParryDistance
        local speedFactor = math.min(ballSpeed, 500) / 100  
        local speedBonus = speedFactor * self.SpeedToDistanceMultiplier * 10
        
        return baseDistance + speedBonus
    end,
    
    OnParrySuccess = function(self)
        self.SuccessCount = self.SuccessCount + 1
        
        if (self.LastBallSpeed > 0) then
            table.insert(self.BallHistory, {
                speed = self.LastBallSpeed,
                success = true
            })
            
            if (#self.BallHistory > 10) then
                table.remove(self.BallHistory, 1)
            end
            
            self:AdjustMultiplier()
        end
    end,
    
    OnParryFail = function(self)
        self.FailCount = self.FailCount + 1
        
        if (self.LastBallSpeed > 0) then
            table.insert(self.BallHistory, {
                speed = self.LastBallSpeed,
                success = false
            })
            
            if (#self.BallHistory > 10) then
                table.remove(self.BallHistory, 1)
            end
            
            self:AdjustMultiplier()
        end
    end,
    
    AdjustMultiplier = function(self)
        if (#self.BallHistory < 5) then
            return
        end
        
        local successCount = 0
        local failCount = 0
        
        for _, record in ipairs(self.BallHistory) do
            if (record.success) then
                successCount = successCount + 1
            else
                failCount = failCount + 1
            end
        end
        
        local successRate = successCount / #self.BallHistory
        
        if (successRate > 0.8) then
            self.SpeedToDistanceMultiplier = self.SpeedToDistanceMultiplier * 1.05
        elseif (successRate < 0.5) then
            self.SpeedToDistanceMultiplier = self.SpeedToDistanceMultiplier * 0.95
        end
        
        self.SpeedToDistanceMultiplier = math.min(math.max(self.SpeedToDistanceMultiplier, 0.1), 2.0)
    end,
    
    GetPing = function(self)
        return game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue() / 1000
    end,
    
    AutoParry = LPH_NO_VIRTUALIZE(function(self)
        if (not Config.Enabled) then 
            return 
        end

        local character = player.Character
        if (not character) then 
            return 
        end
        
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if (not hrp) then 
            return 
        end

        local balls = workspace:FindFirstChild("Balls")
        if (not balls) then 
            return 
        end
        
        local now = tick()
        if (now - self.LastParryTime < self.ParryDebounce) then 
            return 
        end
        
        local ping = self:GetPing()

        for _, ball in ipairs(balls:GetChildren()) do
            if (not ball:IsA("BasePart")) then 
                continue 
            end
            
            local distance = (ball.Position - hrp.Position).Magnitude
            local ballVelocity = ball.Velocity
            local ballSpeed = ballVelocity.Magnitude
            
            if (ballSpeed < 5) then
                continue
            end
            
            self.LastBallSpeed = ballSpeed
            
            local parryDistance = self:CalculateParryDistance(ballSpeed)
            
            if (distance <= parryDistance) then
                local directionToPlayer = (hrp.Position - ball.Position).Unit
                local ballDirection = ballVelocity.Unit
                local dotProduct = directionToPlayer:Dot(ballDirection)
                
                local timeEstimate = distance / (ballSpeed * dotProduct)
                timeEstimate = math.max(0.1, timeEstimate - ping)
                
                Visuals:ShowPrediction(timeEstimate)
                
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 1)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 1)
                
                self.LastParryTime = now
                
                task.delay(0.5, function()
                    if (self.LastParryTime == now) then
                        self:OnParryFail()
                    end
                end)
                
                break
            end
        end
    end)
}

local UI = {
    Setup = function(self)
        Fluent:Notify({
            Title = "Exodus",
            Content = "Adaptive Auto Parry Loaded",
            Duration = 3
        })
        
        local CombatSection = Tabs.Combat:AddSection("Auto Parry")
        
        local AutoParry = Tabs.Combat:AddToggle("AutoParry", {
            Title = "Enable Auto Parry",
            Default = Config.Enabled
        })
        
        AutoParry:OnChanged(function()
            Config.Enabled = Options.AutoParry.Value
        end)
        
        local AdaptiveMode = Tabs.Combat:AddToggle("AdaptiveMode", {
            Title = "Adaptive Distance",
            Description = "Automatically adjusts parry distance based on ball speed",
            Default = Config.AdaptiveMode
        })
        
        AdaptiveMode:OnChanged(function()
            Config.AdaptiveMode = Options.AdaptiveMode.Value
        end)
        
        local BaseDistance = Tabs.Combat:AddSlider("BaseParryDistance", {
            Title = "Base Parry Range",
            Default = Config.BaseParryDistance,
            Min = 20,
            Max = 70,
            Rounding = 0
        })
        
        BaseDistance:OnChanged(function()
            Config.BaseParryDistance = Options.BaseParryDistance.Value
        end)
        
        local StatsSection = Tabs.Combat:AddSection("Statistics")
        
        local StatsButton = Tabs.Combat:AddButton({
            Title = "Show Performance Stats",
            Callback = function()
                local successRate = 0
                if (Combat.SuccessCount + Combat.FailCount > 0) then
                    successRate = Combat.SuccessCount / (Combat.SuccessCount + Combat.FailCount) * 100
                end
                
                Fluent:Notify({
                    Title = "Parry Stats",
                    Content = string.format("Success rate: %.1f%%\nSuccesses: %d\nFails: %d\nMultiplier: %.2f", 
                        successRate, Combat.SuccessCount, Combat.FailCount, Combat.SpeedToDistanceMultiplier),
                    Duration = 5
                })
            end
        })
        
        local ResetButton = Tabs.Combat:AddButton({
            Title = "Reset Stats",
            Callback = function()
                Combat.SuccessCount = 0
                Combat.FailCount = 0
                Combat.BallHistory = {}
                Combat.SpeedToDistanceMultiplier = 0.5
                
                Fluent:Notify({
                    Title = "Stats Reset",
                    Content = "Performance tracking data has been reset",
                    Duration = 3
                })
            end
        })
        
        SaveManager:SetLibrary(Fluent)
        InterfaceManager:SetLibrary(Fluent)
        InterfaceManager:SetFolder("Exodus")
        SaveManager:SetFolder("Exodus")
        InterfaceManager:BuildInterfaceSection(Tabs.Settings)
        SaveManager:BuildConfigSection(Tabs.Configuration)
        Window:SelectTab(1)
        SaveManager:LoadAutoloadConfig()
    end
}

local Runtime = {
    Initialize = function(self)
        UI:Setup()
        Visuals:Setup()
        Visuals:SetupParryDetection()
        
        RunService.RenderStepped:Connect(LPH_NO_VIRTUALIZE(function()
            Combat:AutoParry()
        end))
    end
}

Runtime:Initialize()