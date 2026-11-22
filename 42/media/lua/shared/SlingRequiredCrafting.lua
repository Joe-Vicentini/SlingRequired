require "SlingRequired"

SlingRequiredCrafting = SlingRequiredCrafting or {}

-- Source-specific defaults cover materials whose inventory color is untinted.
local sourceIconColors = {
    ["Base.Belt2"] = "Brown",
    ["Base.RopeBelt"] = "Beige",
    ["Base.DenimStrips"] = "Blue",
    ["Base.LeatherStrips"] = "Brown",
    ["Base.Tie_Full"] = "Beige",
    ["Base.Rope"] = "Beige",
    ["Base.Scarf_White"] = "Beige",
    ["Base.Scarf_StripeBlackWhite"] = "Black",
    ["Base.Scarf_StripeBlueWhite"] = "Blue",
    ["Base.Scarf_StripeRedWhite"] = "Red",
    ["Base.Sheet"] = "Beige",
    ["Base.SheetRope"] = "Beige",
    ["Base.Twine"] = "Brown",
}

local iconColors = {
    Beige = { 0.75, 0.69, 0.56 },
    Black = { 0.14, 0.14, 0.14 },
    Blue = { 0.30, 0.48, 0.65 },
    Brown = { 0.48, 0.29, 0.19 },
    Green = { 0.34, 0.46, 0.27 },
    Red = { 0.57, 0.24, 0.25 },
}

local function iconForSource(source)
    local fallback = sourceIconColors[source:getFullType()] or "Beige"
    local color = source:getColor()
    local clothing = source:getClothingItem()
    local visual = clothing and source:getVisual()
    if visual then
        color = visual:getTint(clothing) or color
    end
    if not color then return "Item_SlingRequired" .. fallback end

    local r, g, b = color:getRedFloat(), color:getGreenFloat(), color:getBlueFloat()
    -- Default white tint means the source's material/type determines its color.
    if r > 0.9 and g > 0.9 and b > 0.9 then
        return "Item_SlingRequired" .. fallback
    end

    local closest, minimum
    for name, rgb in pairs(iconColors) do
        local distance = (r - rgb[1]) ^ 2 + (g - rgb[2]) ^ 2 + (b - rgb[3]) ^ 2
        if not minimum or distance < minimum then
            closest, minimum = name, distance
        end
    end
    return "Item_SlingRequired" .. closest
end

-- OnTest is an execution check; global OnAddToMenu functions hide disabled
-- material groups in the Build 42 recipe panel.
function SlingRequiredCrafting.OnTest(item, character)
    if not item then return true end
    if item:getFullType() == "SlingRequired.MakeshiftSling" then
        return item:getModData().SlingRequiredSourceType ~= nil
    end

    local option = SlingRequired.materialOptions[item:getFullType()]
    return option ~= nil and SlingRequired.isEnabled(option)
end

function SlingRequiredAllowBelts(params)
    return SlingRequired.isEnabled("Belts")
end

function SlingRequiredAllowDenimStrips(params)
    return SlingRequired.isEnabled("DenimStrips")
end

function SlingRequiredAllowLeatherStrips(params)
    return SlingRequired.isEnabled("LeatherStrips")
end

function SlingRequiredAllowNeckties(params)
    return SlingRequired.isEnabled("Neckties")
end

function SlingRequiredAllowRopes(params)
    return SlingRequired.isEnabled("Ropes")
end

function SlingRequiredAllowScarves(params)
    return SlingRequired.isEnabled("Scarves")
end

function SlingRequiredAllowSheets(params)
    return SlingRequired.isEnabled("Sheets")
end

function SlingRequiredAllowTwine(params)
    return SlingRequired.isEnabled("Twine")
end

function SlingRequiredCrafting.OnCreate(data, character)
    local consumed = data:getAllConsumedItems()
    local result = data:getFirstCreatedItem()
    if not result or not consumed or consumed:isEmpty() then return end

    local original = consumed:get(0)
    local option = SlingRequired.materialOptions[original:getFullType()]
    if not option then return end

    local saved = result:getModData()
    saved.SlingRequiredSourceType = original:getFullType()
    saved.SlingRequiredSourceCondition = original:getCondition()
    saved.customInventoryIcon = iconForSource(original)
end

function SlingRequiredCrafting.Dismantle(data, character)
    local consumed = data:getAllConsumedItems()
    if not consumed or consumed:isEmpty() or not character then return end

    local sling = consumed:get(0)
    local saved = sling:getModData()
    local sourceType = saved.SlingRequiredSourceType

    -- Restore only known material items, never arbitrary IDs from mod data.
    if not SlingRequired.materialOptions[sourceType] then return end

    local restored = character:getInventory():AddItem(sourceType)
    if restored and type(saved.SlingRequiredSourceCondition) == "number" then
        restored:setCondition(saved.SlingRequiredSourceCondition)
    end
end
