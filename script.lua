-- ==================== NAMELESS V30 - PART 1/4 ====================
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

task.delay(0.2, function()
    local CoreGui = game:GetService("CoreGui")
    local Players = game:GetService("Players")
    local lp = Players.LocalPlayer

    local function applyLogo()
        local titleLabel = nil
        local containers = { CoreGui, lp:FindFirstChild("PlayerGui") }
        for _, parent in ipairs(containers) do
            if parent then
                for _, descendant in ipairs(parent:GetDescendants()) do
                    if descendant:IsA("TextLabel") and (descendant.Text == "NamelessWare" or descendant.Text:find("Nameless")) then
                        if descendant.Parent and descendant.Parent:FindFirstChild("NamelessLogoIcon") then return true end
                        titleLabel = descendant
                        break
                    end
                end
            end
            if titleLabel then break end
        end

        if titleLabel then
            titleLabel.RichText = true
            titleLabel.Text = '<font color="#ffffff">Nameless</font><font color="#a050ff">Ware</font>'
            local titleParent = titleLabel.Parent
            if titleParent then
                local existingLogo = titleParent:FindFirstChild("NamelessLogoIcon")
                if existingLogo then existingLogo:Destroy() end

                local logoImg = Instance.new("ImageButton")
                logoImg.Name = "NamelessLogoIcon"
                logoImg.BackgroundTransparency = 1
                logoImg.Size = UDim2.new(0, 22, 0, 22)
                logoImg.Image = "rbxassetid://105243902490842"
                logoImg.ScaleType = Enum.ScaleType.Fit
                logoImg.AutoButtonColor = false
                
                Instance.new("UICorner", logoImg).CornerRadius = UDim.new(0, 4)

                local listLayout = titleParent:FindFirstChildOfClass("UIListLayout")
                if listLayout then
                    logoImg.LayoutOrder = 0
                    titleLabel.LayoutOrder = 1
                else
                    logoImg.Position = UDim2.new(0, 8, 0, (titleLabel.Position.Y.Offset > 0 and titleLabel.Position.Y.Offset or 6))
                    titleLabel.Position = UDim2.new(0, 36, 0, titleLabel.Position.Y.Offset)
                end
                
                logoImg.Parent = titleParent
                local windowFrame = titleParent
                while windowFrame and windowFrame.Parent and not windowFrame.Parent:IsA("ScreenGui") do windowFrame = windowFrame.Parent end
                
                local screenGui = windowFrame and windowFrame.Parent
                local toggleBtn = nil
                
                if screenGui then
                    toggleBtn = screenGui:FindFirstChild("NamelessToggleIcon")
                    if not toggleBtn then
                        toggleBtn = Instance.new("ImageButton")
                        toggleBtn.Name = "NamelessToggleIcon"
                        toggleBtn.Size = UDim2.new(0, 42, 0, 42)
                        toggleBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
                        toggleBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
                        toggleBtn.BackgroundTransparency = 0.1
                        toggleBtn.Image = "rbxassetid://105243902490842"
                        toggleBtn.ScaleType = Enum.ScaleType.Fit
                        toggleBtn.Visible = false
                        toggleBtn.Active = true
                        toggleBtn.Draggable = true
                        toggleBtn.Parent = screenGui

                        Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 10)
                        local stroke = Instance.new("UIStroke", toggleBtn)
                        stroke.Color = Color3.fromRGB(160, 80, 255)
                        stroke.Thickness = 2
                        
                        toggleBtn.MouseButton1Click:Connect(function()
                            toggleBtn.Visible = false
                            if windowFrame then windowFrame.Visible = true end
                        end)
                    end
                end

                logoImg.MouseButton1Click:Connect(function()
                    if windowFrame then
                        if toggleBtn then
                            toggleBtn.Position = UDim2.new(windowFrame.Position.X.Scale, windowFrame.Position.X.Offset + 10, windowFrame.Position.Y.Scale, windowFrame.Position.Y.Offset + 10)
                            toggleBtn.Visible = true
                        end
                        windowFrame.Visible = false
                    end
                end)
                return true
            end
        end
        return false
    end

    for i = 1, 5 do
        if applyLogo() then break end
        task.wait(0.3)
    end
end)

local Tabs = {
    Macro       = Window:AddTab("Macro", "keyboard"),
    SilentAim   = Window:AddTab("Silent Aim", "crosshair"),
    SABlacklist = Window:AddTab("SA Blacklist", "ban"),
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

local SilentAimModule
local sharkZActive, vActive, cursedZActive = false, false, false
local rightTouchActive = false
local damageDetected = false
local isBunnyHopping = false

-- AHK Loaders
local ahk_soru_loaded = false
local function UnloadAHKsoru()
    ahk_soru_loaded = false
    _G.NamelessAHKRunning = nil
    pcall(function()
        for _, parent in ipairs({lp:FindFirstChild("PlayerGui"), game:GetService("CoreGui")}) do
            if parent then
                for _, child in pairs(parent:GetChildren()) do
                    if child.Name:find("AHK_Soru") or child.Name:find("namelessWare_AHK_Soru") then child:Destroy() end
                end
            end
        end
    end)
    Library:Notify({ Title = "AHK Soru", Description = "Script disabled!", Time = 3 })
end

local function LoadAHKsoru()
    _G.NamelessAHKRunning = nil
    ahk_soru_loaded = false
    local success = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/sykq0/Namelesssoru/refs/heads/main/ahk.lua"))()
    end)
    if success then
        ahk_soru_loaded = true
        Library:Notify({ Title = "AHK Soru", Description = "Script loaded!", Time = 3 })
    else
        Library:Notify({ Title = "AHK Soru", Description = "Loading error.", Time = 3 })
    end
end

local ahk_combo_script_loaded = false
local function UnloadAHKComboScript()
    ahk_combo_script_loaded = false
    _G.NamelessComboRunning = nil
    pcall(function()
        for _, parent in ipairs({lp:FindFirstChild("PlayerGui"), game:GetService("CoreGui")}) do
            if parent then
                for _, child in pairs(parent:GetChildren()) do
                    if child.Name:find("AHK_Combo") or child.Name:find("namelessWare_AHK_Combo") then child:Destroy() end
                end
            end
        end
    end)
    Library:Notify({ Title = "AHK Combo", Description = "Script disabled!", Time = 3 })
end

local function LoadAHKComboScript()
    _G.NamelessComboRunning = nil
    ahk_combo_script_loaded = false
    local success = pcall(function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/sykq0/Namelesssoru/refs/heads/main/fetched-1.lua"))()
    end)
    if success then
        ahk_combo_script_loaded = true
        Library:Notify({ Title = "AHK Combo", Description = "Script loaded!", Time = 3 })
    else
        Library:Notify({ Title = "AHK Combo", Description = "Loading error.", Time = 3 })
    end
end

-- Damage Monitor
local function watchDamageCounter()
    task.spawn(function()
        while true do
            local gui = lp:FindFirstChild("PlayerGui") and lp.PlayerGui:FindFirstChild("Main")
            local dmgCounter = gui and gui:FindFirstChild("DmgCounter")
            local dmgTextLabel = dmgCounter and dmgCounter:FindFirstChild("Text")
            if dmgTextLabel then
                dmgTextLabel:GetPropertyChangedSignal("Text"):Connect(function()
                    damageDetected = (tonumber(dmgTextLabel.Text) or 0) > 0
                end)
                break
            end
            task.wait(1)
        end
    end)
end
watchDamageCounter()

local function isValidStopCondition()
    local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
    return (tool and tool.Name == "Shark Anchor" and sharkZActive) or vActive or (tool and tool.Name == "Cursed Dual Katana" and cursedZActive)
end -- ==================== NAMELESS V30 - PART 2/4 ====================
local multiEnabled = false; local multiPower = 400; local multiDuration = 0.9
local multiCharging = false; local multiChargeStart = 0; local multiRequiredCharge = 1.0
local diamondEnabled = false; local diamondPower = 250; local diamondDuration = 0.3
local diamondCharging = false; local diamondChargeStart = 0; local diamondRequiredCharge = 1.0
local dtalonEnabled = false; local dtalonPower = 400; local dtalonDuration = 0.9
local dtalonCharging = false; local dtalonChargeStart = 0; local dtalonRequiredCharge = 1.0
local EClawBoost

local function doBoost(power, duration)
    local char = lp.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChild("Humanoid")
    if not hrp or not hum then return end
    hum.PlatformStand = true
    local att = Instance.new("Attachment", hrp); local lv = Instance.new("LinearVelocity", hrp)
    lv.MaxForce = 9999999; lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector; lv.VectorVelocity = camera.CFrame.LookVector * power; lv.Attachment0 = att
    local active = true; local endT = tick() + duration; local conn
    local function stop()
        if not active then return end; active = false
        if lv then lv:Destroy() end; if att then att:Destroy() end; if hum then hum.PlatformStand = false end; if conn then conn:Disconnect() end
    end
    local lbl = lp.PlayerGui and lp.PlayerGui:FindFirstChild("Main") and lp.PlayerGui.Main:FindFirstChild("DmgCounter") and lp.PlayerGui.Main.DmgCounter:FindFirstChild("Text")
    if lbl then
        conn = lbl:GetPropertyChangedSignal("Text"):Connect(function()
            if (lbl.Text ~= "0" and lbl.Text ~= "") or (rightTouchActive and isValidStopCondition()) then stop() end
        end)
    end
    while active and tick() < endT do task.wait() end; stop()
end

RunService.Heartbeat:Connect(function()
    local char = lp.Character; local hum = char and char:FindFirstChild("Humanoid"); if not hum then return end
    local function checkAnim(id, name)
        for _, a in pairs(hum:GetPlayingAnimationTracks()) do if a.Animation.AnimationId:find(id) or a.Name == name then return true end end
        return false
    end
    if multiEnabled then
        if checkAnim("14418367908", "GhoulZCharge") then
            if not multiCharging then multiCharging = true; multiChargeStart = tick() end
        elseif multiCharging then
            if (tick() - multiChargeStart) >= multiRequiredCharge then task.spawn(function() doBoost(multiPower, multiDuration) end) end
            multiCharging = false; multiChargeStart = 0
        end
    end
    if diamondEnabled then
        if checkAnim("14414815375", "") then
            if not diamondCharging then diamondCharging = true; diamondChargeStart = tick() end
        elseif diamondCharging then
            if (tick() - diamondChargeStart) >= diamondRequiredCharge then task.spawn(function() doBoost(diamondPower, diamondDuration) end) end
            diamondCharging = false; diamondChargeStart = 0
        end
    end
    if dtalonEnabled then
        if checkAnim("18839089313", "DTalon_ZCharge") then
            if not dtalonCharging then dtalonCharging = true; dtalonChargeStart = tick() end
        elseif dtalonCharging then
            if (tick() - dtalonChargeStart) >= dtalonRequiredCharge then task.spawn(function() doBoost(dtalonPower, dtalonDuration) end) end
            dtalonCharging = false; dtalonChargeStart = 0
        end
    end
end)

EClawBoost = (function()
    local M = {}; local enabled = false; local power = 400; local duration = 1.7; local requiredCharge = 0.0; local boosted = false
    local function boost()
        local char = lp.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum then return end; local mouse = lp:GetMouse(); local dir = (mouse.Hit.p - hrp.Position).Unit
        hum.PlatformStand = true; local att = Instance.new("Attachment", hrp); local lv = Instance.new("LinearVelocity", hrp)
        lv.MaxForce = 9999999; lv.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector; lv.VectorVelocity = dir * power; lv.Attachment0 = att
        local active = true; local endT = tick() + duration
        local function stop()
            if not active then return end; active = false
            if lv then lv:Destroy() end; if att then att:Destroy() end; if hum then hum.PlatformStand = false end
        end
        while active and tick() < endT do task.wait() end; stop()
    end
    local function hookAnimations(hum)
        hum.AnimationPlayed:Connect(function(track)
            if not enabled then return end
            if track.Animation.AnimationId:find("6875496851") or track.Name == "ElectroClawXImpact" then
                boosted = false; local cs = tick()
                track.Stopped:Connect(function()
                    if not enabled or boosted then return end
                    if (tick() - cs) >= requiredCharge then boosted = true; task.spawn(boost) end
                end)
            end
        end)
    end
    function M:Toggle(v) enabled = v; if not v then boosted = false end end
    function M:SetPower(v) power = v end
    function M:SetDuration(v) duration = v end
    function M:SetRequiredCharge(v) requiredCharge = v end
    function M:Init(char) local hum = char:WaitForChild("Humanoid", 5); if hum then hookAnimations(hum) end end
    return M
end)()
lp.CharacterAdded:Connect(function(char) task.spawn(function() EClawBoost:Init(char) end) end)
if lp.Character then task.spawn(function() EClawBoost:Init(lp.Character) end) end

-- Fake Items
local fakeHeadlessEnabled, fakeHeadlessVersion = false, "V1"
local fakeKorbloxEnabled, fakeKorbloxVersion = false, "V1"
local korbloxMeshes = {}

function applyFakeKorblox()
    local char = lp.Character; if not char then return end
    local rl, rl2, rf = char:FindFirstChild("RightUpperLeg"), char:FindFirstChild("RightLowerLeg"), char:FindFirstChild("RightFoot")
    if rl then
        rl.Transparency = 1
        for _, c in pairs(rl:GetChildren()) do if c:IsA("SpecialMesh") then c:Destroy() end end
        local m = Instance.new("SpecialMesh", rl); m.MeshId = "rbxassetid://139607718"; m.TextureId = "rbxassetid://139607673"; m.Scale = Vector3.new(1,1,1)
        table.insert(korbloxMeshes, m)
    end
    if rl2 then rl2.Transparency = 1 end
    if rf then rf.Transparency = 1 end
    if fakeKorbloxVersion == "V2" then
        for _, n in pairs({"LeftUpperLeg","LeftLowerLeg","LeftFoot"}) do local p = char:FindFirstChild(n) if p then p.Transparency = 1 end end
    end
end

function removeFakeKorblox()
    for _, m in pairs(korbloxMeshes) do pcall(function() m:Destroy() end) end
    korbloxMeshes = {}
    local char = lp.Character; if not char then return end
    for _, n in pairs({"RightUpperLeg","RightLowerLeg","RightFoot","LeftUpperLeg","LeftLowerLeg","LeftFoot"}) do local p = char:FindFirstChild(n) if p then p.Transparency = 0 end end
end

function applyFakeHeadless()
    local char = lp.Character; if not char then return end
    local head = char:FindFirstChild("Head")
    if head then head.Transparency = 1; local face = head:FindFirstChild("face"); if face then face.Transparency = 1 end end
    if fakeHeadlessVersion == "V2" then
        for _, obj in pairs(char:GetChildren()) do if obj:IsA("Accessory") then local h = obj:FindFirstChild("Handle"); if h then h.Transparency = 1 end end end
    end
end

function removeFakeHeadless()
    local char = lp.Character; if not char then return end
    local head = char:FindFirstChild("Head")
    if head then head.Transparency = 0; local face = head:FindFirstChild("face"); if face then face.Transparency = 0 end end
    for _, obj in pairs(char:GetChildren()) do if obj:IsA("Accessory") then local h = obj:FindFirstChild("Handle"); if h then h.Transparency = 0 end end end
end

local function onCharacterAddedApparence()
    task.spawn(function()
        task.wait(0.3)
        if fakeHeadlessEnabled then applyFakeHeadless() end
        if fakeKorbloxEnabled then applyFakeKorblox() end
    end)
end
lp.CharacterAdded:Connect(onCharacterAddedApparence)
if lp.Character then onCharacterAddedApparence() end

-- Movement & Speed & Fly
local bunnyHopEnabled = false
local superJumpEnabled, superJumpMode, superJumpPower, normalJumpPower = false, "V1", 150, 50
local superJumpButton = nil
local dashLengthEnabled, dashLengthValue, dashLengthConnection = false, 1, nil
local flySettings = { flyActive = false, noclipActive = false, mode = "CFrame", speed = 50, incore = nil, nocore = nil }
local flyMiniGui = nil; local flyMiniButton = nil; local flyDragConn, flyEndConn = nil, nil
local speedSettings = { speedActive = false, mode = "WalkSpeed", speedValue = 50, incore = nil }
local speedMiniGui = nil; local speedMiniButton = nil; local speedDragConn, speedEndConn = nil, nil

local function StartFly()
    if flySettings.incore then flySettings.incore:Disconnect() end
    flySettings.flyActive = true
    flySettings.incore = RunService.Stepped:Connect(function()
        local char = lp.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChildOfClass("Humanoid")
        if not flySettings.flyActive or not hrp or not hum then return end
        local moveDir = hum.MoveDirection; local camCF = camera.CFrame; local direction = Vector3.zero
        if moveDir.Magnitude > 0 then
            local relativeMove = camCF:VectorToObjectSpace(moveDir)
            direction = ((camCF.RightVector * relativeMove.X) + (camCF.LookVector * -relativeMove.Z)).Unit
        end
        if flySettings.mode == "CFrame" then
            hum.PlatformStand = true
            hrp.CFrame = hrp.CFrame + (direction * (flySettings.speed / 10))
            hrp.Velocity = Vector3.zero
        elseif flySettings.mode == "Velocity" then
            hrp.Velocity = (direction * flySettings.speed) + Vector3.new(0, 2, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then hrp.CFrame = hrp.CFrame + Vector3.new(0, flySettings.speed / 15, 0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then hrp.CFrame = hrp.CFrame + Vector3.new(0, -flySettings.speed / 15, 0) end
    end)
end

local function StopFly()
    flySettings.flyActive = false
    if flySettings.incore then flySettings.incore:Disconnect(); flySettings.incore = nil end
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.PlatformStand = false end
end

local function StartNoClip()
    if flySettings.nocore then flySettings.nocore:Disconnect() end
    flySettings.nocore = RunService.Stepped:Connect(function()
        if lp.Character then for _, p in pairs(lp.Character:GetDescendants()) do if p:IsA("BasePart") then p.CanCollide = false end end end
    end)
end

local function StopNoClip()
    if flySettings.nocore then flySettings.nocore:Disconnect(); flySettings.nocore = nil end
end -- ==================== NAMELESS V30 - PART 3A ====================
local function applySpeedHack()
    local char = lp.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart"); local hum = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    local moveDir = hum.MoveDirection
    if speedSettings.mode == "WalkSpeed" then hum.WalkSpeed = speedSettings.speedValue
    elseif speedSettings.mode == "CFrame" and moveDir.Magnitude > 0 then hrp.CFrame = hrp.CFrame + (moveDir * (speedSettings.speedValue / 100))
    elseif speedSettings.mode == "Velocity" and moveDir.Magnitude > 0 then hrp.Velocity = Vector3.new(moveDir.X * speedSettings.speedValue, hrp.Velocity.Y, moveDir.Z * speedSettings.speedValue)
    elseif speedSettings.mode == "TP-Flash" and moveDir.Magnitude > 0 then hrp.CFrame = hrp.CFrame * CFrame.new(0, 0, -speedSettings.speedValue / 50)
    elseif speedSettings.mode == "AnimSpeed" then
        hum.WalkSpeed = speedSettings.speedValue
        for _, track in pairs(hum:GetPlayingAnimationTracks()) do track:AdjustSpeed(speedSettings.speedValue / 16) end
    end
end

local function StartSpeedHack() speedSettings.speedActive = true end
local function StopSpeedHack() speedSettings.speedActive = false; if lp.Character and lp.Character:FindFirstChildOfClass("Humanoid") then lp.Character.Humanoid.WalkSpeed = 16 end end
RunService.Heartbeat:Connect(function() if speedSettings.speedActive then applySpeedHack() end end)

local function applySuperJumpV1()
    local char = lp.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum.UseJumpPower = true; hum.JumpPower = superJumpPower end
end
local function resetSuperJumpToNormal()
    local char = lp.Character; if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum.JumpPower = normalJumpPower end
end

local function createSuperJumpButton()
    if superJumpButton then return end
    local gui = Instance.new("ScreenGui", game:GetService("CoreGui")); gui.Name = "SuperJumpBtn"
    local btn = Instance.new("TextButton", gui)
    btn.Size = UDim2.new(0, 120, 0, 50); btn.Position = UDim2.new(0.05, 0, 0.8, 0)
    btn.BackgroundColor3 = Color3.fromRGB(200, 70, 30); btn.TextColor3 = Color3.new(1,1,1); btn.Font = Enum.Font.GothamBold; btn.TextSize = 15; btn.Text = "🚀 SUPER JUMP"; btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)
    btn.MouseButton1Click:Connect(function()
        local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
        if hrp and not damageDetected then hrp.Velocity = Vector3.new(hrp.Velocity.X, superJumpPower, hrp.Velocity.Z) end
    end)
    local dragging, dragStart, startPos
    btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = i.Position; startPos = btn.AbsolutePosition end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local vp = workspace.CurrentCamera.ViewportSize
            btn.Position = UDim2.new(0, math.clamp(startPos.X + (i.Position - dragStart).X, 0, vp.X - btn.AbsoluteSize.X), 0, math.clamp(startPos.Y + (i.Position - dragStart).Y, 0, vp.Y - btn.AbsoluteSize.Y))
        end
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
    superJumpButton = gui
end
local function destroySuperJumpButton() if superJumpButton then superJumpButton:Destroy(); superJumpButton = nil end end

local function updateSuperJumpState()
    if not superJumpEnabled then resetSuperJumpToNormal(); destroySuperJumpButton(); return end
    if superJumpMode == "V1" then destroySuperJumpButton(); applySuperJumpV1()
    elseif superJumpMode == "V2" then resetSuperJumpToNormal(); createSuperJumpButton()
    elseif superJumpMode == "V3" then resetSuperJumpToNormal(); destroySuperJumpButton() end
end

RunService.Heartbeat:Connect(function()
    if superJumpEnabled and superJumpMode == "V1" and lp.Character then
        local hum = lp.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.JumpPower = (damageDetected or isBunnyHopping) and normalJumpPower or superJumpPower end
    end
end)

UserInputService.InputBegan:Connect(function(input, gp)
    if gp or not superJumpEnabled or superJumpMode ~= "V3" or input.KeyCode ~= Enum.KeyCode.Space then return end
    local char = lp.Character; if not char then return end
    local hum, hrp = char:FindFirstChildOfClass("Humanoid"), char:FindFirstChild("HumanoidRootPart")
    if not hum or not hrp then return end
    local onGround = hum.FloorMaterial ~= Enum.Material.Air
    if not onGround then
        local params = RaycastParams.new(); params.FilterDescendantsInstances = {char}; params.FilterType = Enum.RaycastFilterType.Exclude
        if workspace:Raycast(hrp.Position, Vector3.new(0, -4.5, 0), params) then onGround = true end
    end
    if not onGround or damageDetected then return end
    local oldJP = hum.JumpPower; hum.JumpPower = superJumpPower; hum:Jump(); task.delay(0.1, function() if hum then hum.JumpPower = oldJP end end)
end)

-- Mini Toggles
local function makeMiniToggle(name, label, yOff, onToggle, isOn)
    local sg = Instance.new("ScreenGui", game:GetService("CoreGui")); sg.Name = name; sg.ResetOnSpawn = false
    local btn = Instance.new("TextButton", sg); btn.Size = UDim2.new(0, 80, 0, 40); btn.Position = UDim2.new(0, 10, 0.5, yOff)
    btn.Text = label .. ": " .. (isOn and "ON" or "OFF"); btn.TextScaled = true; btn.BackgroundColor3 = Color3.fromRGB(30, 30, 30); btn.TextColor3 = Color3.new(1,1,1); btn.BorderSizePixel = 0
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
    local grad = Instance.new("UIGradient", btn); grad.Rotation = 45
    local state = isOn
    local function update()
        btn.Text = label .. ": " .. (state and "ON" or "OFF")
        grad.Color = ColorSequence.new{ColorSequenceKeypoint.new(0, state and Color3.fromRGB(50,200,50) or Color3.fromRGB(80,80,80)), ColorSequenceKeypoint.new(1, state and Color3.fromRGB(50,255,50) or Color3.fromRGB(50,50,50))}
    end
    update()
    local dragging, dragStart, startPos
    btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = i.Position; startPos = btn.AbsolutePosition end end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseMovement) then
            local vp = camera.ViewportSize
            btn.Position = UDim2.new(0, math.clamp(startPos.X + (i.Position - dragStart).X, 0, vp.X - btn.AbsoluteSize.X), 0, math.clamp(startPos.Y + (i.Position - dragStart).Y, 0, vp.Y - btn.AbsoluteSize.Y))
        end
    end)
    UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.Touch or i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
    btn.MouseButton1Click:Connect(function() state = not state; update(); onToggle(state) end)
    return sg
end

local function CreateFlyMiniToggle()
    if flyMiniGui then return end
    flyMiniGui = makeMiniToggle("FlyMiniToggle", "FLY", -20, function(s) if s then StartFly() else StopFly() end; if Options.FlyToggle then Options.FlyToggle:SetValue(s) end end, flySettings.flyActive)
end
local function DestroyFlyMiniToggle() if flyMiniGui then flyMiniGui:Destroy(); flyMiniGui = nil end end
local function CreateSpeedMiniToggle()
    if speedMiniGui then return end
    speedMiniGui = makeMiniToggle("SpeedMiniToggle", "SPEED", 30, function(s) if s then StartSpeedHack() else StopSpeedHack() end; if Options.SpeedHackToggle then Options.SpeedHackToggle:SetValue(s) end end, speedSettings.speedActive)
end
local function DestroySpeedMiniToggle() if speedMiniGui then speedMiniGui:Destroy(); speedMiniGui = nil end end -- ==================== NAMELESS V30 - PART 3B ====================
local DashGlitch = (function()
    local M = {}
    local enabled, version, cooldown, dashLength, speedBoost, airWalkSpeed = false, "V1", 1.5, 190, 350, 400
    local tapGui, tapButton, v1Active, v2Trigger, autoLoop = nil, nil, false, false, nil
    local args = {"TAP", Vector3.new(-1221.487548828125, 69.36107635498047, -566.5001220703125)}

    local function createTapButton()
        if tapGui then return end
        tapGui = Instance.new("ScreenGui", game:GetService("CoreGui")); tapGui.Name = "DashGlitchTap"; tapGui.ResetOnSpawn = false
        local btn = Instance.new("TextButton", tapGui); btn.Size = UDim2.new(0, 50, 0, 30); btn.Position = UDim2.new(0.02, 0, 0.45, 0)
        btn.BackgroundColor3 = Color3.fromRGB(50, 100, 200); btn.TextColor3 = Color3.new(1,1,1); btn.Text = (version == "V1") and "DASH: OFF" or "TAP"; btn.Font = Enum.Font.GothamBold; btn.TextSize = 9; btn.BorderSizePixel = 0
        Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
        local dragging, dragStart, startPos
        btn.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = true; dragStart = i.Position; startPos = btn.AbsolutePosition end end)
        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                local vp = camera.ViewportSize
                btn.Position = UDim2.new(0, math.clamp(startPos.X + (i.Position - dragStart).X, 0, vp.X - btn.AbsoluteSize.X), 0, math.clamp(startPos.Y + (i.Position - dragStart).Y, 0, vp.Y - btn.AbsoluteSize.Y))
            end
        end)
        UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then dragging = false end end)
        btn.MouseButton1Click:Connect(function()
            if version == "V2" then v2Trigger = true
            elseif version == "V1" then
                v1Active = not v1Active; btn.Text = "DASH: " .. (v1Active and "ON" or "OFF"); btn.BackgroundColor3 = v1Active and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 70, 30)
            end
        end)
        tapButton = btn
    end

    local function destroyTapButton() if tapGui then tapGui:Destroy(); tapGui = nil; tapButton = nil end end

    local function doDashCombo()
        local char = lp.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); local hum = char:FindFirstChildOfClass("Humanoid"); local tool = char:FindFirstChildOfClass("Tool")
        if not tool or tool.Name ~= "Skull Guitar" or not hrp or not hum then return end
        local remote = tool:FindFirstChild("RemoteEvent"); if not remote then return end
        hum.PlatformStand = true; hum:ChangeState(Enum.HumanoidStateType.Physics); remote:FireServer(unpack(args))
        char:SetAttribute("DashLength", dashLength); char:SetAttribute("DashLengthAir", dashLength); hrp.AssemblyLinearVelocity = hrp.CFrame.LookVector * speedBoost
        task.delay(0.2, function() if char then char:SetAttribute("DashLength", 1); char:SetAttribute("DashLengthAir", 1) end end)
        task.wait(0.25); hum.PlatformStand = false; hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end

    local function startAuto()
        if autoLoop then return end
        autoLoop = task.spawn(function()
            while enabled and version == "V1" do
                if v1Active then local char = lp.Character; local tool = char and char:FindFirstChildOfClass("Tool"); if tool and tool.Name == "Skull Guitar" then doDashCombo() end end
                task.wait(cooldown)
            end
        end)
    end
    local function stopAuto() if autoLoop then task.cancel(autoLoop); autoLoop = nil end; local char = lp.Character; if char then char:SetAttribute("DashLength", 1); char:SetAttribute("DashLengthAir", 1); local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum.PlatformStand = false; hum.WalkSpeed = 16 end end end
    local function v2Watch() task.spawn(function() while enabled and version == "V2" do if v2Trigger then v2Trigger = false; doDashCombo() end; task.wait(0.05) end end) end

    function M:SetEnabled(state)
        if state == enabled then return end; enabled = state
        if state then if version == "V1" then v1Active = false; createTapButton(); startAuto() elseif version == "V2" then createTapButton(); v2Watch() end
        else stopAuto(); destroyTapButton(); v2Trigger = false; v1Active = false end
    end
    function M:SetVersion(v) if v == version then return end; local wasEnabled = enabled; if wasEnabled then M:SetEnabled(false) end; version = v; if wasEnabled then M:SetEnabled(true) end end
    function M:SetCooldown(v) cooldown = v end
    function M:SetDashLength(v) dashLength = v end
    function M:SetSpeedBoost(v) speedBoost = v end
    function M:SetAirWalkSpeed(v) airWalkSpeed = v end

    RunService.Stepped:Connect(function()
        if not enabled or version ~= "V1" then return end
        local char = lp.Character; local hum = char and char:FindFirstChildOfClass("Humanoid"); local tool = char and char:FindFirstChildOfClass("Tool")
        if hum and tool and tool.Name == "Skull Guitar" then
            if hum.FloorMaterial == Enum.Material.Air then hum.WalkSpeed = airWalkSpeed else hum.WalkSpeed = 16; hum.PlatformStand = false end
        elseif hum then hum.WalkSpeed = 16; hum.PlatformStand = false end
    end)
    return M
end)()

-- Misc Features
local fontChangerEnabled = false; local fontPreset = "GothamSsm"; local updatedFonts = {}; local fontConn = nil
local antiMoverEnabled = false; local antiMoverConnection = nil
local unbreakableEnabled = false; local unbreakableConnection = nil

local function enableFonts()
    if fontConn then fontConn:Disconnect() end
    fontConn = RunService.Heartbeat:Connect(function()
        for _, gui in pairs({lp:FindFirstChild("PlayerGui"), game:GetService("CoreGui")}) do
            if gui then for _, obj in pairs(gui:GetDescendants()) do if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then if obj.Font ~= Enum.Font[fontPreset] then obj.Font = Enum.Font[fontPreset]; table.insert(updatedFonts, obj) end end end end
        end
    end)
end
local function disableFonts() if fontConn then fontConn:Disconnect(); fontConn = nil end; for _, obj in pairs(updatedFonts) do pcall(function() obj.Font = Enum.Font.SourceSans end) end; updatedFonts = {} end

-- No GFX
local noGfxMode = "Off"; local noGfxConnections = {}; local noGfxModifiedObjects = {}; local hotbarIconsOriginals = {}
local function restoreNoGfx()
    for obj, data in pairs(noGfxModifiedObjects) do pcall(function() if data.Texture ~= nil then obj.Texture = data.Texture end; if data.Enabled ~= nil then obj.Enabled = data.Enabled end end) end
    noGfxModifiedObjects = {}
    for iconLabel, oldImage in pairs(hotbarIconsOriginals) do pcall(function() iconLabel.Image = oldImage or "" end) end
    hotbarIconsOriginals = {}
    if noGfxConnections.DescendantAdded then noGfxConnections.DescendantAdded:Disconnect(); noGfxConnections.DescendantAdded = nil end
    if noGfxConnections.HotbarChildAdded then noGfxConnections.HotbarChildAdded:Disconnect(); noGfxConnections.HotbarChildAdded = nil end
end
local function processObject(inst)
    if inst.ClassName == "Beam" or inst.ClassName == "Trail" then
        if not noGfxModifiedObjects[inst] then noGfxModifiedObjects[inst] = {Texture = inst.Texture}; inst.Texture = "rbxassetid://84308155859778" end
    elseif inst.ClassName == "ParticleEmitter" then
        if not noGfxModifiedObjects[inst] then noGfxModifiedObjects[inst] = {Texture = inst.Texture, Enabled = inst.Enabled}; inst.Texture = ""; inst.Enabled = false end
    end
end
local function startNoGfxV1()
    restoreNoGfx(); task.spawn(function() local desc = workspace:GetDescendants(); for i = 1, #desc do if not desc[i]:IsA("Terrain") and not desc[i]:IsA("Camera") then processObject(desc[i]) end; if i % 100 == 0 then RunService.Heartbeat:Wait() end end end)
    noGfxConnections.DescendantAdded = workspace.DescendantAdded:Connect(processObject)
end
local function startNoGfxV2()
    restoreNoGfx(); task.spawn(function() local desc = workspace:GetDescendants(); for i = 1, #desc do if not desc[i]:IsA("Terrain") and not desc[i]:IsA("Camera") then processObject(desc[i]) end; if i % 100 == 0 then RunService.Heartbeat:Wait() end end end)
    noGfxConnections.DescendantAdded = workspace.DescendantAdded:Connect(processObject)
    task.spawn(function()
        local pg = lp:WaitForChild("PlayerGui"); local bp = pg:WaitForChild("Backpack"); local hc = bp:WaitForChild("Hotbar"):WaitForChild("Container")
        local function updateIcons()
            for _, slot in ipairs(hc:GetChildren()) do local icon = slot:FindFirstChild("Icon") or slot:FindFirstChild("Image") or slot:FindFirstChildOfClass("ImageLabel"); if icon and icon:IsA("ImageLabel") then if not hotbarIconsOriginals[icon] then hotbarIconsOriginals[icon] = icon.Image end; icon.Image = "rbxassetid://84308155859778"; icon.ImageColor3 = Color3.new(1,1,1) end end
        end
        updateIcons(); noGfxConnections.HotbarChildAdded = hc.ChildAdded:Connect(function() task.defer(updateIcons) end)
    end)
end
local function stopNoGfx() restoreNoGfx() end
local function setNoGfxMode(mode) if mode == noGfxMode then return end; noGfxMode = mode; stopNoGfx(); if mode == "V1" then startNoGfxV1() elseif mode == "V2" then startNoGfxV2() end end

-- Delete Ship & Water & Lava
local deleteShipActive = false; local deleteShipRunning = false
local function deleteShipStructure()
    if not deleteShipActive then return end
    task.spawn(function()
        local shipNames = {"CursedShip", "Cursed Ship", "Ship"}; local extNames = {"Wall", "Floor", "Ceiling", "Base", "Hull", "Window", "DoorFrame"}
        for _, obj in pairs(workspace:GetDescendants()) do
            for _, sName in ipairs(shipNames) do
                if obj.Name:find(sName) and (obj:IsA("Model") or obj:IsA("Folder")) then
                    for _, child in pairs(obj:GetDescendants()) do
                        if child:IsA("BasePart") and not child.Parent:FindFirstChild("Humanoid") then
                            local isExt = false; for _, ext in ipairs(extNames) do if child.Name:find(ext) then isExt = true; break end end
                            if not isExt then child:Destroy() end
                        end
                    end
                end
            end
        end
    end)
end
local function startDeleteShipLoop() if deleteShipRunning then return end; deleteShipRunning = true; task.spawn(function() while deleteShipActive do deleteShipStructure(); task.wait(3) end; deleteShipRunning = false end) end

local WalkOnWaterEnabled = false; local waterPart = nil
task.spawn(function()
    while true do
        task.wait(0.15)
        if WalkOnWaterEnabled then
            if not waterPart or not waterPart.Parent then waterPart = Instance.new("Part"); waterPart.Size = Vector3.new(200, 1, 200); waterPart.Transparency = 1; waterPart.Anchored = true; waterPart.CanCollide = false; waterPart.Name = "SacredWater"; waterPart.Parent = workspace end
            local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
            if hrp and hrp.Position.Y >= 9.5 then waterPart.Position = Vector3.new(hrp.Position.X, 9.2, hrp.Position.Z); waterPart.CanCollide = true else waterPart.CanCollide = false end
        elseif waterPart and waterPart.Parent then waterPart.CanCollide = false end
    end
end)

local antiLavaActive = false; local antiLavaConnection = nil
local function startAntiLava()
    if antiLavaConnection then antiLavaConnection:Disconnect() end
    local timer = 0
    antiLavaConnection = RunService.Stepped:Connect(function(_, dt)
        timer = timer + dt; if timer < 0.2 then return end; timer = 0
        local char = lp.Character; if not (char and antiLavaActive) then return end
        for _, part in pairs(char:GetDescendants()) do if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Name ~= "Torso" and part.Name ~= "UpperTorso" and part.Name ~= "LowerTorso" and part.Name ~= "Head" then part.CanTouch = false end end
    end)
end
local function stopAntiLava() if antiLavaConnection then antiLavaConnection:Disconnect(); antiLavaConnection = nil end end -- ==================== NAMELESS V30 - PART 4A ====================
local bigSkinBugEnabled = false; local bigSkinBugOriginal = {}; local bigSkinBugConnections = {}

local function applyBigSkin(char)
    local data = bigSkinBugOriginal[char]
    if not data then return end
    for item, saved in pairs(data.accessories) do item.Parent = nil end
    for part, saved in pairs(data.parts) do
        part.Color = Color3.fromRGB(128, 128, 128); part.Material = Enum.Material.SmoothPlastic; part.CanCollide = true
        if part:IsA("MeshPart") then part.TextureID = "" end
        local nameLower = part.Name:lower()
        if nameLower:match("torso") then part.Size = Vector3.new(5.6, 4.4, 3.4)
        elseif nameLower:match("leg") or nameLower:match("arm") then part.Size = Vector3.new(2.6, 4.8, 2.6)
        elseif nameLower == "head" then part.Size = Vector3.new(2.2, 2.2, 2.2); local mesh = part:FindFirstChildOfClass("SpecialMesh"); if mesh then mesh.Parent = nil end end
    end
    for joint, saved in pairs(data.joints) do
        local jName = joint.Name:lower(); local c0 = saved.C0
        if jName:match("rightshoulder") then joint.C0 = c0 * CFrame.new(2.4, 0.6, 0)
        elseif jName:match("leftshoulder") then joint.C0 = c0 * CFrame.new(-2.4, 0.6, 0)
        elseif jName:match("righthip") then joint.C0 = c0 * CFrame.new(0.9, -0.6, 0)
        elseif jName:match("lefthip") then joint.C0 = c0 * CFrame.new(-0.9, -0.6, 0)
        elseif jName:match("neck") then joint.C0 = c0 * CFrame.new(0, 0.8, 0) end
    end
end

local function saveBigSkinOriginal(char)
    local data = { parts = {}, accessories = {}, joints = {} }
    for _, item in pairs(char:GetDescendants()) do
        if item:IsA("Accessory") or item:IsA("Clothing") or item:IsA("ShirtGraphic") or item:IsA("Decal") then data.accessories[item] = { Parent = item.Parent }
        elseif item:IsA("BasePart") and item.Name ~= "HumanoidRootPart" then
            local saved = { Size = item.Size, Color = item.Color, Material = item.Material, TextureID = item:IsA("MeshPart") and item.TextureID or nil }
            if item.Name == "Head" then local mesh = item:FindFirstChildOfClass("SpecialMesh"); if mesh then saved.MeshParent = mesh.Parent end end
            data.parts[item] = saved
        elseif item:IsA("Motor6D") and item.Part0 and item.Part1 then data.joints[item] = { C0 = item.C0, C1 = item.C1 } end
    end
    bigSkinBugOriginal[char] = data
end

local function restoreBigSkin(char)
    local data = bigSkinBugOriginal[char]; if not data then return end
    for item, saved in pairs(data.accessories) do if saved.Parent then item.Parent = saved.Parent end end
    for part, saved in pairs(data.parts) do
        part.Size = saved.Size; part.Color = saved.Color; part.Material = saved.Material
        if saved.TextureID and part:IsA("MeshPart") then part.TextureID = saved.TextureID end
        if saved.MeshParent and part.Name == "Head" then local mesh = part:FindFirstChildOfClass("SpecialMesh"); if not mesh and saved.MeshParent ~= part then local oldMesh = saved.MeshParent:FindFirstChildOfClass("SpecialMesh"); if oldMesh then oldMesh.Parent = part end end end
    end
    for joint, saved in pairs(data.joints) do joint.C0 = saved.C0; joint.C1 = saved.C1 end
    bigSkinBugOriginal[char] = nil
end

local function onCharAddedBigSkin(char) if not bigSkinBugEnabled then return end; task.wait(0.4); saveBigSkinOriginal(char); applyBigSkin(char) end
local function enableBigSkin() if bigSkinBugEnabled then return end; bigSkinBugEnabled = true; if lp.Character then saveBigSkinOriginal(lp.Character); applyBigSkin(lp.Character) end; bigSkinBugConnections.CharAdded = lp.CharacterAdded:Connect(onCharAddedBigSkin) end
local function disableBigSkin() bigSkinBugEnabled = false; if bigSkinBugConnections.CharAdded then bigSkinBugConnections.CharAdded:Disconnect(); bigSkinBugConnections.CharAdded = nil end; if lp.Character then restoreBigSkin(lp.Character) end end

-- ESP Module
local ESPModule = (function()
    local module = {}
    local ESPEnabled = false; local ShowBox, ShowName, ShowDistance, ShowHealth, ShowLine = true, true, true, true, true
    local BoxColor, TextColor, LineColor = "Red", "White", "Red"; local ShowAllPlayers = false; local LineOrigin = "Player"
    local drawings = {}
    local function clearDrawings() for _, d in pairs(drawings) do pcall(function() d:Remove() end) end drawings = {} end
    local function getColor(name) local colors = { Red=Color3.new(1,0,0), Green=Color3.new(0,1,0), Blue=Color3.new(0,0,1), Yellow=Color3.new(1,1,0), White=Color3.new(1,1,1), Black=Color3.new(0,0,0), Cyan=Color3.new(0,1,1), Magenta=Color3.new(1,0,1) }; return colors[name] or Color3.new(1,1,1) end
    local function isEnemy(plr)
        if plr == lp then return false end; if ShowAllPlayers then return true end
        local myTeam = lp.Team; local targetTeam = plr.Team
        if myTeam and targetTeam then
            if myTeam.Name=="Pirates" and targetTeam.Name=="Marines" then return true elseif myTeam.Name=="Marines" and targetTeam.Name=="Pirates" then return true end
            if myTeam.Name=="Pirates" and targetTeam.Name=="Pirates" then return true end
            if myTeam.Name=="Marines" and targetTeam.Name=="Marines" then return false end
        end
        return true
    end
    local function updateESP()
        clearDrawings(); if not ESPEnabled then return end
        local myHrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart"); local vp = camera.ViewportSize
        for _, plr in pairs(Players:GetPlayers()) do
            if plr == lp or not plr.Character or not plr.Character:FindFirstChild("HumanoidRootPart") then continue end
            if not isEnemy(plr) then continue end
            local hrp = plr.Character.HumanoidRootPart; local hum = plr.Character:FindFirstChildOfClass("Humanoid")
            if not hum or hum.Health <= 0 then continue end
            local pos, onScreen = camera:WorldToViewportPoint(hrp.Position); local screenPos = Vector2.new(pos.X, pos.Y); local isVisible = onScreen; local lineEnd = screenPos
            if pos.Z < 0 then
                local center = Vector2.new(vp.X/2, vp.Y/2); local dirToTarget = (center - screenPos).Unit; local maxX, maxY = (vp.X/2)-5, (vp.Y/2)-5; local t = 1
                if math.abs(dirToTarget.X)>0.001 and math.abs(dirToTarget.Y)>0.001 then t = math.min(math.abs(maxX/dirToTarget.X), math.abs(maxY/dirToTarget.Y))
                elseif math.abs(dirToTarget.X)>0.001 then t = math.abs(maxX/dirToTarget.X)
                elseif math.abs(dirToTarget.Y)>0.001 then t = math.abs(maxY/dirToTarget.Y) end
                lineEnd = center + dirToTarget * t
            end
            local boxCol, txtCol, lineCol = getColor(BoxColor), getColor(TextColor), getColor(LineColor)
            local size = Vector2.new(2000/(camera.CFrame.Position-hrp.Position).Magnitude, 4000/(camera.CFrame.Position-hrp.Position).Magnitude)
            if ShowBox and isVisible then
                local topLeft, topRight, bottomLeft, bottomRight = Vector2.new(pos.X-size.X/2, pos.Y-size.Y/2), Vector2.new(pos.X+size.X/2, pos.Y-size.Y/2), Vector2.new(pos.X-size.X/2, pos.Y+size.Y/2), Vector2.new(pos.X+size.X/2, pos.Y+size.Y/2)
                local function addLine(p1,p2) local l=Drawing.new("Line"); l.Visible=true; l.Color=boxCol; l.Thickness=1; l.From=p1; l.To=p2; table.insert(drawings,l) end
                addLine(topLeft, topRight); addLine(topRight, bottomRight); addLine(bottomRight, bottomLeft); addLine(bottomLeft, topLeft)
            end
            if ShowName and isVisible then local t = Drawing.new("Text"); t.Visible=true; t.Text=plr.Name; t.Color=txtCol; t.Size=13; t.Center=true; t.Position=Vector2.new(pos.X, pos.Y-size.Y/2-15); t.Font=2; table.insert(drawings,t) end
            if ShowDistance and isVisible then local dist = math.floor((hrp.Position-(myHrp and myHrp.Position or Vector3.zero)).Magnitude); local t = Drawing.new("Text"); t.Visible=true; t.Text=dist.."m"; t.Color=txtCol; t.Size=13; t.Center=true; t.Position=Vector2.new(pos.X, pos.Y+size.Y/2+2); t.Font=2; table.insert(drawings,t) end
            if ShowHealth and isVisible then
                local hpRatio = math.clamp(hum.Health/hum.MaxHealth,0,1); local barW, barH = size.X, 4; local barPos = Vector2.new(pos.X-barW/2, pos.Y+size.Y/2+12)
                local bg = Drawing.new("Square"); bg.Visible=true; bg.Color=Color3.new(0,0,0); bg.Filled=true; bg.Size=Vector2.new(barW,barH); bg.Position=barPos; table.insert(drawings,bg)
                local fg = Drawing.new("Square"); fg.Visible=true; fg.Color=Color3.new(1-hpRatio, hpRatio, 0); fg.Filled=true; fg.Size=Vector2.new(barW*hpRatio,barH); fg.Position=barPos; table.insert(drawings,fg)
            end
            if ShowLine then
                local lineStart = nil
                if LineOrigin == "Player" then if myHrp then local myPos, onScr = camera:WorldToViewportPoint(myHrp.Position); if onScr then lineStart = Vector2.new(myPos.X, myPos.Y) else lineStart = Vector2.new(vp.X/2, vp.Y/2) end else lineStart = Vector2.new(vp.X/2, vp.Y/2) end
                elseif LineOrigin == "Center" then lineStart = Vector2.new(vp.X/2, vp.Y/2)
                elseif LineOrigin == "Top" then lineStart = Vector2.new(vp.X/2, 0) end
                if lineStart then local l = Drawing.new("Line"); l.Visible=true; l.Color=lineCol; l.Thickness=1; l.From=lineStart; l.To=lineEnd; table.insert(drawings,l) end
            end
        end
    end
    local espConnection
    function module:SetESPEnabled(state) ESPEnabled=state; if state then if espConnection then espConnection:Disconnect() end espConnection=RunService.RenderStepped:Connect(updateESP) else if espConnection then espConnection:Disconnect(); espConnection=nil end clearDrawings() end end
    function module:SetShowBox(v) ShowBox=v end; function module:SetShowName(v) ShowName=v end; function module:SetShowDistance(v) ShowDistance=v end
    function module:SetShowHealth(v) ShowHealth=v end; function module:SetShowLine(v) ShowLine=v end
    function module:SetBoxColor(c) BoxColor=c end; function module:SetTextColor(c) TextColor=c end; function module:SetLineColor(c) LineColor=c end
    function module:SetShowAllPlayers(v) ShowAllPlayers=v end; function module:SetLineOrigin(v) LineOrigin=v end
    return module
end)()

-- M1 Extender
local M1Extender = (function()
    local M = {}; local active = false; local maxRange = 100
    local Net = RS:WaitForChild("Modules"):WaitForChild("Net"); local RegisterHit = Net["RE/RegisterHit"]; local RegisterAttack = Net["RE/RegisterAttack"]
    local function getTarget()
        local myChar = lp.Character; local myRoot = myChar and myChar:FindFirstChild("HumanoidRootPart"); if not myRoot then return nil end
        local target, shortestDist = nil, maxRange
        for _, folder in pairs({workspace:FindFirstChild("Enemies"), workspace:FindFirstChild("Characters")}) do
            if folder then for _, v in pairs(folder:GetChildren()) do
                local eRoot = v:FindFirstChild("HumanoidRootPart"); local eHum = v:FindFirstChildOfClass("Humanoid")
                if v ~= myChar and eRoot and eHum and eHum.Health > 0 then local dist = (eRoot.Position - myRoot.Position).Magnitude; if dist < shortestDist then shortestDist = dist; target = v end end
            end end
        end
        return target
    end
    UserInputService.InputBegan:Connect(function(input, processed)
        if processed or not active then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            local target = getTarget(); local tool = lp.Character and lp.Character:FindFirstChildOfClass("Tool")
            if target and tool then
                local head = target:FindFirstChild("Head") or target:FindFirstChild("HumanoidRootPart")
                if head then
                    local sessionId = tostring(lp.UserId):sub(2,4) .. tostring(coroutine.running()):sub(11,15)
                    pcall(function() RegisterAttack:FireServer(); local hitData = {}; for _, part in pairs(target:GetChildren()) do if part:IsA("BasePart") then table.insert(hitData, {target, part}) end end; RegisterHit:FireServer(head, hitData, {}, sessionId) end)
                end
            end
        end
    end)
    function M:Toggle(v) active = v end; function M:SetRange(v) maxRange = v end
    return M
end)()

-- Gun Click SL
local GunClickSL = (function()
    local enabled = false; local aimPos = nil; local hookInstalled = false
    local function getClosestTarget()
        local char = lp.Character; if not char then return nil end
        local root = char:FindFirstChild("HumanoidRootPart"); if not root then return nil end
        local closest, dist = nil, math.huge; local myPos = root.Position
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= lp and player.Character then
                local targetPart = player.Character:FindFirstChild("HumanoidRootPart")
                if targetPart then local hum = player.Character:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health > 0 then local d = (targetPart.Position - myPos).Magnitude; if d < dist then dist = d; closest = targetPart end end end
            end
        end
        return closest
    end
    local function installHook()
        if hookInstalled then return end; hookInstalled = true
        if type(getrawmetatable) ~= "function" then return end
        local mt = getrawmetatable(game); local oldNamecall = mt.__namecall; setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local args = {...}; local method = getnamecallmethod()
            if enabled and aimPos and method == "FireServer" then
                local remoteName = tostring(self.Name or self)
                if remoteName:find("ShootGunEvent") then if typeof(args[1]) == "Vector3" then args[1] = aimPos.Position end; if typeof(args[2]) == "table" then args[2] = { [1] = aimPos } end end
            end
            return oldNamecall(self, unpack(args))
        end)
        setreadonly(mt, true)
    end
    local function startLoop() task.spawn(function() while enabled do aimPos = getClosestTarget(); task.wait(0.05) end end) end
    local M = {}
    function M:SetEnabled(state) if state == enabled then return end; enabled = state; if state then aimPos = nil; installHook(); startLoop() else aimPos = nil end end
    return M
end)() -- ==================== NAMELESS V30 - PART 4B-1 ====================
SilentAimModule = (function()
    local module = {}
    local MouseModule = RS:FindFirstChild("Mouse")
    local Mouse = nil
    if MouseModule then
        local ok, res = pcall(require, MouseModule)
        if ok and type(res) == "table" then Mouse = res end
    end

    local SilentAimPlayersEnabled, SilentAimNPCsEnabled = false, false
    local PredictionEnabled, PredictionAmount, ZSkillorM1 = true, 0.12, true
    local ShowFOVCircle, FOVRadius, FOVMode, AimMode, TargetPriority = false, 100, "V1", "360", "Nearest"
    local SoruAutoAimEnabled, SoruAutoAimRange, SoruTargetingMode = false, 300, "360"
    local SoruFOVType, SoruFOVRadius, SoruTargetPriority, SoruShowFOVCircle, SoruCurrentTarget = "V1", 100, "Nearest", false, nil
    local TracerEnabled, TracerColor = false, "Red"
    local tracerModel, tracerAttachment0, tracerAttachment1, tracerBeam = nil, nil, nil, nil
    local renderConnection, heartbeatConnection = nil, nil
    local currentTool, currentToolCategory = nil, "Melee"
    local PlayersPosition, NPCPosition = nil, nil
    local Selectedplayer = nil; local characterConnections = {}; local maxRange = 1000
    
    local BlacklistedKeys = {
        Melee = { Z=false, X=false, C=false },
        Sword = { Z=false, X=false },
        Fruit = { Z=false, X=false, C=false, V=false, F=false, TAP=false },
        Gun   = { Z=false, X=false }
    }
    local currentSkillKey = nil; local SKILL_KEYS = {"Z","X","C","V","F","TAP"}; local lastSkillTime = 0
    local OverrideGodhumanSanguineEnabled = true

    local function isOverrideTool(tool)
        if not tool then return false end
        local name = string.lower(tool.Name)
        if name == "godhuman" or string.find(name, "sanguine") or string.find(name, "yama") then return true end
        if currentToolCategory == "Sword" then return true end
        return false
    end

    local function faceTarget(targetPos)
        if not targetPos then return end
        local char = lp.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
        local lookVector = (Vector3.new(targetPos.X, hrp.Position.Y, targetPos.Z) - hrp.Position).Unit
        if lookVector.Magnitude < 0.001 then return end
        hrp.CFrame = CFrame.lookAt(hrp.Position, hrp.Position + lookVector, Vector3.new(0, 1, 0))
        local hum = char:FindFirstChildOfClass("Humanoid"); if hum then hum.AutoRotate = true end
    end

    local function setCurrentSkillKey(key)
        currentSkillKey = key; lastSkillTime = os.clock()
        if SilentAimPlayersEnabled or SilentAimNPCsEnabled then
            local targetPos = PlayersPosition or NPCPosition
            if targetPos then task.spawn(function() faceTarget(targetPos) end) end
        end
        task.spawn(function()
            local myTime = lastSkillTime; task.wait(1.5)
            if lastSkillTime == myTime and currentSkillKey == key then currentSkillKey = nil end
        end)
    end

    local SG = Instance.new("ScreenGui"); SG.Name="FOV_System"; SG.ResetOnSpawn=false; SG.IgnoreGuiInset=true
    if syn and syn.protect_gui then syn.protect_gui(SG); SG.Parent=game:GetService("CoreGui") elseif getgui then SG.Parent=getgui() else SG.Parent=game:GetService("CoreGui") or lp:WaitForChild("PlayerGui") end
    local FOVFrame = Instance.new("Frame"); FOVFrame.Name="FOVCircle"; FOVFrame.AnchorPoint=Vector2.new(0.5,0.5); FOVFrame.BackgroundTransparency=1; FOVFrame.Visible=false; FOVFrame.Parent=SG
    local UIStroke = Instance.new("UIStroke"); UIStroke.Color=Color3.fromRGB(255,0,0); UIStroke.Thickness=2; UIStroke.Parent=FOVFrame
    Instance.new("UICorner", FOVFrame).CornerRadius=UDim.new(1,0)
    local SoruFOVFrame = Instance.new("Frame"); SoruFOVFrame.Name="SoruFOVCircle"; SoruFOVFrame.AnchorPoint=Vector2.new(0.5,0.5); SoruFOVFrame.BackgroundTransparency=1; SoruFOVFrame.Visible=false; SoruFOVFrame.Parent=SG
    local SoruUIStroke = Instance.new("UIStroke"); SoruUIStroke.Color=Color3.fromRGB(0,255,0); SoruUIStroke.Thickness=2; SoruUIStroke.Parent=SoruFOVFrame
    Instance.new("UICorner", SoruFOVFrame).CornerRadius=UDim.new(1,0)
    module.ScreenGui = SG

    local PingService = game:GetService("Stats").Network.ServerStatsItem

    local function getToolCategory(tool)
        if not tool then return "Melee" end
        local name = string.lower(tool.Name)
        local gunNames = {"guitar","rifle","cannon","gun","slingshot","kabucha","serpent bow","bow"}
        for _,g in ipairs(gunNames) do if string.find(name,g) then return "Gun" end end
        local meleeNames = {"claw","godhuman","superhuman","talon","step","karate","breath","kung fu","combat","fist","sanguine"}
        for _,m in ipairs(meleeNames) do if string.find(name,m) then return "Melee" end end
        if string.find(name,"fruit") or string.find(name,"-") then return "Fruit" end
        return "Sword"
    end
    local function isKeyCurrentlyBlacklisted(key) if not key then return false end; local cat = currentToolCategory; if BlacklistedKeys[cat] and BlacklistedKeys[cat][key] ~= nil then return BlacklistedKeys[cat][key] end; return false end
    local function getHRP(model) if model and model:FindFirstChild("HumanoidRootPart") then return model.HumanoidRootPart end return nil end
    local function clearConnections() for _,c in ipairs(characterConnections) do pcall(function() c:Disconnect() end) end characterConnections = {} end

    local lastVelocity, lastDirection = nil, nil
    local function predicted(hrp)
        if not hrp then return nil end
        local hum = hrp.Parent:FindFirstChildOfClass("Humanoid"); if not hum or hum.Health <= 0 then return hrp.Position end
        if not PredictionEnabled then return hrp.Position end
        local vel = hrp.Velocity; local speed = vel.Magnitude
        if speed < 5 then lastVelocity = nil; lastDirection = nil; return hrp.Position end
        local currentDirection = vel.Unit
        if lastDirection then local dot = lastDirection:Dot(currentDirection); if dot < 0.7 then lastVelocity = nil; lastDirection = nil; return hrp.Position end end
        lastDirection = currentDirection; lastVelocity = vel
        local ping = 0; pcall(function() if PingService then ping = PingService:GetValue() / 1000 end end)
        ping = math.clamp(ping, 0, 0.35); local predictionFactor = PredictionAmount + ping
        if speed > 100 then predictionFactor = math.min(predictionFactor, 0.15) end
        return hrp.Position + (vel * predictionFactor)
    end

    local function isAllyWithMe(targetplayer)
        local myGui = lp:FindFirstChild("PlayerGui"); if not myGui then return false end
        local scrolling = myGui:FindFirstChild("Main") and myGui.Main:FindFirstChild("Allies") and myGui.Main.Allies:FindFirstChild("Container") and myGui.Main.Allies.Container:FindFirstChild("Allies") and myGui.Main.Allies.Container.Allies:FindFirstChild("ScrollingFrame")
        if scrolling then for _,frame in pairs(scrolling:GetDescendants()) do if frame:IsA("ImageButton") and frame.Name==targetplayer.Name then return true end end end
        return false
    end
    local function isTargetProtected(targetPlayer)
        if not targetPlayer then return false end
        local char = targetPlayer.Character; if not char then return false end
        if char:GetAttribute("SafeZone")==true or char:GetAttribute("PvpDisabled")==true or char:GetAttribute("CombatProtected")==true or char:GetAttribute("PVP")==false then return true end
        if targetPlayer:GetAttribute("SafeZone")==true or targetPlayer:GetAttribute("PvpDisabled")==true or targetPlayer:GetAttribute("CombatProtected")==true then return true end
        if char:FindFirstChild("SafeZone") or char:FindFirstChild("CombatPD") or char:FindFirstChild("PvpDisabled") then return true end
        if char:FindFirstChildWhichIsA("ForceField") then return true end
        return false
    end
    local function isEnemy(targetplayer)
        if not targetplayer or targetplayer==lp then return false end
        if isTargetProtected(targetplayer) then return false end
        local myTeam, targetTeam = lp.Team, targetplayer.Team
        if myTeam and targetTeam then
            if myTeam.Name=="Pirates" and targetTeam.Name=="Marines" then return true elseif myTeam.Name=="Marines" and targetTeam.Name=="Pirates" then return true end
            if myTeam.Name=="Pirates" and targetTeam.Name=="Pirates" then return not isAllyWithMe(targetplayer) end
            if myTeam.Name=="Marines" and targetTeam.Name=="Marines" then return false end
        end
        return true
    end
    local function getFOVCenter(mode) if mode=="V2" then return UserInputService:GetMouseLocation() end; if not camera then camera=workspace.CurrentCamera end; return camera.ViewportSize/2 end
    local function isTargetValid(hrp, lpHRP, aimMode, fovRadius, fovType)
        if not hrp or not lpHRP then return false end
        if aimMode=="180" then local dir=(hrp.Position-lpHRP.Position).Unit; if lpHRP.CFrame.LookVector:Dot(dir)<0 then return false end
        elseif aimMode=="FOV" then local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position); if not onScreen then return false end; if (Vector2.new(screenPos.X, screenPos.Y)-getFOVCenter(fovType)).Magnitude > fovRadius then return false end end
        return true
    end
    local function getClosestplayer(lpHRP)
        if not lpHRP then return nil end
        if TargetPriority=="Lock Player" then
            if Selectedplayer and Selectedplayer.Character and Selectedplayer.Character.Parent then
                if isTargetProtected(Selectedplayer) then return nil end
                local hum = Selectedplayer.Character:FindFirstChildWhichIsA("Humanoid"); local hrp = getHRP(Selectedplayer.Character)
                if hum and hum.Health>0 and hrp and isTargetValid(hrp, lpHRP, AimMode, FOVRadius, FOVMode) and (hrp.Position-lpHRP.Position).Magnitude <= maxRange then return Selectedplayer end
            end
            return nil
        end
        local valid = {}
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl~=lp and isEnemy(pl) and pl.Character and pl.Character.Parent then
                local hum = pl.Character:FindFirstChildWhichIsA("Humanoid"); local hrp = getHRP(pl.Character)
                if hum and hum.Health>0 and hrp and isTargetValid(hrp, lpHRP, AimMode, FOVRadius, FOVMode) then
                    local dist = (hrp.Position-lpHRP.Position).Magnitude
                    if dist <= maxRange then table.insert(valid, {Player=pl, Humanoid=hum, HRP=hrp, Distance=dist}) end
                end
            end
        end
        if #valid==0 then return nil end
        if AimMode == "360" or AimMode == "180" then
            if TargetPriority=="Nearest" then table.sort(valid, function(a,b) return a.Distance<b.Distance end)
            elseif TargetPriority=="Low HP" then table.sort(valid, function(a,b) return a.Humanoid.Health<b.Humanoid.Health end)
            elseif TargetPriority=="Looking At Me" then table.sort(valid, function(a,b) local dirA=(lpHRP.Position-a.HRP.Position).Unit; local lookA=a.HRP.CFrame.LookVector; local dirB=(lpHRP.Position-b.HRP.Position).Unit; local lookB=b.HRP.CFrame.LookVector; return lookA:Dot(dirA)>lookB:Dot(dirB) end) end
        else
            local center = getFOVCenter(FOVMode)
            table.sort(valid, function(a,b) local pA = camera:WorldToViewportPoint(a.HRP.Position); local pB = camera:WorldToViewportPoint(b.HRP.Position); return (Vector2.new(pA.X, pA.Y) - center).Magnitude < (Vector2.new(pB.X, pB.Y) - center).Magnitude end)
        end
        return valid[1].Player
    end -- ==================== NAMELESS V30 - PART 4B-2 ====================
    local function getClosestNPC(lpHRP)
        if not lpHRP then return nil end
        local enemiesFolder = workspace:FindFirstChild("Enemies"); if not enemiesFolder then return nil end
        local closest, closestDist = nil, math.huge
        for _,npc in ipairs(enemiesFolder:GetChildren()) do
            if npc:IsA("Model") then
                local hum = npc:FindFirstChildWhichIsA("Humanoid"); local hrp = getHRP(npc)
                if hum and hum.Health>0 and hrp and isTargetValid(hrp, lpHRP, AimMode, FOVRadius, FOVMode) then
                    local dist = (hrp.Position-lpHRP.Position).Magnitude
                    if dist<=maxRange and dist<closestDist then closestDist=dist; closest=npc end
                end
            end
        end
        return closest
    end

    local SoruPredictedPosition = nil
    local function getSoruTarget(lpHRP)
        if not lpHRP then return nil end
        local valid = {}
        for _,pl in ipairs(Players:GetPlayers()) do
            if pl~=lp and pl.Character and pl.Character.Parent then
                if not isEnemy(pl) then continue end
                local hum = pl.Character:FindFirstChildWhichIsA("Humanoid"); local hrp = getHRP(pl.Character)
                if hum and hum.Health>0 and hrp and isTargetValid(hrp, lpHRP, SoruTargetingMode, SoruFOVRadius, SoruFOVType) then
                    local dist = (hrp.Position-lpHRP.Position).Magnitude
                    if dist <= SoruAutoAimRange then table.insert(valid, {HRP=hrp, Humanoid=hum, Distance=dist}) end
                end
            end
        end
        if #valid==0 then return nil end
        if SoruTargetingMode == "360" or SoruTargetingMode == "180" then
            if SoruTargetPriority=="Nearest" then table.sort(valid, function(a,b) return a.Distance<b.Distance end)
            elseif SoruTargetPriority=="Low HP" then table.sort(valid, function(a,b) return a.Humanoid.Health<b.Humanoid.Health end)
            elseif SoruTargetPriority=="Looking At Me" then table.sort(valid, function(a,b) local dirA=(lpHRP.Position-a.HRP.Position).Unit; local lookA=a.HRP.CFrame.LookVector; local dirB=(lpHRP.Position-b.HRP.Position).Unit; local lookB=b.HRP.CFrame.LookVector; return lookA:Dot(dirA)>lookB:Dot(dirB) end) end
        else
            local center = getFOVCenter(SoruFOVType)
            table.sort(valid, function(a,b) local pA = camera:WorldToViewportPoint(a.HRP.Position); local pB = camera:WorldToViewportPoint(b.HRP.Position); return (Vector2.new(pA.X, pA.Y) - center).Magnitude < (Vector2.new(pB.X, pB.Y) - center).Magnitude end)
        end
        return valid[1].HRP
    end

    task.spawn(function()
        while true do
            task.wait(0.2)
            if SoruAutoAimEnabled then
                local myHRP = getHRP(lp.Character)
                local targetHRP = myHRP and getSoruTarget(myHRP)
                if targetHRP then SoruPredictedPosition = targetHRP.Position; SoruCurrentTarget = targetHRP
                else SoruCurrentTarget = nil; SoruPredictedPosition = nil end
            else SoruCurrentTarget = nil; SoruPredictedPosition = nil end
        end
    end)

    local function createTracer()
        if tracerModel then return end
        tracerModel = Instance.new("Model", workspace); tracerModel.Name="SilentAimTracer"
        tracerAttachment0 = Instance.new("Attachment", tracerModel); tracerAttachment1 = Instance.new("Attachment", tracerModel)
        tracerBeam = Instance.new("Beam", tracerModel)
        tracerBeam.Attachment0 = tracerAttachment0; tracerBeam.Attachment1 = tracerAttachment1
        tracerBeam.Width0=0.1; tracerBeam.Width1=0.1; tracerBeam.FaceCamera=true
        updateTracerColor()
    end
    local function destroyTracer() if tracerModel then tracerModel:Destroy(); tracerModel=nil; tracerAttachment0=nil; tracerAttachment1=nil; tracerBeam=nil end end
    local function updateTracerColor()
        if not tracerBeam then return end
        local colorMap = { Red=Color3.fromRGB(255,0,0), Green=Color3.fromRGB(0,255,0), Blue=Color3.fromRGB(0,0,255), Yellow=Color3.fromRGB(255,255,0), White=Color3.fromRGB(255,255,255) }
        local col = colorMap[TracerColor] or Color3.fromRGB(255,0,0)
        tracerBeam.Color = ColorSequence.new(col)
    end
    function module:SetTracerEnabled(state) TracerEnabled=state; if state then createTracer() else destroyTracer() end end
    function module:SetTracerColor(color) TracerColor=color; updateTracerColor() end

    local function installMouseOverride()
        local MouseModuleInstance = RS:FindFirstChild("Mouse"); if not MouseModuleInstance then return end
        local MM = nil; pcall(function() MM = require(MouseModuleInstance) end)
        if not MM or typeof(MM) ~= "table" then return end
        local realStore = { Hit = rawget(MM, "Hit"), Target = rawget(MM, "Target") }
        local mmt = getrawmetatable(MM); if mmt then setreadonly(mmt, false) else mmt = {}; setmetatable(MM, mmt) end
        rawset(MM, "Hit", nil); rawset(MM, "Target", nil)
        mmt.__index = function(self, key)
            if key == "Hit" then
                if OverrideGodhumanSanguineEnabled and (SilentAimPlayersEnabled or SilentAimNPCsEnabled) and (PlayersPosition or NPCPosition) and isOverrideTool(currentTool) and currentSkillKey == "Z" and not isKeyCurrentlyBlacklisted(currentSkillKey) then
                    local pos = PlayersPosition or NPCPosition; if pos then return CFrame.new(pos) end
                end
                return realStore.Hit
            elseif key == "Target" then
                if OverrideGodhumanSanguineEnabled and (SilentAimPlayersEnabled or SilentAimNPCsEnabled) and (PlayersPosition or NPCPosition) and isOverrideTool(currentTool) and currentSkillKey == "Z" and not isKeyCurrentlyBlacklisted(currentSkillKey) then return nil end
                return realStore.Target
            end
            return rawget(self, key)
        end
        mmt.__newindex = function(self, key, value) if key == "Hit" or key == "Target" then realStore[key] = value else rawset(self, key, value) end end
        setreadonly(mmt, true)
    end
    installMouseOverride()

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        local keyMap = { [Enum.KeyCode.Z]="Z", [Enum.KeyCode.X]="X", [Enum.KeyCode.C]="C", [Enum.KeyCode.V]="V", [Enum.KeyCode.F]="F" }
        local key = keyMap[input.KeyCode]; if key then setCurrentSkillKey(key) end
    end)

    local function hookMobileButton(btn)
        if btn:GetAttribute("Hooked") then return end; btn:SetAttribute("Hooked", true)
        local key = btn.Name; if table.find(SKILL_KEYS, key) then btn.Activated:Connect(function() setCurrentSkillKey(key) end) end
    end
    task.spawn(function()
        while not lp.PlayerGui do task.wait(0.5) end
        local pg = lp.PlayerGui; local main = pg:WaitForChild("Main",10)
        if main then
            local skills = main:WaitForChild("Skills",10)
            if skills then
                for _,wf in ipairs(skills:GetChildren()) do if wf:IsA("GuiObject") then for _,b in ipairs(wf:GetChildren()) do if b:IsA("ImageButton") or b:IsA("TextButton") then hookMobileButton(b) end end end end
                skills.ChildAdded:Connect(function(wf) if wf:IsA("GuiObject") then for _,b in ipairs(wf:GetChildren()) do if b:IsA("ImageButton") or b:IsA("TextButton") then hookMobileButton(b) end end end end)
            end
        end
    end)

    local function getSkillKeyFromArgs(args) for _,arg in ipairs(args) do if type(arg)=="string" and table.find(SKILL_KEYS, arg) then return arg end end return nil end

    local function startRenderLoop()
        if not renderConnection then
            renderConnection = RunService.RenderStepped:Connect(function()
                if ShowFOVCircle then local center=getFOVCenter(FOVMode); FOVFrame.Position=UDim2.new(0,center.X,0,center.Y); FOVFrame.Size=UDim2.new(0,FOVRadius*2,0,FOVRadius*2); FOVFrame.Visible=true else FOVFrame.Visible=false end
                if SoruShowFOVCircle then local center=getFOVCenter(SoruFOVType); SoruFOVFrame.Position=UDim2.new(0,center.X,0,center.Y); SoruFOVFrame.Size=UDim2.new(0,SoruFOVRadius*2,0,SoruFOVRadius*2); SoruFOVFrame.Visible=true else SoruFOVFrame.Visible=false end
                pcall(function()
                    local lpChar = lp.Character; if not lpChar then return end
                    local lpHRP = lpChar:FindFirstChild("HumanoidRootPart"); if not lpHRP then return end
                    if not SilentAimPlayersEnabled and not SilentAimNPCsEnabled then
                        if TracerEnabled and tracerBeam then tracerBeam.Enabled=false end; PlayersPosition = nil; NPCPosition = nil; return
                    end
                    if SilentAimPlayersEnabled then local targetplayer = getClosestplayer(lpHRP); if targetplayer and targetplayer.Character then PlayersPosition = predicted(getHRP(targetplayer.Character)) else PlayersPosition=nil end end
                    if SilentAimNPCsEnabled then local npc = getClosestNPC(lpHRP); if npc then NPCPosition = predicted(getHRP(npc)) else NPCPosition=nil end end
                    if TracerEnabled and tracerBeam and tracerAttachment0 and tracerAttachment1 then local targetPos = PlayersPosition or NPCPosition; if lpHRP and targetPos then tracerAttachment0.WorldPosition=lpHRP.Position; tracerAttachment1.WorldPosition=targetPos; tracerBeam.Enabled=true else tracerBeam.Enabled=false end end
                end)
            end)
        end
        if not heartbeatConnection then
            heartbeatConnection = RunService.Heartbeat:Connect(function()
                if not ZSkillorM1 or (not SilentAimPlayersEnabled and not SilentAimNPCsEnabled) then return end
                if currentSkillKey and isKeyCurrentlyBlacklisted(currentSkillKey) then return end
                if currentTool and (string.find(string.lower(currentTool.Name),"portal") or string.find(string.lower(currentTool.Name),"lightning")) then return end
                if not OverrideGodhumanSanguineEnabled then return end
                if not isOverrideTool(currentTool) then return end
                if currentSkillKey ~= "Z" then return end
                local targetPos = PlayersPosition or NPCPosition
                if targetPos and Mouse then local targetCFrame = CFrame.new(targetPos); pcall(function() Mouse.Hit = targetCFrame; Mouse.Target = nil end); if MouseModule then pcall(function() local MouseData = require(MouseModule); MouseData.Hit = targetCFrame; MouseData.Target = nil end) end end
            end)
        end
    end -- ==================== NAMELESS V30 - PART 4C (FINAL) ====================
        if not renderConnection then
            renderConnection = RunService.RenderStepped:Connect(function()
                if ShowFOVCircle then local center=getFOVCenter(FOVMode); FOVFrame.Position=UDim2.new(0,center.X,0,center.Y); FOVFrame.Size=UDim2.new(0,FOVRadius*2,0,FOVRadius*2); FOVFrame.Visible=true else FOVFrame.Visible=false end
                if SoruShowFOVCircle then local center=getFOVCenter(SoruFOVType); SoruFOVFrame.Position=UDim2.new(0,center.X,0,center.Y); SoruFOVFrame.Size=UDim2.new(0,SoruFOVRadius*2,0,SoruFOVRadius*2); SoruFOVFrame.Visible=true else SoruFOVFrame.Visible=false end
                pcall(function()
                    local lpChar = lp.Character; if not lpChar then return end
                    local lpHRP = lpChar:FindFirstChild("HumanoidRootPart"); if not lpHRP then return end
                    if not SilentAimPlayersEnabled and not SilentAimNPCsEnabled then
                        if TracerEnabled and tracerBeam then tracerBeam.Enabled=false end; PlayersPosition = nil; NPCPosition = nil; return
                    end
                    if SilentAimPlayersEnabled then local targetplayer = getClosestplayer(lpHRP); if targetplayer and targetplayer.Character then PlayersPosition = predicted(getHRP(targetplayer.Character)) else PlayersPosition=nil end end
                    if SilentAimNPCsEnabled then local npc = getClosestNPC(lpHRP); if npc then NPCPosition = predicted(getHRP(npc)) else NPCPosition=nil end end
                    if TracerEnabled and tracerBeam and tracerAttachment0 and tracerAttachment1 then local targetPos = PlayersPosition or NPCPosition; if lpHRP and targetPos then tracerAttachment0.WorldPosition=lpHRP.Position; tracerAttachment1.WorldPosition=targetPos; tracerBeam.Enabled=true else tracerBeam.Enabled=false end end
                end)
            end)
        end
        if not heartbeatConnection then
            heartbeatConnection = RunService.Heartbeat:Connect(function()
                if not ZSkillorM1 or (not SilentAimPlayersEnabled and not SilentAimNPCsEnabled) then return end
                if currentSkillKey and isKeyCurrentlyBlacklisted(currentSkillKey) then return end
                if currentTool and (string.find(string.lower(currentTool.Name),"portal") or string.find(string.lower(currentTool.Name),"lightning")) then return end
                if not OverrideGodhumanSanguineEnabled then return end
                if not isOverrideTool(currentTool) then return end
                if currentSkillKey ~= "Z" then return end
                local targetPos = PlayersPosition or NPCPosition
                if targetPos and Mouse then local targetCFrame = CFrame.new(targetPos); pcall(function() Mouse.Hit = targetCFrame; Mouse.Target = nil end); if MouseModule then pcall(function() local MouseData = require(MouseModule); MouseData.Hit = targetCFrame; MouseData.Target = nil end) end end
            end)
        end
    end

    local function stopRenderLoop()
        if renderConnection then renderConnection:Disconnect(); renderConnection=nil end
        if heartbeatConnection then heartbeatConnection:Disconnect(); heartbeatConnection=nil end
        FOVFrame.Visible=false; SoruFOVFrame.Visible=false; destroyTracer(); PlayersPosition = nil; NPCPosition = nil
        if Mouse then pcall(function() Mouse.Hit = CFrame.new(0,0,0) end) end
    end

    local UserMouse = lp:GetMouse()
    task.spawn(function()
        local mt = getrawmetatable(game); if not mt then return end
        local oldNamecall = mt.__namecall; local oldIndex = mt.__index
        setreadonly(mt, false)
        mt.__namecall = newcclosure(function(self, ...)
            local Method = getnamecallmethod(); local args = {...}
            if args[1]=="TAP" then return oldNamecall(self, ...) end
            local skillKey = getSkillKeyFromArgs(args)
            if skillKey then
                if SilentAimPlayersEnabled or SilentAimNPCsEnabled then local targetPos = PlayersPosition or NPCPosition; if targetPos then task.spawn(function() faceTarget(targetPos) end) end end
                setCurrentSkillKey(skillKey)
            end
            if SoruAutoAimEnabled and SoruPredictedPosition and skillKey=="C" then for i,arg in ipairs(args) do if typeof(arg)=="Vector3" then args[i]=SoruPredictedPosition end end end
            local skip = false
            if skillKey and isKeyCurrentlyBlacklisted(skillKey) then skip=true elseif not skillKey and currentSkillKey and isKeyCurrentlyBlacklisted(currentSkillKey) then skip=true end
            if not skip then
                if Method=="FireServer" then
                    if typeof(args[1])=="Vector3" then if SilentAimPlayersEnabled and PlayersPosition then args[1]=PlayersPosition elseif SilentAimNPCsEnabled and NPCPosition then args[1]=NPCPosition end end
                elseif Method=="InvokeServer" and currentTool and currentTool.Name=="Buddy Sword" then
                    if type(args[1])=="string" and table.find(Skills, args[1]) then if SilentAimPlayersEnabled and PlayersPosition then args[2]=PlayersPosition elseif SilentAimNPCsEnabled and NPCPosition then args[2]=NPCPosition end end
                end
            end
            return oldNamecall(self, unpack(args))
        end)
        mt.__index = newcclosure(function(t,k)
            if SoruAutoAimEnabled and t==UserMouse and SoruPredictedPosition then if k=="Hit" then return CFrame.new(SoruPredictedPosition) end; if k=="Target" then return nil end end
            return oldIndex(t,k)
        end)
        setreadonly(mt, true)
    end)

    local function onCharacterAdded(char)
        clearConnections()
        local hum = char:WaitForChild("Humanoid", 10)
        if hum then
            table.insert(characterConnections, hum.AnimationPlayed:Connect(function(track)
                local anim = track.Animation; local id = anim and tostring(anim.AnimationId):match("%d+"); local animName = string.lower(anim and anim.Name or "")
                if bunnyHopEnabled and (string.find(animName, "dash") or string.find(animName, "flashstep") or id == "17555632156" or id == "1846164274" or id == "1846163351") then task.spawn(function() task.wait(0.05); if hum and hum.FloorMaterial ~= Enum.Material.Air then hum:ChangeState(Enum.HumanoidStateType.Jumping) end end) end
            end))
        end
        for _,child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") then currentTool=child; currentToolCategory=getToolCategory(child); currentSkillKey=nil; table.insert(characterConnections, child.AncestryChanged:Connect(function(_,p) if not p then currentTool=nil end end)) end
        end
        table.insert(characterConnections, char.ChildAdded:Connect(function(child) if child:IsA("Tool") then currentTool=child; currentToolCategory=getToolCategory(child); currentSkillKey=nil; table.insert(characterConnections, child.AncestryChanged:Connect(function(_,p) if not p then currentTool=nil end end)) end end))
        table.insert(characterConnections, char.ChildRemoved:Connect(function(child) if child==currentTool then currentTool=nil end end))
    end
    lp.CharacterAdded:Connect(onCharacterAdded)
    if lp.Character then onCharacterAdded(lp.Character) end

    function module:SetZSkillorM1(state) ZSkillorM1=state end
    function module:SetPrediction(state) PredictionEnabled=state end
    function module:SetPredictionAmount(amt) PredictionAmount=amt end
    function module:SetDistanceLimit(num) if type(num)=="number" then maxRange=num end end
    function module:SetSelectedPlayer(playerName) if not playerName or playerName=="" then Selectedplayer=nil return end; Selectedplayer=Players:FindFirstChild(playerName) end
    function module:SetPlayerSilentAim(state) SilentAimPlayersEnabled=state; if state then startRenderLoop() elseif not SilentAimNPCsEnabled then stopRenderLoop() end end
    function module:SetNPCSilentAim(state) SilentAimNPCsEnabled=state; if state then startRenderLoop() elseif not SilentAimPlayersEnabled then stopRenderLoop() end end
    function module:SetBlacklistKey(cat,key,state) if BlacklistedKeys[cat] and BlacklistedKeys[cat][key]~=nil then BlacklistedKeys[cat][key]=state end end
    function module:SetAimMode(mode) AimMode=mode end
    function module:SetTargetPriority(prio) TargetPriority=prio end
    function module:SetShowFOVCircle(state) ShowFOVCircle=state end
    function module:SetFOVRadius(num) FOVRadius=num end
    function module:SetFOVMode(mode) FOVMode=mode end
    function module:SetSoruAutoAim(state) SoruAutoAimEnabled=state; if not state then SoruCurrentTarget=nil; SoruPredictedPosition=nil end end
    function module:SetSoruRange(r) SoruAutoAimRange=r end
    function module:SetSoruAimMode(mode) SoruTargetingMode=mode end
    function module:SetSoruFOVType(mode) SoruFOVType=mode end
    function module:SetSoruFOVRadius(r) SoruFOVRadius=r end
    function module:SetSoruPriority(p) SoruTargetPriority=p end
    function module:SetSoruShowFOVCircle(state) SoruShowFOVCircle=state end
    return module
end)()

-- ==================== UI TABS ====================
local MacroTab = Tabs.Macro
local MacroLeft = MacroTab:AddLeftGroupbox("Automation")
MacroLeft:AddToggle("AHKSoru", { Text="Enable AHK Soru", Default=false, Callback=function(v) if v then LoadAHKsoru() else UnloadAHKsoru() end end })
MacroLeft:AddToggle("AHKCombo", { Text="Enable AHK Combo", Default=false, Callback=function(v) if v then LoadAHKComboScript() else UnloadAHKComboScript() end end })

local SoruGroup = MacroTab:AddRightGroupbox("Soru Auto Aim")
SoruGroup:AddToggle("SoruToggle", { Text="Enable Soru Auto Aim", Default=false, Callback=function(v) SilentAimModule:SetSoruAutoAim(v) end })
SoruGroup:AddDropdown("SoruAimMode", { Values={"360","180","FOV"}, Default="360", Text="Aim Mode", Callback=function(v) SilentAimModule:SetSoruAimMode(v) end })
SoruGroup:AddDropdown("SoruFOVType", { Values={"V1","V2"}, Default="V1", Text="FOV Type", Callback=function(v) SilentAimModule:SetSoruFOVType(v) end })
SoruGroup:AddDropdown("SoruPriority", { Values={"Nearest","Low HP","Looking At Me"}, Default="Nearest", Text="Target Priority", Callback=function(v) SilentAimModule:SetSoruPriority(v) end })
SoruGroup:AddSlider("SoruFOVRadius", { Text="FOV Radius", Default=100, Min=10, Max=800, Rounding=0, Callback=function(v) SilentAimModule:SetSoruFOVRadius(v) end })
SoruGroup:AddSlider("SoruRange", { Text="Max Range", Default=300, Min=50, Max=500, Rounding=0, Suffix=" studs", Callback=function(v) SilentAimModule:SetSoruRange(v) end })
SoruGroup:AddToggle("SoruShowFOV", { Text="Show FOV Circle", Default=false, Callback=function(v) SilentAimModule:SetSoruShowFOVCircle(v) end })

local GlitchTab = Tabs.Glitch
local SanguineGroup = GlitchTab:AddLeftGroupbox("Sanguine Z Boost")
SanguineGroup:AddToggle("SanguineToggle", { Text="Enable Sanguine", Default=false, Callback=function(v) multiEnabled=v; if not v then multiCharging=false; multiChargeStart=0 end end })
SanguineGroup:AddSlider("SanguinePower", { Text="Power", Default=400, Min=100, Max=5000, Rounding=0, Callback=function(v) multiPower=v end })
SanguineGroup:AddSlider("SanguineDuration", { Text="Duration (cs)", Default=90, Min=10, Max=200, Rounding=0, Callback=function(v) multiDuration=v/100 end })
SanguineGroup:AddSlider("SanguineCharge", { Text="Min Charge", Default=10, Min=1, Max=50, Rounding=0, Callback=function(v) multiRequiredCharge=v/10 end })

local DTalonGroup = GlitchTab:AddLeftGroupbox("DTalon Z Boost")
DTalonGroup:AddToggle("DTalonToggle", { Text="Enable DTalon", Default=false, Callback=function(v) dtalonEnabled=v; if not v then dtalonCharging=false; dtalonChargeStart=0 end end })
DTalonGroup:AddSlider("DTalonPower", { Text="Power", Default=400, Min=100, Max=5000, Rounding=0, Callback=function(v) dtalonPower=v end })
DTalonGroup:AddSlider("DTalonDuration", { Text="Duration (cs)", Default=90, Min=10, Max=200, Rounding=0, Callback=function(v) dtalonDuration=v/100 end })
DTalonGroup:AddSlider("DTalonCharge", { Text="Min Charge", Default=10, Min=1, Max=50, Rounding=0, Callback=function(v) dtalonRequiredCharge=v/10 end })

local BigSkinGroup = GlitchTab:AddLeftGroupbox("Big Skin Bug")
BigSkinGroup:AddToggle("BigSkinToggle", { Text="Enable Big Skin Bug", Default=false, Callback=function(v) if v then enableBigSkin() else disableBigSkin() end end })

local DiamondGroup = GlitchTab:AddRightGroupbox("Diamond Boost")
DiamondGroup:AddToggle("DiamondToggle", { Text="Enable Diamond", Default=false, Callback=function(v) diamondEnabled=v; if not v then diamondCharging=false; diamondChargeStart=0 end end })
DiamondGroup:AddSlider("DiamondPower", { Text="Power", Default=250, Min=100, Max=5000, Rounding=0, Callback=function(v) diamondPower=v end })
DiamondGroup:AddSlider("DiamondDuration", { Text="Duration (cs)", Default=30, Min=10, Max=200, Rounding=0, Callback=function(v) diamondDuration=v/100 end })
DiamondGroup:AddSlider("DiamondCharge", { Text="Min Charge", Default=10, Min=1, Max=50, Rounding=0, Callback=function(v) diamondRequiredCharge=v/10 end })

local EClawGroup = GlitchTab:AddRightGroupbox("EClaw X Boost")
EClawGroup:AddToggle("EClawToggle", { Text="Enable EClaw Boost", Default=false, Callback=function(v) EClawBoost:Toggle(v) end })
EClawGroup:AddSlider("EClawPower", { Text="Power", Default=400, Min=100, Max=5000, Rounding=0, Callback=function(v) EClawBoost:SetPower(v) end })
EClawGroup:AddSlider("EClawDuration", { Text="Duration (cs)", Default=170, Min=10, Max=200, Rounding=0, Callback=function(v) EClawBoost:SetDuration(v/100) end })
EClawGroup:AddSlider("EClawCharge", { Text="Min Charge", Default=0, Min=0, Max=50, Rounding=0, Callback=function(v) EClawBoost:SetRequiredCharge(v/10) end })

local MoveTab = Tabs.Movement
local MoveGroup = MoveTab:AddLeftGroupbox("Player Movement")
MoveGroup:AddToggle("BunnyHopToggle", { Text="Bunny Hop", Default=false, Callback=function(v) bunnyHopEnabled=v end })

local SuperJumpGroup = MoveTab:AddLeftGroupbox("Super Jump")
SuperJumpGroup:AddToggle("SuperJumpToggle", { Text="Enable Super Jump", Default=false, Callback=function(v) superJumpEnabled=v; updateSuperJumpState(); if not v then resetSuperJumpToNormal(); if superJumpButton then destroySuperJumpButton() end end end })
SuperJumpGroup:AddDropdown("SuperJumpMode", { Values={"V1","V2","V3"}, Default="V1", Text="", Callback=function(v) superJumpMode=v; updateSuperJumpState() end })
SuperJumpGroup:AddSlider("SuperJumpPower", { Text="Jump Power", Default=150, Min=50, Max=500, Rounding=0, Callback=function(v) superJumpPower=v; if superJumpEnabled and superJumpMode=="V1" then applySuperJumpV1() end end })

local DashLengthGroup = MoveTab:AddRightGroupbox("Dash Length")
DashLengthGroup:AddToggle("DashToggle", { Text="Enable Dash Length", Default=false, Callback=function(v)
    dashLengthEnabled=v
    if v then
        if dashLengthConnection then task.cancel(dashLengthConnection) end
        dashLengthConnection = task.spawn(function() while dashLengthEnabled do task.wait(0.1); local character = lp.Character; if character then local cv = character:GetAttribute("DashLength"); if cv ~= dashLengthValue then character:SetAttribute("DashLength", dashLengthValue); character:SetAttribute("DashLengthAir", dashLengthValue) end end end end)
    else
        if dashLengthConnection then task.cancel(dashLengthConnection); dashLengthConnection=nil end
        if lp.Character then lp.Character:SetAttribute("DashLength",1); lp.Character:SetAttribute("DashLengthAir",1) end
    end
end })
DashLengthGroup:AddSlider("DashLengthValue", { Text="Dash Distance", Default=1, Min=1, Max=300, Rounding=0, Callback=function(v) dashLengthValue=v end })

local SpeedGroup = MoveTab:AddLeftGroupbox("Speed Hack")
SpeedGroup:AddToggle("SpeedHackToggle", { Text="Enable Speed Hack", Default=false, Callback=function(v) if v then StartSpeedHack(); CreateSpeedMiniToggle() else StopSpeedHack(); DestroySpeedMiniToggle() end end })
SpeedGroup:AddDropdown("SpeedMode", { Values={"WalkSpeed","CFrame","Velocity","TP-Flash","AnimSpeed"}, Default="WalkSpeed", Text="Mode", Callback=function(v) speedSettings.mode=v end })
SpeedGroup:AddSlider("SpeedHackValue", { Text="Speed Value", Default=50, Min=16, Max=500, Rounding=0, Callback=function(v) speedSettings.speedValue=v end })

local FlyGroup = MoveTab:AddRightGroupbox("Fly")
FlyGroup:AddToggle("FlyToggle", { Text="Toggle Fly", Default=false, Callback=function(v) if v then StartFly(); CreateFlyMiniToggle() else StopFly(); DestroyFlyMiniToggle() end; flySettings.flyActive=v end })
FlyGroup:AddDropdown("FlyMode", { Values={"CFrame","Velocity"}, Default="CFrame", Text="Mode", Callback=function(v) flySettings.mode=v; if flySettings.flyActive then StopFly(); StartFly() end end })
FlyGroup:AddSlider("FlySpeed", { Text="Speed", Default=50, Min=10, Max=500, Rounding=0, Callback=function(v) flySettings.speed=v end })
FlyGroup:AddToggle("NoClipToggle", { Text="NoClip", Default=false, Callback=function(v) flySettings.noclipActive=v; if v then StartNoClip() else StopNoClip() end end })

local DashGlitchGroup = MoveTab:AddRightGroupbox("Skull Guitar Dash")
DashGlitchGroup:AddToggle("DashGlitchToggle", { Text="Enable Dash Glitch", Default=false, Callback=function(v) DashGlitch:SetEnabled(v) end })
DashGlitchGroup:AddDropdown("DashGlitchVersion", { Values={"V1","V2"}, Default="V1", Text="Version", Callback=function(v) DashGlitch:SetVersion(v) end })
DashGlitchGroup:AddSlider("DashGlitchCooldown", { Text="Cooldown", Default=1.5, Min=0.2, Max=5, Rounding=1, Callback=function(v) DashGlitch:SetCooldown(v) end })
DashGlitchGroup:AddSlider("DashGlitchDashLength", { Text="Dash Length", Default=190, Min=10, Max=500, Rounding=0, Callback=function(v) DashGlitch:SetDashLength(v) end })
DashGlitchGroup:AddSlider("DashGlitchSpeedBoost", { Text="Propulsion", Default=350, Min=50, Max=1000, Rounding=0, Callback=function(v) DashGlitch:SetSpeedBoost(v) end })
DashGlitchGroup:AddSlider("DashGlitchAirSpeed", { Text="Air Speed", Default=400, Min=50, Max=1000, Rounding=0, Callback=function(v) DashGlitch:SetAirWalkSpeed(v) end })

lp.CharacterAdded:Connect(function(char) if dashLengthEnabled then task.wait(0.1); char:SetAttribute("DashLength", dashLengthValue); char:SetAttribute("DashLengthAir", dashLengthValue) end end)

local ApparenceTab = Tabs.Apparence
local HeadlessGroup = ApparenceTab:AddLeftGroupbox("Fake Headless")
HeadlessGroup:AddDropdown("HeadlessVersion", { Values={"V1","V2"}, Default="V1", Text="Version", Callback=function(v) fakeHeadlessVersion=v; if fakeHeadlessEnabled then removeFakeHeadless(); applyFakeHeadless() end end })
HeadlessGroup:AddToggle("HeadlessToggle", { Text="Enable Fake Headless", Default=false, Callback=function(v) fakeHeadlessEnabled=v; if v then applyFakeHeadless() else removeFakeHeadless() end end })

local KorbloxGroup = ApparenceTab:AddRightGroupbox("Fake Korblox")
KorbloxGroup:AddDropdown("KorbloxVersion", { Values={"V1","V2"}, Default="V1", Text="Version", Callback=function(v) fakeKorbloxVersion=v; if fakeKorbloxEnabled then removeFakeKorblox(); applyFakeKorblox() end end })
KorbloxGroup:AddToggle("KorbloxToggle", { Text="Enable Fake Korblox", Default=false, Callback=function(v) fakeKorbloxEnabled=v; if v then applyFakeKorblox() else removeFakeKorblox() end end })

local MiscTab = Tabs.Misc
local FontChangerGroup = MiscTab:AddLeftGroupbox("Font Changer")
local fontList = {}
for _,v in Enum.Font:GetEnumItems() do table.insert(fontList, tostring(v):split(".")[3]) end
FontChangerGroup:AddDropdown("FontStyle", { Values=fontList, Default="GothamSsm", Text="Font Style", Callback=function(v) fontPreset=v; if fontChangerEnabled then disableFonts(); enableFonts() end end })
FontChangerGroup:AddToggle("FontChangerToggle", { Text="Enable Font Changer", Default=false, Callback=function(v) fontChangerEnabled=v; if v then enableFonts() else disableFonts() end end })

local AntiMoverGroup = MiscTab:AddRightGroupbox("Anti Mover")
AntiMoverGroup:AddToggle("AntiMoverToggle", { Text="Enable Anti Mover", Default=false, Callback=function(v)
    antiMoverEnabled=v
    if v then
        local function add(char) if not char:FindFirstChild("AntiMover") then Instance.new("Folder", char).Name="AntiMover" end end
        if lp.Character then add(lp.Character) end
        antiMoverConnection = lp.CharacterAdded:Connect(add)
    else
        if antiMoverConnection then antiMoverConnection:Disconnect(); antiMoverConnection=nil end
        if lp.Character and lp.Character:FindFirstChild("AntiMover") then lp.Character.AntiMover:Destroy() end
    end
end })

local UnbreakableGroup = MiscTab:AddRightGroupbox("Unbreakable")
UnbreakableGroup:AddToggle("UnbreakableToggle", { Text="Enable Unbreakable", Default=false, Callback=function(v)
    unbreakableEnabled=v
    if v then
        if unbreakableConnection then task.cancel(unbreakableConnection) end
        unbreakableConnection = task.spawn(function() while unbreakableEnabled do task.wait(0.1); if lp.Character and lp.Character:GetAttribute("UnbreakableAll")~=true then lp.Character:SetAttribute("UnbreakableAll", true) end end end)
    else
        if unbreakableConnection then task.cancel(unbreakableConnection); unbreakableConnection=nil end
        if lp.Character then lp.Character:SetAttribute("UnbreakableAll", false) end
    end
end })

local NoGFXGroup = MiscTab:AddRightGroupbox("No GFX")
NoGFXGroup:AddDropdown("NoGFXMode", { Values={"Off","V1","V2"}, Default="Off", Text="No GFX Mode", Callback=function(v) setNoGfxMode(v) end })

local DeleteShipGroup = MiscTab:AddLeftGroupbox("Delete Ship")
DeleteShipGroup:AddToggle("DeleteShipToggle", { Text="Enable Delete Ship", Default=false, Callback=function(v) deleteShipActive = v; if v then startDeleteShipLoop() end end })

local WalkOnWaterGroup = MiscTab:AddLeftGroupbox("Walk on Water")
WalkOnWaterGroup:AddToggle("WalkOnWaterToggle", { Text="Enable Walk on Water", Default=false, Callback=function(v) WalkOnWaterEnabled = v end })

local AntiLavaGroup = MiscTab:AddLeftGroupbox("Anti Lava")
AntiLavaGroup:AddToggle("AntiLavaToggle", { Text="Enable Anti Lava", Default=false, Callback=function(v) antiLavaActive = v; if v then startAntiLava() else stopAntiLava() end end })

local ESPTab = Tabs.ESP
local ESPGroup = ESPTab:AddLeftGroupbox("ESP Settings")
local ESPVisualGroup = ESPTab:AddRightGroupbox("ESP Appearance")
ESPGroup:AddToggle("ESPToggle", { Text="Enable ESP", Default=false, Callback=function(v) ESPModule:SetESPEnabled(v) end })
ESPGroup:AddToggle("ShowBox", { Text="Show Box", Default=true, Callback=function(v) ESPModule:SetShowBox(v) end })
ESPGroup:AddToggle("ShowName", { Text="Show Name", Default=true, Callback=function(v) ESPModule:SetShowName(v) end })
ESPGroup:AddToggle("ShowDistance", { Text="Show Distance", Default=true, Callback=function(v) ESPModule:SetShowDistance(v) end })
ESPGroup:AddToggle("ShowHealth", { Text="Show Health Bar", Default=true, Callback=function(v) ESPModule:SetShowHealth(v) end })
ESPGroup:AddToggle("ShowAllPlayers", { Text="Show All Players", Default=false, Callback=function(v) ESPModule:SetShowAllPlayers(v) end })
ESPGroup:AddDropdown("LineOrigin", { Values={"Player","Center","Top"}, Default="Player", Text="Line Origin", Callback=function(v) ESPModule:SetLineOrigin(v) end })
ESPVisualGroup:AddToggle("ShowLine", { Text="Show Tracers (Lines)", Default=true, Callback=function(v) ESPModule:SetShowLine(v) end })
ESPVisualGroup:AddDropdown("BoxColor", { Values={"Red","Green","Blue","Yellow","White","Cyan","Magenta"}, Default="Red", Text="Box Color", Callback=function(v) ESPModule:SetBoxColor(v) end })
ESPVisualGroup:AddDropdown("TextColor", { Values={"Red","Green","Blue","Yellow","White","Cyan","Magenta"}, Default="White", Text="Text Color", Callback=function(v) ESPModule:SetTextColor(v) end })
ESPVisualGroup:AddDropdown("LineColor", { Values={"Red","Green","Blue","Yellow","White","Cyan","Magenta"}, Default="Red", Text="Line Color", Callback=function(v) ESPModule:SetLineColor(v) end })

local SA = Tabs.SilentAim
local MainGroup = SA:AddLeftGroupbox("Main")
MainGroup:AddToggle("EnablePlayerAim", { Text="Player Silent Aim", Default=false, Callback=function(v) SilentAimModule:SetPlayerSilentAim(v) end })
MainGroup:AddToggle("EnableNPCAim", { Text="NPC Silent Aim", Default=false, Callback=function(v) SilentAimModule:SetNPCSilentAim(v) end })

local TargetGroup = SA:AddLeftGroupbox("Target Settings")
TargetGroup:AddDropdown("AimModeSelection", { Values={"360","180","FOV"}, Default="360", Text="Aim Angle Mode", Callback=function(v) SilentAimModule:SetAimMode(v) end })
TargetGroup:AddDropdown("PrioritySelection", { Values={"Nearest","Low HP","Looking At Me","Lock Player"}, Default="Nearest", Text="Target Priority", Callback=function(v) SilentAimModule:SetTargetPriority(v) end })

local FOVGroup = SA:AddLeftGroupbox("FOV Settings")
FOVGroup:AddToggle("ShowFOVCircle", { Text="Show FOV Circle", Default=false, Callback=function(v) SilentAimModule:SetShowFOVCircle(v) end })
FOVGroup:AddDropdown("FOVModeSelection", { Values={"V1","V2"}, Default="V1", Text="FOV Mode", Callback=function(v) SilentAimModule:SetFOVMode(v) end })
FOVGroup:AddSlider("FOVRadiusSize", { Text="FOV Radius Size", Default=100, Min=10, Max=800, Rounding=0, Callback=function(v) SilentAimModule:SetFOVRadius(v) end })

local M1ExtGroup = SA:AddRightGroupbox("M1 Extender")
M1ExtGroup:AddToggle("M1ExtenderToggle", { Text="Enable M1 Extender", Default=false, Callback=function(v) M1Extender:Toggle(v) end })
M1ExtGroup:AddSlider("M1ExtenderRange", { Text="Extender Range", Default=50, Min=10, Max=100, Rounding=0, Callback=function(v) M1Extender:SetRange(v) end })

local GunGroup = SA:AddRightGroupbox("Gun Click SL")
GunGroup:AddToggle("GunClickSLToggle", { Text="Enable Gun Click SL", Default=false, Callback=function(v) GunClickSL:SetEnabled(v) end })

local OptionsGroup = SA:AddRightGroupbox("Options")
local PlayerDropdown = OptionsGroup:AddDropdown("LockPlayerSelect", { Values={"None"}, Default="None", Text="Target Player List", Callback=function(v) SilentAimModule:SetSelectedPlayer(v) end })
local function refreshPlayerList()
    local list = {"None"}
    for _,p in ipairs(Players:GetPlayers()) do if p~=lp then table.insert(list, p.Name) end end
    PlayerDropdown:SetValues(list)
end
task.spawn(function() while true do refreshPlayerList(); task.wait(5) end end)
OptionsGroup:AddButton("Refresh Player List", refreshPlayerList)
OptionsGroup:AddSlider("MaxRange", { Text="Max Range", Default=1000, Min=100, Max=3000, Rounding=0, Callback=function(v) SilentAimModule:SetDistanceLimit(v) end })
OptionsGroup:AddToggle("EnableTracer", { Text="Enable Tracer", Default=false, Callback=function(v) SilentAimModule:SetTracerEnabled(v) end })
OptionsGroup:AddDropdown("TracerColor", { Values={"Red","Green","Blue","Yellow","White"}, Default="Red", Text="Tracer Color", Callback=function(v) SilentAimModule:SetTracerColor(v) end })

local BLTab = Tabs.SABlacklist
local BlacklistLeft = BLTab:AddLeftGroupbox("Blacklist Melee & Fruit")
local BlacklistRight = BLTab:AddRightGroupbox("Blacklist Swords & Guns")
BlacklistLeft:AddLabel("--- MELEES ---")
for _,key in ipairs({"Z","X","C"}) do BlacklistLeft:AddToggle("B_Melee_"..key, { Text="Melee: Blacklist "..key, Default=false, Callback=function(v) SilentAimModule:SetBlacklistKey("Melee", key, v) end }) end
BlacklistLeft:AddLabel("--- FRUITS ---")
for _,key in ipairs({"Z","X","C","V","F","TAP"}) do BlacklistLeft:AddToggle("B_Fruit_"..key, { Text="Fruit: Blacklist "..key, Default=false, Callback=function(v) SilentAimModule:SetBlacklistKey("Fruit", key, v) end }) end
BlacklistRight:AddLabel("--- SWORDS ---")
for _,key in ipairs({"Z","X"}) do BlacklistRight:AddToggle("B_Sword_"..key, { Text="Sword: Blacklist "..key, Default=false, Callback=function(v) SilentAimModule:SetBlacklistKey("Sword", key, v) end }) end
BlacklistRight:AddLabel("--- GUNS ---")
for _,key in ipairs({"Z","X"}) do BlacklistRight:AddToggle("B_Gun_"..key, { Text="Gun: Blacklist "..key, Default=false, Callback=function(v) SilentAimModule:SetBlacklistKey("Gun", key, v) end }) end

local function closeTheScript()
    _G.NamelessLoaded = false; _G.NamelessAuthToken = nil; _G.NamelessScriptBasiqueRunning = nil; _G.NamelessAHKRunning = nil; _G.NamelessComboRunning = nil
    pcall(UnloadAHKsoru); pcall(UnloadAHKComboScript)
    pcall(function() Library:Unload() end)
    pcall(function()
        local containers = {lp:FindFirstChild("PlayerGui"), game:GetService("CoreGui")}
        if get_hidden_gui then table.insert(containers, get_hidden_gui()) end
        for _, parent in ipairs(containers) do if parent then for _, g in pairs(parent:GetChildren()) do if g:IsA("ScreenGui") and -- ==================== NAMELESS V30 - PART 4D (FINAL PART) ====================
                (g.Name:find("Nameless") or g.Name:find("nameless") or g.Name:find("AHK") or g.Name:find("NM_Notify") or g.Name:find("Obsidian") or g.Name:find("Linoria")) then
                        g:Destroy()
                    end
                end
            end
        end
    end)
end

local MenuGroup = Tabs.Settings:AddLeftGroupbox("Menu")
MenuGroup:AddButton("Unload", function() Library:Unload() end)
MenuGroup:AddButton("Close The Script", closeTheScript)
MenuGroup:AddLabel("Menu bind"):AddKeyPicker("MenuKeybind", { Default="End", NoUI=true, Text="Menu keybind" })
Library.ToggleKeybind = Options.MenuKeybind

ThemeManager:SetLibrary(Library)
SaveManager:SetLibrary(Library)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({"MenuKeybind"})
ThemeManager:SetFolder("LinoriaMobile")
SaveManager:SetFolder("LinoriaMobile/game")
ThemeManager:ApplyToGroupbox(MenuGroup)
SaveManager:BuildConfigSection(Tabs.Settings)

SaveManager:LoadAutoloadConfig()
task.wait(0.5)
for _,cat in ipairs({"Melee","Sword","Fruit","Gun"}) do
    local keys = {}
    if cat=="Melee" then keys={"Z","X","C"} elseif cat=="Sword" then keys={"Z","X"} elseif cat=="Fruit" then keys={"Z","X","C","V","F","TAP"} elseif cat=="Gun" then keys={"Z","X"} end
    for _,key in ipairs(keys) do
        local toggleName = "B_"..cat.."_"..key
        if Options[toggleName] then SilentAimModule:SetBlacklistKey(cat, key, Options[toggleName].Value) end
    end
end

-- Chat Commands
local function onChatted(msg)
    local msgLower = msg:lower()
    if not msgLower:match("^/e%s+") then return end
    local command = msgLower:gsub("^/e%s+", ""):gsub("%s+", " "):gsub("^%s*(.-)%s*$", "%1")
    if command == "hide" then
        if Library.ScreenGui then Library.ScreenGui.Enabled = false end
    elseif command == "unhide" or command == "show" then
        if Library.ScreenGui then Library.ScreenGui.Enabled = true end
    end
end

lp.Chatted:Connect(onChatted)
print("[Nameless V30] Loaded Successfully!")
