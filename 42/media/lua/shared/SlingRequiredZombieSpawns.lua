require "SlingRequired"

-- Carried attachments are separate from embedded weapon locations.
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

local slingType = "SlingRequired.ZombieBeltSling"
local providesBackByType = {}

local function hasCarriedBackItem(zombie)
    local attached = zombie:getAttachedItems()
    for i = 0, attached:size() - 1 do
        if carriedOnBack[attached:get(i):getLocation()] then
            return true
        end
    end
    return false
end

local function visualQualifies(visual)
    local fullType = visual:getItemType()
    if not fullType then return false end
    if SlingRequired.qualifiesEquipment(fullType, false) then return true end

    -- Use actual item data when available; only cache script-derived
    -- attachment support for outfit visuals without inventory items.
    local item = visual:getInventoryItem()
    if item then
        local attachments = item:getAttachmentsProvided()
        return SlingRequired.qualifiesEquipment(fullType,
            attachments ~= nil and attachments:contains("Back"))
    end

    local providesBack = providesBackByType[fullType]
    if providesBack == nil then
        local script = visual:getScriptItem()
        if not script then return false end
        local sample = instanceItem(script)
        if not sample then return false end
        local attachments = sample:getAttachmentsProvided()
        providesBack = attachments ~= nil and attachments:contains("Back")
        providesBackByType[fullType] = providesBack
    end
    return SlingRequired.qualifiesEquipment(fullType, providesBack)
end

local function hasQualifyingGear(zombie)
    if SlingRequired.qualifies(zombie) then return true end
    local visuals = zombie:getItemVisuals()
    for i = 0, visuals:size() - 1 do
        if visualQualifies(visuals:get(i)) then return true end
    end
    return false
end

local function equipSling(zombie, forCorpse)
    if not hasCarriedBackItem(zombie) or hasQualifyingGear(zombie) then
        return true
    end

    local sling = instanceItem(slingType)
    if not sling then return false end
    if forCorpse or zombie:isUsingWornItems() then
        zombie:getInventory():AddItem(sling)
        zombie:setWornItem(sling:getBodyLocation(), sling)
    else
        local visual = sling:getVisual()
        local clothing = sling:getClothingItem()
        if not visual or not clothing then return false end
        visual:pickUninitializedValues(clothing)
        zombie:getItemVisuals():add(visual)
        zombie:resetModelNextFrame()
    end
    return true
end

local function checkOutfit(zombie)
    if zombie:isReanimatedPlayer() or zombie:isDead()
            or not zombie:isPersistentOutfitInit() then return end
    local data = zombie:getModData()
    if data.SlingRequiredOutfitChecked then return end

    -- Wait until vanilla has generated the outfit and attached items.
    if equipSling(zombie, false) then
        data.SlingRequiredOutfitChecked = true
    end
end

Events.OnZombieCreate.Add(function(zombie)
    -- Zombies may be recycled; do not retain another outfit's decision.
    zombie:getModData().SlingRequiredOutfitChecked = nil
    if zombie:isPersistentOutfitInit() and hasCarriedBackItem(zombie) then
        checkOutfit(zombie)
    end
end)

-- OnZombieUpdate runs in SP and on clients after deferred outfit generation.
Events.OnZombieUpdate.Add(checkOutfit)

-- A dedicated server may not run OnZombieUpdate. Check generated corpse
-- equipment on the authoritative side before the corpse is created.
Events.OnZombieDead.Add(function(zombie)
    if isClient() or zombie:isReanimatedPlayer() then return end
    if not zombie:getModData().SlingRequiredOutfitChecked then
        equipSling(zombie, true)
    end
end)
