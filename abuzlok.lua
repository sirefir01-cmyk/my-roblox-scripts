--[[
    Violence District Cheat Script
    Features: ESP | Infinite Heal | Fly | Noclip
    Author: Custom
    WARNING: Use at your own risk. Violates Roblox ToS.
--]]

local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local UserInputService   = game:GetService("UserInputService")
local LocalPlayer        = Players.LocalPlayer
local Camera             = workspace.CurrentCamera

-- ============ CONFIG ============
local Config = {
    ESP          = true,
    ESPColor     = Color3.fromRGB(255, 60, 60),
    ShowHealth   = true,
    ShowDistance = true,
    InfiniteHeal = true,
    Fly          = false,
    FlySpeed     = 60,
    Noclip       = false,
}

-- ============ GUI ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VD_Hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 220, 0, 260)
Main.Position = UDim2.new(0, 20, 0, 100)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Main.BorderSizePixel = 0
Main.Active = true
Main.Draggable = true
Main.Parent = ScreenGui

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = Main

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 32)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
Title.Text = "Violence District | Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 8)
TitleCorner.Parent = Title

-- ============ TOGGLE ============
local yOffset = 40
local function makeToggle(label, default, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.9, 0, 0, 34)
    btn.Position = UDim2.new(0.05, 0, 0, yOffset)
    btn.BackgroundColor3 = default and Color3.fromRGB(0, 140, 70) or Color3.fromRGB(140, 40, 40)
    btn.Text = label .. ": " .. (default and "ON" or "OFF")
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.Parent = Main

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 6)
    c.Parent = btn

    btn.MouseButton1Click:Connect(function()
        default = not default
        btn.BackgroundColor3 = default and Color3.fromRGB(0, 140, 70) or Color3.fromRGB(140, 40, 40)
        btn.Text = label .. ": " .. (default and "ON" or "OFF")
        callback(default)
    end)

    yOffset = yOffset + 38
end

-- ============ ESP ============
local ESPData = {}

local function buildESP(player)
    if player == LocalPlayer then return end
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    local highlight = Instance.new("Highlight")
    highlight.Name = "VD_ESP"
    highlight.FillColor = Config.ESPColor
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.55
    highlight.OutlineTransparency = 0
    highlight.Adornee = char
    highlight.Parent = char

    local bb = Instance.new("BillboardGui")
    bb.Name = "VD_BB"
    bb.Size = UDim2.new(0, 220, 0, 46)
    bb.StudsOffset = Vector3.new(0, 3.2, 0)
    bb.AlwaysOnTop = true
    bb.Adornee = root
    bb.Parent = char

    local nameL = Instance.new("TextLabel")
    nameL.Size = UDim2.new(1, 0, 0, 22)
    nameL.BackgroundTransparency = 1
    nameL.Text = player.Name
    nameL.TextColor3 = Color3.fromRGB(255, 255, 255)
    nameL.TextStrokeTransparency = 0
    nameL.Font = Enum.Font.GothamBold
    nameL.TextSize = 14
    nameL.Parent = bb

    local infoL = Instance.new("TextLabel")
    infoL.Size = UDim2.new(1, 0, 0, 18)
    infoL.Position = UDim2.new(0, 0, 0, 22)
    infoL.BackgroundTransparency = 1
    infoL.Text = ""
    infoL.TextColor3 = Color3.fromRGB(255, 220, 90)
    infoL.TextStrokeTransparency = 0
    infoL.Font = Enum.Font.Gotham
    infoL.TextSize = 12
    infoL.Parent = bb

    ESPData[player] = {Highlight=highlight, BB=bb, Info=infoL, Hum=hum, Root=root, Char=char}
end

local function destroyESP(player)
    if ESPData[player] then
        if ESPData[player].Highlight then ESPData[player].Highlight:Destroy() end
        if ESPData[player].BB then ESPData[player].BB:Destroy() end
        ESPData[player] = nil
    end
end

-- ESP обновление
RunService.RenderStepped:Connect(function()
    if not Config.ESP then return end
    for plr, data in pairs(ESPData) do
        if data.Char and data.Char.Parent then
            local root = data.Char:FindFirstChild("HumanoidRootPart")
            local hum  = data.Char:FindFirstChildOfClass("Humanoid")
            if root and hum then
                data.BB.Adornee = root
                local dist = math.floor((root.Position - Camera.CFrame.Position).Magnitude)
                local hp   = math.floor(hum.Health)
                local mhp  = math.floor(hum.MaxHealth)

                local txt = ""
                if Config.ShowHealth then txt = "HP: "..hp.."/"..mhp end
                if Config.ShowDistance then
                    txt = txt .. (txt ~= "" and " | " or "") .. "Dist: "..dist
                end
                data.Info.Text = txt

                if hp <= 0 then
                    data.Highlight.FillColor = Color3.fromRGB(120,120,120)
                elseif hp < mhp * 0.35 then
                    data.Highlight.FillColor = Color3.fromRGB(255, 0, 0)
                elseif hp < mhp * 0.7 then
                    data.Highlight.FillColor = Color3.fromRGB(255, 170, 0)
                else
                    data.Highlight.FillColor = Config.ESPColor
                end
            end
        else
            destroyESP(plr)
        end
    end
end)

-- Подключаем игроков
local function hookPlayer(plr)
    if plr == LocalPlayer then return end
    plr.CharacterAdded:Connect(function()
        task.wait(0.8)
        if Config.ESP then buildESP(plr) end
    end)
    if plr.Character then
        task.wait(0.5)
        if Config.ESP then buildESP(plr) end
    end
end

for _, plr in ipairs(Players:GetPlayers()) do hookPlayer(plr) end
Players.PlayerAdded:Connect(hookPlayer)
Players.PlayerRemoving:Connect(destroyESP)

-- ============ INFINITE HEAL ============
-- Прямое восстановление HP каждый кадр.
-- Дополнительно пытаемся вызывать возможные heal-ремоуты, если найдутся.
local healRemotes = {}

local function collectHealRemotes()
    for _, obj in ipairs(game:GetDescendants()) do
        if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
            local n = obj.Name:lower()
            if n:find("heal") or n:find("regen") or n:find("health") or n:find("revive") then
                table.insert(healRemotes, obj)
            end
        end
    end
end

collectHealRemotes()

task.spawn(function()
    while task.wait(0.05) do
        if not Config.InfiniteHeal then continue end
        local char = LocalPlayer.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 and hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
        -- попытка прожать heal-ремоуты (если игра использует их)
        for _, r in ipairs(healRemotes) do
            pcall(function()
                if r:IsA("RemoteEvent") then
                    r:FireServer()
                else
                    r:InvokeServer()
                end
            end)
        end
    end
end)

-- ============ FLY ============
local flyBV, flyBG, flyConn

local function stopFly()
    if flyConn then flyConn:Disconnect() flyConn = nil end
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
    local char = LocalPlayer.Character
    if char then
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
    end
end

local function startFly()
    stopFly()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local hum  = char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    flyBV = Instance.new("BodyVelocity")
    flyBV.Name = "VD_FlyBV"
    flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = root

    flyBG = Instance.new("BodyGyro")
    flyBG.Name = "VD_FlyBG"
    flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyBG.P = 1e4
    flyBG.CFrame = root.CFrame
    flyBG.Parent = root

    hum.PlatformStand = true

    flyConn = RunService.RenderStepped:Connect(function()
        if not Config.Fly or not root.Parent then
            stopFly()
            return
        end
        local dir = Vector3.zero
        local cf  = Camera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cf.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cf.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then dir -= Vector3.new(0,1,0) end
        if dir.Magnitude > 0 then dir = dir.Unit end
        flyBV.Velocity = dir * Config.FlySpeed
        flyBG.CFrame = cf
    end)
end

-- ============ NOCLIP ============
local noclipConn

local function stopNoclip()
    if noclipConn then noclipConn:Disconnect() noclipConn = nil end
end

local function startNoclip()
    stopNoclip()
    noclipConn = RunService.Stepped:Connect(function()
        if not Config.Noclip then return end
        local char = LocalPlayer.Character
        if not char then return end
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then
                p.CanCollide = false
            end
        end
    end)
end

-- ============ GUI CALLBACKS ============
makeToggle("ESP", Config.ESP, function(state)
    Config.ESP = state
    if state then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then buildESP(plr) end
        end
    else
        for plr, _ in pairs(ESPData) do destroyESP(plr) end
    end
end)

makeToggle("Infinite Heal", Config.InfiniteHeal, function(state)
    Config.InfiniteHeal = state
end)

makeToggle("Fly (F)", Config.Fly, function(state)
    Config.Fly = state
    if state then startFly() else stopFly() end
end)

makeToggle("Noclip (N)", Config.Noclip, function(state)
    Config.Noclip = state
    if state then startNoclip() else stopNoclip() end
end)

-- ============ HOTKEYS ============
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.F then
        Config.Fly = not Config.Fly
        if Config.Fly then startFly() else stopFly() end
    elseif input.KeyCode == Enum.KeyCode.N then
        Config.Noclip = not Config.Noclip
        if Config.Noclip then startNoclip() else stopNoclip() end
    end
end)

-- ============ RESPAWN HANDLING ============
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if Config.Fly then startFly() end
    if Config.Noclip then startNoclip() end
end)

print("[VD Hub] Loaded. F = Fly, N = Noclip")
