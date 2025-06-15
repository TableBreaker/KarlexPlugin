local frame = CreateFrame("Frame")
frame:RegisterEvent("UNIT_HEALTH")
frame:RegisterEvent("UNIT_MAXHEALTH")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")

local targetHealthStr

local function UpdateTargetHealth()
    if UnitExists("target") and not UnitIsDead("target") then
        local cur = UnitHealth("target")
        local max = UnitHealthMax("target")
        local perc = cur / max * 100
        targetHealthStr = string.format("%d / %d (%.1f%%)", BreakUpLargeNumbers(cur), BreakUpLargeNumbers(max), perc)
    end
end

frame:SetScript("OnEvent", UpdateTargetHealth)

local f = CreateFrame("Frame")

-- 存储所有我们 Hook 过的 nameplates
local targetFrame

-- 添加血量文本到姓名板
local function AddHealthTextToPlate(unitFrame)
    if unitFrame.healthText then return end

    local healthBar = unitFrame.healthBar
    local hpText = healthBar:CreateFontString(nil, "OVERLAY")
    local font, size, flags = GameFontNormal:GetFont()
    hpText:SetFont(font, 8, "OUTLINE") -- 设置为10号字，带描边
    hpText:SetPoint("CENTER", healthBar, "CENTER", 0, 0)
    hpText:SetTextColor(1, 1, 1)
    unitFrame.healthText = hpText

    -- 连击点文本
    local comboText = healthBar:CreateFontString(nil, "OVERLAY")
    comboText:SetFont(font, 12, "OUTLINE")
    comboText:SetPoint("TOP", healthBar, "BOTTOM", 0, -2)
    unitFrame.comboText = comboText
end

-- 更新血量文字
local function UpdateHealthText(unitFrame)
    if not unitFrame.healthText then return end

    unitFrame.healthText:SetText(targetHealthStr)

    -- 更新连击点
    if unitFrame.comboText then
        local combo = 0
        if UnitExists("target") and UnitCanAttack("player", "target") then
            combo = GetComboPoints("player", "target")
        end

        if combo > 0 then
            if combo >= 5 then
                unitFrame.comboText:SetTextColor(1, 0, 0) -- 红色
            else
                unitFrame.comboText:SetTextColor(1, 1, 0) -- 黄色
            end
            unitFrame.comboText:SetText("Combo: " .. combo)
            unitFrame.comboText:Show()
        else
            unitFrame.comboText:SetText("")
            unitFrame.comboText:Hide()
        end
    end
end

local function ClearHealthTextFromPlate(unitFrame)
    if unitFrame.healthText then
        unitFrame.healthText:Hide()
        unitFrame.healthText = nil
    end

    if unitFrame.comboText then
        unitFrame.comboText:Hide()
        unitFrame.comboText = nil
    end
end

-- 尝试 Hook 新出现的姓名板
local function TryHookNameplates()
    local findTarget = false
    for _, namePlate in ipairs(C_NamePlate.GetNamePlates(true)) do
        if namePlate.namePlateUnitToken and UnitIsUnit(namePlate.namePlateUnitToken, "target") then
            local unitFrame = namePlate.UnitFrame or namePlate:GetChildren()
            findTarget = true
            if targetFrame and targetFrame ~= unitFrame then
                ClearHealthTextFromPlate(targetFrame)
                targetFrame = nil
            end

            if unitFrame and targetFrame == nil then
                AddHealthTextToPlate(unitFrame)
                targetFrame = unitFrame
            end
        end
    end

    if not findTarget and targetFrame then
        ClearHealthTextFromPlate(targetFrame)
        targetFrame = nil
    end
end

-- 每帧检查（也可以用定时器优化）
f:SetScript("OnUpdate", function(self, elapsed)
    TryHookNameplates()
    if targetFrame then
        UpdateHealthText(targetFrame)
    end
end)

-- 开始监听
f:RegisterEvent("NAME_PLATE_UNIT_ADDED")
f:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event, ...)
    TryHookNameplates()
end)