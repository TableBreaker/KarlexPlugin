local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")

local isRegenEnable = true -- 默认状态为 true
f:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_DISABLED" then
        isRegenEnable = false
    elseif event == "PLAYER_REGEN_ENABLED" then
        isRegenEnable = true
    end
end)

local NUM_SEGMENTS = 100
local RADIUS = 100
local CENTER_X, CENTER_Y = 0, 0 -- 相对于UIParent中心

local ringFrame = CreateFrame("Frame", "KarlexEnergyRing", UIParent)
ringFrame:SetSize(RADIUS*2+20, RADIUS*2+20)
ringFrame:SetPoint("CENTER", UIParent, "CENTER", CENTER_X, CENTER_Y)
ringFrame:Show()

local segments = {}
local energyText

for i = 1, NUM_SEGMENTS do
    local tex = ringFrame:CreateTexture(nil, "ARTWORK")
    energyText = ringFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    energyText:SetPoint("CENTER", ringFrame, "CENTER", 0, 0)
    energyText:SetTextColor(1, 1, 0)

    tex:SetTexture("Interface\\AddOns\\Karlex_Plugins\\Resources\\bar_energy.png") -- 你需要准备一张细长矩形的贴图
    tex:SetSize(2, 10)
    local angle = (i-1) * (360/NUM_SEGMENTS) + 90
    local rad = math.rad(angle)
    local x = RADIUS * math.cos(rad)
    local y = RADIUS * math.sin(rad)
    tex:SetPoint("CENTER", ringFrame, "CENTER", x, y)
    tex:SetRotation(rad + math.pi/2)
    tex:SetVertexColor(1, 1, 0, 0.8)
    tex:Hide()
    segments[i] = tex
end

local function UpdateRing()
    if not UnitExists("target") or UnitIsDead("target") or isRegenEnable then
        energyText:Hide()
        for i = 1, NUM_SEGMENTS do
            segments[i]:Hide()
        end
        return
    end

    local cur = UnitPower("player")
    local max = UnitPowerMax("player")
    energyText:Show()
    energyText:SetText(cur .. " / " .. max)

    local percent = max > 0 and cur / max or 0
    local showCount = math.floor(NUM_SEGMENTS * percent + 0.5)
    for i = 1, NUM_SEGMENTS do
        if i <= showCount then
            segments[i]:Show()
        else
            segments[i]:Hide()
        end
    end
end

ringFrame:SetScript("OnEvent", UpdateRing)
ringFrame:SetScript("OnUpdate", UpdateRing)
ringFrame:RegisterEvent("UNIT_POWER_UPDATE")
ringFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
ringFrame:RegisterEvent("UNIT_DISPLAYPOWER")

UpdateRing()