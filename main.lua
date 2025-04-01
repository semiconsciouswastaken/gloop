local tool = Instance.new("Tool")
tool.Name = "LaserPointer"
local toolval = Instance.new("StringValue")
toolval.Value = "None"
toolval.Parent = tool

local tweenserv = game:GetService("TweenService")
local dstable = {}
local ntime = false
local twpos = {}
local twinfo = TweenInfo.new(1)
local RunService = game:GetService("RunService")
local hb = 0

local handle = Instance.new("Part")
handle.Size = Vector3.new(1, 1, 1)
handle.BrickColor = BrickColor.new("Really blue")
handle.Name = "Handle"
handle.Anchored = false
handle.CanCollide = false
handle.Parent = tool

local attachment0 = Instance.new("Attachment", handle)
attachment0.Position = Vector3.new(0, 0, -0.5)

local laserPart = Instance.new("Part")
laserPart.Size = Vector3.new(0.2, 0.2, 0.2)
laserPart.Transparency = 1
laserPart.CanCollide = false
laserPart.Anchored = true
laserPart.Parent = tool

local attachment1 = Instance.new("Attachment", laserPart)

local beam = Instance.new("Beam")
beam.Attachment0 = attachment0
beam.Attachment1 = attachment1
beam.Color = ColorSequence.new(Color3.new(1, 0, 0))
beam.Width0 = 0.1
beam.Width1 = 0.1
beam.FaceCamera = true
beam.Enabled = false
beam.Parent = handle

local sound = Instance.new("Sound")
sound.SoundId = "rbxassetid://1838457617"
sound.Parent = handle
sound.Looped = true

local billboard = Instance.new("BillboardGui")
billboard.Size = UDim2.new(0, 200, 0, 50)
billboard.StudsOffset = Vector3.new(0, 2, 0)
billboard.AlwaysOnTop = true
billboard.Parent = handle

local statusLabel = Instance.new("TextLabel")
statusLabel.Size = UDim2.new(1, 0, 0.5, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.TextScaled = true
statusLabel.Text = "Idle"
statusLabel.Parent = billboard

local methodLabel = Instance.new("TextLabel")
methodLabel.Size = UDim2.new(1, 0, 0.5, 0)
methodLabel.Position = UDim2.new(0, 0, 0.5, 0)
methodLabel.BackgroundTransparency = 1
methodLabel.TextColor3 = Color3.new(1, 1, 1)
methodLabel.TextScaled = true
methodLabel.Text = "Kill Method: None"
methodLabel.Parent = billboard

if owner then
    tool.Parent = owner:FindFirstChild("Backpack")
end

local disarm = false
local safetable = {}
safetable = {owner.Character, owner, workspace.Base}

local function updateKillMethod()
    local methodText = {
        z = "Safe",
        x = "Destroy",
        c = "Move",
        v = "Break Joints",
        b = "Reparent",
        n = "Rename",
        m = "Kill",
        Comma = "Destroy All",
        None = "None"
    }
    methodLabel.Text = "Kill Method: " .. (methodText[toolval.Value] or "None")
end

local function fireLaser(targetPosition)
    local origin = owner.Character:FindFirstChild("HumanoidRootPart").Position
    local direction = (targetPosition - origin).Unit * 500

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = safetable
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(origin, direction, raycastParams)

    if result then
        laserPart.Position = result.Position
        local hitPart = result.Instance
        if hitPart then
            local character = hitPart.Parent
            local humanoid = character:FindFirstChildWhichIsA("Humanoid")
            if humanoid then
                if toolval.Value == "z" then
                    statusLabel.Text = "Safe: " .. character.Name
                elseif toolval.Value == "x" then
                    hitPart:Destroy()
                    statusLabel.Text = "Destroyed: " .. hitPart.Name
                elseif toolval.Value == "c" then
                    hitPart.Position = Vector3.new(99999999999, 99999999999, 99999999999)
                    statusLabel.Text = "Moved: " .. hitPart.Name
                elseif toolval.Value == "v" then
                    character:BreakJoints()
                    statusLabel.Text = "Broken Joints: " .. character.Name
                elseif toolval.Value == "b" then
                    character.Parent = game.ReplicatedStorage
                    statusLabel.Text = "Reparented: " .. character.Name
                elseif toolval.Value == "n" then
                    character.Name = "banana"
                    statusLabel.Text = "Renamed: " .. character.Name
                elseif toolval.Value == "m" then
                    humanoid:Destroy()
                    statusLabel.Text = "Killed: " .. character.Name
                elseif toolval.Value == "Comma" then
                    humanoid:Destroy()
                    hitPart:Destroy()
                    statusLabel.Text = "Destroyed All: " .. character.Name
                end
                updateKillMethod()
            else
                statusLabel.Text = "Hit: " .. hitPart.Name
            end
        end
    else
        laserPart.Position = origin + direction
        statusLabel.Text = "No Target"
    end
end

local detect = 0
local function eqp()
    sound:Play()
    detect = 1
    beam.Enabled = true
    statusLabel.Text = "Ready"
    updateKillMethod()
end
local function nqp()
    sound:Stop()
    detect = 0
    beam.Enabled = false
    statusLabel.Text = "Idle"
    methodLabel.Text = "Kill Method: None"
end
tool.Equipped:Connect(eqp)
tool.Unequipped:Connect(nqp)

local Remote = Instance.new("RemoteEvent")
Remote.Name = "FireLaser"
Remote.Parent = tool

Remote.OnServerEvent:Connect(function(player, data)
    if player == owner then
        if typeof(data) == "Vector3" then
            fireLaser(data)
        elseif typeof(data) == "EnumItem" then
            local key = data.Name
            if key == "Z" then
                toolval.Value = "z"
            elseif key == "X" then
                toolval.Value = "x"
            elseif key == "C" then
                toolval.Value = "c"
            elseif key == "V" then
                toolval.Value = "v"
            elseif key == "B" then
                toolval.Value = "b"
            elseif key == "N" then
                toolval.Value = "n"
            elseif key == "M" then
                toolval.Value = "m"
            elseif key == "Comma" then
                toolval.Value = "Comma"
            end
            updateKillMethod()
        end
    end
end)

NewLocalScript([[ 
local tool = script.Parent
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local remote = tool:WaitForChild("FireLaser")
local UserInputService = game:GetService("UserInputService")

tool.Activated:Connect(function()
    remote:FireServer(mouse.Hit.Position)
end)

UserInputService.InputBegan:Connect(function(input)
    if UserInputService:GetFocusedTextBox() ~= nil then return end
    if input.UserInputType == Enum.UserInputType.Keyboard then
        remote:FireServer(input.KeyCode)
    end
end)
]], tool)
