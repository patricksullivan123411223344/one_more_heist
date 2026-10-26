print("One More Heist: Test environment initialized!")

local function calculateReward(
    currentCash: number,
    roomReward: number
): number
    return currentCash + roomReward
end

local total = calculateReward(500, 1000)

assert(total == 1500, "Reward calculation failed")

print("Reward calculation: PASSED")
print("All smoke tests passed!")