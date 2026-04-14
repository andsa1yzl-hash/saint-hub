local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

-- right side path
local rightWaypoints = {
    Vector3.new(-473.04, -6.99, 29.71),
    Vector3.new(-483.57, -5.10, 18.74),
    Vector3.new(-475.00, -6.99, 26.43),
    Vector3.new(-474.67, -6.94, 105.48),
}
-- left side path
local leftWaypoints = {
    Vector3.new(-472.49, -7.00, 90.62),
    Vector3.new(-484.62, -5.10, 100.37),
    Vector3.new(-475.08, -7.00, 93.29),
    Vector3.new(-474.22, -6.96, 16.18),
}


local patrolMode = "none"
local floating = false
local currentWaypoint = 1
local heartbeatConn
local waitingForCountdownLeft = false
local waitingForCountdownRight = false
local AUTO_START_DELAY = 0.7

local function isCountdownNumber(text)
    local num = tonumber(text)
    if num and num >= 1 and num <= 5 then
        return true, num
    end
    return false
end

local function isTimerInCountdown(label)
    if not label then return false end
    local ok, num = isCountdownNumber(label.Text)
    return ok and num >= 1 and num <= 5
end

local function getCurrentSpeed()
    if patrolMode == "right" then
        if currentWaypoint >= 3 then
            return 29.4
        else
            return 60
        end
    elseif patrolMode == "left" then
        if currentWaypoint >= 3 then
            return 29.4
        else
            return 60
        end
    end
    return 0
end

local function getCurrentWaypoints()
    if patrolMode == "right" then
        return rightWaypoints
    elseif patrolMode == "left" then
        return leftWaypoints
    end
    return {}
end

local function startMovement(mode)
    patrolMode = mode
    currentWaypoint = 1
    if mode == "right" then
        rightBtn.Text = "STOP Right"
        TweenService:Create(rightBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(80, 40, 40)}):Play()
        print("AutoRight movement started")
    else
        leftBtn.Text = "STOP Left"
        TweenService:Create(leftBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(80, 40, 40)}):Play()
        print("AutoLeft movement started")
    end
end

local function updateWalking()
    local char = player.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    local hum = char:FindFirstChild("Humanoid")
    if not root or not hum then return end

    local currentVel = root.AssemblyLinearVelocity

    if floating then
        local raycastParams = RaycastParams.new()
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.FilterDescendantsInstances = {char}

        local raycastResult = workspace:Raycast(root.Position, Vector3.new(0, -50, 0), raycastParams)

        if raycastResult then
            local groundY = raycastResult.Position.Y
            local targetY = groundY + 8
            local currentY = root.Position.Y
            local yDifference = targetY - currentY

            if math.abs(yDifference) > 0.3 then
                root.AssemblyLinearVelocity = Vector3.new(
                    currentVel.X,
                    yDifference * 15,
                    currentVel.Z
                )
            else
                root.AssemblyLinearVelocity = Vector3.new(
                    currentVel.X,
                    0,
                    currentVel.Z
                )
            end
        end
    end

    if patrolMode ~= "none" then
        local waypoints = getCurrentWaypoints()
        local targetPos = waypoints[currentWaypoint]
        local currentPos = root.Position

        local targetXZ = Vector3.new(targetPos.X, 0, targetPos.Z)
        local currentXZ = Vector3.new(currentPos.X, 0, currentPos.Z)
        local distanceXZ = (targetXZ - currentXZ).Magnitude

        if distanceXZ > 3 then
            local moveDirection = (targetXZ - currentXZ).Unit
            local currentSpeed = getCurrentSpeed()

            root.AssemblyLinearVelocity = Vector3.new(
                moveDirection.X * currentSpeed,
                root.AssemblyLinearVelocity.Y,
                moveDirection.Z * currentSpeed
            )
        else
            if currentWaypoint == #waypoints then
                local completedMode = patrolMode
                patrolMode = "none"
                currentWaypoint = 1
                waitingForCountdownLeft = false
                waitingForCountdownRight = false

                rightBtn.Text = "AutoRight"
                leftBtn.Text = "AutoLeft"
                TweenService:Create(rightBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
                TweenService:Create(leftBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()

                root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)

                print("Path completed - auto stopped")
            else
                currentWaypoint = currentWaypoint + 1
                local speed = getCurrentSpeed()
                local modeText = (patrolMode == "right") and "AutoRight" or "AutoLeft"
                local speedText = (speed == 60) and "60" or "30"
                print("heading to " .. modeText .. " spot " .. currentWaypoint .. " @ " .. speedText)
            end
        end
    end
end

-- ========== MODERN GUI WITH RAINBOW OUTLINE ==========
local sg = Instance.new("ScreenGui")
sg.Name = "AutoDuel"
sg.Parent = player:WaitForChild("PlayerGui")
sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.IgnoreGuiInset = true

-- Shadow (modern depth effect)
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Size = UDim2.new(0, 230, 0, 170)  -- slightly larger than MainFrame
Shadow.Position = UDim2.new(0.5, -115, 0.5, -85)
Shadow.BackgroundTransparency = 1
Shadow.Image = "rbxassetid://6015897843"  -- blurred circle gradient
Shadow.ImageColor3 = Color3.new(0, 0, 0)
Shadow.ImageTransparency = 0.7
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
Shadow.Parent = sg

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 220, 0, 160)
MainFrame.Position = UDim2.new(0.5, -110, 0.5, -80)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
MainFrame.BackgroundTransparency = 0.1   -- slight transparency for modern look
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = sg

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)   -- more rounded
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Thickness = 2.5
UIStroke.Transparency = 0
UIStroke.Parent = MainFrame

-- Rainbow stroke updater
local hue = 0
local rainbowConnection
rainbowConnection = RunService.Heartbeat:Connect(function()
    hue = (hue + 0.005) % 1
    UIStroke.Color = Color3.fromHSV(hue, 1, 1)
end)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 28)
Title.Position = UDim2.new(0, 0, 0, 5)
Title.BackgroundTransparency = 1
Title.Text = "AutoDuel"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamSemibold
Title.Parent = MainFrame

local CreditText = Instance.new("TextLabel")
CreditText.Size = UDim2.new(1, 0, 0, 15)
CreditText.Position = UDim2.new(0, 0, 0, 28)
CreditText.BackgroundTransparency = 1
CreditText.Text = ""
CreditText.TextColor3 = Color3.fromRGB(170, 170, 170)
CreditText.TextSize = 11
CreditText.Font = Enum.Font.Gotham
CreditText.Parent = MainFrame

-- Button hover effects
local function addHoverEffects(btn, normalColor, hoverColor)
    btn.MouseEnter:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = hoverColor}):Play()
    end)
    btn.MouseLeave:Connect(function()
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = normalColor}):Play()
    end)
end

-- Right button
rightBtn = Instance.new("TextButton")
rightBtn.Size = UDim2.new(0.85, 0, 0, 32)
rightBtn.Position = UDim2.new(0.075, 0, 0, 48)
rightBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
rightBtn.Text = "AutoRight"
rightBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
rightBtn.TextSize = 12
rightBtn.Font = Enum.Font.GothamBold
rightBtn.BorderSizePixel = 0
rightBtn.AutoButtonColor = false
rightBtn.Parent = MainFrame

local rightBtnCorner = Instance.new("UICorner")
rightBtnCorner.CornerRadius = UDim.new(0, 8)
rightBtnCorner.Parent = rightBtn

addHoverEffects(rightBtn, Color3.fromRGB(45,45,45), Color3.fromRGB(70,70,70))

-- Left button
leftBtn = Instance.new("TextButton")
leftBtn.Size = UDim2.new(0.85, 0, 0, 32)
leftBtn.Position = UDim2.new(0.075, 0, 0, 85)
leftBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
leftBtn.Text = "AutoLeft"
leftBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
leftBtn.TextSize = 12
leftBtn.Font = Enum.Font.GothamBold
leftBtn.BorderSizePixel = 0
leftBtn.AutoButtonColor = false
leftBtn.Parent = MainFrame

local leftBtnCorner = Instance.new("UICorner")
leftBtnCorner.CornerRadius = UDim.new(0, 8)
leftBtnCorner.Parent = leftBtn

addHoverEffects(leftBtn, Color3.fromRGB(45,45,45), Color3.fromRGB(70,70,70))

-- Float button
floatBtn = Instance.new("TextButton")
floatBtn.Size = UDim2.new(0.85, 0, 0, 32)
floatBtn.Position = UDim2.new(0.075, 0, 0, 122)
floatBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
floatBtn.Text = "Float OFF"
floatBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
floatBtn.TextSize = 12
floatBtn.Font = Enum.Font.GothamBold
floatBtn.BorderSizePixel = 0
floatBtn.AutoButtonColor = false
floatBtn.Parent = MainFrame

local floatBtnCorner = Instance.new("UICorner")
floatBtnCorner.CornerRadius = UDim.new(0, 8)
floatBtnCorner.Parent = floatBtn

addHoverEffects(floatBtn, Color3.fromRGB(45,45,45), Color3.fromRGB(70,70,70))

-- ========== ORIGINAL FUNCTIONALITY (unchanged) ==========
rightBtn.MouseButton1Click:Connect(function()
    if patrolMode == "right" or waitingForCountdownRight then
        patrolMode = "none"
        currentWaypoint = 1
        waitingForCountdownRight = false
        rightBtn.Text = "AutoRight"
        TweenService:Create(rightBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
        leftBtn.Text = "AutoLeft"
        TweenService:Create(leftBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()

        local char = player.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
            end
        end
        print("AutoRight stopped")
    else
        local success, label = pcall(function()
            return player.PlayerGui
                :FindFirstChild("DuelsMachineTopFrame")
                and player.PlayerGui.DuelsMachineTopFrame
                :FindFirstChild("DuelsMachineTopFrame")
                and player.PlayerGui.DuelsMachineTopFrame.DuelsMachineTopFrame
                :FindFirstChild("Timer")
                and player.PlayerGui.DuelsMachineTopFrame.DuelsMachineTopFrame.Timer
                :FindFirstChild("Label")
        end)

        if success and label and isTimerInCountdown(label) then
            waitingForCountdownRight = true
            rightBtn.Text = "Waiting..."
            TweenService:Create(rightBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(255, 200, 50)}):Play()
            leftBtn.Text = "AutoLeft"
            TweenService:Create(leftBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
            print("AutoRight waiting for countdown")
        else
            startMovement("right")
        end
    end
end)

leftBtn.MouseButton1Click:Connect(function()
    if patrolMode == "left" or waitingForCountdownLeft then
        patrolMode = "none"
        currentWaypoint = 1
        waitingForCountdownLeft = false
        leftBtn.Text = "AutoLeft"
        TweenService:Create(leftBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
        rightBtn.Text = "AutoRight"
        TweenService:Create(rightBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()

        local char = player.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.AssemblyLinearVelocity = Vector3.new(0, root.AssemblyLinearVelocity.Y, 0)
            end
        end
        print("AutoLeft stopped")
    else
        local success, label = pcall(function()
            return player.PlayerGui
                :FindFirstChild("DuelsMachineTopFrame")
                and player.PlayerGui.DuelsMachineTopFrame
                :FindFirstChild("DuelsMachineTopFrame")
                and player.PlayerGui.DuelsMachineTopFrame.DuelsMachineTopFrame
                :FindFirstChild("Timer")
                and player.PlayerGui.DuelsMachineTopFrame.DuelsMachineTopFrame.Timer
                :FindFirstChild("Label")
        end)

        if success and label and isTimerInCountdown(label) then
            waitingForCountdownLeft = true
            leftBtn.Text = "Waiting..."
            TweenService:Create(leftBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(255, 200, 50)}):Play()
            rightBtn.Text = "AutoRight"
            TweenService:Create(rightBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
            print("AutoLeft waiting for countdown")
        else
            startMovement("left")
        end
    end
end)

floatBtn.MouseButton1Click:Connect(function()
    floating = not floating

    if floating then
        floatBtn.Text = "Float ON"
        floatBtn.BackgroundColor3 = Color3.fromRGB(40, 80, 40)
        print("Float ON")
    else
        floatBtn.Text = "Float OFF"
        floatBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)

        local char = player.Character
        if char then
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 0, root.AssemblyLinearVelocity.Z)
            end
        end
        print("Float OFF")
    end
end)

heartbeatConn = RunService.Heartbeat:Connect(updateWalking)

player.CharacterAdded:Connect(function()
    task.wait(1)
    patrolMode = "none"
    currentWaypoint = 1
    waitingForCountdownLeft = false
    waitingForCountdownRight = false
    floating = false

    rightBtn.Text = "AutoRight"
    leftBtn.Text = "AutoLeft"
    floatBtn.Text = "Float OFF"
    TweenService:Create(rightBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
    TweenService:Create(leftBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
    floatBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
end)

sg.Destroying:Connect(function()
    if heartbeatConn then
        heartbeatConn:Disconnect()
    end
    if rainbowConnection then
        rainbowConnection:Disconnect()
    end
end)

local function onTextChanged(label)
    local text = label.Text
    local ok, number = isCountdownNumber(text)

    if ok then
        print("Countdown detected:", number)

        if number == 1 then
            if waitingForCountdownLeft then
                print("Countdown finished! Starting auto left in", AUTO_START_DELAY, "seconds")
                task.wait(AUTO_START_DELAY)
                waitingForCountdownLeft = false
                startMovement("left")
            end

            if waitingForCountdownRight then
                print("Countdown finished! Starting auto right in", AUTO_START_DELAY, "seconds")
                task.wait(AUTO_START_DELAY)
                waitingForCountdownRight = false
                startMovement("right")
            end
        end
    end
end

spawn(function()
    local success, label = pcall(function()
        return player.PlayerGui
            :FindFirstChild("DuelsMachineTopFrame")
            and player.PlayerGui.DuelsMachineTopFrame
            :FindFirstChild("DuelsMachineTopFrame")
            and player.PlayerGui.DuelsMachineTopFrame.DuelsMachineTopFrame
            :FindFirstChild("Timer")
            and player.PlayerGui.DuelsMachineTopFrame.DuelsMachineTopFrame.Timer
            :FindFirstChild("Label")
    end)

    if success and label then
        print("Timer label found! Countdown detection enabled.")
        onTextChanged(label)
        label:GetPropertyChangedSignal("Text"):Connect(function()
            onTextChanged(label)
        end)
    else
        print("Timer label not found. Auto movements will start immediately.")
    end
end)
