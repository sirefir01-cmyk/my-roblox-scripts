-- ============================================
-- VIOLENCE DISTRICT | AIMBOT + ESP | ALPHA v0.4.1
-- Fix: безопасный getRole + диагностика
-- ============================================

-- ============================================
-- АВТООЧИСТКА ПРЕДЫДУЩЕЙ ВЕРСИИ
-- ============================================
local genv = (typeof(getgenv) == "function" and getgenv()) or _G

if genv.VD_ALPHA_LOADED then
    local old = genv.VD_ALPHA_LOADED
    if old.connections then
        for _, c in ipairs(old.connections) do
            pcall(function() c:Disconnect() end)
        end
    end
    if old.gui then
        pcall(function() old.gui:Destroy() end)
    end
    if old.espCache then
        for _, data in pairs(old.espCache) do
            if data.highlight then pcall(function() data.highlight:Destroy() end) end
            if data.billboard then pcall(function() data.billboard:Destroy() end) end
        end
    end
    genv.VD_ALPHA_LOADED = nil
    print("[VD Alpha] Предыдущая версия скрипта удалена.")
end

local ActiveConnections = {}
genv.VD_ALPHA_LOADED = { connections = ActiveConnections, gui = nil, espCache = nil }

local function track(c)
    table.insert(ActiveConnections, c)
    return c
end

-- ============================================
-- СЕРВИСЫ
-- ============================================
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- ==================== КОНФИГ ====================
local Config = {
    -- Aimbot
    AimbotEnabled = false,
    AimMode = "Revolver",
    Smoothness = 0.15,
    FOV = 150,
    ShowFOV = true,
    TeamCheck = true,
    WallCheck = false,
    Prediction = 0.16,
    MaxDistance = 1000,
    FlashlightOffsetX = 35,
    FlashlightOffsetY = 10,
    -- ESP Survivors
    ESP_Survivors = false,
    ESP_SurvivorColor = Color3.fromRGB(0, 255, 100),
    ESP_Survivor_Name = true,
    ESP_Survivor_Distance = true,
    ESP_Survivor_MaxDist = 2000,
    -- ESP Killers
    ESP_Killers = false,
    ESP_KillerColor = Color3.fromRGB(255, 50, 50),
    ESP_Killer_Name = true,
    ESP_Killer_Distance = true,
    ESP_Killer_MaxDist = 2000,
}

-- ==================== РАЗМЕРЫ ====================
local BASE_W, BASE_H = 1920, 1200
local SCALE = 1 / 1.4
local MENU_W = math.floor(BASE_W * SCALE)
local MENU_H = math.floor(BASE_H * SCALE)

-- ==================== GUI ====================
local existing = CoreGui:FindFirstChild("VD_Alpha_GUI")
if existing then existing:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VD_Alpha_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui
genv.VD_ALPHA_LOADED.gui = ScreenGui

-- ==================== ЭКРАН ЗАГРУЗКИ ====================
local LoadingFrame = Instance.new("Frame")
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
LoadingFrame.BorderSizePixel = 0
LoadingFrame.ZIndex = 100
LoadingFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0, 500, 0, 60)
Title.Position = UDim2.new(0.5, -250, 0.4, -70)
Title.BackgroundTransparency = 1
Title.Text = "VIOLENCE DISTRICT | ALPHA"
Title.TextColor3 = Color3.fromRGB(255, 100, 100)
Title.TextScaled = true
Title.Font = Enum.Font.GothamBold
Title.ZIndex = 101
Title.Parent = LoadingFrame

local BarBG = Instance.new("Frame")
BarBG.Size = UDim2.new(0, 500, 0, 8)
BarBG.Position = UDim2.new(0.5, -250, 0.5, 0)
BarBG.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
BarBG.BorderSizePixel = 0
BarBG.ZIndex = 101
BarBG.Parent = LoadingFrame

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
BarFill.BorderSizePixel = 0
BarFill.ZIndex = 102
BarFill.Parent = BarBG

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0, 500, 0, 30)
StatusLabel.Position = UDim2.new(0.5, -250, 0.5, 20)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Инициализация..."
StatusLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
StatusLabel.TextScaled = true
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.ZIndex = 101
StatusLabel.Parent = LoadingFrame

local Stages = {
    {text = "Загрузка модулей...",     time = 0.4},
    {text = "Проверка окружения...",   time = 0.3},
    {text = "Инициализация Aimbot...", time = 0.4},
    {text = "Инициализация ESP...",    time = 0.4},
    {text = "Готово!",                 time = 0.3},
}

task.spawn(function()
    for i, stage in ipairs(Stages) do
        StatusLabel.Text = stage.text
        TweenService:Create(BarFill, TweenInfo.new(stage.time, Enum.EasingStyle.Quad), {
            Size = UDim2.new(i / #Stages, 0, 1, 0)
        }):Play()
        task.wait(stage.time)
    end
    task.wait(0.3)
    for _, obj in ipairs({LoadingFrame, Title, BarBG, BarFill, StatusLabel}) do
        TweenService:Create(obj, TweenInfo.new(0.4), {BackgroundTransparency = 1}):Play()
    end
    TweenService:Create(Title, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TweenService:Create(StatusLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    task.wait(0.6)
    LoadingFrame.Visible = false
end)

-- ==================== ГЛАВНОЕ МЕНЮ ====================
local Menu = Instance.new("Frame")
Menu.Name = "Menu"
Menu.Size = UDim2.new(0, MENU_W, 0, MENU_H)
Menu.Position = UDim2.new(0.5, -MENU_W/2, 0.5, -MENU_H/2)
Menu.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
Menu.BorderSizePixel = 0
Menu.Visible = false
Menu.Parent = ScreenGui

local MenuCorner = Instance.new("UICorner")
MenuCorner.CornerRadius = UDim.new(0, 12)
MenuCorner.Parent = Menu

local MenuStroke = Instance.new("UIStroke")
MenuStroke.Color = Color3.fromRGB(255, 100, 100)
MenuStroke.Thickness = 1.5
MenuStroke.Transparency = 0.4
MenuStroke.Parent = Menu

local HEADER_H = 55
local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, HEADER_H)
Header.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
Header.BorderSizePixel = 0
Header.Parent = Menu

local HeaderCorner = Instance.new("UICorner")
HeaderCorner.CornerRadius = UDim.new(0, 12)
HeaderCorner.Parent = Header

local HeaderCover = Instance.new("Frame")
HeaderCover.Size = UDim2.new(1, 0, 0, 20)
HeaderCover.Position = UDim2.new(0, 0, 1, -20)
HeaderCover.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
HeaderCover.BorderSizePixel = 0
HeaderCover.Parent = Header

local HeaderTitle = Instance.new("TextLabel")
HeaderTitle.Size = UDim2.new(1, -150, 1, 0)
HeaderTitle.Position = UDim2.new(0, 20, 0, 0)
HeaderTitle.BackgroundTransparency = 1
HeaderTitle.Text = "🔪  VIOLENCE DISTRICT  •  ALPHA v0.4.1"
HeaderTitle.TextColor3 = Color3.fromRGB(255, 100, 100)
HeaderTitle.TextSize = 20
HeaderTitle.Font = Enum.Font.GothamBold
HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
HeaderTitle.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 34, 0, 34)
CloseBtn.Position = UDim2.new(1, -46, 0, 10)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.BorderSizePixel = 0
CloseBtn.Parent = Header

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 8)
CloseCorner.Parent = CloseBtn

-- ==================== САЙДБАР ====================
local SIDEBAR_W = 220
local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, SIDEBAR_W, 1, -(HEADER_H + 20))
Sidebar.Position = UDim2.new(0, 10, 0, HEADER_H + 10)
Sidebar.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = Menu

local SidebarCorner = Instance.new("UICorner")
SidebarCorner.CornerRadius = UDim.new(0, 8)
SidebarCorner.Parent = Sidebar

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder
SidebarLayout.Parent = Sidebar

local SidebarPad = Instance.new("UIPadding")
SidebarPad.PaddingTop = UDim.new(0, 10)
SidebarPad.PaddingLeft = UDim.new(0, 10)
SidebarPad.PaddingRight = UDim.new(0, 10)
SidebarPad.PaddingBottom = UDim.new(0, 10)
SidebarPad.Parent = Sidebar

-- ==================== КОНТЕНТ ====================
local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -(SIDEBAR_W + 30), 1, -(HEADER_H + 20))
Content.Position = UDim2.new(0, SIDEBAR_W + 20, 0, HEADER_H + 10)
Content.BackgroundTransparency = 1
Content.Parent = Menu

local Pages = {}
local CategoryButtons = {}
local CurrentCategory = nil

-- ==================== ФАБРИКИ UI ====================
local function CreateToggle(parent, name, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 46)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    Frame.BorderSizePixel = 0
    Frame.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -90, 1, 0)
    Label.Position = UDim2.new(0, 16, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(220, 220, 230)
    Label.TextSize = 15
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 48, 0, 24)
    ToggleBtn.Position = UDim2.new(1, -62, 0.5, -12)
    ToggleBtn.BackgroundColor3 = default and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(50, 50, 60)
    ToggleBtn.Text = ""
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = Frame

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(1, 0)
    ToggleCorner.Parent = ToggleBtn

    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 18, 0, 18)
    Circle.Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Circle.BorderSizePixel = 0
    Circle.Parent = ToggleBtn

    local CircleCorner = Instance.new("UICorner")
    CircleCorner.CornerRadius = UDim.new(1, 0)
    CircleCorner.Parent = Circle

    local state = default
    track(ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = state and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(50, 50, 60)
        }):Play()
        TweenService:Create(Circle, TweenInfo.new(0.2), {
            Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        }):Play()
        if callback then callback(state) end
    end))
end

local function CreateSlider(parent, name, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 62)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    Frame.BorderSizePixel = 0
    Frame.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -30, 0, 22)
    Label.Position = UDim2.new(0, 16, 0, 8)
    Label.BackgroundTransparency = 1
    Label.Text = name .. ": " .. tostring(default)
    Label.TextColor3 = Color3.fromRGB(220, 220, 230)
    Label.TextSize = 15
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local SliderBG = Instance.new("Frame")
    SliderBG.Size = UDim2.new(1, -32, 0, 6)
    SliderBG.Position = UDim2.new(0, 16, 0, 42)
    SliderBG.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    SliderBG.BorderSizePixel = 0
    SliderBG.Parent = Frame

    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(1, 0)
    SliderCorner.Parent = SliderBG

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBG

    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = SliderFill

    local dragging = false
    local function updateFromInput(input)
        local relX = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
        local value = min + (max - min) * relX
        SliderFill.Size = UDim2.new(relX, 0, 1, 0)
        local display = (max - min) > 5 and math.floor(value) or math.floor(value * 100) / 100
        Label.Text = name .. ": " .. tostring(display)
        if callback then callback(value) end
    end

    track(SliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(input)
        end
    end))
    track(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input)
        end
    end))
    track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
end

local function CreateDropdown(parent, name, options, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 46)
    Frame.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    Frame.BorderSizePixel = 0
    Frame.ClipsDescendants = true
    Frame.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 6)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(0.5, 0, 1, 0)
    Label.Position = UDim2.new(0, 16, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(220, 220, 230)
    Label.TextSize = 15
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 240, 0, 30)
    Btn.Position = UDim2.new(1, -256, 0, 8)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Btn.Text = default .. "  ▼"
    Btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    Btn.TextSize = 13
    Btn.Font = Enum.Font.Gotham
    Btn.BorderSizePixel = 0
    Btn.Parent = Frame

    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 5)
    BtnCorner.Parent = Btn

    local expanded = false
    local optionButtons = {}

    track(Btn.MouseButton1Click:Connect(function()
        expanded = not expanded
        if expanded then
            for _, opt in ipairs(optionButtons) do
                TweenService:Create(opt, TweenInfo.new(0.2), {BackgroundTransparency = 0, TextTransparency = 0}):Play()
            end
            TweenService:Create(Frame, TweenInfo.new(0.25), {Size = UDim2.new(1, 0, 0, 46 + #options * 30)}):Play()
        else
            for _, opt in ipairs(optionButtons) do
                TweenService:Create(opt, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
            end
            TweenService:Create(Frame, TweenInfo.new(0.25), {Size = UDim2.new(1, 0, 0, 46)}):Play()
        end
    end))

    for i, opt in ipairs(options) do
        local OptBtn = Instance.new("TextButton")
        OptBtn.Size = UDim2.new(1, -32, 0, 26)
        OptBtn.Position = UDim2.new(0, 16, 0, 46 + (i - 1) * 30)
        OptBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
        OptBtn.Text = opt
        OptBtn.TextColor3 = Color3.fromRGB(220, 220, 230)
        OptBtn.TextSize = 13
        OptBtn.Font = Enum.Font.Gotham
        OptBtn.BorderSizePixel = 0
        OptBtn.BackgroundTransparency = 1
        OptBtn.TextTransparency = 1
        OptBtn.Parent = Frame

        local OptCorner = Instance.new("UICorner")
        OptCorner.CornerRadius = UDim.new(0, 4)
        OptCorner.Parent = OptBtn

        track(OptBtn.MouseButton1Click:Connect(function()
            Btn.Text = opt .. "  ▼"
            expanded = false
            for _, o in ipairs(optionButtons) do
                TweenService:Create(o, TweenInfo.new(0.2), {BackgroundTransparency = 1, TextTransparency = 1}):Play()
            end
            TweenService:Create(Frame, TweenInfo.new(0.25), {Size = UDim2.new(1, 0, 0, 46)}):Play()
            if callback then callback(opt) end
        end))
        table.insert(optionButtons, OptBtn)
    end
end

-- ==================== КОМПАКТНЫЕ ЭЛЕМЕНТЫ ====================
local function CreateSubToggle(parent, name, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 34)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    Frame.BorderSizePixel = 0
    Frame.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -80, 1, 0)
    Label.Position = UDim2.new(0, 12, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = name
    Label.TextColor3 = Color3.fromRGB(200, 200, 215)
    Label.TextSize = 13
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 38, 0, 20)
    ToggleBtn.Position = UDim2.new(1, -50, 0.5, -10)
    ToggleBtn.BackgroundColor3 = default and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(45, 45, 55)
    ToggleBtn.Text = ""
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = Frame

    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(1, 0)
    TCorner.Parent = ToggleBtn

    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 14, 0, 14)
    Circle.Position = default and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Circle.BorderSizePixel = 0
    Circle.Parent = ToggleBtn

    local CC = Instance.new("UICorner")
    CC.CornerRadius = UDim.new(1, 0)
    CC.Parent = Circle

    local state = default
    track(ToggleBtn.MouseButton1Click:Connect(function()
        state = not state
        TweenService:Create(ToggleBtn, TweenInfo.new(0.18), {
            BackgroundColor3 = state and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(45, 45, 55)
        }):Play()
        TweenService:Create(Circle, TweenInfo.new(0.18), {
            Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
        }):Play()
        if callback then callback(state) end
    end))
end

local function CreateSubSlider(parent, name, min, max, default, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 38)
    Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    Frame.BorderSizePixel = 0
    Frame.Parent = parent

    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 5)
    Corner.Parent = Frame

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -24, 0, 16)
    Label.Position = UDim2.new(0, 12, 0, 4)
    Label.BackgroundTransparency = 1
    Label.Text = name .. ": " .. tostring(default)
    Label.TextColor3 = Color3.fromRGB(200, 200, 215)
    Label.TextSize = 12
    Label.Font = Enum.Font.Gotham
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Frame

    local SliderBG = Instance.new("Frame")
    SliderBG.Size = UDim2.new(1, -24, 0, 5)
    SliderBG.Position = UDim2.new(0, 12, 0, 26)
    SliderBG.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
    SliderBG.BorderSizePixel = 0
    SliderBG.Parent = Frame

    local SBCorner = Instance.new("UICorner")
    SBCorner.CornerRadius = UDim.new(1, 0)
    SBCorner.Parent = SliderBG

    local SliderFill = Instance.new("Frame")
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    SliderFill.BorderSizePixel = 0
    SliderFill.Parent = SliderBG

    local FCorner = Instance.new("UICorner")
    FCorner.CornerRadius = UDim.new(1, 0)
    FCorner.Parent = SliderFill

    local dragging = false
    local function updateFromInput(input)
        local relX = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
        local value = min + (max - min) * relX
        SliderFill.Size = UDim2.new(relX, 0, 1, 0)
        Label.Text = name .. ": " .. math.floor(value)
        if callback then callback(math.floor(value)) end
    end

    track(SliderBG.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateFromInput(input)
        end
    end))
    track(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input)
        end
    end))
    track(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))
end

-- ==================== ESP-СЕКЦИЯ С ПОДМЕНЮ ====================
local function CreateESPEntry(parent, title, configPrefix, initialColor)
    local keyEnabled  = "ESP_" .. configPrefix
    local keyColor    = "ESP_" .. configPrefix .. "_Color"
    local keyName     = "ESP_" .. configPrefix .. "_Name"
    local keyDistance = "ESP_" .. configPrefix .. "_Distance"
    local keyMaxDist  = "ESP_" .. configPrefix .. "_MaxDist"

    local COLLAPSED_H = 46
    local EXPANDED_H  = 320

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, COLLAPSED_H)
    Container.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
    Container.BorderSizePixel = 0
    Container.ClipsDescendants = true
    Container.Parent = parent

    local CCorner = Instance.new("UICorner")
    CCorner.CornerRadius = UDim.new(0, 6)
    CCorner.Parent = Container

    local Label = Instance.new("TextLabel")
    Label.Size = UDim2.new(1, -200, 0, COLLAPSED_H)
    Label.Position = UDim2.new(0, 16, 0, 0)
    Label.BackgroundTransparency = 1
    Label.Text = title
    Label.TextColor3 = Color3.fromRGB(220, 220, 230)
    Label.TextSize = 15
    Label.Font = Enum.Font.GothamMedium
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.Parent = Container

    local Preview = Instance.new("Frame")
    Preview.Size = UDim2.new(0, 18, 0, 18)
    Preview.Position = UDim2.new(1, -160, 0, 14)
    Preview.BackgroundColor3 = initialColor
    Preview.BorderSizePixel = 0
    Preview.Parent = Container

    local PrevCorner = Instance.new("UICorner")
    PrevCorner.CornerRadius = UDim.new(1, 0)
    PrevCorner.Parent = Preview

    local PrevStroke = Instance.new("UIStroke")
    PrevStroke.Color = Color3.fromRGB(255, 255, 255)
    PrevStroke.Thickness = 1
    PrevStroke.Transparency = 0.5
    PrevStroke.Parent = Preview

    local ArrowBtn = Instance.new("TextButton")
    ArrowBtn.Size = UDim2.new(0, 28, 0, 28)
    ArrowBtn.Position = UDim2.new(1, -122, 0, 9)
    ArrowBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    ArrowBtn.Text = "▼"
    ArrowBtn.TextColor3 = Color3.fromRGB(180, 180, 200)
    ArrowBtn.TextSize = 12
    ArrowBtn.Font = Enum.Font.GothamBold
    ArrowBtn.BorderSizePixel = 0
    ArrowBtn.Parent = Container

    local ArrowCorner = Instance.new("UICorner")
    ArrowCorner.CornerRadius = UDim.new(0, 5)
    ArrowCorner.Parent = ArrowBtn

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 48, 0, 24)
    ToggleBtn.Position = UDim2.new(1, -62, 0.5, -12)
    ToggleBtn.BackgroundColor3 = Config[keyEnabled] and initialColor or Color3.fromRGB(50, 50, 60)
    ToggleBtn.Text = ""
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Parent = Container

    local TCorner = Instance.new("UICorner")
    TCorner.CornerRadius = UDim.new(1, 0)
    TCorner.Parent = ToggleBtn

    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 18, 0, 18)
    Circle.Position = Config[keyEnabled] and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Circle.BorderSizePixel = 0
    Circle.Parent = ToggleBtn

    local CC = Instance.new("UICorner")
    CC.CornerRadius = UDim.new(1, 0)
    CC.Parent = Circle

    local toggleState = Config[keyEnabled]
    track(ToggleBtn.MouseButton1Click:Connect(function()
        toggleState = not toggleState
        Config[keyEnabled] = toggleState
        TweenService:Create(ToggleBtn, TweenInfo.new(0.2), {
            BackgroundColor3 = toggleState and Config[keyColor] or Color3.fromRGB(50, 50, 60)
        }):Play()
        TweenService:Create(Circle, TweenInfo.new(0.2), {
            Position = toggleState and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
        }):Play()
    end))

    local ContentFrame = Instance.new("Frame")
    ContentFrame.Size = UDim2.new(1, -24, 0, EXPANDED_H - COLLAPSED_H - 10)
    ContentFrame.Position = UDim2.new(0, 12, 0, COLLAPSED_H + 5)
    ContentFrame.BackgroundTransparency = 1
    ContentFrame.Parent = Container

    local CLayout = Instance.new("UIListLayout")
    CLayout.Padding = UDim.new(0, 6)
    CLayout.SortOrder = Enum.SortOrder.LayoutOrder
    CLayout.Parent = ContentFrame

    CreateSubToggle(ContentFrame, "👤  Показывать ник", Config[keyName], function(v) Config[keyName] = v end)
    CreateSubToggle(ContentFrame, "📏  Показывать дистанцию", Config[keyDistance], function(v) Config[keyDistance] = v end)
    CreateSubSlider(ContentFrame, "Макс. дистанция (м)", 50, 5000, Config[keyMaxDist], function(v) Config[keyMaxDist] = v end)

    local ColorFrame = Instance.new("Frame")
    ColorFrame.Size = UDim2.new(1, 0, 0, 148)
    ColorFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
    ColorFrame.BorderSizePixel = 0
    ColorFrame.Parent = ContentFrame

    local CFrCorner = Instance.new("UICorner")
    CFrCorner.CornerRadius = UDim.new(0, 5)
    CFrCorner.Parent = ColorFrame

    local ColorTitle = Instance.new("TextLabel")
    ColorTitle.Size = UDim2.new(1, -60, 0, 18)
    ColorTitle.Position = UDim2.new(0, 12, 0, 4)
    ColorTitle.BackgroundTransparency = 1
    ColorTitle.Text = "🎨  Цвет ESP"
    ColorTitle.TextColor3 = Color3.fromRGB(200, 200, 215)
    ColorTitle.TextSize = 12
    ColorTitle.Font = Enum.Font.GothamMedium
    ColorTitle.TextXAlignment = Enum.TextXAlignment.Left
    ColorTitle.Parent = ColorFrame

    local BigPreview = Instance.new("Frame")
    BigPreview.Size = UDim2.new(0, 36, 0, 36)
    BigPreview.Position = UDim2.new(1, -48, 0, 4)
    BigPreview.BackgroundColor3 = initialColor
    BigPreview.BorderSizePixel = 0
    BigPreview.Parent = ColorFrame

    local BPcorner = Instance.new("UICorner")
    BPcorner.CornerRadius = UDim.new(0, 6)
    BPcorner.Parent = BigPreview

    local BPstroke = Instance.new("UIStroke")
    BPstroke.Color = Color3.fromRGB(255, 255, 255)
    BPstroke.Thickness = 1
    BPstroke.Transparency = 0.5
    BPstroke.Parent = BigPreview

    local r0 = math.floor(initialColor.R * 255)
    local g0 = math.floor(initialColor.G * 255)
    local b0 = math.floor(initialColor.B * 255)

    local function applyColor()
        local col = Color3.fromRGB(r0, g0, b0)
        Config[keyColor] = col
        BigPreview.BackgroundColor3 = col
        Preview.BackgroundColor3 = col
        TweenService:Create(ToggleBtn, TweenInfo.new(0.15), {
            BackgroundColor3 = toggleState and col or Color3.fromRGB(50, 50, 60)
        }):Play()
    end

    local function makeChannelSlider(name, y, initial, onChanged)
        local SliderBG = Instance.new("Frame")
        SliderBG.Size = UDim2.new(1, -24, 0, 5)
        SliderBG.Position = UDim2.new(0, 12, 0, y + 22)
        SliderBG.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
        SliderBG.BorderSizePixel = 0
        SliderBG.Parent = ColorFrame

        local SBCorner = Instance.new("UICorner")
        SBCorner.CornerRadius = UDim.new(1, 0)
        SBCorner.Parent = SliderBG

        local Fill = Instance.new("Frame")
        Fill.Size = UDim2.new(initial / 255, 0, 1, 0)
        Fill.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
        Fill.BorderSizePixel = 0
        Fill.Parent = SliderBG

        local FCorner = Instance.new("UICorner")
        FCorner.CornerRadius = UDim.new(1, 0)
        FCorner.Parent = Fill

        local Lbl = Instance.new("TextLabel")
        Lbl.Size = UDim2.new(1, -24, 0, 16)
        Lbl.Position = UDim2.new(0, 12, 0, y + 2)
        Lbl.BackgroundTransparency = 1
        Lbl.Text = name .. ": " .. initial
        Lbl.TextColor3 = Color3.fromRGB(200, 200, 215)
        Lbl.TextSize = 12
        Lbl.Font = Enum.Font.Gotham
        Lbl.TextXAlignment = Enum.TextXAlignment.Left
        Lbl.Parent = ColorFrame

        local dragging = false
        local function update(input)
            local relX = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
            local v = math.floor(relX * 255)
            Fill.Size = UDim2.new(relX, 0, 1, 0)
            Lbl.Text = name .. ": " .. v
            onChanged(v)
            applyColor()
        end

        track(SliderBG.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                update(input)
            end
        end))
        track(UserInputService.InputChanged:Connect(function(input)
            if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                update(input)
            end
        end))
        track(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
            end
        end))
    end

    makeChannelSlider("R", 26, r0, function(v) r0 = v end)
    makeChannelSlider("G", 62, g0, function(v) g0 = v end)
    makeChannelSlider("B", 98, b0, function(v) b0 = v end)

    local expanded = false
    track(ArrowBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        ArrowBtn.Text = expanded and "▲" or "▼"
        TweenService:Create(Container, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Size = UDim2.new(1, 0, 0, expanded and EXPANDED_H or COLLAPSED_H)
        }):Play()
    end))
end

-- ==================== СОЗДАНИЕ СТРАНИЦ ====================
local function CreatePage(id)
    local Scroll = Instance.new("ScrollingFrame")
    Scroll.Name = id
    Scroll.Size = UDim2.new(1, 0, 1, 0)
    Scroll.BackgroundTransparency = 1
    Scroll.BorderSizePixel = 0
    Scroll.ScrollBarThickness = 4
    Scroll.ScrollBarImageColor3 = Color3.fromRGB(255, 100, 100)
    Scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    Scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Scroll.Visible = false
    Scroll.Parent = Content

    local Layout = Instance.new("UIListLayout")
    Layout.Padding = UDim.new(0, 10)
    Layout.SortOrder = Enum.SortOrder.LayoutOrder
    Layout.Parent = Scroll

    local Pad = Instance.new("UIPadding")
    Pad.PaddingRight = UDim.new(0, 10)
    Pad.PaddingBottom = UDim.new(0, 10)
    Pad.Parent = Scroll

    return Scroll
end

local PageAimbot = CreatePage("Aimbot")
local PageESP = CreatePage("ESP")
local PageMisc = CreatePage("Misc")

-- ==================== КАТЕГОРИИ ====================
local function CreateCategoryButton(name, icon, page)
    local Btn = Instance.new("TextButton")
    Btn.Name = name
    Btn.Size = UDim2.new(1, 0, 0, 46)
    Btn.BackgroundColor3 = Color3.fromRGB(22, 22, 30)
    Btn.Text = ""
    Btn.BorderSizePixel = 0
    Btn.AutoButtonColor = false
    Btn.Parent = Sidebar

    local C = Instance.new("UICorner")
    C.CornerRadius = UDim.new(0, 6)
    C.Parent = Btn

    local Indicator = Instance.new("Frame")
    Indicator.Size = UDim2.new(0, 3, 0.55, 0)
    Indicator.Position = UDim2.new(0, 0, 0.225, 0)
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 100, 100)
    Indicator.BorderSizePixel = 0
    Indicator.BackgroundTransparency = 1
    Indicator.Parent = Btn

    local IndCorner = Instance.new("UICorner")
    IndCorner.CornerRadius = UDim.new(1, 0)
    IndCorner.Parent = Indicator

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(1, -20, 1, 0)
    Lbl.Position = UDim2.new(0, 18, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = icon .. "  " .. name
    Lbl.TextColor3 = Color3.fromRGB(170, 170, 190)
    Lbl.TextSize = 15
    Lbl.Font = Enum.Font.GothamMedium
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Parent = Btn

    local function setActive(active)
        TweenService:Create(Btn, TweenInfo.new(0.2), {
            BackgroundColor3 = active and Color3.fromRGB(35, 35, 50) or Color3.fromRGB(22, 22, 30)
        }):Play()
        TweenService:Create(Lbl, TweenInfo.new(0.2), {
            TextColor3 = active and Color3.fromRGB(255, 100, 100) or Color3.fromRGB(170, 170, 190)
        }):Play()
        TweenService:Create(Indicator, TweenInfo.new(0.2), {
            BackgroundTransparency = active and 0 or 1
        }):Play()
    end

    track(Btn.MouseButton1Click:Connect(function()
        if CurrentCategory == name then return end
        if CurrentCategory and CategoryButtons[CurrentCategory] then
            CategoryButtons[CurrentCategory].setActive(false)
        end
        CurrentCategory = name
        setActive(true)
        for pName, pFrame in pairs(Pages) do
            pFrame.Visible = (pName == name)
        end
    end))

    CategoryButtons[name] = {setActive = setActive, button = Btn, page = page}
end

CreateCategoryButton("Aimbot", "🎯", PageAimbot)
CreateCategoryButton("ESP", "👁", PageESP)
CreateCategoryButton("Misc", "🎲", PageMisc)

Pages["Aimbot"] = PageAimbot
Pages["ESP"] = PageESP
Pages["Misc"] = PageMisc

-- ==================== AIMBOT UI ====================
CreateToggle(PageAimbot, "🎯  Включить аимбот", Config.AimbotEnabled, function(v) Config.AimbotEnabled = v end)
CreateDropdown(PageAimbot, "Режим (Предмет)", {"Revolver", "Flashlight"}, Config.AimMode, function(v)
    Config.AimMode = v
    print("[VD Alpha] Режим аимбота: " .. v)
end)
CreateSlider(PageAimbot, "Smoothness (плавность)", 0.01, 1, Config.Smoothness, function(v) Config.Smoothness = v end)
CreateSlider(PageAimbot, "FOV (радиус)", 10, 500, Config.FOV, function(v) Config.FOV = v end)
CreateSlider(PageAimbot, "Prediction", 0, 0.5, Config.Prediction, function(v) Config.Prediction = v end)
CreateSlider(PageAimbot, "Max Distance", 50, 2000, Config.MaxDistance, function(v) Config.MaxDistance = v end)
CreateToggle(PageAimbot, "🛡  Team Check", Config.TeamCheck, function(v) Config.TeamCheck = v end)
CreateToggle(PageAimbot, "🧱  Wall Check", Config.WallCheck, function(v) Config.WallCheck = v end)
CreateSlider(PageAimbot, "Фонарик: Смещение X (вправо)", -100, 100, Config.FlashlightOffsetX, function(v) Config.FlashlightOffsetX = v end)
CreateSlider(PageAimbot, "Фонарик: Смещение Y (вверх)", -100, 100, Config.FlashlightOffsetY, function(v) Config.FlashlightOffsetY = v end)

-- ==================== ESP UI ====================
CreateESPEntry(PageESP, "🟢  ESP Выживших", "Survivor", Config.ESP_SurvivorColor)
CreateESPEntry(PageESP, "🔴  ESP Убийц",    "Killer",   Config.ESP_KillerColor)

-- ==================== MISC UI ====================
CreateToggle(PageMisc, "🚀  Скорость (заглушка)", false, function(v) end)
CreateToggle(PageMisc, "🦘  Прыжок (заглушка)", false, function(v) end)

local UnloadBtn = Instance.new("TextButton")
UnloadBtn.Size = UDim2.new(1, 0, 0, 46)
UnloadBtn.BackgroundColor3 = Color3.fromRGB(200, 60, 60)
UnloadBtn.Text = "⚠  ВЫГРУЗИТЬ СКРИПТ"
UnloadBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UnloadBtn.TextSize = 15
UnloadBtn.Font = Enum.Font.GothamBold
UnloadBtn.BorderSizePixel = 0
UnloadBtn.Parent = PageMisc

local UBCorner = Instance.new("UICorner")
UBCorner.CornerRadius = UDim.new(0, 6)
UBCorner.Parent = UnloadBtn

track(UnloadBtn.MouseButton1Click:Connect(function()
    for _, c in ipairs(ActiveConnections) do
        pcall(function() c:Disconnect() end)
    end
    if ScreenGui then ScreenGui:Destroy() end
    for _, data in pairs(genv.VD_ALPHA_LOADED.espCache or {}) do
        if data.highlight then pcall(function() data.highlight:Destroy() end) end
        if data.billboard then pcall(function() data.billboard:Destroy() end) end
    end
    genv.VD_ALPHA_LOADED = nil
    print("[VD Alpha] Скрипт выгружен.")
end))

-- ==================== FOV КРУГ ====================
local FOVCircle = Instance.new("Frame")
FOVCircle.Name = "FOVCircle"
FOVCircle.AnchorPoint = Vector2.new(0.5, 0.5)
FOVCircle.Size = UDim2.new(0, Config.FOV * 2, 0, Config.FOV * 2)
FOVCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
FOVCircle.BackgroundTransparency = 1
FOVCircle.BorderSizePixel = 0
FOVCircle.Visible = false
FOVCircle.Parent = ScreenGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVCircle

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = Color3.fromRGB(255, 100, 100)
FOVStroke.Thickness = 1.5
FOVStroke.Transparency = 0.3
FOVStroke.Parent = FOVCircle

track(RunService.RenderStepped:Connect(function()
    FOVCircle.Visible = Config.AimbotEnabled and Config.ShowFOV
    FOVCircle.Size = UDim2.new(0, Config.FOV * 2, 0, Config.FOV * 2)
end))

-- ==================== ЛОГИКА АИМБОТА ====================
local aiming = false

track(UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = true
    end
end))
track(UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton2 then
        aiming = false
    end
end))

local function isVisible(part)
    if not Config.WallCheck then return true end
    local origin = Camera.CFrame.Position
    local dir = part.Position - origin
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, Camera}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(origin, dir, rayParams)
    return not result or result.Instance:IsDescendantOf(part.Parent)
end

local function getClosestTarget()
    local closest, closestDist = nil, Config.FOV
    local mousePos = UserInputService:GetMouseLocation()
    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end
        if not player.Character then continue end
        local hrp = player.Character:FindFirstChild("HumanoidRootPart")
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if not hrp or not hum or hum.Health <= 0 then continue end
        if Config.TeamCheck and player.Team == LocalPlayer.Team then continue end
        local dist3D = (Camera.CFrame.Position - hrp.Position).Magnitude
        if dist3D > Config.MaxDistance then continue end
        local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
        if not onScreen then continue end
        local dist2D = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
        if dist2D < closestDist then
            local targetPart = player.Character:FindFirstChild("Head") or hrp
            if isVisible(targetPart) then
                closest = targetPart
                closestDist = dist2D
            end
        end
    end
    return closest
end

track(RunService.RenderStepped:Connect(function()
    if not Config.AimbotEnabled or not aiming then return end
    local target = getClosestTarget()
    if not target then return end

    local targetPos = target.Position
    if Config.Prediction > 0 then
        targetPos = targetPos + target.Velocity * Config.Prediction
    end
    if Config.AimMode == "Flashlight" then
        local right = Camera.CFrame.RightVector
        local up = Camera.CFrame.UpVector
        targetPos = targetPos + right * (Config.FlashlightOffsetX / 100) + up * (Config.FlashlightOffsetY / 100)
    end

    local aimCFrame = CFrame.new(Camera.CFrame.Position, targetPos)
    Camera.CFrame = Camera.CFrame:Lerp(aimCFrame, Config.Smoothness)
end))

-- ==================== ЛОГИКА ESP ====================
local espCache = {}
genv.VD_ALPHA_LOADED.espCache = espCache

-- Безопасный поиск роли (всё в pcall)
local function getRole(player)
    -- 1. Team
    local ok1, team = pcall(function() return player.Team end)
    if ok1 and team then
        local tn = tostring(team.Name):lower()
        if tn:find("killer") or tn:find("убийца") or tn:find("slasher") then return "Killer" end
        if tn:find("survivor") or tn:find("выжив") or tn:find("runner") then return "Survivor" end
    end

    -- 2. Атрибуты
    local ok2, attr = pcall(function()
        return player:GetAttribute("Role") or player:GetAttribute("Team") or player:GetAttribute("role")
    end)
    if ok2 and attr then
        local a = tostring(attr):lower()
        if a:find("killer") then return "Killer" end
        if a:find("survivor") then return "Survivor" end
    end

    -- 3. leaderstats
    local ok3, ls = pcall(function() return player:FindFirstChild("leaderstats") end)
    if ok3 and ls then
        local rs = ls:FindFirstChild("Role") or ls:FindFirstChild("Team")
        if rs then
            local r = tostring(rs.Value):lower()
            if r:find("killer") then return "Killer" end
            if r:find("survivor") then return "Survivor" end
        end
    end

    -- 4. Имя персонажа
    local char = player.Character
    if char then
        local cn = char.Name:lower()
        if cn:find("killer") then return "Killer" end
        if cn:find("survivor") then return "Survivor" end
    end

    -- 5. Имя игрока
    local n = player.Name:lower()
    if n:find("killer") then return "Killer" end

    return "Survivor"
end

-- ==================== ДИАГНОСТИКА РОЛЕЙ ====================
task.spawn(function()
    task.wait(5)
    print("========== [VD Alpha] ДИАГНОСТИКА РОЛЕЙ ==========")
    for _, p in ipairs(Players:GetPlayers()) do
        if p == LocalPlayer then continue end
        local role = getRole(p)
        local teamName = "нет Team"
        pcall(function()
            if p.Team then teamName = p.Team.Name end
        end)
        local attrStr = "nil"
        pcall(function()
            attrStr = tostring(p:GetAttribute("Role") or p:GetAttribute("Team") or "nil")
        end)
        local leaderStr = "нет"
        local ls = p:FindFirstChild("leaderstats")
        if ls then
            local r = ls:FindFirstChild("Role") or ls:FindFirstChild("Team")
            if r then leaderStr = tostring(r.Value) end
        end
        print(string.format("[%s] Role=%s | Team=%s | Attr=%s | Leaderstat=%s",
            p.Name, role, teamName, attrStr, leaderStr))
    end
    print("===================================================")
end)

local function createESP(player)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local teamType = getRole(player)
    local isKiller = (teamType == "Killer")
    local color = isKiller and Config.ESP_KillerColor or Config.ESP_SurvivorColor

    local highlight = Instance.new("Highlight")
    highlight.Name = "VD_ESP_Highlight"
    highlight.Adornee = character
    highlight.FillColor = color
    highlight.FillTransparency = 0.5
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.OutlineTransparency = 0.3
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Enabled = false
    highlight.Parent = character

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "VD_ESP_Billboard"
    billboard.Size = UDim2.new(0, 200, 0, 42)
    billboard.StudsOffset = Vector3.new(0, 3.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Adornee = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")
    billboard.Enabled = false
    billboard.Parent = character

    local nameLabel = Instance.new("TextLabel")
    nameLabel.Name = "NameLabel"
    nameLabel.Size = UDim2.new(1, 0, 0, 20)
    nameLabel.BackgroundTransparency = 1
    nameLabel.Text = player.Name
    nameLabel.TextColor3 = color
    nameLabel.TextStrokeTransparency = 0.3
    nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    nameLabel.Font = Enum.Font.GothamBold
    nameLabel.TextSize = 14
    nameLabel.Parent = billboard

    local distLabel = Instance.new("TextLabel")
    distLabel.Name = "DistanceLabel"
    distLabel.Size = UDim2.new(1, 0, 0, 18)
    distLabel.Position = UDim2.new(0, 0, 0, 20)
    distLabel.BackgroundTransparency = 1
    distLabel.Text = "[0m]"
    distLabel.TextColor3 = color
    distLabel.TextStrokeTransparency = 0.3
    distLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    distLabel.Font = Enum.Font.Gotham
    distLabel.TextSize = 12
    distLabel.Parent = billboard

    espCache[player] = {
        highlight = highlight,
        billboard = billboard,
        nameLabel = nameLabel,
        distLabel = distLabel,
        team = teamType,
    }
end

local function removeESP(player)
    if espCache[player] then
        if espCache[player].highlight then espCache[player].highlight:Destroy() end
        if espCache[player].billboard then espCache[player].billboard:Destroy() end
        espCache[player] = nil
    end
end

track(Players.PlayerAdded:Connect(function(player)
    track(player.CharacterAdded:Connect(function()
        task.wait(0.5)
        if espCache[player] then removeESP(player) end
        if Config.ESP_Survivors or Config.ESP_Killers then
            createESP(player)
        end
    end))
end))

track(Players.PlayerRemoving:Connect(removeESP))

track(RunService.RenderStepped:Connect(function()
    local anyOn = Config.ESP_Survivors or Config.ESP_Killers

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local data = espCache[player]

        if anyOn and not data and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            createESP(player)
            data = espCache[player]
        end

        if data then
            local character = player.Character
            local hum = character and character:FindFirstChildOfClass("Humanoid")

            if character and hum and hum.Health > 0 then
                local currentTeam = getRole(player)
                if currentTeam ~= data.team then
                    data.team = currentTeam
                end
                local isKiller = (currentTeam == "Killer")
                local color = isKiller and Config.ESP_KillerColor or Config.ESP_SurvivorColor
                local enabled = isKiller and Config.ESP_Killers or (not isKiller and Config.ESP_Survivors)
                local showName = isKiller and Config.ESP_Killer_Name or Config.ESP_Survivor_Name
                local showDist = isKiller and Config.ESP_Killer_Distance or Config.ESP_Survivor_Distance
                local maxDist = isKiller and Config.ESP_Killer_MaxDist or Config.ESP_Survivor_MaxDist

                local myChar = LocalPlayer.Character
                local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
                local dist = 0
                if myHRP and character:FindFirstChild("HumanoidRootPart") then
                    dist = math.floor((myHRP.Position - character.HumanoidRootPart.Position).Magnitude)
                end

                local show = enabled and dist <= maxDist

                data.highlight.Enabled = show
                data.highlight.FillColor = color
                data.highlight.Adornee = character

                data.billboard.Enabled = show and (showName or showDist)
                data.billboard.Adornee = character:FindFirstChild("Head") or character:FindFirstChild("HumanoidRootPart")

                data.nameLabel.Visible = showName
                data.nameLabel.Text = player.Name
                data.nameLabel.TextColor3 = color

                data.distLabel.Visible = showDist
                data.distLabel.Text = "[" .. dist .. "m]"
                data.distLabel.TextColor3 = color

                data.nameLabel.Position = UDim2.new(0, 0, 0, showName and 0 or 20)
                data.distLabel.Position = UDim2.new(0, 0, 0, showName and 20 or 0)
            else
                data.highlight.Enabled = false
                data.billboard.Enabled = false
            end
        end
    end
end))

-- ==================== ПЕРЕТАСКИВАНИЕ ====================
local dragging, dragStart, startPos
track(Header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Menu.Position
        track(input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end))
    end
end))
track(UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        local delta = input.Position - dragStart
        Menu.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end))

-- ==================== УПРАВЛЕНИЕ МЕНЮ ====================
local menuOpen = false
local menuReady = false

task.delay(3, function()
    menuReady = true
    Menu.Visible = true
    menuOpen = true
    Menu.Size = UDim2.new(0, 0, 0, 0)
    Menu.Position = UDim2.new(0.5, 0, 0.5, 0)
    TweenService:Create(Menu, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, MENU_W, 0, MENU_H),
        Position = UDim2.new(0.5, -MENU_W/2, 0.5, -MENU_H/2)
    }):Play()
end)

local function toggleMenu()
    if not menuReady then return end
    menuOpen = not menuOpen
    if menuOpen then
        Menu.Visible = true
        Menu.Size = UDim2.new(0, 0, 0, 0)
        Menu.Position = UDim2.new(0.5, 0, 0.5, 0)
        TweenService:Create(Menu, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, MENU_W, 0, MENU_H),
            Position = UDim2.new(0.5, -MENU_W/2, 0.5, -MENU_H/2)
        }):Play()
    else
        TweenService:Create(Menu, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        task.wait(0.25)
        Menu.Visible = false
    end
end

track(CloseBtn.MouseButton1Click:Connect(toggleMenu))
track(UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.L then
        toggleMenu()
    end
end))

CategoryButtons["Aimbot"].setActive(true)
CurrentCategory = "Aimbot"
PageAimbot.Visible = true

print("[VD Alpha v0.4.1] Скрипт загружен. L — меню, ПКМ — аимбот.")
print("[VD Alpha v0.4.1] Диагностика ролей появится в консоли через 5 секунд. Открой F9.")
