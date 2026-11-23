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
    ["Base.Sheet"] = "White",
    ["Base.SheetRope"] = "White",
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

function SlingRequiredCrafting.iconForSource(source)
    if source:getFullType() == "Base.Belt2" then
        return "Item_SlingRequiredBrown"
    end
    if source:getFullType() == "Base.Sheet" or source:getFullType() == "Base.SheetRope" then
        return "Item_SlingRequiredWhite"
    end

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

-- Use the saved per-item icon, not a randomly selected clothing texture variant.
local slingIcons = {
    Item_SlingRequiredBeige = true,
    Item_SlingRequiredBlack = true,
    Item_SlingRequiredBlue = true,
    Item_SlingRequiredBrown = true,
    Item_SlingRequiredGreen = true,
    Item_SlingRequiredRed = true,
    Item_SlingRequiredWhite = true,
}

-- Indices match the ordered textureChoices in SlingRequired_MakeshiftSling.xml.
local wornTextureChoices = {
    Item_SlingRequiredBeige = 0,
    Item_SlingRequiredBlack = 1,
    Item_SlingRequiredBlue = 2,
    Item_SlingRequiredBrown = 3,
    Item_SlingRequiredGreen = 4,
    Item_SlingRequiredRed = 5,
    Item_SlingRequiredWhite = 6,
}

function SlingRequiredCrafting.textureForIcon(icon)
    return getTexture(icon) or getTexture("media/textures/" .. icon .. ".png")
end

function SlingRequiredCrafting.ensureIcon(sling)
    if not sling or sling:getFullType() ~= "SlingRequired.MakeshiftSling" then return nil end

    local saved = sling:getModData()
    local icon = saved.customInventoryIcon
    if saved.SlingRequiredSourceType == "Base.Belt2" then
        icon = "Item_SlingRequiredBrown"
    elseif saved.SlingRequiredSourceType == "Base.Sheet" or saved.SlingRequiredSourceType == "Base.SheetRope" then
        icon = "Item_SlingRequiredWhite"
    elseif not slingIcons[icon] then
        icon = "Item_SlingRequired" .. (sourceIconColors[saved.SlingRequiredSourceType] or "Beige")
    end

    saved.customInventoryIcon = icon
    local texture = SlingRequiredCrafting.textureForIcon(icon)
    if texture then
        sling:setIcon(texture)
        sling:setTexture(texture)
    end

    -- Use the same saved color for the worn model and inventory icon.
    local visual = sling:getVisual()
    if visual then
        local choice = wornTextureChoices[icon] or 0
        if visual:getTextureChoice() ~= choice then
            visual:setTextureChoice(choice)
            sling:synchWithVisual()
        end
    end

    -- Clothing textures otherwise inherit an unrelated random scarf tint.
    sling:setColorRed(1)
    sling:setColorGreen(1)
    sling:setColorBlue(1)
    sling:setCustomColor(true)
    return texture
end

-- OnTest is an execution check; global OnAddToMenu functions hide disabled
-- material groups in the Build 42 recipe panel.
function SlingRequiredCrafting.OnTest(item, character)
    if not item then return true end
    if item:getFullType() == "SlingRequired.MakeshiftSling" then
        SlingRequiredCrafting.ensureIcon(item)
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

-- The recipe has one shared icon. Only override it for a known selected item,
-- or for a single available sling; item-specific context menus use that item.
function SlingRequiredCrafting.DismantleIcon(params)
    if not params or not params.recipe then return true end

    local sling = params.selectedItem or params.item
    if not sling or sling:getFullType() ~= "SlingRequired.MakeshiftSling" then
        sling = nil
        local inventory = params.player and params.player:getInventory()
        local slings = inventory and inventory:getItemsFromType("SlingRequired.MakeshiftSling", true)
        if slings and slings:size() == 1 then
            sling = slings:get(0)
        end
    end

    local texture = sling and SlingRequiredCrafting.ensureIcon(sling)
        or SlingRequiredCrafting.textureForIcon("Item_SlingRequiredBeige")
    if texture then
        params.recipe:overrideIconTexture(texture)
    end
    return true
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
    saved.customInventoryIcon = SlingRequiredCrafting.iconForSource(original)
    SlingRequiredCrafting.ensureIcon(result)
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
