--// ============================================================
--//  🌙 abuzlok VD — Moonwalk Edition
--//  ESP + Fly + Noclip + Teleport + Visual + World + Moonwalk
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
    HighlightColor=Color3.fromRGB(108,92,231),
    FlyEnabled=false, FlySpeed=100, NoClip=false,
    Crosshair=true, CrosshairColor=Color3.fromRGB(0,255,150),
    FOVEnabled=false, FOV=70, FPSUnlock=false,
    HideUI=false, Watermark=true,
    EnvEnabled=false,
    Ambient=Color3.fromRGB(70,70,70),
    OutdoorAmbient=Color3.fromRGB(128,128,128),
    Brightness=2, Exposure=0,
    Fullbright=false,
    Bloom=false, SunRays=false, ColorCorr=false, DoF=false,
    AntiAFK=true,
    -- Moonwalk
    AutoMoonwalk=false,
    MoonwalkSpeed=0.05,   -- скорость переключения (сек)
    MoonwalkHold=0.03,    -- длительность нажатия (сек)
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

local COL = {
    bg=Color3.fromRGB(20,20,28), bgHeader=Color3.fromRGB(28,28,40), bgRow=Color3.fromRGB(34,34,48),
    accent=Color3.fromRGB(108,92,231), accentSoft=Color3.fromRGB(162,155,254),
    text=Color3.fromRGB(240,240,250), subtext=Color3.fromRGB(150,150,170),
    on=Color3.fromRGB(0,214,143), off=Color3.fromRGB(58,58,74),
    track=Color3.fromRGB(48,48,66), border=Color3.fromRGB(60,60,80), input=Color3.fromRGB(28,28,42),
    warn=Color3.fromRGB(255,180,60), moon=Color3.fromRGB(200,180,255),
}

local function tween(o,t,p,st,d) local i=TweenInfo.new(t or .2,st or Enum.EasingStyle.Quad,d or Enum.EasingDirection.Out);local tw=TweenService:Create(o,i,p);tw:Play();return tw end
local function corner(p,r) local c=Instance.new("UICorner",p);c.CornerRadius=UDim.new(0,r or 8);return c end
local function safe(f,...) local ok,err=pcall(f,...); if not ok then warn("[abuzlok VD]",err) end end

--// Sound
local SoundPlayer = Instance.new("Sound")
SoundPlayer.SoundId = "rbxasset://sounds/electronicpingshort.wav"
SoundPlayer.Volume = 0.35
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

--// ============================================================
--//  MOONWALK
--// ============================================================
local moonwalkActive = false
local moonwalkThread = nil

-- Универсальная отправка нажатия клавиши
local function sendKey(key, state)
    -- Основной метод — VirtualInputManager
    pcall(function()
        local VIM = game:GetService("VirtualInputManager")
        VIM:SendKeyEvent(state, key, false, game)
    end)
    -- Fallback для executor'ов с keypress/keyrelease
    pcall(function()
        if state then
            if keypress then keypress(key) end
        else
            if keyrelease then keyrelease(key) end
        end
    end)
end

local function startMoonwalk()
    if moonwalkThread then return end
    moonwalkActive = true
    moonwalkThread = task.spawn(function()
        local toggle = false
        while moonwalkActive do
            if Config.AutoMoonwalk and UserInputService:IsKeyDown(Enum.KeyCode.W) then
                toggle = not toggle
                local k = toggle and Enum.KeyCode.A or Enum.KeyCode.D
                sendKey(k, true)
                task.wait(Config.MoonwalkHold)
                sendKey(k, false)
                task.wait(math.max(0, Config.MoonwalkSpeed - Config.MoonwalkHold))
            else
                task.wait(0.03)
            end
        end
    end)
end

local function stopMoonwalk()
    moonwalkActive = false
    if moonwalkThread then
        pcall(function() task.cancel(moonwalkThread) end)
        moonwalkThread = nil
    end
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
    setEffect("ABZ_CC", "ColorCorrectionEffect", Config.ColorCorr and on, {Saturation=0.15, Contrast=0.1})
    setEffect("ABZ_DoF", "DepthOfFieldEffect", Config.DoF and on, {FarIntensity=0.15, FocusDistance=20, InFocusRadius=40})
end

--// Lighting
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

--// Root
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name="AbuzlokVD"; ScreenGui.ResetOnSpawn=false
ScreenGui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
ScreenGui.IgnoreGuiInset=true; ScreenGui.DisplayOrder=999999
ScreenGui.Parent = getGuiParent()

--// Watermark
local Watermark = Instance.new("Frame")
Watermark.Size=UDim2.new(0,240,0,26); Watermark.Position=UDim2.new(0,10,0,10)
Watermark.BackgroundColor3=COL.bg; Watermark.BackgroundTransparency=0.15
Watermark.BorderSizePixel=0; Watermark.Parent=ScreenGui; corner(Watermark,6)
local wmStroke=Instance.new("UIStroke",Watermark); wmStroke.Color=COL.accent; wmStroke.Thickness=1
local wmLabel=Instance.new("TextLabel")
wmLabel.Size=UDim2.new(1,0,1,0); wmLabel.BackgroundTransparency=1
wmLabel.Text="🌙 abuzlok VD  |  "..LocalPlayer.Name
wmLabel.TextColor3=COL.accentSoft; wmLabel.Font=Enum.Font.GothamBold
wmLabel.TextSize=11; wmLabel.Parent=Watermark

--// Moonwalk indicator
local MoonIndicator = Instance.new("Frame")
MoonIndicator.Size=UDim2.new(0,120,0,22); MoonIndicator.Position=UDim2.new(0,10,0,40)
MoonIndicator.BackgroundColor3=COL.bg; MoonIndicator.BackgroundTransparency=0.3
MoonIndicator.BorderSizePixel=0; MoonIndicator.Visible=false; MoonIndicator.Parent=ScreenGui
corner(MoonIndicator,4)
local miStroke=Instance.new("UIStroke",MoonIndicator); miStroke.Color=COL.moon; miStroke.Thickness=1
local miLabel=Instance.new("TextLabel")
miLabel.Size=UDim2.new(1,0,1,0); miLabel.BackgroundTransparency=1
miLabel.Text="🌙 MOONWALK ACTIVE"
miLabel.TextColor3=COL.moon; miLabel.Font=Enum.Font.GothamBold
miLabel.TextSize=10; miLabel.Parent=MoonIndicator

--// Crosshair
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

--// Toggle button
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size=UDim2.new(0,140,0,36); ToggleBtn.Position=UDim2.new(0.5,-70,0,14)
ToggleBtn.BackgroundColor3=COL.bg; ToggleBtn.Text="🌙 abuzlok VD [L]"
ToggleBtn.TextColor3=COL.accentSoft; ToggleBtn.Font=Enum.Font.GothamBold
ToggleBtn.TextSize=12; ToggleBtn.AutoButtonColor=false; ToggleBtn.Parent=ScreenGui; corner(ToggleBtn,10)
local tbStroke=Instance.new("UIStroke",ToggleBtn); tbStroke.Color=COL.accent; tbStroke.Thickness=1.5

--// Menu
local Menu = Instance.new("Frame")
Menu.Size=UDim2.new(0,320,0,480); Menu.Position=UDim2.new(0.5,-160,0,62)
Menu.BackgroundColor3=COL.bg; Menu.BorderSizePixel=0
Menu.Visible=false; Menu.Parent=ScreenGui; corner(Menu,14)
local menuStroke=Instance.new("UIStroke",Menu); menuStroke.Color=COL.border; menuStroke.Thickness=1

local Header=Instance.new("Frame")
Header.Size=UDim2.new(1,0,0,44); Header.BackgroundColor3=COL.bgHeader
Header.BorderSizePixel=0; Header.Parent=Menu; corner(Header,14)
local hGrad=Instance.new("UIGradient")
hGrad.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,Color3.fromRGB(108,92,231)),ColorSequenceKeypoint.new(1,Color3.fromRGB(162,155,254))}
hGrad.Transparency=NumberSequence.new{NumberSequenceKeypoint.new(0,0.88),NumberSequenceKeypoint.new(1,0.82)}
hGrad.Parent=Header
local hCover=Instance.new("Frame")
hCover.Size=UDim2.new(1,0,0.5,0); hCover.Position=UDim2.new(0,0,0.5,0)
hCover.BackgroundColor3=COL.bgHeader; hCover.BorderSizePixel=0; hCover.ZIndex=2; hCover.Parent=Header
local hcGrad=Instance.new("UIGradient"); hcGrad.Color=hGrad.Color; hcGrad.Transparency=hGrad.Transparency; hcGrad.Parent=hCover
local Title=Instance.new("TextLabel")
Title.Size=UDim2.new(1,-50,1,0); Title.Position=UDim2.new(0,16,0,0); Title.BackgroundTransparency=1
Title.Text="🌙  abuzlok VD"; Title.TextColor3=Color3.fromRGB(255,255,255)
Title.Font=Enum.Font.GothamBold; Title.TextSize=15; Title.TextXAlignment=Enum.TextXAlignment.Left
Title.ZIndex=3; Title.Parent=Header
local CloseBtn=Instance.new("TextButton")
CloseBtn.Size=UDim2.new(0,24,0,24); CloseBtn.Position=UDim2.new(1,-34,0.5,-12)
CloseBtn.BackgroundColor3=Color3.fromRGB(255,90,90); CloseBtn.Text="×"
CloseBtn.TextColor3=Color3.fromRGB(255,255,255); CloseBtn.Font=Enum.Font.GothamBold
CloseBtn.TextSize=17; CloseBtn.AutoButtonColor=false; CloseBtn.ZIndex=4; CloseBtn.Parent=Header; corner(CloseBtn,12)

--// Tabs
local TabBar=Instance.new("Frame")
TabBar.Size=UDim2.new(1,-20,0,32); TabBar.Position=UDim2.new(0,10,0,52)
TabBar.BackgroundColor3=COL.bgRow; TabBar.BorderSizePixel=0; TabBar.Parent=Menu; corner(TabBar,9)
local tabIndicator=Instance.new("Frame")
tabIndicator.Size=UDim2.new(0.166,-4,1,-4); tabIndicator.Position=UDim2.new(0,2,0,2)
tabIndicator.BackgroundColor3=COL.accent; tabIndicator.BorderSizePixel=0; tabIndicator.ZIndex=1; tabIndicator.Parent=TabBar
corner(tabIndicator,7)
local tabNames={"ESP","MOVE","MOON","VISUAL","WORLD","BINDS"}
local tabButtons={}
for i,name in ipairs(tabNames) do
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(0.166,0,1,0); b.Position=UDim2.new(0.166*(i-1),0,0,0)
    b.BackgroundTransparency=1; b.Text=name
    b.TextColor3=(i==1) and Color3.fromRGB(255,255,255) or COL.subtext
    b.Font=Enum.Font.GothamBold; b.TextSize=9; b.ZIndex=2; b.AutoButtonColor=false; b.Parent=TabBar
    tabButtons[i]=b
end

local Content=Instance.new("Frame")
Content.Size=UDim2.new(1,-20,1,-100); Content.Position=UDim2.new(0,10,0,96)
Content.BackgroundTransparency=1; Content.ClipsDescendants=true; Content.Parent=Menu

local MainScroll = Instance.new("ScrollingFrame")
MainScroll.Size=UDim2.new(1,0,1,0); MainScroll.BackgroundTransparency=1; MainScroll.BorderSizePixel=0
MainScroll.ScrollBarThickness=4; MainScroll.ScrollBarImageColor3=COL.accent
MainScroll.CanvasSize=UDim2.new(0,0,0,0); MainScroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
MainScroll.Parent=Content

local PageHolder = Instance.new("Frame")
PageHolder.Size=UDim2.new(1,0,0,0); PageHolder.BackgroundTransparency=1
PageHolder.AutomaticSize = Enum.AutomaticSize.Y
PageHolder.Parent = MainScroll

--// Components
local componentY = 4
local function resetY() componentY = 4 end
local function nextY(o) componentY = componentY + (o or 0); return componentY end
local function currentY() return componentY end

local function makeSection(text)
    local y=currentY()
    local l=Instance.new("TextLabel")
    l.Size=UDim2.new(1,-16,0,18); l.Position=UDim2.new(0,8,0,y)
    l.BackgroundTransparency=1; l.Text=string.upper(text); l.TextColor3=COL.accentSoft
    l.Font=Enum.Font.GothamBold; l.TextSize=10; l.TextXAlignment=Enum.TextXAlignment.Left
    l.Parent=PageHolder; nextY(22)
end

local function makeSwitch(text,key,onChange)
    local y=currentY()
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,-16,0,34); row.Position=UDim2.new(0,8,0,y)
    row.BackgroundColor3=COL.bgRow; row.BackgroundTransparency=1; row.BorderSizePixel=0; row.Parent=PageHolder
    corner(row,8)
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-60,1,0); lbl.Position=UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=text; lbl.TextColor3=COL.text
    lbl.Font=Enum.Font.Gotham; lbl.TextSize=13; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=row
    local sw=Instance.new("TextButton")
    sw.Size=UDim2.new(0,42,0,22); sw.Position=UDim2.new(1,-54,.5,-11)
    sw.BackgroundColor3=Config[key] and COL.on or COL.off; sw.Text=""; sw.AutoButtonColor=false; sw.Parent=row
    corner(sw,11)
    local knob=Instance.new("Frame")
    knob.Size=UDim2.new(0,18,0,18)
    knob.Position=Config[key] and UDim2.new(1,-20,.5,-9) or UDim2.new(0,2,.5,-9)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.BorderSizePixel=0; knob.Parent=sw; corner(knob,9)
    local function apply(on,anim)
        local p=on and UDim2.new(1,-20,.5,-9) or UDim2.new(0,2,.5,-9)
        local c=on and COL.on or COL.off
        if anim then tween(knob,.25,{Position=p},Enum.EasingStyle.Back,Enum.EasingDirection.Out); tween(sw,.2,{BackgroundColor3=c})
        else knob.Position=p; sw.BackgroundColor3=c end
    end
    sw.MouseButton1Click:Connect(function()
        Config[key]=not Config[key]; apply(Config[key],true); playSound(Config[key] and 1.3 or 0.9)
        if onChange then safe(onChange, Config[key]) end
    end)
    SwitchRefs[key]={apply=apply}
    nextY(36)
end

local function makeSlider(text,min,max,value,onChange,isFloat)
    local y=currentY()
    local h=Instance.new("Frame")
    h.Size=UDim2.new(1,-16,0,44); h.Position=UDim2.new(0,8,0,y); h.BackgroundTransparency=1; h.Parent=PageHolder
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-80,0,16); lbl.Position=UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=text; lbl.TextColor3=COL.text
    lbl.Font=Enum.Font.Gotham; lbl.TextSize=12; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=h
    local vl=Instance.new("TextLabel")
    vl.Size=UDim2.new(0,70,0,16); vl.Position=UDim2.new(1,-80,0,0)
    vl.BackgroundTransparency=1; vl.Text=isFloat and string.format("%.3f",value) or tostring(value)
    vl.TextColor3=COL.accentSoft; vl.Font=Enum.Font.GothamBold; vl.TextSize=12
    vl.TextXAlignment=Enum.TextXAlignment.Right; vl.Parent=h
    local track=Instance.new("Frame")
    track.Size=UDim2.new(1,-24,0,6); track.Position=UDim2.new(0,12,0,30)
    track.BackgroundColor3=COL.track; track.BorderSizePixel=0; track.Parent=h; corner(track,3)
    local fill=Instance.new("Frame")
    fill.Size=UDim2.new(0,0,1,0); fill.BackgroundColor3=COL.accent; fill.BorderSizePixel=0; fill.Parent=track; corner(fill,3)
    local knob=Instance.new("Frame")
    knob.Size=UDim2.new(0,14,0,14); knob.AnchorPoint=Vector2.new(.5,.5); knob.Position=UDim2.new(0,0,.5,0)
    knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.BorderSizePixel=0; knob.Parent=track; corner(knob,7)
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
    setV(value); nextY(48)
end

local function makeColorPicker(colors,initial,onChange)
    local y=currentY()
    local h=Instance.new("Frame")
    h.Size=UDim2.new(1,-16,0,44); h.Position=UDim2.new(0,8,0,y); h.BackgroundTransparency=1; h.Parent=PageHolder
    local size,gap=22,5
    for i,c in ipairs(colors) do
        local b=Instance.new("TextButton")
        b.Size=UDim2.new(0,size,0,size); b.Position=UDim2.new(0,12+(i-1)*(size+gap),0,10)
        b.BackgroundColor3=c; b.Text=""; b.AutoButtonColor=false; b.Parent=h; corner(b,size/2)
        if c == initial then
            local st=Instance.new("UIStroke",b); st.Color=Color3.fromRGB(255,255,255); st.Thickness=2
        end
        b.MouseButton1Click:Connect(function()
            playSound(1.2)
            if onChange then safe(onChange, c) end
        end)
    end
    nextY(48)
end

local function makeButton(text,onClick,color)
    local y=currentY()
    local b=Instance.new("TextButton")
    b.Size=UDim2.new(1,-16,0,32); b.Position=UDim2.new(0,8,0,y)
    b.BackgroundColor3=color or COL.accent; b.Text=text; b.TextColor3=Color3.fromRGB(255,255,255)
    b.Font=Enum.Font.GothamBold; b.TextSize=12; b.AutoButtonColor=false; b.Parent=PageHolder
    corner(b,8)
    b.MouseButton1Click:Connect(function()
        playSound(1)
        if onClick then safe(onClick) end
    end)
    nextY(36)
end

local function makeTextBox(placeholder,onEnter)
    local y=currentY()
    local tb=Instance.new("TextBox")
    tb.Size=UDim2.new(1,-16,0,30); tb.Position=UDim2.new(0,8,0,y)
    tb.BackgroundColor3=COL.input; tb.BorderSizePixel=0; tb.Text=""
    tb.PlaceholderText=placeholder; tb.TextColor3=COL.text
    tb.PlaceholderColor3=COL.subtext; tb.Font=Enum.Font.Gotham; tb.TextSize=12
    tb.Parent=PageHolder; corner(tb,8)
    tb.FocusLost:Connect(function(enter)
        if enter and onEnter then safe(onEnter, tb.Text) end
    end)
    nextY(34)
end

local listeningBind=nil; local bindRefs={}
local function refreshBindUI(k)
    local r=bindRefs[k]; if not r then return end
    r.btn.Text=Config.Keybinds[k].Name; r.btn.TextColor3=COL.accentSoft; r.stroke.Color=COL.border
end
local function makeKeybind(text,bindKey)
    local y=currentY()
    local row=Instance.new("Frame")
    row.Size=UDim2.new(1,-16,0,36); row.Position=UDim2.new(0,8,0,y)
    row.BackgroundColor3=COL.bgRow; row.BackgroundTransparency=1; row.BorderSizePixel=0; row.Parent=PageHolder
    corner(row,8)
    local lbl=Instance.new("TextLabel")
    lbl.Size=UDim2.new(1,-110,1,0); lbl.Position=UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency=1; lbl.Text=text; lbl.TextColor3=COL.text
    lbl.Font=Enum.Font.Gotham; lbl.TextSize=13; lbl.TextXAlignment=Enum.TextXAlignment.Left; lbl.Parent=row
    local kb=Instance.new("TextButton")
    kb.Size=UDim2.new(0,95,0,24); kb.Position=UDim2.new(1,-107,.5,-12)
    kb.BackgroundColor3=COL.bgRow; kb.Text=Config.Keybinds[bindKey].Name
    kb.TextColor3=COL.accentSoft; kb.Font=Enum.Font.GothamBold; kb.TextSize=12
    kb.AutoButtonColor=false; kb.Parent=row; corner(kb,6)
    local st=Instance.new("UIStroke",kb); st.Color=COL.border; st.Thickness=1
    kb.MouseButton1Click:Connect(function()
        playSound(1.2)
        if listeningBind and listeningBind~=bindKey then refreshBindUI(listeningBind) end
        if listeningBind==bindKey then refreshBindUI(bindKey); listeningBind=nil; return end
        listeningBind=bindKey; kb.Text="..."
        kb.BackgroundColor3=COL.accent; kb.TextColor3=Color3.fromRGB(255,255,255); st.Color=COL.accent
    end)
    bindRefs[bindKey]={btn=kb,stroke=st}
    nextY(38)
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

--// MOONWALK PAGE
local function buildMoonPage()
    makeSection("🌙 Moonwalk")
    makeSwitch("Auto Moonwalk (M)","AutoMoonwalk",function(on)
        if on then
            startMoonwalk()
            MoonIndicator.Visible = true
        else
            stopMoonwalk()
            MoonIndicator.Visible = false
            -- Отпустим возможные зажатые клавиши
            sendKey(Enum.KeyCode.A, false)
            sendKey(Enum.KeyCode.D, false)
        end
    end)
    makeSection("Настройки скорости")
    makeSlider("Скорость перекл. (сек)",0.02,0.30,Config.MoonwalkSpeed,function(v)
        Config.MoonwalkSpeed = v
    end,true)
    makeSlider("Длительность нажатия",0.01,0.15,Config.MoonwalkHold,function(v)
        Config.MoonwalkHold = v
    end,true)
    makeSection("Подсказка")
    local y=currentY()
    local info=Instance.new("TextLabel")
    info.Size=UDim2.new(1,-16,0,90); info.Position=UDim2.new(0,8,0,y)
    info.BackgroundColor3=COL.bgRow; info.BackgroundTransparency=.4; info.BorderSizePixel=0
    info.Text="  🌙 Как работает:\n  1. Включи Auto Moonwalk (M)\n  2. Зажми W — персонаж идёт задом\n  3. Скрипт спамит A/D очень быстро\n\n  ⚠ Слишком быстро = не работает\n     Оптимум: 0.05 / 0.03"
    info.TextColor3=COL.subtext; info.Font=Enum.Font.Gotham
    info.TextSize=11; info.TextXAlignment=Enum.TextXAlignment.Left
    info.TextYAlignment=Enum.TextYAlignment.Top; info.TextWrapped=true; info.Parent=PageHolder
    corner(info,8); nextY(96)
    makeSection("Тест")
    makeButton("▶ Тест 3 секунды",function()
        if not Config.AutoMoonwalk then
            Config.AutoMoonwalk = true
            if SwitchRefs.AutoMoonwalk then SwitchRefs.AutoMoonwalk.apply(true, true) end
            startMoonwalk()
            MoonIndicator.Visible = true
        end
        task.spawn(function()
            -- Имитируем нажатие W для теста
            sendKey(Enum.KeyCode.W, true)
            task.wait(3)
            sendKey(Enum.KeyCode.W, false)
        end)
    end, COL.moon)
end

local function buildVisualPage()
    makeSection("Прицел")
    makeSwitch("Crosshair","Crosshair",function(on) Crosshair.Visible = on end)
    makeSection("Цвет прицела")
    makeColorPicker({
        Color3.fromRGB(0,255,150),Color3.fromRGB(255,80,80),Color3.fromRGB(255,255,255),
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
            Menu.Visible=false; ToggleBtn.Visible=false
            Watermark.Visible=false; Crosshair.Visible=false
            MoonIndicator.Visible=false
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
    makeSwitch("Color Correction","ColorCorr",UpdateEffects)
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
    end, Color3.fromRGB(200,70,70))
end

local function buildBindPage()
    makeSection("Клавиши")
    makeKeybind("Полёт","Fly")
    makeKeybind("Noclip","NoClip")
    makeKeybind("Меню","ToggleMenu")
    makeKeybind("Скрыть UI","HideUI")
    makeKeybind("Moonwalk","Moonwalk")
    makeSection("Информация")
    local y=currentY()
    local info=Instance.new("TextLabel")
    info.Size=UDim2.new(1,-16,0,60); info.Position=UDim2.new(0,8,0,y)
    info.BackgroundColor3=COL.bgRow; info.BackgroundTransparency=.4; info.BorderSizePixel=0
    info.Text="  🌙 abuzlok VD — Moonwalk Edition\n  ESP + Fly + Noclip + Visual + Moonwalk"
    info.TextColor3=COL.subtext; info.Font=Enum.Font.Gotham
    info.TextSize=11; info.TextXAlignment=Enum.TextXAlignment.Left
    info.TextYAlignment=Enum.TextYAlignment.Top; info.TextWrapped=true; info.Parent=PageHolder
    corner(info,8); nextY(66)
    makeSection("Сброс")
    makeButton("↺ Сбросить бинды",function()
        for k,v in pairs(Config.DefaultBinds) do Config.Keybinds[k]=v; refreshBindUI(k) end
    end, Color3.fromRGB(200,70,70))
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
        Menu.Visible=true; tween(Menu,.22,{BackgroundTransparency=0}); playSound(1.4)
    else
        tween(Menu,.18,{BackgroundTransparency=1})
        task.delay(.18,function() if not menuOpen then Menu.Visible=false end end)
        playSound(0.9)
    end
end
CloseBtn.MouseButton1Click:Connect(function() setMenuOpen(false) end)

local dragging,dragStart,menuStart,btnStart
local function startDrag(i)
    dragging=true; dragStart=i.Position; menuStart=Menu.Position; btnStart=ToggleBtn.Position
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
        tween(tabIndicator,.3,{Position=UDim2.new(0.166*(i-1),2,0,2)},Enum.EasingStyle.Quart,Enum.EasingDirection.Out)
        for idx,tb in ipairs(tabButtons) do
            tween(tb,.2,{TextColor3=(idx==i) and Color3.fromRGB(255,255,255) or COL.subtext})
        end
        showTab(i)
    end)
end

--// ESP
local function createESPFor(p, char)
    local head=char:WaitForChild("Head",5); if not head then return end
    local d={}
    local hl=Instance.new("Highlight")
    hl.Adornee=char; hl.FillColor=Config.HighlightColor
    hl.OutlineColor=Color3.fromRGB(255,255,255)
    hl.FillTransparency=0.6; hl.OutlineTransparency=0
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
    hbFill.Size=UDim2.new(1,0,1,0); hbFill.BackgroundColor3=Color3.fromRGB(0,214,143)
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
        startMoonwalk()
        MoonIndicator.Visible = true
    else
        stopMoonwalk()
        MoonIndicator.Visible = false
        sendKey(Enum.KeyCode.A, false)
        sendKey(Enum.KeyCode.D, false)
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
            Menu.Visible=false; ToggleBtn.Visible=false; Watermark.Visible=false
            Crosshair.Visible=false; MoonIndicator.Visible=false
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
                    if hp > 0.6 then d.healthBar.BackgroundColor3=Color3.fromRGB(0,214,143)
                    elseif hp > 0.3 then d.healthBar.BackgroundColor3=Color3.fromRGB(255,180,60)
                    else d.healthBar.BackgroundColor3=Color3.fromRGB(255,80,80) end
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

print(">>> abuzlok VD Moonwalk загружен")
