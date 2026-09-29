-- ============================================================
-- СКРИПТ: КРАСИВЫЙ ЗАГРУЗОЧНЫЙ ЭКРАН + МЕНЮ ВВОДА КЛЮЧА
-- Вставьте этот код в LocalScript внутри StarterPlayerScripts
-- или в ReplicatedFirst (рекомендуется).
-- ============================================================

-- Подключаем нужные сервисы
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local ContentProvider = game:GetService("ContentProvider")

-- Настройки
local CORRECT_KEY = "Key"           -- Временный ключ
local LOADING_TIME = 3              -- Длительность загрузки (сек)

-- Получаем локального игрока
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ============================================================
-- 1. ЗАГРУЗОЧНЫЙ ЭКРАН
-- ============================================================

-- Создаём ScreenGui для загрузки
local loadingGui = Instance.new("ScreenGui")
loadingGui.Name = "LoadingScreen"
loadingGui.ResetOnSpawn = false
loadingGui.IgnoreGuiInset = true
loadingGui.DisplayOrder = 999
loadingGui.Parent = playerGui

-- Затемнённый фон
local loadingBg = Instance.new("Frame")
loadingBg.Size = UDim2.new(1, 0, 1, 0)
loadingBg.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
loadingBg.BorderSizePixel = 0
loadingBg.ZIndex = 1
loadingBg.Parent = loadingGui

-- Круг для эффекта свечения
local glowCircle = Instance.new("Frame")
glowCircle.Size = UDim2.new(0, 120, 0, 120)
glowCircle.Position = UDim2.new(0.5, -60, 0.5, -60)
glowCircle.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
glowCircle.BackgroundTransparency = 0.6
glowCircle.BorderSizePixel = 0
glowCircle.ZIndex = 2
glowCircle.Parent = loadingBg

local glowCorner = Instance.new("UICorner")
glowCorner.CornerRadius = UDim.new(1, 0)
glowCorner.Parent = glowCircle

-- Текст загрузки
local loadingText = Instance.new("TextLabel")
loadingText.Size = UDim2.new(1, 0, 0, 60)
loadingText.Position = UDim2.new(0, 0, 0.5, 40)
loadingText.BackgroundTransparency = 1
loadingText.Text = "ЗАГРУЗКА..."
loadingText.Font = Enum.Font.GothamBlack
loadingText.TextSize = 28
loadingText.TextColor3 = Color3.fromRGB(255, 255, 255)
loadingText.TextStrokeTransparency = 0.5
loadingText.ZIndex = 3
loadingText.Parent = loadingBg

-- Полоса прогресса (фон)
local progressBarBg = Instance.new("Frame")
progressBarBg.Size = UDim2.new(0, 300, 0, 8)
progressBarBg.Position = UDim2.new(0.5, -150, 0.5, 80)
progressBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
progressBarBg.BorderSizePixel = 0
progressBarBg.ZIndex = 3
progressBarBg.Parent = loadingBg

local progressBarCorner = Instance.new("UICorner")
progressBarCorner.CornerRadius = UDim.new(1, 0)
progressBarCorner.Parent = progressBarBg

-- Полоса прогресса (заполнение)
local progressBarFill = Instance.new("Frame")
progressBarFill.Size = UDim2.new(0, 0, 1, 0)
progressBarFill.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
progressBarFill.BorderSizePixel = 0
progressBarFill.ZIndex = 4
progressBarFill.Parent = progressBarBg

local fillCorner = Instance.new("UICorner")
fillCorner.CornerRadius = UDim.new(1, 0)
fillCorner.Parent = progressBarFill

-- Звук загрузки
local loadingSound = Instance.new("Sound")
loadingSound.SoundId = "rbxassetid://131902697394780"  -- Замените на свой ID
loadingSound.Volume = 0.5
loadingSound.Parent = loadingGui

-- Звук завершения загрузки
local completeSound = Instance.new("Sound")
completeSound.SoundId = "rbxassetid://6042053626"  -- Замените на свой ID
completeSound.Volume = 0.6
completeSound.Parent = loadingGui

-- Проигрываем звук загрузки
loadingSound:Play()

-- Анимируем полосу прогресса
local progressTween = TweenService:Create(
    progressBarFill,
    TweenInfo.new(LOADING_TIME, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
    {Size = UDim2.new(1, 0, 1, 0)}
)
progressTween:Play()

-- Пульсация круга
local pulseTween = TweenService:Create(
    glowCircle,
    TweenInfo.new(0.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
    {Size = UDim2.new(0, 150, 0, 150), Position = UDim2.new(0.5, -75, 0.5, -75)}
)
pulseTween:Play()

-- Ждём завершения загрузки
task.wait(LOADING_TIME)
completeSound:Play()

-- Плавно скрываем загрузочный экран
local fadeOutTween = TweenService:Create(
    loadingBg,
    TweenInfo.new(0.8, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    {BackgroundTransparency = 1}
)

local textFadeTween = TweenService:Create(
    loadingText,
    TweenInfo.new(0.6, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
    {TextTransparency = 1}
)

fadeOutTween:Play()
textFadeTween:Play()

task.wait(0.9)
loadingGui:Destroy()

-- ============================================================
-- 2. МЕНЮ ВВОДА КЛЮЧА
-- ============================================================

-- Создаём ScreenGui для меню
local keyGui = Instance.new("ScreenGui")
keyGui.Name = "KeyMenu"
keyGui.ResetOnSpawn = false
keyGui.IgnoreGuiInset = true
keyGui.DisplayOrder = 1000
keyGui.Parent = playerGui

-- Затемнённый фон
local keyBg = Instance.new("Frame")
keyBg.Size = UDim2.new(1, 0, 1, 0)
keyBg.BackgroundColor3 = Color3.fromRGB(5, 5, 12)
keyBg.BackgroundTransparency = 0.3
keyBg.BorderSizePixel = 0
keyBg.ZIndex = 1
keyBg.Parent = keyGui

-- Основная рамка меню
local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 420, 0, 320)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -160)
mainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
mainFrame.BorderSizePixel = 0
mainFrame.ZIndex = 2
mainFrame.Parent = keyGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 18)
mainCorner.Parent = mainFrame

-- Обводка рамки
local mainStroke = Instance.new("UIStroke")
mainStroke.Color = Color3.fromRGB(80, 140, 255)
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.3
mainStroke.Parent = mainFrame

-- Градиентный фон рамки
local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new{
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 30)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 18))
}
gradient.Rotation = 135
gradient.Parent = mainFrame

-- Заголовок
local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, 0, 0, 50)
titleLabel.Position = UDim2.new(0, 0, 0, 18)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "🔑 СИСТЕМА КЛЮЧА"
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.TextSize = 26
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.ZIndex = 3
titleLabel.Parent = mainFrame

-- Подзаголовок
local subtitleLabel = Instance.new("TextLabel")
subtitleLabel.Size = UDim2.new(1, 0, 0, 24)
subtitleLabel.Position = UDim2.new(0, 0, 0, 62)
subtitleLabel.BackgroundTransparency = 1
subtitleLabel.Text = "Введите ключ для доступа"
subtitleLabel.Font = Enum.Font.Gotham
subtitleLabel.TextSize = 15
subtitleLabel.TextColor3 = Color3.fromRGB(160, 160, 180)
subtitleLabel.ZIndex = 3
subtitleLabel.Parent = mainFrame

-- Поле ввода
local keyInput = Instance.new("TextBox")
keyInput.Size = UDim2.new(0, 320, 0, 48)
keyInput.Position = UDim2.new(0.5, -160, 0, 110)
keyInput.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
keyInput.BorderSizePixel = 0
keyInput.PlaceholderText = "Введите ключ..."
keyInput.Font = Enum.Font.Gotham
keyInput.TextSize = 18
keyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
keyInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 120)
keyInput.ClearTextOnFocus = false
keyInput.ZIndex = 3
keyInput.Parent = mainFrame

local inputCorner = Instance.new("UICorner")
inputCorner.CornerRadius = UDim.new(0, 10)
inputCorner.Parent = keyInput

local inputStroke = Instance.new("UIStroke")
inputStroke.Color = Color3.fromRGB(60, 60, 80)
inputStroke.Thickness = 1
inputStroke.Parent = keyInput

-- Подсветка при фокусе
keyInput.Focused:Connect(function()
    TweenService:Create(inputStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(80, 140, 255)}):Play()
end)

keyInput.FocusLost:Connect(function()
    TweenService:Create(inputStroke, TweenInfo.new(0.2), {Color = Color3.fromRGB(60, 60, 80)}):Play()
end)

-- Кнопка подтверждения
local submitButton = Instance.new("TextButton")
submitButton.Size = UDim2.new(0, 200, 0, 46)
submitButton.Position = UDim2.new(0.5, -100, 0, 180)
submitButton.BackgroundColor3 = Color3.fromRGB(80, 140, 255)
submitButton.BorderSizePixel = 0
submitButton.Text = "ПОДТВЕРДИТЬ"
submitButton.Font = Enum.Font.GothamBold
submitButton.TextSize = 18
submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
submitButton.ZIndex = 3
submitButton.Parent = mainFrame

local submitCorner = Instance.new("UICorner")
submitCorner.CornerRadius = UDim.new(0, 10)
submitCorner.Parent = submitButton

-- Анимация кнопки при наведении
submitButton.MouseEnter:Connect(function()
    TweenService:Create(submitButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(100, 160, 255),
        Size = UDim2.new(0, 210, 0, 48)
    }):Play()
end)

submitButton.MouseLeave:Connect(function()
    TweenService:Create(submitButton, TweenInfo.new(0.2), {
        BackgroundColor3 = Color3.fromRGB(80, 140, 255),
        Size = UDim2.new(0, 200, 0, 46)
    }):Play()
end)

-- Текст ошибки / успеха
local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0, 24)
statusLabel.Position = UDim2.new(0, 0, 0, 238)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = ""
statusLabel.Font = Enum.Font.GothamBold
statusLabel.TextSize = 15
statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
statusLabel.ZIndex = 3
statusLabel.Parent = mainFrame

-- Звуки для меню
local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxassetid://6042053626"  -- Замените на свой ID
clickSound.Volume = 0.5
clickSound.Parent = keyGui

local successSound = Instance.new("Sound")
successSound.SoundId = "rbxassetid://6042053626"  -- Замените на свой ID (можно другой)
successSound.Volume = 0.6
successSound.Parent = keyGui

local errorSound = Instance.new("Sound")
errorSound.SoundId = "rbxassetid://6042053626"  -- Замените на свой ID (звук ошибки)
errorSound.Volume = 0.5
errorSound.Parent = keyGui

-- Анимация появления меню
mainFrame.Size = UDim2.new(0, 0, 0, 0)
mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)

TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size = UDim2.new(0, 420, 0, 320),
    Position = UDim2.new(0.5, -210, 0.5, -160)
}):Play()

-- Функция проверки ключа
local function checkKey()
    clickSound:Play()
    
    if keyInput.Text == CORRECT_KEY then
        statusLabel.Text = "✅ Ключ верный! Загрузка..."
        statusLabel.TextColor3 = Color3.fromRGB(80, 255, 120)
        successSound:Play()
        
        -- Анимация успеха
        TweenService:Create(mainFrame, TweenInfo.new(0.3), {
            BackgroundColor3 = Color3.fromRGB(20, 40, 25)
        }):Play()
        
        task.wait(0.8)
        
        -- Плавно скрываем меню
        local hideTween = TweenService:Create(keyBg, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
            BackgroundTransparency = 1
        })
        hideTween:Play()
        
        TweenService:Create(mainFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quart), {
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        }):Play()
        
        task.wait(0.6)
        keyGui:Destroy()
        
        -- Здесь можно запустить основной скрипт
        -- Например: loadstring(...)() или require(...)
        print("✅ Ключ принят! Запуск основного скрипта...")
        
    else
        statusLabel.Text = "❌ Неверный ключ! Попробуйте снова."
        statusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        errorSound:Play()
        keyInput.Text = ""
        
        -- Анимация ошибки (тряска)
        local originalPos = mainFrame.Position
        for i = 1, 3 do
            TweenService:Create(mainFrame, TweenInfo.new(0.05), {
                Position = originalPos + UDim2.new(0, 10, 0, 0)
            }):Play()
            task.wait(0.05)
            TweenService:Create(mainFrame, TweenInfo.new(0.05), {
                Position = originalPos - UDim2.new(0, 10, 0, 0)
            }):Play()
            task.wait(0.05)
        end
        TweenService:Create(mainFrame, TweenInfo.new(0.05), {
            Position = originalPos
        }):Play()
    end
end

-- Привязываем кнопку и клавишу Enter
submitButton.MouseButton1Click:Connect(checkKey)
keyInput.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        checkKey()
    end
end)

-- ============================================================
-- КОНЕЦ СКРИПТА
-- ============================================================
