---------------------------------------------------------------------------------------
local slots = {
    "HeadSlot", "NeckSlot", "ShoulderSlot", "BackSlot", "ChestSlot",
    "ShirtSlot", "TabardSlot", "WristSlot", "HandsSlot", "WaistSlot",
    "LegsSlot", "FeetSlot", "Finger0Slot", "Finger1Slot",
    "Trinket0Slot", "Trinket1Slot", "MainHandSlot", "SecondaryHandSlot",
    "RangedSlot"
}

local function CreateIlvlText(slotFrame)
    local font = slotFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    font:SetPoint("BOTTOM", slotFrame, "BOTTOM", 0, 2)
    font:SetText("")
    return font
end

local ilvlTexts = {}

local function UpdateItemLevels()
    local totalItemLevel = 0
    local itemCount = 0
    for _, slotName in ipairs(slots) do
        local slotFrame = _G["Character" .. slotName]
        if slotFrame then
            -- 初始化字体
            if not ilvlTexts[slotName] then
                ilvlTexts[slotName] = CreateIlvlText(slotFrame)
            end

            local id = GetInventorySlotInfo(slotName)
            local itemLink = GetInventoryItemLink("player", id)
            local font = ilvlTexts[slotName]

            if itemLink then
                local _, _, itemQuality, itemLevel = GetItemInfo(itemLink)
                if itemLevel then
                    itemCount = itemCount + 1
                    totalItemLevel = totalItemLevel + itemLevel
                    font:SetText(itemLevel)
                    if itemQuality then
                        local r, g, b, _ = GetItemQualityColor(itemQuality)
                        font:SetTextColor(r, g, b)
                    else
                        font:SetTextColor(1, 1, 1) -- 默认颜色
                    end
                else
                    font:SetText("...")
                end
            else
                font:SetText("")
            end
        end
    end
    if itemCount > 0 then
        local averageItemLevel = string.format("Avg Item Level: %.1f", totalItemLevel / itemCount)
        if not CharacterFrame.avgItemLvlText then
            CharacterFrame.avgItemLvlText = CharacterFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        end
        
        CharacterFrame.avgItemLvlText:SetPoint("TOP", CharacterFrame, "TOP", 0, -57)
        CharacterFrame.avgItemLvlText:SetText(averageItemLevel)
    end
end

-- 创建事件监听器
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("UNIT_INVENTORY_CHANGED")

f:SetScript("OnEvent", function()
    if CharacterFrame and CharacterFrame:IsShown() then
        UpdateItemLevels()
    end
end)

-- 角色面板打开时刷新
CharacterFrame:HookScript("OnShow", UpdateItemLevels)

---------------------------------------------------------------------------------------

-- local function AddItemLevelToContainerFrame()
--     for bag = 0, NUM_BAG_SLOTS do
--         for slot = 1, GetContainerNumSlots(bag) do
--             local button = _G["ContainerFrame" .. (bag + 1) .. "Item" .. slot]
--             if button and not button.itemLevelText then
--                 local font = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
--                 font:SetPoint("BOTTOMLEFT", 2, 2)
--                 font:SetTextColor(1, 0.8, 0)
--                 button.itemLevelText = font
--             end

--             local itemLink = GetContainerItemLink(bag, slot)
--             if itemLink then
--                 local _, _, _, itemLevel = GetItemInfo(itemLink)
--                 if itemLevel and button.itemLevelText then
--                     button.itemLevelText:SetText(itemLevel)
--                 end
--             elseif button and button.itemLevelText then
--                 button.itemLevelText:SetText("XXX")
--             end
--         end
--     end
-- end

-- -- 每次背包更新时刷新
-- local f1 = CreateFrame("Frame")
-- f1:RegisterEvent("BAG_UPDATE_DELAYED")
-- f1:SetScript("OnEvent", AddItemLevelToContainerFrame)

---------------------------------------------------------------------------------------

local function AddLootItemLevels()
    for i = 1, LootFrame.numLootItems do
        local lootButton = _G["LootButton" .. i]
        if lootButton and lootButton:IsShown() then
            local link = GetLootSlotLink(i)
            if link then
                local _, _, iquality, ilvl, _, _, _, _, equipLoc = GetItemInfo(link)
                if ilvl and equipLoc ~= "INVTYPE_NON_EQUIP_IGNORE" then
                    if not lootButton.itemLevelText then
                        lootButton.itemLevelText = lootButton:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                        lootButton.itemLevelText:SetPoint("BOTTOMRIGHT", -2, 2)
                    end
                    lootButton.itemLevelText:SetText(ilvl)
                    local r, g, b, _ = GetItemQualityColor(iquality)
                    lootButton.itemLevelText:SetTextColor(r, g, b)
                end
            end
        end
    end
end

local f2 = CreateFrame("Frame")
f2:RegisterEvent("LOOT_OPENED")
f2:SetScript("OnEvent", AddLootItemLevels)

---------------------------------------------------------------------------------------

GameTooltip:HookScript("OnTooltipSetItem", function(self)
    local _, itemLink = self:GetItem()
    if itemLink then
        local _, _, _, ilvl = GetItemInfo(itemLink)
        if ilvl then
            self:AddLine("Item Level: " .. ilvl, 1, 1, 0)
            self:Show()
        end
    end
end)