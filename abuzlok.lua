-- ============================================
-- VIOLENCE DISTRICT | AIMBOT + ESP | ALPHA v0.2
-- Auto-cleanup edition
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
            if data.highlight then
                pcall(function() data.highlight:Destroy() end)
            end
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
    AimMode = "Revolver", -- "Revolver" или "Flashlight"
    Smoothness = 0.15,
    FOV = 150,
    ShowFOV = true,
    TeamCheck = true,
    WallCheck = false,
    Prediction = 0.16,
    MaxDistance = 1000,
    -- Смещение для фонарика
    FlashlightOffsetX = 30,
    FlashlightOffsetY = -20,
    -- ESP
    ESP_Survivors = false,
    ESP_Killers = false,
    ESP_SurvivorColor = Color3.fromRGB(0, 255, 100),
    ESP_KillerColor = Color3.fromRGB(255, 50, 50),
}

-- ==================== РАЗМЕРЫ ====================
local BASE_W, BASE_H = 1920, 1200
local SCALE = 1 / 1.4
local MENU_W = math.floor(BASE_W * SCALE)
local MENU_H = math.floor(BASE_H * SCALE)

-- ==================== GUI ====================
-- CoreGui-версия удаляется выше через old.gui, но на случай если флаг слетел — проверим вручную
local existing = CoreGui:FindFirstChild("VD_Alpha_GUI")
if existing then existing:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VD_Alpha_GUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = CoreGui
genv.VD_ALPHA_LOADED.gui = ScreenGui  -- ← регистрируем

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
    {text = "Загрузка модулей...",       time = 0.4},
    {text = "Проверка окружения...",     time = 0.3},
    {text = "Инициализация Aimbot...",   time = 0.4},
    {text = "Инициализация ESP...",      time = 0.4},
    {text = "Готово!",                   time = 0.3},
}

task.spawn(function()
    for i, stage in ipairs(Stages) do
        StatusLabel.Text = stage.text
        local targetSize = UDim2.new(i / #Stages, 0, 1, 0)
        TweenService:Create(BarFill, TweenInfo.new(stage.time, Enum.EasingStyle.Quad), {Size = targetSize}):Play()
        task.wait(stage.time)
    end
    task.wait(0.3)
    TweenService:Create(LoadingFrame, TweenInfo.new(0.5), {BackgroundTransparency = 1}):Play()
    TweenService:Create(Title, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
    TweenService:Create(BarBG, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
    TweenService:Create(BarFill, TweenInfo.new(0.3), {BackgroundTransparency = 1}):Play()
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

-- ==================== ЗАГОЛОВОК ====================
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
HeaderTitle.Text = "🔪  VIOLENCE DISTRICT  •  ALPHA v0.2"
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

    local value = default
    local dragging = false

    local function updateFromInput(input)
        local relX = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
        value = min + (max - min) * relX
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

-- ==================== КНОПКИ КАТЕГОРИЙ ====================
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

-- ==================== НАПОЛНЕНИЕ: AIMBOT ====================
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

-- ==================== НАПОЛНЕНИЕ: ESP ====================
CreateToggle(PageESP, "🟢  ESP Выживших", Config.ESP_Survivors, function(v) Config.ESP_Survivors = v end)
CreateToggle(PageESP, "🔴  ESP Убийц", Config.ESP_Killers, function(v) Config.ESP_Killers = v end)

local ESPInfo = Instance.new("TextLabel")
ESPInfo.Size = UDim2.new(1, 0, 0, 60)
ESPInfo.BackgroundColor3 = Color3.fromRGB(25, 25, 32)
ESPInfo.BorderSizePixel = 0
ESPInfo.Text = "Цвета ESP (фиксированные для альфы):\nВыжившие — зелёный, Убийцы — красный"
ESPInfo.TextColor3 = Color3.fromRGB(180, 180, 200)
ESPInfo.TextSize = 13
ESPInfo.Font = Enum.Font.Gotham
ESPInfo.Parent = PageESP

local EICorner = Instance.new("UICorner")
EICorner.CornerRadius = UDim.new(0, 6)
EICorner.Parent = ESPInfo

-- ==================== НАПОЛНЕНИЕ: MISC ====================
CreateToggle(PageMisc, "🚀  Скорость (заглушка)", false, function(v) end)
CreateToggle(PageMisc, "🦘  Прыжок (заглушка)", false, function(v) end)

-- Кнопка выгрузки
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
    for _, data in pairs(espCache or {}) do
        if data.highlight then pcall(function() data.highlight:Destroy() end) end
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
genv.VD_ALPHA_LOADED.espCache = espCache  -- ← регистрируем

local function getTeamType(player)
    if player.Team then
        local teamName = player.Team.Name:lower()
        if teamName:find("killer") or teamName:find("убийца") or teamName:find("slasher") then
            return "Killer"
        elseif teamName:find("survivor") or teamName:find("выжив") or teamName:find("runner") then
            return "Survivor"
        end
    end
    local name = player.Name:lower()
    if name:find("killer") then return "Killer" end
    if name:find("survivor") then return "Survivor" end
    return "Survivor"
end

local function createESP(player)
    local character = player.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end

    local teamType = getTeamType(player)
    local color = (teamType == "Killer") and Config.ESP_KillerColor or Config.ESP_SurvivorColor

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

    espCache[player] = {highlight = highlight, team = teamType}
end

local function removeESP(player)
    if espCache[player] then
        if espCache[player].highlight then
            espCache[player].highlight:Destroy()
        end
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
    if not Config.ESP_Survivors and not Config.ESP_Killers then
        for _, data in pairs(espCache) do
            if data.highlight then data.highlight.Enabled = false end
        end
        return
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player == LocalPlayer then continue end

        local data = espCache[player]

        if not data and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            createESP(player)
            data = espCache[player]
        end

        if data and data.highlight then
            local character = player.Character
            if character and character:FindFirstChild("Humanoid") and character.Humanoid.Health > 0 then
                local currentTeam = getTeamType(player)
                if currentTeam ~= data.team then
                    data.team = currentTeam
                    data.highlight.FillColor = (currentTeam == "Killer") and Config.ESP_KillerColor or Config.ESP_SurvivorColor
                end

                local shouldShow = (currentTeam == "Killer" and Config.ESP_Killers) or (currentTeam == "Survivor" and Config.ESP_Survivors)
                data.highlight.Enabled = shouldShow
                data.highlight.Adornee = character
            else
                data.highlight.Enabled = false
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

print("[VD Alpha v0.2] Скрипт загружен. Нажми L чтобы открыть меню.")
print("[VD Alpha v0.2] Всего подключений: " .. tostring(#ActiveConnections))
