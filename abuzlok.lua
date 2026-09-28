--[[
    █████╗ ██████╗ ██╗   ██╗███████╗██╗      ██████╗ ██╗  ██╗
    ██╔══██╗██╔══██╗██║   ██║╚══███╔╝██║     ██╔═══██╗██║ ██╔╝
    ███████║██████╔╝██║   ██║  ███╔╝ ██║     ██║   ██║█████╔╝
    ██╔══██║██╔══██╗██║   ██║ ███╔╝  ██║     ██║   ██║██╔═██╗
    ██║  ██║██████╔╝╚██████╔╝███████╗███████╗╚██████╔╝██║  ██╗
    ╚═╝  ╚═╝╚═════╝  ╚═════╝ ╚══════╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝
                Player Highlight • v2 • by abuzlok
--]]

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local LocalPlayer      = Players.LocalPlayer

-- ============================================================
-- КОНФИГ
-- ============================================================
local Config = {
    Enabled             = true,
    FillColor           = Color3.fromRGB(160, 100, 255),
    OutlineColor        = Color3.fromRGB(255, 255, 255),
    FillTransparency    = 0.55,
    OutlineTransparency = 0.10,
    Rainbow             = false,
    TeamCheck           = false,
    MaxDistance         = 1000,
    HighlightKey        = Enum.KeyCode.RightShift, -- вкл/выкл подсветку
    ToggleUIKey         = Enum.KeyCode.L,          -- показать/скрыть меню
}

-- ============================================================
-- УТИЛИТЫ
-- ============================================================
local function new(class, props)
    local o = Instance.new(class)
    for k, v in pairs(props or {}) do
        if k ~= "Parent" then o[k] = v end
    end
    if props and props.Parent then o.Parent = props.Parent end
    return o
end

local function tween(obj, time, props, style, dir)
    local t = TweenService:Create(
        obj,
        TweenInfo.new(time, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out),
        props
    )
    t:Play()
    return t
end

-- ============================================================
-- ROOT
-- ============================================================
local parentGui
pcall(function() parentGui = gethui() end)
if not parentGui then
    pcall(function() parentGui = game:GetService("CoreGui") end)
end
if not parentGui then
    parentGui = LocalPlayer:WaitForChild("PlayerGui")
end

local gui = new("ScreenGui", {
    Name = "abuzlok_ui",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = parentGui,
})

-- ============================================================
-- ГЛАВНАЯ ПАНЕЛЬ
-- ============================================================
local HEADER_H  = 54
local CONTENT_H = 340
local WIDTH     = 340
local EXPANDED_SIZE   = UDim2.new(0, WIDTH, 0, HEADER_H + CONTENT_H)
local COLLAPSED_SIZE  = UDim2.new(0, WIDTH, 0, HEADER_H)

local main = new("Frame", {
    Name = "abuzlok",
    AnchorPoint = Vector2.new(0.5, 0),
    Position = UDim2.new(0.5, 0, 0, 18),
    Size = EXPANDED_SIZE,           -- ← открыто по умолчанию (фикс бага)
    BackgroundColor3 = Color3.fromRGB(15, 13, 22),
    BorderSizePixel = 0,
    ClipsDescendants = true,
    Parent = gui,
})
new("UICorner", { CornerRadius = UDim.new(0, 16), Parent = main })

-- Градиентный фон
new("UIGradient", {
    Rotation = 90,
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(22, 18, 34)),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(12, 10, 20)),
    }),
    Parent = main,
})

-- Обводка с анимированным градиентом
local stroke = new("UIStroke", {
    Thickness = 1.6,
    ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    Color = Color3.fromRGB(255, 255, 255),
    Parent = main,
})
local strokeGrad = new("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(180, 120, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(120, 200, 255)),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(255, 120, 200)),
    }),
    Parent = stroke,
})

-- Свечение
local glow = new("ImageLabel", {
    Image = "rbxassetid://5028857084",
    ImageColor3 = Color3.fromRGB(140, 90, 255),
    ImageTransparency = 0.55,
    BackgroundTransparency = 1,
    AnchorPoint = Vector2.new(0.5, 0.5),
    Position = UDim2.new(0.5, 0, 0, 0),
    Size = UDim2.new(1, 80, 1, 80),
    ZIndex = 0,
    Parent = main,
})

-- ============================================================
-- DRAG HANDLE (невидимая полоса для перетаскивания)
-- ============================================================
-- Отдельный прозрачный фрейм поверх хедера, но НЕ поверх кнопок справа.
-- Именно он отвечает за перетаскивание → клики по кнопкам больше не съедаются.
local dragHandle = new("TextButton", {
    Name = "DragHandle",
    BackgroundTransparency = 1,
    Text = "",
    AutoButtonColor = false,
    Position = UDim2.new(0, 0, 0, 0),
    Size = UDim2.new(1, -105, 0, HEADER_H), -- справа оставляем место под кнопки
    ZIndex = 5,
    Parent = main,
})

-- ============================================================
-- ХЕДЕР
-- ============================================================
local dot = new("Frame", {
    Size = UDim2.new(0, 10, 0, 10),
    Position = UDim2.new(0, 20, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundColor3 = Color3.fromRGB(170, 110, 255),
    BorderSizePixel = 0,
    ZIndex = 3,
    Parent = main,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = dot })
new("UIStroke", {
    Thickness = 1.5, Color = Color3.fromRGB(255,255,255), Transparency = 0.4, Parent = dot
})

task.spawn(function()
    while dot.Parent do
        tween(dot, 1.2, { Size = UDim2.new(0, 13, 0, 13) }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.wait(1.2)
        tween(dot, 1.2, { Size = UDim2.new(0, 10, 0, 10) }, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut)
        task.wait(1.2)
    end
end)

local title = new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 40, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    Size = UDim2.new(0, 200, 0, 30),
    Font = Enum.Font.GothamBlack,
    Text = "abuzlok",
    TextSize = 21,
    TextColor3 = Color3.fromRGB(255, 255, 255),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 3,
    Parent = main,
})
local titleGrad = new("UIGradient", {
    Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(180, 130, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(130, 200, 255)),
    }),
    Parent = title,
})

new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 40, 0.5, 12),
    AnchorPoint = Vector2.new(0, 0.5),
    Size = UDim2.new(0, 200, 0, 12),
    Font = Enum.Font.Gotham,
    Text = "player highlight • L - скрыть • RShift - вкл/выкл",
    TextSize = 9,
    TextColor3 = Color3.fromRGB(150, 150, 175),
    TextXAlignment = Enum.TextXAlignment.Left,
    ZIndex = 3,
    Parent = main,
})

-- Переключатель вкл/выкл подсветки
local toggleBtn = new("TextButton", {
    Name = "Toggle",
    Size = UDim2.new(0, 46, 0, 24),
    Position = UDim2.new(1, -50, 0.5, 0),
    AnchorPoint = Vector2.new(1, 0.5),
    BackgroundColor3 = Color3.fromRGB(140, 90, 255),
    AutoButtonColor = false,
    Text = "",
    ZIndex = 6,
    Parent = main,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = toggleBtn })

local toggleKnob = new("Frame", {
    Size = UDim2.new(0, 18, 0, 18),
    Position = UDim2.new(1, -21, 0.5, 0),
    AnchorPoint = Vector2.new(0, 0.5),
    BackgroundColor3 = Color3.fromRGB(255, 255, 255),
    BorderSizePixel = 0,
    ZIndex = 7,
    Parent = toggleBtn,
})
new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = toggleKnob })

-- Стрелка
local arrow = new("TextButton", {
    Size = UDim2.new(0, 24, 0, 24),
    Position = UDim2.new(1, -14, 0.5, 0),
    AnchorPoint = Vector2.new(1, 0.5),
    BackgroundTransparency = 1,
    Text = "▼",
    TextColor3 = Color3.fromRGB(180, 180, 200),
    Font = Enum.Font.GothamBold,
    TextSize = 13,
    AutoButtonColor = false,
    ZIndex = 6,
    Parent = main,
})

-- ============================================================
-- КОНТЕНТ
-- ============================================================
local content = new("Frame", {
    Name = "Content",
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 0, 0, HEADER_H),
    Size = UDim2.new(1, 0, 0, CONTENT_H),
    ZIndex = 2,
    Parent = main,
})

local sep = new("Frame", {
    Size = UDim2.new(1, -32, 0, 1),
    Position = UDim2.new(0, 16, 0, 0),
    BackgroundColor3 = Color3.fromRGB(45, 40, 62),
    BorderSizePixel = 0,
    ZIndex = 2,
    Parent = content,
})
new("UIGradient", {
    Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 1),
    }),
    Parent = sep,
})

-- ---- Хелпер: подпись раздела ----
local function sectionLabel(text, y)
    return new("TextLabel", {
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 16, 0, y),
        Size = UDim2.new(1, -32, 0, 14),
        Font = Enum.Font.GothamBold,
        Text = text,
        TextSize = 10,
        TextColor3 = Color3.fromRGB(130, 130, 160),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = content,
    })
end

-- ---- Хелпер: тумблер ----
local function makeToggleVisual(btn, knob, state)
    tween(btn, 0.22, {
        BackgroundColor3 = state and Color3.fromRGB(140, 90, 255) or Color3.fromRGB(45, 42, 62),
    })
    tween(knob, 0.22, {
        Position = state and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
    }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

local function createToggle(y, labelText, initial, callback)
    local row = new("TextButton", {
        Size = UDim2.new(1, -32, 0, 30),
        Position = UDim2.new(0, 16, 0, y),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = content,
    })

    new("TextLabel", {
        BackgroundTransparency = 1,
        Size = UDim2.new(0.7, 0, 1, 0),
        Font = Enum.Font.GothamMedium,
        Text = labelText,
        TextSize = 13,
        TextColor3 = Color3.fromRGB(220, 220, 235),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local btn = new("Frame", {
        Size = UDim2.new(0, 40, 0, 20),
        Position = UDim2.new(1, 0, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundColor3 = initial and Color3.fromRGB(140, 90, 255) or Color3.fromRGB(45, 42, 62),
        Parent = row,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = btn })

    local knob = new("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = initial and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Parent = btn,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

    local state = initial
    row.MouseButton1Click:Connect(function()
        state = not state
        makeToggleVisual(btn, knob, state)
        callback(state)
    end)

    return row
end

-- ---- Хелпер: слайдер ----
local function createSlider(y, labelText, initial, minV, maxV, fmt, callback)
    local row = new("Frame", {
        Size = UDim2.new(1, -32, 0, 40),
        Position = UDim2.new(0, 16, 0, y),
        BackgroundTransparency = 1,
        Parent = content,
    })

    new("TextLabel", {
        Size = UDim2.new(0.6, 0, 0, 14),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = labelText,
        TextSize = 12,
        TextColor3 = Color3.fromRGB(210, 210, 230),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = row,
    })

    local valLabel = new("TextLabel", {
        Size = UDim2.new(0.4, 0, 0, 14),
        Position = UDim2.new(0.6, 0, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = fmt and fmt(initial) or tostring(initial),
        TextSize = 12,
        TextColor3 = Color3.fromRGB(170, 130, 255),
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = row,
    })

    local track = new("Frame", {
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0, 28),
        BackgroundColor3 = Color3.fromRGB(38, 35, 52),
        BorderSizePixel = 0,
        Parent = row,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = track })

    local startPct = (initial - minV) / (maxV - minV)

    local fill = new("Frame", {
        Size = UDim2.new(startPct, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(160, 100, 255),
        BorderSizePixel = 0,
        Parent = track,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = fill })
    new("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(130, 90, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(220, 130, 255)),
        }),
        Parent = fill,
    })

    local knob = new("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(startPct, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Parent = track,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = knob })

    local dragging = false

    local function update(input)
        local posX = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
        local pct  = math.clamp(posX, 0, 1)
        local val  = minV + (maxV - minV) * pct
        fill.Size = UDim2.new(pct, 0, 1, 0)
        knob.Position = UDim2.new(pct, 0, 0.5, 0)
        valLabel.Text = fmt and fmt(val) or tostring(val)
        callback(val)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
           or input.UserInputType == Enum.UserInputType.Touch) then
            update(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)

    return row
end

-- ============================================================
-- РАЗМЕЩЕНИЕ ЭЛЕМЕНТОВ
-- ============================================================
local yCursor = 12

sectionLabel("ЦВЕТ ПОДСВЕТКИ", yCursor)
yCursor = yCursor + 20

local presetColors = {
    Color3.fromRGB(160, 100, 255),
    Color3.fromRGB(255,  80, 100),
    Color3.fromRGB( 80, 255, 140),
    Color3.fromRGB( 80, 160, 255),
    Color3.fromRGB(255, 210,  80),
    Color3.fromRGB(255, 120, 200),
    Color3.fromRGB( 80, 255, 255),
    Color3.fromRGB(255, 255, 255),
}

local presetRow = new("Frame", {
    Size = UDim2.new(1, -32, 0, 30),
    Position = UDim2.new(0, 16, 0, yCursor),
    BackgroundTransparency = 1,
    Parent = content,
})

local presetButtons = {}
new("UIListLayout", {
    FillDirection = Enum.FillDirection.Horizontal,
    HorizontalAlignment = Enum.HorizontalAlignment.Left,
    VerticalAlignment = Enum.VerticalAlignment.Center,
    Padding = UDim.new(0, 8),
    Parent = presetRow,
})

for _, col in ipairs(presetColors) do
    local btn = new("TextButton", {
        Size = UDim2.new(0, 26, 0, 26),
        BackgroundColor3 = col,
        Text = "",
        AutoButtonColor = false,
        Parent = presetRow,
    })
    new("UICorner", { CornerRadius = UDim.new(1, 0), Parent = btn })
    local bs = new("UIStroke", {
        Thickness = 0, Color = Color3.fromRGB(255,255,255), Parent = btn
    })
    btn.MouseEnter:Connect(function() tween(btn, 0.15, {Size = UDim2.new(0, 30, 0, 30)}) end)
    btn.MouseLeave:Connect(function() tween(btn, 0.15, {Size = UDim2.new(0, 26, 0, 26)}) end)
    btn.MouseButton1Click:Connect(function()
        Config.FillColor    = col
        Config.OutlineColor = col:Lerp(Color3.new(1,1,1), 0.35)
        for _, b in ipairs(presetButtons) do
            tween(b.stroke, 0.15, {Thickness = 0})
        end
        tween(bs, 0.15, {Thickness = 2})
    end)
    btn.stroke = bs
    table.insert(presetButtons, btn)
end

tween(presetButtons[1].stroke, 0.15, {Thickness = 2})

yCursor = yCursor + 40

createToggle(yCursor, "🌈 Радужная подсветка", Config.Rainbow, function(s)
    Config.Rainbow = s
end)
yCursor = yCursor + 34

createToggle(yCursor, "🛡 Игнорировать сокомандников", Config.TeamCheck, function(s)
    Config.TeamCheck = s
end)
yCursor = yCursor + 40

createSlider(yCursor, "Прозрачность заливки", Config.FillTransparency, 0, 1,
    function(v) return string.format("%.2f", v) end,
    function(v) Config.FillTransparency = v end)
yCursor = yCursor + 46

createSlider(yCursor, "Прозрачность обводки", Config.OutlineTransparency, 0, 1,
    function(v) return string.format("%.2f", v) end,
    function(v) Config.OutlineTransparency = v end)
yCursor = yCursor + 46

createSlider(yCursor, "Макс. дистанция", Config.MaxDistance, 50, 3000,
    function(v) return string.format("%d", math.floor(v)) end,
    function(v) Config.MaxDistance = v end)
yCursor = yCursor + 46

new("TextLabel", {
    BackgroundTransparency = 1,
    Position = UDim2.new(0, 16, 0, yCursor),
    Size = UDim2.new(1, -32, 0, 30),
    Font = Enum.Font.Gotham,
    Text = "Хоткеи:\nL — показать/скрыть меню   •   RShift — вкл/выкл подсветку",
    TextSize = 10,
    TextColor3 = Color3.fromRGB(120, 120, 145),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    Parent = content,
})

-- ============================================================
-- РАСКРЫТИЕ / СКРЫТИЕ
-- ============================================================
local expanded = true -- открыто по умолчанию

local function setExpanded(state)
    expanded = state
    tween(main, 0.35, {
        Size = state and EXPANDED_SIZE or COLLAPSED_SIZE,
    }, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
    tween(arrow, 0.3, { Rotation = state and 180 or 0 })
end

-- Клик по стрелке (mouse down работает надёжнее чем Click, если рядом drag)
arrow.MouseButton1Click:Connect(function()
    setExpanded(not expanded)
end)

-- ============================================================
-- ПЕРЕТАСКИВАНИЕ ЗА ХЕДЕР (dragHandle)
-- ============================================================
do
    local dragging, dragStart, startPos

    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then
            dragging  = true
            dragStart = input.Position
            startPos  = main.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
           or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            main.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
           or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ============================================================
-- ТУМБЛЕР ВКЛ/ВЫКЛ ПОДСВЕТКИ
-- ============================================================
local function setToggleVisual(state)
    tween(toggleBtn, 0.22, {
        BackgroundColor3 = state and Color3.fromRGB(140, 90, 255) or Color3.fromRGB(50, 48, 68),
    })
    tween(toggleKnob, 0.22, {
        Position = state and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
    }, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

toggleBtn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    setToggleVisual(Config.Enabled)
    if not Config.Enabled then
        for _, h in pairs(workspace:GetDescendants()) do
            if h:IsA("Highlight") and h.Name == "abuzlok_hl" then
                h.Enabled = false
            end
        end
    end
end)

-- ============================================================
-- ХОТКЕИ
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    -- RShift — вкл/выкл подсветку
    if input.KeyCode == Config.HighlightKey then
        Config.Enabled = not Config.Enabled
        setToggleVisual(Config.Enabled)

    -- L — показать/скрыть меню
    elseif input.KeyCode == Config.ToggleUIKey then
        gui.Enabled = not gui.Enabled
    end
end)

-- ============================================================
-- ЛОГИКА ПОДСВЕТКИ
-- ============================================================
local highlights = {}

local function getHighlight(player)
    local char = player.Character
    if not char then return nil end
    local h = highlights[player]
    if not h or h.Parent ~= char then
        if h then h:Destroy() end
        h = Instance.new("Highlight")
        h.Name = "abuzlok_hl"
        h.Adornee = char
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        h.Parent = char
        highlights[player] = h
    end
    return h
end

local function updatePlayer(player)
    local h = getHighlight(player)
    if not h then return end

    if not Config.Enabled then h.Enabled = false; return end

    local char = player.Character
    local hrp  = char and char:FindFirstChild("HumanoidRootPart")
    local hum  = char and char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum or hum.Health <= 0 then
        h.Enabled = false
        return
    end

    if Config.TeamCheck and player.Team == LocalPlayer.Team and player ~= LocalPlayer then
        h.Enabled = false
        return
    end

    local camPos = workspace.CurrentCamera.CFrame.Position
    if (camPos - hrp.Position).Magnitude > Config.MaxDistance then
        h.Enabled = false
        return
    end

    h.Enabled = true
    h.FillTransparency    = Config.FillTransparency
    h.OutlineTransparency = Config.OutlineTransparency

    if Config.Rainbow then
        local hue = (tick() * 0.35) % 1
        h.FillColor    = Color3.fromHSV(hue, 1, 1)
        h.OutlineColor = Color3.fromHSV((hue + 0.5) % 1, 1, 1)
    else
        h.FillColor    = Config.FillColor
        h.OutlineColor = Config.OutlineColor
    end
end

local function clearPlayer(player)
    local h = highlights[player]
    if h then h:Destroy() end
    highlights[player] = nil
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(0.25)
        updatePlayer(p)
    end)
    p.CharacterRemoving:Connect(function() clearPlayer(p) end)
end)

Players.PlayerRemoving:Connect(clearPlayer)

for _, p in ipairs(Players:GetPlayers()) do
    if p ~= LocalPlayer then
        p.CharacterAdded:Connect(function() task.wait(0.25); updatePlayer(p) end)
        p.CharacterRemoving:Connect(function() clearPlayer(p) end)
    end
end

-- ============================================================
-- ГЛАВНЫЙ ЦИКЛ АНИМАЦИЙ
-- ============================================================
local startTime = tick()

RunService.RenderStepped:Connect(function()
    local t = tick() - startTime

    strokeGrad.Rotation   = (t * 80) % 360
    titleGrad.Offset      = Vector2.new((math.sin(t * 1.2) + 1) * 0.25, 0)
    glow.ImageTransparency = 0.5 + math.sin(t * 1.5) * 0.12
    glow.Size = UDim2.new(1, 80 + math.sin(t * 1.5) * 8, 1, 80 + math.sin(t * 1.5) * 8)

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            updatePlayer(p)
        end
    end
end)
