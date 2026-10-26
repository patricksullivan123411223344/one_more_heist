local BaseService = {}

local Config = require(
    game:GetService("ReplicatedStorage").Shared.Config
)

function BaseService.SendToBase(player)

    local character = player.character

    if not character then
        return
    end 

    character:PivotTo(
        CFrame.new(Config.Base.SpawnPosition)
    )

    print(player.Name .. " returned to base")

end

return BaseService

