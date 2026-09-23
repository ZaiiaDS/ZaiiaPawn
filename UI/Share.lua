-------------------------------------------------
-- ZaiiaPawn UI/Share.lua
-------------------------------------------------
ZaiiaPawn = ZaiiaPawn or {}

local shareFrame
local cachedText = ""

-------------------------------------------------
-- Helpers
-------------------------------------------------
local function SanitizeName(s)
    if not s then return "" end
    s = string.gsub(s, "\r", " ")
    s = string.gsub(s, "\n", " ")
    s = string.gsub(s, "\t", " ")
    s = string.gsub(s, "|", "_")
    s = string.gsub(s, "^%s+", "")
    s = string.gsub(s, "%s+$", "")
    return s
end

local function NormalizeEOL(str)
    str = string.gsub(str, "\r\n", "\n")
    str = string.gsub(str, "\r", "\n")
    str = string.gsub(str, "\t", " ")
    str = string.gsub(str, "%z", "")
    return str
end

local function StripAllControl(str)
    str = string.gsub(str, "\r", "")
    str = string.gsub(str, "\n", "")
    str = string.gsub(str, "\t", "")
    str = string.gsub(str, "%z", "")
    return str
end

local function WrapLongLine(text, maxLen)
    maxLen = maxLen or 60
    if string.len(text) <= maxLen then return text end
    local out = ""
    local first = true
    while string.len(text) > maxLen do
        local cut = maxLen
        local pos = maxLen
        while pos >= 1 do
            if string.sub(text, pos, pos) == "," then
                cut = pos
                break
            end
            pos = pos - 1
        end
        local chunk = string.sub(text, 1, cut)
        text = string.sub(text, cut + 1)
        if first then
            out = chunk
            first = false
        else
            out = out .. "\n+" .. chunk
        end
    end
    if string.len(text) > 0 then
        out = out .. "\n+" .. text
    end
    return out
end

-------------------------------------------------
-- Single-set Pawn v1 export / import
-------------------------------------------------
function ZaiiaPawn.ExportPawnFormat(setName, weights)
    setName = setName or ZaiiaPawn.GetCurrentSet() or "Default"
    weights = weights or ZaiiaPawn.GetSetWeights(setName)

    local parts = {}
    for stat, val in pairs(weights) do
        local token = ZaiiaPawn.PAWN_STAT_MAP[stat]
        if token and val and math.abs(val) > 0.00001 then
            table.insert(parts, token .. "=" .. ZaiiaPawn.TrimNum(val))
        end
    end
    table.sort(parts)

    -- Raw set name only - no class prefix, no extras.
    local body = ""
    if table.getn(parts) > 0 then
        body = parts[1]
        for i = 2, table.getn(parts) do
            body = body .. ", " .. parts[i]
        end
    end
    return "( Pawn: v1: \"" .. setName .. "\": " .. body .. " )"
end

function ZaiiaPawn.ImportPawnFormat(str)
    if not str or str == "" then return false, "Empty string" end
    str = StripAllControl(str)
    str = string.gsub(str, "^%s+", "")
    str = string.gsub(str, "%s+$", "")

    local _, _, ver, name, body = string.find(str,
        "^%(%s*Pawn:%s*(v%d+):%s*\"([^\"]*)\":%s*(.-)%s*%)$")
    if not ver then
        _, _, ver, name, body = string.find(str,
            "^%(%s*Pawn:%s*(v%d+):%s*([^:]*):%s*(.-)%s*%)$")
    end
    if not ver or not body then return false, "Invalid Pawn format" end

    local overrides = {}
    local chunk
    for chunk in string.gfind(body, "[^,]+") do
        local _, _, token, val = string.find(chunk,
            "^%s*([%w_%-]+)%s*=%s*([%-%d%.]+)%s*$")
        if token and val then
            local stat = ZaiiaPawn.PAWN_STAT_MAP_REVERSE[token]
            if stat then
                local v = tonumber(val)
                if v then overrides[stat] = v end
            end
        end
    end
    if not next(overrides) then return false, "No recognized stats" end

    local desiredName = nil
    if name and name ~= "" then
        desiredName = SanitizeName(name)
    end

    local set = ZaiiaPawn.GetCurrentSet()

    if desiredName then
        -- If a set with that name exists (and it's NOT the current
        -- one), rename the current set to "<name> (imported)".
        local finalName = desiredName
        if ZaiiaPawn.GetSet(desiredName) and desiredName ~= set then
            finalName = desiredName .. " (imported)"
            local n = 2
            while ZaiiaPawn.GetSet(finalName) and finalName ~= set do
                finalName = desiredName .. " (imported " .. n .. ")"
                n = n + 1
            end
        end

        if set then
            if finalName ~= set then
                local ok, err = ZaiiaPawn.RenameSet(set, finalName)
                if not ok then return false, err end
            end
            set = finalName
        else
            local ok, err = ZaiiaPawn.CreateSet(finalName, overrides)
            if not ok then return false, err end
            set = finalName
        end
        ZaiiaPawn.SetCurrentSet(set)
    else
        if not set then
            local ok, err = ZaiiaPawn.CreateSet("Imported", overrides)
            if not ok then return false, err end
            set = "Imported"
            ZaiiaPawn.SetCurrentSet(set)
        end
    end

    local existing = ZaiiaPawn.GetSetWeights(set)
    local newWeights = {}
    for k, v in pairs(existing) do newWeights[k] = v end
    for k, v in pairs(overrides) do newWeights[k] = v end
    ZaiiaPawn.UpdateSetWeights(set, newWeights)

    if ZaiiaPawn.RefreshSetList then ZaiiaPawn.RefreshSetList() end
    return true, set, name
end

-------------------------------------------------
-- notUsable (de)serialization
-------------------------------------------------
local function SerializeNU(nu)
    if type(nu) ~= "table" then return "" end
    local sections = {}

    if type(nu.byEquipLoc) == "table" then
        local items = {}
        for k in pairs(nu.byEquipLoc) do table.insert(items, k) end
        if table.getn(items) > 0 then
            table.sort(items)
            table.insert(sections, "eq=" .. table.concat(items, ","))
        end
    end

    if type(nu.byClassSubclass) == "table" then
        local items = {}
        local cid, subs
        for cid, subs in pairs(nu.byClassSubclass) do
            if type(subs) == "table" then
                local sid
                for sid in pairs(subs) do
                    table.insert(items,
                        tostring(cid) .. ":" .. tostring(sid))
                end
            end
        end
        if table.getn(items) > 0 then
            table.sort(items)
            table.insert(sections, "cs=" .. table.concat(items, ","))
        end
    end

    if type(nu.byClassEquipLoc) == "table" then
        local items = {}
        local cid, locs
        for cid, locs in pairs(nu.byClassEquipLoc) do
            if type(locs) == "table" then
                local loc
                for loc in pairs(locs) do
                    table.insert(items, tostring(cid) .. ":" .. loc)
                end
            end
        end
        if table.getn(items) > 0 then
            table.sort(items)
            table.insert(sections, "ce=" .. table.concat(items, ","))
        end
    end

    return table.concat(sections, ";")
end

local function ParseNU(nustr)
    if not nustr or nustr == "" then return nil end
    local nu = {}
    local section
    for section in string.gfind(nustr, "[^;]+") do
        if string.find(section, "^eq=") then
            nu.byEquipLoc = nu.byEquipLoc or {}
            local item
            for item in string.gfind(string.sub(section, 4), "[^,]+") do
                nu.byEquipLoc[item] = true
            end
        elseif string.find(section, "^cs=") then
            nu.byClassSubclass = nu.byClassSubclass or {}
            local pair
            for pair in string.gfind(string.sub(section, 4), "[^,]+") do
                local _, _, cid, sid = string.find(pair, "^(%d+):(%d+)$")
                if cid and sid then
                    cid = tonumber(cid); sid = tonumber(sid)
                    nu.byClassSubclass[cid] =
                        nu.byClassSubclass[cid] or {}
                    nu.byClassSubclass[cid][sid] = true
                end
            end
        elseif string.find(section, "^ce=") then
            nu.byClassEquipLoc = nu.byClassEquipLoc or {}
            local pair
            for pair in string.gfind(string.sub(section, 4), "[^,]+") do
                local _, _, cid, loc = string.find(pair, "^(%d+):(.+)$")
                if cid and loc then
                    cid = tonumber(cid)
                    nu.byClassEquipLoc[cid] =
                        nu.byClassEquipLoc[cid] or {}
                    nu.byClassEquipLoc[cid][loc] = true
                end
            end
        end
    end
    if next(nu) == nil then return nil end
    return nu
end

-------------------------------------------------
-- Full-profile export / import
-------------------------------------------------
function ZaiiaPawn.ExportAllSets()
    local class = ZaiiaPawn.GetClass() or "?"
    local lines = {}
    table.insert(lines, "ZPALL|" .. class)

    local names = ZaiiaPawn.GetAllSetNames()
    local i
    for i = 1, table.getn(names) do
        local name = names[i]
        local set = ZaiiaPawn.GetSet(name)
        if set then
            local safeName = SanitizeName(name)

            local wparts = {}
            local stat, val
            for stat, val in pairs(set.weights or {}) do
                local token = ZaiiaPawn.PAWN_STAT_MAP[stat]
                if token and val and math.abs(val) > 0.00001 then
                    table.insert(wparts,
                        token .. "=" .. ZaiiaPawn.TrimNum(val))
                end
            end
            table.sort(wparts)
            local wstr = table.concat(wparts, ",")

            local nustr = SerializeNU(set.notUsable)

            local wlines = {}
            local wrapped = WrapLongLine(wstr, 60)
            local ln
            for ln in string.gfind(wrapped, "[^\n]+") do
                table.insert(wlines, ln)
            end

            local first = "SET:" .. safeName .. "|W:" .. wlines[1]
            for k = 2, table.getn(wlines) do
                first = first .. "\n" .. wlines[k]
            end
            if nustr ~= "" then
                first = first .. "|NU:" .. nustr
            end

            table.insert(lines, first)
        end
    end

    return table.concat(lines, "\n")
end

function ZaiiaPawn.ImportAllSets(str)
    if not str or str == "" then return false, "Empty" end
    str = NormalizeEOL(str)
    str = string.gsub(str, "^%s+", "")
    str = string.gsub(str, "%s+$", "")

    local rawLines = {}
    local ln
    for ln in string.gfind(str, "[^\n]+") do
        table.insert(rawLines, ln)
    end
    if table.getn(rawLines) == 0 then return false, "Empty body" end

    local logical = {}
    local i
    for i = 1, table.getn(rawLines) do
        local line = rawLines[i]
        if string.sub(line, 1, 1) == "+" then
            if table.getn(logical) > 0 then
                logical[table.getn(logical)] =
                    logical[table.getn(logical)] .. string.sub(line, 2)
            end
        else
            table.insert(logical, line)
        end
    end

    local header = logical[1]
    local p1 = string.find(header, "|")
    if not p1 then return false, "No header separator" end
    local tag = string.sub(header, 1, p1 - 1)
    if tag ~= "ZPALL" then
        return false, "Not a ZPALL export (tag='" .. tag .. "')"
    end

    local class = ""
    local c
    for c in string.gfind(string.sub(header, p1 + 1), "[^|]+") do
        class = c
        break
    end
    class = string.gsub(class, "^%s+", "")
    class = string.gsub(class, "%s+$", "")

    local playerClass = ZaiiaPawn.GetClass()
    if class ~= playerClass then
        return false, "Class mismatch: [" .. class
            .. "] vs [" .. tostring(playerClass) .. "]"
    end

    local created, updated, skipped = 0, 0, 0
    local firstImported

    for i = 2, table.getn(logical) do
        local blob = logical[i]
        if blob and blob ~= "" then
            local fields = {}
            local f
            for f in string.gfind(blob, "[^|]+") do
                table.insert(fields, f)
            end

            local name, wstr, nustr
            local j
            for j = 1, table.getn(fields) do
                local fd = fields[j]
                if string.find(fd, "^SET:") then
                    name = string.sub(fd, 5)
                elseif string.find(fd, "^W:") then
                    wstr = string.sub(fd, 3)
                elseif string.find(fd, "^NU:") then
                    nustr = string.sub(fd, 4)
                end
            end

            name = SanitizeName(name)

            if name and name ~= "" and wstr then
                local weights = {}
                local chunk
                for chunk in string.gfind(wstr, "[^,]+") do
                    local _, _, token, val = string.find(chunk,
                        "^%s*([%w_%-]+)%s*=%s*([%-%d%.]+)%s*$")
                    if token and val then
                        local stat = ZaiiaPawn.PAWN_STAT_MAP_REVERSE[token]
                        if stat then
                            weights[stat] = tonumber(val) or 0
                        end
                    end
                end

                local nu = ParseNU(nustr)

                if ZaiiaPawn.GetSet(name) then
                    ZaiiaPawn.UpdateSetWeights(name, weights)
                    ZaiiaPawn.SetSetNotUsable(name, nu)
                    updated = updated + 1
                    if not firstImported then firstImported = name end
                else
                    local ok = ZaiiaPawn.CreateSet(name, weights, nil, nu)
                    if ok then
                        created = created + 1
                        if not firstImported then firstImported = name end
                    else
                        skipped = skipped + 1
                    end
                end
            else
                skipped = skipped + 1
            end
        end
    end

    if firstImported then
        ZaiiaPawn.SetCurrentSet(firstImported)
    end
    if ZaiiaPawn.RefreshSetList then ZaiiaPawn.RefreshSetList() end
    return true, created, updated, skipped
end

-------------------------------------------------
-- Share frame
-------------------------------------------------
local function EnsureShareFrame()
    if shareFrame then return end
    shareFrame = CreateFrame("Frame", "ZaiiaPawnShareFrame", UIParent)
    shareFrame:SetWidth(520); shareFrame:SetHeight(440)
    shareFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
    shareFrame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
    })
    shareFrame:SetFrameStrata("FULLSCREEN_DIALOG")
    shareFrame:EnableMouse(true)
    shareFrame:SetMovable(true)
    shareFrame:RegisterForDrag("LeftButton")
    shareFrame:SetScript("OnDragStart", function() this:StartMoving() end)
    shareFrame:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
    shareFrame:Hide()

    local st = shareFrame:CreateFontString(nil, "OVERLAY",
        "GameFontHighlightLarge")
    st:SetPoint("TOP", shareFrame, "TOP", 0, -14)
    st:SetText("Share Weights")

    local close = CreateFrame("Button", nil, shareFrame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", shareFrame, "TOPRIGHT", -4, -4)

    local hint = shareFrame:CreateFontString(nil, "OVERLAY",
        "GameFontNormalSmall")
    hint:SetPoint("TOP", st, "BOTTOM", 0, -4)
    hint:SetWidth(480)
    hint:SetJustifyH("LEFT")
    hint:SetText("Export -> click Copy (then Ctrl+C).  "
        .. "Import: paste into the box, click Import.")

    -------------------------------------------------
    -- Edit area: backdrop frame + ScrollFrame + EditBox
    --
    -- Mirrors the standard MacroFrame layout: the EditBox
    -- lives inside a ScrollFrame, so long text is clipped
    -- at the ScrollFrame bounds and word-wraps at the
    -- EditBox width.  Fixed size prevents the 1.12 layout
    -- bug where two anchors collapsed the frame.
    -------------------------------------------------
    local boxBg = CreateFrame("Frame", "ZaiiaPawnShareBoxBg", shareFrame)
    boxBg:SetPoint("TOPLEFT", shareFrame, "TOPLEFT", 28, -80)
    boxBg:SetPoint("BOTTOMRIGHT", shareFrame, "BOTTOMRIGHT", -28, 96)
    boxBg:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 8, edgeSize = 12,
    })
    boxBg:SetBackdropColor(0, 0, 0, 0.6)
    boxBg:SetBackdropBorderColor(0.7, 0.7, 0.7, 1)

    local sf = CreateFrame("ScrollFrame", "ZaiiaPawnShareScroll",
        boxBg, "UIPanelScrollFrameTemplate")
    sf:SetPoint("TOPLEFT", boxBg, "TOPLEFT", 4, -4)
    sf:SetPoint("BOTTOMRIGHT", boxBg, "BOTTOMRIGHT", -26, 4)
    sf:EnableMouseWheel(true)

    local box = CreateFrame("EditBox", "ZaiiaPawnShareEditBox", sf)
    box:SetMultiLine(true)
    box:SetAutoFocus(false)
    box:SetMaxLetters(0)
    box:SetFontObject(ChatFontNormal)
    box:SetTextInsets(0, 0, 0, 0)
    box:SetWidth(400)
    box:SetHeight(2000)
    box:SetPoint("TOPLEFT", sf, "TOPLEFT", 0, 0)
    sf:SetScrollChild(box)
    box:SetScript("OnEscapePressed", function() this:ClearFocus() end)
    shareFrame.edit = box
    shareFrame.scroll = sf

    local function RefreshScrollHeight()
        local text = box:GetText() or ""
        -- Count wrapped lines: line breaks + estimated wrap at 55 chars.
        local lines = 1
        local line
        for line in string.gfind(text .. "\n", "([^\n]*)\n") do
            local l = string.len(line)
            local wrapped = math.floor(l / 55) + 1
            lines = lines + wrapped - 1
        end
        local h = lines * 14 + 20
        if h < 200 then h = 200 end
        box:SetHeight(h)
        if sf.UpdateScrollChildRect then sf:UpdateScrollChildRect() end
        if sf.SetVerticalScroll then sf:SetVerticalScroll(0) end
    end
    shareFrame.refreshScroll = RefreshScrollHeight

    local function SetBoxText(s)
        box:SetText(s or "")
        box:SetCursorPosition(0)
        RefreshScrollHeight()
    end
    shareFrame.setBoxText = SetBoxText

    -------------------------------------------------
    -- Row 1: export
    -------------------------------------------------
    local expCurrent = CreateFrame("Button", nil, shareFrame,
        "UIPanelButtonTemplate")
    expCurrent:SetWidth(220); expCurrent:SetHeight(26)
    expCurrent:SetPoint("BOTTOMLEFT", shareFrame, "BOTTOMLEFT", 25, 52)
    expCurrent:SetText("Export current (Pawn)")
    expCurrent:SetScript("OnClick", function()
        cachedText = ZaiiaPawn.ExportPawnFormat()
        SetBoxText(cachedText)
        DEFAULT_CHAT_FRAME:AddMessage(
            "|cFF00FF00ZaiiaPawn: exported current set ("
            .. tostring(string.len(cachedText)) .. " chars).|r")
    end)

    local expAll = CreateFrame("Button", nil, shareFrame,
        "UIPanelButtonTemplate")
    expAll:SetWidth(220); expAll:SetHeight(26)
    expAll:SetPoint("BOTTOMRIGHT", shareFrame, "BOTTOMRIGHT", -25, 52)
    expAll:SetText("Export ALL sets")
    expAll:SetScript("OnClick", function()
        cachedText = ZaiiaPawn.ExportAllSets()
        SetBoxText(cachedText)
        DEFAULT_CHAT_FRAME:AddMessage(
            "|cFF00FF00ZaiiaPawn: exported ALL sets ("
            .. tostring(string.len(cachedText)) .. " chars).|r")
    end)

    -------------------------------------------------
    -- Row 2: copy / import
    -------------------------------------------------
    local copyBtn = CreateFrame("Button", nil, shareFrame,
        "UIPanelButtonTemplate")
    copyBtn:SetWidth(220); copyBtn:SetHeight(26)
    copyBtn:SetPoint("BOTTOMLEFT", shareFrame, "BOTTOMLEFT", 25, 16)
    copyBtn:SetText("Copy  (then Ctrl+C)")
    copyBtn:SetScript("OnClick", function()
        if not cachedText or cachedText == "" then
            DEFAULT_CHAT_FRAME:AddMessage(
                "|cFFFF9900ZaiiaPawn: export something first.|r")
            return
        end
        box:SetFocus()
        box:HighlightText()
        DEFAULT_CHAT_FRAME:AddMessage(
            "|cFF00FF00ZaiiaPawn: text selected - press Ctrl+C now.|r")
    end)

    local importBtn = CreateFrame("Button", nil, shareFrame,
        "UIPanelButtonTemplate")
    importBtn:SetWidth(220); importBtn:SetHeight(26)
    importBtn:SetPoint("BOTTOMRIGHT", shareFrame, "BOTTOMRIGHT", -25, 16)
    importBtn:SetText("Import from Box")
    importBtn:SetScript("OnClick", function()
        local text = box:GetText() or ""
        local trimmed = string.gsub(text, "^%s+", "")
        if trimmed == "" then
            DEFAULT_CHAT_FRAME:AddMessage(
                "|cFFFF9900ZaiiaPawn: paste text into the box first.|r")
            return
        end

        if string.find(trimmed, "^ZPALL") then
            local ok, a, b, c = ZaiiaPawn.ImportAllSets(text)
            if not ok then
                DEFAULT_CHAT_FRAME:AddMessage(
                    "|cFFFF0000ZaiiaPawn: import failed - "
                    .. tostring(a) .. "|r")
                return
            end
            local msg = "|cFF00FF00ZaiiaPawn: imported " .. tostring(a)
                .. " new, " .. tostring(b) .. " updated"
            if c and c > 0 then
                msg = msg .. ", " .. tostring(c) .. " skipped"
            end
            DEFAULT_CHAT_FRAME:AddMessage(msg .. ".|r")
            shareFrame:Hide()
        elseif string.find(trimmed, "^%(") then
            local ok, info, name = ZaiiaPawn.ImportPawnFormat(text)
            if not ok then
                DEFAULT_CHAT_FRAME:AddMessage(
                    "|cFFFF0000ZaiiaPawn: import failed - "
                    .. tostring(info) .. "|r")
                return
            end
            local extra = ""
            if name and name ~= "" then extra = " (" .. name .. ")" end
            DEFAULT_CHAT_FRAME:AddMessage(
                "|cFF00FF00ZaiiaPawn: imported into set '"
                .. tostring(info) .. "'" .. extra .. ".|r")
            shareFrame:Hide()
        else
            DEFAULT_CHAT_FRAME:AddMessage(
                "|cFFFF0000ZaiiaPawn: unrecognized format.  "
                .. "Expected ZPALL... or ( Pawn: ... ).|r")
        end
    end)

    -- Ensure layout updates when user types/pastes into the box.
    box:SetScript("OnTextChanged", function()
        if shareFrame.refreshScroll then shareFrame.refreshScroll() end
    end)
end

function ToggleShareFrame()
    EnsureShareFrame()
    if shareFrame:IsShown() then
        shareFrame:Hide()
    else
        cachedText = ""
        if shareFrame.setBoxText then
            shareFrame.setBoxText("")
        end
        shareFrame:Show()
    end
end