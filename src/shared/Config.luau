-- Later this may contain multiple banks, bases, and progression systems
-- For now all we need is two locations, a base spawn and a hesit spawn for testing

local Config = {}

Config.Base = {
    SpawnPosition = Vector3.new(0, 5, 0)
}

Config.Heist = {
    SpawnPosition = Vector3.new(150, 5, 0)
}

return Config
