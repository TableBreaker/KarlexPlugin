local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:RegisterEvent("PLAYER_REGEN_ENABLED")

-- 文字框架
local msgFrame = CreateFrame("Frame", nil, UIParent)
msgFrame:SetSize(400, 100)
msgFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
msgFrame:SetAlpha(0)
msgFrame:Hide()

local text = msgFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
text:SetPoint("CENTER")

-- 动画数据
local anim = {
    duration = 0.25,
    hold = 2,
    startY = 150,
    dy = 50, -- 垂直移动距离
}

-- 自定义 tween 动画函数
local function PlayTween(msg, isRegenEnable)
    text:SetText(msg)
    if isRegenEnable == true then
        text:SetTextColor(0, 1, 0)
    else
        text:SetTextColor(1, 0, 0)
    end

    msgFrame:Show()
    msgFrame:SetAlpha(0)

    local startTime = GetTime()
    local holdTime = anim.hold
    local moveOffset = anim.dy
    local fadeInDuration = anim.duration
    local fadeOutDuration = anim.duration

    local totalTime = fadeInDuration + holdTime + fadeOutDuration

    local startY = anim.startY

    msgFrame:SetPoint("CENTER", UIParent, "CENTER", 0, startY)

    msgFrame:SetScript("OnUpdate", function(self, elapsed)
        local now = GetTime()
        local t = now - startTime

        -- 计算透明度
        local alpha
        if t < fadeInDuration then
            alpha = t / fadeInDuration -- 淡入
        elseif t < fadeInDuration + holdTime then
            alpha = 1 -- 停留
        elseif t < totalTime then
            alpha = 1 - ((t - fadeInDuration - holdTime) / fadeOutDuration) -- 淡出
        else
            alpha = 0
        end
        self:SetAlpha(alpha)

        -- 计算位置偏移
        local y
        if t < fadeInDuration then
            y = startY + moveOffset * (t / fadeInDuration)
        elseif t < fadeInDuration + holdTime then
            y = startY + moveOffset
        elseif t < totalTime then
            y = startY + moveOffset + moveOffset * ((t - fadeInDuration - holdTime) / fadeOutDuration)
        else
            y = startY + moveOffset * 2
        end
        self:ClearAllPoints()
        self:SetPoint("CENTER", UIParent, "CENTER", 0, y)

        -- 动画结束
        if t >= totalTime then
            self:SetScript("OnUpdate", nil)
            self:Hide()
        end
    end)
end

-- 事件触发
f:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_DISABLED" then
        PlayTween("进入战斗", false)
    elseif event == "PLAYER_REGEN_ENABLED" then
        PlayTween("脱离战斗", true)
    end
end)