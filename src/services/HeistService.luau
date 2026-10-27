local HeistService = {}

local Config = require(
    game:GetService("ReplicatedStorage").Shared.Config
)

local HeistSession = require(
    script.Parent.Parent.Systems.HeistSession
)

local ActiveSessions = {}

function HeistService.StartHeist(player)

    local character = player.Character
    local userId = player.UserId

    if not character or not character:FindFirstChild("HumanoidRootPart") then
        return false
    end

    if ActiveSessions[userId] then
        return false
    end

    local session = HeistSession.new(userId)
    ActiveSessions[userId] = session
    character:PivotTo(CFrame.new(Config.Heist.SpawnPosition))

    print(player.Name .. " started a heist")
    return true
end

function HeistService.EndHeist(player)

    local userId = player.UserId

    if not ActiveSessions[userId] then
        return false
    end

    ActiveSessions[userId] = nil

    return true
end

return HeistService

