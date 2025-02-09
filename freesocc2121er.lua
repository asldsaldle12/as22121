loadstring(game:HttpGet("https://raw.githubusercontent.com/asldsaldle12/as22121/refs/heads/main/freewarning.lua"))()
if game.PlaceId == 13664698400 then
    print('')
  else
  return print('):') end    
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Teams = game:GetService("Teams")
local player = Players.LocalPlayer
local balls, touchint = {}, {}
local lastRefreshTime = os.time()
local reach = 50
local reachCircle

local DrRayLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/AZYsGithub/DrRay-UI-Library/main/DrRay.lua"))()
local window = DrRayLibrary:Load("SPJ Reach", "Default")
local ConfigTab = DrRayLibrary.newTab("Configs", "ImageIdHere")
local Auto = DrRayLibrary.newTab("Auto-Farm", "ImageIdHere")
local foldersToSearch = {
    Workspace.WorkspaceStadiumSounds,
    Workspace.WorkspaceStadiumFolder,
    Workspace.WorkspaceCharacters,
    Workspace.WorkspaceLeaderboards,
    Workspace["Main Portal Template"]
}


local function findTPSBall()
    for _, folder in ipairs(foldersToSearch) do
        local ballCandidate = folder:FindFirstChild("TPS")
        if ballCandidate then
            return ballCandidate
        end
    end
    return nil
end


local ball = findTPSBall()
if not ball then
    warn("TPS ball não encontrada em nenhuma das pastas!")
end


local networkOwner = ball and ball:FindFirstChild("Owner")


local autoFarmEnabled2 = false
local autoFarmEnabled = false
spawn(function()
    while true do
        if autoFarmEnabled2 then
            local VirtualInputManager = game:GetService("VirtualInputManager")
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.R, false, game)
            wait(0.05)
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.R, false, game)
        end
        wait()
    end
end)


local function teleportBallToGoal()
    if not ball then return end
    if player.Team == Teams["Away"] then
        ball.CFrame = CFrame.new(-19.0787888, -24.802742, -197.551834, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    elseif player.Team == Teams["Home"] then
        ball.CFrame = CFrame.new(-20.0310287, -26.8024559, 382.160706, 1, 0, 0, 0, 1, 0, 0, 0, 1)
    end
end

local function teleportToBall()
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") and ball then
        player.Character.HumanoidRootPart.CFrame = ball.CFrame * CFrame.new(0, 2, 0)
    end
end

local function shootBall()
    local shootTool = player.Backpack:FindFirstChild("Dribble")
    if shootTool and player.Character and player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid:EquipTool(shootTool)
    end
end

local function startAutoFarm()
    while autoFarmEnabled do
        wait(0.1)
        if not ball or not ball.Parent then
            ball = findTPSBall()
            if ball then
                networkOwner = ball:FindFirstChild("Owner")
            end
        end

        if ball and networkOwner then
            if tostring(networkOwner.Value) == player.Name then
                teleportBallToGoal()
            else
                teleportToBall()
                shootBall()
            end
        end
    end
end
function openDevConsole()
    CoreGui:SetCore("DevConsoleVisible", true)
    warn("[+] Spj Reach : Loading..")
end

function closeDevConsole()
    warn("[!] Done")
    CoreGui:SetCore("DevConsoleVisible", false)
end

function errorHandler(err)
    warn("[-] Error, please report at the discord server, error details:\n", err)
    CoreGui:SetCore("DevConsoleVisible", true)
end

openDevConsole()

local function refreshBalls(force)
    if not force and lastRefreshTime + 1.5 > os.time() then return end
    table.clear(touchint)
    for _, v in pairs(player.Character:GetDescendants()) do
        if v.Name == "TouchInterest" and v.Parent:IsA("BasePart") then
            table.insert(touchint, v)
        end
    end
    lastRefreshTime = os.time()
    table.clear(balls)
    for _, v in pairs(Workspace:GetDescendants()) do
        local firstLetter = string.sub(v.Name, 1, 1)
        if v.Name == "TPS" or v.Name == "AIFA" or v.Name == "MRS" or v.Name == "PRS" or 
           v.Name == "MPS" or v.Name == "VFA" or firstLetter == "{" then
            task.wait()
            table.insert(balls, v)
        end
    end
end

local function moveReachCircle(targetPosition)
    if not reachCircle then return end
    local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
    local tweenGoal = {Position = targetPosition}
    local tween = TweenService:Create(reachCircle, tweenInfo, tweenGoal)
    tween:Play()
end

local function createReachCircle()
    if not reachCircle then
        reachCircle = Instance.new("Part")
        reachCircle.Parent = Workspace
        reachCircle.Shape = Enum.PartType.Ball
        reachCircle.Size = Vector3.new(reach * 2, reach * 2, reach * 2)
        reachCircle.Anchored = true
        reachCircle.CanCollide = false
        reachCircle.Transparency = 0.7
        reachCircle.Material = Enum.Material.ForceField
        reachCircle.Color = Color3.new(0, 0, 1)

        RunService.RenderStepped:Connect(function()
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                moveReachCircle(player.Character.HumanoidRootPart.Position)
            end
        end)
    else
        reachCircle.Size = Vector3.new(reach * 2, reach * 2, reach * 2)
    end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    refreshBalls(false)
    for _, ball in pairs(balls) do
        if (ball.Position - player.Character["Right Leg"].Position).magnitude <= reach then
            task.wait()
            for _, v in pairs(touchint) do
                if v.Parent ~= player.Character["Head"] then
                    task.spawn(function()
                        firetouchinterest(ball, v.Parent, 0)
                        firetouchinterest(ball, v.Parent, 1)
                    end)
                end
            end
        end
    end
end)

ConfigTab.newSlider("Reach", "", reach, false, function(value)
    reach = value
    createReachCircle()
end)
Auto.newToggle("Enable Auto-Farm", "", true, function(toggleState)
    autoFarmEnabled = toggleState
    if autoFarmEnabled then
        startAutoFarm()
    end
end)

Auto.newToggle("Enable Auto-key", "", true, function(toggleState)
    autoFarmEnabled2 = toggleState
end)
createReachCircle()

pcall(closeDevConsole)
