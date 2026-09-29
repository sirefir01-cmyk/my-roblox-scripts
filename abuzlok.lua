-- ============================================================
-- ПОЛНЫЙ СКРИПТ: LOADING → KEY MENU → MAIN MENU
-- Features: ESP Survivor, ESP Killer, Fly, Noclip
-- Ключ: "Key"
-- Меню показать/скрыть: RightShift
-- ============================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local camera = workspace.CurrentCamera

-- ========== CONFIG ==========
local CONFIG = {
    CORRECT_KEY = "Key",
    LOADING_TIME = 3,
    ESP = {
        Survivor = {Enabled=false, Color=Color3.fromRGB(80,200,255), ShowName=true, ShowDistance=true, MaxDistance=500},
        Killer   = {Enabled=false, Color=Color3.fromRGB(255,80,80), ShowName=true, ShowDistance=true, MaxDistance=500},
    },
    Fly = {Enabled=false, Speed=60},
    Noclip = {Enabled=false},
}

-- ========== SOUND IDS (замени при желании) ==========
local SOUNDS = {
    Loading = "rbxassetid://131902697394780",
    Complete = "rbxassetid://6042053626",
    Click = "rbxassetid://6042053626",
    Success = "rbxassetid://6042053626",
    Error = "rbxassetid://6042053626",
}

-- ============================================================
-- 1. ЗАГРУЗОЧНЫЙ ЭКРАН
-- ============================================================
local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "LoadingScreen"
loadingGui.ResetOnSpawn = false
loadingGui.IgnoreGuiInset = true
loadingGui.DisplayOrder = 999
loadingGui.Parent = playerGui

local loadingBg = Instance.new("Frame")
loadingBg.Size = UDim2.new(1,0,1,0)
loadingBg.BackgroundColor3 = Color3.fromRGB(10,10,15)
loadingBg.BorderSizePixel = 0
loadingBg.Parent = loadingGui

local glowCircle = Instance.new("Frame")
glowCircle.Size = UDim2.new(0,120,0,120)
glowCircle.Position = UDim2.new(0.5,-60,0.5,-60)
glowCircle.BackgroundColor3 = Color3.fromRGB(80,140,255)
glowCircle.BackgroundTransparency = 0.6
glowCircle.BorderSizePixel = 0
glowCircle.Parent = loadingBg
Instance.new("UICorner", glowCircle).CornerRadius = UDim.new(1,0)

local loadingText = Instance.new("TextLabel")
loadingText.Size = UDim2.new(1,0,0,60)
loadingText.Position = UDim2.new(0,0,0.5,40)
loadingText.BackgroundTransparency = 1
loadingText.Text = "ЗАГРУЗКА..."
loadingText.Font = Enum.Font.GothamBlack
loadingText.TextSize = 28
loadingText.TextColor3 = Color3.new(1,1,1)
loadingText.TextStrokeTransparency = 0.5
loadingText.Parent = loadingBg

local progressBarBg = Instance.new("Frame")
progressBarBg.Size = UDim2.new(0,300,0,8)
progressBarBg.Position = UDim2.new(0.5,-150,0.5,80)
progressBarBg.BackgroundColor3 = Color3.fromRGB(40,40,50)
progressBarBg.BorderSizePixel = 0
progressBarBg.Parent = loadingBg
Instance.new("UICorner", progressBarBg).CornerRadius = UDim.new(1,0)

local progressBarFill = Instance.new("Frame")
progressBarFill.Size = UDim2.new(0,0,1,0)
progressBarFill.BackgroundColor3 = Color3.fromRGB(80,140,255)
progressBarFill.BorderSizePixel = 0
progressBarFill.Parent = progressBarBg
Instance.new("UICorner", progressBarFill).CornerRadius = UDim.new(1,0)

local loadingSound = Instance.new("Sound")
loadingSound.SoundId = SOUNDS.Loading
loadingSound.Volume = 0.5
loadingSound.Parent = loadingGui
loadingSound:Play()

TweenService:Create(progressBarFill, TweenInfo.new(CONFIG.LOADING_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(1,0,1,0)}):Play()
TweenService:Create(glowCircle, TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {Size = UDim2.new(0,150,0,150), Position = UDim2.new(0.5,-75,0.5,-75)}):Play()

task.wait(CONFIG.LOADING_TIME)

local completeSound = Instance.new("Sound")
completeSound.SoundId = SOUNDS.Complete
completeSound.Volume = 0.6
completeSound.Parent = loadingGui
completeSound:Play()

TweenService:Create(loadingBg, TweenInfo.new(0.8, Enum.EasingStyle.Quart), {BackgroundTransparency = 1}):Play()
TweenService:Create(loadingText, TweenInfo.new(0.6), {TextTransparency = 1}):Play()
task.wait(0.9)
loadingGui:Destroy()

-- ============================================================
-- 2. МЕНЮ ВВОДА КЛЮЧА
-- ============================================================
local keyGui = Instance.new("ScreenGui")
keyGui.Name = "KeyMenu"
keyGui.ResetOnSpawn = false
keyGui.IgnoreGuiInset = true
keyGui.DisplayOrder = 1000
keyGui.Parent = playerGui

local keyBg = Instance.new("Frame")
keyBg.Size = UDim2.new(1,0,1,0)
keyBg.BackgroundColor3 = Color3.fromRGB(5,5,12)
keyBg.BackgroundTransparency = 0.3
keyBg.BorderSizePixel = 0
keyBg.Parent = keyGui

local keyFrame = Instance.new("Frame")
keyFrame.Size = UDim2.new(0,420,0,320)
keyFrame.Position = UDim2.new(0.5,-210,0.5,-160)
keyFrame.BackgroundColor3 = Color3.fromRGB(15,15,22)
keyFrame.BorderSizePixel = 0
keyFrame.Parent = keyGui
Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0,18)

local kStroke = Instance.new("UIStroke", keyFrame)
kStroke.Color = Color3.fromRGB(80,140,255)
kStroke.Thickness = 1.5
kStroke.Transparency = 0.3

local kGrad = Instance.new("UIGradient", keyFrame)
kGrad.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20,20,30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10,10,18))
}
kGrad.Rotation = 135

local keyTitle = Instance.new("TextLabel")
keyTitle.Size = UDim2.new(1,0,0,50)
keyTitle.Position = UDim2.new(0,0,0,18)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = "🔑 СИСТЕМА КЛЮЧА"
keyTitle.Font = Enum.Font.GothamBlack
keyTitle.TextSize = 26
keyTitle.TextColor3 = Color3.new(1,1,1)
keyTitle.Parent = keyFrame

local keySub = Instance.new("TextLabel")
keySub.Size = UDim2.new(1,0,0,24)
keySub.Position = UDim2.new(0,0,0,62)
keySub.BackgroundTransparency = 1
keySub.Text = "Введите ключ для доступа"
keySub.Font = Enum.Font.Gotham
keySub.TextSize = 15
keySub.TextColor3 = Color3.fromRGB(160,160,180)
keySub.Parent = keyFrame

local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(0,320,0,48)
keyInput.Position = UDim2.new(0.5,-160,0,110)
keyInput.BackgroundColor3 = Color3.fromRGB(25,25,35)
keyInput.BorderSizePixel = 0
keyInput.PlaceholderText = "Введите ключ..."
keyInput.Font = Enum.Font.Gotham
keyInput.TextSize = 18
keyInput.TextColor3 = Color3.new(1,1,1)
keyInput.PlaceholderColor3 = Color3.fromRGB(100,100,120)
keyInput.ClearTextOnFocus = false
keyInput.Parent = keyFrame
Instance.new("UICorner", keyInput).CornerRadius = UDim.new(0,10)
local kInStroke = Instance.new("UIStroke", keyInput)
kInStroke.Color = Color3.fromRGB(60,60,80)
kInStroke.Thickness = 1

keyInput.Focused:Connect(function()
    TweenService:Create(kInStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(80,140,255)}):Play()
end)
keyInput.FocusLost:Connect(function()
    TweenService:Create(kInStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(60,60,80)}):Play()
end)

local submitButton = Instance.new("TextButton")
submitButton.Size = UDim2.new(0,200,0,46)
submitButton.Position = UDim2.new(0.5,-100,0,180)
submitButton.BackgroundColor3 = Color3.fromRGB(80,140,255)
submitButton.BorderSizePixel = 0
submitButton.Text = "ПОДТВЕРДИТЬ"
submitButton.Font = Enum.Font.GothamBold
submitButton.TextSize = 18
submitButton.TextColor3 = Color3.new(1,1,1)
submitButton.AutoButtonColor = false
submitButton.Parent = keyFrame
Instance.new("UICorner", submitButton).CornerRadius = UDim.new(0,10)

submitButton.MouseEnter:Connect(function()
    TweenService:Create(submitButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(100,160,255)}):Play()
end)
submitButton.MouseLeave:Connect(function()
    TweenService:Create(submitButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80,140,255)}):Play()
end)

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1,0,0,24)
statusLabel.Position = UDim2.new(0,0,0,238)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 15
statusLabel.TextColor3 = Color3.fromRGB(255,80,80)
statusLabel.Parent = keyFrame

local clickSound = Instance.new("Sound", keyGui); clickSound.SoundId = SOUNDS.Click; clickSound.Volume = 0.5
local successSound = Instance.new("Sound", keyGui); successSound.SoundId = SOUNDS.Success; successSound.Volume = 0.6
local errorSound = Instance.new("Sound", keyGui); errorSound.SoundId = SOUNDS.Error; errorSound.Volume = 0.5

keyFrame.Size = UDim2.new(0,0,0,0)
keyFrame.Position = UDim2.new(0.5,0,0.5,0)
TweenService:Create(keyFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0,420,0,320),
    Position = UDim2.new(0.5,-210,0.5,-160),
}):Play()

-- ============================================================
-- 3. ESP СИСТЕМА (Survivor / Killer)
-- ============================================================
local espGui = Instance.new("ScreenGui")
espGui.Name = "ESP"
espGui.ResetOnSpawn = false
espGui.IgnoreGuiInset = true
espGui.DisplayOrder = 5
espGui.Parent = playerGui

local espData = {}

local function getRole(plr)
    if plr.Team then
        local n = plr.Team.Name:lower()
        if n:find("kill") or n:find("murder") or n:find("hunter") or n:find("monster") then return "Killer" end
        if n:find("surv") or n:find("runner") or n:find("victim") or n:find("innocent") then return "Survivor" end
    end
    for _, attr in ipairs({"Role","role","Class","class","Team","team"}) do
        local v = plr:GetAttribute(attr)
        if v then
            local s = tostring(v):lower()
            if s:find("kill") or s:find("murder") or s:find("hunter") then return "Killer" end
            if s:find("surv") or s:find("runner") or s:find("victim") then return "Survivor" end
        end
    end
    return nil
end

local function createESP(plr)
    if espData[plr] then return espData[plr] end
    local hl = Instance.new("Highlight")
    hl.Name = "ESP_HL"
    hl.FillTransparency = 0.5
    hl.OutlineTransparency = 0
    hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    hl.Parent = espGui

    local bb = Instance.new("BillboardGui")
    bb.Name = "ESP_BB"
    bb.Size = UDim2.new(0, 200, 0, 46)
    bb.StudsOffset = Vector3.new(0, 3, 0)
    bb.AlwaysOnTop = true
    bb.Parent = espGui

    local nameL = Instance.new("TextLabel")
    nameL.Size = UDim2.new(1, 0, 0, 24)
    nameL.BackgroundTransparency = 1
    nameL.Font = Enum.Font.GothamBold
    nameL.TextSize = 16
    nameL.TextColor3 = Color3.new(1,1,1)
    nameL.TextStrokeTransparency = 0
    nameL.TextStrokeColor3 = Color3.new(0,0,0)
    nameL.Parent = bb

    local distL = Instance.new("TextLabel")
    distL.Size = UDim2.new(1, 0, 0, 18)
    distL.Position = UDim2.new(0, 0, 0, 24)
    distL.BackgroundTransparency = 1
    distL.Font = Enum.Font.Gotham
    distL.TextSize = 13
    distL.TextColor3 = Color3.fromRGB(220,220,220)
    distL.TextStrokeTransparency = 0
    distL.TextStrokeColor3 = Color3.new(0,0,0)
    distL.Parent = bb

    local data = {Highlight = hl, Billboard = bb, Name = nameL, Dist = distL}
    espData[plr] = data
    return data
end

local function removeESP(plr)
    local d = espData[plr]
    if d then
        if d.Highlight then d.Highlight:Destroy() end
        if d.Billboard then d.Billboard:Destroy() end
        espData[plr] = nil
    end
end

for _, plr in ipairs(Players:GetPlayers()) do
    if plr ~= player then createESP(plr) end
end
Players.PlayerAdded:Connect(function(plr)
    if plr ~= player then createESP(plr) end
end)
Players.PlayerRemoving:Connect(function(plr)
    removeESP(plr)
end)

RunService.RenderStepped:Connect(function()
    local myChar = player.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    for plr, data in pairs(espData) do
        local char = plr.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local role = getRole(plr)
        local cfg = role and CONFIG.ESP[role] or nil

        local show = false
        if char and hrp and hum and hum.Health > 0 and cfg and cfg.Enabled and plr ~= player then
            local dist = myHRP and (myHRP.Position - hrp.Position).Magnitude or 0
            if dist <= cfg.MaxDistance then
                show = true
                data.Highlight.Adornee = char
                data.Highlight.FillColor = cfg.Color
                data.Highlight.OutlineColor = cfg.Color
                data.Billboard.Adornee = hrp
                data.Name.Text = plr.Name
                data.Name.TextColor3 = cfg.Color
                data.Name.Visible = cfg.ShowName
                data.Dist.Text = string.format("[%d studs]", math.floor(dist))
                data.Dist.Visible = cfg.ShowDistance
                data.Dist.TextColor3 = cfg.Color
            end
        end
        if not show then
            data.Highlight.Adornee = nil
            data.Billboard.Adornee = nil
        end
    end
end)

-- ============================================================
-- 4. FLY
-- ============================================================
local flyBV, flyBG

local function enableFly()
    local char = player.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    flyBV = Instance.new("BodyVelocity")
    flyBV.Name = "FlyBV"
    flyBV.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = hrp

    flyBG = Instance.new("BodyGyro")
    flyBG.Name = "FlyBG"
    flyBG.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
    flyBG.P = 10000
    flyBG.CFrame = hrp.CFrame
    flyBG.Parent = hrp
end

local function disableFly()
    if flyBV then flyBV:Destroy(); flyBV = nil end
    if flyBG then flyBG:Destroy(); flyBG = nil end
end

RunService.RenderStepped:Connect(function()
    if not CONFIG.Fly.Enabled then return end
    if not flyBV or not flyBV.Parent then
        enableFly()
    end
    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then disableFly() return end
    local dir = Vector3.zero
    if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= camera.CFrame.LookVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += camera.CFrame.RightVector end
    if UserInputService:IsKeyDown(Enum.KeyCode.Space) then dir += Vector3.new(0,1,0) end
    if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then dir -= Vector3.new(0,1,0) end

    if dir.Magnitude > 0 then
        flyBV.Velocity = dir.Unit * CONFIG.Fly.Speed
    else
        flyBV.Velocity = Vector3.zero
    end
    flyBG.CFrame = camera.CFrame
end)

-- ============================================================
-- 5. NOCLIP
-- ============================================================
local noclipConn = RunService.Stepped:Connect(function()
    if not CONFIG.Noclip.Enabled then return end
    local char = player.Character
    if not char then return end
    for _, part in ipairs(char:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            part.CanCollide = false
        end
    end
end)

player.CharacterAdded:Connect(function()
    if CONFIG.Fly.Enabled then
        task.wait(0.5)
        enableFly()
    end
end)

-- ============================================================
-- 6. ГЛАВНОЕ МЕНЮ (создаётся после принятия ключа)
-- ============================================================
local function openMainMenu()
    -- ===== GUI =====
    local menuGui = Instance.new("ScreenGui")
    menuGui.Name = "MainMenu"
    menuGui.ResetOnSpawn = false
    menuGui.IgnoreGuiInset = true
    menuGui.DisplayOrder = 100
    menuGui.Parent = playerGui

    -- ===== MAIN FRAME =====
    local main = Instance.new("Frame")
    main.Size = UDim2.new(0, 500, 0, 480)
    main.Position = UDim2.new(0.5, -250, 0.5, -240)
    main.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
    main.BorderSizePixel = 0
    main.Parent = menuGui
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 14)
    local mStroke = Instance.new("UIStroke", main)
    mStroke.Color = Color3.fromRGB(80, 140, 255)
    mStroke.Thickness = 1.3
    mStroke.Transparency = 0.3

    -- ===== HEADER (draggable) =====
    local header = Instance.new("Frame")
    header.Size = UDim2.new(1, 0, 0, 42)
    header.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    header.BorderSizePixel = 0
    header.Parent = main
    Instance.new("UICorner", header).CornerRadius = UDim.new(0, 14)

    local headerFix = Instance.new("Frame")
    headerFix.Size = UDim2.new(1, 0, 0, 16)
    headerFix.Position = UDim2.new(0, 0, 1, -16)
    headerFix.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    headerFix.BorderSizePixel = 0
    headerFix.Parent = header

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -60, 1, 0)
    title.Position = UDim2.new(0, 16, 0, 0)
    title.BackgroundTransparency = 1
    title.Text = "⚡ FEATURES MENU"
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 18
    title.TextColor3 = Color3.new(1,1,1)
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = header

    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -38, 0.5, -15)
    closeBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 40)
    closeBtn.Text = "✕"
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 16
    closeBtn.TextColor3 = Color3.fromRGB(255, 120, 120)
    closeBtn.BorderSizePixel = 0
    closeBtn.AutoButtonColor = false
    closeBtn.Parent = header
    Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 8)
    closeBtn.MouseButton1Click:Connect(function()
        menuGui.Enabled = false
    end)

    -- drag
    do
        local dragging, dragStart, startPos
        header.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = main.Position
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    -- ===== SCROLL LIST =====
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, -20, 1, -60)
    scroll.Position = UDim2.new(0, 10, 0, 50)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(80, 140, 255)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = main

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 8)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = scroll

    -- ========= HELPERS =========
    local COLORS = {
        Color3.fromRGB(255, 80, 80),
        Color3.fromRGB(255, 160, 60),
        Color3.fromRGB(255, 240, 80),
        Color3.fromRGB(100, 255, 120),
        Color3.fromRGB(80, 200, 255),
        Color3.fromRGB(150, 100, 255),
        Color3.fromRGB(255, 100, 200),
        Color3.fromRGB(255, 255, 255),
    }

    local function makeToggle(parent, initialState, callback)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 44, 0, 22)
        btn.BackgroundColor3 = initialState and Color3.fromRGB(80, 200, 120) or Color3.fromRGB(45, 45, 60)
        btn.Text = ""
        btn.BorderSizePixel = 0
        btn.AutoButtonColor = false
        btn.Parent = parent
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1, 0)
        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 18, 0, 18)
        knob.Position = initialState and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
        knob.BackgroundColor3 = Color3.new(1,1,1)
        knob.BorderSizePixel = 0
        knob.Parent = btn
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)
        local state = initialState
        btn.MouseButton1Click:Connect(function()
            state = not state
            TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = state and Color3.fromRGB(80,200,120) or Color3.fromRGB(45,45,60)}):Play()
            TweenService:Create(knob, TweenInfo.new(0.2), {Position = state and UDim2.new(1,-20,0.5,-9) or UDim2.new(0,2,0.5,-9)}):Play()
            callback(state)
        end)
        return btn
    end

    local function makeSlider(parent, minV, maxV, initV, callback)
        local wrap = Instance.new("Frame")
        wrap.Size = UDim2.new(1, 0, 0, 22)
        wrap.BackgroundTransparency = 1
        wrap.Parent = parent

        local track = Instance.new("Frame")
        track.Size = UDim2.new(1, -60, 0, 6)
        track.Position = UDim2.new(0, 0, 0.5, -3)
        track.BackgroundColor3 = Color3.fromRGB(40,40,55)
        track.BorderSizePixel = 0
        track.Parent = wrap
        Instance.new("UICorner", track).CornerRadius = UDim.new(1,0)

        local fill = Instance.new("Frame")
        fill.Size = UDim2.new((initV - minV)/(maxV - minV), 0, 1, 0)
        fill.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
        fill.BorderSizePixel = 0
        fill.Parent = track
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

        local knob = Instance.new("Frame")
        knob.Size = UDim2.new(0, 14, 0, 14)
        knob.Position = UDim2.new((initV - minV)/(maxV - minV), -7, 0.5, -7)
        knob.BackgroundColor3 = Color3.new(1,1,1)
        knob.BorderSizePixel = 0
        knob.Parent = track
        Instance.new("UICorner", knob).CornerRadius = UDim.new(1,0)

        local valLabel = Instance.new("TextLabel")
        valLabel.Size = UDim2.new(0, 50, 0, 20)
        valLabel.Position = UDim2.new(1, -55, 0.5, -10)
        valLabel.BackgroundTransparency = 1
        valLabel.Text = tostring(math.floor(initV))
        valLabel.Font = Enum.Font.GothamBold
        valLabel.TextSize = 14
        valLabel.TextColor3 = Color3.fromRGB(220,220,240)
        valLabel.Parent = wrap

        local dragging = false
        local function updateFromX(x)
            local rel = math.clamp((x - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
            local val = minV + (maxV - minV) * rel
            fill.Size = UDim2.new(rel, 0, 1, 0)
            knob.Position = UDim2.new(rel, -7, 0.5, -7)
            valLabel.Text = tostring(math.floor(val))
            callback(val)
        end

        track.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                updateFromX(input.Position.X)
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                updateFromX(input.Position.X)
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end)
    end

    local function makeColorRow(parent, initColor, callback)
        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 22)
        row.BackgroundTransparency = 1
        row.Parent = parent
        local l = Instance.new("UIListLayout", row)
        l.FillDirection = Enum.FillDirection.Horizontal
        l.Padding = UDim.new(0, 8)
        for _, col in ipairs(COLORS) do
            local b = Instance.new("TextButton")
            b.Size = UDim2.new(0, 20, 0, 20)
            b.BackgroundColor3 = col
            b.Text = ""
            b.BorderSizePixel = 0
            b.AutoButtonColor = false
            b.Parent = row
            Instance.new("UICorner", b).CornerRadius = UDim.new(1,0)
            local st = Instance.new("UIStroke", b)
            st.Color = (col == initColor) and Color3.new(1,1,1) or Color3.fromRGB(60,60,80)
            st.Thickness = 2
            b.MouseButton1Click:Connect(function()
                for _, c in ipairs(row:GetChildren()) do
                    if c:IsA("TextButton") and c:FindFirstChildOfClass("UIStroke") then
                        c:FindFirstChildOfClass("UIStroke").Color = Color3.fromRGB(60,60,80)
                    end
                end
                st.Color = Color3.new(1,1,1)
                callback(col)
            end)
        end
    end

    local function makeCard(titleText, height)
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, -8, 0, height)
        card.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
        card.BorderSizePixel = 0
        card.Parent = scroll
        Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
        local cs = Instance.new("UIStroke", card)
        cs.Color = Color3.fromRGB(45, 45, 65)
        cs.Thickness = 1

        local tl = Instance.new("TextLabel")
        tl.Size = UDim2.new(1, -70, 0, 26)
        tl.Position = UDim2.new(0, 14, 0, 8)
        tl.BackgroundTransparency = 1
        tl.Text = titleText
        tl.Font = Enum.Font.GothamBold
        tl.TextSize = 15
        tl.TextColor3 = Color3.new(1,1,1)
        tl.TextXAlignment = Enum.TextXAlignment.Left
        tl.Parent = card

        local toggleHolder = Instance.new("Frame")
        toggleHolder.Size = UDim2.new(0, 44, 0, 22)
        toggleHolder.Position = UDim2.new(1, -58, 0, 10)
        toggleHolder.BackgroundTransparency = 1
        toggleHolder.Parent = card

        local content = Instance.new("Frame")
        content.Size = UDim2.new(1, -28, 0, height - 46)
        content.Position = UDim2.new(0, 14, 0, 42)
        content.BackgroundTransparency = 1
        content.Parent = card

        local cl = Instance.new("UIListLayout", content)
        cl.Padding = UDim.new(0, 6)
        cl.SortOrder = Enum.SortOrder.LayoutOrder

        return card, toggleHolder, content
    end

    -- ===== ESP SURVIVOR CARD =====
    do
        local card, toggleHolder, content = makeCard("🎯 ESP SURVIVOR", 150)
        makeToggle(toggleHolder, CONFIG.ESP.Survivor.Enabled, function(s) CONFIG.ESP.Survivor.Enabled = s end)
        makeColorRow(content, CONFIG.ESP.Survivor.Color, function(c) CONFIG.ESP.Survivor.Color = c end)
        makeSlider(content, 50, 2000, CONFIG.ESP.Survivor.MaxDistance, function(v) CONFIG.ESP.Survivor.MaxDistance = v end)
        local optsRow = Instance.new("Frame")
        optsRow.Size = UDim2.new(1, 0, 0, 22)
        optsRow.BackgroundTransparency = 1
        optsRow.Parent = content
        local ol = Instance.new("UIListLayout", optsRow)
        ol.FillDirection = Enum.FillDirection.Horizontal
        ol.Padding = UDim.new(0, 12)

        local nameBtn = Instance.new("TextButton")
        nameBtn.Size = UDim2.new(0, 130, 0, 22)
        nameBtn.BackgroundColor3 = CONFIG.ESP.Survivor.ShowName and Color3.fromRGB(80,140,255) or Color3.fromRGB(45,45,60)
        nameBtn.Text = "Имя: " .. (CONFIG.ESP.Survivor.ShowName and "ВКЛ" or "ВЫКЛ")
        nameBtn.Font = Enum.Font.GothamBold
        nameBtn.TextSize = 12
        nameBtn.TextColor3 = Color3.new(1,1,1)
        nameBtn.BorderSizePixel = 0
        nameBtn.AutoButtonColor = false
        nameBtn.Parent = optsRow
        Instance.new("UICorner", nameBtn).CornerRadius = UDim.new(0, 6)
        nameBtn.MouseButton1Click:Connect(function()
            CONFIG.ESP.Survivor.ShowName = not CONFIG.ESP.Survivor.ShowName
            nameBtn.Text = "Имя: " .. (CONFIG.ESP.Survivor.ShowName and "ВКЛ" or "ВЫКЛ")
            nameBtn.BackgroundColor3 = CONFIG.ESP.Survivor.ShowName and Color3.fromRGB(80,140,255) or Color3.fromRGB(45,45,60)
        end)

        local distBtn = Instance.new("TextButton")
        distBtn.Size = UDim2.new(0, 150, 0, 22)
        distBtn.BackgroundColor3 = CONFIG.ESP.Survivor.ShowDistance and Color3.fromRGB(80,140,255) or Color3.fromRGB(45,45,60)
        distBtn.Text = "Дистанция: " .. (CONFIG.ESP.Survivor.ShowDistance and "ВКЛ" or "ВЫКЛ")
        distBtn.Font = Enum.Font.GothamBold
        distBtn.TextSize = 12
        distBtn.TextColor3 = Color3.new(1,1,1)
        distBtn.BorderSizePixel = 0
        distBtn.AutoButtonColor = false
        distBtn.Parent = optsRow
        Instance.new("UICorner", distBtn).CornerRadius = UDim.new(0, 6)
        distBtn.MouseButton1Click:Connect(function()
            CONFIG.ESP.Survivor.ShowDistance = not CONFIG.ESP.Survivor.ShowDistance
            distBtn.Text = "Дистанция: " .. (CONFIG.ESP.Survivor.ShowDistance and "ВКЛ" or "ВЫКЛ")
            distBtn.BackgroundColor3 = CONFIG.ESP.Survivor.ShowDistance and Color3.fromRGB(80,140,255) or Color3.fromRGB(45,45,60)
        end)
    end

    -- ===== ESP KILLER CARD =====
    do
        local card, toggleHolder, content = makeCard("🔪 ESP KILLER", 150)
        makeToggle(toggleHolder, CONFIG.ESP.Killer.Enabled, function(s) CONFIG.ESP.Killer.Enabled = s end)
        makeColorRow(content, CONFIG.ESP.Killer.Color, function(c) CONFIG.ESP.Killer.Color = c end)
        makeSlider(content, 50, 2000, CONFIG.ESP.Killer.MaxDistance, function(v) CONFIG.ESP.Killer.MaxDistance = v end)
        local optsRow = Instance.new("Frame")
        optsRow.Size = UDim2.new(1, 0, 0, 22)
        optsRow.BackgroundTransparency = 1
        optsRow.Parent = content
        local ol = Instance.new("UIListLayout", optsRow)
        ol.FillDirection = Enum.FillDirection.Horizontal
        ol.Padding = UDim.new(0, 12)

        local nameBtn = Instance.new("TextButton")
        nameBtn.Size = UDim2.new(0, 130, 0, 22)
        nameBtn.BackgroundColor3 = CONFIG.ESP.Killer.ShowName and Color3.fromRGB(80,140,255) or Color3.fromRGB(45,45,60)
        nameBtn.Text = "Имя: " .. (CONFIG.ESP.Killer.ShowName and "ВКЛ" or "ВЫКЛ")
        nameBtn.Font = Enum.Font.GothamBold
        nameBtn.TextSize = 12
        nameBtn.TextColor3 = Color3.new(1,1,1)
        nameBtn.BorderSizePixel = 0
        nameBtn.AutoButtonColor = false
        nameBtn.Parent = optsRow
        Instance.new("UICorner", nameBtn).CornerRadius = UDim.new(0, 6)
        nameBtn.MouseButton1Click:Connect(function()
            CONFIG.ESP.Killer.ShowName = not CONFIG.ESP.Killer.ShowName
            nameBtn.Text = "Имя: " .. (CONFIG.ESP.Killer.ShowName and "ВКЛ" or "ВЫКЛ")
            nameBtn.BackgroundColor3 = CONFIG.ESP.Killer.ShowName and Color3.fromRGB(80,140,255) or Color3.fromRGB(45,45,60)
        end)

        local distBtn = Instance.new("TextButton")
        distBtn.Size = UDim2.new(0, 150, 0, 22)
        distBtn.BackgroundColor3 = CONFIG.ESP.Killer.ShowDistance and Color3.fromRGB(80,140,255) or Color3.fromRGB(45,45,60)
        distBtn.Text = "Дистанция: " .. (CONFIG.ESP.Killer.ShowDistance and "ВКЛ" or "ВЫКЛ")
        distBtn.Font = Enum.Font.GothamBold
        distBtn.TextSize = 12
        distBtn.TextColor3 = Color3.new(1,1,1)
        distBtn.BorderSizePixel = 0
        distBtn.AutoButtonColor = false
        distBtn.Parent = optsRow
        Instance.new("UICorner", distBtn).CornerRadius = UDim.new(0, 6)
        distBtn.MouseButton1Click:Connect(function()
            CONFIG.ESP.Killer.ShowDistance = not CONFIG.ESP.Killer.ShowDistance
            distBtn.Text = "Дистанция: " .. (CONFIG.ESP.Killer.ShowDistance and "ВКЛ" or "ВЫКЛ")
            distBtn.BackgroundColor3 = CONFIG.ESP.Killer.ShowDistance and Color3.fromRGB(80,140,255) or Color3.fromRGB(45,45,60)
        end)
    end

    -- ===== FLY CARD =====
    do
        local card, toggleHolder, content = makeCard("🕊 FLY", 80)
        makeToggle(toggleHolder, CONFIG.Fly.Enabled, function(s)
            CONFIG.Fly.Enabled = s
            if not s then disableFly() end
        end)
        makeSlider(content, 10, 300, CONFIG.Fly.Speed, function(v) CONFIG.Fly.Speed = v end)
        local hint = Instance.new("TextLabel")
        hint.Size = UDim2.new(1, 0, 0, 16)
        hint.BackgroundTransparency = 1
        hint.Text = "WASD — движение, Space — вверх, Ctrl — вниз"
        hint.Font = Enum.Font.Gotham
        hint.TextSize = 11
        hint.TextColor3 = Color3.fromRGB(150,150,170)
        hint.TextXAlignment = Enum.TextXAlignment.Left
        hint.Parent = content
    end

    -- ===== NOCLIP CARD =====
    do
        local card, toggleHolder, content = makeCard("👻 NOCLIP", 55)
        makeToggle(toggleHolder, CONFIG.Noclip.Enabled, function(s)
            CONFIG.Noclip.Enabled = s
            if not s then
                local char = player.Character
                if char then
                    for _, part in ipairs(char:GetDescendants()) do
                        if part:IsA("BasePart") then
                            part.CanCollide = true
                        end
                    end
                end
            end
        end)
    end

    -- ===== TOGGLE MENU HOTKEY =====
    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == Enum.KeyCode.RightShift then
            menuGui.Enabled = not menuGui.Enabled
        end
    end)

    -- ===== ANIMATION =====
    main.Size = UDim2.new(0, 0, 0, 0)
    main.Position = UDim2.new(0.5, 0, 0.5, 0)
    TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 500, 0, 480),
        Position = UDim2.new(0.5, -250, 0.5, -240),
    }):Play()
end

-- ============================================================
-- 7. ПРОВЕРКА КЛЮЧА (запускает меню)
-- ============================================================
local function checkKey()
    clickSound:Play()
    if keyInput.Text == CONFIG.CORRECT_KEY then
        statusLabel.Text = "✅ Ключ верный!"
        statusLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
        successSound:Play()

        TweenService:Create(keyFrame, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(20, 40, 25)}):Play()
        task.wait(0.7)

        TweenService:Create(keyBg, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {BackgroundTransparency = 1}):Play()
        TweenService:Create(keyFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0),
        }):Play()
        task.wait(0.6)
        keyGui:Destroy()

        openMainMenu()
    else
        statusLabel.Text = "❌ Неверный ключ!"
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        errorSound:Play()
        keyInput.Text = ""

        local orig = keyFrame.Position
        for _ = 1, 3 do
            TweenService:Create(keyFrame, TweenInfo.new(0.05), {Position = orig + UDim2.new(0, 10, 0, 0)}):Play()
            task.wait(0.05)
            TweenService:Create(keyFrame, TweenInfo.new(0.05), {Position = orig - UDim2.new(0, 10, 0, 0)}):Play()
            task.wait(0.05)
        end
        TweenService:Create(keyFrame, TweenInfo.new(0.05), {Position = orig}):Play()
    end
end

submitButton.MouseButton1Click:Connect(checkKey)
keyInput.FocusLost:Connect(function(enter)
    if enter then checkKey() end
end)
