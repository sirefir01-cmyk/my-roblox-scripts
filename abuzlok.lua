--// ============================================================
--//  ✨ abuzlok VD — Liquid Glass Edition
--//  LocalScript в StarterPlayerScripts
--// ============================================================

local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local Lighting         = game:GetService("Lighting")
local CoreGui          = game:GetService("CoreGui")
local SoundService     = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui") or LocalPlayer:WaitForChild("PlayerGui", 5)
if not PlayerGui then return end

--// Config
local Config = {
    Enabled=true,
    ShowHighlight=true, ShowNames=true, ShowDistance=true, ShowArrows=true,
    ShowHealthBars=true, TeamCheck=false, MaxDistance=1000,
    HighlightColor=Color3.fromRGB(200,200,210),
    FlyEnabled=false, FlySpeed=100, NoClip=false,
    Crosshair=true, CrosshairColor=Color3.fromRGB(255,255,255),
    FOVEnabled=false, FOV=70, FPSUnlock=false,
    HideUI=false, Watermark=true,
    EnvEnabled=false,
    Ambient=Color3.fromRGB(70,70,70),
    OutdoorAmbient=Color3.fromRGB(128,128,128),
    Brightness=2, Exposure=0,
    Fullbright=false,
    Bloom=false, SunRays=false, ColorCorr=false, DoF=false,
    AntiAFK=true,
    AutoMoonwalk=false,
    MoonwalkSpeed=0.02,
    MoonwalkHold=0.02,
    MoonwalkWadMode=false,
    MoonwalkDebug=false,
    Keybinds={Fly=Enum.KeyCode.F, NoClip=Enum.KeyCode.N, ToggleMenu=Enum.KeyCode.L, HideUI=Enum.KeyCode.RightBracket, Moonwalk=Enum.KeyCode.M},
    DefaultBinds={Fly=Enum.KeyCode.F, NoClip=Enum.KeyCode.N, ToggleMenu=Enum.KeyCode.L, HideUI=Enum.KeyCode.RightBracket, Moonwalk=Enum.KeyCode.M},
}
local OriginalLighting = {
    Ambient=Lighting.Ambient, OutdoorAmbient=Lighting.OutdoorAmbient,
    Brightness=Lighting.Brightness, Exposure=Lighting.ExposureCompensation,
    FOV=workspace.CurrentCamera and workspace.CurrentCamera.FieldOfView or 70,
}
local OriginalFPS = 60

local ESPData, SwitchRefs = {}, {}
local LazyPages = {}

--// ЧЁРНО-БЕЛАЯ ПАЛИТРА
local COL = {
    bgGlass      = Color3.fromRGB(12, 12, 16),
    bgHeader     = Color3.fromRGB(20, 20, 26),
    bgRow        = Color3.fromRGB(28, 28, 35),
    bgRowHover   = Color3.fromRGB(55, 55, 65),
    accent       = Color3.fromRGB(255, 255, 255),
    accentSoft   = Color3.fromRGB(200, 200, 215),
    text         = Color3.fromRGB(245, 245, 250),
    subtext      = Color3.fromRGB(140, 140, 155),
    on           = Color3.fromRGB(240, 240, 245),
    off          = Color3.fromRGB(45, 45, 55),
    track        = Color3.fromRGB(35, 35, 45),
    border       = Color3.fromRGB(255, 255, 255),
    input        = Color3.fromRGB(22, 22, 28),
    glass        = Color3.fromRGB(255, 255, 255),
}

local function tween(o,t,p,st,d) local i=TweenInfo.new(t or .2,st or Enum.EasingStyle.Quad,d or Enum.EasingDirection.Out);local tw=TweenService:Create(o,i,p);tw:Play();return tw end
local function corner(p,r) local c=Instance.new("UICorner",p);c.CornerRadius=UDim.new(0,r or 8);return c end
local function safe(f,...) local ok,err=pcall(f,...); if not ok then warn("[abuzlok VD]",err) end end

--// Sound
local SoundPlayer = Instance.new("Sound")
SoundPlayer.SoundId = "rbxasset://sounds/electronicpingshort.wav"
SoundPlayer.Volume = 0.25
SoundPlayer.Parent = SoundService
local function playSound(pitch)
    pcall(function()
        SoundPlayer.PlaybackSpeed = pitch or 1
        SoundPlayer.TimePosition = 0
        SoundPlayer:Play()
    end)
end

--// Fly
local flyBV, flyBG
local function StartFly()
    local char=LocalPlayer.Character; if not char then return end
    local hrp=char:FindFirstChild("HumanoidRootPart"); local hum=char:FindFirstChildOfClass("Humanoid")
    if not hrp or not hum then return end
    hum.PlatformStand=true
    if flyBV then flyBV:Destroy() end; if flyBG then flyBG:Destroy() end
    flyBV=Instance.new("BodyVelocity"); flyBV.MaxForce=Vector3.new(1e5,1e5,1e5)
    flyBV.Velocity=Vector3.zero; flyBV.Parent=hrp
    flyBG=Instance.new("BodyGyro"); flyBG.MaxTorque=Vector3.new(1e5,1e5,1e5)
    flyBG.P=2000; flyBG.D=100; flyBG.CFrame=hrp.CFrame; flyBG.Parent=hrp
end
local function StopFly()
    local char=LocalPlayer.Character
    if char then
        local hrp=char:FindFirstChild("HumanoidRootPart"); local hum=char:FindFirstChildOfClass("Humanoid")
        if hrp then
            if hrp:FindFirstChild("BodyVelocity") then hrp.BodyVelocity:Destroy() end
            if hrp:FindFirstChild("BodyGyro") then hrp.BodyGyro:Destroy() end
        end
        if hum then hum.PlatformStand=false end
    end
    flyBV, flyBG=nil,nil
end

--// Moonwalk
local moonwalkActive = false
local moonwalkThread = nil
local moonwalkCounter = 0

local VIM
pcall(function() VIM = game:GetService("VirtualInputManager") end)

local function pressKey(keyCode, keyName)
    if VIM then
        local ok = pcall(function() VIM:SendKeyEvent(true, keyCode, false, game) end)
        if ok then return true end
    end
    if keypress then
        pcall(function() keypress(keyName) end)
    end
    return false
end
local function releaseKey(keyCode, keyName)
    if VIM then
        local ok = pcall(function() VIM:SendKeyEvent(false, keyCode, false, game) end)
        if ok then return true end
    end
    if keyrelease then
        pcall(function() keyrelease(keyName) end)
    end
    return false
end
local function tapKey(keyCode, keyName, holdTime)
    pressKey(keyCode, keyName)
    task.wait(holdTime or 0.015)
    releaseKey(keyCode, keyName)
end

local function startMoonwalk()
    if moonwalkThread then return end
    moonwalkActive = true
    moonwalkCounter = 0
    moonwalkThread = task.spawn(function()
        local tick_a = false
        while moonwalkActive do
            if Config.AutoMoonwalk and UserInputService:IsKeyDown(Enum.KeyCode.W) then
                if Config.MoonwalkWadMode then
                    tapKey(Enum.KeyCode.W, "w", Config.MoonwalkHold); task.wait(Config.MoonwalkSpeed)
                    tapKey(Enum.KeyCode.A, "a", Config.MoonwalkHold); task.wait(Config.MoonwalkSpeed)
                    tapKey(Enum.KeyCode.D, "d", Config.MoonwalkHold); task.wait(Config.MoonwalkSpeed)
                else
                    tick_a = not tick_a
                    if tick_a then tapKey(Enum.KeyCode.A, "a", Config.MoonwalkHold)
                    else tapKey(Enum.KeyCode.D, "d", Config.MoonwalkHold) end
                    task.wait(math.max(0, Config.MoonwalkSpeed - Config.MoonwalkHold))
                end
                moonwalkCounter = moonwalkCounter + 1
            else
                task.wait(0.02)
            end
        end
    end)
end
local function stopMoonwalk()
    moonwalkActive = false
    if moonwalkThread then pcall(function() task.cancel(moonwalkThread) end); moonwalkThread = nil end
    pcall(function() releaseKey(Enum.KeyCode.W, "w") end)
    pcall(function() releaseKey(Enum.KeyCode.A, "a") end)
    pcall(function() releaseKey(Enum.KeyCode.D, "d") end)
end

--// Anti-AFK
local VirtualUser
pcall(function() VirtualUser = game:GetService("VirtualUser") end)
if VirtualUser then
    LocalPlayer.Idled:Connect(function()
        if not Config.AntiAFK then return end
        pcall(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end)
end

--// Effects
local Effects = {}
local function setEffect(name, class, enabled, props)
    if enabled then
        if not Effects[name] or not Effects[name].Parent then
            local ex = Lighting:FindFirstChild(name)
            if ex then ex:Destroy() end
            ex = Instance.new(class); ex.Name = name; ex.Parent = Lighting
            Effects[name] = ex
        end
        for k,v in pairs(props or {}) do Effects[name][k] = v end
        Effects[name].Enabled = true
    else
        if Effects[name] then Effects[name].Enabled = false end
    end
end
local function UpdateEffects()
    local on = Config.EnvEnabled
    setEffect("ABZ_Bloom", "BloomEffect", Config.Bloom and on, {Intensity=0.7, Size=24, Threshold=0.95})
    setEffect("ABZ_SunRays", "SunRaysEffect", Config.SunRays and on, {Intensity=0.15, Spread=0.8})
    setEffect("ABZ_CC", "ColorCorrectionEffect", Config.ColorCorr and on, {Saturation=-0.2, Contrast=0.1})
    setEffect("ABZ_DoF", "DepthOfFieldEffect", Config.DoF and on, {FarIntensity=0.15, FocusDistance=20, InFocusRadius=40})
end

local LightingTween
local function tweenLighting(prop, target, time)
    if LightingTween then pcall(function() LightingTween:Cancel() end) end
    LightingTween = TweenService:Create(Lighting,
        TweenInfo.new(time or 1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        {[prop] = target})
    LightingTween:Play()
end
local function ApplyLighting()
    UpdateEffects()
    safe(function() tweenLighting("Ambient", Config.Ambient, 1.5) end)
    safe(function() tweenLighting("OutdoorAmbient", Config.OutdoorAmbient, 1.5) end)
    safe(function() tweenLighting("Brightness", math.clamp(Config.Brightness, 0.5, 4), 1) end)
    safe(function() tweenLighting("ExposureCompensation", math.clamp(Config.Exposure, -1, 1), 1) end)
    if Config.Fullbright then
        safe(function()
            tweenLighting("Brightness", 3, 1)
            tweenLighting("Ambient", Color3.fromRGB(200,200,200), 1)
        end)
    end
end
local function ResetLighting()
    if LightingTween then pcall(function() LightingTween:Cancel() end); LightingTween=nil end
    safe(function()
        Lighting.Ambient = OriginalLighting.Ambient
        Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
        Lighting.Brightness = OriginalLighting.Brightness
        Lighting.ExposureCompensation = OriginalLighting.Exposure
    end)
    for _, e in pairs(Effects) do if e then e:Destroy() end end
    Effects = {}
end

--// GUI parent
local function getGuiParent()
    local ok, cg = pcall(function() return CoreGui end)
    if ok and cg then
        local canWrite = pcall(function()
            local t = Instance.new("Folder"); t.Name="__abz__"; t.Parent=cg; t:Destroy()
        end)
        if canWrite then return cg end
    end
    return PlayerGui
end
do
    local o1 = PlayerGui:FindFirstChild("AbuzlokVD"); if o1 then o1:Destroy() end
    pcall(function() local o2 = CoreGui:FindFirstChild("AbuzlokVD"); if o2 then o2:Destroy() end end)
end

--// Root GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name="AbuzlokVD"; ScreenGui.ResetOnSpawn=false
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset=true; ScreenGui.DisplayOrder=999999
ScreenGui.Parent = getGuiParent()

-- Watermark
local Watermark = Instance.new("Frame")
Watermark.Size=UDim2.new(0,230,0,26); Watermark.Position=UDim2.new(0,10,0,10)
Watermark.BackgroundColor3=COL.bgGlass; Watermark.BackgroundTransparency=0.4
Watermark.BorderSizePixel=0; Watermark.Parent=ScreenGui; corner(Watermark,8)
local wmStroke=Instance.new("UIStroke",Watermark); wmStroke.Color=Color3.fromRGB(255,255,255); wmStroke.Thickness=1; wmStroke.Transparency=0.6
local wmLabel=Instance.new("TextLabel")
wmLabel.Size=UDim2.new(1,0,1,0); wmLabel.BackgroundTransparency=1
wmLabel.Text="◈ abuzlok VD  ·  "..LocalPlayer.Name
wmLabel.TextColor3=COL.text; wmLabel.Font=Enum.Font.GothamBold
wmLabel.TextSize=11; wmLabel.Parent=Watermark

-- Moonwalk indicator
local MoonIndicator = Instance.new("Frame")
MoonIndicator.Size=UDim2.new(0,170,0,22); MoonIndicator.Position=UDim2.new(0,10,0,40)
MoonIndicator.BackgroundColor3=COL.bgGlass; MoonIndicator.BackgroundTransparency=0.35
MoonIndicator.BorderSizePixel=0; MoonIndicator.Visible=false; MoonIndicator.Parent=ScreenGui
corner(MoonIndicator,6)
local miStroke=Instance.new("UIStroke",MoonIndicator); miStroke.Color=Color3.fromRGB(255,255,255); miStroke.Thickness=1; miStroke.Transparency=0.4
local miLabel=Instance.new("TextLabel")
miLabel.Size=UDim2.new(1,0,1,0); miLabel.BackgroundTransparency=1
miLabel.Text="◐ MOONWALK  ·  ACTIVE"
miLabel.TextColor3=Color3.fromRGB(240,240,245); miLabel.Font=Enum.Font.GothamBold
miLabel.TextSize=10; miLabel.Parent=MoonIndicator

-- Crosshair
local Crosshair = Instance.new("Frame")
Crosshair.Size=UDim2.new(0,20,0,20); Crosshair.Position=UDim2.new(0.5,-10,0.5,-10)
Crosshair.BackgroundTransparency=1; Crosshair.Parent=ScreenGui
local chH = Instance.new("Frame")
chH.Size=UDim2.new(1,0,0,1); chH.Position=UDim2.new(0,0,0.5,0)
chH.BackgroundColor3=Config.CrosshairColor; chH.BorderSizePixel=0; chH.Parent=Crosshair
local chV = Instance.new("Frame")
chV.Size=UDim2.new(0,1,1,0); chV.Position=UDim2.new(0.5,0,0,0)
chV.BackgroundColor3=Config.CrosshairColor; chV.BorderSizePixel=0; chV.Parent=Crosshair
local chDot = Instance.new("Frame")
chDot.Size=UDim2.new(0,2,0,2); chDot.Position=UDim2.new(0.5,-1,0.5,-1)
chDot.BackgroundColor3=Config.CrosshairColor; chDot.BorderSizePixel=0; chDot.Parent=Crosshair

-- Toggle button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size=UDim2.new(0,150,0,38); ToggleBtn.Position=UDim2.new(0.5,-75,0,14)
ToggleBtn.BackgroundColor3=COL.bgGlass; ToggleBtn.BackgroundTransparency=0.3
ToggleBtn.Text="◈  abuzlok VD  [L]"
ToggleBtn.TextColor3=COL.text; ToggleBtn.Font=Enum.Font.GothamBold
ToggleBtn.TextSize=12; ToggleBtn.AutoButtonColor=false; ToggleBtn.Parent=ScreenGui; corner(ToggleBtn,12)
local tbStroke=Instance.new("UIStroke",ToggleBtn); tbStroke.Color=Color3.fromRGB(255,255,255); tbStroke.Thickness=1; tbStroke.Transparency=0.5

-- pulse stroke
task.spawn(function()
    while ToggleBtn.Parent do
        tween(tbStroke, 2, {Transparency = 0.85}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut); task.wait(2)
        tween(tbStroke, 2, {Transparency = 0.5}, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut); task.wait(2)
    end
end)

-- Menu
local Menu = Instance.new("Frame")
Menu.Size=UDim2.new(0,340,0,500); Menu.Position=UDim2.new(0.5,-170,0,62)
Menu.BackgroundColor3=COL.bgGlass; Menu.BackgroundTransparency=0.15
Menu.BorderSizePixel=0; Menu.ClipsDescendants=true
Menu.Visible=false; Menu.Parent=ScreenGui; corner(Menu,18)
local menuStroke=Instance.new("UIStroke",Menu); menuStroke.Color=Color3.fromRGB(255,255,255); menuStroke.Thickness=1.2; menuStroke.Transparency=0.55

-- Menu shadow (эффект глубины стекла)
local MenuShadow = Instance.new("Frame")
MenuShadow.Size=UDim2.new(1,20,1,20); MenuShadow.Position=UDim2.new(0,-10,0,8)
MenuShadow.BackgroundColor3=Color3.fromRGB(0,0,0); MenuShadow.BackgroundTransparency=0.65
MenuShadow.BorderSizePixel=0; MenuShadow.ZIndex=0; MenuShadow.Parent=ScreenGui
corner(MenuShadow,20)
MenuShadow.Visible = false

-- Glass shine (внутренний блик)
local GlassShine = Instance.new("Frame")
GlassShine.Size=UDim2.new(1,0,0.5,0); GlassShine.Position=UDim2.new(0,0,0,0)
GlassShine.BackgroundColor3=Color3.fromRGB(255,255,255); GlassShine.BackgroundTransparency=0.92
GlassShine.BorderSizePixel=0; GlassShine.ZIndex=1; GlassShine.Parent=Menu
corner(GlassShine,18)
local gsGrad=Instance.new("UIGradient", GlassShine)
gsGrad.Rotation = 90
gsGrad.Transparency = NumberSequence.new{
    NumberSequenceKeypoint.new(0, 0.85),
    NumberSequenceKeypoint.new(1, 1),
}
gsGrad.Color = ColorSequence.new(Color3.fromRGB(255,255,255))

-- SPOTLIGHT за мышью
local Spotlight = Instance.new("Frame")
Spotlight.Name="Spotlight"
Spotlight.Size=UDim2.fromOffset(340,340)
Spotlight.AnchorPoint=Vector2.new(0.5,0.5)
Spotlight.Position=UDim2.new(0.5,0,0.5,0)
Spotlight.BackgroundTransparency=1
Spotlight.ZIndex=1; Spotlight.Parent=Menu

for i = 1, 10 do
    local layer = Instance.new("Frame")
    local size = 340 * (1 - i * 0.08)
    layer.Size = UDim2.fromOffset(size, size)
    layer.AnchorPoint = Vector2.new(0.5, 0.5)
    layer.Position = UDim2.new(0.5, 0, 0.5, 0)
    layer.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    layer.BackgroundTransparency = 0.82 + (i * 0.016)
    layer.BorderSizePixel = 0
    layer.ZIndex = 1
    layer.Parent = Spotlight
    Instance.new("UICorner", layer).CornerRadius = UDim.new(1, 0)
end

-- Header
local Header=Instance.new("Frame")
Header.Size=UDim2.new(1,0,0,46); Header.BackgroundColor3=COL.bgHeader; Header.BackgroundTransparency=0.3
Header.BorderSizePixel=0; Header.ZIndex=2; Header.Parent=Menu; corner(Header,18)

-- Hide bottom corners of header
local hCover=Instance.new("Frame")
hCover.Size=UDim2.new(1,0,0.5,0); hCover.Position=UDim2.new(0,0,0.5,0)
hCover.BackgroundColor3=COL.bgHeader; hCover.BackgroundTransparency=0.3
hCover.BorderSizePixel=0; hCover.ZIndex=3; hCover.Parent=Header

local Title=Instance.new("TextLabel")
Title.Size=UDim2.new(1,-50,1,0); Title.Position=UDim2.new(0,18,0,0); Title.BackgroundTransparency=1
Title.Text="◈   abuzlok VD"; Title.TextColor3=COL.text
Title.Font=Enum.Font.GothamBold; Title.TextSize=15; Title.TextXAlignment=Enum.TextXAlignment.Left
Title.ZIndex=4; Title.Parent=Header

local CloseBtn=Instance.new("TextButton")
CloseBtn.Size=UDim2.new(0,26,0,26); CloseBtn.Position=UDim2.new(1,-36,0.5,-13)
CloseBtn.BackgroundColor3=Color3.fromRGB(60,60,70); CloseBtn.BackgroundTransparency=0.3
CloseBtn.Text="×"; CloseBtn.TextColor3=COL.text; CloseBtn.Font=Enum.Font.GothamBold
CloseBtn.TextSize=16; CloseBtn.AutoButtonColor=false; CloseBtn.ZIndex=4; CloseBtn.Parent=Header; corner(CloseBtn,13)
local cbStroke=Instance.new("UIStroke", CloseBtn); cbStroke.Color=Color3.fromRGB(255,255,255); cbStroke.Thickness=1; cbStroke.Transparency=0.6
CloseBtn.MouseEnter:Connect(function() tween(CloseBtn, 0.15, {BackgroundTransparency = 0, BackgroundColor3 = Color3.fromRGB(255,255,255)}); tween(CloseBtn, 0.15, {TextColor3 = Color3.fromRGB(20,20,25)}) end)
CloseBtn.MouseLeave:Connect(function() tween(CloseBtn, 0.15, {BackgroundTransparency = 0.3, BackgroundColor3 = Color3.fromRGB(60,60,70)}); tween(CloseBtn, 0.15, {TextColor3 = COL.text}) end)

-- Tabs
local TabBar=Instance.new("Frame")
TabBar.Size=UDim2.new(1,-20,0,36); TabBar.Position=UDim2.new(0,10,0,54)
TabBar.BackgroundColor3=Color3.fromRGB(20,20,26); TabBar.BackgroundTransparency=0.4
TabBar.BorderSizePixel=0; TabBar.ZIndex=2; TabBar.Parent=Menu; corner(TabBar,10)
local tBarStroke=Instance.new("UIStroke", TabBar); tBarStroke.Color=Color3.fromRGB(255,255,255); tBarStroke.Thickness=1; tBarStroke.Transparency=0.75

local tabIndicator=Instance.new("Frame")
tabIndicator.Size=UDim2.new(0.166,-6,1,-6); tabIndicator.Position=UDim2.new(0,3,0,3)
tabIndicator.BackgroundColor3=Color3.fromRGB(255,255,255); tabIndicator.BackgroundTransparency=0.1
tabIndicator.BorderSizePixel=0; tabIndicator.ZIndex=2; tabIndicator.Parent=TabBar
corner(tabIndicator,8)

local tabNames={"ESP","MOVE","MOON","VISUAL","WORLD","BINDS"}
local tabButtons={}
for i,name in ipairs(tabNames) do
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(0.166,0,1,0); b.Position=UDim2.new(0.166*(i-1),0,0,0)
    b.BackgroundTransparency=1; b.Text=name
    b.TextColor3=(i==1) and Color3.fromRGB(20,20,25) or COL.subtext
    b.Font=Enum.Font.GothamBold; b.TextSize=9; b.ZIndex=3; b.AutoButtonColor=false; b.Parent=TabBar
    tabButtons[i]=b
end

-- Content
local Content=Instance.new("Frame")
Content.Size=UDim2.new(1,-20,1,-104); Content.Position=UDim2.new(0,10,0,100)
Content.BackgroundTransparency=1; Content.ClipsDescendants=true; Content.ZIndex=2; Content.Parent=Menu

local MainScroll = Instance.new("ScrollingFrame")
MainScroll.Size=UDim2.new(1,0,1,0); MainScroll.BackgroundTransparency=1; MainScroll.BorderSizePixel=0
MainScroll.ScrollBarThickness=3; MainScroll.ScrollBarImageColor3=Color3.fromRGB(255,255,255)
MainScroll.ScrollBarImageTransparency=0.5
MainScroll.CanvasSize=UDim2.new(0,0,0,0); MainScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
MainScroll.ZIndex=2; MainScroll.Parent=Content

local PageHolder = Instance.new("Frame")
PageHolder.Size=UDim2.new(1,0,0,0); PageHolder.BackgroundTransparency=1
PageHolder.AutomaticSize = Enum.AutomaticSize.Y; PageHolder.ZIndex=2
PageHolder.Parent = MainScroll

-- Components
local componentY = 4
local function resetY() componentY = 4 end
local function nextY(o) componentY = componentY + (o or 0); return componentY end
local function currentY() return componentY end

local function makeSection(text)
    local y=currentY()
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(1,-16,0,18); l.Position=UDim2.new(0,8,0,y)
    l.BackgroundTransparency=1; l.Text=string.upper(text); l.TextColor3=COL.subtext
    l.Font=Enum.Font.GothamBold; l.TextSize=9; l.TextXAlignment=Enum.TextXAlignment.Left
    l.ZIndex=2; l.Parent=PageHolder; nextY(22)
end

local function addHover(row, isRow)
    local origTrans = row.BackgroundTransparency
    local origColor = row.BackgroundColor3
    row.MouseEnter:Connect(function()
        tween(row, 0.2, {
            BackgroundTransparency = math.max(0, origTrans - 0.45),
            BackgroundColor3 = COL.bgRowHover,
        })
    end)
    row.MouseLeave:Connect(function()
        tween(row, 0.25, {
            BackgroundTransparency = origTrans,
            BackgroundColor3 = origColor,
        })
    end)
end

local function makeSwitch(text,key,onChange)
    local y=currentY()
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,-16,0,36); row.Position=UDim2.new(0,8,0,y)
    row.BackgroundColor3=COL.bgRow; row.BackgroundTransparency=0.55; row.BorderSizePixel=0
    row.ZIndex=2; row.Parent=PageHolder; corner(row,10)
    local rStroke=Instance.new("UIStroke", row); rStroke.Color=Color3.fromRGB(255,255,255); rStroke.Thickness=1; rStroke.Transparency=0.85

    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-60,1,0); lbl.Position=UDim2.new(0,14,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=text; lbl.TextColor3=COL.text
    lbl.Font=Enum.Font.Gotham; lbl.TextSize=13; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=3; lbl.Parent=row

    local sw=Instance.new("TextButton")
    sw.Size=UDim2.new(0,44,0,22); sw.Position=UDim2.new(1,-56,.5,-11)
    sw.BackgroundColor3=Config[key] and COL.on or COL.off
    sw.BackgroundTransparency=0.1
    sw.Text=""; sw.AutoButtonColor=false; sw.ZIndex=3; sw.Parent=row; corner(sw,11)
    local swStroke=Instance.new("UIStroke", sw); swStroke.Color=Color3.fromRGB(255,255,255); swStroke.Thickness=1; swStroke.Transparency=0.6

    local knob=Instance.new("Frame")
    knob.Size=UDim2.new(0,18,0,18)
    knob.Position=Config[key] and UDim2.new(1,-20,.5,-9) or UDim2.new(0,2,.5,-9)
    knob.BackgroundColor3=Config[key] and Color3.fromRGB(20,20,25) or Color3.fromRGB(255,255,255)
    knob.BorderSizePixel=0; knob.ZIndex=4; knob.Parent=sw; corner(knob,9)

    local function apply(on,anim)
        local p=on and UDim2.new(1,-20,.5,-9) or UDim2.new(0,2,.5,-9)
        local swc=on and COL.on or COL.off
        local knc=on and Color3.fromRGB(20,20,25) or Color3.fromRGB(255,255,255)
        if anim then
            tween(knob,.3,{Position=p},Enum.EasingStyle.Back,Enum.EasingDirection.Out)
            tween(sw,.25,{BackgroundColor3=swc})
            tween(knob,.25,{BackgroundColor3=knc})
        else
            knob.Position=p; sw.BackgroundColor3=swc; knob.BackgroundColor3=knc
        end
    end

    addHover(row)

    sw.MouseButton1Click:Connect(function()
        Config[key]=not Config[key]; apply(Config[key],true); playSound(Config[key] and 1.3 or 0.9)
        if onChange then safe(onChange, Config[key]) end
    end)
    SwitchRefs[key]={apply=apply}
    nextY(38)
end

local function makeSlider(text,min,max,value,onChange,isFloat)
    local y=currentY()
    local h=Instance.new("Frame")
    h.Size=UDim2.new(1,-16,0,46); h.Position=UDim2.new(0,8,0,y)
    h.BackgroundColor3=COL.bgRow; h.BackgroundTransparency=0.55; h.BorderSizePixel=0
    h.ZIndex=2; h.Parent=PageHolder; corner(h,10)
    local hStroke=Instance.new("UIStroke", h); hStroke.Color=Color3.fromRGB(255,255,255); hStroke.Thickness=1; hStroke.Transparency=0.85

    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-80,0,16); lbl.Position=UDim2.new(0,14,0,6)
    lbl.BackgroundTransparency=1; lbl.Text=text; lbl.TextColor3=COL.text
    lbl.Font=Enum.Font.Gotham; lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=3; lbl.Parent=h

    local vl=Instance.new("TextLabel")
    vl.Size=UDim2.new(0,70,0,16); vl.Position=UDim2.new(1,-80,0,6)
    vl.BackgroundTransparency=1; vl.Text=isFloat and string.format("%.3f",value) or tostring(value)
    vl.TextColor3=Color3.fromRGB(255,255,255); vl.Font=Enum.Font.GothamBold; vl.TextSize=12
    vl.TextXAlignment=Enum.TextXAlignment.Right; vl.ZIndex=3; vl.Parent=h

    local track=Instance.new("Frame")
    track.Size=UDim2.new(1,-28,0,4); track.Position=UDim2.new(0,14,0,32)
    track.BackgroundColor3=COL.track; track.BackgroundTransparency=0.2; track.BorderSizePixel=0
    track.ZIndex=3; track.Parent=h; corner(track,2)

    local fill=Instance.new("Frame")
    fill.Size=UDim2.new(0,0,1,0); fill.BackgroundColor3=Color3.fromRGB(255,255,255)
    fill.BorderSizePixel=0; fill.ZIndex=4; fill.Parent=track; corner(fill,2)

    local knob=Instance.new("Frame")
    knob.Size=UDim2.new(0,12,0,12); knob.AnchorPoint=Vector2.new(.5,.5); knob.Position=UDim2.new(0,0,.5,0)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.BorderSizePixel=0; knob.ZIndex=5; knob.Parent=track
    corner(knob,6)

    local function setV(v)
        v=math.clamp(v,min,max); value=v
        local p=(v-min)/(max-min); fill.Size=UDim2.new(p,0,1,0); knob.Position=UDim2.new(p,0,.5,0)
        vl.Text=isFloat and string.format("%.3f",v) or tostring(v)
        if onChange then safe(onChange, v) end
    end
    local drag=false
    local function upd(x)
        local p=math.clamp((x-track.AbsolutePosition.X)/track.AbsoluteSize.X,0,1)
        local raw=min+(max-min)*p; setV(isFloat and raw or math.floor(raw+.5))
    end
    track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=true; upd(i.Position.X)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then upd(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)
    setV(value); nextY(50)
end

local function makeColorPicker(colors,initial,onChange)
    local y=currentY()
    local h=Instance.new("Frame")
    h.Size=UDim2.new(1,-16,0,46); h.Position=UDim2.new(0,8,0,y)
    h.BackgroundColor3=COL.bgRow; h.BackgroundTransparency=0.55; h.BorderSizePixel=0
    h.ZIndex=2; h.Parent=PageHolder; corner(h,10)
    local hStroke=Instance.new("UIStroke", h); hStroke.Color=Color3.fromRGB(255,255,255); hStroke.Thickness=1; hStroke.Transparency=0.85

    local size,gap=22,5
    local totalW = #colors*size + (#colors-1)*gap
    local startX = (h.AbsoluteSize.X - totalW)/2
    for i,c in ipairs(colors) do
        local b=Instance.new("TextButton")
        b.Size=UDim2.new(0,size,0,size)
        b.Position=UDim2.new(0.5, -totalW/2 + (i-1)*(size+gap), 0.5, -size/2)
        b.BackgroundColor3=c; b.Text=""; b.AutoButtonColor=false; b.ZIndex=3; b.Parent=h
        corner(b,size/2)
        local st=Instance.new("UIStroke",b); st.Color=Color3.fromRGB(255,255,255)
        st.Thickness=(c == initial) and 2 or 1
        st.Transparency=(c == initial) and 0 or 0.7

        b.MouseButton1Click:Connect(function()
            playSound(1.2)
            if onChange then safe(onChange, c) end
        end)
        b.MouseEnter:Connect(function()
            tween(b, 0.15, {Size=UDim2.new(0,size+3,0,size+3)})
            tween(b, 0.15, {Position=UDim2.new(0.5, -totalW/2 + (i-1)*(size+gap) - 1.5, 0.5, -size/2 - 1.5)})
        end)
        b.MouseLeave:Connect(function()
            tween(b, 0.15, {Size=UDim2.new(0,size,0,size)})
            tween(b, 0.15, {Position=UDim2.new(0.5, -totalW/2 + (i-1)*(size+gap), 0.5, -size/2)})
        end)
    end
    nextY(50)
end

local function makeButton(text,onClick,color)
    local y=currentY()
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1,-16,0,36); b.Position=UDim2.new(0,8,0,y)
    b.BackgroundColor3=COL.bgRow; b.BackgroundTransparency=0.55
    b.Text=text; b.TextColor3=color or COL.text
    b.Font=Enum.Font.GothamBold; b.TextSize=12; b.AutoButtonColor=false
    b.ZIndex=2; b.Parent=PageHolder; corner(b,10)
    local bStroke=Instance.new("UIStroke", b); bStroke.Color=Color3.fromRGB(255,255,255); bStroke.Thickness=1; bStroke.Transparency=0.85

    b.MouseEnter:Connect(function()
        tween(b, 0.2, {BackgroundColor3 = Color3.fromRGB(70,70,80), BackgroundTransparency = 0.2})
        tween(bStroke, 0.2, {Transparency = 0.4})
    end)
    b.MouseLeave:Connect(function()
        tween(b, 0.25, {BackgroundColor3 = COL.bgRow, BackgroundTransparency = 0.55})
        tween(bStroke, 0.25, {Transparency = 0.85})
    end)
    b.MouseButton1Click:Connect(function()
        playSound(1)
        if onClick then safe(onClick) end
    end)
    nextY(40)
end

local function makeTextBox(placeholder,onEnter)
    local y=currentY()
    local tb=Instance.new("TextBox")
    tb.Size=UDim2.new(1,-16,0,34); tb.Position=UDim2.new(0,8,0,y)
    tb.BackgroundColor3=COL.input; tb.BackgroundTransparency=0.3
    tb.BorderSizePixel=0; tb.Text=""
    tb.PlaceholderText=placeholder; tb.TextColor3=COL.text
    tb.PlaceholderColor3=COL.subtext; tb.Font=Enum.Font.Gotham; tb.TextSize=12
    tb.ZIndex=2; tb.Parent=PageHolder; corner(tb,8)
    local tStroke=Instance.new("UIStroke", tb); tStroke.Color=Color3.fromRGB(255,255,255); tStroke.Thickness=1; tStroke.Transparency=0.75
    tb.Focused:Connect(function() tween(tStroke, 0.2, {Transparency = 0.3}) end)
    tb.FocusLost:Connect(function(enter)
        tween(tStroke, 0.2, {Transparency = 0.75})
        if enter and onEnter then safe(onEnter, tb.Text) end
    end)
    nextY(38)
end

local listeningBind=nil; local bindRefs={}
local function refreshBindUI(k)
    local r=bindRefs[k]; if not r then return end
    r.btn.Text=Config.Keybinds[k].Name; r.btn.TextColor3=COL.text; r.stroke.Transparency=0.75
end
local function makeKeybind(text,bindKey)
    local y=currentY()
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,-16,0,38); row.Position=UDim2.new(0,8,0,y)
    row.BackgroundColor3=COL.bgRow; row.BackgroundTransparency=0.55; row.BorderSizePixel=0
    row.ZIndex=2; row.Parent=PageHolder; corner(row,10)
    local rStroke=Instance.new("UIStroke", row); rStroke.Color=Color3.fromRGB(255,255,255); rStroke.Thickness=1; rStroke.Transparency=0.85

    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-110,1,0); lbl.Position=UDim2.new(0,14,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=text; lbl.TextColor3=COL.text
    lbl.Font=Enum.Font.Gotham; lbl.TextSize=13; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.ZIndex=3; lbl.Parent=row

    local kb=Instance.new("TextButton")
    kb.Size=UDim2.new(0,95,0,26); kb.Position=UDim2.new(1,-107,.5,-13)
    kb.BackgroundColor3=Color3.fromRGB(18,18,24); kb.BackgroundTransparency=0.3
    kb.Text=Config.Keybinds[bindKey].Name
    kb.TextColor3=COL.text; kb.Font=Enum.Font.GothamBold; kb.TextSize=12
    kb.AutoButtonColor=false; kb.ZIndex=3; kb.Parent=row; corner(kb,7)
    local st=Instance.new("UIStroke",kb); st.Color=Color3.fromRGB(255,255,255); st.Thickness=1; st.Transparency=0.75

    addHover(row)

    kb.MouseButton1Click:Connect(function()
        playSound(1.2)
        if listeningBind and listeningBind~=bindKey then refreshBindUI(listeningBind) end
        if listeningBind==bindKey then refreshBindUI(bindKey); listeningBind=nil; return end
        listeningBind=bindKey; kb.Text="..."
        kb.BackgroundColor3=Color3.fromRGB(255,255,255); kb.TextColor3=Color3.fromRGB(20,20,25)
        st.Transparency=0.2
    end)
    bindRefs[bindKey]={btn=kb,stroke=st}
    nextY(40)
end

--// Pages
local function clearPage()
    for _, c in ipairs(PageHolder:GetChildren()) do c:Destroy() end
    SwitchRefs = {}; bindRefs = {}; resetY()
end

local function buildESPPage()
    makeSection("Визуал")
    makeSwitch("Подсветка","ShowHighlight")
    makeSwitch("Ники","ShowNames")
    makeSwitch("Дистанция","ShowDistance")
    makeSwitch("Стрелки","ShowArrows")
    makeSwitch("HP бары","ShowHealthBars")
    makeSection("Фильтр")
    makeSwitch("Только враги","TeamCheck")
    makeSection("Дистанция")
    makeSlider("Макс.",100,5000,Config.MaxDistance,function(v) Config.MaxDistance=v end)
    makeSection("Цвет подсветки")
    makeColorPicker({
        Color3.fromRGB(255,80,80),Color3.fromRGB(255,165,0),Color3.fromRGB(255,220,80),
        Color3.fromRGB(0,214,143),Color3.fromRGB(80,180,255),Color3.fromRGB(108,92,231),
        Color3.fromRGB(255,100,200),Color3.fromRGB(255,255,255),
    },Config.HighlightColor,function(c)
        Config.HighlightColor=c
        for _,d in pairs(ESPData) do
            if d.highlight then d.highlight.FillColor=c end
            if d.arrow then d.arrow.TextColor3=c end
        end
    end)
end

local function buildMovePage()
    makeSection("Полёт")
    makeSwitch("Полёт (F)","FlyEnabled",function(on)
        if on then StartFly() else StopFly() end
    end)
    makeSlider("Скорость полёта",25,500,Config.FlySpeed,function(v) Config.FlySpeed=v end)
    makeSection("Noclip")
    makeSwitch("Noclip (N)","NoClip")
    makeSwitch("Anti-AFK","AntiAFK")
    makeSection("Телепорт")
    makeTextBox("Ник игрока...",function(txt)
        local target=Players:FindFirstChild(txt)
        if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local myHrp=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if myHrp then myHrp.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.new(0,0,3) end
        end
    end)
    makeSection("Spectate")
    makeTextBox("Ник для spectate...",function(txt)
        local target=Players:FindFirstChild(txt)
        if target and target.Character then
            local hum=target.Character:FindFirstChildOfClass("Humanoid")
            if hum then workspace.CurrentCamera.CameraSubject=hum end
        end
    end)
end

local moonDebugLbl
local function buildMoonPage()
    makeSection("Moonwalk V2")
    makeSwitch("Auto Moonwalk (M)","AutoMoonwalk",function(on)
        if on then startMoonwalk(); MoonIndicator.Visible = true
        else stopMoonwalk(); MoonIndicator.Visible = false end
    end)
    makeSwitch("W-A-D Pattern","MoonwalkWadMode",function(on)
        if Config.AutoMoonwalk then
            stopMoonwalk(); task.wait(0.05); startMoonwalk()
        end
    end)
    makeSection("Настройки скорости")
    makeSlider("Скорость цикла",0.005,0.15,Config.MoonwalkSpeed,function(v) Config.MoonwalkSpeed = v end,true)
    makeSlider("Удержание",0.005,0.10,Config.MoonwalkHold,function(v) Config.MoonwalkHold = v end,true)
    makeSection("Debug")
    makeSwitch("Debug счётчик","MoonwalkDebug",function(on)
        if moonDebugLbl then moonDebugLbl.Visible = on end
    end)
    local y=currentY()
    moonDebugLbl = Instance.new("TextLabel")
    moonDebugLbl.Size=UDim2.new(1,-16,0,28); moonDebugLbl.Position=UDim2.new(0,8,0,y)
    moonDebugLbl.BackgroundColor3=COL.bgRow; moonDebugLbl.BackgroundTransparency=.5; moonDebugLbl.BorderSizePixel=0
    moonDebugLbl.Text="  Нажатий: 0"; moonDebugLbl.TextColor3=COL.text
    moonDebugLbl.Font=Enum.Font.GothamBold; moonDebugLbl.TextSize=12
    moonDebugLbl.TextXAlignment=Enum.TextXAlignment.Left
    moonDebugLbl.Visible = Config.MoonwalkDebug
    moonDebugLbl.ZIndex=2; moonDebugLbl.Parent=PageHolder; corner(moonDebugLbl,10); nextY(32)
    makeSection("Тест")
    makeButton("▶ Тест 5 сек (W + A/D)",function()
        if not Config.AutoMoonwalk then
            Config.AutoMoonwalk = true
            if SwitchRefs.AutoMoonwalk then SwitchRefs.AutoMoonwalk.apply(true, true) end
            startMoonwalk(); MoonIndicator.Visible = true
        end
        task.spawn(function()
            pressKey(Enum.KeyCode.W, "w")
            task.wait(5)
            releaseKey(Enum.KeyCode.W, "w")
        end)
    end, Color3.fromRGB(255,255,255))
    makeSection("Подсказка")
    local y2=currentY()
    local info=Instance.new("TextLabel")
    info.Size=UDim2.new(1,-16,0,110); info.Position=UDim2.new(0,8,0,y2)
    info.BackgroundColor3=COL.bgRow; info.BackgroundTransparency=.5; info.BorderSizePixel=0
    info.Text="  Как работает:\n  1. Включи Auto Moonwalk (M)\n  2. Зажми W — персонаж идёт задом\n  3. Скрипт спамит A/D очень быстро\n\n  Speed 0.02 = ~50 циклов/сек\n  Hold 0.02 = клавиша держится 20мс"
    info.TextColor3=COL.subtext; info.Font=Enum.Font.Gotham
    info.TextSize=11; info.TextXAlignment=Enum.TextXAlignment.Left
    info.TextYAlignment=Enum.TextYAlignment.Top; info.TextWrapped=true
    info.ZIndex=2; info.Parent=PageHolder
    corner(info,10); nextY(116)
end

local function buildVisualPage()
    makeSection("Прицел")
    makeSwitch("Crosshair","Crosshair",function(on) Crosshair.Visible = on end)
    makeSection("Цвет прицела")
    makeColorPicker({
        Color3.fromRGB(255,255,255),Color3.fromRGB(0,255,150),Color3.fromRGB(255,80,80),
        Color3.fromRGB(108,92,231),Color3.fromRGB(255,220,80),
    },Config.CrosshairColor,function(c)
        Config.CrosshairColor=c
        chH.BackgroundColor3=c; chV.BackgroundColor3=c; chDot.BackgroundColor3=c
    end)
    makeSection("Камера")
    makeSwitch("Изменить FOV","FOVEnabled",function(on)
        safe(function()
            local cam = workspace.CurrentCamera
            if cam then
                if on then cam.FieldOfView = Config.FOV
                else cam.FieldOfView = OriginalLighting.FOV end
            end
        end)
    end)
    makeSlider("FOV",40,120,Config.FOV,function(v)
        Config.FOV=v
        if Config.FOVEnabled then
            safe(function()
                local cam = workspace.CurrentCamera
                if cam then cam.FieldOfView = v end
            end)
        end
    end)
    makeSection("Производительность")
    makeSwitch("FPS Unlock (240)","FPSUnlock",function(on)
        safe(function()
            if on then
                OriginalFPS = settings().Rendering.FramerateCap or 60
                settings().Rendering.FramerateCap = 240
            else
                settings().Rendering.FramerateCap = OriginalFPS
            end
        end)
    end)
    makeSection("Интерфейс")
    makeSwitch("Watermark","Watermark",function(on) Watermark.Visible = on end)
    makeSwitch("Скрыть всё (])","HideUI",function(on)
        if on then
            Menu.Visible=false; MenuShadow.Visible=false; ToggleBtn.Visible=false
            Watermark.Visible=false; Crosshair.Visible=false; MoonIndicator.Visible=false
        else
            ToggleBtn.Visible=true
            Watermark.Visible=Config.Watermark
            Crosshair.Visible=Config.Crosshair
            MoonIndicator.Visible=Config.AutoMoonwalk
        end
    end)
end

local function buildWorldPage()
    makeSection("Environment")
    makeSwitch("Активировать","EnvEnabled",function(on)
        if on then ApplyLighting() else ResetLighting() end
    end)
    makeSwitch("Fullbright (safe)","Fullbright",function(on)
        if Config.EnvEnabled then ApplyLighting() end
    end)
    makeSection("Эффекты")
    makeSwitch("Bloom","Bloom",UpdateEffects)
    makeSwitch("SunRays","SunRays",UpdateEffects)
    makeSwitch("Mono (CC)","ColorCorr",UpdateEffects)
    makeSwitch("Depth of Field","DoF",UpdateEffects)
    makeSection("Свет")
    makeSlider("Яркость",0,10,Config.Brightness,function(v)
        Config.Brightness=v
        if Config.EnvEnabled then safe(function() tweenLighting("Brightness", math.clamp(v,0.5,4), 1) end) end
    end,true)
    makeSlider("Экспозиция",-3,3,Config.Exposure,function(v)
        Config.Exposure=v
        if Config.EnvEnabled then safe(function() tweenLighting("ExposureCompensation", math.clamp(v,-1,1), 1) end) end
    end,true)
    makeSection("Сброс")
    makeButton("↺ Сброс света",function()
        ResetLighting()
        Config.EnvEnabled=false
        if SwitchRefs.EnvEnabled then SwitchRefs.EnvEnabled.apply(false,true) end
    end, Color3.fromRGB(240,240,245))
end

local function buildBindPage()
    makeSection("Клавиши")
    makeKeybind("Полёт","Fly")
    makeKeybind("Noclip","NoClip")
    makeKeybind("Меню","ToggleMenu")
    makeKeybind("Скрыть UI","HideUI")
    makeKeybind("Moonwalk","Moonwalk")
    makeSection("Сброс")
    makeButton("↺ Сбросить бинды",function()
        for k,v in pairs(Config.DefaultBinds) do Config.Keybinds[k]=v; refreshBindUI(k) end
    end, Color3.fromRGB(240,240,245))
end

LazyPages = {
    [1] = {built=false, builder=buildESPPage},
    [2] = {built=false, builder=buildMovePage},
    [3] = {built=false, builder=buildMoonPage},
    [4] = {built=false, builder=buildVisualPage},
    [5] = {built=false, builder=buildWorldPage},
    [6] = {built=false, builder=buildBindPage},
}
local currentTab=1
local function showTab(i)
    if not LazyPages[i].built then
        clearPage()
        LazyPages[i].builder()
        LazyPages[i].built = true
    end
end
showTab(1)

--// Menu control
local menuOpen=false
local function setMenuOpen(open)
    menuOpen=open
    if open then
        Menu.Visible=true; MenuShadow.Visible=true
        Menu.BackgroundTransparency = 0.85
        tween(Menu, 0.25, {BackgroundTransparency = 0.15}, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        MenuShadow.BackgroundTransparency = 0.9
        tween(MenuShadow, 0.25, {BackgroundTransparency = 0.65})
        playSound(1.4)
    else
        tween(Menu, 0.2, {BackgroundTransparency = 0.85})
        tween(MenuShadow, 0.2, {BackgroundTransparency = 1})
        task.delay(.2,function()
            if not menuOpen then Menu.Visible=false; MenuShadow.Visible=false end
        end)
        playSound(0.9)
    end
end
CloseBtn.MouseButton1Click:Connect(function() setMenuOpen(false) end)

local dragging,dragStart,menuStart,btnStart,shadowStart
local function startDrag(i)
    dragging=true; dragStart=i.Position
    menuStart=Menu.Position; btnStart=ToggleBtn.Position; shadowStart=MenuShadow.Position
    i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then dragging=false end end)
end
Header.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then startDrag(i) end
end)
ToggleBtn.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then startDrag(i) end
end)
UserInputService.InputChanged:Connect(function(i)
    if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-dragStart
        Menu.Position=UDim2.new(menuStart.X.Scale,menuStart.X.Offset+d.X,menuStart.Y.Scale,menuStart.Y.Offset+d.Y)
        MenuShadow.Position=UDim2.new(shadowStart.X.Scale,shadowStart.X.Offset+d.X,shadowStart.Y.Scale,shadowStart.Y.Offset+d.Y)
        ToggleBtn.Position=UDim2.new(btnStart.X.Scale,btnStart.X.Offset+d.X,btnStart.Y.Scale,btnStart.Y.Offset+d.Y)
    end
end)
local bpp
ToggleBtn.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then bpp=i.Position end
end)
ToggleBtn.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
        if bpp and (i.Position-bpp).Magnitude<5 then setMenuOpen(not menuOpen) end
        bpp=nil
    end
end)

for i,b in ipairs(tabButtons) do
    b.MouseButton1Click:Connect(function()
        if currentTab==i then return end
        currentTab=i
        playSound(1.1)
        tween(tabIndicator,.35,{Position=UDim2.new(0.166*(i-1),3,0,3)},Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
        for idx,tb in ipairs(tabButtons) do
            if idx==i then
                tween(tb,.25,{TextColor3=Color3.fromRGB(20,20,25)})
            else
                tween(tb,.25,{TextColor3=COL.subtext})
            end
        end
        showTab(i)
    end)
end

--// SPOTLIGHT (следит за мышью)
local spotlightTarget = Vector2.new(0,0)
local spotlightCurrent = Vector2.new(0,0)
local spotlightActive = false

UserInputService.InputChanged:Connect(function(input)
    if not menuOpen then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        local mousePos = UserInputService:GetMouseLocation()
        local menuPos = Menu.AbsolutePosition
        local menuSize = Menu.AbsoluteSize
        if mousePos.X >= menuPos.X and mousePos.X <= menuPos.X + menuSize.X
           and mousePos.Y >= menuPos.Y and mousePos.Y <= menuPos.Y + menuSize.Y then
            spotlightTarget = Vector2.new(mousePos.X - menuPos.X, mousePos.Y - menuPos.Y)
            if not spotlightActive then
                spotlightActive = true
                Spotlight.BackgroundTransparency = 1
                for _, c in ipairs(Spotlight:GetChildren()) do
                    if c:IsA("Frame") then c.BackgroundTransparency = 1 end
                end
                -- fade in
                task.spawn(function()
                    for _, c in ipairs(Spotlight:GetChildren()) do
                        if c:IsA("Frame") then
                            tween(c, 0.3, {BackgroundTransparency = 0.85 + (1 - c.Size.X.Offset / 340) * 0.15})
                        end
                    end
                end)
            end
        else
            if spotlightActive then
                spotlightActive = false
                for _, c in ipairs(Spotlight:GetChildren()) do
                    if c:IsA("Frame") then
                        tween(c, 0.25, {BackgroundTransparency = 1})
                    end
                end
            end
        end
    end
end)

-- Spotlight smooth follow
RunService.RenderStepped:Connect(function()
    if not spotlightActive then return end
    spotlightCurrent = spotlightCurrent + (spotlightTarget - spotlightCurrent) * 0.25
    Spotlight.Position = UDim2.fromOffset(spotlightCurrent.X, spotlightCurrent.Y)
end)

--// ESP
local function createESPFor(p, char)
    local head=char:WaitForChild("Head",5); if not head then return end
    local d={}
    local hl=Instance.new("Highlight")
    hl.Adornee=char; hl.FillColor=Config.HighlightColor
    hl.OutlineColor=Color3.fromRGB(255,255,255)
    hl.FillTransparency=0.65; hl.OutlineTransparency=0
    hl.DepthMode=Enum.HighlightDepthMode.AlwaysOnTop; hl.Parent=char
    d.highlight=hl
    local bb=Instance.new("BillboardGui")
    bb.Size=UDim2.new(0,200,0,44); bb.StudsOffset=Vector3.new(0,2.8,0)
    bb.AlwaysOnTop=true; bb.Adornee=head; bb.Parent=head
    local nl=Instance.new("TextLabel")
    nl.Size=UDim2.new(1,0,.5,0); nl.BackgroundTransparency=1
    nl.TextColor3=Color3.fromRGB(255,255,255); nl.TextStrokeTransparency=0
    nl.TextStrokeColor3=Color3.fromRGB(0,0,0); nl.Font=Enum.Font.GothamBold
    nl.TextSize=14; nl.Text=p.Name; nl.Parent=bb
    local dl=Instance.new("TextLabel")
    dl.Size=UDim2.new(1,0,.5,0); dl.Position=UDim2.new(0,0,.5,0)
    dl.BackgroundTransparency=1; dl.TextColor3=Color3.fromRGB(220,220,220)
    dl.TextStrokeTransparency=0; dl.TextStrokeColor3=Color3.fromRGB(0,0,0)
    dl.Font=Enum.Font.Gotham; dl.TextSize=12; dl.Parent=bb
    d.billboard=bb; d.nameLabel=nl; d.distanceLabel=dl
    local hbBg=Instance.new("Frame")
    hbBg.Size=UDim2.new(0,60,0,4); hbBg.Position=UDim2.new(0.5,-30,1,2)
    hbBg.BackgroundColor3=Color3.fromRGB(30,30,30); hbBg.BorderSizePixel=0
    hbBg.Parent=bb; corner(hbBg,2)
    local hbFill=Instance.new("Frame")
    hbFill.Size=UDim2.new(1,0,1,0); hbFill.BackgroundColor3=Color3.fromRGB(255,255,255)
    hbFill.BorderSizePixel=0; hbFill.Parent=hbBg; corner(hbFill,2)
    d.healthBar=hbFill
    local ar=Instance.new("TextLabel")
    ar.Size=UDim2.new(0,40,0,40); ar.AnchorPoint=Vector2.new(.5,.5)
    ar.BackgroundTransparency=1; ar.Text="➤"; ar.TextColor3=Config.HighlightColor
    ar.TextSize=32; ar.Font=Enum.Font.GothamBold
    ar.TextStrokeTransparency=0; ar.TextStrokeColor3=Color3.fromRGB(0,0,0)
    ar.Visible=false; ar.Parent=ScreenGui
    d.arrow=ar
    ESPData[p]=d
end

local function clearESP(p)
    local d=ESPData[p]; if not d then return end
    if d.highlight then d.highlight:Destroy() end
    if d.billboard then d.billboard:Destroy() end
    if d.arrow then d.arrow:Destroy() end
    ESPData[p]=nil
end

local function setupPlayer(p)
    if p==LocalPlayer then return end
    local function onChar(ch)
        clearESP(p)
        task.spawn(function()
            local hrp
            for _=1,25 do
                hrp=ch:FindFirstChild("HumanoidRootPart")
                if hrp then break end
                task.wait(0.2)
            end
            if not hrp then return end
            local myRoot=LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if not myRoot then return end
            if (hrp.Position-myRoot.Position).Magnitude <= Config.MaxDistance*1.5 then
                createESPFor(p, ch)
            end
        end)
    end
    p.CharacterAdded:Connect(onChar)
    if p.Character then task.spawn(onChar, p.Character) end
end
for _,p in ipairs(Players:GetPlayers()) do setupPlayer(p) end
Players.PlayerAdded:Connect(setupPlayer)
Players.PlayerRemoving:Connect(clearESP)

LocalPlayer.CharacterAdded:Connect(function()
    if Config.FlyEnabled then task.wait(.5); if Config.FlyEnabled then StartFly() end end
end)

--// Keybinds
local function toggleFly()
    local ns=not Config.FlyEnabled; Config.FlyEnabled=ns
    if ns then StartFly() else StopFly() end
    if SwitchRefs.FlyEnabled then SwitchRefs.FlyEnabled.apply(ns,true) end
end
local function toggleNoClip()
    Config.NoClip=not Config.NoClip
    if SwitchRefs.NoClip then SwitchRefs.NoClip.apply(Config.NoClip,true) end
end
local function toggleMoonwalk()
    Config.AutoMoonwalk = not Config.AutoMoonwalk
    if Config.AutoMoonwalk then
        startMoonwalk(); MoonIndicator.Visible = true
    else
        stopMoonwalk(); MoonIndicator.Visible = false
    end
    if SwitchRefs.AutoMoonwalk then SwitchRefs.AutoMoonwalk.apply(Config.AutoMoonwalk, true) end
end

UserInputService.InputBegan:Connect(function(i,gpe)
    if listeningBind then
        if i.UserInputType==Enum.UserInputType.Keyboard then
            if i.KeyCode==Enum.KeyCode.Escape then refreshBindUI(listeningBind); listeningBind=nil; return end
            Config.Keybinds[listeningBind]=i.KeyCode
            refreshBindUI(listeningBind); listeningBind=nil
            return
        end
        return
    end
    if gpe then return end
    if i.KeyCode==Config.Keybinds.Fly then toggleFly()
    elseif i.KeyCode==Config.Keybinds.NoClip then toggleNoClip()
    elseif i.KeyCode==Config.Keybinds.ToggleMenu then setMenuOpen(not menuOpen)
    elseif i.KeyCode==Config.Keybinds.Moonwalk then toggleMoonwalk()
    elseif i.KeyCode==Config.Keybinds.HideUI then
        Config.HideUI = not Config.HideUI
        if SwitchRefs.HideUI then SwitchRefs.HideUI.apply(Config.HideUI, true) end
        if Config.HideUI then
            Menu.Visible=false; MenuShadow.Visible=false; ToggleBtn.Visible=false
            Watermark.Visible=false; Crosshair.Visible=false; MoonIndicator.Visible=false
        else
            ToggleBtn.Visible=true; Watermark.Visible=Config.Watermark
            Crosshair.Visible=Config.Crosshair
            MoonIndicator.Visible=Config.AutoMoonwalk
        end
    end
end)

--// Auto-restore
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(.5)
    if not ScreenGui.Parent then ScreenGui.Parent=getGuiParent() end
end)
task.spawn(function()
    while task.wait(5) do
        if not ScreenGui.Parent then ScreenGui.Parent=getGuiParent() end
    end
end)

-- Debug updater
task.spawn(function()
    while task.wait(0.3) do
        if moonDebugLbl and Config.MoonwalkDebug then
            moonDebugLbl.Text = "  Нажатий: " .. moonwalkCounter
        end
    end
end)

--// Main loop
local espAccum = 0
local ESP_UPDATE_INTERVAL = 0.15

RunService.Heartbeat:Connect(function(dt)
    if Config.NoClip then
        local ch=LocalPlayer.Character
        if ch then
            for _,p in ipairs(ch:GetDescendants()) do
                if p:IsA("BasePart") and p.CanCollide then p.CanCollide=false end
            end
        end
    end
    if Config.FlyEnabled and flyBV and flyBG then
        local cam=workspace.CurrentCamera; local mv=Vector3.zero
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then mv+=cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then mv-=cam.CFrame.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then mv-=cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then mv+=cam.CFrame.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then mv+=Vector3.yAxis end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then mv-=Vector3.yAxis end
        flyBV.Velocity=(mv.Magnitude>0) and (mv.Unit*Config.FlySpeed) or Vector3.zero
        flyBG.CFrame=cam.CFrame
    end

    espAccum = espAccum + dt
    if espAccum < ESP_UPDATE_INTERVAL then return end
    espAccum = 0

    if not Config.Enabled then return end
    local myCh=LocalPlayer.Character
    local myRoot=myCh and myCh:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end
    local myPos=myRoot.Position

    for p,d in pairs(ESPData) do
        local ch=p.Character
        local root=ch and ch:FindFirstChild("HumanoidRootPart")
        local head=ch and ch:FindFirstChild("Head")
        local hum=ch and ch:FindFirstChildOfClass("Humanoid")
        if not root or not head or not hum or hum.Health<=0 then
            if d.highlight then d.highlight.Enabled=false end
            if d.billboard then d.billboard.Enabled=false end
            if d.arrow then d.arrow.Visible=false end
        else
            local dist=(root.Position-myPos).Magnitude
            local inRange=dist<=Config.MaxDistance
            local teamOK=(not Config.TeamCheck) or (p.Team~=LocalPlayer.Team)
            local vis=inRange and teamOK
            if d.highlight then d.highlight.Enabled=vis and Config.ShowHighlight end
            if d.billboard then
                d.billboard.Enabled=vis and (Config.ShowNames or Config.ShowDistance or Config.ShowHealthBars)
                d.nameLabel.Visible=Config.ShowNames
                if Config.ShowNames then d.nameLabel.Text=p.Name end
                d.distanceLabel.Visible=Config.ShowDistance
                if Config.ShowDistance then d.distanceLabel.Text=string.format("%d",math.floor(dist)) end
                if d.healthBar then
                    d.healthBar.Parent.Visible = Config.ShowHealthBars and vis
                    local hp = math.clamp(hum.Health/hum.MaxHealth, 0, 1)
                    d.healthBar.Size = UDim2.new(hp, 0, 1, 0)
                    d.healthBar.BackgroundColor3 = Color3.fromRGB(255,255,255)
                end
            end
            if d.arrow then
                if vis and Config.ShowArrows then
                    local cam=workspace.CurrentCamera
                    local sp,onS=cam:WorldToViewportPoint(root.Position)
                    if onS and sp.Z>0 then d.arrow.Visible=false
                    else
                        local dir=(root.Position-cam.CFrame.Position).Unit
                        local x=dir:Dot(cam.CFrame.RightVector); local y=dir:Dot(cam.CFrame.UpVector)
                        local a=math.atan2(y,x)
                        local vp=cam.ViewportSize
                        local c=Vector2.new(vp.X/2,vp.Y/2)
                        local r=math.min(vp.X,vp.Y)*0.35
                        d.arrow.Position=UDim2.fromOffset(c.X+math.cos(a)*r,c.Y-math.sin(a)*r)
                        d.arrow.Rotation=-math.deg(a)
                        d.arrow.Visible=true
                    end
                else d.arrow.Visible=false end
            end
        end
    end
end)

print(">>> abuzlok VD Liquid Glass загружен")
