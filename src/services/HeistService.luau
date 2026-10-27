local HeistService = {}

local HeistSession = require(
    script.Parent.Parent.Systems.HeistSession
)

local ActiveSessions = {}

function HeistService.StartHeist(player)

    local userId = player.UserId

    if ActiveSessions[userId] then
        return false
    end

    local session = HeistSession.new(userId)

    ActiveSessions[userId] = session

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

