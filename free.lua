loadstring(game:HttpGet("https://raw.githubusercontent.com/asldsaldle12/as22121/refs/heads/main/freewarning.lua"))()
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local balls = {}
local lastRefreshTime = os.time()
local reach = 10

local reachCircle = nil
local ballOwners = {}
local ballColor = Color3.new(1, 0, 0)
local reachColor = Color3.new(0, 0, 1)
local ballNames = {"TPS", "ESA", "MRS", "PRS", "MPS", "XYZ", "ABC", "LMN", "TRS"}

local function refreshBalls(force)
    if not force and lastRefreshTime + 2 > os.time() then
        print("refreshTooEarly")
        return
    end
    lastRefreshTime = os.time()
    table.clear(balls)
    for _, v in pairs(Workspace:GetDescendants()) do
        if v:IsA("Part") and table.find(ballNames, v.Name) then
            table.insert(balls, v)
            v.Color = ballColor
        end
    end
end

local function moveCircleSmoothly(targetPosition)
    if not reachCircle then return end
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local tweenGoal = {Position = targetPosition}
    local tween = TweenService:Create(reachCircle, tweenInfo, tweenGoal)
    tween:Play()
end

local function createReachCircle()
    if reachCircle then
        reachCircle.Size = Vector3.new(reach * 2, reach * 2, reach * 2)
    else
        reachCircle = Instance.new("Part")
        reachCircle.Parent = Workspace
        reachCircle.Shape = Enum.PartType.Ball
        reachCircle.Size = Vector3.new(reach * 2, reach * 2, reach * 2)
        reachCircle.Anchored = true
        reachCircle.CanCollide = false
        reachCircle.Transparency = 0.8
        reachCircle.Material = Enum.Material.ForceField
        reachCircle.Color = reachColor

        RunService.RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local targetPosition = player.Character.HumanoidRootPart.Position
                moveCircleSmoothly(targetPosition)
            end
        end)
    end
end

local function on(input, gameProcessedEvent)
    local ignoredKeys = {
        [Enum.KeyCode.W] = true,
        [Enum.KeyCode.A] = true,
        [Enum.KeyCode.S] = true,
        [Enum.KeyCode.D] = true,
        [Enum.KeyCode.Space] = true,
        [Enum.KeyCode.Slash] = true,
        [Enum.KeyCode.Semicolon] = true
    }

    if input.UserInputType == Enum.UserInputType.Keyboard and 
       (input.KeyCode == Enum.KeyCode.Slash or input.KeyCode == Enum.KeyCode.Semicolon) then
        return
    end

    if ignoredKeys[input.KeyCode] then return end

    if not gameProcessedEvent then
        if input.KeyCode == Enum.KeyCode.Comma then
            reach = math.max(1, reach - 1)
            StarterGui:SetCore("SendNotification", {
                Title = "SPJ Reach",
                Text = "reachSetTo " .. reach,
                Duration = 0.5
            })
            createReachCircle()
        elseif input.KeyCode == Enum.KeyCode.Period then
            reach = reach + 1
            StarterGui:SetCore("SendNotification", {
                Title = "SPJ Reach",
                Text = "reachSetTo " .. reach,
                Duration = 0.5
            })
            createReachCircle()
        else
            refreshBalls(false)
            for _, legName in pairs({"Right Leg", "Left Leg"}) do
                local leg = player.Character and player.Character:FindFirstChild(legName)
                if leg then
                    for _, v in pairs(leg:GetDescendants()) do
                        if v.Name == "TouchInterest" and v.Parent then
                            for _, e in pairs(balls) do
                                if (e.Position - leg.Position).magnitude < reach then
                                    if not ballOwners[e] or ballOwners[e] == player then
                                        if not ballOwners[e] then
                                            ballOwners[e] = player
                                        end
                                        firetouchinterest(e, v.Parent, 0)
                                        firetouchinterest(e, v.Parent, 1)
                                        break
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

UserInputService.InputBegan:Connect(on)

RunService.RenderStepped:Connect(function()
    if player.Character then
        for _, legName in pairs({"Right Leg", "Left Leg"}) do
            local leg = player.Character:FindFirstChild(legName)
            if leg then
                for _, v in pairs(leg:GetDescendants()) do
                    if v.Name == "TouchInterest" and v.Parent then
                        for _, e in pairs(balls) do
                            if (e.Position - leg.Position).magnitude < reach then
                                if not ballOwners[e] then
                                    ballOwners[e] = player
                                    firetouchinterest(e, v.Parent, 0)
                                    firetouchinterest(e, v.Parent, 1)
                                elseif ballOwners[e] == player then
                                    firetouchinterest(e, v.Parent, 0)
                                    firetouchinterest(e, v.Parent, 1)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

local DrRayLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/AZYsGithub/DrRay-UI-Library/main/DrRay.lua"))()
local window = DrRayLibrary:Load("SPJ Reach", "Default")
local Tab = DrRayLibrary.newTab("Configs", "ImageIdHere")

Tab.newSlider("Reach", "Ajust the reach (Reach: "..reach..")", reach, false, function(Value)
    reach = Value
    createReachCircle()
    StarterGui:SetCore("SendNotification", {
        Title = "SPJ Reach",
        Text = "reachSetTo " .. reach,
        Duration = 0.5
    })
end)

createReachCircle()
