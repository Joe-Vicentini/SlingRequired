require "SlingRequired"

SlingRequiredCrafting = SlingRequiredCrafting or {}

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
