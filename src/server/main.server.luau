local Players = game:GetService("Players")

local HeistService = require(
    script.Parent.Parent.Services.HeistService
)

local BaseService = require(
    script.Parent.Parent.Services.BaseService
)

local ExitSystem = require(
    script.Parent.Parent.Systems.ExitSystem
)

local function createPlatform(name, position)

    local platform = Instance.new("Part")

    platform.Name = name
    platform.Size = Vector3.new(60, 2, 60)
    platform.Position = position
    platform.Anchored = true
    platform.Parent = workspace

    return platform
end

local function createInteractionPart(
    name,
    position,
    actionText,
    callback
)

    local part = Instance.new("Part")

    part.Name = name
    part.Size = Vector3.new(8, 1, 8)
    part.Position = position
    part.Anchored = true
    part.Parent = workspace

    local prompt = Instance.new("ProximityPrompt")

    prompt.ActionText = actionText
    prompt.ObjectText = name
    prompt.HoldDuration = 0.5
    prompt.MaxActivationDistance = 12
    prompt.Parent = part

    prompt.Triggered:Connect(callback)

    return part
end

-- Create platforms

createPlatform(
    "HeadquartersPlatform",
    Vector3.new(0, 0, 0)
)

createPlatform(
    "HeistPlatform",
    Vector3.new(150, 0, 0)
)

-- Headquarters entrance

createInteractionPart(
    "HeistEntrance",
    Vector3.new(0, 1, 15),
    "Start Heist",
    function(player)
        HeistService.StartHeist(player)
    end
)

-- Heist exit

createInteractionPart(
    "HeistExit",
    Vector3.new(150, 1, 15),
    "Exit Heist",
    function(player)
        ExitSystem.ExitHeist(player)
    end
)

-- Player initialization

Players.PlayerAdded:Connect(function(player)

    player.CharacterAdded:Connect(function(character)

        character:WaitForChild("HumanoidRootPart")
        BaseService.SendToBase(player)
    
    end)

end)






