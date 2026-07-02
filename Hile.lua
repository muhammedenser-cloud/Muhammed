getgenv().SCRIPT_KEY = "KEYLESS"

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")
local runService = game:GetService("RunService")
local players = game:GetService("Players")
local camera = workspace.CurrentCamera
local starterGui = game:GetService("StarterGui")
local userInput = game:GetService("UserInputService")
local lighting = game:GetService("Lighting")
local tweenService = game:GetService("TweenService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local debris = game:GetService("Debris")
local httpService = game:GetService("HttpService")

local themes = {
    {name = "Kırmızı", bg = Color3.new(0.2, 0.05, 0.05), btn = Color3.new(0.4, 0.1, 0.1), text = Color3.new(1, 0.3, 0.3)},
    {name = "Mavi", bg = Color3.new(0.05, 0.05, 0.2), btn = Color3.new(0.1, 0.1, 0.4), text = Color3.new(0.3, 0.5, 1)},
    {name = "Yeşil", bg = Color3.new(0.05, 0.2, 0.05), btn = Color3.new(0.1, 0.4, 0.1), text = Color3.new(0.3, 1, 0.3)},
    {name = "Sarı", bg = Color3.new(0.2, 0.2, 0.05), btn = Color3.new(0.4, 0.4, 0.1), text = Color3.new(1, 1, 0.3)},
    {name = "Mor", bg = Color3.new(0.15, 0.05, 0.2), btn = Color3.new(0.3, 0.1, 0.4), text = Color3.new(0.8, 0.3, 1)},
    {name = "Turuncu", bg = Color3.new(0.2, 0.1, 0.05), btn = Color3.new(0.4, 0.2, 0.1), text = Color3.new(1, 0.6, 0.2)},
    {name = "Pembe", bg = Color3.new(0.2, 0.05, 0.15), btn = Color3.new(0.4, 0.1, 0.3), text = Color3.new(1, 0.4, 0.8)},
    {name = "Siyah", bg = Color3.new(0.05, 0.05, 0.05), btn = Color3.new(0.15, 0.15, 0.15), text = Color3.new(0.8, 0.8, 0.8)},
    {name = "Beyaz", bg = Color3.new(0.2, 0.2, 0.2), btn = Color3.new(0.4, 0.4, 0.4), text = Color3.new(1, 1, 1)},
    {name = "RGB", bg = Color3.new(0.05, 0.05, 0.08), btn = Color3.new(0.15, 0.15, 0.2), text = Color3.new(1, 0.3, 0.3), rgb = true}
}

local currentTheme = 1
local rgbRunning = false
local rgbConnection = nil
local mainFrame = nil
local titleBar = nil
local titleText = nil
local scrollFrame = nil
local screenGui = nil

local function applyTheme(themeIndex)
    local theme = themes[themeIndex]
    if mainFrame then
        mainFrame.BackgroundColor3 = theme.bg
    end
    if titleBar then
        titleBar.BackgroundColor3 = theme.bg + Color3.new(0.1, 0.05, 0.05)
    end
    if titleText then
        titleText.TextColor3 = theme.text
    end
    if theme.rgb and not rgbRunning then
        rgbRunning = true
        if rgbConnection then rgbConnection:Disconnect() end
        rgbConnection = runService.Heartbeat:Connect(function()
            local hue = tick() % 360 / 360
            local color = Color3.fromHSV(hue, 1, 0.8)
            if titleText then titleText.TextColor3 = color end
            if titleBar then titleBar.BackgroundColor3 = Color3.new(color.r * 0.3, color.g * 0.05, color.b * 0.3) end
        end)
    elseif not theme.rgb and rgbRunning then
        rgbRunning = false
        if rgbConnection then rgbConnection:Disconnect(); rgbConnection = nil end
    end
end

local function toggleTheme()
    currentTheme = currentTheme + 1
    if currentTheme > #themes then currentTheme = 1 end
    applyTheme(currentTheme)
    starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "Tema: " .. themes[currentTheme].name, Duration = 2})
end

local function getEnemies()
    local list = {}
    for _, p in pairs(players:GetPlayers()) do 
        if p ~= player and p.Character then 
            table.insert(list, p) 
        end 
    end
    return list
end

local function getNearest()
    local nearest, dist = nil, math.huge
    for _, p in pairs(getEnemies()) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pos = p.Character.HumanoidRootPart.Position
            local d = (rootPart.Position - pos).Magnitude
            if d < dist then dist = d; nearest = p end
        end
    end
    return nearest
end

local function getNearby(radius)
    local nearby = {}
    for _, p in pairs(getEnemies()) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pos = p.Character.HumanoidRootPart.Position
            local d = (rootPart.Position - pos).Magnitude
            if d < radius then table.insert(nearby, p) end
        end
    end
    return nearby
end

local function getMurderer()
    for _, p in pairs(getEnemies()) do
        if p.Character and p.Character:FindFirstChild("Humanoid") then
            local hum = p.Character.Humanoid
            if hum:FindFirstChild("Murderer") or hum:FindFirstChild("Katil") or hum:FindFirstChild("Killer") then
                return p
            end
        end
    end
    return nil
end

local function getSheriff()
    for _, p in pairs(getEnemies()) do
        if p.Character and p.Character:FindFirstChild("Humanoid") then
            local hum = p.Character.Humanoid
            if hum:FindFirstChild("Sheriff") or hum:FindFirstChild("Serif") or hum:FindFirstChild("Sherif") then
                return p
            end
        end
    end
    return nil
end

local function getHero()
    for _, p in pairs(getEnemies()) do
        if p.Character and p.Character:FindFirstChild("Humanoid") then
            local hum = p.Character.Humanoid
            if hum:FindFirstChild("Hero") or hum:FindFirstChild("Kahraman") then
                return p
            end
        end
    end
    return nil
end

local function getPlayerRole(p)
    if not p or not p.Character then return "Masum" end
    local hum = p.Character:FindFirstChild("Humanoid")
    if not hum then return "Masum" end
    if hum:FindFirstChild("Murderer") or hum:FindFirstChild("Katil") or hum:FindFirstChild("Killer") then
        return "Katil"
    elseif hum:FindFirstChild("Sheriff") or hum:FindFirstChild("Serif") or hum:FindFirstChild("Sherif") then
        return "Serif"
    elseif hum:FindFirstChild("Hero") or hum:FindFirstChild("Kahraman") then
        return "Kahraman"
    else
        return "Masum"
    end
end

local function getPlayerColor(p)
    local role = getPlayerRole(p)
    if role == "Katil" then return Color3.new(1, 0, 0)
    elseif role == "Serif" then return Color3.new(0, 0.3, 1)
    elseif role == "Kahraman" then return Color3.new(1, 1, 0)
    else return Color3.new(0, 1, 0) end
end

local function getAliveEnemies()
    local list = {}
    for _, p in pairs(getEnemies()) do
        if p.Character then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then table.insert(list, p) end
        end
    end
    return list
end

local function getAlivePlayers()
    local list = {}
    for _, p in pairs(players:GetPlayers()) do
        if p.Character then
            local hum = p.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then table.insert(list, p) end
        end
    end
    return list
end

local function getPlayerDistance(p)
    if not p or not p.Character or not p.Character:FindFirstChild("HumanoidRootPart") then
        return math.huge
    end
    return (rootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
end

local function getClosestEnemy()
    local nearest, dist = nil, math.huge
    for _, p in pairs(getAliveEnemies()) do
        local d = getPlayerDistance(p)
        if d < dist then dist = d; nearest = p end
    end
    return nearest
end

local function getFurthestEnemy()
    local furthest, dist = nil, 0
    for _, p in pairs(getAliveEnemies()) do
        local d = getPlayerDistance(p)
        if d > dist then dist = d; furthest = p end
    end
    return furthest
end

local function getClosestToMouse()
    local mouse = player:GetMouse()
    if not mouse then return nil end
    local mousePos = mouse.Hit.Position
    local nearest, dist = nil, math.huge
    for _, p in pairs(getAliveEnemies()) do
        if p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local pos = p.Character.HumanoidRootPart.Position
            local d = (mousePos - pos).Magnitude
            if d < dist then dist = d; nearest = p end
        end
    end
    return nearest
end

local function isPlayerAlive(p)
    if not p or not p.Character then return false end
    local hum = p.Character:FindFirstChild("Humanoid")
    if not hum then return false end
    return hum.Health > 0
end

local function getEnemyCount()
    return #getEnemies()
end

local function getAliveEnemyCount()
    return #getAliveEnemies()
end

local function getTeamSize(role)
    local count = 0
    for _, p in pairs(players:GetPlayers()) do
        if getPlayerRole(p) == role then count = count + 1 end
    end
    return count
end

local function getInnocents()
    local list = {}
    for _, p in pairs(getEnemies()) do
        if p.Character and p.Character:FindFirstChild("Humanoid") then
            local hum = p.Character.Humanoid
            if not hum:FindFirstChild("Murderer") and not hum:FindFirstChild("Sheriff") and not hum:FindFirstChild("Hero") then
                table.insert(list, p)
            end
        end
    end
    return list
end

local function getRandomEnemy()
    local list = getAliveEnemies()
    if #list > 0 then
        return list[math.random(1, #list)]
    end
    return nil
end

local function getRandomPlayer()
    local list = getAlivePlayers()
    if #list > 0 then
        return list[math.random(1, #list)]
    end
    return nil
end

local function teleportToPosition(pos)
    if pos then
        rootPart.CFrame = CFrame.new(pos + Vector3.new(0, 3, 0))
    end
end

local function teleportToPlayer(p)
    if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
        local tRoot = p.Character.HumanoidRootPart
        rootPart.CFrame = CFrame.new(tRoot.Position + Vector3.new(0, 3, 0))
    end
end

local function getMousePosition()
    local mouse = player:GetMouse()
    if mouse and mouse.Hit then
        return mouse.Hit.Position
    end
    return nil
end

local function getLookVector()
    return rootPart.CFrame.LookVector
end

local function getDistanceBetweenPositions(pos1, pos2)
    return (pos1 - pos2).Magnitude
end

local function getRandomPosition()
    return Vector3.new(math.random(-500, 500), 50, math.random(-500, 500))
end

local function getGunPositions()
    local guns = {}
    for _, tool in pairs(workspace:GetDescendants()) do
        if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
            local name = tool.Name:lower()
            if name:find("gun") or name:find("knife") or name:find("sword") or name:find("silah") then
                table.insert(guns, {tool = tool, pos = tool.Handle.Position})
            end
        end
    end
    return guns
end

local function getNearestGun()
    local guns = getGunPositions()
    if #guns > 0 then
        local nearest, dist = nil, math.huge
        for _, gun in pairs(guns) do
            local d = getDistanceBetweenPositions(rootPart.Position, gun.pos)
            if d < dist then dist = d; nearest = gun end
        end
        return nearest
    end
    return nil
end

local function getFurthestGun()
    local guns = getGunPositions()
    if #guns > 0 then
        local furthest, dist = nil, 0
        for _, gun in pairs(guns) do
            local d = getDistanceBetweenPositions(rootPart.Position, gun.pos)
            if d > dist then dist = d; furthest = gun end
        end
        return furthest
    end
    return nil
end

local function getRandomGun()
    local guns = getGunPositions()
    if #guns > 0 then
        return guns[math.random(1, #guns)]
    end
    return nil
end

local function activateTool()
    local tool = character:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
        return true
    end
    return false
end

local function getTool()
    return character:FindFirstChildOfClass("Tool")
end

local function setHumanoidSpeed(speed)
    if humanoid then
        humanoid.WalkSpeed = speed
    end
end

local function setHumanoidJumpPower(power)
    if humanoid then
        humanoid.JumpPower = power
    end
end

local function getHumanoidState()
    if humanoid then
        return humanoid:GetState()
    end
    return nil
end

local function isHumanoidJumping()
    return getHumanoidState() == Enum.HumanoidStateType.Jumping
end

local function isHumanoidRunning()
    local state = getHumanoidState()
    return state == Enum.HumanoidStateType.Running or state == Enum.HumanoidStateType.Sprinting
end

local function getHumanoidMoveDirection()
    if humanoid then
        return humanoid.MoveDirection
    end
    return Vector3.new(0, 0, 0)
end

local function setRootVelocity(velocity)
    if rootPart then
        rootPart.Velocity = velocity
    end
end

local function getRootVelocity()
    if rootPart then
        return rootPart.Velocity
    end
    return Vector3.new(0, 0, 0)
end

local function setRootCFrame(cframe)
    if rootPart then
        rootPart.CFrame = cframe
    end
end

local function getRootPosition()
    if rootPart then
        return rootPart.Position
    end
    return Vector3.new(0, 0, 0)
end

local function isCharacterAlive()
    return humanoid and humanoid.Health > 0
end

local function reviveCharacter()
    if humanoid then
        humanoid.Health = humanoid.MaxHealth
    end
end

local function setCharacterHealth(health)
    if humanoid then
        humanoid.Health = health
    end
end

local function getCharacterHealth()
    if humanoid then
        return humanoid.Health
    end
    return 0
end

local function getCharacterMaxHealth()
    if humanoid then
        return humanoid.MaxHealth
    end
    return 100
end

local function isCharacterInGame()
    return character and character.Parent == workspace
end

local function getPlayerGui()
    return player.PlayerGui
end

local function createScreenGui(name)
    local gui = Instance.new("ScreenGui")
    gui.Name = name
    gui.Parent = getPlayerGui()
    gui.ResetOnSpawn = false
    return gui
end

local function createFrame(parent, size, pos, color)
    local frame = Instance.new("Frame")
    frame.Size = size
    frame.Position = pos
    frame.BackgroundColor3 = color or Color3.new(0.05, 0.05, 0.08)
    frame.BackgroundTransparency = 0.1
    frame.BorderSizePixel = 0
    frame.Parent = parent
    return frame
end

local function createCorner(parent, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius)
    corner.Parent = parent
end

local function createTextLabel(parent, size, pos, text, color, size2)
    local label = Instance.new("TextLabel")
    label.Size = size
    label.Position = pos
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = color or Color3.new(1, 1, 1)
    label.TextSize = size2 or 14
    label.Font = Enum.Font.GothamBold
    label.Parent = parent
    return label
end

local function createTextButton(parent, size, pos, text, color, func)
    local btn = Instance.new("TextButton")
    btn.Size = size
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = color or Color3.new(0.15, 0.15, 0.2)
    btn.BackgroundTransparency = 0
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 11
    btn.Font = Enum.Font.Gotham
    btn.BorderSizePixel = 0
    btn.Parent = parent
    createCorner(btn, 5)
    btn.MouseButton1Click:Connect(function() pcall(func) end)
    return btn
end

local function createScrollingFrame(parent, size, pos)
    local frame = Instance.new("ScrollingFrame")
    frame.Size = size
    frame.Position = pos
    frame.BackgroundTransparency = 1
    frame.Parent = parent
    frame.CanvasSize = UDim2.new(0, 0, 0, 0)
    return frame
end

local function createBillboard(parent, size)
    local bill = Instance.new("BillboardGui")
    bill.Size = size
    bill.AlwaysOnTop = true
    bill.Parent = parent
    return bill
end

local function createHighlight(adornee, color, trans)
    local highlight = Instance.new("Highlight")
    highlight.Adornee = adornee
    highlight.FillColor = color
    highlight.FillTransparency = trans or 0.2
    highlight.OutlineColor = Color3.new(1, 1, 1)
    highlight.OutlineTransparency = 0.1
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = adornee
    return highlight
end

local function createBodyVelocity(force)
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = force or Vector3.new(1e9, 1e9, 1e9)
    return bv
end

local function createExplosion(position, radius, pressure)
    local explo = Instance.new("Explosion")
    explo.BlastRadius = radius or 15
    explo.BlastPressure = pressure or 200000
    explo.Position = position
    explo.Parent = workspace
    return explo
end

local espEnabled = false
local espObjects = {}
local espConnections = {}
local espUpdateConnection = nil
local espHighlightTransparency = 0.15
local espShowNames = true
local espShowHealth = true
local espShowDistance = true
local espShowBoxes = true
local espShowTracers = false
local espBoxColor = Color3.new(1, 1, 1)
local espTracerColor = Color3.new(1, 1, 0)
local espFontSize = 16
local espBillboardSize = UDim2.new(0, 150, 0, 50)
local espHealthBarHeight = 0.3
local espDistanceLabelHeight = 0.8
local espNameLabelHeight = 0.5
local espShowSelf = true
local espSelfColor = Color3.new(0, 1, 1)
local espSelfRole = "Kendin"

local function createESPForPlayer(p)
    if not p or not p.Character then return end
    local char = p.Character
    local hum = char:FindFirstChild("Humanoid")
    if not hum then return end
    local isSelf = (p == player)
    local role = isSelf and espSelfRole or getPlayerRole(p)
    local color = isSelf and espSelfColor or getPlayerColor(p)
    if isSelf and not espShowSelf then return end
    local highlight = Instance.new("Highlight")
    highlight.Adornee = char
    highlight.FillColor = color
    highlight.FillTransparency = espHighlightTransparency
    highlight.OutlineColor = espBoxColor
    highlight.OutlineTransparency = 0.1
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Parent = char
    table.insert(espObjects, highlight)
    local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
    if not head then return end
    local bill = Instance.new("BillboardGui")
    bill.Size = espBillboardSize
    bill.AlwaysOnTop = true
    bill.Parent = head
    table.insert(espObjects, bill)
    if espShowNames then
        local nameLabel = Instance.new("TextLabel")
        nameLabel.Size = UDim2.new(1, 0, espNameLabelHeight, 0)
        nameLabel.Position = UDim2.new(0, 0, 0, 0)
        nameLabel.BackgroundTransparency = 1
        nameLabel.Text = isSelf and ("[BEN] " .. p.Name) or p.Name
        nameLabel.TextColor3 = color
        nameLabel.TextSize = espFontSize
        nameLabel.Font = Enum.Font.GothamBold
        nameLabel.TextStrokeTransparency = 0
        nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        nameLabel.Parent = bill
        table.insert(espObjects, nameLabel)
    end
    if espShowHealth then
        local healthBar = Instance.new("Frame")
        healthBar.Size = UDim2.new(1, 0, espHealthBarHeight, 0)
        healthBar.Position = UDim2.new(0, 0, espNameLabelHeight, 0)
        healthBar.BackgroundColor3 = Color3.new(0, 1, 0)
        healthBar.BorderSizePixel = 0
        healthBar.Parent = bill
        table.insert(espObjects, healthBar)
        local healthFill = Instance.new("Frame")
        healthFill.Size = UDim2.new(hum.Health / hum.MaxHealth, 0, 1, 0)
        healthFill.BackgroundColor3 = Color3.new(0, 1, 0)
        healthFill.BorderSizePixel = 0
        healthFill.Parent = healthBar
        table.insert(espObjects, healthFill)
        local function updateHealth()
            if hum and healthFill then
                healthFill.Size = UDim2.new(hum.Health / hum.MaxHealth, 0, 1, 0)
                local ratio = hum.Health / hum.MaxHealth
                if ratio < 0.3 then healthFill.BackgroundColor3 = Color3.new(1, 0, 0)
                elseif ratio < 0.6 then healthFill.BackgroundColor3 = Color3.new(1, 1, 0)
                else healthFill.BackgroundColor3 = Color3.new(0, 1, 0) end
            end
        end
        local healthConn = hum.HealthChanged:Connect(updateHealth)
        table.insert(espConnections, healthConn)
    end
    if espShowDistance then
        local distLabel = Instance.new("TextLabel")
        distLabel.Size = UDim2.new(1, 0, 0.15, 0)
        distLabel.Position = UDim2.new(0, 0, espDistanceLabelHeight, 0)
        distLabel.BackgroundTransparency = 1
        distLabel.Text = ""
        distLabel.TextColor3 = Color3.new(1, 1, 1)
        distLabel.TextSize = 12
        distLabel.Font = Enum.Font.Gotham
        distLabel.Parent = bill
        table.insert(espObjects, distLabel)
        local function updateDistance()
            if hum and rootPart and distLabel then
                local tRoot = hum.Parent:FindFirstChild("HumanoidRootPart")
                if tRoot then
                    local dist = (rootPart.Position - tRoot.Position).Magnitude
                    distLabel.Text = math.floor(dist) .. "m"
                end
            end
        end
        local distConn = runService.Heartbeat:Connect(updateDistance)
        table.insert(espConnections, distConn)
    end
    if espShowBoxes then
        local box = Instance.new("SelectionBox")
        box.Adornee = char
        box.Color3 = espBoxColor
        box.Transparency = 0.5
        box.Parent = char
        table.insert(espObjects, box)
    end
    if espShowTracers and not isSelf then
        local tracer = Instance.new("Part")
        tracer.Size = Vector3.new(0.1, 0.1, 0.1)
        tracer.Anchored = true
        tracer.CanCollide = false
        tracer.Material = Enum.Material.Neon
        tracer.BrickColor = BrickColor.new(Color3.new(1, 1, 0))
        tracer.Parent = workspace
        table.insert(espObjects, tracer)
        local function updateTracer()
            if tracer and rootPart and head then
                local startPos = rootPart.Position + Vector3.new(0, 1, 0)
                local endPos = head.Position
                local midPos = (startPos + endPos) / 2
                local distance = (startPos - endPos).Magnitude
                tracer.CFrame = CFrame.new(midPos, endPos) * CFrame.new(0, 0, -distance / 2)
                tracer.Size = Vector3.new(0.1, 0.1, distance)
            end
        end
        local tracerConn = runService.Heartbeat:Connect(updateTracer)
        table.insert(espConnections, tracerConn)
    end
end

local function toggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        if espUpdateConnection then espUpdateConnection:Disconnect() end
        espUpdateConnection = runService.Heartbeat:Connect(function()
            for _, obj in pairs(espObjects) do obj:Destroy() end
            espObjects = {}
            for _, conn in pairs(espConnections) do conn:Disconnect() end
            espConnections = {}
            for _, p in pairs(players:GetPlayers()) do
                if p.Character then
                    createESPForPlayer(p)
                end
            end
        end)
        starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "ESP Aktif! Tüm rolleri ve kendini görüyorsun.", Duration = 2})
    else
        if espUpdateConnection then espUpdateConnection:Disconnect(); espUpdateConnection = nil end
        for _, obj in pairs(espObjects) do obj:Destroy() end
        espObjects = {}
        for _, conn in pairs(espConnections) do conn:Disconnect() end
        espConnections = {}
        starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "ESP Devre Dışı.", Duration = 2})
    end
end

local aimbotEnabled = false
local aimbotConnection = nil
local aimbotTarget = nil
local aimbotLocked = false
local aimbotSmoothness = 0.05
local aimbotFOV = 180
local aimbotTargetPart = "Head"
local aimbotAutoShoot = true
local aimbotPredictMovement = true
local aimbotPrediction = 0.5
local aimbotShootDelay = 0.02
local aimbotMaxDistance = 350
local aimbotMinDistance = 5
local aimbotOnlyMurderer = false
local aimbotIgnoreSheriff = false
local aimbotIgnoreInnocent = false
local aimbotShowFOV = true
local aimbotFOVCircle = nil
local aimbotFOVColor = Color3.new(1, 0, 0)
local aimbotFOVTransparency = 0.3

local function createFOVCircle()
    if aimbotFOVCircle then aimbotFOVCircle:Destroy() end
    if not aimbotEnabled or not aimbotShowFOV then return end
    local circle = Instance.new("Part")
    circle.Size = Vector3.new(aimbotFOV * 0.1, 0.1, aimbotFOV * 0.1)
    circle.Shape = Enum.PartType.Cylinder
    circle.Material = Enum.Material.Neon
    circle.BrickColor = BrickColor.new(aimbotFOVColor)
    circle.Transparency = aimbotFOVTransparency
    circle.Anchored = true
    circle.CanCollide = false
    circle.Parent = workspace
    local attachment = Instance.new("Attachment")
    attachment.Parent = circle
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(2, 0, 2, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = circle
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 1
    frame.Parent = billboard
    local fovLabel = Instance.new("TextLabel")
    fovLabel.Size = UDim2.new(1, 0, 1, 0)
    fovLabel.BackgroundTransparency = 1
    fovLabel.Text = "FOV: " .. aimbotFOV
    fovLabel.TextColor3 = aimbotFOVColor
    fovLabel.TextSize = 16
    fovLabel.Font = Enum.Font.GothamBold
    fovLabel.Parent = frame
    local function updateFOV()
        if not aimbotEnabled or not aimbotShowFOV then
            if aimbotFOVCircle then aimbotFOVCircle:Destroy(); aimbotFOVCircle = nil end
            return
        end
        local camPos = camera.CFrame.Position
        local lookVector = camera.CFrame.LookVector
        circle.CFrame = CFrame.new(camPos + lookVector * 10, camPos + lookVector * 20)
    end
    aimbotFOVCircle = circle
    runService.RenderStepped:Connect(updateFOV)
end

local function toggleAimbot()
    aimbotEnabled = not aimbotEnabled
    if aimbotEnabled then
        if aimbotConnection then aimbotConnection:Disconnect() end
        createFOVCircle()
        aimbotConnection = runService.RenderStepped:Connect(function()
            if aimbotEnabled then
                local target = nil
                if aimbotOnlyMurderer then
                    target = getMurderer()
                end
                if not target then
                    target = getNearest()
                end
                if aimbotIgnoreSheriff and target == getSheriff() then
                    target = getNearest()
                end
                if aimbotIgnoreInnocent and getPlayerRole(target) == "Masum" then
                    target = getNearest()
                end
                if target and target.Character then
                    local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
                    local tHead = target.Character:FindFirstChild("Head")
                    local tTorso = target.Character:FindFirstChild("Torso") or target.Character:FindFirstChild("UpperTorso")
                    local tHumanoid = target.Character:FindFirstChild("Humanoid")
                    if tRoot and tHumanoid and tHumanoid.Health > 0 then
                        local distance = (rootPart.Position - tRoot.Position).Magnitude
                        if distance >= aimbotMinDistance and distance <= aimbotMaxDistance then
                            aimbotTarget = target
                            aimbotLocked = true
                            local aimPart = tHead or tRoot
                            if aimbotTargetPart == "Head" and tHead then
                                aimPart = tHead
                            elseif aimbotTargetPart == "Torso" and tTorso then
                                aimPart = tTorso
                            end
                            local targetPos = aimPart.Position
                            if aimbotPredictMovement then
                                local velocity = tRoot.Velocity or Vector3.new(0, 0, 0)
                                targetPos = targetPos + (velocity * aimbotPrediction)
                            end
                            local viewportPoint = camera:WorldToViewportPoint(targetPos)
                            local mouse = player:GetMouse()
                            local currentPos = Vector2.new(mouse.X, mouse.Y)
                            local targetPos2D = Vector2.new(viewportPoint.X, viewportPoint.Y)
                            local newPos = currentPos:Lerp(targetPos2D, aimbotSmoothness)
                            mouse.Move(newPos)
                            if aimbotAutoShoot then
                                local tool = character:FindFirstChildOfClass("Tool")
                                if tool and distance < 300 then
                                    tool:Activate()
                                    task.wait(aimbotShootDelay)
                                    tool:Activate()
                                    task.wait(aimbotShootDelay)
                                    tool:Activate()
                                    task.wait(aimbotShootDelay)
                                end
                            end
                        else
                            aimbotLocked = false
                        end
                    else
                        aimbotLocked = false
                    end
                else
                    aimbotLocked = false
                end
            end
        end)
        starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "Aimbot Aktif! Hedef kilitlendi.", Duration = 2})
    else
        if aimbotConnection then aimbotConnection:Disconnect(); aimbotConnection = nil end
        if aimbotFOVCircle then aimbotFOVCircle:Destroy(); aimbotFOVCircle = nil end
        aimbotTarget = nil
        aimbotLocked = false
        starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "Aimbot Devre Dışı.", Duration = 2})
    end
end

local autoShoot = false
local autoShootConnection = nil
local autoShootDelay = 0.02
local autoShootMaxDistance = 350
local autoShootMinDistance = 5
local autoShootOnlyMurderer = false
local autoShootIgnoreSheriff = false
local autoShootIgnoreInnocent = false
local autoShootBurstCount = 3
local autoShootBurstDelay = 0.05
local autoShootTarget = nil
local autoShootLocked = false
local autoShootPredictMovement = true
local autoShootPrediction = 0.3

local function toggleAutoShoot()
    autoShoot = not autoShoot
    if autoShoot then
        if autoShootConnection then autoShootConnection:Disconnect() end
        autoShootConnection = runService.Heartbeat:Connect(function()
            if autoShoot then
                local target = nil
                if autoShootOnlyMurderer then
                    target = getMurderer()
                end
                if not target then
                    target = getNearest()
                end
                if autoShootIgnoreSheriff and target == getSheriff() then
                    target = getNearest()
                end
                if autoShootIgnoreInnocent and getPlayerRole(target) == "Masum" then
                    target = getNearest()
                end
                if target and target.Character then
                    local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
                    local tHumanoid = target.Character:FindFirstChild("Humanoid")
                    if tRoot and tHumanoid and tHumanoid.Health > 0 then
                        local distance = (rootPart.Position - tRoot.Position).Magnitude
                        if distance >= autoShootMinDistance and distance <= autoShootMaxDistance then
                            autoShootTarget = target
                            autoShootLocked = true
                            local tool = character:FindFirstChildOfClass("Tool")
                            if tool then
                                for i = 1, autoShootBurstCount do
                                    tool:Activate()
                                    task.wait(autoShootDelay)
                                end
                            end
                        else
                            autoShootLocked = false
                        end
                    else
                        autoShootLocked = false
                    end
                else
                    autoShootLocked = false
                end
            end
        end)
        starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "Auto Shoot Aktif!", Duration = 2})
    else
        if autoShootConnection then autoShootConnection:Disconnect(); autoShootConnection = nil end
        starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "Auto Shoot Devre Dışı.", Duration = 2})
    end
end

local massKillEnabled = false
local massKillConnection = nil

local function toggleMassKill()
    massKillEnabled = not massKillEnabled
    if massKillEnabled then
        if massKillConnection then massKillConnection:Disconnect() end
        massKillConnection = runService.Heartbeat:Connect(function()
            if massKillEnabled then
                for _, enemy in pairs(getAliveEnemies()) do
                    if enemy and enemy.Character then
                        local tRoot = enemy.Character:FindFirstChild("HumanoidRootPart")
                        local tHumanoid = enemy.Character:FindFirstChild("Humanoid")
                        if tRoot and tHumanoid and tHumanoid.Health > 0 then
                            rootPart.CFrame = CFrame.new(tRoot.Position + Vector3.new(0, 2, 0))
                            task.wait(0.03)
                            local tool = character:FindFirstChildOfClass("Tool")
                            if tool then
                                tool:Activate()
                                task.wait(0.03)
                                tool:Activate()
                                task.wait(0.03)
                            end
                            tHumanoid.Health = 0
                            task.wait(0.03)
                        end
                    end
                end
            end
        end)
        starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "Mass Kill Aktif!", Duration = 2})
    else
        if massKillConnection then massKillConnection:Disconnect(); massKillConnection = nil end
        starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "Mass Kill Devre Dışı.", Duration = 2})
    end
end

local function massKillOnce()
    local killed = 0
    for _, enemy in pairs(getAliveEnemies()) do
        if enemy and enemy.Character then
            local tRoot = enemy.Character:FindFirstChild("HumanoidRootPart")
            local tHumanoid = enemy.Character:FindFirstChild("Humanoid")
            if tRoot and tHumanoid and tHumanoid.Health > 0 then
                rootPart.CFrame = CFrame.new(tRoot.Position + Vector3.new(0, 2, 0))
                task.wait(0.02)
                local tool = character:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                    task.wait(0.02)
                    tool:Activate()
                    task.wait(0.02)
                end
                tHumanoid.Health = 0
                killed = killed + 1
                task.wait(0.02)
            end
        end
    end
    starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = killed .. " kişi öldürüldü!", Duration = 2})
end

local nearbyKillEnabled = false
local nearbyKillConnection = nil

local function toggleNearbyKill()
    nearbyKillEnabled = not nearbyKillEnabled
    if nearbyKillEnabled then
        if nearbyKillConnection then nearbyKillConnection:Disconnect() end
        nearbyKillConnection = runService.Heartbeat:Connect(function()
            if nearbyKillEnabled then
                for _, enemy in pairs(getNearby(50)) do
                    if enemy and enemy.Character then
                        local tHumanoid = enemy.Character:FindFirstChild("Humanoid")
                        if tHumanoid and tHumanoid.Health > 0 then
                            tHumanoid.Health = 0
                            task.wait(0.05)
                        end
                    end
                end
            end
        end)
        starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "Nearby Kill Aktif!", Duration = 2})
    else
        if nearbyKillConnection then nearbyKillConnection:Disconnect(); nearbyKillConnection = nil end
        starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "Nearby Kill Devre Dışı.", Duration = 2})
    end
end

local function nearbyKillOnce()
    local killed = 0
    for _, enemy in pairs(getNearby(50)) do
        if enemy and enemy.Character then
            local tHumanoid = enemy.Character:FindFirstChild("Humanoid")
            if tHumanoid and tHumanoid.Health > 0 then
                tHumanoid.Health = 0
                killed = killed + 1
                task.wait(0.05)
            end
        end
    end
    starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = killed .. " yakın düşman öldürüldü!", Duration = 2})
end

local autoTeleportGun = false
local autoTeleportGunConnection = nil

local function toggleAutoTeleportGun()
    autoTeleportGun = not autoTeleportGun
    if autoTeleportGun then
        if autoTeleportGunConnection then autoTeleportGunConnection:Disconnect() end
        autoTeleportGunConnection = runService.Heartbeat:Connect(function()
            if autoTeleportGun then
                local guns = {}
                for _, tool in pairs(workspace:GetDescendants()) do
                    if tool:IsA("Tool") and tool:FindFirstChild("Handle") and tool.Parent ~= character then
                        local name = tool.Name:lower()
                        if name:find("gun") or name:find("knife") or name:find("sword") or name:find("silah") then
                            table.insert(guns, tool)
                        end
                    end
                end
                if #guns > 0 then
                    local nearestGun, nearestDist = nil, math.huge
                    for _, gun in pairs(guns) do
                        local dist = (rootPart.Position - gun.Handle.Position).Magnitude
                        if dist < nearestDist and dist > 5 then
                            nearestDist = dist
                            nearestGun = gun
                        end
                    end
                    if nearestGun and nearestDist > 10 and nearestDist < 200 then
                        rootPart.CFrame = CFrame.new(nearestGun.Handle.Position + Vector3.new(0, 3, 0))
                        task.wait(0.3)
                    end
                end
            end
        end)
        starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "Auto Teleport Gun Aktif!", Duration = 2})
    else
        if autoTeleportGunConnection then autoTeleportGunConnection:Disconnect(); autoTeleportGunConnection = nil end
        starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "Auto Teleport Gun Devre Dışı.", Duration = 2})
    end
end

local function teleportToGun()
    local guns = {}
    for _, tool in pairs(workspace:GetDescendants()) do
        if tool:IsA("Tool") and tool:FindFirstChild("Handle") then
            local name = tool.Name:lower()
            if name:find("gun") or name:find("knife") or name:find("sword") or name:find("silah") then
                table.insert(guns, tool)
            end
        end
    end
    if #guns > 0 then
        local nearestGun, nearestDist = nil, math.huge
        for _, gun in pairs(guns) do
            local dist = (rootPart.Position - gun.Handle.Position).Magnitude
            if dist < nearestDist then
                nearestDist = dist
                nearestGun = gun
            end
        end
        if nearestGun then
            rootPart.CFrame = CFrame.new(nearestGun.Handle.Position + Vector3.new(0, 3, 0))
            starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "Silaha ışınlandın!", Duration = 2})
        end
    else
        starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "Silah bulunamadı!", Duration = 2})
    end
end

local function flingMurderer()
    local murderer = getMurderer()
    if murderer and murderer.Character then
        local tRoot = murderer.Character:FindFirstChild("HumanoidRootPart")
        local tHumanoid = murderer.Character:FindFirstChild("Humanoid")
        if tRoot and tHumanoid and tHumanoid.Health > 0 then
            tRoot.Velocity = Vector3.new(math.random(-20000,20000), math.random(15000,25000), math.random(-20000,20000))
            tHumanoid.PlatformStand = true
            task.wait(2)
            tHumanoid.PlatformStand = false
            starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "Katil uçuruldu!", Duration = 2})
        end
    else
        starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "Katil bulunamadı!", Duration = 2})
    end
end

local function flingSheriff()
    local sheriff = getSheriff()
    if sheriff and sheriff.Character then
        local tRoot = sheriff.Character:FindFirstChild("HumanoidRootPart")
        local tHumanoid = sheriff.Character:FindFirstChild("Humanoid")
        if tRoot and tHumanoid and tHumanoid.Health > 0 then
            tRoot.Velocity = Vector3.new(math.random(-20000,20000), math.random(15000,25000), math.random(-20000,20000))
            tHumanoid.PlatformStand = true
            task.wait(2)
            tHumanoid.PlatformStand = false
            starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "Şerif uçuruldu!", Duration = 2})
        end
    else
        starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "Şerif bulunamadı!", Duration = 2})
    end
end

local speedBoost = false
local speedBoostConnection = nil

local function toggleSpeedBoost()
    speedBoost = not speedBoost
    if speedBoost then
        if speedBoostConnection then speedBoostConnection:Disconnect() end
        speedBoostConnection = runService.Heartbeat:Connect(function()
            if speedBoost and humanoid and rootPart then
                local moveVector = humanoid.MoveDirection
                if moveVector.Magnitude > 0 then
                    rootPart.Velocity = moveVector * 300 + Vector3.new(0, rootPart.Velocity.Y, 0)
                end
                if humanoid:GetState() == Enum.HumanoidStateType.Jumping then
                    rootPart.Velocity = rootPart.Velocity + moveVector * 1500
                end
            end
        end)
        starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "Speed Boost Aktif!", Duration = 2})
    else
        if speedBoostConnection then speedBoostConnection:Disconnect(); speedBoostConnection = nil end
        starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "Speed Boost Devre Dışı.", Duration = 2})
    end
end

local bombJumpEnabled = false
local bombJumpConnection = nil
local bombJumpPower = 500
local bombJumpDelay = 0.2

local function toggleBombJump()
    bombJumpEnabled = not bombJumpEnabled
    if bombJumpEnabled then
        if bombJumpConnection then bombJumpConnection:Disconnect() end
        bombJumpConnection = runService.Heartbeat:Connect(function()
            if bombJumpEnabled and humanoid then
                if humanoid:GetState() == Enum.HumanoidStateType.Jumping then
                    humanoid.JumpPower = bombJumpPower
                    local explosion = Instance.new("Explosion")
                    explosion.BlastRadius = 10
                    explosion.BlastPressure = 500000
                    explosion.Position = rootPart.Position - Vector3.new(0, 2, 0)
                    explosion.Parent = workspace
                    task.wait(bombJumpDelay)
                    humanoid.JumpPower = 50
                end
            end
        end)
        starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "Bomb Jump Aktif!", Duration = 2})
    else
        if bombJumpConnection then bombJumpConnection:Disconnect(); bombJumpConnection = nil end
        humanoid.JumpPower = 50
        starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "Bomb Jump Devre Dışı.", Duration = 2})
    end
end

local sheriffDead = false
local sheriffCheckConnection = nil

local function checkSheriffDeath()
    if sheriffCheckConnection then sheriffCheckConnection:Disconnect() end
    sheriffCheckConnection = runService.Heartbeat:Connect(function()
        local sheriff = getSheriff()
        if sheriff and sheriff.Character then
            local hum = sheriff.Character:FindFirstChild("Humanoid")
            if hum and hum.Health <= 0 and not sheriffDead then
                sheriffDead = true
                starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "Şerif öldü! Silaha ışınlanıyorsun...", Duration = 2})
                task.wait(0.5)
                teleportToGun()
                task.wait(1)
                sheriffDead = false
            end
        end
    end)
end

checkSheriffDeath()

screenGui = Instance.new("ScreenGui")
screenGui.Name = "MEnserHub"
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false

mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 220, 0, 450)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.08)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.new(0.2, 0.05, 0.05)
titleBar.BackgroundTransparency = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

titleText = Instance.new("TextLabel")
titleText.Size = UDim2.new(0.6, 0, 1, 0)
titleText.Position = UDim2.new(0.05, 0, 0, 0)
titleText.BackgroundTransparency = 1
titleText.Text = "M.EnserHub"
titleText.TextColor3 = Color3.new(1, 0.3, 0.3)
titleText.TextSize = 14
titleText.Font = Enum.Font.GothamBold
titleText.TextXAlignment = Enum.TextXAlignment.Left
titleText.Parent = titleBar

local minimizeBtn = Instance.new("TextButton")
minimizeBtn.Size = UDim2.new(0, 25, 0, 25)
minimizeBtn.Position = UDim2.new(0.7, 0, 0, 5)
minimizeBtn.BackgroundColor3 = Color3.new(0.3, 0.3, 0.3)
minimizeBtn.BackgroundTransparency = 0
minimizeBtn.Text = "_"
minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
minimizeBtn.TextSize = 16
minimizeBtn.Font = Enum.Font.GothamBold
minimizeBtn.Parent = titleBar

local minCorner = Instance.new("UICorner")
minCorner.CornerRadius = UDim.new(0, 5)
minCorner.Parent = minimizeBtn

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 25, 0, 25)
closeBtn.Position = UDim2.new(0.85, 0, 0, 5)
closeBtn.BackgroundColor3 = Color3.new(1, 0.2, 0.2)
closeBtn.BackgroundTransparency = 0
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.new(1, 1, 1)
closeBtn.TextSize = 14
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Parent = titleBar

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 5)
closeCorner.Parent = closeBtn

local isMinimized = false
minimizeBtn.MouseButton1Click:Connect(function()
    isMinimized = not isMinimized
    if isMinimized then
        mainFrame.Size = UDim2.new(0, 220, 0, 35)
        scrollFrame.Visible = false
        minimizeBtn.Text = "+"
    else
        mainFrame.Size = UDim2.new(0, 220, 0, 450)
        scrollFrame.Visible = true
        minimizeBtn.Text = "_"
    end
end)

closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -45)
scrollFrame.Position = UDim2.new(0, 5, 0, 40)
scrollFrame.BackgroundTransparency = 1
scrollFrame.Parent = mainFrame
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)

local y = 5
local function addButton(text, func, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 28)
    btn.Position = UDim2.new(0, 5, 0, y)
    btn.Text = text
    btn.BackgroundColor3 = color or Color3.new(0.15, 0.15, 0.2)
    btn.BackgroundTransparency = 0
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.TextSize = 11
    btn.Font = Enum.Font.Gotham
    btn.BorderSizePixel = 0
    btn.Parent = scrollFrame
    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 5)
    btnCorner.Parent = btn
    btn.MouseButton1Click:Connect(function() pcall(func) end)
    y = y + 33
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, y + 10)
end

addButton("🎯 Aimbot", toggleAimbot, Color3.new(0.3, 0.1, 0.1))
addButton("🔫 Auto Shoot", toggleAutoShoot, Color3.new(0.2, 0.1, 0.2))
addButton("💀 Mass Kill (Sürekli)", toggleMassKill, Color3.new(0.3, 0.1, 0.1))
addButton("⚡ Mass Kill Tek", massKillOnce, Color3.new(0.3, 0.2, 0.1))
addButton("🔪 Nearby Kill (Sürekli)", toggleNearbyKill, Color3.new(0.2, 0.2, 0.1))
addButton("🔪 Nearby Kill Tek", nearbyKillOnce, Color3.new(0.2, 0.3, 0.1))
addButton("📦 Auto Teleport Gun", toggleAutoTeleportGun, Color3.new(0.1, 0.3, 0.2))
addButton("📦 Silaha Işınlan", teleportToGun, Color3.new(0.1, 0.2, 0.3))
addButton("👤 ESP (Tüm Roller)", toggleESP, Color3.new(0.1, 0.2, 0.1))
addButton("🔄 Fling Katil", flingMurderer, Color3.new(0.3, 0.1, 0.1))
addButton("🔄 Fling Şerif", flingSheriff, Color3.new(0.1, 0.1, 0.3))
addButton("💨 Speed Boost", toggleSpeedBoost, Color3.new(0.2, 0.3, 0.1))
addButton("💥 Bomb Jump", toggleBombJump, Color3.new(0.3, 0.2, 0.1))
addButton("🎨 Tema Değiştir", toggleTheme, Color3.new(0.2, 0.1, 0.3))

print("M.EnserHub Yüklendi!")
starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "13 Özellik Yüklendi!", Duration = 3})
