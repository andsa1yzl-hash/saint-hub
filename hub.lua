loadstring(game:HttpGet("https://api.luarmor.net/files/v4/loaders/0f2631e2b6fdbb9be3d698973ea6ef35.lua"))()

local Lib = Instance.new("ScreenGui")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

Lib.Name = "Saint_Hub"
Lib.ResetOnSpawn = false
Lib.Parent = game:GetService("CoreGui")
Lib.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local rightWaypoints = {
    Vector3.new(-473.04,-6.99,29.71), Vector3.new(-483.57,-5.10,18.74),
    Vector3.new(-475.00,-6.99,26.43), Vector3.new(-474.67,-6.94,105.48),
}
local leftWaypoints = {
    Vector3.new(-472.49,-7.00,90.62), Vector3.new(-484.62,-5.10,100.37),
    Vector3.new(-475.08,-7.00,93.29), Vector3.new(-474.22,-6.96,16.18),
}
local patrolMode = "none"
local currentWaypoint = 1
local heartbeatConn
local AUTO_START_DELAY = 0.7
local batAimbotActive = false
local batAimbotConn = nil
local AimbotRadius = 100
local BatAimbotSpeed = 55
local SlapList = {
    {1,"Bat"},{2,"Slap"},{3,"Iron Slap"},{4,"Gold Slap"},{5,"Diamond Slap"},
    {6,"Emerald Slap"},{7,"Ruby Slap"},{8,"Dark Matter Slap"},{9,"Flame Slap"},
    {10,"Nuclear Slap"},{11,"Galaxy Slap"},{12,"Glitched Slap"}
}
local spinActive = false
local spinAngle = 0
local spinSpeed = 20
local spinAlign, spinAttachment, spinConn = nil, nil, nil

local infiniteJumpActive = false
local infiniteJumpJumpConn = nil
local infiniteJumpHeartbeatConn = nil

-- Auto steal variables
local autoStealActive = false
local autoStealConn = nil
local autoStealIsStealing = false
local autoStealLastCheck = 0
local autoStealAllPodiums = {}
local autoStealPromptCache = {}
local autoStealPlotsFolder = workspace:FindFirstChild("Plots")
local autoStealConfig = {
    RADIUS = 7,
    PREDICT_FACTOR = 1.5,
}

-- Spin Bot Functions
local function setupSpinBot()
    local char = player.Character; if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart"); if not hrp then return end
    if spinAlign then spinAlign:Destroy() end
    if spinAttachment then spinAttachment:Destroy() end
    spinAttachment = Instance.new("Attachment"); spinAttachment.Parent = hrp
    spinAlign = Instance.new("AlignOrientation")
    spinAlign.Attachment0 = spinAttachment
    spinAlign.Mode = Enum.OrientationAlignmentMode.OneAttachment
    spinAlign.Responsiveness = 30; spinAlign.MaxTorque = math.huge
    spinAlign.RigidityEnabled = false; spinAlign.Enabled = false; spinAlign.Parent = hrp
end

local function startSpinBot()
    setupSpinBot()
    if spinAlign then spinAlign.Enabled = true end
    if spinConn then spinConn:Disconnect() end
    spinConn = RunService.Heartbeat:Connect(function(dt)
        if not spinActive then return end
        if not spinAlign or not spinAlign.Parent then
            setupSpinBot()
            if spinAlign then spinAlign.Enabled = true end
            return
        end
        spinAngle = spinAngle + spinSpeed * dt
        spinAlign.CFrame = CFrame.Angles(0, spinAngle, 0)
    end)
end

local function stopSpinBot()
    spinActive = false
    if spinConn then spinConn:Disconnect(); spinConn = nil end
    if spinAlign then spinAlign.Enabled = false end
end

-- Teleport / Movement Functions
local function tpMove(pos)
    local char = player.Character; if not char then return end
    char:PivotTo(CFrame.new(pos))
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.AssemblyLinearVelocity = Vector3.new(0,0,0) end
end

-- Infinite Jump
local function startInfiniteJump()
    if infiniteJumpJumpConn then return end
    infiniteJumpJumpConn = UIS.JumpRequest:Connect(function()
        if not infiniteJumpActive then return end
        local char = player.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, 50, hrp.AssemblyLinearVelocity.Z) end
    end)
    infiniteJumpHeartbeatConn = RunService.Heartbeat:Connect(function()
        if not infiniteJumpActive then return end
        local char = player.Character; if not char then return end
        local hrp = char:FindFirstChild("HumanoidRootPart")
        if hrp and hrp.AssemblyLinearVelocity.Y < -80 then
            hrp.AssemblyLinearVelocity = Vector3.new(hrp.AssemblyLinearVelocity.X, -80, hrp.AssemblyLinearVelocity.Z)
        end
    end)
end

local function stopInfiniteJump()
    if infiniteJumpJumpConn then infiniteJumpJumpConn:Disconnect(); infiniteJumpJumpConn = nil end
    if infiniteJumpHeartbeatConn then infiniteJumpHeartbeatConn:Disconnect(); infiniteJumpHeartbeatConn = nil end
end

-- Auto Steal
local function autoStealRescan()
    autoStealAllPodiums = {}
    local plots = autoStealPlotsFolder; if not plots then return end
    for _, plot in ipairs(plots:GetChildren()) do
        if plot:IsA("Model") then
            local sign = plot:FindFirstChild("PlotSign")
            local yourBase = sign and sign:FindFirstChild("YourBase")
            if not (yourBase and yourBase:IsA("BillboardGui") and yourBase.Enabled) then
                local podiums = plot:FindFirstChild("Podiums") or plot:FindFirstChild("AnimalPodiums")
                if podiums then
                    for _, podium in ipairs(podiums:GetChildren()) do
                        if podium:IsA("Model") and podium:FindFirstChild("Base") then
                            table.insert(autoStealAllPodiums, {
                                uid = plot.Name .. "_" .. podium.Name,
                                pos = podium:GetPivot().Position,
                                podium = podium
                            })
                        end
                    end
                end
            end
        end
    end
end

local function autoStealGetPrompt(data)
    local cached = autoStealPromptCache[data.uid]
    if cached and cached.Parent then return cached end
    local base = data.podium:FindFirstChild("Base")
    if base then
        for _, obj in ipairs(base:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                autoStealPromptCache[data.uid] = obj
                return obj
            end
        end
    end
    return nil
end

local function autoStealFirePrompt(prompt)
    if not prompt or not prompt.Parent then return false end
    if fireproximityprompt then
        fireproximityprompt(prompt)
    else
        prompt:InputHoldBegin(); task.wait(0.001); prompt:InputHoldEnd()
    end
    return true
end

local function autoStealStart()
    if autoStealConn then return end
    autoStealConn = RunService.Heartbeat:Connect(function()
        if not autoStealActive or autoStealIsStealing then return end
        if tick() - autoStealLastCheck < 0.04 then return end
        autoStealLastCheck = tick()
        local char = player.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local velocity = hrp.AssemblyLinearVelocity or Vector3.new(0,0,0)
        local nearest, minDist = nil, math.huge
        for _, data in ipairs(autoStealAllPodiums) do
            local dir = (data.pos - hrp.Position).Unit
            local dist = (data.pos - hrp.Position).Magnitude
            local predicted_dist = dist - (velocity:Dot(dir) * autoStealConfig.PREDICT_FACTOR)
            if predicted_dist < minDist and predicted_dist < autoStealConfig.RADIUS then
                minDist = predicted_dist; nearest = data
            end
        end
        if nearest then
            autoStealIsStealing = true
            task.spawn(function()
                local p = autoStealGetPrompt(nearest)
                if p then autoStealFirePrompt(p) end
                task.wait(0.08); autoStealIsStealing = false
            end)
        end
    end)
end

local function autoStealStop()
    if autoStealConn then autoStealConn:Disconnect(); autoStealConn = nil end
end

local rescanTimer = nil
local function startRescanTimer()
    if rescanTimer then return end
    rescanTimer = task.spawn(function()
        while true do task.wait(10); if autoStealActive then autoStealRescan() end end
    end)
end

-- Unwalk Function
local unwalkActive = false
local unwalkConn = nil
local function startUnwalk()
    if unwalkConn then unwalkConn:Disconnect() end
    unwalkConn = RunService.Heartbeat:Connect(function()
        if not unwalkActive then return end
        local char = player.Character; if not char then return end
        local hum = char:FindFirstChildOfClass("Humanoid")
        if hum then local anim = hum:FindFirstChildOfClass("Animator")
            if anim then for _, t in pairs(anim:GetPlayingAnimationTracks()) do t:Stop() end end
        end
    end)
end

-- Aimbot Functions
local function findBat()
    local c = player.Character; local bp = player:FindFirstChildOfClass("Backpack")
    if not c then return nil end
    for _, ch in ipairs(c:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end
    if bp then for _, ch in ipairs(bp:GetChildren()) do if ch:IsA("Tool") and ch.Name:lower():find("bat") then return ch end end end
    for _, i in ipairs(SlapList) do local t = c:FindFirstChild(i[2]) or (bp and bp:FindFirstChild(i[2])); if t then return t end end
end

local function startBatAimbot()
    if batAimbotConn then return end
    batAimbotConn = RunService.Heartbeat:Connect(function()
        local c = player.Character; local h = c and c:FindFirstChild("HumanoidRootPart")
        local hum = c and c:FindFirstChildOfClass("Humanoid")
        if not h or not hum then return end
        local bat = findBat(); if bat and bat.Parent ~= c then hum:EquipTool(bat) end
        local target, dist, torso = nil, math.huge, nil
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player and p.Character then
                local eh = p.Character:FindFirstChild("HumanoidRootPart")
                if eh and p.Character:FindFirstChildOfClass("Humanoid").Health > 0 then
                    local d = (eh.Position - h.Position).Magnitude
                    if d < dist and d <= AimbotRadius then
                        dist = d; target = eh; torso = p.Character:FindFirstChild("Torso") or eh
                    end
                end
            end
        end
        if target and torso then
            local dir = (torso.Position + (torso.AssemblyLinearVelocity * 0.13)) - h.Position
            h.AssemblyLinearVelocity = (dir.Magnitude > 1.5) and (dir.Unit * BatAimbotSpeed) or target.AssemblyLinearVelocity
        end
    end)
end

-- Patrol Update
local function updateWalking()
    local char = player.Character; local root = char and char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    if patrolMode ~= "none" then
        local wps = (patrolMode == "right") and rightWaypoints or leftWaypoints
        local target = wps[currentWaypoint]
        local dir = (Vector3.new(target.X, 0, target.Z) - Vector3.new(root.Position.X, 0, root.Position.Z))
        if dir.Magnitude > 3 then
            local spd = (currentWaypoint >= 3) and 29.4 or 60
            root.AssemblyLinearVelocity = Vector3.new(dir.Unit.X*spd, root.AssemblyLinearVelocity.Y, dir.Unit.Z*spd)
        else
            currentWaypoint = (currentWaypoint == #wps) and 1 or currentWaypoint+1
        end
    end
end

-- [ UI COMPONENTS ]
local C_BG, C_ACTIVE, C_BORDER, C_TEXT = Color3.fromRGB(0,0,0), Color3.fromRGB(139,0,0), Color3.fromRGB(180,0,0), Color3.fromRGB(255,255,255)

local function MakeDraggable(frame)
    local dragging, dragInput, dragStart, startPos
    frame.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; dragStart = input.Position; startPos = frame.Position end end)
    frame.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end end)
    UIS.InputChanged:Connect(function(input) if input == dragInput and dragging then
        local delta = input.Position - dragStart; frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end end)
    frame.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
end

local function MakeMainBtnV2(label, xS, xO, yS, yO, w, h)
    local b = Instance.new("TextButton", Lib); b.Size = UDim2.new(0, w, 0, h); b.Position = UDim2.new(xS, xO, yS, yO)
    b.Text = ""; b.BackgroundColor3 = C_BG; b.BackgroundTransparency = 0.15; b.AutoButtonColor = false
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 9)
    local s = Instance.new("UIStroke", b); s.Color = C_BORDER; s.Thickness = 1
    local dot = Instance.new("Frame", b); dot.Name = "StatusDot"; dot.Size = UDim2.new(0, 7, 0, 7); dot.Position = UDim2.new(0, 8, 0.5, -3); dot.BackgroundColor3 = Color3.fromRGB(80,0,0); Instance.new("UICorner", dot)
    local lbl = Instance.new("TextLabel", b); lbl.Name = "Label"; lbl.Size = UDim2.new(1,-34,1,0); lbl.Position = UDim2.new(0,22,0,0); lbl.BackgroundTransparency = 1; lbl.Text = label; lbl.TextColor3 = C_TEXT; lbl.Font = Enum.Font.Gotham; lbl.TextSize = 12; lbl.TextXAlignment = Enum.TextXAlignment.Left
    MakeDraggable(b); return b
end

local function updateButtonState(b, active, onTxt, offTxt)
    b.BackgroundColor3 = active and C_ACTIVE or C_BG; b.StatusDot.BackgroundColor3 = active and Color3.new(1,0,0) or Color3.fromRGB(80,0,0)
    b.Label.Text = active and onTxt or offTxt
end

-- MAIN UI
local TitleBar = Instance.new("TextButton", Lib)
TitleBar.Size = UDim2.new(0, 260, 0, 38); TitleBar.Position = UDim2.new(0.5, -130, 0, 6); TitleBar.BackgroundColor3 = C_BG; TitleBar.Text = "SAINT HUB"; TitleBar.TextColor3 = Color3.new(1,0,0); TitleBar.Font = Enum.Font.GothamBold; TitleBar.TextSize = 18; TitleBar.AutoButtonColor = false
Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 9); Instance.new("UIStroke", TitleBar).Color = C_BORDER; MakeDraggable(TitleBar)

local buttons = {}
local BH, BW, GAP, RY1 = 32, 105, 5, 60
local RB_X = 20

buttons["Aimbot [X]"]     = MakeMainBtnV2("Aimbot [X]", 0.5, -110, 0, RY1, BW, BH)
buttons["Auto Steal"]     = MakeMainBtnV2("Auto Steal [S]", 0.5, 5, 0, RY1, BW, BH)
buttons["autoleft"]       = MakeMainBtnV2("Auto Left [Z]", 0.5, -110, 0, RY1 + (BH+GAP), BW, BH)
buttons["autoright"]      = MakeMainBtnV2("Auto Right [C]", 0.5, 5, 0, RY1 + (BH+GAP), BW, BH)
buttons["Infinite Jump"]  = MakeMainBtnV2("Infinite Jump [J]", 0.5, -110, 0, RY1 + (BH+GAP)*2, BW, BH)
buttons["Spin Bot"]       = MakeMainBtnV2("Spin Bot", 0.5, 5, 0, RY1 + (BH+GAP)*2, BW, BH)
buttons["Unwalk"]         = MakeMainBtnV2("Unwalk", 0.5, -52, 0, RY1 + (BH+GAP)*3, BW, BH)

-- LOGIC CONNECTIONS
buttons["Infinite Jump"].MouseButton1Click:Connect(function() infiniteJumpActive = not infiniteJumpActive; updateButtonState(buttons["Infinite Jump"], infiniteJumpActive, "Infinite Jump [ON]", "Infinite Jump [J]"); if infiniteJumpActive then startInfiniteJump() else stopInfiniteJump() end end)
buttons["Aimbot [X]"].MouseButton1Click:Connect(function() batAimbotActive = not batAimbotActive; updateButtonState(buttons["Aimbot [X]"], batAimbotActive, "Aimbot [ON]", "Aimbot [X]"); if batAimbotActive then startBatAimbot() else if batAimbotConn then batAimbotConn:Disconnect(); batAimbotConn = nil end end end)
buttons["Auto Steal"].MouseButton1Click:Connect(function() autoStealActive = not autoStealActive; updateButtonState(buttons["Auto Steal"], autoStealActive, "Auto Steal [ON]", "Auto Steal [S]"); if autoStealActive then autoStealRescan(); startRescanTimer(); autoStealStart() else autoStealStop() end end)
buttons["autoright"].MouseButton1Click:Connect(function() if patrolMode == "right" then patrolMode = "none"; updateButtonState(buttons["autoright"], false, "", "Auto Right [C]") else patrolMode = "right"; currentWaypoint = 1; updateButtonState(buttons["autoright"], true, "Auto Right [ON]", "Auto Right [C]"); updateButtonState(buttons["autoleft"], false, "", "Auto Left [Z]") end end)
buttons["autoleft"].MouseButton1Click:Connect(function() if patrolMode == "left" then patrolMode = "none"; updateButtonState(buttons["autoleft"], false, "", "Auto Left [Z]") else patrolMode = "left"; currentWaypoint = 1; updateButtonState(buttons["autoleft"], true, "Auto Left [ON]", "Auto Left [Z]"); updateButtonState(buttons["autoright"], false, "", "Auto Right [C]") end end)
buttons["Spin Bot"].MouseButton1Click:Connect(function() spinActive = not spinActive; updateButtonState(buttons["Spin Bot"], spinActive, "Spin Bot [ON]", "Spin Bot"); if spinActive then startSpinBot() else stopSpinBot() end end)
buttons["Unwalk"].MouseButton1Click:Connect(function() unwalkActive = not unwalkActive; updateButtonState(buttons["Unwalk"], unwalkActive, "Unwalk [ON]", "Unwalk"); if unwalkActive then startUnwalk() else if unwalkConn then unwalkConn:Disconnect(); unwalkConn = nil end end end)

heartbeatConn = RunService.Heartbeat:Connect(updateWalking)

player.CharacterAdded:Connect(function()
    task.wait(1); patrolMode = "none"; batAimbotActive = false; infiniteJumpActive = false; autoStealActive = false; spinActive = false; unwalkActive = false
    for _, b in pairs(buttons) do updateButtonState(b, false, "", b.Label.Text:gsub(" %[ON%]", "")) end
    stopSpinBot(); stopInfiniteJump(); autoStealStop()
end)

Lib.Destroying:Connect(function() if heartbeatConn then heartbeatConn:Disconnect() end end)
