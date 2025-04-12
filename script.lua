--///////////////////////////////////////////
--// Integrated Script - All Functions //
--///////////////////////////////////////////

--------------------------------------------------
-- UI-Library (Kavo UI Library instead of Orion)
--------------------------------------------------
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("CoreHub EH Cheating Hub", "Ocean")

--------------------------------------------------
-- Create Tabs
--------------------------------------------------
local AimbotTab    = Window:NewTab("Aimbot")
local CarModTab    = Window:NewTab("Car Modifications")
local ESP_Tab      = Window:NewTab("ESP")
local MiscTab      = Window:NewTab("Misc")
local MainTab      = Window:NewTab("localPlayer")
local InfoTab      = Window:NewTab("Info")
local TrollTab     = Window:NewTab("Troll")
local ServerTab    = Window:NewTab("Server Infos")

-- Create Sections for each tab
local AimbotSection = AimbotTab:NewSection("Aimbot Settings")
local CarModSection = CarModTab:NewSection("Car Modifications")
local ESPSection = ESP_Tab:NewSection("ESP Settings")
local MiscSection = MiscTab:NewSection("Miscellaneous")
local MainSection = MainTab:NewSection("Client")
local PlayerSection = MainTab:NewSection("Player")
local InfoSection = InfoTab:NewSection("Information")
local TrollSection = TrollTab:NewSection("Troll Options")
local ServerSection = ServerTab:NewSection("Server Information")

--------------------------------------------------
-- Common Services & Variables
--------------------------------------------------
local Players          = game:GetService("Players")
local RunService       = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService  = game:GetService("TeleportService")
local HttpService      = game:GetService("HttpService")
local LocalPlayer      = Players.LocalPlayer
local cam              = workspace.CurrentCamera

--------------------------------------------------
-- [AIMBOT] - Functions
--------------------------------------------------
local aimbotEnabled = false
local aimPart = "HumanoidRootPart"
local teamCheck = true
local smoothness = 0.20

AimbotSection:NewToggle("Aimbot", "Toggles the aimbot functionality", function(state)
    aimbotEnabled = state
end)

AimbotSection:NewKeybind("Aimbot Keybind", "Press to toggle aimbot", Enum.KeyCode.V, function()
    aimbotEnabled = not aimbotEnabled
end)

AimbotSection:NewDropdown("Aim Part", "Select which part to aim at", {"Head", "HumanoidRootPart"}, function(currentOption)
    aimPart = currentOption
end)

AimbotSection:NewToggle("Team Check", "Don't target teammates", function(state)
    teamCheck = state
end)

AimbotSection:NewSlider("Aimbot Strength", "Adjust aimbot smoothness", 100, 10, function(value)
    smoothness = value / 100
end)

local function getClosestTarget()
    local cam = workspace.CurrentCamera
    local closestPlayer = nil
    local closestDistance = math.huge

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(aimPart) then
            if teamCheck and player.Team == LocalPlayer.Team then
                continue
            end

            local targetPos, onScreen = cam:WorldToScreenPoint(player.Character[aimPart].Position)
            if onScreen then
                local distance = (Vector2.new(targetPos.X, targetPos.Y) - Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y/2)).Magnitude
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = player
                end
            end
        end
    end

    return closestPlayer
end

RunService.RenderStepped:Connect(function()
    if aimbotEnabled and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        local target = getClosestTarget()
        if target and target.Character and target.Character:FindFirstChild(aimPart) then
            local targetPos = target.Character[aimPart].Position
            local currentLookAt = cam.CFrame.LookVector
            local targetLookAt = (targetPos - cam.CFrame.Position).Unit
            local newLookAt = currentLookAt:Lerp(targetLookAt, smoothness)
            cam.CFrame = CFrame.new(cam.CFrame.Position, cam.CFrame.Position + newLookAt)
        end
    end
end)

--------------------------------------------------
-- [CAR MODS] - Functions
--------------------------------------------------
local SpeedKey = Enum.KeyCode.LeftControl
local SpeedKeyMultiplier = 13
local FlightSpeed = 100
local FlightAcceleration = 11
local UserCharacter = nil
local UserRootPart = nil
local FlightConnection = nil
local Flying = false

local function setCharacter(character)
    UserCharacter = character
    UserRootPart = character:WaitForChild("HumanoidRootPart")
end
LocalPlayer.CharacterAdded:Connect(setCharacter)
if LocalPlayer.Character then setCharacter(LocalPlayer.Character) end

local CurrentVelocity = Vector3.new(0,0,0)
local function Flight(delta)
    local BaseVelocity = Vector3.new(0,0,0)
    if not UserInputService:GetFocusedTextBox() then
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then
            BaseVelocity = BaseVelocity + cam.CFrame.LookVector * FlightSpeed
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then
            BaseVelocity = BaseVelocity - cam.CFrame.LookVector * FlightSpeed
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then
            BaseVelocity = BaseVelocity - cam.CFrame.RightVector * FlightSpeed
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then
            BaseVelocity = BaseVelocity + cam.CFrame.RightVector * FlightSpeed
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
            BaseVelocity = BaseVelocity + Vector3.new(0, FlightSpeed, 0)
        end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
            BaseVelocity = BaseVelocity - Vector3.new(0, FlightSpeed, 0)
        end
        if UserInputService:IsKeyDown(SpeedKey) then
            BaseVelocity = BaseVelocity * SpeedKeyMultiplier
        end
    end
    if UserRootPart then
        local root = UserRootPart:GetRootPart()
        if root and not root.Anchored then
            CurrentVelocity = CurrentVelocity:Lerp(BaseVelocity, math.clamp(delta * FlightAcceleration, 0, 1))
            root.Velocity = CurrentVelocity + Vector3.new(0,2,0)
            root.CFrame = CFrame.lookAt(root.Position, root.Position + cam.CFrame.LookVector)
        end
    end
end

function ToggleFlight(enable)
    if enable then
        Flying = true
        FlightConnection = RunService.RenderStepped:Connect(Flight)
    else
        Flying = false
        if FlightConnection then
            FlightConnection:Disconnect()
            FlightConnection = nil
        end
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.X then
         ToggleFlight(not Flying)
    end
end)

CarModSection:NewLabel("Vehicle Fly Keybind: X")
CarModSection:NewSlider("Flight Speed", "Adjust flight speed", 190, 20, function(value)
    FlightSpeed = value
end)

local function enterVehicle()
    local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid and humanoid.SeatPart then
        humanoid.Sit = false
        humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
    end
end

CarModSection:NewButton("Enter Car", "Exit the current vehicle", function()
    enterVehicle()
end)

function serverHop()
    local placeId = game.PlaceId
    local serversApi = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100"
    local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
    if not playerGui then
        warn("PlayerGui not found!")
        return
    end
    local screenGui = Instance.new("ScreenGui", playerGui)
    screenGui.Name = "ServerSearchText"
    local textLabel = Instance.new("TextLabel", screenGui)
    textLabel.Size = UDim2.new(0.4, 0, 0.05, 0)
    textLabel.Position = UDim2.new(0.3, 0, 0.9, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "Looking for a new server... Made by c00lguy :D"
    textLabel.TextColor3 = Color3.new(1, 0, 0)
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.TextScaled = true
    spawn(function()
        while screenGui.Parent do
            for i = 0, 1, 0.01 do
                textLabel.TextColor3 = Color3.fromHSV(i, 1, 1)
                task.wait(0.05)
            end
        end
    end)
    task.delay(10, function()
        textLabel.Text = "We are sorry but the server hop failed"
        task.wait(1)
        screenGui:Destroy()
    end)
    while true do
        local success, response = pcall(function()
            return game:HttpGet(serversApi)
        end)
        if success and response then
            local data = HttpService:JSONDecode(response)
            if data and data.data then
                for _, server in ipairs(data.data) do
                    if server.playing < server.maxPlayers and server.id ~= game.JobId then
                        print("Free server found: " .. server.id)
                        screenGui:Destroy()
                        TeleportService:TeleportToPlaceInstance(placeId, server.id)
                        return
                    end
                end
            end
        end
        print("No server found. Searching again...")
        task.wait(5)
    end
end

MiscSection:NewButton("Server Hop", "Join a different server", function()
    serverHop()
end)

local function moveToPosition(Vehicle, destination, speed)
    if Vehicle and Vehicle.PrimaryPart then
        local diff = destination - Vehicle.PrimaryPart.Position
        local direction = diff.Unit
        Vehicle:SetPrimaryPartCFrame(Vehicle.PrimaryPart.CFrame:Lerp(CFrame.new(destination), 0.05))
    end
end

local running = false
local function autoFarm()
    local Character = LocalPlayer.Character
    if not Character then
        warn("Player character not found!")
        return
    end
    local Humanoid = Character:FindFirstChildWhichIsA("Humanoid")
    if not Humanoid or not Humanoid.SeatPart or not Humanoid.SeatPart:IsA("VehicleSeat") then
        warn("Player is not sitting in a vehicle!")
        return
    end
    local SeatPart = Humanoid.SeatPart
    local Vehicle = SeatPart.Parent
    if not Vehicle or not Vehicle:IsA("Model") then
        warn("No vehicle model found!")
        return
    end
    if not Vehicle.PrimaryPart then
        Vehicle.PrimaryPart = Vehicle:FindFirstChildWhichIsA("BasePart")
    end
    if not Vehicle.PrimaryPart then
        warn("Vehicle has no PrimaryPart!")
        return
    end
    while running do
        for _, destination in ipairs({
            Vector3.new(-1681.19, 10.18, -1262.23),
            Vector3.new(-1698.44, 232.60, -1249.67),
            Vector3.new(-974.89, 333.79, -1518.37),
            Vector3.new(-966.96, 10.19, -1520.92),
            Vector3.new(-1016.46, 373.71, -1523.31),
            Vector3.new(449.28, 343.82, -1525.49),
            Vector3.new(455.47, 10.18, -1516.97),
            Vector3.new(514.28, 469.11, -1507.60),
            Vector3.new(-988.95, 299.10, -1556.77),
            Vector3.new(-997.54, 10.18, -1563.18),
            Vector3.new(-985.69, 392.95, -1553.51),
            Vector3.new(-1116.60, 533.45, -260.89),
            Vector3.new(-1100.83, 10.20, -234.67),
            Vector3.new(-1109.38, 524.85, -265.78),
            Vector3.new(-1451.84, 698.98, 823.48),
            Vector3.new(-1456.86, 10.18, 789.07),
            Vector3.new(-1408.65, 493.05, 786.56),
            Vector3.new(-1778.05, 605.96, 2729.24),
            Vector3.new(-1543.54, 530.30, 2736.57),
            Vector3.new(-1522.59, 10.16, 2732.81),
            Vector3.new(-1652.04, 575.36, 2730.64),
            Vector3.new(-883.61, 525.79, 2732.55),
            Vector3.new(-852.89, 10.16, 2734.87),
            Vector3.new(-874.54, 693.48, 2747.84),
            Vector3.new(-294.54, 762.64, 3596.54),
            Vector3.new(-330.82, 10.18, 3622.39),
            Vector3.new(-278.73, 397.32, 3618.05),
            Vector3.new(-858.61, 514.71, 2698.35),
            Vector3.new(-886.25, 10.16, 2693.42),
            Vector3.new(-859.37, 512.87, 2696.70),
            Vector3.new(-1537.10, 228.78, 2685.75),
            Vector3.new(-1555.95, 10.20, 2693.96),
            Vector3.new(-1539.72, 724.35, 2689.17),
            Vector3.new(-1439.12, 718.88, 826.53),
            Vector3.new(-1416.24, 10.21, 831.46),
            Vector3.new(-1448.49, 725.31, 829.72),
            Vector3.new(-1079.40, 702.66, -245.85),
            Vector3.new(-1076.40, 974.83, -243.18),
            Vector3.new(-1089.55, 10.17, -267.41)
        }) do
            if not running then break end
            print("Moving to:", destination)
            moveToPosition(Vehicle, destination, 120)
            wait(1)
        end
    end
    print("AutoFarm ended.")
end

MiscSection:NewToggle("AutoFarm", "Automatically farm locations", function(state)
    running = state
    if running then
        task.spawn(autoFarm)
    end
end)

local isRunning = false
local function antiFallOut()
    while isRunning do
        wait(0.1)
        enterVehicle()
    end
end

local function spawnTrain()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local trainsFolder = ReplicatedStorage:FindFirstChild("Trains")
    if trainsFolder then
        local trainModel = trainsFolder:FindFirstChild("HB IC")
        if trainModel and trainModel:IsA("Model") then
            local clonedTrain = trainModel:Clone()
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart
                local spawnPosition = hrp.Position + hrp.CFrame.LookVector * 5
                local modelCFrame = clonedTrain:GetModelCFrame()
                local offset = spawnPosition - modelCFrame.Position
                for _, descendant in ipairs(clonedTrain:GetDescendants()) do
                    if descendant:IsA("BasePart") then
                        descendant.Position = descendant.Position + offset
                    end
                end
                clonedTrain.Parent = workspace
                print("Model successfully spawned in front of player!")
            else
                warn("Character or HumanoidRootPart not found!")
            end
        else
            warn("HB IC was not found in 'Trains' folder or is not a model!")
        end
    else
        warn("The 'Trains' folder was not found in ReplicatedStorage!")
    end
end

TrollSection:NewButton("Spawn HB IC (Train)", "Spawns a train in front of you", function()
    spawnTrain()
end)

local function spawnTrain2()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local trainsFolder = ReplicatedStorage:FindFirstChild("Trains")
    if trainsFolder then
        local trainModel = trainsFolder:FindFirstChild("HB Regio")
        if trainModel and trainModel:IsA("Model") then
            local clonedTrain = trainModel:Clone()
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart
                local spawnPosition = hrp.Position + hrp.CFrame.LookVector * 5
                local modelCFrame = clonedTrain:GetModelCFrame()
                local offset = spawnPosition - modelCFrame.Position
                for _, descendant in ipairs(clonedTrain:GetDescendants()) do
                    if descendant:IsA("BasePart") then
                        descendant.Position = descendant.Position + offset
                    end
                end
                clonedTrain.Parent = workspace
                print("Model successfully spawned in front of player!")
            else
                warn("Character or HumanoidRootPart not found!")
            end
        else
            warn("HB Regio was not found in 'Trains' folder or is not a model!")
        end
    else
        warn("The 'Trains' folder was not found in ReplicatedStorage!")
    end
end

TrollSection:NewButton("Spawn HB Regio (Train)", "Spawns a regional train in front of you", function()
    spawnTrain2()
end)

local function spawnAdminCar()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local VehiclesFolder = ReplicatedStorage:FindFirstChild("Vehicles")
    if VehiclesFolder then
        local vehicleModel = VehiclesFolder:FindFirstChild("BMW M5 Admin")
        if vehicleModel and vehicleModel:IsA("Model") then
            local clonedVehicle = vehicleModel:Clone()
            local character = LocalPlayer.Character
            if character and character:FindFirstChild("HumanoidRootPart") then
                local hrp = character.HumanoidRootPart
                local spawnPosition = hrp.Position + hrp.CFrame.LookVector * 5
                local modelCFrame = clonedVehicle:GetModelCFrame()
                local offset = spawnPosition - modelCFrame.Position
                for _, descendant in ipairs(clonedVehicle:GetDescendants()) do
                    if descendant:IsA("BasePart") then
                        descendant.Position = descendant.Position + offset
                    end
                end
                clonedVehicle.Parent = workspace
            end
        end
    end
end

TrollSection:NewButton("Spawn Admin Car", "Spawns an admin car in front of you", function()
    spawnAdminCar()
end)

function tpPlayer(targetPosition)
    local player = LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if humanoidRootPart then
        local seat = Instance.new("Seat")
        seat.Size = Vector3.new(2,1,2)
        seat.Anchored = true
        seat.CanCollide = false
        seat.Transparency = 1
        seat.CFrame = CFrame.new(targetPosition)
        seat.Parent = workspace
        local humanoid = character:FindFirstChildOfClass("Humanoid")
        if humanoid then
            humanoid.Sit = true
        end
        humanoidRootPart.CFrame = CFrame.new(targetPosition)
        task.delay(1, function()
            if seat and seat.Parent then seat:Destroy() end
        end)
    else
        warn("HumanoidRootPart not found!")
    end
end

local function applyRainbowEffect()
    local player = LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local running = true
    local rainbowColors = {
        Color3.fromRGB(255, 0, 0),
        Color3.fromRGB(255, 165, 0),
        Color3.fromRGB(255, 255, 0),
        Color3.fromRGB(0, 255, 0),
        Color3.fromRGB(0, 0, 255),
        Color3.fromRGB(128, 0, 128),
        Color3.fromRGB(255, 20, 147)
    }
    local function isCarPart(part)
        local partName = part.Name:lower()
        return partName:find("wheel") or partName:find("chassis") or partName:find("body")
    end
    local carParts = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and isCarPart(obj) then
            table.insert(carParts, obj)
        end
    end
    local colorIndex = 1
    local nextColorIndex = 2
    local transitionStep = 0
    while running do
        for _, obj in ipairs(carParts) do
            if obj and obj.Parent then
                local distance = (obj.Position - character.HumanoidRootPart.Position).Magnitude
                if distance < 10 then
                    local currentColor = rainbowColors[colorIndex]
                    local nextColor = rainbowColors[nextColorIndex]
                    local interpolatedColor = currentColor:Lerp(nextColor, transitionStep)
                    obj.Color = interpolatedColor
                end
            end
        end
        transitionStep = transitionStep + 0.05
        if transitionStep >= 1 then
            transitionStep = 0
            colorIndex = nextColorIndex
            nextColorIndex = (nextColorIndex % #rainbowColors) + 1
        end
        task.wait(0.05)
    end
end

CarModSection:NewToggle("Rainbow Car", "Makes your car change colors", function(state)
    running = state
    if running then
        task.spawn(applyRainbowEffect)
    end
end)

local toggleActive = false
local function updateHealth()
    local vehiclesFolder = workspace:FindFirstChild("Vehicles")
    if vehiclesFolder then
        for _, vehicle in ipairs(vehiclesFolder:GetChildren()) do
            if vehicle:IsA("Model") then
                if toggleActive then
                    vehicle:SetAttribute("CurrentHealth", 0.99)
                end
            end
        end
    end
end

CarModSection:NewToggle("God Car", "Makes your car invincible", function(value)
    toggleActive = value
    updateHealth()
end)

CarModSection:NewButton("Always Working", "Keeps your car running", function() 
    updateIsOn() 
end)

local function updateIsOn()
    local vehiclesFolder = workspace:FindFirstChild("Vehicles")
    if vehiclesFolder then
        for _, vehicle in ipairs(vehiclesFolder:GetChildren()) do
            if vehicle:IsA("Model") then
                vehicle:SetAttribute("IsOn", true)
            end
        end
    end
end

--------------------------------------------------
-- [ESP] - Basic & Advanced Functions
--------------------------------------------------
local espEnabled = false
local espBoxEnabled = false
local espNameEnabled = false
local espTracerEnabled = false
local espHealthEnabled = false

ESPSection:NewToggle("Enable ESP (Basic)", "Toggles ESP functionality", function(Value) 
    espEnabled = Value 
end)

ESPSection:NewToggle("Box ESP", "Shows boxes around players", function(Value) 
    espBoxEnabled = Value 
end)

ESPSection:NewToggle("Name/Distance/Role ESP", "Shows player info", function(Value) 
    espNameEnabled = Value 
end)

ESPSection:NewToggle("Tracer ESP", "Shows lines to players", function(Value) 
    espTracerEnabled = Value 
end)

ESPSection:NewToggle("Health ESP", "Shows player health", function(Value) 
    espHealthEnabled = Value 
end)

local espObjects = {}
local function CreateESP(player)
    if espObjects[player] then return end
    local esp = {}
    esp.BoxOutline = Drawing.new("Square")
    esp.BoxOutline.Thickness = 4
    esp.BoxOutline.Filled = false
    esp.BoxOutline.Color = Color3.new(0,0,0)
    esp.BoxOutline.Transparency = 1
    esp.BoxOutline.Visible = false

    esp.Box = Drawing.new("Square")
    esp.Box.Thickness = 2
    esp.Box.Filled = false
    esp.Box.Color = Color3.fromRGB(255,0,255)
    esp.Box.Transparency = 1
    esp.Box.Visible = false

    esp.Name = Drawing.new("Text")
    esp.Name.Size = 13
    esp.Name.Color = Color3.new(1,1,1)
    esp.Name.Center = true
    esp.Name.Outline = true
    esp.Name.Visible = false

    esp.Tracer = Drawing.new("Line")
    esp.Tracer.Color = Color3.fromRGB(255,0,255)
    esp.Tracer.Thickness = 1
    esp.Tracer.Visible = false

    esp.HealthBack = Drawing.new("Square")
    esp.HealthBack.Color = Color3.new(0,0,0)
    esp.HealthBack.Thickness = 1
    esp.HealthBack.Filled = true
    esp.HealthBack.Transparency = 0.5
    esp.HealthBack.Visible = false

    esp.HealthFill = Drawing.new("Square")
    esp.HealthFill.Color = Color3.new(0,1,0)
    esp.HealthFill.Thickness = 1
    esp.HealthFill.Filled = true
    esp.HealthFill.Transparency = 0.5
    esp.HealthFill.Visible = false

    espObjects[player] = esp
end

local function RemoveESP(player)
    if espObjects[player] then
        for _, obj in pairs(espObjects[player]) do
            obj:Remove()
        end
        espObjects[player] = nil
    end
end

for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        if player.Character then CreateESP(player) end
        player.CharacterAdded:Connect(function() CreateESP(player) end)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        player.CharacterAdded:Connect(function() CreateESP(player) end)
    end
end)

Players.PlayerRemoving:Connect(function(player)
    RemoveESP(player)
end)

RunService.RenderStepped:Connect(function()
    if not espEnabled then
        for _, esp in pairs(espObjects) do
            for _, obj in pairs(esp) do
                obj.Visible = false
            end
        end
        return
    end
    for player, esp in pairs(espObjects) do
        local char = player.Character
        if char then
            local head = char:FindFirstChild("Head")
            local root = char:FindFirstChild("HumanoidRootPart")
            local humanoid = char:FindFirstChild("Humanoid")
            if head and root and humanoid and humanoid.Health > 0 then
                local headPos, headVis = cam:WorldToViewportPoint(head.Position)
                local rootPos, rootVis = cam:WorldToViewportPoint(root.Position)
                if headVis and rootVis then
                    local boxHeight = math.abs(rootPos.Y - headPos.Y)
                    local boxWidth = boxHeight * 0.65
                    local boxX = rootPos.X - boxWidth/2
                    local boxY = headPos.Y
                    if espBoxEnabled then
                        esp.BoxOutline.Visible = true
                        esp.BoxOutline.Position = Vector2.new(boxX, boxY)
                        esp.BoxOutline.Size = Vector2.new(boxWidth, boxHeight)
                        esp.Box.Visible = true
                        esp.Box.Position = Vector2.new(boxX, boxY)
                        esp.Box.Size = Vector2.new(boxWidth, boxHeight)
                    else
                        esp.BoxOutline.Visible = false
                        esp.Box.Visible = false
                    end
                    if espNameEnabled then
                        local distance = (root.Position - cam.CFrame.Position).Magnitude
                        esp.Name.Visible = true
                        esp.Name.Text = string.format("%s\n[%.0f]", player.Name, distance)
                        esp.Name.Position = Vector2.new(headPos.X, headPos.Y - 35)
                    else
                        esp.Name.Visible = false
                    end
                    if espTracerEnabled then
                        esp.Tracer.Visible = true
                        esp.Tracer.From = Vector2.new(cam.ViewportSize.X/2, cam.ViewportSize.Y - 5)
                        esp.Tracer.To = Vector2.new(rootPos.X, rootPos.Y)
                    else
                        esp.Tracer.Visible = false
                    end
                    if espHealthEnabled then
                        esp.HealthBack.Visible = true
                        esp.HealthFill.Visible = true
                        local healthPercent = humanoid.Health / humanoid.MaxHealth
                        local barHeight = boxHeight
                        local barWidth = 4
                        local barX = boxX - (barWidth + 2)
                        local barY = boxY
                        esp.HealthBack.Position = Vector2.new(barX, barY)
                        esp.HealthBack.Size = Vector2.new(barWidth, barHeight)
                        local fillHeight = math.clamp(barHeight * healthPercent, 0, barHeight)
                        esp.HealthFill.Position = Vector2.new(barX, barY + (boxHeight - fillHeight))
                        esp.HealthFill.Size = Vector2.new(barWidth, fillHeight)
                    else
                        esp.HealthBack.Visible = false
                        esp.HealthFill.Visible = false
                    end
                else
                    for _, obj in pairs(esp) do obj.Visible = false end
                end
            else
                for _, obj in pairs(esp) do obj.Visible = false end
            end
        else
            for _, obj in pairs(esp) do obj.Visible = false end
        end
    end
end)

--------------------------------------------------
-- [MISC] - Various Functions
--------------------------------------------------
local toggleSpeedHack = false
MiscSection:NewToggle("SpeedHack", "Increases movement speed", function(Value)
    toggleSpeedHack = Value
end)

MiscSection:NewKeybind("SpeedBind", "Toggle speed hack with key", Enum.KeyCode.T, function()
    toggleSpeedHack = not toggleSpeedHack
end)

local stepSize = 0.25
RunService.Heartbeat:Connect(function()
    if toggleSpeedHack and LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if humanoid then
            local direction = humanoid.MoveDirection
            if direction.Magnitude > 0 then
                LocalPlayer.Character:SetPrimaryPartCFrame(LocalPlayer.Character.PrimaryPart.CFrame + direction.Unit * stepSize)
            end
        end
    end
end)

local Noclipping
local Clip = true
MiscSection:NewToggle("Noclip", "Walk through walls", function(Value)
    if Value then
        Clip = false
        Noclipping = RunService.Stepped:Connect(function()
            if LocalPlayer.Character then
                for _, child in pairs(LocalPlayer.Character:GetDescendants()) do
                    if child:IsA("BasePart") and child.CanCollide then
                        child.CanCollide = false
                    end
                end
            end
        end)
    else
        if Noclipping then Noclipping:Disconnect() end
        Clip = true
    end
end)

MiscSection:NewButton("Fling", "Creates a fling GUI", function()
    local ScreenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    ScreenGui.ResetOnSpawn = false
    local Frame = Instance.new("Frame", ScreenGui)
    Frame.BackgroundColor3 = Color3.new(0,0,0)
    Frame.BorderColor3 = Color3.new(1,1,1)
    Frame.Position = UDim2.new(0.4,0,0.4,0)
    Frame.Size = UDim2.new(0,107,0,69)
    local TextButton = Instance.new("TextButton", Frame)
    TextButton.BackgroundColor3 = Color3.new(0,0,0)
    TextButton.BorderColor3 = Color3.new(1,1,1)
    TextButton.Position = UDim2.new(0.11,0,0.45,0)
    TextButton.Size = UDim2.new(0,83,0,31)
    TextButton.Font = Enum.Font.SourceSans
    TextButton.Text = "OFF"
    TextButton.TextColor3 = Color3.new(1,1,1)
    TextButton.TextSize = 20
    local CloseButton = Instance.new("TextButton", Frame)
    CloseButton.BackgroundColor3 = Color3.fromRGB(255,0,0)
    CloseButton.BorderColor3 = Color3.new(1,1,1)
    CloseButton.Position = UDim2.new(0.86,0,0.02,0)
    CloseButton.Size = UDim2.new(0,16,0,16)
    CloseButton.Font = Enum.Font.SourceSansBold
    CloseButton.Text = "X"
    CloseButton.TextColor3 = Color3.new(0,0,0)
    CloseButton.TextSize = 12
    TextButton.MouseButton1Click:Connect(function()
        if TextButton.Text == "OFF" then TextButton.Text = "ON" else TextButton.Text = "OFF" end
    end)
    CloseButton.MouseButton1Click:Connect(function() Frame:Destroy() end)
end)

MiscSection:NewButton("INF Stamina", "Gives infinite stamina", function()
    if not getfenv().firsttime then
        getfenv().firsttime = true
        local func
        for i, v in pairs(getgc(true)) do
            if type(v) == "function" and debug.getinfo(v).name == "setStamina" then
                func = v
                break
            end
        end
        if func then
            hookfunction(func, function(...)
                local args = {...}
                return args[1], math.huge
            end)
        end
    end
end)

MiscSection:NewToggle("Anti-Fall", "Prevents falling damage", function(state)
    if state then
        getfenv().ANTIFALL = true
        getfenv().nofall = RunService.RenderStepped:Connect(function()
            if LocalPlayer.Character then
                local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local ray = workspace:Raycast(hrp.Position, Vector3.new(0,-20,0))
                    if ray and hrp.Velocity.Y < -30 then
                        hrp.Velocity = Vector3.new(0,0,0)
                    end
                end
            end
        end)
    else
        getfenv().ANTIFALL = false
        if getfenv().nofall then getfenv().nofall:Disconnect() end
    end
end)

local antiDownedConnection
MiscSection:NewToggle("Anti Downed", "Prevents getting downed", function(state)
    if LocalPlayer.Character then
        local humanoid = LocalPlayer.Character:WaitForChild("Humanoid")
        if state then
            antiDownedConnection = humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                humanoid.Health = 100
            end)
        else
            if antiDownedConnection then
                antiDownedConnection:Disconnect()
                antiDownedConnection = nil
            end
        end
    end
end)

MiscSection:NewButton("Escape Car", "Exit current vehicle", function()
    enterVehicle()
end)

local xrayEnabled = false
MiscSection:NewToggle("Xray", "See through walls", function(Value)
    xrayEnabled = Value
    for _, part in ipairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and not part.Parent:FindFirstChildWhichIsA("Humanoid") then
            part.LocalTransparencyModifier = xrayEnabled and 0.5 or 0
        end
    end
end)

local clickToDeleteEnabled = false
local clickToDeleteConnection
local function toggleClickToDelete(enable)
    local mouse = LocalPlayer:GetMouse()
    if enable then
        clickToDeleteConnection = mouse.Button1Down:Connect(function()
            if mouse.Target then mouse.Target:Destroy() end
        end)
    elseif clickToDeleteConnection then
        clickToDeleteConnection:Disconnect()
        clickToDeleteConnection = nil
    end
end

MiscSection:NewToggle("Click To Delete", "Delete objects by clicking", function(Value)
    clickToDeleteEnabled = Value
    toggleClickToDelete(clickToDeleteEnabled)
end)

local infinityJumpEnabled = false
local function toggleInfinityJump(enable)
    if enable then
        UserInputService.JumpRequest:Connect(function()
            if infinityJumpEnabled and LocalPlayer.Character then
                local humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end
        end)
    end
end

MiscSection:NewToggle("Infinity Jump", "Jump without limits", function(Value)
    infinityJumpEnabled = Value
    toggleInfinityJump(infinityJumpEnabled)
end)

local rainbowColorsChar = {
    Color3.fromRGB(255, 0, 0),
    Color3.fromRGB(255, 127, 0),
    Color3.fromRGB(255, 255, 0),
    Color3.fromRGB(0, 255, 0),
    Color3.fromRGB(0, 0, 255),
    Color3.fromRGB(75, 0, 130),
    Color3.fromRGB(148, 0, 211),
    Color3.fromRGB(255, 255, 255)
}
local currentColorIndex = 1
local changingColors = false
local function changeColor()
    if LocalPlayer.Character then
        local newColor = rainbowColorsChar[currentColorIndex]
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("MeshPart") then
                part.Color = newColor
            end
        end
        currentColorIndex = (currentColorIndex % #rainbowColorsChar) + 1
    else
        warn("Character not found!")
    end
end
local function toggleColorChange(state)
    changingColors = state
    if changingColors then
        spawn(function()
            while changingColors do
                changeColor()
                task.wait(0.6)
            end
        end)
    end
end

MainSection:NewToggle("Rainbow Character", "Makes your character change colors", function(Value)
    toggleColorChange(Value)
end)

local isForceField = false
local function toggleMaterial(state)
    isForceField = state
    if LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("MeshPart") then
                part.Material = isForceField and Enum.Material.ForceField or Enum.Material.Plastic
            end
        end
    end
end

MainSection:NewToggle("Ghost Body", "Makes your character transparent", function(Value)
    toggleMaterial(Value)
end)

local antiFallDamageEnabled = false
local function toggleAntiFallDamage(enable)
    if enable then
        RunService.RenderStepped:Connect(function()
            if antiFallDamageEnabled and LocalPlayer.Character then
                local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Velocity.Y < -50 then
                    hrp.Velocity = Vector3.new(hrp.Velocity.X, -5, hrp.Velocity.Z)
                    hrp.CFrame = hrp.CFrame * CFrame.new(0, -0.1, 0)
                end
            end
        end)
    end
end

PlayerSection:NewToggle("Anti Fall Damage", "Prevents fall damage", function(Value)
    antiFallDamageEnabled = Value
    toggleAntiFallDamage(antiFallDamageEnabled)
end)

PlayerSection:NewToggle("Infinity Jump", "Jump without limits", function(Value)
    infinityJumpEnabled = Value
    toggleInfinityJump(infinityJumpEnabled)
end)

--------------------------------------------------
-- [INFO] Tab
--------------------------------------------------
InfoSection:NewButton("Discord: CoreHub.lol", "Copies Discord link", function()
    local link = "https://discord.gg/2kyywkEnNu"
    setclipboard(link)
    Library:MakeNotification({
        Name = "Link Copied!",
        Content = "Discord link has been copied.",
        Time = 5
    })
end)

InfoSection:NewButton("Discord: X Reselling", "Copies Discord link", function()
    local link = "https://discord.gg/xreselling"
    setclipboard(link)
    Library:MakeNotification({
        Name = "Link Copied!",
        Content = "Discord link has been copied.",
        Time = 5
    })
end)

InfoSection:NewSection("User Feedback")
local function SendMessageEMBED(url, embed)
    local headers = { ["Content-Type"] = "application/json" }
    local data = {
        ["embeds"] = {
            {
                ["title"] = embed.title,
                ["description"] = embed.description,
                ["color"] = embed.color,
                ["fields"] = embed.fields,
                ["footer"] = { ["text"] = embed.footer.text },
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
        }
    }
    local body = HttpService:JSONEncode(data)
    local response = request({
        Url = url,
        Method = "POST",
        Headers = headers,
        Body = body
    })
    print("Embed sent to Discord.")
end

local webhookUrl = "https://discord.com/api/webhooks/1340051437173866546/0ZCOu_5ByZIDEkuniR9LjQCjjHBu8HbxeYedp2IJNxeYyZ6TUOraxtjmf3Cd6fe-7kBP"
local userRating = 0
local userComment = ""
local startTime = tick()

InfoSection:NewDropdown("Rate the script (1-5)", "Select a rating", {"1", "2", "3", "4", "5"}, function(value)
    userRating = tonumber(value)
    print("User selected rating:", userRating)
end)

InfoSection:NewTextBox("Leave a comment (optional)", "Type your feedback", function(value)
    userComment = value
    print("User comment:", userComment)
end)

InfoSection:NewButton("Submit Rating", "Send your feedback", function()
    if userRating > 0 then
        local playTime = math.floor(tick() - startTime)
        local player = LocalPlayer
        local stars = string.rep("⭐", userRating)
        local embed = {
            title = "Script Rating Received!",
            description = "A user has rated your script.",
            color = 16766720,
            fields = {
                { name = "Username", value = player.Name, inline = true },
                { name = "User ID", value = tostring(player.UserId), inline = true },
                { name = "Server ID", value = game.JobId, inline = false },
                { name = "Rating", value = tostring(userRating) .. " / 5 " .. stars, inline = true },
                { name = "Playtime", value = tostring(playTime) .. " seconds", inline = true },
                { name = "Comment", value = userComment ~= "" and userComment or "No comment provided.", inline = false },
                { name = "Place ID", value = tostring(game.PlaceId), inline = false }
            },
            footer = { text = "Rating System" }
        }
        SendMessageEMBED(webhookUrl, embed)
        Library:MakeNotification({
            Name = "Thank You!",
            Content = "Your feedback has been submitted. We appreciate it!",
            Time = 5
        })
    else
        Library:MakeNotification({
            Name = "Error",
            Content = "Please select a rating before submitting.",
            Time = 5
        })
    end
end)

--------------------------------------------------
-- [ServerTab] - Team Statistics
--------------------------------------------------
local teamLabels = {}
local function createTeamLabels()
    for _, team in pairs(game:GetService("Teams"):GetChildren()) do
        local count = #team:GetPlayers()
        local label = ServerSection:NewLabel(team.Name .. " - Players: " .. count)
        teamLabels[team.Name] = label
    end
end

local function updateTeamLabels()
    for teamName, label in pairs(teamLabels) do
        local team = game:GetService("Teams"):FindFirstChild(teamName)
        if team then
            local playerCount = #team:GetPlayers()
            label:UpdateLabel(teamName .. " - Players: " .. playerCount)
        end
    end
end

createTeamLabels()
task.spawn(function() 
    while task.wait(1) do 
        updateTeamLabels() 
    end 
end)

--------------------------------------------------
-- Initialize UI
--------------------------------------------------
Library:ToggleUI()
