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

local function getEnemies()
    local list = {}
    for _, p in pairs(players:GetPlayers()) do if p ~= player and p.Character then table.insert(list, p) end end
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

local function getPlayerRole(p)
    if not p or not p.Character then return "Masum" end
    local hum = p.Character:FindFirstChild("Humanoid")
    if not hum then return "Masum" end
    if hum:FindFirstChild("Murderer") or hum:FindFirstChild("Katil") or hum:FindFirstChild("Killer") then return "Katil"
    elseif hum:FindFirstChild("Sheriff") or hum:FindFirstChild("Serif") or hum:FindFirstChild("Sherif") then return "Serif"
    elseif hum:FindFirstChild("Hero") or hum:FindFirstChild("Kahraman") then return "Kahraman"
    else return "Masum" end
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

local aimbotEnabled = false
local aimbotConnection = nil

local function toggleAimbot()
    aimbotEnabled = not aimbotEnabled
    if aimbotEnabled then
        if aimbotConnection then aimbotConnection:Disconnect() end
        aimbotConnection = runService.RenderStepped:Connect(function()
            if aimbotEnabled then
                local target = getMurderer() or getNearest()
                if target and target.Character then
                    local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
                    local tHead = target.Character:FindFirstChild("Head")
                    local tHumanoid = target.Character:FindFirstChild("Humanoid")
                    if tRoot and tHumanoid and tHumanoid.Health > 0 then
                        local aimPart = tHead or tRoot
                        local viewportPoint = camera:WorldToViewportPoint(aimPart.Position)
                        local mouse = player:GetMouse()
                        local currentPos = Vector2.new(mouse.X, mouse.Y)
                        local targetPos2D = Vector2.new(viewportPoint.X, viewportPoint.Y)
                        local newPos = currentPos:Lerp(targetPos2D, 0.05)
                        mouse.Move(newPos)
                        if (rootPart.Position - tRoot.Position).Magnitude < 300 then
                            local tool = character:FindFirstChildOfClass("Tool")
                            if tool then tool:Activate(); task.wait(0.02); tool:Activate(); task.wait(0.02) end
                        end
                    end
                end
            end
        end)
        starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "Aimbot Aktif!", Duration = 2})
    else
        if aimbotConnection then aimbotConnection:Disconnect(); aimbotConnection = nil end
        starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "Aimbot Devre Dışı.", Duration = 2})
    end
end

local autoShoot = false
local autoShootConnection = nil

local function toggleAutoShoot()
    autoShoot = not autoShoot
    if autoShoot then
        if autoShootConnection then autoShootConnection:Disconnect() end
        autoShootConnection = runService.Heartbeat:Connect(function()
            if autoShoot then
                local target = getMurderer() or getNearest()
                if target and target.Character then
                    local tRoot = target.Character:FindFirstChild("HumanoidRootPart")
                    local tHumanoid = target.Character:FindFirstChild("Humanoid")
                    if tRoot and tHumanoid and tHumanoid.Health > 0 and (rootPart.Position - tRoot.Position).Magnitude < 350 then
                        local tool = character:FindFirstChildOfClass("Tool")
                        if tool then tool:Activate(); task.wait(0.02); tool:Activate(); task.wait(0.02) end
                    end
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
                            if tool then tool:Activate(); task.wait(0.03); tool:Activate(); task.wait(0.03) end
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
                if tool then tool:Activate(); task.wait(0.02); tool:Activate(); task.wait(0.02) end
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
                        if tHumanoid and tHumanoid.Health > 0 then tHumanoid.Health = 0; task.wait(0.05) end
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
            if tHumanoid and tHumanoid.Health > 0 then tHumanoid.Health = 0; killed = killed + 1; task.wait(0.05) end
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
                        if dist < nearestDist and dist > 5 then nearestDist = dist; nearestGun = gun end
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
            if dist < nearestDist then nearestDist = dist; nearestGun = gun end
        end
        if nearestGun then
            rootPart.CFrame = CFrame.new(nearestGun.Handle.Position + Vector3.new(0, 3, 0))
            starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "Silaha ışınlandın!", Duration = 2})
        end
    else
        starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "Silah bulunamadı!", Duration = 2})
    end
end

local espEnabled = false
local espObjects = {}

local function toggleESP()
    espEnabled = not espEnabled
    if espEnabled then
        for _, p in pairs(players:GetPlayers()) do
            if p ~= player and p.Character then
                local char = p.Character
                local hum = char:FindFirstChild("Humanoid")
                if hum then
                    local role = getPlayerRole(p)
                    local color = getPlayerColor(p)
                    local highlight = Instance.new("Highlight")
                    highlight.Adornee = char
                    highlight.FillColor = color
                    highlight.FillTransparency = 0.2
                    highlight.OutlineColor = Color3.new(1, 1, 1)
                    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
                    highlight.Parent = char
                    table.insert(espObjects, highlight)
                    local head = char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
                    if head then
                        local bill = Instance.new("BillboardGui")
                        bill.Size = UDim2.new(0, 120, 0, 40)
                        bill.AlwaysOnTop = true
                        bill.Parent = head
                        local label = Instance.new("TextLabel")
                        label.Size = UDim2.new(1, 0, 1, 0)
                        label.BackgroundTransparency = 1
                        label.Text = p.Name .. " [" .. role .. "]"
                        label.TextColor3 = color
                        label.TextSize = 16
                        label.Font = Enum.Font.GothamBold
                        label.TextStrokeTransparency = 0
                        label.TextStrokeColor3 = Color3.new(0, 0, 0)
                        label.Parent = bill
                        table.insert(espObjects, bill)
                    end
                end
            end
        end
        starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "ESP Aktif!", Duration = 2})
    else
        for _, obj in pairs(espObjects) do obj:Destroy() end
        espObjects = {}
        starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "ESP Devre Dışı.", Duration = 2})
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
            task.wait(3)
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
            task.wait(3)
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

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "MEnserHub"
screenGui.Parent = player.PlayerGui
screenGui.ResetOnSpawn = false

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 200, 0, 400)
mainFrame.Position = UDim2.new(0, 10, 0, 10)
mainFrame.BackgroundColor3 = Color3.new(0.05, 0.05, 0.08)
mainFrame.BackgroundTransparency = 0.1
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 35)
titleBar.BackgroundColor3 = Color3.new(0.2, 0.05, 0.05)
titleBar.BackgroundTransparency = 0
titleBar.Parent = mainFrame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = titleBar

local titleText = Instance.new("TextLabel")
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
        mainFrame.Size = UDim2.new(0, 200, 0, 35)
        scrollFrame.Visible = false
        minimizeBtn.Text = "+"
    else
        mainFrame.Size = UDim2.new(0, 200, 0, 400)
        scrollFrame.Visible = true
        minimizeBtn.Text = "_"
    end
end)

closeBtn.MouseButton1Click:Connect(function() screenGui:Destroy() end)

local scrollFrame = Instance.new("ScrollingFrame")
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

print("M.EnserHub Yüklendi!")
starterGui:SetCore("SendNotification", {Title = "M.EnserHub", Text = "12 Özellik Yüklendi!", Duration = 3})
