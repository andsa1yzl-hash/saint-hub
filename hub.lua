local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local CONFIG_FILE = "CerberusDuels_Config.json"

local C = {
    bg       = Color3.fromRGB(4, 10, 6),
    green    = Color3.fromRGB(34, 197, 94),
    greenDim = Color3.fromRGB(16, 80, 38),
    danger   = Color3.fromRGB(239, 68, 68),
    textDim  = Color3.fromRGB(80, 180, 100),
    cardBg   = Color3.fromRGB(6, 14, 8),
    cardBgOn = Color3.fromRGB(10, 30, 14),
}

local Connections = {}
local BoostSpeed         = 30
local StealSpeed         = 60
local STEAL_RADIUS       = 20
local STEAL_DURATION     = 0.2
local SpinSpeed          = 30
local VELOCITY_SPEED     = 59.2
local SECOND_PHASE_SPEED = 29.6
local BASE_STOP          = 1.35
local MIN_STOP           = 0.65
local NEXT_POINT_BIAS    = 0.45
local SMOOTH_FACTOR      = 0.12

local speedBoostEnabled  = false
local spamBatEnabled     = false
local unwalkEnabled      = false
local optimizerEnabled   = false
local spinBotEnabled     = false
local batAimbotEnabled   = false
local autoStealEnabled   = false
local stealSpeedEnabled  = false
local antiRagdollEnabled = false
local floatEnabled       = false
local autoRightOn        = false
local autoLeftOn         = false

local ToggleStates = {
    speedBoost  = false, spamBat    = false, unwalk      = false,
    optimizer   = false, spinBot    = false, batAimbot   = false,
    autoSteal   = false, stealSpeed = false, antiRagdoll = false,
    float       = false, autoRight  = false, autoLeft    = false,
}

-- ═══════════════════════════════════════════════════════════════
--  SCREEN GUI
-- ═══════════════════════════════════════════════════════════════
local sg = Instance.new("ScreenGui")
sg.Name = "CERBERUS_DUELS"
sg.ResetOnSpawn = false
sg.IgnoreGuiInset = true
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = Player.PlayerGui

-- ═══════════════════════════════════════════════════════════════
--  PROGRESS BAR
-- ═══════════════════════════════════════════════════════════════
local ProgressBarFill, ProgressLabel, ProgressPercentLabel

local ProgressBarContainer = Instance.new("Frame", sg)
ProgressBarContainer.Name = "progressBar"
ProgressBarContainer.Size = UDim2.new(0, 280, 0, 36)
ProgressBarContainer.Position = UDim2.new(0.5, -140, 1, -80)
ProgressBarContainer.BackgroundColor3 = Color3.fromRGB(6, 16, 8)
ProgressBarContainer.BorderSizePixel = 0
ProgressBarContainer.ClipsDescendants = true
ProgressBarContainer.ZIndex = 8
ProgressBarContainer.Active = false
Instance.new("UICorner", ProgressBarContainer).CornerRadius = UDim.new(0, 8)
local pStroke = Instance.new("UIStroke", ProgressBarContainer)
pStroke.Thickness = 1.5 pStroke.Color = Color3.fromRGB(20,90,40) pStroke.Transparency = 0.2

local topAccent = Instance.new("Frame", ProgressBarContainer)
topAccent.Size = UDim2.new(1,0,0,2) topAccent.BackgroundColor3 = C.green
topAccent.BackgroundTransparency = 0.3 topAccent.BorderSizePixel = 0 topAccent.ZIndex = 9

local pDot = Instance.new("Frame", ProgressBarContainer)
pDot.Size = UDim2.new(0,7,0,7) pDot.Position = UDim2.new(0,10,0.35,-3)
pDot.BackgroundColor3 = C.green pDot.BorderSizePixel = 0 pDot.ZIndex = 10
Instance.new("UICorner", pDot).CornerRadius = UDim.new(1,0)

ProgressLabel = Instance.new("TextLabel", ProgressBarContainer)
ProgressLabel.Size = UDim2.new(0,120,0,22) ProgressLabel.Position = UDim2.new(0,22,0,4)
ProgressLabel.BackgroundTransparency = 1 ProgressLabel.Text = "READY"
ProgressLabel.TextColor3 = Color3.fromRGB(220,255,225) ProgressLabel.Font = Enum.Font.GothamBold
ProgressLabel.TextSize = 12 ProgressLabel.TextXAlignment = Enum.TextXAlignment.Left
ProgressLabel.TextYAlignment = Enum.TextYAlignment.Center ProgressLabel.ZIndex = 10

ProgressPercentLabel = Instance.new("TextLabel", ProgressBarContainer)
ProgressPercentLabel.Size = UDim2.new(0,40,0,22) ProgressPercentLabel.Position = UDim2.new(0,22,0,4)
ProgressPercentLabel.BackgroundTransparency = 1 ProgressPercentLabel.Text = ""
ProgressPercentLabel.TextColor3 = C.green ProgressPercentLabel.Font = Enum.Font.GothamBold
ProgressPercentLabel.TextSize = 11 ProgressPercentLabel.TextXAlignment = Enum.TextXAlignment.Left
ProgressPercentLabel.TextYAlignment = Enum.TextYAlignment.Center ProgressPercentLabel.ZIndex = 11

local radiusBox = Instance.new("TextBox", ProgressBarContainer)
radiusBox.Size = UDim2.new(0,38,0,20) radiusBox.Position = UDim2.new(1,-90,0.5,-10)
radiusBox.BackgroundColor3 = Color3.fromRGB(10,24,12) radiusBox.Text = "20"
radiusBox.TextColor3 = C.green radiusBox.Font = Enum.Font.GothamBold radiusBox.TextSize = 11
radiusBox.TextXAlignment = Enum.TextXAlignment.Center radiusBox.BorderSizePixel = 0
radiusBox.ClearTextOnFocus = false radiusBox.ZIndex = 10
Instance.new("UICorner", radiusBox).CornerRadius = UDim.new(0,5)
local rStroke = Instance.new("UIStroke", radiusBox) rStroke.Color = C.green rStroke.Transparency = 0.5

local radiusHint = Instance.new("TextLabel", radiusBox)
radiusHint.Size = UDim2.new(1,0,0,9) radiusHint.Position = UDim2.new(0,0,1,1)
radiusHint.BackgroundTransparency = 1 radiusHint.Text = "radius"
radiusHint.TextColor3 = Color3.fromRGB(60,140,75) radiusHint.Font = Enum.Font.Gotham
radiusHint.TextSize = 8 radiusHint.TextXAlignment = Enum.TextXAlignment.Center radiusHint.ZIndex = 10

local durationBox = Instance.new("TextBox", ProgressBarContainer)
durationBox.Size = UDim2.new(0,38,0,20) durationBox.Position = UDim2.new(1,-46,0.5,-10)
durationBox.BackgroundColor3 = Color3.fromRGB(10,24,12) durationBox.Text = "1.3"
durationBox.TextColor3 = C.green durationBox.Font = Enum.Font.GothamBold durationBox.TextSize = 11
durationBox.TextXAlignment = Enum.TextXAlignment.Center durationBox.BorderSizePixel = 0
durationBox.ClearTextOnFocus = false durationBox.ZIndex = 10
Instance.new("UICorner", durationBox).CornerRadius = UDim.new(0,5)
local dStroke = Instance.new("UIStroke", durationBox) dStroke.Color = C.green dStroke.Transparency = 0.5

local durationHint = Instance.new("TextLabel", durationBox)
durationHint.Size = UDim2.new(1,0,0,9) durationHint.Position = UDim2.new(0,0,1,1)
durationHint.BackgroundTransparency = 1 durationHint.Text = "dur"
durationHint.TextColor3 = Color3.fromRGB(60,140,75) durationHint.Font = Enum.Font.Gotham
durationHint.TextSize = 8 durationHint.TextXAlignment = Enum.TextXAlignment.Center durationHint.ZIndex = 10

local pTrack = Instance.new("Frame", ProgressBarContainer)
pTrack.Size = UDim2.new(1,0,0,3) pTrack.Position = UDim2.new(0,0,1,-3)
pTrack.BackgroundColor3 = Color3.fromRGB(15,40,20) pTrack.ZIndex = 9 pTrack.BorderSizePixel = 0

ProgressBarFill = Instance.new("Frame", pTrack)
ProgressBarFill.Size = UDim2.new(0,0,1,0) ProgressBarFill.BackgroundColor3 = C.green
ProgressBarFill.ZIndex = 10 ProgressBarFill.BorderSizePixel = 0
local fillGrad = Instance.new("UIGradient", ProgressBarFill)
fillGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(34,197,94)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(100,255,140)),
})

radiusBox.FocusLost:Connect(function()
    local n = tonumber(radiusBox.Text)
    if n then STEAL_RADIUS = math.clamp(math.floor(n),1,500) radiusBox.Text = tostring(STEAL_RADIUS)
    else radiusBox.Text = tostring(STEAL_RADIUS) end
end)
durationBox.FocusLost:Connect(function()
    local n = tonumber(durationBox.Text)
    if n then STEAL_DURATION = math.max(0.05, math.floor(n*10+0.5)/10) durationBox.Text = string.format("%.1f",STEAL_DURATION)
    else durationBox.Text = string.format("%.1f",STEAL_DURATION) end
end)

task.spawn(function()
    while sg.Parent do
        if ProgressLabel.Text ~= "READY" then
            TweenService:Create(pDot,TweenInfo.new(0.4,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{BackgroundTransparency=0.6}):Play()
            task.wait(0.4)
            TweenService:Create(pDot,TweenInfo.new(0.4,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut),{BackgroundTransparency=0}):Play()
        else pDot.BackgroundTransparency = 0 end
        task.wait(0.4)
    end
end)

-- ═══════════════════════════════════════════════════════════════
--  TITLE BAR
-- ═══════════════════════════════════════════════════════════════
local titleBar = Instance.new("Frame", sg)
titleBar.Size = UDim2.new(0,220,0,32) titleBar.AnchorPoint = Vector2.new(0.5,0)
titleBar.Position = UDim2.new(0.5,0,0,48) titleBar.BackgroundColor3 = Color3.fromRGB(5,12,6)
titleBar.BorderSizePixel = 0 titleBar.Active = false titleBar.ZIndex = 5
Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0,10)
local tbs = Instance.new("UIStroke", titleBar) tbs.Thickness = 1.5 tbs.Color = C.green tbs.Transparency = 0.3

local titleBarLabel = Instance.new("TextLabel", titleBar)
titleBarLabel.Size = UDim2.new(1,0,1,0) titleBarLabel.BackgroundTransparency = 1
titleBarLabel.Text = "SAINT HUB" titleBarLabel.TextColor3 = Color3.fromRGB(220,255,225)
titleBarLabel.Font = Enum.Font.GothamBold titleBarLabel.TextSize = 14
titleBarLabel.TextXAlignment = Enum.TextXAlignment.Center titleBarLabel.ZIndex = 6

task.spawn(function()
    while sg.Parent do
        local offset = math.sin(tick()*1.6*math.pi*2)*5
        titleBar.Position = UDim2.new(0.5,0,0,48+offset)
        task.wait(0.016)
    end
end)

-- ═══════════════════════════════════════════════════════════════
--  SIDE MENU BUTTON
-- ═══════════════════════════════════════════════════════════════
local menuBtn = Instance.new("TextButton", sg)
menuBtn.Size = UDim2.new(0,28,0,90) menuBtn.Position = UDim2.new(0,6,0.5,-45)
menuBtn.BackgroundColor3 = Color3.fromRGB(5,14,7) menuBtn.BorderSizePixel = 0
menuBtn.Text = "" menuBtn.AutoButtonColor = false menuBtn.Active = true menuBtn.ZIndex = 10
Instance.new("UICorner", menuBtn).CornerRadius = UDim.new(0,10)
local menuStroke = Instance.new("UIStroke", menuBtn)
menuStroke.Thickness = 1.5 menuStroke.Color = C.green menuStroke.Transparency = 0.35

local menuLbl = Instance.new("TextLabel", menuBtn)
menuLbl.Size = UDim2.new(0,80,0,20) menuLbl.AnchorPoint = Vector2.new(0.5,0.5)
menuLbl.Position = UDim2.new(0.5,0,0.5,0) menuLbl.BackgroundTransparency = 1
menuLbl.Text = "☰ MENU" menuLbl.TextColor3 = C.green menuLbl.Font = Enum.Font.GothamBold
menuLbl.TextSize = 11 menuLbl.Rotation = -90 menuLbl.ZIndex = 11

for i = 1,3 do
    local d = Instance.new("Frame", menuBtn)
    d.Size = UDim2.new(0,4,0,4) d.Position = UDim2.new(0.5,-2,0,6+(i-1)*7)
    d.BackgroundColor3 = C.green d.BackgroundTransparency = 0.5
    d.BorderSizePixel = 0 d.ZIndex = 11
    Instance.new("UICorner", d).CornerRadius = UDim.new(1,0)
end

menuBtn.MouseEnter:Connect(function()
    TweenService:Create(menuStroke,TweenInfo.new(0.2),{Transparency=0}):Play()
    TweenService:Create(menuBtn,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(10,28,14)}):Play()
end)
menuBtn.MouseLeave:Connect(function()
    TweenService:Create(menuStroke,TweenInfo.new(0.2),{Transparency=0.35}):Play()
    TweenService:Create(menuBtn,TweenInfo.new(0.2),{BackgroundColor3=Color3.fromRGB(5,14,7)}):Play()
end)

local mbDrag,mbMouse,mbPos = false,nil,nil
menuBtn.InputBegan:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
        mbDrag=true mbMouse=Vector2.new(inp.Position.X,inp.Position.Y) mbPos=menuBtn.Position
    end
end)
UserInputService.InputChanged:Connect(function(inp)
    if not mbDrag then return end
    if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then
        local d=Vector2.new(inp.Position.X,inp.Position.Y)-mbMouse
        menuBtn.Position=UDim2.new(mbPos.X.Scale,mbPos.X.Offset+d.X,mbPos.Y.Scale,mbPos.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(inp)
    if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
        mbDrag=false
    end
end)

-- ═══════════════════════════════════════════════════════════════
--  FEATURES PANEL
-- ═══════════════════════════════════════════════════════════════
local PANEL_W=300 local PANEL_H=440 local HEADER_H=44

local panel = Instance.new("Frame", sg)
panel.Name = "MainPanel" panel.Size = UDim2.new(0,PANEL_W,0,0)
panel.AnchorPoint = Vector2.new(0.5,0.5) panel.Position = UDim2.new(0.5,0,0.5,0)
panel.BackgroundColor3 = C.bg panel.BorderSizePixel = 0
panel.Visible = false panel.ZIndex = 8 panel.ClipsDescendants = true
Instance.new("UICorner", panel).CornerRadius = UDim.new(0,12)

local panelStroke = Instance.new("UIStroke", panel) panelStroke.Thickness = 1.5
local strokeGrad = Instance.new("UIGradient", panelStroke)
strokeGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0,   Color3.fromRGB(34,197,94)),
    ColorSequenceKeypoint.new(0.2, Color3.fromRGB(0,0,0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100,255,140)),
    ColorSequenceKeypoint.new(0.8, Color3.fromRGB(0,0,0)),
    ColorSequenceKeypoint.new(1,   Color3.fromRGB(34,197,94)),
})
task.spawn(function()
    local r=0
    while sg.Parent do r=(r+3)%360 strokeGrad.Rotation=r task.wait(0.02) end
end)

local header = Instance.new("Frame", panel)
header.Size = UDim2.new(1,0,0,HEADER_H) header.BackgroundTransparency = 1
header.BorderSizePixel = 0 header.ZIndex = 10

local titleLbl = Instance.new("TextLabel", header)
titleLbl.Size = UDim2.new(1,0,1,0) titleLbl.BackgroundTransparency = 1
titleLbl.Text = "Features" titleLbl.TextColor3 = Color3.fromRGB(220,255,225)
titleLbl.Font = Enum.Font.GothamBold titleLbl.TextSize = 15
titleLbl.TextXAlignment = Enum.TextXAlignment.Center titleLbl.ZIndex = 11

local closeBtn = Instance.new("TextButton", header)
closeBtn.Size = UDim2.new(0,28,0,28) closeBtn.Position = UDim2.new(1,-36,0.5,-14)
closeBtn.BackgroundTransparency = 1 closeBtn.Text = "×"
closeBtn.TextColor3 = C.textDim closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 20 closeBtn.ZIndex = 11
closeBtn.MouseEnter:Connect(function() closeBtn.TextColor3 = C.danger end)
closeBtn.MouseLeave:Connect(function() closeBtn.TextColor3 = C.textDim end)

local contentFrame = Instance.new("ScrollingFrame", panel)
contentFrame.Size = UDim2.new(1,-12,1,-HEADER_H-6)
contentFrame.Position = UDim2.new(0,6,0,HEADER_H+3)
contentFrame.BackgroundTransparency = 1 contentFrame.BorderSizePixel = 0
contentFrame.ScrollBarThickness = 2 contentFrame.ScrollBarImageColor3 = C.green
contentFrame.CanvasSize = UDim2.new(0,0,0,0)
contentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y contentFrame.ZIndex = 10

local listLayout = Instance.new("UIListLayout", contentFrame)
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
listLayout.SortOrder = Enum.SortOrder.LayoutOrder listLayout.Padding = UDim.new(0,4)

local contentPad = Instance.new("UIPadding", contentFrame)
contentPad.PaddingTop = UDim.new(0,3) contentPad.PaddingBottom = UDim.new(0,6)

-- ═══════════════════════════════════════════════════════════════
--  FEATURE LOGIC
-- ═══════════════════════════════════════════════════════════════
local savedAnimations={} local spinBAV=nil
local isStealing=false local stealStartTime=nil
local progressConn=nil local stealSpeedConn=nil local StealData={}

local function getMovementDirection()
    local c=Player.Character if not c then return Vector3.zero end
    local hum=c:FindFirstChildOfClass("Humanoid")
    return hum and hum.MoveDirection or Vector3.zero
end
local function startSpeedBoost()
    if Connections.speed then return end
    Connections.speed=RunService.Heartbeat:Connect(function()
        if not speedBoostEnabled then return end
        pcall(function()
            local c=Player.Character if not c then return end
            local h=c:FindFirstChild("HumanoidRootPart") if not h then return end
            local md=getMovementDirection()
            if md.Magnitude>0.1 then
                h.AssemblyLinearVelocity=Vector3.new(md.X*BoostSpeed,h.AssemblyLinearVelocity.Y,md.Z*BoostSpeed)
            end
        end)
    end)
end
local function stopSpeedBoost()
    if Connections.speed then Connections.speed:Disconnect() Connections.speed=nil end
end

local function startUnwalk()
    local c=Player.Character if not c then return end
    local hum=c:FindFirstChildOfClass("Humanoid")
    if hum then for _,t in ipairs(hum:GetPlayingAnimationTracks()) do t:Stop() end end
    local anim=c:FindFirstChild("Animate")
    if anim then savedAnimations.Animate=anim:Clone() anim:Destroy() end
end
local function stopUnwalk()
    local c=Player.Character
    if c and savedAnimations.Animate then
        savedAnimations.Animate:Clone().Parent=c savedAnimations.Animate=nil
    end
end

local lastBatSwing=0 local BAT_SWING_COOLDOWN=0.12
local SlapList={
    {1,"Bat"},{2,"Slap"},{3,"Iron Slap"},{4,"Gold Slap"},{5,"Diamond Slap"},
    {6,"Emerald Slap"},{7,"Ruby Slap"},{8,"Dark Matter Slap"},{9,"Flame Slap"},
    {10,"Nuclear Slap"},{11,"Galaxy Slap"},{12,"Glitched Slap"}
}
local function findBat()
    local c=Player.Character if not c then return nil end
    local bp=Player:FindFirstChildOfClass("Backpack")
    for _,ch in ipairs(c:GetChildren()) do
        if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
    end
    if bp then for _,ch in ipairs(bp:GetChildren()) do
        if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end
    end end
    for _,i in ipairs(SlapList) do
        local t=c:FindFirstChild(i[2]) or (bp and bp:FindFirstChild(i[2]))
        if t then return t end
    end
    return nil
end
local function startSpamBat()
    if Connections.spamBat then return end
    Connections.spamBat=RunService.Heartbeat:Connect(function()
        if not spamBatEnabled then return end
        local c=Player.Character if not c then return end
        local bat=findBat() if not bat then return end
        if bat.Parent~=c then bat.Parent=c end
        local now=tick()
        if now-lastBatSwing<BAT_SWING_COOLDOWN then return end
        lastBatSwing=now pcall(function() bat:Activate() end)
    end)
end
local function stopSpamBat()
    if Connections.spamBat then Connections.spamBat:Disconnect() Connections.spamBat=nil end
end

local originalTransparency={} local xrayEnabled=false
local function enableOptimizer()
    if getgenv and getgenv().OPTIMIZER_ACTIVE then return end
    if getgenv then getgenv().OPTIMIZER_ACTIVE=true end
    pcall(function()
        settings().Rendering.QualityLevel=Enum.QualityLevel.Level01
        game:GetService("Lighting").GlobalShadows=false
        game:GetService("Lighting").Brightness=3
        game:GetService("Lighting").FogEnd=9e9
    end)
    pcall(function()
        for _,obj in ipairs(workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then obj:Destroy()
                elseif obj:IsA("BasePart") then obj.CastShadow=false obj.Material=Enum.Material.Plastic end
            end)
        end
    end)
    xrayEnabled=true
    pcall(function()
        for _,obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("BasePart") and obj.Anchored and
               (obj.Name:lower():find("base") or (obj.Parent and obj.Parent.Name:lower():find("base"))) then
                originalTransparency[obj]=obj.LocalTransparencyModifier
                obj.LocalTransparencyModifier=0.85
            end
        end
    end)
end
local function disableOptimizer()
    if getgenv then getgenv().OPTIMIZER_ACTIVE=false end
    if xrayEnabled then
        for part,value in pairs(originalTransparency) do
            if part then part.LocalTransparencyModifier=value end
        end
        originalTransparency={} xrayEnabled=false
    end
end

local function startSpinBot()
    local c=Player.Character if not c then return end
    local hrp=c:FindFirstChild("HumanoidRootPart") if not hrp then return end
    if spinBAV then spinBAV:Destroy() spinBAV=nil end
    for _,v in pairs(hrp:GetChildren()) do if v.Name=="SpinBAV" then v:Destroy() end end
    spinBAV=Instance.new("BodyAngularVelocity")
    spinBAV.Name="SpinBAV" spinBAV.MaxTorque=Vector3.new(0,math.huge,0)
    spinBAV.AngularVelocity=Vector3.new(0,SpinSpeed,0) spinBAV.Parent=hrp
end
local function stopSpinBot()
    if spinBAV then spinBAV:Destroy() spinBAV=nil end
    local c=Player.Character
    if c then
        local hrp=c:FindFirstChild("HumanoidRootPart")
        if hrp then for _,v in pairs(hrp:GetChildren()) do if v.Name=="SpinBAV" then v:Destroy() end end end
    end
end

local BAT_MOVE_SPEED=56.5 local BAT_ENGAGE_RANGE=20 local BAT_LOOP_TIME=0.3
local lastEquipTick_bat=0 local lastUseTick_bat=0
local lookConn_bat,lookAttachment_bat,lookAlign_bat=nil,nil,nil
local BAT_LOOK_DISTANCE=50
local function findNearestEnemy_bat(myHRP)
    local closest,minDist=nil,math.huge
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=Player and plr.Character then
            local eh=plr.Character:FindFirstChild("HumanoidRootPart")
            local hum=plr.Character:FindFirstChildOfClass("Humanoid")
            if eh and hum and hum.Health>0 then
                local d=(eh.Position-myHRP.Position).Magnitude
                if d<minDist then minDist=d closest=eh end
            end
        end
    end
    return closest,minDist
end
local function closestLookTarget_bat(myHRP)
    local nearest,shortest=nil,BAT_LOOK_DISTANCE
    for _,plr in ipairs(Players:GetPlayers()) do
        if plr~=Player and plr.Character then
            local eh=plr.Character:FindFirstChild("HumanoidRootPart")
            if eh then
                local d=(myHRP.Position-eh.Position).Magnitude
                if d<shortest then shortest=d nearest=eh end
            end
        end
    end
    return nearest
end
local function startLookAt_bat(myHRP,myHum)
    myHum.AutoRotate=false
    lookAttachment_bat=Instance.new("Attachment",myHRP)
    lookAlign_bat=Instance.new("AlignOrientation")
    lookAlign_bat.Attachment0=lookAttachment_bat
    lookAlign_bat.Mode=Enum.OrientationAlignmentMode.OneAttachment
    lookAlign_bat.MaxTorque=Vector3.new(math.huge,math.huge,math.huge)
    lookAlign_bat.Responsiveness=1000 lookAlign_bat.RigidityEnabled=true lookAlign_bat.Parent=myHRP
    lookConn_bat=RunService.RenderStepped:Connect(function()
        if not myHRP or not lookAlign_bat then return end
        local tgt=closestLookTarget_bat(myHRP) if not tgt then return end
        local lookPos=Vector3.new(tgt.Position.X,myHRP.Position.Y,tgt.Position.Z)
        lookAlign_bat.CFrame=CFrame.lookAt(myHRP.Position,lookPos)
    end)
end
local function stopLookAt_bat(myHum)
    if lookConn_bat then lookConn_bat:Disconnect() lookConn_bat=nil end
    if lookAlign_bat then lookAlign_bat:Destroy() lookAlign_bat=nil end
    if lookAttachment_bat then lookAttachment_bat:Destroy() lookAttachment_bat=nil end
    if myHum then myHum.AutoRotate=true end
end
local function startBatAimbot()
    batAimbotEnabled=true
    local c=Player.Character if not c then return end
    local myHRP=c:FindFirstChild("HumanoidRootPart")
    local myHum=c:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then return end
    startLookAt_bat(myHRP,myHum)
end
local function stopBatAimbot()
    batAimbotEnabled=false
    local c=Player.Character
    local myHum=c and c:FindFirstChildOfClass("Humanoid")
    stopLookAt_bat(myHum)
    local myHRP=c and c:FindFirstChild("HumanoidRootPart")
    if myHRP then myHRP.AssemblyLinearVelocity=Vector3.zero end
end
RunService.Heartbeat:Connect(function()
    if not batAimbotEnabled then return end
    local c=Player.Character if not c then return end
    local myHRP=c:FindFirstChild("HumanoidRootPart")
    local myHum=c:FindFirstChildOfClass("Humanoid")
    if not myHRP or not myHum then return end
    myHRP.CanCollide=false
    local target,distance=findNearestEnemy_bat(myHRP)
    if not target then return end
    local moveDir=(target.Position-myHRP.Position).Unit
    myHRP.AssemblyLinearVelocity=moveDir*BAT_MOVE_SPEED
    if distance<=BAT_ENGAGE_RANGE then
        local bat=findBat()
        if bat then
            if tick()-lastEquipTick_bat>=BAT_LOOP_TIME then
                if bat.Parent~=c then myHum:EquipTool(bat) end
                lastEquipTick_bat=tick()
            end
            if tick()-lastUseTick_bat>=BAT_LOOP_TIME then
                pcall(function() bat:Activate() end) lastUseTick_bat=tick()
            end
        end
    end
end)

local antiRagdollMode=nil local ragdollConnections={} local cachedCharData={}
local arIsBoosting=false local AR_BOOST_SPEED=400 local AR_DEFAULT_SPEED=16
local function arCacheCharacterData()
    local char=Player.Character if not char then return false end
    local hum=char:FindFirstChildOfClass("Humanoid")
    local root=char:FindFirstChild("HumanoidRootPart")
    if not hum or not root then return false end
    cachedCharData={character=char,humanoid=hum,root=root} return true
end
local function arDisconnectAll()
    for _,conn in ipairs(ragdollConnections) do pcall(function() conn:Disconnect() end) end
    ragdollConnections={}
end
local function arIsRagdolled()
    if not cachedCharData.humanoid then return false end
    local state=cachedCharData.humanoid:GetState()
    local rs={[Enum.HumanoidStateType.Physics]=true,[Enum.HumanoidStateType.Ragdoll]=true,[Enum.HumanoidStateType.FallingDown]=true}
    if rs[state] then return true end
    local endTime=Player:GetAttribute("RagdollEndTime")
    if endTime and (endTime-workspace:GetServerTimeNow())>0 then return true end
    return false
end
local function arForceExitRagdoll()
    if not cachedCharData.humanoid or not cachedCharData.root then return end
    pcall(function() Player:SetAttribute("RagdollEndTime",workspace:GetServerTimeNow()) end)
    for _,desc in ipairs(cachedCharData.character:GetDescendants()) do
        if desc:IsA("BallSocketConstraint") or
           (desc:IsA("Attachment") and desc.Name:find("RagdollAttachment")) then
            desc:Destroy()
        end
    end
    if not arIsBoosting then
        arIsBoosting=true cachedCharData.humanoid.WalkSpeed=AR_BOOST_SPEED
    end
    if cachedCharData.humanoid.Health>0 then
        cachedCharData.humanoid:ChangeState(Enum.HumanoidStateType.Running)
    end
    cachedCharData.root.Anchored=false
end
local function arHeartbeatLoop()
    while antiRagdollMode=="v1" do
        task.wait()
        local r=arIsRagdolled()
        if r then arForceExitRagdoll()
        elseif arIsBoosting and not r then
            arIsBoosting=false
            if cachedCharData.humanoid then cachedCharData.humanoid.WalkSpeed=AR_DEFAULT_SPEED end
        end
    end
end
local function startAntiRagdoll()
    if antiRagdollMode=="v1" then return end
    if not arCacheCharacterData() then return end
    antiRagdollMode="v1"
    local camConn=RunService.RenderStepped:Connect(function()
        local cam=workspace.CurrentCamera
        if cam and cachedCharData.humanoid then cam.CameraSubject=cachedCharData.humanoid end
    end)
    table.insert(ragdollConnections,camConn)
    local respawnConn=Player.CharacterAdded:Connect(function()
        arIsBoosting=false task.wait(0.5) arCacheCharacterData()
    end)
    table.insert(ragdollConnections,respawnConn)
    task.spawn(arHeartbeatLoop)
end
local function stopAntiRagdoll()
    antiRagdollMode=nil
    if arIsBoosting and cachedCharData.humanoid then cachedCharData.humanoid.WalkSpeed=AR_DEFAULT_SPEED end
    arIsBoosting=false arDisconnectAll() cachedCharData={}
end

local floatConn=nil local FLOAT_TARGET_HEIGHT=10 local floatOriginY=nil
local _G_stopFloatVisual=nil
local function startFloat()
    local c=Player.Character if not c then return end
    local hrp=c:FindFirstChild("HumanoidRootPart") if not hrp then return end
    if floatConn then floatConn:Disconnect() floatConn=nil end
    floatOriginY=hrp.Position.Y+FLOAT_TARGET_HEIGHT
    local floatStartTime=tick() local floatDescending=false
    floatConn=RunService.Heartbeat:Connect(function()
        if not floatEnabled then return end
        local c2=Player.Character if not c2 then return end
        local h=c2:FindFirstChild("HumanoidRootPart") if not h then return end
        local hum2=c2:FindFirstChildOfClass("Humanoid")
        if tick()-floatStartTime>=4 then floatDescending=true end
        local currentY=h.Position.Y local vertVel
        if floatDescending then
            vertVel=-20
            if currentY<=floatOriginY-FLOAT_TARGET_HEIGHT+0.5 then
                h.AssemblyLinearVelocity=Vector3.zero floatEnabled=false
                if floatConn then floatConn:Disconnect() floatConn=nil end
                if _G_stopFloatVisual then _G_stopFloatVisual() end return
            end
        else
            local diff=floatOriginY-currentY
            if diff>0.3 then vertVel=math.clamp(diff*8,5,50)
            elseif diff<-0.3 then vertVel=math.clamp(diff*8,-50,-5)
            else vertVel=0 end
        end
        local moveDir=hum2 and hum2.MoveDirection or Vector3.zero
        local hx=moveDir.Magnitude>0.1 and moveDir.X*BoostSpeed or 0
        local hz=moveDir.Magnitude>0.1 and moveDir.Z*BoostSpeed or 0
        h.AssemblyLinearVelocity=Vector3.new(hx,vertVel,hz)
    end)
end
local function stopFloat()
    floatEnabled=false
    if floatConn then floatConn:Disconnect() floatConn=nil end
    local c=Player.Character
    if c then local hrp=c:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.AssemblyLinearVelocity=Vector3.zero end end
end

-- ─── DROP + DAMAGE PREVENTION ────────────────────────────────────────────────
local dropActive = false
local dmgPrevConn = nil
local function startDamagePrevention()
    if dmgPrevConn then return end
    dmgPrevConn = RunService.Heartbeat:Connect(function()
        pcall(function()
            local c = Player.Character if not c then return end
            local hum = c:FindFirstChildOfClass("Humanoid") if not hum then return end
            if hum.Health < hum.MaxHealth then hum.Health = hum.MaxHealth end
        end)
    end)
end
local function stopDamagePrevention()
    if dmgPrevConn then dmgPrevConn:Disconnect() dmgPrevConn = nil end
end

local function doDrop()
    if dropActive then return end
    dropActive = true
    local char = Player.Character if not char then dropActive=false return end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    if not humanoid or not root then dropActive=false return end

    startDamagePrevention()

    local originalY = root.Position.Y
    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    root.AssemblyLinearVelocity = Vector3.new(
        root.AssemblyLinearVelocity.X, 100, root.AssemblyLinearVelocity.Z)

    local start = tick()
    while tick()-start < 0.2 do
        local pos = root.Position
        root.CFrame = CFrame.new(pos.X, originalY, pos.Z)
            * CFrame.Angles(0, root.Orientation.Y * math.pi/180, 0)
        task.wait()
    end

    task.delay(0.5, function()
        stopDamagePrevention()
        dropActive = false
    end)
end

local function isMyPlotByName(pn)
    local plots=workspace:FindFirstChild("Plots") if not plots then return false end
    local plot=plots:FindFirstChild(pn) if not plot then return false end
    local sign=plot:FindFirstChild("PlotSign")
    if sign then
        local yb=sign:FindFirstChild("YourBase")
        if yb and yb:IsA("BillboardGui") then return yb.Enabled==true end
    end
    return false
end
local function findNearestPrompt()
    local c=Player.Character
    local h=c and c:FindFirstChild("HumanoidRootPart") if not h then return nil end
    local plots=workspace:FindFirstChild("Plots") if not plots then return nil end
    local np,nd,nn=nil,math.huge,nil
    for _,plot in ipairs(plots:GetChildren()) do
        if isMyPlotByName(plot.Name) then continue end
        local podiums=plot:FindFirstChild("AnimalPodiums") if not podiums then continue end
        for _,pod in ipairs(podiums:GetChildren()) do
            pcall(function()
                local base=pod:FindFirstChild("Base")
                local spawn=base and base:FindFirstChild("Spawn")
                if spawn then
                    local dist=(spawn.Position-h.Position).Magnitude
                    if dist<nd and dist<=STEAL_RADIUS then
                        local att=spawn:FindFirstChild("PromptAttachment")
                        if att then
                            for _,ch in ipairs(att:GetChildren()) do
                                if ch:IsA("ProximityPrompt") then np,nd,nn=ch,dist,pod.Name break end
                            end
                        end
                    end
                end
            end)
        end
    end
    return np,nd,nn
end
local function resetProgressBar()
    if ProgressLabel then ProgressLabel.Text="READY" ProgressLabel.Visible=true end
    if ProgressPercentLabel then ProgressPercentLabel.Text="" end
    if ProgressBarFill then ProgressBarFill.Size=UDim2.new(0,0,1,0) end
end
local function executeSteal(prompt,name)
    if isStealing then return end
    if not StealData[prompt] then
        StealData[prompt]={hold={},trigger={},ready=true}
        pcall(function()
            if getconnections then
                for _,c in ipairs(getconnections(prompt.PromptButtonHoldBegan)) do
                    if c.Function then table.insert(StealData[prompt].hold,c.Function) end
                end
                for _,c in ipairs(getconnections(prompt.Triggered)) do
                    if c.Function then table.insert(StealData[prompt].trigger,c.Function) end
                end
            end
        end)
    end
    local data=StealData[prompt]
    if not data.ready then return end
    data.ready=false isStealing=true stealStartTime=tick()
    if ProgressLabel then ProgressLabel.Text=name or "STEALING..." end
    if ProgressBarFill then ProgressBarFill.Size=UDim2.new(0,0,1,0) end
    if ProgressPercentLabel then ProgressPercentLabel.Text="" end
    if progressConn then progressConn:Disconnect() progressConn=nil end
    if stealSpeedEnabled then
        if stealSpeedConn then stealSpeedConn:Disconnect() stealSpeedConn=nil end
        stealSpeedConn=RunService.Heartbeat:Connect(function()
            if not isStealing then stealSpeedConn:Disconnect() stealSpeedConn=nil return end
            pcall(function()
                local c=Player.Character if not c then return end
                local h=c:FindFirstChild("HumanoidRootPart") if not h then return end
                local hum=c:FindFirstChildOfClass("Humanoid")
                local md=hum and hum.MoveDirection or Vector3.zero
                if md.Magnitude>0.1 then
                    h.AssemblyLinearVelocity=Vector3.new(md.X*StealSpeed,h.AssemblyLinearVelocity.Y,md.Z*StealSpeed)
                end
            end)
        end)
    end
    progressConn=RunService.Heartbeat:Connect(function()
        if not isStealing then
            if progressConn then progressConn:Disconnect() progressConn=nil end return
        end
        local prog=math.clamp((tick()-stealStartTime)/STEAL_DURATION,0,1)
        if ProgressBarFill then ProgressBarFill.Size=UDim2.new(prog,0,1,0) end
        if ProgressPercentLabel then ProgressPercentLabel.Text=math.floor(prog*100).."%%" end
    end)
    task.spawn(function()
        for _,f in ipairs(data.hold) do task.spawn(f) end
        task.wait(STEAL_DURATION)
        for _,f in ipairs(data.trigger) do task.spawn(f) end
        if progressConn then progressConn:Disconnect() progressConn=nil end
        if stealSpeedConn then stealSpeedConn:Disconnect() stealSpeedConn=nil end
        isStealing=false resetProgressBar() data.ready=true
    end)
end
local function startAutoSteal()
    if Connections.autoSteal then return end
    Connections.autoSteal=RunService.Heartbeat:Connect(function()
        if not autoStealEnabled or isStealing then return end
        local p,_,n=findNearestPrompt()
        if p then executeSteal(p,n) end
    end)
end
local function stopAutoSteal()
    if Connections.autoSteal then Connections.autoSteal:Disconnect() Connections.autoSteal=nil end
    isStealing=false
    if progressConn then progressConn:Disconnect() end
    resetProgressBar()
end

-- ═══════════════════════════════════════════════════════════════
--  CARD FACTORY
-- ═══════════════════════════════════════════════════════════════
local CardSetVisuals={}

local function createCard(labelText,hasGear,onToggle,gearLabel,gearDefault,gearOnChange)
    local wrapper=Instance.new("Frame",contentFrame)
    wrapper.Size=UDim2.new(1,0,0,0) wrapper.AutomaticSize=Enum.AutomaticSize.Y
    wrapper.BackgroundTransparency=1 wrapper.BorderSizePixel=0 wrapper.ZIndex=11

    local wrapLayout=Instance.new("UIListLayout",wrapper)
    wrapLayout.FillDirection=Enum.FillDirection.Vertical
    wrapLayout.HorizontalAlignment=Enum.HorizontalAlignment.Center
    wrapLayout.SortOrder=Enum.SortOrder.LayoutOrder wrapLayout.Padding=UDim.new(0,0)

    local card=Instance.new("Frame",wrapper)
    card.Size=UDim2.new(1,0,0,44) card.BackgroundColor3=C.cardBg
    card.BorderSizePixel=0 card.ZIndex=11 card.LayoutOrder=1
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,10)

    local stroke=Instance.new("UIStroke",card)
    stroke.Thickness=1.2 stroke.Color=C.greenDim stroke.Transparency=0.3

    local dot=Instance.new("Frame",card)
    dot.Size=UDim2.new(0,8,0,8) dot.Position=UDim2.new(0,10,0.5,-4)
    dot.BackgroundColor3=C.greenDim dot.BorderSizePixel=0 dot.ZIndex=12
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)

    local lbl=Instance.new("TextLabel",card)
    lbl.Size=UDim2.new(1,hasGear and -58 or -24,1,0) lbl.Position=UDim2.new(0,24,0,0)
    lbl.BackgroundTransparency=1 lbl.Text=labelText
    lbl.TextColor3=Color3.fromRGB(180,230,190) lbl.Font=Enum.Font.GothamBold
    lbl.TextSize=13 lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.ZIndex=12

    local isOn=false

    if hasGear then
        local gearBtn=Instance.new("TextButton",card)
        gearBtn.Size=UDim2.new(0,28,0,28) gearBtn.Position=UDim2.new(1,-34,0.5,-14)
        gearBtn.BackgroundTransparency=1 gearBtn.Text="⚙"
        gearBtn.TextColor3=C.greenDim gearBtn.Font=Enum.Font.GothamBold
        gearBtn.TextSize=16 gearBtn.ZIndex=13

        local inputPopup=Instance.new("Frame",wrapper)
        inputPopup.Size=UDim2.new(1,0,0,36) inputPopup.BackgroundColor3=Color3.fromRGB(6,16,8)
        inputPopup.BorderSizePixel=0 inputPopup.Visible=false inputPopup.ZIndex=11 inputPopup.LayoutOrder=2
        Instance.new("UICorner",inputPopup).CornerRadius=UDim.new(0,7)
        local ipS=Instance.new("UIStroke",inputPopup) ipS.Color=C.greenDim ipS.Thickness=1.2 ipS.Transparency=0.5

        local ipLbl=Instance.new("TextLabel",inputPopup)
        ipLbl.Size=UDim2.new(0.6,0,1,0) ipLbl.Position=UDim2.new(0,10,0,0)
        ipLbl.BackgroundTransparency=1 ipLbl.Text=gearLabel or "Speed"
        ipLbl.TextColor3=Color3.fromRGB(140,200,155) ipLbl.Font=Enum.Font.GothamBold
        ipLbl.TextSize=12 ipLbl.TextXAlignment=Enum.TextXAlignment.Left ipLbl.ZIndex=12

        local speedInput=Instance.new("TextBox",inputPopup)
        speedInput.Size=UDim2.new(0,60,0,24) speedInput.Position=UDim2.new(1,-68,0.5,-12)
        speedInput.BackgroundColor3=Color3.fromRGB(10,22,12) speedInput.Text=tostring(gearDefault or BoostSpeed)
        speedInput.TextColor3=C.green speedInput.Font=Enum.Font.GothamBold
        speedInput.TextSize=13 speedInput.ClearTextOnFocus=false speedInput.ZIndex=12
        Instance.new("UICorner",speedInput).CornerRadius=UDim.new(0,5)
        Instance.new("UIStroke",speedInput).Color=C.greenDim

        speedInput.FocusLost:Connect(function()
            local n=tonumber(speedInput.Text)
            if n then
                if gearOnChange then
                    local cl=math.clamp(math.floor(n),1,300)
                    speedInput.Text=tostring(cl) gearOnChange(cl)
                else
                    BoostSpeed=math.clamp(math.floor(n),1,200) speedInput.Text=tostring(BoostSpeed)
                end
            else speedInput.Text=tostring(gearDefault or BoostSpeed) end
        end)

        local popupOpen=false
        gearBtn.MouseButton1Click:Connect(function()
            popupOpen=not popupOpen inputPopup.Visible=popupOpen
            gearBtn.TextColor3=popupOpen and C.green or C.greenDim
        end)
    end

    local clickBtn=Instance.new("TextButton",card)
    clickBtn.Size=UDim2.new(1,hasGear and -36 or 0,1,0)
    clickBtn.BackgroundTransparency=1 clickBtn.Text="" clickBtn.ZIndex=14

    clickBtn.MouseButton1Click:Connect(function()
        isOn=not isOn
        TweenService:Create(dot,TweenInfo.new(0.2),{BackgroundColor3=isOn and C.green or C.greenDim}):Play()
        TweenService:Create(stroke,TweenInfo.new(0.2),{Color=isOn and C.green or C.greenDim,Transparency=isOn and 0 or 0.3}):Play()
        TweenService:Create(card,TweenInfo.new(0.2),{BackgroundColor3=isOn and C.cardBgOn or C.cardBg}):Play()
        if onToggle then onToggle(isOn) end
    end)
    clickBtn.MouseEnter:Connect(function()
        TweenService:Create(lbl,TweenInfo.new(0.15),{TextColor3=Color3.fromRGB(200,255,210)}):Play()
    end)
    clickBtn.MouseLeave:Connect(function()
        TweenService:Create(lbl,TweenInfo.new(0.15),{TextColor3=Color3.fromRGB(180,230,190)}):Play()
    end)

    local function setVisual(state)
        isOn=state
        TweenService:Create(dot,TweenInfo.new(0.2),{BackgroundColor3=isOn and C.green or C.greenDim}):Play()
        TweenService:Create(stroke,TweenInfo.new(0.2),{Color=isOn and C.green or C.greenDim,Transparency=isOn and 0 or 0.3}):Play()
        TweenService:Create(card,TweenInfo.new(0.2),{BackgroundColor3=isOn and C.cardBgOn or C.cardBg}):Play()
    end
    return wrapper,setVisual
end

-- ═══════════════════════════════════════════════════════════════
--  BUILD CARDS
-- ═══════════════════════════════════════════════════════════════
local _,sv_speedBoost=createCard("Speed Boost",true,function(s)
    speedBoostEnabled=s ToggleStates.speedBoost=s
    if s then startSpeedBoost() else stopSpeedBoost() end
end,"Boost Speed",BoostSpeed,function(n) BoostSpeed=n end)
CardSetVisuals["speedBoost"]=sv_speedBoost

local _,sv_spamBat=createCard("Spam Bat",false,function(s)
    spamBatEnabled=s ToggleStates.spamBat=s
    if s then startSpamBat() else stopSpamBat() end
end) CardSetVisuals["spamBat"]=sv_spamBat

local _,sv_unwalk=createCard("Unwalk",false,function(s)
    unwalkEnabled=s ToggleStates.unwalk=s
    if s then startUnwalk() else stopUnwalk() end
end) CardSetVisuals["unwalk"]=sv_unwalk

local _,sv_optimizer=createCard("Performance / XRay",false,function(s)
    optimizerEnabled=s ToggleStates.optimizer=s
    if s then enableOptimizer() else disableOptimizer() end
end) CardSetVisuals["optimizer"]=sv_optimizer

local _,sv_spinBot=createCard("Spin Bot",true,function(s)
    spinBotEnabled=s ToggleStates.spinBot=s
    if s then startSpinBot() else stopSpinBot() end
end,"Spin Speed",SpinSpeed,function(n)
    SpinSpeed=n if spinBotEnabled then stopSpinBot() startSpinBot() end
end) CardSetVisuals["spinBot"]=sv_spinBot

local _,sv_batAimbot=createCard("Bat Aimbot",false,function(s)
    batAimbotEnabled=s ToggleStates.batAimbot=s
    if s then startBatAimbot() else stopBatAimbot() end
end) CardSetVisuals["batAimbot"]=sv_batAimbot

local _,sv_autoSteal=createCard("Auto Steal",false,function(s)
    autoStealEnabled=s ToggleStates.autoSteal=s
    if s then startAutoSteal() else stopAutoSteal() end
end) CardSetVisuals["autoSteal"]=sv_autoSteal

local _,sv_stealSpeed=createCard("Speed While Stealing",true,function(s)
    stealSpeedEnabled=s ToggleStates.stealSpeed=s
end,"Steal Speed",StealSpeed,function(n) StealSpeed=n end)
CardSetVisuals["stealSpeed"]=sv_stealSpeed

local _,sv_antiRagdoll=createCard("Anti Ragdoll",false,function(s)
    antiRagdollEnabled=s ToggleStates.antiRagdoll=s
    if s then startAntiRagdoll() else stopAntiRagdoll() end
end) CardSetVisuals["antiRagdoll"]=sv_antiRagdoll

local setFloatCardVisual
_,setFloatCardVisual=createCard("Float",false,function(s)
    floatEnabled=s ToggleStates.float=s
    if s then startFloat() else stopFloat() end
end) CardSetVisuals["float"]=setFloatCardVisual

_G_stopFloatVisual=function()
    if setFloatCardVisual then setFloatCardVisual(false) end
    ToggleStates.float=false
end

-- ═══════════════════════════════════════════════════════════════
--  PATH LOGIC
-- ═══════════════════════════════════════════════════════════════
local lastFlatVel=Vector3.zero local pathActive=false

local path1={
    {pos=Vector3.new(-470.6,-5.9, 34.4)},{pos=Vector3.new(-484.2,-3.9, 21.4)},
    {pos=Vector3.new(-475.6,-5.8, 29.3)},{pos=Vector3.new(-473.4,-5.9,111.0)},
}
local path2={
    {pos=Vector3.new(-474.7,-5.9, 91.0)},{pos=Vector3.new(-483.4,-3.9, 97.3)},
    {pos=Vector3.new(-474.7,-5.9, 91.0)},{pos=Vector3.new(-476.1,-5.5, 25.4)},
}

local function moveToPoint(hrp,current,nextPoint,speed)
    local conn
    conn=RunService.Heartbeat:Connect(function()
        if not pathActive then conn:Disconnect() hrp.AssemblyLinearVelocity=Vector3.zero return end
        local pos=hrp.Position
        local target=Vector3.new(current.X,pos.Y,current.Z)
        local dir=target-pos local dist=dir.Magnitude
        local stopDist=math.clamp(BASE_STOP-dist*0.04,MIN_STOP,BASE_STOP)
        if dist<=stopDist then conn:Disconnect() hrp.AssemblyLinearVelocity=Vector3.zero return end
        local moveDir=dir.Unit
        if nextPoint then
            local nextDir=(Vector3.new(nextPoint.X,pos.Y,nextPoint.Z)-pos).Unit
            moveDir=(moveDir+nextDir*NEXT_POINT_BIAS).Unit
        end
        if lastFlatVel.Magnitude>0.1 then
            moveDir=(moveDir*(1-SMOOTH_FACTOR)+lastFlatVel.Unit*SMOOTH_FACTOR).Unit
        end
        local vel=Vector3.new(moveDir.X*speed,hrp.AssemblyLinearVelocity.Y,moveDir.Z*speed)
        hrp.AssemblyLinearVelocity=vel lastFlatVel=Vector3.new(vel.X,0,vel.Z)
    end)
    while pathActive and
        (Vector3.new(hrp.Position.X,0,hrp.Position.Z)-Vector3.new(current.X,0,current.Z)).Magnitude>BASE_STOP do
        RunService.Heartbeat:Wait()
    end
end
local function runPath(path)
    local char=Player.Character or Player.CharacterAdded:Wait()
    local hrp=char:WaitForChild("HumanoidRootPart")
    for i,p in ipairs(path) do
        if not pathActive then return end
        local speed=i>2 and SECOND_PHASE_SPEED or VELOCITY_SPEED
        local nextP=path[i+1] and path[i+1].pos
        moveToPoint(hrp,p.pos,nextP,speed)
        task.wait(i==2 and 0.2 or 0.01)
    end
end
local function startPath(path)
    pathActive=true
    task.spawn(function()
        while pathActive do runPath(path) task.wait(0.1) end
    end)
end
local function stopPath()
    pathActive=false
    local hrp=Player.Character and Player.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.AssemblyLinearVelocity=Vector3.zero end
end

-- ═══════════════════════════════════════════════════════════════
--  TP RAGDOLL
-- ═══════════════════════════════════════════════════════════════
local finalPos1=Vector3.new(-483.59,-5.04,104.24)
local finalPos2=Vector3.new(-483.51,-5.10, 18.89)
local checkpointA=Vector3.new(-472.60,-7.00, 57.52)
local checkpointB1=Vector3.new(-472.65,-7.00, 95.69)
local checkpointB2=Vector3.new(-471.76,-7.00, 26.22)

local function tpMove(pos)
    local char=Player.Character if not char then return end
    char:PivotTo(CFrame.new(pos))
    local hrp=char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.AssemblyLinearVelocity=Vector3.zero end
end
local function doTP1() tpMove(checkpointA) task.wait(0.1) tpMove(checkpointB1) task.wait(0.1) tpMove(finalPos1) end
local function doTP2() tpMove(checkpointA) task.wait(0.1) tpMove(checkpointB2) task.wait(0.1) tpMove(finalPos2) end

do
    local hw=Instance.new("Frame",contentFrame)
    hw.Size=UDim2.new(1,0,0,24) hw.BackgroundTransparency=1 hw.BorderSizePixel=0 hw.ZIndex=11
    local hl=Instance.new("TextLabel",hw)
    hl.Size=UDim2.new(1,-12,1,0) hl.Position=UDim2.new(0,6,0,0)
    hl.BackgroundTransparency=1 hl.Text="── TP ON RAGDOLL ──"
    hl.TextColor3=Color3.fromRGB(40,140,65) hl.Font=Enum.Font.GothamBold
    hl.TextSize=10 hl.TextXAlignment=Enum.TextXAlignment.Center hl.ZIndex=12
end

local function makeTpCard(label,tpFn)
    local card=Instance.new("Frame",contentFrame)
    card.Size=UDim2.new(1,0,0,44) card.BackgroundColor3=C.cardBg
    card.BorderSizePixel=0 card.ZIndex=11
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,10)
    local cs=Instance.new("UIStroke",card) cs.Thickness=1.2 cs.Color=C.greenDim cs.Transparency=0.3
    local lbl=Instance.new("TextLabel",card)
    lbl.Size=UDim2.new(1,-70,1,0) lbl.Position=UDim2.new(0,12,0,0)
    lbl.BackgroundTransparency=1 lbl.Text=label
    lbl.TextColor3=Color3.fromRGB(180,230,190) lbl.Font=Enum.Font.GothamBold
    lbl.TextSize=13 lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.ZIndex=12
    local goBtn=Instance.new("TextButton",card)
    goBtn.Size=UDim2.new(0,46,0,26) goBtn.Position=UDim2.new(1,-54,0.5,-13)
    goBtn.BackgroundColor3=C.green goBtn.Text="GO"
    goBtn.TextColor3=Color3.fromRGB(0,0,0) goBtn.Font=Enum.Font.GothamBold
    goBtn.TextSize=12 goBtn.BorderSizePixel=0 goBtn.ZIndex=13
    Instance.new("UICorner",goBtn).CornerRadius=UDim.new(0,7)
    goBtn.MouseButton1Click:Connect(function() task.spawn(tpFn) end)
    goBtn.MouseEnter:Connect(function() TweenService:Create(goBtn,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(100,255,140)}):Play() end)
    goBtn.MouseLeave:Connect(function() TweenService:Create(goBtn,TweenInfo.new(0.15),{BackgroundColor3=C.green}):Play() end)
end
makeTpCard("TP Spot 1",doTP1) makeTpCard("TP Spot 2",doTP2)

local tp1En={false} local tp2En={false} local sync1={} local sync2={}
local function makeAutoTpCard(label,enabledVar,otherEnabledVar,syncSelf,syncOther)
    local wrapper=Instance.new("Frame",contentFrame)
    wrapper.Size=UDim2.new(1,0,0,44) wrapper.BackgroundTransparency=1
    wrapper.BorderSizePixel=0 wrapper.ZIndex=11
    local card=Instance.new("Frame",wrapper)
    card.Size=UDim2.new(1,0,1,0) card.BackgroundColor3=C.cardBg
    card.BorderSizePixel=0 card.ZIndex=11
    Instance.new("UICorner",card).CornerRadius=UDim.new(0,10)
    local stroke=Instance.new("UIStroke",card) stroke.Thickness=1.2 stroke.Color=C.greenDim stroke.Transparency=0.3
    local dot=Instance.new("Frame",card)
    dot.Size=UDim2.new(0,8,0,8) dot.Position=UDim2.new(0,10,0.5,-4)
    dot.BackgroundColor3=C.greenDim dot.BorderSizePixel=0 dot.ZIndex=12
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)
    local lbl=Instance.new("TextLabel",card)
    lbl.Size=UDim2.new(1,-24,1,0) lbl.Position=UDim2.new(0,24,0,0)
    lbl.BackgroundTransparency=1 lbl.Text=label
    lbl.TextColor3=Color3.fromRGB(180,230,190) lbl.Font=Enum.Font.GothamBold
    lbl.TextSize=12 lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.ZIndex=12
    local isOn=false
    local function setVisual(state)
        isOn=state
        TweenService:Create(dot,TweenInfo.new(0.2),{BackgroundColor3=state and C.green or C.greenDim}):Play()
        TweenService:Create(stroke,TweenInfo.new(0.2),{Color=state and C.green or C.greenDim,Transparency=state and 0 or 0.3}):Play()
        TweenService:Create(card,TweenInfo.new(0.2),{BackgroundColor3=state and C.cardBgOn or C.cardBg}):Play()
    end
    syncSelf[1]=function(state) enabledVar[1]=state setVisual(state) end
    local clickBtn=Instance.new("TextButton",card)
    clickBtn.Size=UDim2.new(1,0,1,0) clickBtn.BackgroundTransparency=1 clickBtn.Text="" clickBtn.ZIndex=14
    clickBtn.MouseButton1Click:Connect(function()
        isOn=not isOn enabledVar[1]=isOn
        if isOn then otherEnabledVar[1]=false if syncOther[1] then syncOther[1](false) end end
        setVisual(isOn)
    end)
end
makeAutoTpCard("Auto TP1 on Ragdoll",tp1En,tp2En,sync1,sync2)
makeAutoTpCard("Auto TP2 on Ragdoll",tp2En,tp1En,sync2,sync1)

local function setupAutoTP(char)
    local hum=char:WaitForChild("Humanoid")
    local lastHealth=hum.Health local tpCooldown=false
    hum.HealthChanged:Connect(function(newHp)
        if tpCooldown then return end
        if newHp<lastHealth and newHp>0 then
            tpCooldown=true
            if tp1En[1] then task.spawn(doTP1) elseif tp2En[1] then task.spawn(doTP2) end
            task.delay(1.5,function() tpCooldown=false end)
        end
        lastHealth=newHp
    end)
    hum.StateChanged:Connect(function(_,newState)
        if tpCooldown then return end
        if newState==Enum.HumanoidStateType.Physics or newState==Enum.HumanoidStateType.FallingDown then
            tpCooldown=true task.wait(0.1)
            if tp1En[1] then task.spawn(doTP1) elseif tp2En[1] then task.spawn(doTP2) end
            task.delay(1.5,function() tpCooldown=false end)
        end
    end)
end
if Player.Character then task.spawn(setupAutoTP,Player.Character) end
Player.CharacterAdded:Connect(function(char) task.spawn(setupAutoTP,char) end)

-- ═══════════════════════════════════════════════════════════════
--  PANEL OPEN / CLOSE
-- ═══════════════════════════════════════════════════════════════
local panelOpen=false
local function closePanel()
    local t=TweenService:Create(panel,TweenInfo.new(0.18,Enum.EasingStyle.Quart,Enum.EasingDirection.In),{Size=UDim2.new(0,PANEL_W,0,0)})
    t:Play() t.Completed:Connect(function() panel.Visible=false end) panelOpen=false
end
closeBtn.MouseButton1Click:Connect(closePanel)
menuBtn.MouseButton1Click:Connect(function()
    panelOpen=not panelOpen
    if panelOpen then
        panel.Size=UDim2.new(0,PANEL_W,0,0) panel.Visible=true
        TweenService:Create(panel,TweenInfo.new(0.24,Enum.EasingStyle.Quart,Enum.EasingDirection.Out),{Size=UDim2.new(0,PANEL_W,0,PANEL_H)}):Play()
    else closePanel() end
end)

-- ═══════════════════════════════════════════════════════════════
--  FLOATING BUTTON FACTORY
-- ═══════════════════════════════════════════════════════════════
local floatingBtns={}

local function createFloatingBtn(labelText,xOffset,yOffset,onActivate)
    local btn=Instance.new("Frame",sg)
    btn.Name="FloatBtn_"..labelText:gsub("%s+","_")
    btn.Size=UDim2.new(0,110,0,38) btn.Position=UDim2.new(0,xOffset,0.5,yOffset)
    btn.BackgroundColor3=Color3.fromRGB(5,14,7) btn.BorderSizePixel=0
    btn.Active=true btn.ZIndex=20
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)
    table.insert(floatingBtns,btn)

    local btnStroke=Instance.new("UIStroke",btn) btnStroke.Thickness=1.5
    local bsg=Instance.new("UIGradient",btnStroke)
    bsg.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(34,197,94)),
        ColorSequenceKeypoint.new(0.3,Color3.fromRGB(10,50,20)),
        ColorSequenceKeypoint.new(0.6,Color3.fromRGB(100,255,140)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(10,50,20)),
    })
    task.spawn(function()
        local r=0 while sg.Parent do r=(r+2)%360 bsg.Rotation=r task.wait(0.02) end
    end)

    local dot=Instance.new("Frame",btn)
    dot.Size=UDim2.new(0,6,0,6) dot.Position=UDim2.new(0,8,0.5,-3)
    dot.BackgroundColor3=C.greenDim dot.BorderSizePixel=0 dot.ZIndex=21
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)

    local lbl=Instance.new("TextLabel",btn)
    lbl.Size=UDim2.new(1,-18,1,0) lbl.Position=UDim2.new(0,18,0,0)
    lbl.BackgroundTransparency=1 lbl.Text=labelText
    lbl.TextColor3=Color3.fromRGB(140,200,155) lbl.Font=Enum.Font.GothamBold
    lbl.TextSize=11 lbl.TextXAlignment=Enum.TextXAlignment.Center
    lbl.TextYAlignment=Enum.TextYAlignment.Center lbl.ZIndex=21

    local detector=Instance.new("TextButton",btn)
    detector.Size=UDim2.new(1,0,1,0) detector.BackgroundTransparency=1
    detector.Text="" detector.ZIndex=22

    local isDragging,dStart,fStart,didMove=false,nil,nil,false
    local isOn=false

    local function setActive(state)
        isOn=state
        TweenService:Create(dot,TweenInfo.new(0.2),{BackgroundColor3=isOn and C.green or C.greenDim}):Play()
        TweenService:Create(lbl,TweenInfo.new(0.2),{TextColor3=isOn and Color3.fromRGB(180,255,195) or Color3.fromRGB(140,200,155)}):Play()
        TweenService:Create(btn,TweenInfo.new(0.2),{BackgroundColor3=isOn and Color3.fromRGB(10,28,14) or Color3.fromRGB(5,14,7)}):Play()
        btnStroke.Transparency=isOn and 0 or 0.2
    end

    detector.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            isDragging=true didMove=false dStart=inp.Position fStart=btn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if not isDragging then return end
        if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then
            local delta=inp.Position-dStart
            if delta.Magnitude>4 then didMove=true end
            btn.Position=UDim2.new(fStart.X.Scale,fStart.X.Offset+delta.X,fStart.Y.Scale,fStart.Y.Offset+delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            if isDragging and not didMove then isOn=not isOn setActive(isOn) onActivate(isOn,setActive) end
            isDragging=false
        end
    end)
    detector.MouseEnter:Connect(function()
        TweenService:Create(lbl,TweenInfo.new(0.15),{TextColor3=Color3.fromRGB(180,255,195)}):Play()
    end)
    detector.MouseLeave:Connect(function()
        if not isOn then TweenService:Create(lbl,TweenInfo.new(0.15),{TextColor3=Color3.fromRGB(140,200,155)}):Play() end
    end)
    return btn,setActive
end

-- ═══════════════════════════════════════════════════════════════
--  FLOATING BUTTONS
-- ═══════════════════════════════════════════════════════════════
local setAutoRightActive,setAutoLeftActive,setFloatBtnActive2,setBatAimbotBtnActive

_,setAutoRightActive=createFloatingBtn("AUTO RIGHT",24,-110,function(on)
    autoRightOn=on ToggleStates.autoRight=on
    if on then
        autoLeftOn=false ToggleStates.autoLeft=false
        if setAutoLeftActive then setAutoLeftActive(false) end
        stopPath() startPath(path1)
    else stopPath() end
end)

-- AUTO LEFT with ⚙ popup
do
    local btn=Instance.new("Frame",sg)
    btn.Name="FloatBtn_AUTO_LEFT"
    btn.Size=UDim2.new(0,110,0,38) btn.Position=UDim2.new(0,24,0.5,-62)
    btn.BackgroundColor3=Color3.fromRGB(5,14,7) btn.BorderSizePixel=0
    btn.Active=true btn.ZIndex=20
    Instance.new("UICorner",btn).CornerRadius=UDim.new(0,10)
    table.insert(floatingBtns,btn)

    local btnStroke=Instance.new("UIStroke",btn) btnStroke.Thickness=1.5
    local bsg=Instance.new("UIGradient",btnStroke)
    bsg.Color=ColorSequence.new({
        ColorSequenceKeypoint.new(0,Color3.fromRGB(34,197,94)),
        ColorSequenceKeypoint.new(0.3,Color3.fromRGB(10,50,20)),
        ColorSequenceKeypoint.new(0.6,Color3.fromRGB(100,255,140)),
        ColorSequenceKeypoint.new(1,Color3.fromRGB(10,50,20)),
    })
    task.spawn(function()
        local r=0 while sg.Parent do r=(r+2)%360 bsg.Rotation=r task.wait(0.02) end
    end)

    local dot=Instance.new("Frame",btn)
    dot.Size=UDim2.new(0,6,0,6) dot.Position=UDim2.new(0,8,0.5,-3)
    dot.BackgroundColor3=C.greenDim dot.BorderSizePixel=0 dot.ZIndex=21
    Instance.new("UICorner",dot).CornerRadius=UDim.new(1,0)

    local lbl=Instance.new("TextLabel",btn)
    lbl.Size=UDim2.new(1,-34,1,0) lbl.Position=UDim2.new(0,16,0,0)
    lbl.BackgroundTransparency=1 lbl.Text="AUTO LEFT"
    lbl.TextColor3=Color3.fromRGB(140,200,155) lbl.Font=Enum.Font.GothamBold
    lbl.TextSize=11 lbl.TextXAlignment=Enum.TextXAlignment.Center
    lbl.TextYAlignment=Enum.TextYAlignment.Center lbl.ZIndex=21

    local gearBtn2=Instance.new("TextButton",btn)
    gearBtn2.Size=UDim2.new(0,22,0,22) gearBtn2.Position=UDim2.new(1,-26,0.5,-11)
    gearBtn2.BackgroundTransparency=1 gearBtn2.Text="⚙"
    gearBtn2.TextColor3=C.greenDim gearBtn2.Font=Enum.Font.GothamBold
    gearBtn2.TextSize=14 gearBtn2.ZIndex=23

    local popup=Instance.new("Frame",sg)
    popup.Size=UDim2.new(0,160,0,90) popup.BackgroundColor3=Color3.fromRGB(5,14,7)
    popup.BorderSizePixel=0 popup.Visible=false popup.ZIndex=30
    Instance.new("UICorner",popup).CornerRadius=UDim.new(0,8)
    local ps=Instance.new("UIStroke",popup) ps.Thickness=1.2 ps.Color=C.green ps.Transparency=0.3

    local function makePopupRow(labelTxt,defaultVal,rowY,onChanged)
        local rl=Instance.new("TextLabel",popup)
        rl.Size=UDim2.new(0,88,0,22) rl.Position=UDim2.new(0,8,0,rowY)
        rl.BackgroundTransparency=1 rl.Text=labelTxt
        rl.TextColor3=Color3.fromRGB(140,200,155) rl.Font=Enum.Font.GothamBold
        rl.TextSize=11 rl.TextXAlignment=Enum.TextXAlignment.Left rl.ZIndex=31
        local tb=Instance.new("TextBox",popup)
        tb.Size=UDim2.new(0,52,0,22) tb.Position=UDim2.new(1,-58,0,rowY)
        tb.BackgroundColor3=Color3.fromRGB(10,22,12) tb.Text=tostring(defaultVal)
        tb.TextColor3=C.green tb.Font=Enum.Font.GothamBold tb.TextSize=12
        tb.ClearTextOnFocus=false tb.ZIndex=31
        Instance.new("UICorner",tb).CornerRadius=UDim.new(0,5)
        Instance.new("UIStroke",tb).Color=C.greenDim
        tb.FocusLost:Connect(function()
            local n=tonumber(tb.Text)
            if n then
                local cl=math.clamp(math.floor(n*10+0.5)/10,0.5,300)
                tb.Text=tostring(cl) onChanged(cl)
            else tb.Text=tostring(defaultVal) end
        end)
    end
    makePopupRow("Path Speed",VELOCITY_SPEED,6,function(n) VELOCITY_SPEED=n end)
    makePopupRow("Loop Speed",SECOND_PHASE_SPEED,36,function(n) SECOND_PHASE_SPEED=n end)

    local hint=Instance.new("TextLabel",popup)
    hint.Size=UDim2.new(1,0,0,14) hint.Position=UDim2.new(0,0,1,-16)
    hint.BackgroundTransparency=1 hint.Text="path spd · loop spd"
    hint.TextColor3=Color3.fromRGB(40,120,60) hint.Font=Enum.Font.Gotham
    hint.TextSize=9 hint.TextXAlignment=Enum.TextXAlignment.Center hint.ZIndex=31

    local popupOpen2=false
    local function syncPopupPos()
        local bpos=btn.Position
        popup.Position=UDim2.new(bpos.X.Scale,bpos.X.Offset,bpos.Y.Scale,bpos.Y.Offset+42)
    end
    gearBtn2.MouseButton1Click:Connect(function()
        popupOpen2=not popupOpen2 syncPopupPos() popup.Visible=popupOpen2
        gearBtn2.TextColor3=popupOpen2 and C.green or C.greenDim
    end)

    local detector=Instance.new("TextButton",btn)
    detector.Size=UDim2.new(1,-24,1,0) detector.BackgroundTransparency=1
    detector.Text="" detector.ZIndex=22

    local isOn=false
    local function setActive(state)
        isOn=state
        TweenService:Create(dot,TweenInfo.new(0.2),{BackgroundColor3=isOn and C.green or C.greenDim}):Play()
        TweenService:Create(lbl,TweenInfo.new(0.2),{TextColor3=isOn and Color3.fromRGB(180,255,195) or Color3.fromRGB(140,200,155)}):Play()
        TweenService:Create(btn,TweenInfo.new(0.2),{BackgroundColor3=isOn and Color3.fromRGB(10,28,14) or Color3.fromRGB(5,14,7)}):Play()
        btnStroke.Transparency=isOn and 0 or 0.2
    end
    setAutoLeftActive=setActive

    local isDragging2,dStart2,fStart2,didMove2=false,nil,nil,false
    detector.InputBegan:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            isDragging2=true didMove2=false dStart2=inp.Position fStart2=btn.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(inp)
        if not isDragging2 then return end
        if inp.UserInputType==Enum.UserInputType.MouseMovement or inp.UserInputType==Enum.UserInputType.Touch then
            local delta=inp.Position-dStart2
            if delta.Magnitude>4 then didMove2=true end
            btn.Position=UDim2.new(fStart2.X.Scale,fStart2.X.Offset+delta.X,fStart2.Y.Scale,fStart2.Y.Offset+delta.Y)
            if popupOpen2 then syncPopupPos() end
        end
    end)
    UserInputService.InputEnded:Connect(function(inp)
        if inp.UserInputType==Enum.UserInputType.MouseButton1 or inp.UserInputType==Enum.UserInputType.Touch then
            if isDragging2 and not didMove2 then
                isOn=not isOn setActive(isOn)
                autoLeftOn=isOn ToggleStates.autoLeft=isOn
                if isOn then
                    autoRightOn=false ToggleStates.autoRight=false
                    if setAutoRightActive then setAutoRightActive(false) end
                    stopPath() startPath(path2)
                else stopPath() end
            end
            isDragging2=false
        end
    end)
    detector.MouseEnter:Connect(function()
        TweenService:Create(lbl,TweenInfo.new(0.15),{TextColor3=Color3.fromRGB(180,255,195)}):Play()
    end)
    detector.MouseLeave:Connect(function()
        if not isOn then TweenService:Create(lbl,TweenInfo.new(0.15),{TextColor3=Color3.fromRGB(140,200,155)}):Play() end
    end)
end

_,setBatAimbotBtnActive=createFloatingBtn("BAT AIMBOT",24,-14,function(on)
    batAimbotEnabled=on ToggleStates.batAimbot=on
    if on then
        autoRightOn=false autoLeftOn=false
        if setAutoRightActive then setAutoRightActive(false) end
        if setAutoLeftActive  then setAutoLeftActive(false)  end
        stopPath() startBatAimbot()
    else stopBatAimbot() end
end)

_,setFloatBtnActive2=createFloatingBtn("FLOAT",24,34,function(on)
    floatEnabled=on ToggleStates.float=on
    if on then if setFloatCardVisual then setFloatCardVisual(true) end startFloat()
    else if setFloatCardVisual then setFloatCardVisual(false) end stopFloat() end
end)

-- DROP button
createFloatingBtn("DROP",24,82,function(on,setFn)
    setFn(false) -- immediately reset visual, it's a one-shot
    task.spawn(doDrop)
end)

local _orig2=_G_stopFloatVisual
_G_stopFloatVisual=function()
    if _orig2 then _orig2() end
    if setFloatBtnActive2 then setFloatBtnActive2(false) end
    ToggleStates.float=false
end

-- ═══════════════════════════════════════════════════════════════
--  KEYBINDS
-- ═══════════════════════════════════════════════════════════════
local guiVisible=true
UserInputService.InputBegan:Connect(function(inp,gpe)
    if gpe then return end
    if inp.KeyCode==Enum.KeyCode.U then
        guiVisible=not guiVisible
        menuBtn.Visible=guiVisible titleBar.Visible=guiVisible
        ProgressBarContainer.Visible=guiVisible
        for _,b in ipairs(floatingBtns) do b.Visible=guiVisible end
        if not guiVisible then panel.Visible=false panelOpen=false end
    end
    if inp.KeyCode==Enum.KeyCode.V then
        speedBoostEnabled=not speedBoostEnabled ToggleStates.speedBoost=speedBoostEnabled
        if speedBoostEnabled then startSpeedBoost() else stopSpeedBoost() end
    end
    if inp.KeyCode==Enum.KeyCode.E then
        autoRightOn=not autoRightOn ToggleStates.autoRight=autoRightOn
        if setAutoRightActive then setAutoRightActive(autoRightOn) end
        if autoRightOn then
            autoLeftOn=false ToggleStates.autoLeft=false
            if setAutoLeftActive then setAutoLeftActive(false) end
            stopPath() startPath(path1)
        else stopPath() end
    elseif inp.KeyCode==Enum.KeyCode.Q then
        autoLeftOn=not autoLeftOn ToggleStates.autoLeft=autoLeftOn
        if setAutoLeftActive then setAutoLeftActive(autoLeftOn) end
        if autoLeftOn then
            autoRightOn=false ToggleStates.autoRight=false
            if setAutoRightActive then setAutoRightActive(false) end
            stopPath() startPath(path2)
        else stopPath() end
    end
end)

Player.CharacterAdded:Connect(function()
    task.wait(1)
    if speedBoostEnabled  then stopSpeedBoost() task.wait(0.1) startSpeedBoost() end
    if spamBatEnabled     then stopSpamBat()    task.wait(0.1) startSpamBat()    end
    if unwalkEnabled      then startUnwalk() end
    if spinBotEnabled     then stopSpinBot()    task.wait(0.1) startSpinBot()    end
    if batAimbotEnabled   then stopBatAimbot()  task.wait(0.1) startBatAimbot()  end
end)

-- ═══════════════════════════════════════════════════════════════
--  SAVE / LOAD / AUTO SAVE
-- ═══════════════════════════════════════════════════════════════
local function posToTable(pos)
    return {xs=pos.X.Scale,xo=pos.X.Offset,ys=pos.Y.Scale,yo=pos.Y.Offset}
end
local function tableToPos(t)
    return UDim2.new(t.xs,t.xo,t.ys,t.yo)
end

local function saveConfig()
    if not writefile then return end
    local data={
        positions={menuBtn=posToTable(menuBtn.Position)},
        settings={
            BoostSpeed=BoostSpeed, StealSpeed=StealSpeed, SpinSpeed=SpinSpeed,
            STEAL_RADIUS=STEAL_RADIUS, STEAL_DURATION=STEAL_DURATION,
            VELOCITY_SPEED=VELOCITY_SPEED, SECOND_PHASE_SPEED=SECOND_PHASE_SPEED,
        },
        toggles={
            speedBoost=ToggleStates.speedBoost, spamBat=ToggleStates.spamBat,
            unwalk=ToggleStates.unwalk, optimizer=ToggleStates.optimizer,
            spinBot=ToggleStates.spinBot, batAimbot=ToggleStates.batAimbot,
            autoSteal=ToggleStates.autoSteal, stealSpeed=ToggleStates.stealSpeed,
            antiRagdoll=ToggleStates.antiRagdoll, float=ToggleStates.float,
        }
    }
    for _,b in ipairs(floatingBtns) do
        data.positions[b.Name]=posToTable(b.Position)
    end
    pcall(function() writefile(CONFIG_FILE,HttpService:JSONEncode(data)) end)
end

local function activateToggle(key,state)
    if key=="speedBoost" then
        speedBoostEnabled=state ToggleStates.speedBoost=state
        if state then startSpeedBoost() else stopSpeedBoost() end
        if CardSetVisuals["speedBoost"] then CardSetVisuals["speedBoost"](state) end
    elseif key=="spamBat" then
        spamBatEnabled=state ToggleStates.spamBat=state
        if state then startSpamBat() else stopSpamBat() end
        if CardSetVisuals["spamBat"] then CardSetVisuals["spamBat"](state) end
    elseif key=="unwalk" then
        unwalkEnabled=state ToggleStates.unwalk=state
        if state then startUnwalk() else stopUnwalk() end
        if CardSetVisuals["unwalk"] then CardSetVisuals["unwalk"](state) end
    elseif key=="optimizer" then
        optimizerEnabled=state ToggleStates.optimizer=state
        if state then enableOptimizer() else disableOptimizer() end
        if CardSetVisuals["optimizer"] then CardSetVisuals["optimizer"](state) end
    elseif key=="spinBot" then
        spinBotEnabled=state ToggleStates.spinBot=state
        if state then startSpinBot() else stopSpinBot() end
        if CardSetVisuals["spinBot"] then CardSetVisuals["spinBot"](state) end
    elseif key=="batAimbot" then
        batAimbotEnabled=state ToggleStates.batAimbot=state
        if state then startBatAimbot() else stopBatAimbot() end
        if CardSetVisuals["batAimbot"] then CardSetVisuals["batAimbot"](state) end
    elseif key=="autoSteal" then
        autoStealEnabled=state ToggleStates.autoSteal=state
        if state then startAutoSteal() else stopAutoSteal() end
        if CardSetVisuals["autoSteal"] then CardSetVisuals["autoSteal"](state) end
    elseif key=="stealSpeed" then
        stealSpeedEnabled=state ToggleStates.stealSpeed=state
        if CardSetVisuals["stealSpeed"] then CardSetVisuals["stealSpeed"](state) end
    elseif key=="antiRagdoll" then
        antiRagdollEnabled=state ToggleStates.antiRagdoll=state
        if state then startAntiRagdoll() else stopAntiRagdoll() end
        if CardSetVisuals["antiRagdoll"] then CardSetVisuals["antiRagdoll"](state) end
    elseif key=="float" then
        floatEnabled=state ToggleStates.float=state
        if state then startFloat() else stopFloat() end
        if CardSetVisuals["float"] then CardSetVisuals["float"](state) end
        if setFloatBtnActive2 then setFloatBtnActive2(state) end
    end
end

local function loadConfig()
    if not isfile or not readfile then return end
    pcall(function()
        if not isfile(CONFIG_FILE) then return end
        local ok,data=pcall(function() return HttpService:JSONDecode(readfile(CONFIG_FILE)) end)
        if not ok or not data then return end
        if data.positions then
            if data.positions.menuBtn then menuBtn.Position=tableToPos(data.positions.menuBtn) end
            for _,b in ipairs(floatingBtns) do
                if data.positions[b.Name] then b.Position=tableToPos(data.positions[b.Name]) end
            end
        end
        if data.settings then
            if data.settings.BoostSpeed         then BoostSpeed         =data.settings.BoostSpeed         end
            if data.settings.StealSpeed         then StealSpeed         =data.settings.StealSpeed         end
            if data.settings.SpinSpeed          then SpinSpeed          =data.settings.SpinSpeed          end
            if data.settings.STEAL_RADIUS       then STEAL_RADIUS       =data.settings.STEAL_RADIUS       end
            if data.settings.STEAL_DURATION     then STEAL_DURATION     =data.settings.STEAL_DURATION     end
            if data.settings.VELOCITY_SPEED     then VELOCITY_SPEED     =data.settings.VELOCITY_SPEED     end
            if data.settings.SECOND_PHASE_SPEED then SECOND_PHASE_SPEED =data.settings.SECOND_PHASE_SPEED end
        end
        if data.toggles then
            task.wait(0.5)
            for key,state in pairs(data.toggles) do
                if state then activateToggle(key,true) end
            end
        end
    end)
end

loadConfig()
pcall(function()
    radiusBox.Text=tostring(STEAL_RADIUS)
    durationBox.Text=string.format("%.1f",STEAL_DURATION)
end)

-- Auto save every 5 seconds
task.spawn(function()
    while sg.Parent do
        task.wait(5)
        saveConfig()
    end
end)
