require "Definitions/AttachedWeaponDefinitions"

-- The engine adds ensureItem to the outfit when it selects a weapon.
-- Use only carry locations; embedded weapons have separate locations.
local carriedOnBack = {
    ["Big Weapon On Back"] = true,
    ["Big Weapon On Back with Bag"] = true,
    ["Blade On Back"] = true,
    ["Big Blade On Back with Bag"] = true,
    ["Rifle On Back"] = true,
    ["Rifle On Back with Bag"] = true,
    ["Racket On Back"] = true,
    ["Racket Back with Bag"] = true,
    ["Shovel Back"] = true,
    ["Shovel Back with Bag"] = true,
    ["Guitar"] = true,
    ["Guitar Acoustic"] = true,
    ["Pan On Back"] = true,
    ["Pan On Back with Bag"] = true,
    ["Saucepan Back"] = true,
    ["Saucepan Back with Bag"] = true,
}

local function ensureSlings()
    for _, definition in pairs(AttachedWeaponDefinitions) do
        if type(definition) == "table" and not definition.ensureItem
                and not definition.addHoles and not definition.bloodLocations
                and type(definition.weaponLocation) == "table"
                and #definition.weaponLocation > 0 then
            local carried = true
            for _, location in ipairs(definition.weaponLocation) do
                if not carriedOnBack[location] then
                    carried = false
                    break
                end
            end
            if carried then
                definition.ensureItem = "SlingRequired.ZombieBeltSling"
            end
        end
    end
end

ensureSlings()
Events.OnGameBoot.Add(ensureSlings)
