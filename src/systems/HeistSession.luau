local HeistSession = {}
HeistSession.__index = HeistSession

function HeistSession.new(userId: number)

    local self = setmetatable({}, HeistSession)
    
    self.UserId = userId
    self.CurrentRoom = 1
    self.UnbankedCash = 0
    self.Status = "InProgress"

    return self
end

function HeistSession:AddReward(amount: number)

    if self.Status ~= "InProgress" then
        return false
    end

    if amount <= 0 then
        return false
    end

    self.UnbankedCash += amount

    return true
end

