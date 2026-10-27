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

function HeistSession:CompleteRoom()
    
    if self.Status ~= "InProgress" then
        return false
    end

    self.Status = "CanCashOut"

    return true
end

function HeistSession:ContinueHeist()

    if self.Status ~= "CanCashOut" then
        return false
    end

    self.CurrentRoom += 1
    self.Status = "InProgress"

    return true
end

function HeistSession:CashOut() 

    if self.Status ~= "CanCashOut" then
        return nil
    end

    local payout = self.UnbankedCash

    if payout then
        self.UnbankedCash = 0
    end

    self.Status = "Completed"
    return payout
end

function HeistSession:HeistFail()

    if self.Status == "Completed" or self.Status == "Failed" then
        return false
    end

    self.UnbankedCash = 0
    self.Status = "Failed"

    return true
end

return HeistSession


