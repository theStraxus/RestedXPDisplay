-- SavedVariables
RestedXPDB = RestedXPDB or {}

local f = CreateFrame("Frame", "RestedXPDisplayFrame", UIParent)
f:SetWidth(220)
f:SetHeight(50)
f:SetPoint("CENTER", UIParent, "CENTER")
f:SetMovable(true)
f:SetClampedToScreen(true)
f:EnableMouse(true)
f:RegisterForDrag("LeftButton")

-- Background
f.bg = f:CreateTexture(nil, "BACKGROUND")
f.bg:SetAllPoints(f)
f.bg:SetTexture(0, 0, 0, 0.3) -- semi-transparent black

-- Rested XP text
f.restedText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
f.restedText:SetPoint("TOP", f, "TOP", 0, -5)

-- XP to Level text
f.remainingText = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
f.remainingText:SetPoint("TOP", f.restedText, "BOTTOM", 0, -2) -- closer together (-2 instead of bigger gap)

-- Dragging handlers
f:SetScript("OnDragStart", function() f:StartMoving() end)
f:SetScript("OnDragStop", function()
    f:StopMovingOrSizing()
    -- Save position
    local point, _, relPoint, xOfs, yOfs = f:GetPoint()
    RestedXPDB.point = point
    RestedXPDB.relPoint = relPoint
    RestedXPDB.xOfs = xOfs
    RestedXPDB.yOfs = yOfs
end)

-- Function to update texts
local function UpdateXPTexts()
    local rested = GetXPExhaustion()
    local currXP = UnitXP("player")
    local maxXP = UnitXPMax("player")

    if rested and maxXP > 0 then
        f.restedText:SetText(string.format("Rested XP: %d (%.1f%%)", rested, (rested / maxXP) * 100))
    else
        f.restedText:SetText("Rested XP: 0 (0%)")
    end

    if maxXP > 0 then
        local remaining = maxXP - currXP
        f.remainingText:SetText(string.format("XP to Level: %d (%.1f%%)", remaining, (remaining / maxXP) * 100))
    else
        f.remainingText:SetText("XP to Level: 0 (0%)")
    end
end

-- Events
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("UPDATE_EXHAUSTION")
f:RegisterEvent("PLAYER_XP_UPDATE")

f:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_ENTERING_WORLD" then
        -- Restore saved position
        if RestedXPDB.point then
            f:ClearAllPoints()
            f:SetPoint(RestedXPDB.point, UIParent, RestedXPDB.relPoint, RestedXPDB.xOfs, RestedXPDB.yOfs)
        end
    end
    UpdateXPTexts()
end)

-- Initial update
UpdateXPTexts()

-- Slash command
SLASH_RESTEDXP1 = "/restedxp"
SlashCmdList["RESTEDXP"] = function(msg)
    UpdateXPTexts()

    if msg == "toggle" then
        if f:IsShown() then
            f:Hide()
            DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Rested XP frame hidden. Type /restedxp toggle to show again.|r")
        else
            f:Show()
            DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Rested XP frame shown.|r")
        end
    elseif msg == "reset" then
        f:ClearAllPoints()
        f:SetPoint("CENTER", UIParent, "CENTER")
        RestedXPDB.point = nil
        DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Rested XP frame reset to center.|r")
    end
end
