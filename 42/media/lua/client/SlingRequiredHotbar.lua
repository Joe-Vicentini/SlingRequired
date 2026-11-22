require "Hotbar/ISHotbar"
require "SlingRequired"

-- Vanilla B42 always inserts Back. Reconcile only that slot after the
-- normal hotbar update, keeping every other slot and modded attachment intact.
local vanillaUpdate = ISHotbar.update

function ISHotbar:update(...)
    vanillaUpdate(self, ...)

    if not self.chr or not self.availableSlot or not self.attachedItems then return end

    local backIndex
    for i, slot in ipairs(self.availableSlot) do
        if slot.slotType == "Back" then
            backIndex = i
            break
        end
    end

    local allowed = SlingRequired.qualifies(self.chr)
    if allowed == (backIndex ~= nil) then return end

    if not allowed then
        local attached = self.attachedItems[backIndex]
        if attached then
            self:removeItem(attached, false)
        end
        table.remove(self.availableSlot, backIndex)

        for _, item in pairs(self.attachedItems) do
            local index = item:getAttachedSlot()
            if index > backIndex then
                item:setAttachedSlot(index - 1)
            end
        end
    else
        local slotDef = self:getSlotDef("Back")
        if not slotDef then return end

        table.insert(self.availableSlot, 1, {
            slotType = slotDef.type,
            name = slotDef.name,
            def = slotDef,
        })

        for _, item in pairs(self.attachedItems) do
            local index = item:getAttachedSlot()
            if index >= 1 then
                item:setAttachedSlot(index + 1)
            end
        end
    end

    self:reloadIcons()
    self:savePosition()
    self:setSizeAndPosition()
end
