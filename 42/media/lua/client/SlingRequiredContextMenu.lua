require "ISUI/ISInventoryPaneContextMenu"
require "SlingRequired"
require "SlingRequiredCrafting"

local function nameDismantleOptions(context)
    for i = 1, context.numOptions - 1 do
        local option = context.options[i]
        if option.onSelect == ISInventoryPaneContextMenu.OnNewCraft
                and option.param1 and option.param1:getName() == "DismantleMakeshiftSling"
                and option.target and option.target:getFullType() == "SlingRequired.MakeshiftSling" then
            local sourceType = option.target:getModData().SlingRequiredSourceType
            if SlingRequired.materialOptions[sourceType] then
                option.name = getText(option.param1:getTranslationName()) .. " (" .. getItemNameFromFullType(sourceType) .. ")"
                SlingRequiredCrafting.ensureIcon(option.target)
                option.color = nil
                option.iconTexture = nil
                option.itemForTexture = option.target
                if option.toolTip then
                    option.toolTip:setName(option.name)
                    option.toolTip:setTextureDirectly(option.target:getTex())
                end
            end
        elseif option.onSelect == ISInventoryPaneContextMenu.OnNewCraft
                and option.param1 and option.param1:getName():find("^MakeSlingFrom")
                and option.target and SlingRequired.materialOptions[option.target:getFullType()] then
            local icon = SlingRequiredCrafting.iconForSource(option.target)
            local texture = SlingRequiredCrafting.textureForIcon(icon)
            if texture then
                option.iconTexture = texture
                option.color = nil
                if option.toolTip then
                    option.toolTip:setTextureDirectly(texture)
                end
            end
        end
        if option.subOption then
            nameDismantleOptions(context:getSubMenu(option.subOption))
        end
    end
end

Events.OnFillInventoryObjectContextMenu.Add(function(player, context, items)
    nameDismantleOptions(context)
end)

-- Correct belt and sheet icons on existing saved slings as the player loads.
Events.OnCreatePlayer.Add(function(index, player)
    if not player then return end
    local slings = player:getInventory():getItemsFromType("SlingRequired.MakeshiftSling", true)
    if not slings then return end
    for i = 0, slings:size() - 1 do
        SlingRequiredCrafting.ensureIcon(slings:get(i))
    end
end)
