-- ==================== NAMELESS V30 FINAL (FULL CHỨC NĂNG) ====================
local repo = "https://raw.githubusercontent.com/ApparentlyZen/Obsidian-Zen/main/"
local Library = loadstring(game:HttpGet(repo .. "Library.lua"))()
local ThemeManager = loadstring(game:HttpGet(repo .. "addons/ThemeManager.lua"))()
local SaveManager = loadstring(game:HttpGet(repo .. "addons/SaveManager.lua"))()

local Options = Library.Options
local Toggles = Library.Toggles

if not isfolder("NamelessConfigs") then makefolder("NamelessConfigs") end
if not isfolder("NamelessConfigs/Fonts") then makefolder("NamelessConfigs/Fonts") end

local Window = Library:CreateWindow({
    Title = "NamelessWare",
    Footer = "lumexa on top",
    ShowCustomCursor = true,
    NotifySide = "Right",
    Size = UDim2.new(0, 600, 0, 460),
})

local Tabs = {
    Macro       = Window:AddTab("Macro", "keyboard"),
    SilentAim   = Window:AddTab("Silent Aim", "crosshair"),
    Glitch      = Window:AddTab("Glitch", "zap"),
    Movement    = Window:AddTab("Movement", "move"),
    Apparence   = Window:AddTab("Appearance", "user"),
    Misc        = Window:AddTab("Misc", "box"),
    ESP         = Window:AddTab("ESP", "eye"),
    Settings    = Window:AddTab("Settings", "settings"),
}

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local camera = workspace.CurrentCamera
local RS = game:GetService("ReplicatedStorage")
local CoreGui = game:GetService("CoreGui")

local SilentAimModule
local Soru = { Enabled = false, Range = 300, FOVRadius = 100, PredictedPosition = nil }

local function Notify(title, text) pcall(function() Library:Notify({Title = title, Description = text, Time = 3}) end) end

-- ==================== MACRO ====================
local function LoadAHK()
    local ok = pcall(function() loadstring(game:HttpGet("https://raw.githubusercontent.com/sykq0/Namelesssoru/refs/heads/main/ahk.lua"))() end)
    if ok then Notify("AHK", "Bật thành công!") else Notify("AHK", "Lỗi tải!") end
end

local M1Active = false
local function M1Extend()
    if not M1Active then return end
    local myChar = lp.Character; local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local target, shortest = nil, 100
    for _, v in pairs(workspace:GetChildren()) do
        if v:FindFirstChild("HumanoidRootPart") and v:FindFirstChild("Humanoid") and v ~= myChar then
            local hum = v.Humanoid; if hum.Health > 0 and (v:FindFirstChild("NPC") or Players:GetPlayerFromCharacter(v)) then
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
                local Hit = Net:FindFirstChild("RE/RegisterHit"); local Atk = Net:FindFirstChild("RE/RegisterAttack")
                if Hit and Atk then pcall(function() Atk:FireServer(); local hD = {}; for _, p in pairs(target:GetChildren()) do if p:IsA("BasePart") then table.insert(hD, {target, p}) end end; Hit:FireServer(target:FindFirstChild("Head") or target.HumanoidRootPart, hD, {}, "1234") end) end
            end
        end
    end
end
UserInputService.InputBegan:Connect(function(i, g) if not g and (i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch) then task.spawn(M1Extend) end end)

-- ==================== SORU AIM ====================
local function getTarget()
    local myHrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart"); if not myHrp then return nil end
    local valid = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character:FindFirstChild("Humanoid").Health > 0 then
            local d = (p.Character.HumanoidRootPart.Position - myHrp.Position).Magnitude
            if d <= Soru.Range then table.insert(valid, {HRP = p.Character.HumanoidRootPart, Dist = d}) end
        end
    end
    if #valid == 0 then return nil end
    table.sort(valid, function(a,b) return a.Dist < b.Dist end)
    return valid[1].HRP
end
task.spawn(function() while true do task.wait(0.1); if Soru.Enabled then local t = getTarget(); Soru.PredictedPosition = t and (t.Position + t.AssemblyLinearVelocity * 0.12) or nil; else Soru.PredictedPosition = nil end end end)

local UserMouse = lp:GetMouse()
task.spawn(function()
    task.wait(1); pcall(function()
        local mt = getrawmetatable(game); if not mt then return end
        local oldIndex = mt.__index; setreadonly(mt, false)
        mt.__index = function(t, k)
            if Soru.Enabled and Soru.PredictedPosition and t == UserMouse then
                if k == "Hit" then return CFrame.new(Soru.PredictedPosition) end
                if k == "Target" then return nil end
            end
            return oldIndex(t, k)
        end
        setreadonly(mt, true)
    end)
end)

-- ==================== ESP ====================
local Drawings = {}; local ESPEnabled = false
local function clearESP() for _, d in pairs(Drawings) do pcall(function() d:Remove() end) end Drawings = {} end
RunService.RenderStepped:Connect(function()
    clearESP(); if not ESPEnabled then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = p.Character.HumanoidRootPart; local pos, onScreen = camera:WorldToViewportPoint(hrp.Position)
            if onScreen then
                local t = Drawing.new("Text"); t.Visible = true; t.Center = true; t.Outline = true; t.Text = p.Name; t.Position = Vector2.new(pos.X, pos.Y - 30); table.insert(Drawings, t)
                local l = Drawing.new("Line"); l.Visible = true; l.From = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y); l.To = Vector2.new(pos.X, pos.Y); table.insert(Drawings, l)
            end
        end
    end
end)

-- ==================== PLAYER / MOVEMENT ====================
local FlyEnabled, SpeedEnabled, AntiLavaEnabled = false, false, false
local flyConn, speedConn, lavaConn
local function ToggleFly(v)
    FlyEnabled = v; if flyConn then flyConn:Disconnect() end
    if v then flyConn = RunService.Stepped:Connect(function() local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart"); local hum = lp.Character and lp.Character:FindFirstChild("Humanoid"); if hrp and hum then hum.PlatformStand = true; hrp.Velocity = camera.CFrame.LookVector * 50 end end)
    else if lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.PlatformStand = false end end
end
local function ToggleSpeed(v)
    SpeedEnabled = v; if speedConn then speedConn:Disconnect() end
    if v then speedConn = RunService.Heartbeat:Connect(function() if lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.WalkSpeed = 100 end end)
    else if lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.WalkSpeed = 16 end end
end
local function ToggleLava(v)
    AntiLavaEnabled = v; if lavaConn then lavaConn:Disconnect() end
    if v then lavaConn = RunService.Stepped:Connect(function() local char = lp.Character; if char then for _, p in pairs(char:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.CanTouch = false end end end end) end
end

-- ==================== BUILD UI ====================
local CombatTab = Tabs.SilentAim
local SA = CombatTab:AddLeftGroupbox("Soru Aim")
SA:AddToggle("EnableSoru", {Text="Enable Soru", Default=false, Callback=function(v) Soru.Enabled = v end})
SA:AddSlider("SoruRange", {Text="Range", Default=300, Min=50, Max=500, Rounding=0, Callback=function(v) Soru.Range = v end})

local MacroTab = Tabs.Macro
local MA = MacroTab:AddLeftGroupbox("AHK & M1")
MA:AddButton("Load AHK Soru", LoadAHK)
MA:AddToggle("M1Ext", {Text="M1 Extender", Default=false, Callback=function(v) M1Active = v end})

local PTab = Tabs.Movement
local PA = PTab:AddLeftGroupbox("Movement")
PA:AddToggle("Fly", {Text="Fly", Default=false, Callback=ToggleFly})
PA:AddToggle("Speed", {Text="Speed Hack", Default=false, Callback=ToggleSpeed})

local VTab = Tabs.ESP
local VA = VTab:AddLeftGroupbox("ESP")
VA:AddToggle("ESP", {Text="Enable ESP", Default=false, Callback=function(v) ESPEnabled = v if not v then clearESP() end end})

local MTab = Tabs.Misc
local MA2 = MTab:AddLeftGroupbox("Misc")
MA2:AddToggle("AntiLava", {Text="Anti Lava", Default=false, Callback=ToggleLava})

local STab = Tabs.Settings
local SGroup = STab:AddLeftGroupbox("Menu")
SGroup:AddButton("Unload", function() Library:Unload() end)
SGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default="End", NoUI=true, Text="Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({"MenuKeybind"})
ThemeManager:SetFolder("LinoriaMobile")
SaveManager:SetFolder("LinoriaMobile/game")
ThemeManager:ApplyToGroupbox(SGroup)
SaveManager:BuildConfigSection(Tabs.Settings)
SaveManager:LoadAutoloadConfig()

print("[Nameless] Full Loaded OK")
