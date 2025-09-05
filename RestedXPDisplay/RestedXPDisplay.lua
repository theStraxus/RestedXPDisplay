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
f.remainingText:SetPoint("TOP", f.restedText, "BOTTOM", 0, -2)

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

-- Helper: disable frame permanently at max level
local function DisableAtMaxLevel()
    f:Hide()
    f:UnregisterAllEvents()
    DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Rested XP frame disabled at max level.|r")
end

-- Function to update texts
local function UpdateXPTexts()
    local playerLevel = UnitLevel("player")
    local maxLevel = 60 -- Vanilla Classic cap

    -- Auto-disable if at or above max level
    if playerLevel >= maxLevel then
        DisableAtMaxLevel()
        return
    end

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
f:RegisterEvent("PLAYER_LEVEL_UP")

f:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_ENTERING_WORLD" then
        -- Check immediately if at max level
        if UnitLevel("player") >= 60 then
            DisableAtMaxLevel()
            return
        end
        -- Restore saved position
        if RestedXPDB.point then
            f:ClearAllPoints()
            f:SetPoint(RestedXPDB.point, UIParent, RestedXPDB.relPoint, RestedXPDB.xOfs, RestedXPDB.yOfs)
        end
    end
    UpdateXPTexts()
end)

-- Initial check at addon load
if UnitLevel("player") >= 60 then
    DisableAtMaxLevel()
else
    UpdateXPTexts()
end

-- Slash command
SLASH_RESTEDXP1 = "/restedxp"
SlashCmdList["RESTEDXP"] = function(msg)
    if UnitLevel("player") >= 60 then
        DEFAULT_CHAT_FRAME:AddMessage("|cffffff00Rested XP frame is disabled at max level.|r")
        return
    end

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
