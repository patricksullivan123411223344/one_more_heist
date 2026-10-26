local HeistService = {}

local Config = require(
    game:GetService("ReplicatedStorage").Shared.Config
)

function HeistService.StartHeist(player)

    local character = player.Character

    if not character then
        return
    end  

    character:PivotTo(
        CFrame.new(Config.Heist.SpawnPosition)
    )

    print(player.Name .. " started a heist")

end

return HeistService

