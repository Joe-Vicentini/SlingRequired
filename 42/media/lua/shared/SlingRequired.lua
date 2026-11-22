SlingRequired = SlingRequired or {}

SlingRequired.materialOptions = {
    ["Base.Belt2"] = "Belts",
    ["Base.RopeBelt"] = "Belts",
    ["Base.DenimStrips"] = "DenimStrips",
    ["Base.LeatherStrips"] = "LeatherStrips",
    ["Base.Tie_Full"] = "Neckties",
    ["Base.Rope"] = "Ropes",
    ["Base.Scarf_White"] = "Scarves",
    ["Base.Scarf_StripeBlackWhite"] = "Scarves",
    ["Base.Scarf_StripeBlueWhite"] = "Scarves",
    ["Base.Scarf_StripeRedWhite"] = "Scarves",
    ["Base.Sheet"] = "Sheets",
    ["Base.SheetRope"] = "Sheets",
    ["Base.Twine"] = "Twine",
}

SlingRequired.backwearOptions = {
    ["Base.Bag_NormalHikingBag"] = "HikingBackpacks",
    ["Base.Bag_BigHikingBag"] = "HikingBackpacks",
    ["Base.Bag_CraftedFramepack_Large3"] = "LargeFramepacks",
    ["Base.Bag_ALICEpack"] = "MilitaryBackpacks",
    ["Base.Bag_ALICEpack_Army"] = "MilitaryBackpacks",
    ["Base.Bag_ALICEpack_DesertCamo"] = "MilitaryBackpacks",
    ["Base.Bag_SurvivorBag"] = "MilitaryBackpacks",
    ["Base.Bag_Schoolbag"] = "SchoolBackpacks",
    ["Base.Bag_Schoolbag_Kids"] = "SchoolBackpacks",
    ["Base.Bag_Schoolbag_Medical"] = "SchoolBackpacks",
    ["Base.Bag_SheetSlingBag"] = "SlingBags",
    ["Base.Bag_TarpSlingBag"] = "SlingBags",
    ["Base.Bag_HideSlingBag"] = "SlingBags",
}

function SlingRequired.isEnabled(option)
    local settings = SandboxVars and SandboxVars.SlingRequired
    return not settings or settings[option] ~= false
end

function SlingRequired.qualifies(character)
    if not character then return false end

    local worn = character:getWornItems()
    for i = 0, worn:size() - 1 do
        local item = worn:getItemByIndex(i)
        if item and not character:isHandItem(item) then
            if item:getFullType() == "SlingRequired.MakeshiftSling" then
                return true
            end

            local attachments = item:getAttachmentsProvided()
            if attachments and attachments:contains("Back") then
                return true
            end

            local option = SlingRequired.backwearOptions[item:getFullType()]
            if option and SlingRequired.isEnabled(option) then
                return true
            end
        end
    end
    return false
end
