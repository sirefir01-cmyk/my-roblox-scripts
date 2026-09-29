--[[
    Violence District Hub v2
    Features: ESP | Infinite Heal | Fly | Noclip | Auto Skill Check | Custom Keybinds
    Author: Custom
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
    AutoSkill    = true,
}

-- Хоткеи (можно менять в меню)
local Keybinds = {
    ESP          = Enum.KeyCode.RightControl, -- пример, ESP обычно всегда вкл
    InfiniteHeal = Enum.KeyCode.H,
    Fly          = Enum.KeyCode.F,
    Noclip       = Enum.KeyCode.N,
    AutoSkill    = Enum.KeyCode.G,
    ToggleMenu   = Enum.KeyCode.RightShift,
}

-- ============ GUI ============
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VD_Hub"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 9999
ScreenGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Size = UDim2.new(0, 260, 0, 420)
Main.Position = UDim2.new(0, 20, 0, 100)
Main.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
Main.BorderSizePixel = 0
Main.Active = true
Main.ClipsDescendants = true
Main.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = Main

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(80, 80, 100)
MainStroke.Thickness = 1
MainStroke.Parent = Main

-- ===== TITLE BAR (drag zone) =====
local Title = Instance.new("TextButton")
Title.Size = UDim2.new(1, 0, 0, 36)
Title.BackgroundColor3 = Color3.fromRGB(38, 38, 50)
Title.Text = "  Violence District | Hub"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.AutoButtonColor = false
Title.Parent = Main

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

-- ===== CUSTOM DRAG (нормальный, не Roblox Draggable) =====
local dragging, dragStart, startPos = false, nil, nil

Title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
       or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
       or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- ===== SCROLL FRAME для тогглов =====
local Scroll = Instance.new("ScrollingFrame")
Scroll.Size = UDim2.new(1, 0, 1, -36)
Scroll.Position = UDim2.new(0, 0, 0, 36)
Scroll.BackgroundTransparency = 1
Scroll.BorderSizePixel = 0
Scroll.ScrollBarThickness = 4
Scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 140)
Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
Scroll.Parent = Main

local UIList = Instance.new("UIListLayout")
UIList.Padding = UDim.new(0, 6)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.Parent = Scroll

local UIPad = Instance.new("UIPadding")
UIPad.PaddingTop = UDim.new(0, 8)
UIPad.PaddingLeft = UDim.new(0, 8)
UIPad.PaddingRight = UDim.new(0, 8)
UIPad.PaddingBottom = UDim.new(0, 8)
UIPad.Parent = Scroll

-- ============ TOGGLE BUILDER с биндом ============
local function makeToggle(label, key, getter, setter)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 34)
    row.BackgroundColor3 = Color3.fromRGB(32, 32, 42)
    row.BorderSizePixel = 0
    row.Parent = Scroll

    local rc = Instance.new("UICorner")
    rc.CornerRadius = UDim.new(0, 6)
    rc.Parent = row

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(0.5, 0, 1, 0)
    lbl.Position = UDim2.new(0, 8, 0, 0)
    lbl.BackgroundTransparency = 1
    lbl.Text = label
    lbl.TextColor3 = Color3.fromRGB(230, 230, 240)
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 13
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Parent = row

    -- Кнопка бинда
    local bindBtn = Instance.new("TextButton")
    bindBtn.Size = UDim2.new(0, 44, 0, 24)
    bindBtn.Position = UDim2.new(1, -114, 0.5, -12)
    bindBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
    bindBtn.Text = key.Name
    bindBtn.TextColor3 = Color3.fromRGB(255, 220, 90)
    bindBtn.Font = Enum.Font.GothamBold
    bindBtn.TextSize = 11
    bindBtn.Parent = row

    local bc = Instance.new("UICorner")
    bc.CornerRadius = UDim.new(0, 5)
    bc.Parent = bindBtn

    -- Toggle-кнопка
    local tog = Instance.new("TextButton")
    tog.Size = UDim2.new(0, 52, 0, 24)
    tog.Position = UDim2.new(1, -62, 0.5, -12)
    tog.BackgroundColor3 = getter() and Color3.fromRGB(0, 150, 75) or Color3.fromRGB(140, 40, 40)
    tog.Text = getter() and "ON" or "OFF"
    tog.TextColor3 = Color3.fromRGB(255, 255, 255)
    tog.Font = Enum.Font.GothamBold
    tog.TextSize = 11
    tog.Parent = row

    local tc = Instance.new("UICorner")
    tc.CornerRadius = UDim.new(0, 5)
    tc.Parent = tog

    -- binding state
    local binding = false

    bindBtn.MouseButton1Click:Connect(function()
        binding = true
        bindBtn.Text = "..."
        bindBtn.BackgroundColor3 = Color3.fromRGB(180, 140, 0)
    end)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if binding and input.UserInputType == Enum.UserInputType.Keyboard then
            Keybinds[label] = input.KeyCode
            bindBtn.Text = input.KeyCode.Name
            bindBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            binding = false
        end
    end)

    local function refresh()
        local state = getter()
        tog.Text = state and "ON" or "OFF"
        tog.BackgroundColor3 = state and Color3.fromRGB(0, 150, 75) or Color3.fromRGB(140, 40, 40)
    end

    tog.MouseButton1Click:Connect(function()
        setter(not getter())
        refresh()
    end)

    return refresh
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

    local hl = Instance.new("Highlight")
    hl.Name = "VD_ESP"
    hl.FillColor = Config.ESPColor
    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
    hl.FillTransparency = 0.55
    hl.Adornee = char
    hl.Parent = char

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

    ESPData[player] = {Highlight=hl, BB=bb, Info=infoL, Char=char}
end

local function destroyESP(player)
    if ESPData[player] then
        if ESPData[player].Highlight then ESPData[player].Highlight:Destroy() end
        if ESPData[player].BB then ESPData[player].BB:Destroy() end
        ESPData[player] = nil
    end
end

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
local healRemotes = {}
for _, obj in ipairs(game:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        local n = obj.Name:lower()
        if n:find("heal") or n:find("regen") or n:find("health") or n:find("revive") then
            table.insert(healRemotes, obj)
        end
    end
end

task.spawn(function()
    while task.wait(0.05) do
        if not Config.InfiniteHeal then continue end
        local char = LocalPlayer.Character
        if not char then continue end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum and hum.Health > 0 and hum.Health < hum.MaxHealth then
            hum.Health = hum.MaxHealth
        end
        for _, r in ipairs(healRemotes) do
            pcall(function()
                if r:IsA("RemoteEvent") then r:FireServer() else r:InvokeServer() end
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
    flyBV.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    flyBV.Velocity = Vector3.zero
    flyBV.Parent = root

    flyBG = Instance.new("BodyGyro")
    flyBG.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
    flyBG.P = 1e4
    flyBG.CFrame = root.CFrame
    flyBG.Parent = root

    hum.PlatformStand = true

    flyConn = RunService.RenderStepped:Connect(function()
        if not Config.Fly or not root.Parent then stopFly() return end
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
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide = false end
        end
    end)
end

-- ============ AUTO SKILL CHECK ============
-- Логика: ищем GUI с крутящимся элементом или текстом "skill".
-- Если нашли — жмём Space + кликаем в центр экрана + пробуем ремоуты skill/perk.
local skillRemotes = {}
for _, obj in ipairs(game:GetDescendants()) do
    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
        local n = obj.Name:lower()
        if n:find("skill") or n:find("check") or n:find("hit") or n:find("perk") then
            table.insert(skillRemotes, obj)
        end
    end
end

local function isSkillGuiActive()
    local pg = LocalPlayer:FindFirstChild("PlayerGui")
    if not pg then return false end
    for _, d in ipairs(pg:GetDescendants()) do
        if d:IsA("GuiObject") and d.Visible then
            local n = d.Name:lower()
            if n:find("skill") or n:find("check") or n:find("qte") or n:find("minigame") then
                return true, d
            end
        end
    end
    return false
end

task.spawn(function()
    while task.wait(0.03) do
        if not Config.AutoSkill then continue end

        local active, gui = isSkillGuiActive()
        if active then
            -- 1) Пробуем нажать пробел
            pcall(function()
                local vim = game:GetService("VirtualInputManager")
                vim:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
                task.wait(0.02)
                vim:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
            end)

            -- 2) Если есть крутящаяся стрелка/маркер — вычислим её зону и кликнем
            pcall(function()
                if gui then
                    for _, c in ipairs(gui:GetDescendants()) do
                        if c:IsA("ImageLabel") or c:IsA("Frame") then
                            -- клик в центр этого элемента
                            local pos = c.AbsolutePosition + c.AbsoluteSize / 2
                            local vim = game:GetService("VirtualInputManager")
                            vim:SendMouseButtonEvent(pos.X, pos.Y, 0, true, game, 1)
                            task.wait(0.01)
                            vim:SendMouseButtonEvent(pos.X, pos.Y, 0, false, game, 1)
                        end
                    end
                end
            end)

            -- 3) Фаерим все найденные skill-ремоуты
            for _, r in ipairs(skillRemotes) do
                pcall(function()
                    if r:IsA("RemoteEvent") then
                        r:FireServer(true)
                        r:FireServer()
                    else
                        r:InvokeServer(true)
                    end
                end)
            end
        end
    end
end)

-- ============ BUILD MENU ============
local refreshESP   = makeToggle("ESP",          Keybinds.ESP,          function() return Config.ESP end,          function(v)
    Config.ESP = v
    if v then
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then buildESP(plr) end
        end
    else
        for plr, _ in pairs(ESPData) do destroyESP(plr) end
    end
end)

local refreshHeal  = makeToggle("Infinite Heal",Keybinds.InfiniteHeal,  function() return Config.InfiniteHeal end, function(v) Config.InfiniteHeal = v end)

local refreshFly   = makeToggle("Fly",          Keybinds.Fly,          function() return Config.Fly end,          function(v)
    Config.Fly = v
    if v then startFly() else stopFly() end
end)

local refreshNoclip= makeToggle("Noclip",       Keybinds.Noclip,       function() return Config.Noclip end,       function(v)
    Config.Noclip = v
    if v then startNoclip() else stopNoclip() end
end)

local refreshSkill = makeToggle("Auto Skill Check", Keybinds.AutoSkill, function() return Config.AutoSkill end, function(v) Config.AutoSkill = v end)

-- ============ HOTKEY HANDLER ============
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.UserInputType ~= Enum.UserInputType.Keyboard then return end

    local k = input.KeyCode

    if k == Keybinds.Fly then
        Config.Fly = not Config.Fly
        if Config.Fly then startFly() else stopFly() end
        refreshFly()
    elseif k == Keybinds.Noclip then
        Config.Noclip = not Config.Noclip
        if Config.Noclip then startNoclip() else stopNoclip() end
        refreshNoclip()
    elseif k == Keybinds.InfiniteHeal then
        Config.InfiniteHeal = not Config.InfiniteHeal
        refreshHeal()
    elseif k == Keybinds.AutoSkill then
        Config.AutoSkill = not Config.AutoSkill
        refreshSkill()
    elseif k == Keybinds.ESP then
        Config.ESP = not Config.ESP
        if Config.ESP then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then buildESP(plr) end
            end
        else
            for plr, _ in pairs(ESPData) do destroyESP(plr) end
        end
        refreshESP()
    elseif k == Keybinds.ToggleMenu then
        Main.Visible = not Main.Visible
    end
end)

-- ============ RESPAWN ============
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    if Config.Fly then startFly() end
    if Config.Noclip then startNoclip() end
end)

print("[VD Hub v2] Loaded. RightShift = toggle menu. Кликни по кнопке клавиши (например 'F') и потом нажми нужную клавишу для ребинда.")
