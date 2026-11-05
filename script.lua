-- ==================== NAMELESS FINAL (NO LAG - NO ERROR) ====================
local repo = "https://raw.githubusercontent.com/ApparentlyZen/Obsidian-Zen/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Window = Library:CreateWindow({ Title = "NamelessWare", Footer = "lumexa", Size = UDim2.new(0, 550, 0, 400) })
local Tabs = { 
    Aim = Window:AddTab("Combat", "crosshair"), 
    Macro = Window:AddTab("Macro", "keyboard"), 
    Move = Window:AddTab("Movement", "move"), 
    Visual = Window:AddTab("ESP", "eye"), 
    Misc = Window:AddTab("Misc", "box") 
}

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local camera = workspace.CurrentCamera
local RS = game:GetService("ReplicatedStorage")

local function Notify(t, txt) pcall(function() Library:Notify({Title = t, Description = txt, Time = 3}) end) end

-- ==================== AIM ====================
local Soru = { Enabled = false, Range = 300, Target = nil, Pos = nil }
local function getTarget()
    local myHrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart"); if not myHrp then return end
    local closest, dist = nil, Soru.Range
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                local d = (p.Character.HumanoidRootPart.Position - myHrp.Position).Magnitude
                if d < dist then dist = d; closest = p.Character.HumanoidRootPart end
            end
        end
    end
    return closest
end
task.spawn(function()
    while true do
        task.wait(0.1)
        if Soru.Enabled then
            Soru.Target = getTarget()
            Soru.Pos = Soru.Target and (Soru.Target.Position + Soru.Target.AssemblyLinearVelocity * 0.12) or nil
        else
            Soru.Pos = nil
        end
    end
end)
task.spawn(function()
    task.wait(1)
    pcall(function()
        local mt = getrawmetatable(game); if not mt then return end
        local oldIndex = mt.__index; setreadonly(mt, false)
        mt.__index = function(t, k)
            if Soru.Enabled and Soru.Pos and t == lp:GetMouse() then
                if k == "Hit" then return CFrame.new(Soru.Pos) end
                if k == "Target" then return nil end
            end
            return oldIndex(t, k)
        end
        setreadonly(mt, true)
    end)
end)

-- ==================== AHK & M1 ====================
local function LoadAHK()
    local ok = pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/sykq0/Namelesssoru/refs/heads/main/ahk.lua"))() end)
    if ok then Notify("AHK", "Thành công!") else Notify("AHK", "Lỗi!") end
end

local M1Active = false
UIS.InputBegan:Connect(function(input, gp)
    if gp or not M1Active then return end
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        local myChar = lp.Character; local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart"); if not myRoot then return end
        local target, shortest = nil, 100
        for _, v in pairs(workspace:GetChildren()) do
            if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v ~= myChar then
                if v.Humanoid.Health > 0 then
                    local d = (v.HumanoidRootPart.Position - myRoot.Position).Magnitude
                    if d < shortest then shortest = d; target = v end
                end
            end
        end
        if target then
            local tool = myChar:FindFirstChildOfClass("Tool")
            if tool then
                local Net = RS:FindFirstChild("Modules") and RS.Modules:FindFirstChild("Net")
                if Net then
                    local Hit, Atk = Net:FindFirstChild("RE/RegisterHit"), Net:FindFirstChild("RE/RegisterAttack")
                    if Hit and Atk then pcall(function() Atk:FireServer(); local hD = {}; for _, p in pairs(target:GetChildren()) do if p:IsA("BasePart") then table.insert(hD, {target, p}) end end; Hit:FireServer(target:FindFirstChild("Head") or target.HumanoidRootPart, hD, {}, "1") end) end
                end
            end
        end
    end
end)

-- ==================== MOVEMENT ====================
local FlyActive, SpeedActive, AntiLavaActive = false, false, false
local flyConn, speedConn, lavaConn

local function ToggleFly(v)
    FlyActive = v; if flyConn then flyConn:Disconnect() end
    if v then flyConn = RunService.Stepped:Connect(function()
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart"); local hum = lp.Character and lp.Character:FindFirstChild("Humanoid")
        if hrp and hum then hum.PlatformStand = true; hrp.Velocity = camera.CFrame.LookVector * 50 end
    end) else if lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.PlatformStand = false end end
end

local function ToggleSpeed(v)
    SpeedActive = v; if speedConn then speedConn:Disconnect() end
    if v then speedConn = RunService.Heartbeat:Connect(function() if lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.WalkSpeed = 100 end end)
    else if lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.WalkSpeed = 16 end end
end

local function ToggleLava(v)
    AntiLavaActive = v; if lavaConn then lavaConn:Disconnect() end
    if v then lavaConn = RunService.Stepped:Connect(function() local char = lp.Character; if char then for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.CanTouch = false end end end end) end
end

-- ==================== ESP ====================
local Drawings = {}; local ESPEnabled = false
local function clearESP() for _, d in pairs(Drawings) do pcall(function() d:Remove() end) end Drawings = {} end
RunService.RenderStepped:Connect(function()
    clearESP(); if not ESPEnabled then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pos, onScreen = camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if onScreen then
                local t = Drawing.new("Text"); t.Visible = true; t.Center = true; t.Outline = true; t.Text = p.Name; t.Position = Vector2.new(pos.X, pos.Y - 30); table.insert(Drawings, t)
                local l = Drawing.new("Line"); l.Visible = true; l.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y); l.To = Vector2.new(pos.X, pos.Y); table.insert(Drawings, l)
            end
        end
    end
end)

-- ==================== BUILD UI ====================
local TabAim = Tabs.Aim:AddLeftGroupbox("Soru Aim")
TabAim:AddToggle("SoruTg", {Text="Enable Soru", Default=false, Callback=function(v) Soru.Enabled = v end})
TabAim:AddSlider("SoruRng", {Text="Range", Default=300, Min=50, Max=500, Rounding=0, Callback=function(v) Soru.Range = v end})

local TabMacro = Tabs.Macro:AddLeftGroupbox("Macro")
TabMacro:AddButton("Load AHK Soru", LoadAHK)
TabMacro:AddToggle("M1Tg", {Text="M1 Extender", Default=false, Callback=function(v) M1Active = v end})

local TabMove = Tabs.Move:AddLeftGroupbox("Movement")
TabMove:AddToggle("FlyTg", {Text="Fly", Default=false, Callback=ToggleFly})
TabMove:AddToggle("SpeedTg", {Text="Speed Hack", Default=false, Callback=ToggleSpeed})

local TabVis = Tabs.Visual:AddLeftGroupbox("ESP")
TabVis:AddToggle("ESPTg", {Text="Enable ESP", Default=false, Callback=function(v) ESPEnabled = v if not v then clearESP() end end})

local TabMisc = Tabs.Misc:AddLeftGroupbox("Misc")
TabMisc:AddToggle("LavaTg", {Text="Anti Lava", Default=false, Callback=ToggleLava})
TabMisc:AddButton("Unload Script", function() Library:Unload() end)

print("[Nameless] Loaded OK!")
