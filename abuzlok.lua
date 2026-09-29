--[[
    ═══════════════════════════════════════════════════════════
    Violence District Hub v4 — FULL MEGA BUILD
    ═══════════════════════════════════════════════════════════
    Visual:  ESP | Chams | Tracers | Fullbright | HUD | Radar
    Combat:  Auto Skill Check v3 | Inf Stamina | Inf Abilities
    Move:    Speed | TP Suite | Fly | Noclip
    Misc:    Config | Keybinds | Notifications | Search | Panic
             Anti-Cheat | Legit | Auto-Disable | Auto-Play | Stats
    ═══════════════════════════════════════════════════════════
--]]

-- ═══════════ SERVICES ═══════════
local Players      = game:GetService("Players")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local Lighting     = game:GetService("Lighting")
local VIM          = game:GetService("VirtualInputManager")
local HttpService  = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")
local LP           = Players.LocalPlayer
local Cam          = workspace.CurrentCamera

-- ═══════════ STATE ═══════════
local State = {
    -- Visual
    ESP=false, ESPColor=Color3.fromRGB(255,60,60), ShowHealth=true, ShowDistance=true,
    Chams=false, ChamsColor=Color3.fromRGB(255,0,200),
    Tracers=false, TracerColor=Color3.fromRGB(0,255,120),
    Fullbright=false, HUD=true, Radar=true,
    -- Combat
    AutoSkill=false, SkillHitChance=95,
    InfStamina=false, InfAbilities=false, InstantCooldown=false, InfiniteHeal=false,
    -- Movement
    Speed=false, WalkSpeed=60, SpeedMode="Blatant",
    Fly=false, FlySpeed=60, Noclip=false,
    -- Misc
    LegitMode=false, AntiCheat=true, AutoDisableOnReport=true, AutoPlay=false,
    -- Keys
    MenuKey=Enum.KeyCode.RightShift, PanicKey=Enum.KeyCode.Delete,
}

local ESPData, TracerData = {}, {}
local OriginalLighting = {}
local SavedPos = nil
local clickTP = false

-- ═══════════ NOTIFICATIONS ═══════════
local NotifyGui = Instance.new("ScreenGui")
NotifyGui.Name="VD_Notify"; NotifyGui.ResetOnSpawn=false
NotifyGui.Parent=(gethui and gethui()) or game:GetService("CoreGui")

local NotifyFrame = Instance.new("Frame")
NotifyFrame.Size=UDim2.new(0,320,1,0); NotifyFrame.Position=UDim2.new(1,-340,0,0)
NotifyFrame.BackgroundTransparency=1; NotifyFrame.Parent=NotifyGui

local NL = Instance.new("UIListLayout",NotifyFrame)
NL.Padding=UDim.new(0,8); NL.VerticalAlignment=Enum.VerticalAlignment.Bottom
NL.SortOrder=Enum.SortOrder.LayoutOrder

local function Notify(text, color, dur)
    color=color or Color3.fromRGB(0,180,255); dur=dur or 3
    local f=Instance.new("Frame")
    f.Size=UDim2.new(1,0,0,42); f.BackgroundColor3=Color3.fromRGB(25,25,35)
    f.BorderSizePixel=0; f.Parent=NotifyFrame
    Instance.new("UICorner",f).CornerRadius=UDim.new(0,8)
    local s=Instance.new("UIStroke",f); s.Color=color; s.Thickness=1.5
    local bar=Instance.new("Frame",f)
    bar.Size=UDim2.new(0,4,1,0); bar.BackgroundColor3=color
    bar.BorderSizePixel=0
    Instance.new("UICorner",bar).CornerRadius=UDim.new(0,8)
    local t=Instance.new("TextLabel",f)
    t.Size=UDim2.new(1,-20,1,0); t.Position=UDim2.new(0,14,0,0)
    t.BackgroundTransparency=1; t.Text=text
    t.TextColor3=Color3.fromRGB(240,240,255); t.Font=Enum.Font.GothamSemibold
    t.TextSize=13; t.TextXAlignment=Enum.TextXAlignment.Left
    task.delay(dur,function()
        TweenService:Create(f,TweenInfo.new(0.3),{BackgroundTransparency=1}):Play()
        TweenService:Create(t,TweenInfo.new(0.3),{TextTransparency=1}):Play()
        TweenService:Create(bar,TweenInfo.new(0.3),{BackgroundTransparency=1}):Play()
        task.wait(0.35); f:Destroy()
    end)
end

-- ═══════════ MAIN UI ═══════════
local SG = Instance.new("ScreenGui")
SG.Name="VD_Hub_v4"; SG.ResetOnSpawn=false; SG.DisplayOrder=9999
SG.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
SG.Parent=(gethui and gethui()) or game:GetService("CoreGui")

local Main = Instance.new("Frame")
Main.Size=UDim2.new(0,480,0,400); Main.Position=UDim2.new(0,50,0,80)
Main.BackgroundColor3=Color3.fromRGB(18,18,24); Main.BorderSizePixel=0
Main.Active=true; Main.ClipsDescendants=true; Main.Parent=SG
Instance.new("UICorner",Main).CornerRadius=UDim.new(0,12)
local MS=Instance.new("UIStroke",Main); MS.Color=Color3.fromRGB(90,90,130); MS.Thickness=1

local Title=Instance.new("TextButton")
Title.Size=UDim2.new(1,0,0,38); Title.BackgroundColor3=Color3.fromRGB(30,30,42)
Title.Text="  ⚡ Violence District Hub v4"
Title.TextColor3=Color3.fromRGB(255,255,255); Title.Font=Enum.Font.GothamBold
Title.TextSize=14; Title.TextXAlignment=Enum.TextXAlignment.Left
Title.AutoButtonColor=false; Title.Parent=Main
Instance.new("UICorner",Title).CornerRadius=UDim.new(0,12)

local SearchBox=Instance.new("TextBox")
SearchBox.Size=UDim2.new(0,200,0,26); SearchBox.Position=UDim2.new(1,-220,0,6)
SearchBox.BackgroundColor3=Color3.fromRGB(45,45,60); SearchBox.BorderSizePixel=0
SearchBox.PlaceholderText="🔍 Search..."; SearchBox.Text=""
SearchBox.TextColor3=Color3.fromRGB(255,255,255); SearchBox.Font=Enum.Font.Gotham
SearchBox.TextSize=12; SearchBox.Parent=Title
Instance.new("UICorner",SearchBox).CornerRadius=UDim.new(0,6)

local Sidebar=Instance.new("Frame")
Sidebar.Size=UDim2.new(0,110,1,-38); Sidebar.Position=UDim2.new(0,0,0,38)
Sidebar.BackgroundColor3=Color3.fromRGB(22,22,30); Sidebar.BorderSizePixel=0; Sidebar.Parent=Main
local SideList=Instance.new("UIListLayout",Sidebar)
SideList.Padding=UDim.new(0,4); SideList.SortOrder=Enum.SortOrder.LayoutOrder
Instance.new("UIPadding",Sidebar).PaddingTop=UDim.new(0,8)

local Content=Instance.new("Frame")
Content.Size=UDim2.new(1,-110,1,-38); Content.Position=UDim2.new(0,110,0,38)
Content.BackgroundTransparency=1; Content.Parent=Main

local Tabs={}
local function newTab(name)
    local page=Instance.new("ScrollingFrame")
    page.Size=UDim2.new(1,0,1,0); page.BackgroundTransparency=1
    page.BorderSizePixel=0; page.ScrollBarThickness=4
    page.ScrollBarImageColor3=Color3.fromRGB(100,100,150)
    page.CanvasSize=UDim2.new(0,0,0,0)
    page.AutomaticCanvasSize=Enum.AutomaticSize.Y
    page.Visible=false; page.Parent=Content
    local L=Instance.new("UIListLayout",page)
    L.Padding=UDim.new(0,6); L.SortOrder=Enum.SortOrder.LayoutOrder
    local P=Instance.new("UIPadding",page)
    P.PaddingTop=UDim.new(0,10); P.PaddingLeft=UDim.new(0,10)
    P.PaddingRight=UDim.new(0,10); P.PaddingBottom=UDim.new(0,10)
    Tabs[name]=page; return page
end
local function switchTab(name)
    for n,p in pairs(Tabs) do p.Visible=(n==name) end
    for _,c in ipairs(Sidebar:GetChildren()) do
        if c:IsA("TextButton") then
            c.BackgroundColor3=(c.Name==name) and Color3.fromRGB(50,50,80) or Color3.fromRGB(30,30,42)
        end
    end
end
local function addTabButton(name)
    local b=Instance.new("TextButton")
    b.Name=name; b.Size=UDim2.new(1,-12,0,32); b.Position=UDim2.new(0,6,0,0)
    b.BackgroundColor3=Color3.fromRGB(30,30,42); b.BorderSizePixel=0
    b.Text=name; b.TextColor3=Color3.fromRGB(220,220,255)
    b.Font=Enum.Font.GothamSemibold; b.TextSize=12; b.Parent=Sidebar
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
    b.MouseButton1Click:Connect(function() switchTab(name) end)
end
for _,n in ipairs({"Visual","Combat","Movement","Misc","Config","Keybinds"}) do
    newTab(n); addTabButton(n)
end

-- Drag
do
    local drag, ds, sp = false, nil, nil
    Title.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=true; ds=i.Position; sp=Main.Position
            i.Changed:Connect(function() if i.UserInputState==Enum.UserInputState.End then drag=false end end)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-ds
            Main.Position=UDim2.new(sp.X.Scale,sp.X.Offset+d.X,sp.Y.Scale,sp.Y.Offset+d.Y)
        end
    end)
end

-- ═══════════ UI BUILDERS ═══════════
local function makeRow(parent)
    local r=Instance.new("Frame")
    r.Size=UDim2.new(1,0,0,36); r.BackgroundColor3=Color3.fromRGB(28,28,40)
    r.BorderSizePixel=0; r.Parent=parent
    Instance.new("UICorner",r).CornerRadius=UDim.new(0,6)
    return r
end

local function makeToggle(parent,label,getter,setter)
    local r=makeRow(parent); r.Name="Row_"..label
    local l=Instance.new("TextLabel",r)
    l.Size=UDim2.new(0.55,0,1,0); l.Position=UDim2.new(0,10,0,0)
    l.BackgroundTransparency=1; l.Text=label
    l.TextColor3=Color3.fromRGB(230,230,245); l.Font=Enum.Font.Gotham
    l.TextSize=13; l.TextXAlignment=Enum.TextXAlignment.Left
    local b=Instance.new("TextButton",r)
    b.Size=UDim2.new(0,52,0,24); b.Position=UDim2.new(1,-62,0.5,-12)
    b.BackgroundColor3=getter() and Color3.fromRGB(0,160,80) or Color3.fromRGB(140,40,40)
    b.Text=getter() and "ON" or "OFF"; b.TextColor3=Color3.fromRGB(255,255,255)
    b.Font=Enum.Font.GothamBold; b.TextSize=11
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,5)
    local function refresh()
        local v=getter()
        b.Text=v and "ON" or "OFF"
        b.BackgroundColor3=v and Color3.fromRGB(0,160,80) or Color3.fromRGB(140,40,40)
    end
    b.MouseButton1Click:Connect(function()
        setter(not getter()); refresh()
        Notify(label..": "..(getter() and "ON" or "OFF"),
            getter() and Color3.fromRGB(0,200,100) or Color3.fromRGB(200,60,60),2)
    end)
    return r, refresh
end

local function makeSlider(parent,label,min,max,getter,setter)
    local r=makeRow(parent); r.Size=UDim2.new(1,0,0,48); r.Name="Row_"..label
    local l=Instance.new("TextLabel",r)
    l.Size=UDim2.new(1,-20,0,18); l.Position=UDim2.new(0,10,0,4)
    l.BackgroundTransparency=1; l.Text=label..": "..tostring(getter())
    l.TextColor3=Color3.fromRGB(230,230,245); l.Font=Enum.Font.Gotham
    l.TextSize=12; l.TextXAlignment=Enum.TextXAlignment.Left
    local bar=Instance.new("TextButton",r)
    bar.Size=UDim2.new(1,-20,0,8); bar.Position=UDim2.new(0,10,0,30)
    bar.BackgroundColor3=Color3.fromRGB(45,45,60); bar.Text=""; bar.AutoButtonColor=false
    Instance.new("UICorner",bar).CornerRadius=UDim.new(0,4)
    local fill=Instance.new("Frame",bar)
    fill.BackgroundColor3=Color3.fromRGB(90,150,255); fill.BorderSizePixel=0
    fill.Size=UDim2.new((getter()-min)/(max-min),0,1,0)
    Instance.new("UICorner",fill).CornerRadius=UDim.new(0,4)
    local dragging=false
    local function upd(x)
        local rel=math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
        local val=math.floor(min+(max-min)*rel+0.5)
        fill.Size=UDim2.new(rel,0,1,0)
        l.Text=label..": "..tostring(val)
        setter(val)
    end
    bar.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            dragging=true; upd(i.Position.X)
        end
    end)
    UIS.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            upd(i.Position.X)
        end
    end)
    UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
    return r
end

local function makeButton(parent,label,callback,color)
    local r=makeRow(parent); r.Name="Row_"..label
    local b=Instance.new("TextButton",r)
    b.Size=UDim2.new(1,-16,0,26); b.Position=UDim2.new(0,8,0.5,-13)
    b.BackgroundColor3=color or Color3.fromRGB(60,60,90); b.Text=label
    b.TextColor3=Color3.fromRGB(255,255,255); b.Font=Enum.Font.GothamSemibold
    b.TextSize=12
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,5)
    b.MouseButton1Click:Connect(callback)
    return r
end

local function makeDropdown(parent,label,items,getter,setter)
    local r=makeRow(parent); r.Name="Row_"..label
    local l=Instance.new("TextLabel",r)
    l.Size=UDim2.new(0.5,0,1,0); l.Position=UDim2.new(0,10,0,0)
    l.BackgroundTransparency=1; l.Text=label
    l.TextColor3=Color3.fromRGB(230,230,245); l.Font=Enum.Font.Gotham
    l.TextSize=12; l.TextXAlignment=Enum.TextXAlignment.Left
    local b=Instance.new("TextButton",r)
    b.Size=UDim2.new(0,140,0,24); b.Position=UDim2.new(1,-150,0.5,-12)
    b.BackgroundColor3=Color3.fromRGB(45,45,65); b.Text=tostring(getter())
    b.TextColor3=Color3.fromRGB(255,255,255); b.Font=Enum.Font.Gotham
    b.TextSize=11
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,5)
    local idx=1
    for i,v in ipairs(items) do if v==getter() then idx=i end end
    b.MouseButton1Click:Connect(function()
        idx=idx+1; if idx>#items then idx=1 end
        b.Text=items[idx]; setter(items[idx])
    end)
    return r
end

-- ═══════════ VISUAL: ESP / CHAMS / TRACERS ═══════════
local function cleanupPlayer(plr)
    if ESPData[plr] then
        for _,o in pairs(ESPData[plr]) do pcall(function() o:Destroy() end) end
        ESPData[plr]=nil
    end
    if TracerData[plr] then
        pcall(function() TracerData[plr]:Destroy() end); TracerData[plr]=nil
    end
end

local function buildVisuals(plr)
    if plr==LP then return end
    cleanupPlayer(plr)
    local char=plr.Character; if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart")
    local hum=char:FindFirstChildOfClass("Humanoid")
    if not root or not hum then return end

    local hl=Instance.new("Highlight")
    hl.FillColor=State.ESPColor; hl.OutlineColor=Color3.fromRGB(255,255,255)
    hl.FillTransparency=0.55; hl.OutlineTransparency=0.2
    hl.Adornee=char; hl.Parent=char

    local bb=Instance.new("BillboardGui")
    bb.Size=UDim2.new(0,220,0,46); bb.StudsOffset=Vector3.new(0,3.2,0)
    bb.AlwaysOnTop=true; bb.Adornee=root; bb.Parent=char

    local nL=Instance.new("TextLabel",bb)
    nL.Size=UDim2.new(1,0,0,22); nL.BackgroundTransparency=1
    nL.Text=plr.Name; nL.TextColor3=Color3.fromRGB(255,255,255)
    nL.TextStrokeTransparency=0; nL.Font=Enum.Font.GothamBold; nL.TextSize=14

    local iL=Instance.new("TextLabel",bb)
    iL.Size=UDim2.new(1,0,0,18); iL.Position=UDim2.new(0,0,0,22)
    iL.BackgroundTransparency=1; iL.Text=""
    iL.TextColor3=Color3.fromRGB(255,220,90); iL.TextStrokeTransparency=0
    iL.Font=Enum.Font.Gotham; iL.TextSize=12

    local tr=Instance.new("Frame")
    tr.BackgroundColor3=State.TracerColor; tr.BorderSizePixel=0
    tr.AnchorPoint=Vector2.new(0.5,1); tr.ZIndex=5
    tr.Parent=(gethui and gethui()) or SG
    TracerData[plr]=tr

    ESPData[plr]={Highlight=hl,BB=bb,Name=nL,Info=iL,Char=char}
end

local function updateVisuals()
    for plr,d in pairs(ESPData) do
        if d.Char and d.Char.Parent then
            local root=d.Char:FindFirstChild("HumanoidRootPart")
            local hum=d.Char:FindFirstChildOfClass("Humanoid")
            if root and hum then
                d.BB.Adornee=root
                d.Highlight.Enabled=State.ESP or State.Chams
                d.BB.Enabled=State.ESP
                if State.Chams then
                    d.Highlight.FillColor=State.ChamsColor
                    d.Highlight.FillTransparency=0.3
                elseif State.ESP then
                    d.Highlight.FillColor=State.ESPColor
                    d.Highlight.FillTransparency=0.55
                end
                local dist=math.floor((root.Position-Cam.CFrame.Position).Magnitude)
                local hp=math.floor(hum.Health); local mhp=math.floor(hum.MaxHealth)
                local txt=""
                if State.ShowHealth then txt="HP: "..hp.."/"..mhp end
                if State.ShowDistance then txt=txt..(txt~="" and " | " or "").."Dist: "..dist end
                d.Info.Text=txt
                if State.ESP and not State.Chams then
                    if hp<mhp*0.35 then d.Highlight.FillColor=Color3.fromRGB(255,0,0)
                    elseif hp<mhp*0.7 then d.Highlight.FillColor=Color3.fromRGB(255,170,0) end
                end
                local tr=TracerData[plr]
                if tr then
                    if State.Tracers and root then
                        local sp,onScr=Cam:WorldToViewportPoint(root.Position)
                        if onScr then
                            local from=Vector2.new(Cam.ViewportSize.X/2,Cam.ViewportSize.Y)
                            local to=Vector2.new(sp.X,sp.Y)
                            local mid=(from+to)/2
                            local len=(to-from).Magnitude
                            local ang=math.atan2(to.Y-from.Y,to.X-from.X)
                            tr.Visible=true
                            tr.Size=UDim2.new(0,len,0,2)
                            tr.Position=UDim2.new(0,mid.X,0,mid.Y)
                            tr.Rotation=math.deg(ang)+90
                            tr.BackgroundColor3=State.TracerColor
                        else tr.Visible=false end
                    else tr.Visible=false end
                end
            end
        else cleanupPlayer(plr) end
    end
end

RunService.RenderStepped:Connect(updateVisuals)

local function hookPlayer(plr)
    if plr==LP then return end
    plr.CharacterAdded:Connect(function() task.wait(0.8); buildVisuals(plr) end)
    if plr.Character then task.wait(0.5); buildVisuals(plr) end
end
for _,p in ipairs(Players:GetPlayers()) do hookPlayer(p) end
Players.PlayerAdded:Connect(hookPlayer)
Players.PlayerRemoving:Connect(cleanupPlayer)

-- ═══════════ FULLBRIGHT ═══════════
local function applyFullbright()
    if State.Fullbright then
        if not OriginalLighting.Ambient then
            OriginalLighting.Ambient=Lighting.Ambient
            OriginalLighting.OutdoorAmbient=Lighting.OutdoorAmbient
            OriginalLighting.Brightness=Lighting.Brightness
            OriginalLighting.FogEnd=Lighting.FogEnd
            OriginalLighting.ClockTime=Lighting.ClockTime
        end
        Lighting.Ambient=Color3.fromRGB(180,180,180)
        Lighting.OutdoorAmbient=Color3.fromRGB(180,180,180)
        Lighting.Brightness=3; Lighting.FogEnd=1e6; Lighting.ClockTime=14
    else
        if OriginalLighting.Ambient then
            Lighting.Ambient=OriginalLighting.Ambient
            Lighting.OutdoorAmbient=OriginalLighting.OutdoorAmbient
            Lighting.Brightness=OriginalLighting.Brightness
            Lighting.FogEnd=OriginalLighting.FogEnd
            Lighting.ClockTime=OriginalLighting.ClockTime
        end
    end
end

-- ═══════════ HUD ═══════════
local HudGui=Instance.new("ScreenGui")
HudGui.Name="VD_HUD"; HudGui.ResetOnSpawn=false
HudGui.Parent=(gethui and gethui()) or game:GetService("CoreGui")

local Hud=Instance.new("Frame",HudGui)
Hud.Size=UDim2.new(0,180,0,110); Hud.Position=UDim2.new(0,10,0,10)
Hud.BackgroundColor3=Color3.fromRGB(15,15,22); Hud.BackgroundTransparency=0.25
Hud.BorderSizePixel=0
Instance.new("UICorner",Hud).CornerRadius=UDim.new(0,8)

local HudLbl=Instance.new("TextLabel",Hud)
HudLbl.Size=UDim2.new(1,-16,1,-16); HudLbl.Position=UDim2.new(0,8,0,8)
HudLbl.BackgroundTransparency=1; HudLbl.TextColor3=Color3.fromRGB(220,255,220)
HudLbl.Font=Enum.Font.Code; HudLbl.TextSize=12
HudLbl.TextXAlignment=Enum.TextXAlignment.Left
HudLbl.TextYAlignment=Enum.TextYAlignment.Top; HudLbl.Text=""

local fpsCount, fpsTime, fpsVal = 0, 0, 0
RunService.RenderStepped:Connect(function(dt)
    fpsCount=fpsCount+1; fpsTime=fpsTime+dt
    if fpsTime>=1 then fpsVal=fpsCount; fpsCount=0; fpsTime=0 end
end)
local matchStart=tick()
task.spawn(function()
    while task.wait(0.25) do
        if not State.HUD then Hud.Visible=false; continue end
        Hud.Visible=true
        local char=LP.Character
        local root=char and char:FindFirstChild("HumanoidRootPart")
        local hum=char and char:FindFirstChildOfClass("Humanoid")
        local pos=root and root.Position or Vector3.zero
        local spd=root and math.floor(root.Velocity.Magnitude) or 0
        local hp=hum and math.floor(hum.Health) or 0
        local ping=math.floor(LP:GetNetworkPing()*1000)
        local elapsed=math.floor(tick()-matchStart)
        HudLbl.Text=string.format(
            "FPS: %d\nPing: %d ms\nHP: %d\nSpeed: %d\nXYZ: %d, %d, %d\nTime: %02d:%02d",
            fpsVal, ping, hp, spd, pos.X, pos.Y, pos.Z, math.floor(elapsed/60), elapsed%60)
    end
end)

-- ═══════════ RADAR ═══════════
local RadarGui=Instance.new("ScreenGui")
RadarGui.Name="VD_Radar"; RadarGui.ResetOnSpawn=false
RadarGui.Parent=(gethui and gethui()) or game:GetService("CoreGui")

local Radar=Instance.new("Frame",RadarGui)
Radar.Size=UDim2.new(0,180,0,180); Radar.Position=UDim2.new(1,-200,0,10)
Radar.BackgroundColor3=Color3.fromRGB(15,15,22); Radar.BackgroundTransparency=0.3
Radar.BorderSizePixel=0
Instance.new("UICorner",Radar).CornerRadius=UDim.new(0,90)

local RadarRange=250
task.spawn(function()
    while task.wait(0.1) do
        if not State.Radar then Radar.Visible=false; continue end
        Radar.Visible=true
        for _,c in ipairs(Radar:GetChildren()) do
            if c:IsA("Frame") and c.Name=="Dot" then c:Destroy() end
        end
        local char=LP.Character; local myRoot=char and char:FindFirstChild("HumanoidRootPart")
        if not myRoot then continue end
        local myPos=myRoot.Position
        for _,plr in ipairs(Players:GetPlayers()) do
            if plr==LP then continue end
            local r=plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
            if r then
                local rel=r.Position-myPos
                if Vector3.new(rel.X,0,rel.Z).Magnitude<=RadarRange then
                    local dot=Instance.new("Frame",Radar)
                    dot.Name="Dot"; dot.Size=UDim2.new(0,8,0,8)
                    dot.AnchorPoint=Vector2.new(0.5,0.5)
                    dot.BackgroundColor3=Color3.fromRGB(255,80,80); dot.BorderSizePixel=0
                    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
                    dot.Position=UDim2.new(rel.X/RadarRange*0.5+0.5,-4,rel.Z/RadarRange*0.5+0.5,-4)
                end
            end
        end
    end
end)

-- ═══════════ AUTO SKILL CHECK v3 (AGGRESSIVE) ═══════════
local SKILL_DEBUG = true

local allRemotes = {}
local function scanRemotes()
    for _,o in ipairs(game:GetDescendants()) do
        if o:IsA("RemoteEvent") or o:IsA("RemoteFunction") then
            allRemotes[o:GetFullName()] = o
        end
    end
end
scanRemotes()

game.DescendantAdded:Connect(function(o)
    if o:IsA("RemoteEvent") or o:IsA("RemoteFunction") then
        allRemotes[o:GetFullName()] = o
        if SKILL_DEBUG then print("[VD SkillCheck] NEW REMOTE:", o:GetFullName()) end
    end
end)

local BLACKLIST = {"kick","ban","chat","report","admin","mod","vote","anticheat","ac_","_ac"}
local function isBlacklisted(name)
    local l = name:lower()
    for _,w in ipairs(BLACKLIST) do if l:find(w) then return true end end
    return false
end

local KnownGuis = {}
local ActiveChecks = {}

local function isOurGui(obj)
    local p = obj
    for _=1,8 do
        if not p then break end
        if p.Name and (p.Name:find("VD_") or p.Name=="VD_Hub_v4") then return true end
        p = p.Parent
    end
    return false
end

local function looksLikeSkillCheck(obj)
    if not obj:IsA("GuiObject") then return false end
    if not obj.Visible then return false end
    if isOurGui(obj) then return false end
    local sz = obj.AbsoluteSize
    if sz.X < 30 or sz.Y < 30 then return false end
    if sz.X > 900 or sz.Y > 900 then return false end
    return true
end

local function scanForNewSkillGui()
    local pg = LP:FindFirstChild("PlayerGui")
    if not pg then return nil end
    local found = nil
    for _,d in ipairs(pg:GetDescendants()) do
        if d:IsA("GuiObject") then
            if not KnownGuis[d] then
                KnownGuis[d] = true
                if looksLikeSkillCheck(d) then
                    ActiveChecks[d] = tick(); found = d
                    if SKILL_DEBUG then
                        print(string.format("[VD SkillCheck] NEW GUI: %s | %dx%d | %s",
                            d:GetFullName(), d.AbsoluteSize.X, d.AbsoluteSize.Y, d.ClassName))
                    end
                end
            end
        end
    end
    for id in pairs(KnownGuis) do
        if typeof(id)=="Instance" and not id.Parent then
            KnownGuis[id]=nil; ActiveChecks[id]=nil
        end
    end
    return found
end

local function spamAllInputs()
    local keys = {Enum.KeyCode.Space,Enum.KeyCode.E,Enum.KeyCode.F,
                  Enum.KeyCode.Q,Enum.KeyCode.R,Enum.KeyCode.Enter,Enum.KeyCode.One}
    for _,k in ipairs(keys) do
        pcall(function()
            VIM:SendKeyEvent(true,k,false,game); task.wait(0.01)
            VIM:SendKeyEvent(false,k,false,game)
        end)
    end
    pcall(function()
        local cx=Cam.ViewportSize.X/2; local cy=Cam.ViewportSize.Y/2
        VIM:SendMouseButtonEvent(cx,cy,0,true,game,1); task.wait(0.01)
        VIM:SendMouseButtonEvent(cx,cy,0,false,game,1)
    end)
end

local function clickAllInteractive(gui)
    for _,c in ipairs(gui:GetDescendants()) do
        if c:IsA("ImageLabel") or c:IsA("ImageButton")
           or c:IsA("TextButton") or c:IsA("Frame") then
            if c.Visible and c.AbsoluteSize.X > 5 and c.AbsoluteSize.Y > 5 then
                pcall(function()
                    local pos = c.AbsolutePosition + c.AbsoluteSize/2
                    VIM:SendMouseButtonEvent(pos.X,pos.Y,0,true,game,1)
                    task.wait(0.008)
                    VIM:SendMouseButtonEvent(pos.X,pos.Y,0,false,game,1)
                end)
            end
        end
    end
end

local function fireAllRemotes()
    local count = 0
    for name,r in pairs(allRemotes) do
        if isBlacklisted(name) then continue end
        pcall(function()
            if r:IsA("RemoteEvent") then r:FireServer() else r:InvokeServer() end
        end)
        count = count + 1
    end
    return count
end

task.spawn(function()
    local lastFire = 0
    while task.wait(0.02) do
        if not State.AutoSkill then continue end
        local newGui = scanForNewSkillGui()
        local activeNow = false; local targetGui = nil
        for g,t in pairs(ActiveChecks) do
            if tick()-t < 1.5 and g.Parent and g.Visible then
                activeNow=true; targetGui=g; break
            end
        end
        if newGui then activeNow=true; targetGui=targetGui or newGui end
        if activeNow then
            if math.random(100) > State.SkillHitChance then continue end
            spamAllInputs()
            if targetGui then clickAllInteractive(targetGui) end
            if tick()-lastFire > 0.15 then
                local n = fireAllRemotes()
                lastFire = tick()
                if SKILL_DEBUG then
                    print("[VD SkillCheck] Fired "..n.." remotes. GUI:",
                        targetGui and targetGui:GetFullName() or "nil")
                end
            end
        end
    end
end)

_G.VD_DumpRemotes = function()
    print("═══════ ALL REMOTES ═══════")
    local list={}; for n,_ in pairs(allRemotes) do table.insert(list,n) end
    table.sort(list); for _,n in ipairs(list) do print(" • "..n) end
    print("═══════ TOTAL: "..#list.." ═══════")
end
_G.VD_DumpGui = function()
    print("═══════ PlayerGui TREE ═══════")
    local pg=LP:FindFirstChild("PlayerGui")
    if pg then
        for _,d in ipairs(pg:GetDescendants()) do
            if d:IsA("GuiObject") and d.Visible then
                print(string.format(" • %s [%s] %dx%d",
                    d:GetFullName(), d.ClassName, d.AbsoluteSize.X, d.AbsoluteSize.Y))
            end
        end
    end
    print("═══════ END ═══════")
end

-- ═══════════ INF STAMINA / ABILITIES / HEAL ═══════════
local healRemotes={}
for _,o in ipairs(game:GetDescendants()) do
    if o:IsA("RemoteEvent") or o:IsA("RemoteFunction") then
        local n=o.Name:lower()
        if n:find("heal") or n:find("regen") or n:find("health") or n:find("revive") then
            table.insert(healRemotes,o)
        end
    end
end

task.spawn(function()
    while task.wait(0.08) do
        -- Infinite Heal
        if State.InfiniteHeal then
            local c=LP.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
            if h and h.Health>0 and h.Health<h.MaxHealth then h.Health=h.MaxHealth end
            for _,r in ipairs(healRemotes) do
                pcall(function()
                    if r:IsA("RemoteEvent") then r:FireServer() else r:InvokeServer() end
                end)
            end
        end
        -- Inf Stamina
        if State.InfStamina then
            local c=LP.Character
            if c then
                for _,o in ipairs(c:GetDescendants()) do
                    if o:IsA("NumberValue") and (o.Name:lower():find("stam") or o.Name:lower():find("endur")) then
                        pcall(function() o.Value=o.Value+1000 end)
                    end
                end
            end
        end
        -- Inf Abilities / CD
        if State.InfAbilities or State.InstantCooldown then
            local pg=LP:FindFirstChild("PlayerGui")
            if pg then
                for _,o in ipairs(pg:GetDescendants()) do
                    if o:IsA("ImageLabel") or o:IsA("Frame") or o:IsA("TextButton") then
                        local n=o.Name:lower()
                        if n:find("cooldown") or n:find("cd") or n:find("ability") then
                            pcall(function()
                                local f=o:FindFirstChildOfClass("Frame")
                                if f then f.Size=UDim2.new(0,0,0,0) end
                            end)
                        end
                    end
                end
            end
        end
    end
end)

-- ═══════════ SPEED ═══════════
RunService.Heartbeat:Connect(function()
    if not State.Speed then return end
    local c=LP.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
    if h then
        if State.SpeedMode=="Legit" then
            h.WalkSpeed=h.WalkSpeed+(State.WalkSpeed-h.WalkSpeed)*0.08
        else
            h.WalkSpeed=State.WalkSpeed
        end
    end
end)

-- ═══════════ TP SUITE ═══════════
local function tweenTP(target)
    local c=LP.Character; if not c then return end
    local r=c:FindFirstChild("HumanoidRootPart"); if not r then return end
    if typeof(target)=="Vector3" then
        local start=r.CFrame; local goal=CFrame.new(target)
        local dist=(start.Position-target).Magnitude
        local dur=math.clamp(dist/200,0.15,0.8)
        local obj={t=0}
        local tw=TweenService:Create(obj,TweenInfo.new(dur,Enum.EasingStyle.Quad),{t=1})
        local conn
        conn=RunService.RenderStepped:Connect(function()
            r.CFrame=start:Lerp(goal,obj.t)
        end)
        tw.Completed:Connect(function() conn:Disconnect() end)
        tw:Play()
    elseif typeof(target)=="CFrame" then
        r.CFrame=target
    end
end

local function tpToPlayer(name)
    for _,p in ipairs(Players:GetPlayers()) do
        if p.Name:lower():find(name:lower()) and p~=LP and p.Character then
            local r=p.Character:FindFirstChild("HumanoidRootPart")
            if r then tweenTP(r.Position+Vector3.new(0,3,0)); return end
        end
    end
    Notify("Игрок не найден: "..name,Color3.fromRGB(255,80,80),2)
end

UIS.InputBegan:Connect(function(i,g)
    if g then return end
    if clickTP and i.UserInputType==Enum.UserInputType.MouseButton1 then
        local m=UIS:GetMouseLocation()
        local ray=Cam:ViewportPointToRay(m.X,m.Y)
        local params=RaycastParams.new()
        params.FilterDescendantsInstances={LP.Character}
        local res=workspace:Raycast(ray.Origin,ray.Direction*5000,params)
        if res then tweenTP(res.Position+Vector3.new(0,3,0)) end
    end
end)

-- ═══════════ FLY / NOCLIP ═══════════
local flyBV,flyBG,flyConn
local function stopFly()
    if flyConn then flyConn:Disconnect() flyConn=nil end
    if flyBV then flyBV:Destroy() flyBV=nil end
    if flyBG then flyBG:Destroy() flyBG=nil end
    local c=LP.Character; local h=c and c:FindFirstChildOfClass("Humanoid")
    if h then h.PlatformStand=false end
end
local function startFly()
    stopFly()
    local c=LP.Character; if not c then return end
    local r=c:FindFirstChild("HumanoidRootPart"); local h=c:FindFirstChildOfClass("Humanoid")
    if not r or not h then return end
    flyBV=Instance.new("BodyVelocity")
    flyBV.MaxForce=Vector3.new(1e5,1e5,1e5); flyBV.Velocity=Vector3.zero; flyBV.Parent=r
    flyBG=Instance.new("BodyGyro")
    flyBG.MaxTorque=Vector3.new(1e5,1e5,1e5); flyBG.P=1e4
    flyBG.CFrame=r.CFrame; flyBG.Parent=r
    h.PlatformStand=true
    flyConn=RunService.RenderStepped:Connect(function()
        if not State.Fly or not r.Parent then stopFly() return end
        local d=Vector3.zero; local cf=Cam.CFrame
        if UIS:IsKeyDown(Enum.KeyCode.W) then d+=cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.S) then d-=cf.LookVector end
        if UIS:IsKeyDown(Enum.KeyCode.A) then d-=cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.D) then d+=cf.RightVector end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then d+=Vector3.new(0,1,0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then d-=Vector3.new(0,1,0) end
        if d.Magnitude>0 then d=d.Unit end
        flyBV.Velocity=d*State.FlySpeed
        flyBG.CFrame=cf
    end)
end

local noclipConn
local function startNoclip()
    if noclipConn then noclipConn:Disconnect() end
    noclipConn=RunService.Stepped:Connect(function()
        if not State.Noclip then return end
        local c=LP.Character; if not c then return end
        for _,p in ipairs(c:GetDescendants()) do
            if p:IsA("BasePart") and p.CanCollide then p.CanCollide=false end
        end
    end)
end

-- ═══════════ ANTI-CHEAT / LEGIT / AUTO-DISABLE / AUTOPLAY ═══════════
task.spawn(function()
    if not State.AntiCheat then return end
    local mt=getrawmetatable and getrawmetatable(game)
    if mt then
        local old=mt.__namecall
        setreadonly(mt,false)
        mt.__namecall=function(self,...)
            local m=getnamecallmethod()
            if m=="Kick" and self==LP then
                Notify("Anti-Kick: блок",Color3.fromRGB(255,200,0),3); return
            end
            return old(self,...)
        end
        setreadonly(mt,true)
    end
end)

local function applyLegit()
    if State.LegitMode then
        State.FlySpeed=math.min(State.FlySpeed,40)
        State.WalkSpeed=math.min(State.WalkSpeed,35)
        State.SkillHitChance=math.min(State.SkillHitChance,80)
    end
end

task.spawn(function()
    local function hookChat(msg)
        if not State.AutoDisableOnReport then return end
        local l=msg:lower()
        if l:find("report") or l:find("cheater") or l:find("hacker") or l:find("hack") then
            State.ESP=false; State.Chams=false; State.Tracers=false
            State.Fly=false; State.Noclip=false; State.Speed=false; State.AutoSkill=false
            stopFly()
            Notify("⚠ Auto-Disable: репорт!",Color3.fromRGB(255,60,60),4)
        end
    end
    LP.Chatted:Connect(hookChat)
    for _,p in ipairs(Players:GetPlayers()) do
        if p~=LP then p.Chatted:Connect(hookChat) end
    end
    Players.PlayerAdded:Connect(function(p) p.Chatted:Connect(hookChat) end)
end)

task.spawn(function()
    while task.wait(0.5) do
        if not State.AutoPlay then continue end
        local c=LP.Character; local r=c and c:FindFirstChild("HumanoidRootPart")
        if not r then continue end
        local best,bd=nil,math.huge
        for _,o in ipairs(workspace:GetDescendants()) do
            if o:IsA("BasePart") and (o.Name:lower():find("gen") or o.Name:lower():find("objective")) then
                local d=(o.Position-r.Position).Magnitude
                if d<bd then bd=d; best=o end
            end
        end
        if best and bd>8 then
            local dir=(best.Position-r.Position).Unit
            r.Velocity=Vector3.new(dir.X*30,r.Velocity.Y,dir.Z*30)
        end
    end
end)

-- ═══════════ PANIC KEY ═══════════
UIS.InputBegan:Connect(function(i,g)
    if g then return end
    if i.KeyCode==State.PanicKey then
        State.ESP=false; State.Chams=false; State.Tracers=false
        State.Fly=false; State.Noclip=false; State.Speed=false
        State.AutoSkill=false; State.InfiniteHeal=false; State.Fullbright=false
        stopFly(); applyFullbright(); Main.Visible=false
        Notify("🚨 PANIC",Color3.fromRGB(255,0,0),3)
    end
    if i.KeyCode==State.MenuKey then
        Main.Visible=not Main.Visible
    end
end)

-- ═══════════ STATS ═══════════
local Stats = {matches=0, deaths=0, kills=0}
LP.CharacterAdded:Connect(function()
    Stats.matches=Stats.matches+1
    task.wait(0.5)
    local h=LP.Character and LP.Character:FindFirstChildOfClass("Humanoid")
    if h then h.Died:Connect(function() Stats.deaths=Stats.deaths+1 end) end
end)

local function saveStats()
    if writefile then pcall(function() writefile("vd_stats.json",HttpService:JSONEncode(Stats)) end) end
end
if readfile and isfile and isfile("vd_stats.json") then
    pcall(function()
        local d=HttpService:JSONDecode(readfile("vd_stats.json"))
        Stats.matches=d.matches or 0; Stats.deaths=d.deaths or 0; Stats.kills=d.kills or 0
    end)
end
task.spawn(function() while task.wait(10) do saveStats() end end)

-- ═══════════ CONFIG SAVE/LOAD ═══════════
local function saveConfig()
    local d={}
    for k,v in pairs(State) do
        if typeof(v)=="EnumItem" then d[k]=v.Name
        elseif typeof(v)=="Color3" then d[k]={v.R,v.G,v.B}
        else d[k]=v end
    end
    if writefile then
        pcall(function() writefile("vd_config.json",HttpService:JSONEncode(d)) end)
        Notify("✅ Config saved",Color3.fromRGB(0,200,100),2)
    end
end
local function loadConfig()
    if readfile and isfile and isfile("vd_config.json") then
        local ok,d=pcall(function() return HttpService:JSONDecode(readfile("vd_config.json")) end)
        if ok and d then
            for k,v in pairs(d) do
                if State[k]~=nil and (type(State[k])=="boolean" or type(State[k])=="number" or type(State[k])=="string") then
                    State[k]=v
                end
            end
            Notify("✅ Config loaded",Color3.fromRGB(0,200,100),2)
            return
        end
    end
    Notify("⚠ Config не найден",Color3.fromRGB(255,180,0),2)
end

local function loadScriptByUrl(url)
    pcall(function()
        loadstring(game:HttpGet(url))()
        Notify("✅ Script loaded",Color3.fromRGB(0,200,100),2)
    end)
end

-- ═══════════ BUILD TABS ═══════════
local V=Tabs.Visual
makeToggle(V,"ESP",function() return State.ESP end,function(v) State.ESP=v end)
makeToggle(V,"Chams (неон)",function() return State.Chams end,function(v) State.Chams=v end)
makeToggle(V,"Tracers",function() return State.Tracers end,function(v) State.Tracers=v end)
makeToggle(V,"Fullbright / No Fog",function() return State.Fullbright end,function(v) State.Fullbright=v; applyFullbright() end)
makeToggle(V,"HUD (FPS/Ping/Coords)",function() return State.HUD end,function(v) State.HUD=v end)
makeToggle(V,"Radar",function() return State.Radar end,function(v) State.Radar=v end)
makeToggle(V,"Show Health",function() return State.ShowHealth end,function(v) State.ShowHealth=v end)
makeToggle(V,"Show Distance",function() return State.ShowDistance end,function(v) State.ShowDistance=v end)

local C=Tabs.Combat
makeToggle(C,"Auto Skill Check v3",function() return State.AutoSkill end,function(v) State.AutoSkill=v end)
makeSlider(C,"Hit Chance %",0,100,function() return State.SkillHitChance end,function(v) State.SkillHitChance=v end)
makeToggle(C,"Infinite Stamina",function() return State.InfStamina end,function(v) State.InfStamina=v end)
makeToggle(C,"Infinite Abilities",function() return State.InfAbilities end,function(v) State.InfAbilities=v end)
makeToggle(C,"Instant Cooldown",function() return State.InstantCooldown end,function(v) State.InstantCooldown=v end)
makeToggle(C,"Infinite Heal",function() return State.InfiniteHeal end,function(v) State.InfiniteHeal=v end)

local M=Tabs.Movement
makeToggle(M,"Speed Hack",function() return State.Speed end,function(v) State.Speed=v end)
makeSlider(M,"WalkSpeed",16,300,function() return State.WalkSpeed end,function(v) State.WalkSpeed=v end)
makeDropdown(M,"Speed Mode",{"Blatant","Legit"},function() return State.SpeedMode end,function(v) State.SpeedMode=v end)
makeToggle(M,"Fly",function() return State.Fly end,function(v) State.Fly=v; if v then startFly() else stopFly() end end)
makeSlider(M,"Fly Speed",20,300,function() return State.FlySpeed end,function(v) State.FlySpeed=v end)
makeToggle(M,"Noclip",function() return State.Noclip end,function(v) State.Noclip=v; if v then startNoclip() end end)

local tpRow=makeRow(M)
local tpBox=Instance.new("TextBox",tpRow)
tpBox.Size=UDim2.new(1,-120,0,26); tpBox.Position=UDim2.new(0,8,0.5,-13)
tpBox.BackgroundColor3=Color3.fromRGB(45,45,65); tpBox.BorderSizePixel=0
tpBox.PlaceholderText="Имя игрока..."; tpBox.Text=""
tpBox.TextColor3=Color3.fromRGB(255,255,255); tpBox.Font=Enum.Font.Gotham
tpBox.TextSize=12
Instance.new("UICorner",tpBox).CornerRadius=UDim.new(0,5)
local tpBtn=Instance.new("TextButton",tpRow)
tpBtn.Size=UDim2.new(0,100,0,26); tpBtn.Position=UDim2.new(1,-108,0.5,-13)
tpBtn.BackgroundColor3=Color3.fromRGB(90,60,180); tpBtn.Text="TP → Player"
tpBtn.TextColor3=Color3.fromRGB(255,255,255); tpBtn.Font=Enum.Font.GothamBold
tpBtn.TextSize=11
Instance.new("UICorner",tpBtn).CornerRadius=UDim.new(0,5)
tpBtn.MouseButton1Click:Connect(function() tpToPlayer(tpBox.Text) end)

makeButton(M,"💾 Save Position",function()
    local c=LP.Character; local r=c and c:FindFirstChild("HumanoidRootPart")
    if r then SavedPos=r.CFrame; Notify("Сохранено",Color3.fromRGB(100,200,255),2) end
end,Color3.fromRGB(60,120,200))

makeButton(M,"⏪ Load Position",function()
    if SavedPos then tweenTP(SavedPos); Notify("TP",Color3.fromRGB(100,200,255),2)
    else Notify("Нет позиции",Color3.fromRGB(255,80,80),2) end
end,Color3.fromRGB(60,120,200))

makeButton(M,"🖱 Click TP (toggle)",function()
    clickTP=not clickTP
    Notify("Click TP: "..(clickTP and "ON" or "OFF"),Color3.fromRGB(150,100,255),2)
end,Color3.fromRGB(120,60,200))

local Mi=Tabs.Misc
makeToggle(Mi,"Legit Mode",function() return State.LegitMode end,function(v) State.LegitMode=v; applyLegit() end)
makeToggle(Mi,"Anti-Cheat Layer",function() return State.AntiCheat end,function(v) State.AntiCheat=v end)
makeToggle(Mi,"Auto-Disable on Report",function() return State.AutoDisableOnReport end,function(v) State.AutoDisableOnReport=v end)
makeToggle(Mi,"Auto-Play Bot",function() return State.AutoPlay end,function(v) State.AutoPlay=v end)

makeButton(Mi,"📊 Show Stats",function()
    Notify(string.format("Matches: %d | Deaths: %d",Stats.matches,Stats.deaths),Color3.fromRGB(100,200,255),4)
end,Color3.fromRGB(60,100,180))

makeButton(Mi,"🎯 Test Notification",function()
    Notify("Тест!",Color3.fromRGB(255,180,0),3)
end,Color3.fromRGB(180,120,40))

makeButton(Mi,"🔍 Dump Remotes (Console)",function()
    _G.VD_DumpRemotes()
    Notify("Смотри консоль (F9)",Color3.fromRGB(100,200,255),3)
end,Color3.fromRGB(60,100,180))

makeButton(Mi,"🖼 Dump GUI (Console)",function()
    _G.VD_DumpGui()
    Notify("Смотри консоль (F9)",Color3.fromRGB(100,200,255),3)
end,Color3.fromRGB(60,100,180))

local slRow=makeRow(Mi)
local slBox=Instance.new("TextBox",slRow)
slBox.Size=UDim2.new(1,-90,0,26); slBox.Position=UDim2.new(0,8,0.5,-13)
slBox.BackgroundColor3=Color3.fromRGB(45,45,65); slBox.BorderSizePixel=0
slBox.PlaceholderText="Script URL (raw)"; slBox.Text=""
slBox.TextColor3=Color3.fromRGB(255,255,255); slBox.Font=Enum.Font.Gotham
slBox.TextSize=11
Instance.new("UICorner",slBox).CornerRadius=UDim.new(0,5)
local slBtn=Instance.new("TextButton",slRow)
slBtn.Size=UDim2.new(0,72,0,26); slBtn.Position=UDim2.new(1,-80,0.5,-13)
slBtn.BackgroundColor3=Color3.fromRGB(60,140,90); slBtn.Text="Load"
slBtn.TextColor3=Color3.fromRGB(255,255,255); slBtn.Font=Enum.Font.GothamBold
slBtn.TextSize=11
Instance.new("UICorner",slBtn).CornerRadius=UDim.new(0,5)
slBtn.MouseButton1Click:Connect(function() loadScriptByUrl(slBox.Text) end)

local Cf=Tabs.Config
makeButton(Cf,"💾 Save Config",saveConfig,Color3.fromRGB(60,140,90))
makeButton(Cf,"📂 Load Config",loadConfig,Color3.fromRGB(60,120,200))
makeButton(Cf,"🔄 Reset All",function()
    State.ESP=false; State.Chams=false; State.Tracers=false; State.Fly=false
    State.Noclip=false; State.Speed=false; State.AutoSkill=false
    State.Fullbright=false; applyFullbright(); stopFly()
    Notify("Сброшено",Color3.fromRGB(255,180,0),2)
end,Color3.fromRGB(180,80,80))

local Kb=Tabs.Keybinds
local function addBind(label,keyName)
    local r=makeRow(Kb); r.Name="Row_"..label
    local l=Instance.new("TextLabel",r)
    l.Size=UDim2.new(0.6,0,1,0); l.Position=UDim2.new(0,10,0,0)
    l.BackgroundTransparency=1; l.Text=label
    l.TextColor3=Color3.fromRGB(230,230,245); l.Font=Enum.Font.Gotham
    l.TextSize=13; l.TextXAlignment=Enum.TextXAlignment.Left
    local b=Instance.new("TextButton",r)
    b.Size=UDim2.new(0,80,0,24); b.Position=UDim2.new(1,-90,0.5,-12)
    b.BackgroundColor3=Color3.fromRGB(55,55,80)
    b.Text=State[keyName] and State[keyName].Name or "?"
    b.TextColor3=Color3.fromRGB(255,220,90); b.Font=Enum.Font.GothamBold
    b.TextSize=11
    Instance.new("UICorner",b).CornerRadius=UDim.new(0,5)
    local binding=false
    b.MouseButton1Click:Connect(function() binding=true; b.Text="..." end)
    UIS.InputBegan:Connect(function(i,g)
        if g then return end
        if binding and i.UserInputType==Enum.UserInputType.Keyboard then
            State[keyName]=i.KeyCode; b.Text=i.KeyCode.Name; binding=false
            Notify("Бинд "..label.." → "..i.KeyCode.Name,Color3.fromRGB(100,200,255),2)
        end
    end)
end
addBind("Toggle Menu","MenuKey")
addBind("Panic Key","PanicKey")

-- ═══════════ SEARCH ═══════════
SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
    local q=SearchBox.Text:lower()
    for _,page in pairs(Tabs) do
        for _,row in ipairs(page:GetChildren()) do
            if row:IsA("Frame") then
                local lbl=row:FindFirstChildOfClass("TextLabel")
                if lbl then row.Visible=(q=="" or lbl.Text:lower():find(q)) end
            end
        end
    end
end)

-- ═══════════ INIT ═══════════
switchTab("Visual")
Notify("⚡ VD Hub v4 loaded!",Color3.fromRGB(100,200,255),3)
if SKILL_DEBUG then
    print("[VD] v4 loaded. Use _G.VD_DumpRemotes() / _G.VD_DumpGui()")
end

LP.CharacterAdded:Connect(function()
    task.wait(1)
    if State.Fly then startFly() end
    if State.Noclip then startNoclip() end
end)

print("[VD Hub v4] Ready. RightShift=menu, Delete=panic")
