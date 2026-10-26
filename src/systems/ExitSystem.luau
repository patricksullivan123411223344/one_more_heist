local ExitSystem = {}

local BaseService = require(
    script.Parent.Parent.Services.BaseService
)

function ExitSystem.ExitHeist(player)

    print(player.Name .. " exiting heist")

    BaseService.SendToBase(player)

end

return ExitSystem

