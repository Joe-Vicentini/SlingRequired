require "ISUI/ISInventoryPaneContextMenu"
require "SlingRequired"

local function nameDismantleOptions(context)
    for i = 1, context.numOptions - 1 do
        local option = context.options[i]
        if option.onSelect == ISInventoryPaneContextMenu.OnNewCraft
                and option.param1 and option.param1:getName() == "DismantleMakeshiftSling"
                and option.target and option.target:getFullType() == "SlingRequired.MakeshiftSling" then
            local sourceType = option.target:getModData().SlingRequiredSourceType
            if SlingRequired.materialOptions[sourceType] then
                option.name = getText(option.param1:getTranslationName()) .. " (" .. getItemNameFromFullType(sourceType) .. ")"
                if option.toolTip then
                    option.toolTip:setName(option.name)
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
