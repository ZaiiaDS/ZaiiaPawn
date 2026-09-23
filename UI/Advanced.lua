-------------------------------------------------
-- ZaiiaPawn UI/Advanced.lua
-------------------------------------------------
ZaiiaPawn = ZaiiaPawn or {}

local advancedFrame
local advRows = {}

local function EnsureAdvancedFrame()
    if advancedFrame then return end
    advancedFrame = CreateFrame("Frame", "ZaiiaPawnAdvancedFrame", UIParent)
    advancedFrame:SetWidth(460); advancedFrame:SetHeight(420)
    advancedFrame:SetPoint("CENTER", 40, 20)
    advancedFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
    })
    advancedFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    advancedFrame:EnableMouse(true)
    advancedFrame:SetMovable(true)
    advancedFrame:RegisterForDrag("LeftButton")
    advancedFrame:SetScript("OnDragStart", function() this:StartMoving() end)
    advancedFrame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
    advancedFrame:Hide()

    local at = advancedFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    at:SetPoint("TOP", advancedFrame, "TOP", 0, -14)
    at:SetText("Advanced - Soft Caps")

    local close = CreateFrame("Button", nil, advancedFrame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -4, -4)

    local hint = advancedFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hint:SetPoint("TOP", at, "BOTTOM", 0, -4)
    hint:SetText("Soft Cap 0 = no DR for that stat")

    local hdr1 = advancedFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    hdr1:SetPoint("TOPLEFT", advancedFrame, "TOPLEFT", 24, -48)
    hdr1:SetText("Stat")
    local hdr2 = advancedFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    hdr2:SetPoint("TOPLEFT", advancedFrame, "TOPLEFT", 200, -48)
    hdr2:SetText("Soft Cap")
    local hdr3 = advancedFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    hdr3:SetPoint("TOPLEFT", advancedFrame, "TOPLEFT", 300, -48)
    hdr3:SetText("Post Scale")

    advancedFrame.scroll = CreateFrame("ScrollFrame", "ZaiiaPawnAdvScroll",
        advancedFrame, "UIPanelScrollFrameTemplate")
    advancedFrame.scroll:SetPoint("TOPLEFT", 16, -64)
    advancedFrame.scroll:SetPoint("BOTTOMRIGHT", -36, 50)
    advancedFrame.child = CreateFrame("Frame", nil, advancedFrame.scroll)
    advancedFrame.child:SetWidth(400); advancedFrame.child:SetHeight(2000)
    advancedFrame.scroll:SetScrollChild(advancedFrame.child)

    local save = CreateFrame("Button", nil, advancedFrame, "UIPanelButtonTemplate")
    save:SetWidth(120); save:SetHeight(26)
    save:SetPoint("BOTTOM", -70, 16)
    save:SetText("Save Soft Caps")
    save:SetScript("OnClick", function()
        if not ZaiiaPawnDB then ZaiiaPawnDB = {} end
        ZaiiaPawnDB.dr = {}
        local defaults = ZaiiaPawn.GetDefaultDR() or {}
        for _, row in ipairs(advRows) do
            local softVal = tonumber(row.soft:GetText()) or 0
            local postVal = tonumber(row.post:GetText()) or 0.5
            if softVal > 0 then
                ZaiiaPawnDB.dr[row.stat] = { softCap = softVal, postScale = postVal }
            elseif defaults[row.stat] then
                ZaiiaPawnDB.dr[row.stat] = { softCap = 0, postScale = postVal }
            end
        end
        if ZaiiaPawn_ClearScoreCache then ZaiiaPawn_ClearScoreCache() end
        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00ZaiiaPawn: Soft caps saved.|r")
    end)

    local clear = CreateFrame("Button", nil, advancedFrame, "UIPanelButtonTemplate")
    clear:SetWidth(100); clear:SetHeight(26)
    clear:SetPoint("BOTTOM", 70, 16)
    clear:SetText("Clear All")
    clear:SetScript("OnClick", function()
        if not ZaiiaPawnDB then ZaiiaPawnDB = {} end
        ZaiiaPawnDB.dr = {}
        for _, row in ipairs(advRows) do
            row.soft:SetText("0"); row.post:SetText("0")
        end
        if ZaiiaPawn_ClearScoreCache then ZaiiaPawn_ClearScoreCache() end
        DEFAULT_CHAT_FRAME:AddMessage("|cFFFF9900ZaiiaPawn: Soft caps cleared.|r")
    end)
end

local function BuildAdvancedRows()
    EnsureAdvancedFrame()
    for _, row in ipairs(advRows) do
        if row.frame then row.frame:Hide(); row.frame:SetParent(nil) end
    end
    advRows = {}

    -- Use current set's weights as the primary stat source.
    -- GetDefaultWeights already returns the current set (via ClassRoles),
    -- so this covers the "no set selected yet" case too.
    local statsMap = {}
    local cur = ZaiiaPawn.GetDefaultWeights() or {}
    for s in pairs(cur) do statsMap[s] = true end

    -- Fallback for a fresh install with no sets yet:
    -- collect every stat from every class.
    if not next(statsMap) and defaultWeights then
        for _, classTable in pairs(defaultWeights) do
            if type(classTable) == "table" then
                for k, v in pairs(classTable) do
                    if type(v) == "table" then
                        for s in pairs(v) do statsMap[s] = true end
                    else
                        statsMap[k] = true
                    end
                end
            end
        end
    end

    local stats = {}
    for s in pairs(statsMap) do table.insert(stats, s) end
    table.sort(stats)

    local y = -4
    for _, stat in ipairs(stats) do
        local f = CreateFrame("Frame", nil, advancedFrame.child)
        f:SetWidth(380); f:SetHeight(24)
        f:SetPoint("TOPLEFT", advancedFrame.child, "TOPLEFT", 4, y)

        local lab = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        lab:SetPoint("LEFT", 2, 0); lab:SetWidth(170)
        lab:SetJustifyH("LEFT"); lab:SetText(stat)

        local soft = CreateFrame("EditBox", nil, f)
        soft:SetWidth(70); soft:SetHeight(18); soft:SetPoint("LEFT", 180, 0)
        soft:SetAutoFocus(false); soft:SetFontObject("GameFontHighlight")
        soft:SetJustifyH("CENTER")
        soft:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 8, edgeSize = 12,
        })
        soft:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
        soft:SetBackdropBorderColor(0.7, 0.7, 0.7, 1)

        local post = CreateFrame("EditBox", nil, f)
        post:SetWidth(70); post:SetHeight(18); post:SetPoint("LEFT", 280, 0)
        post:SetAutoFocus(false); post:SetFontObject("GameFontHighlight")
        post:SetJustifyH("CENTER")
        post:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 8, edgeSize = 12,
        })
        post:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
        post:SetBackdropBorderColor(0.7, 0.7, 0.7, 1)

        local dr = ZaiiaPawn.GetDR(stat)
        if ZaiiaPawnDB and ZaiiaPawnDB.dr and ZaiiaPawnDB.dr[stat]
            and tonumber(ZaiiaPawnDB.dr[stat].softCap) == 0 then
            soft:SetText("0")
            post:SetText(tostring(ZaiiaPawnDB.dr[stat].postScale or 0))
        elseif dr and dr.softCap then
            soft:SetText(tostring(dr.softCap))
            post:SetText(tostring(dr.postScale or 0.5))
        else
            soft:SetText("0"); post:SetText("0")
        end

        table.insert(advRows, { frame = f, stat = stat, soft = soft, post = post })
        y = y - 26
    end
    advancedFrame.child:SetHeight(math.max(200, -y + 20))
end

function ToggleAdvancedFrame()
    EnsureAdvancedFrame()
    if advancedFrame:IsShown() then
        advancedFrame:Hide()
    else
        BuildAdvancedRows()
        advancedFrame:Show()
    end
end