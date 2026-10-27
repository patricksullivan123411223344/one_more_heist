type HeistStatusOptions = "InProgress" | "CanCashOut" | "Completed" | "Failed"
type RoomStatusOptions = "InProgress" | "Completed" | "Failed"

export type HeistSession = {
    UserId: number,
    CurrentRoom: number,
    UnbankedCash: number,
    HeistStatus: HeistStatusOptions,
    RoomStatus: RoomStatusOptions
}

local HeistSession = {}
HeistSession.__index = HeistSession

function HeistSession.new(userId: number)
    local self = setmetatable({}, HeistSession)

    self.UserId = userId
    self.CurrentRoom = 1
    self.UnbankedCash = 0
    self.HeistStatus = "InProgress"
    self.RoomStatus = "InProgress"

    return self
end

function HeistSession:AddReward(amount: number)
    if self.HeistStatus ~= "InProgress" then
        return false
    end

    if amount <= 0 then
        return false
    end

    self.UnbankedCash += amount

    return true
end

function HeistSession:CompleteRoom()
    if self.RoomStatus ~= "InProgress" then
        return false
    end

    self.RoomStatus = "Completed"
    self.HeistStatus = "CanCashOut"

    return true
end

function HeistSession:ContinueHeist()
    if self.HeistStatus ~= "CanCashOut" then
        return false
    end

    self.CurrentRoom += 1
    self.HeistStatus = "InProgress"
    self.RoomStatus = "InProgress"

    return true
end

function HeistSession:CashOut() 
    if self.HeistStatus ~= "CanCashOut" then
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
    if self.HeistStatus == "CanCashOut" or self.HeistStatus == "Completed" or self.HeistStatus == "Failed" then
        return false
    end

    if self.RoomStatus == "Completed" then
        return false
    end

    self.UnbankedCash = 0
    self.Status = "Failed"

    return true
end

return HeistSession


