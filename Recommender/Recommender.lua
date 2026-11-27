-- ZaiiaPawn Recommender.lua (v3.5 Final)
-- Fixed: persistent checkbox state (LoadFilters/SaveFilters), nil guards, performance
ZaiiaPawn = ZaiiaPawn or {}
ZaiiaPawnRecommender = ZaiiaPawnRecommender or {}

ZaiiaPawnRecommender.INV_SLOT = {
    head = 1, neck = 2, shoulder = 3, chest = 5,
    waist = 6, legs = 7, feet = 8, wrist = 9, hands = 10,
    ring1 = 11, ring2 = 12, trinket1 = 13, trinket2 = 14,
    back = 15, mainhand = 16, offhand = 17, ranged = 18,
}

ZaiiaPawnRecommender.SLOT_NAMES = {
    head = "Head", neck = "Neck", shoulder = "Shoulder", back = "Back",
    chest = "Chest", wrist = "Wrist", hands = "Hands", waist = "Waist",
    legs = "Legs", feet = "Feet", ring = "Ring", trinket = "Trinket",
    mainhand = "Main Hand", offhand = "Off Hand", ranged = "Ranged",
}

ZaiiaPawnRecommender.SLOT_MAP = {
    INVTYPE_HEAD = "head", INVTYPE_NECK = "neck",
    INVTYPE_SHOULDER = "shoulder", INVTYPE_CLOAK = "back",
    INVTYPE_CHEST = "chest", INVTYPE_ROBE = "chest",
    INVTYPE_WRIST = "wrist", INVTYPE_HANDS = "hands",
    INVTYPE_WAIST = "waist", INVTYPE_LEGS = "legs",
    INVTYPE_FEET = "feet", INVTYPE_FINGER = "ring",
    INVTYPE_TRINKET = "trinket",
    INVTYPE_WEAPON = "mainhand", INVTYPE_WEAPONMAINHAND = "mainhand",
    INVTYPE_2HWEAPON = "mainhand",
    INVTYPE_WEAPONOFFHAND = "offhand", INVTYPE_SHIELD = "offhand",
    INVTYPE_HOLDABLE = "offhand",
    INVTYPE_RANGED = "ranged", INVTYPE_RANGEDRIGHT = "ranged",
    INVTYPE_THROWN = "ranged", INVTYPE_RELIC = "ranged",
}

do
    local locs = {}
    for equipLoc, baseSlot in pairs(ZaiiaPawnRecommender.SLOT_MAP) do
        if baseSlot == "ring" then
            locs["ring"] = { "INVTYPE_FINGER" }
        elseif baseSlot == "trinket" then
            locs["trinket"] = { "INVTYPE_TRINKET" }
        else
            locs[baseSlot] = locs[baseSlot] or {}
            table.insert(locs[baseSlot], equipLoc)
        end
    end
    ZaiiaPawnRecommender.SLOT_TO_EQUIPLOCS = locs
end

ZaiiaPawnRecommender.CLASS_ARMOR = {
    WARRIOR = { [1]=1, [2]=1, [3]=1, [4]=1 },
    PALADIN = { [1]=1, [2]=1, [3]=1, [4]=1 },
    HUNTER  = { [1]=1, [2]=1, [3]=1 },
    ROGUE   = { [1]=1, [2]=1 },
    PRIEST  = { [1]=1 },
    SHAMAN  = { [1]=1, [2]=1, [3]=1 },
    MAGE    = { [1]=1 },
    WARLOCK = { [1]=1 },
    DRUID   = { [1]=1, [2]=1 },
}

ZaiiaPawnRecommender.ARMOR_NAMES = { [1]="Cloth", [2]="Leather", [3]="Mail", [4]="Plate" }

local CLASS_ID = {
    WARRIOR = 1, PALADIN = 2, HUNTER  = 3, ROGUE  = 4,
    PRIEST  = 5, SHAMAN  = 7, MAGE    = 8, WARLOCK = 9, DRUID = 11,
}

ZaiiaPawnRecommender._state = {
    items = {}, cache = {}, filters = {}, cachedLevel = nil, cachedSet = nil,
    activeSlot = "head", loadedAt = nil, frame = nil,
}

-- Load persistent filters from ZaiiaPawnDB
local function LoadFilters()
    if ZaiiaPawnDB and ZaiiaPawnDB.recommenderFilters then
        for subID, val in pairs(ZaiiaPawnDB.recommenderFilters) do
            ZaiiaPawnRecommender._state.filters[tonumber(subID)] = val
        end
    end
end

-- Save filters to ZaiiaPawnDB
local function SaveFilters()
    if not ZaiiaPawnDB then ZaiiaPawnDB = {} end
    ZaiiaPawnDB.recommenderFilters = {}
    for subID, val in pairs(ZaiiaPawnRecommender._state.filters) do
        ZaiiaPawnDB.recommenderFilters[subID] = val
    end
end

function ZaiiaPawnRecommender.LoadFromData()
    local data = ZaiiaPawnRecommenderData
    if not data or not data.items then return false end
    local st = ZaiiaPawnRecommender._state
    st.items = {}
    for id, arr in pairs(data.items) do
        if type(arr) == "table" and arr[1] and arr[2] then
            local link = arr[1]
            local _, _, nm = string.find(link, "%[(.-)%]")
            st.items[id] = {
                id = tonumber(id) or id,
                name = nm or "?",
                link = link,
                equipLoc = arr[2],
                reqLevel = tonumber(arr[3]) or 0,
                classID = tonumber(arr[4]) or 0,
                subclassID = tonumber(arr[5]) or 0,
                ilvl = tonumber(arr[6]) or 0,
                stats = arr[7] or {},
                setID = tonumber(arr[8]),
                classMask = -1,
            }
        end
    end
    st.loadedAt = time()
    local _, classToken = UnitClass("player")
    local allowed = ZaiiaPawnRecommender.CLASS_ARMOR[classToken] or { [1]=1 }
    -- Load saved filters FIRST, then apply defaults only for missing keys
    LoadFilters()
    for subID in pairs(allowed) do
        if st.filters[subID] == nil then
            st.filters[subID] = true
        end
    end
    if classToken == "PALADIN" then ZaiiaPawnRecommender.SLOT_NAMES.ranged = "Libram"
    elseif classToken == "DRUID" then ZaiiaPawnRecommender.SLOT_NAMES.ranged = "Idol"
    elseif classToken == "SHAMAN" then ZaiiaPawnRecommender.SLOT_NAMES.ranged = "Totem"
    else ZaiiaPawnRecommender.SLOT_NAMES.ranged = "Ranged" end
    return true
end

function ZaiiaPawnRecommender.GetPlayerClassID()
    local _, token = UnitClass("player")
    return CLASS_ID[token]
end

function ZaiiaPawnRecommender.GetEquippedLink(slotKey)
    local inv = ZaiiaPawnRecommender.INV_SLOT[slotKey]
    if not inv then return nil end
    return GetInventoryItemLink("player", inv)
end

local function ItemIDFromLink(link)
    if not link then return nil end
    local id = string.match(link, "item:(%d+)")
    return id and tonumber(id) or nil
end

local function IsItemLevelAllowed(itemId, itemReqLevel)
    local playerLevel = UnitLevel("player") or 1
    if itemReqLevel and itemReqLevel > 0 then
        return itemReqLevel <= playerLevel
    end
    local srcs = ZaiiaPawnSources and ZaiiaPawnSources.sources[itemId]
    if not srcs then return true end
    local minReq = nil
    for _, s in ipairs(srcs) do
        if s.reqLevel and s.reqLevel > 0 then
            if not minReq or s.reqLevel < minReq then
                minReq = s.reqLevel
            end
        end
    end
    if not minReq then return true end
    return minReq <= playerLevel
end

local function ParseSetBonusText(text, weights)
    if not text then return 0 end
    local upper = string.upper(text)
    local val, stat = string.match(upper, "%+(%d+)%s+(.+)")
    if val and stat then return tonumber(val) * (weights[stat] or 0) end
    local stat2, val2 = string.match(upper, "INCREASES?%s+(.+)%s*%+(%d+)")
    if stat2 and val2 then return tonumber(val2) * (weights[stat2] or 0) end
    local crit = string.match(upper, "CRITICAL STRIKE BY (%d+)")
    if crit then return tonumber(crit) * (weights["CRIT"] or 0) end
    return 0
end

local function GetSetBonusScore(it, weights, equippedMap)
    if not it.setID then return 0 end
    local setInfo = ZaiiaPawnSetBonus and ZaiiaPawnSetBonus.sets[it.setID]
    if not setInfo or not setInfo.members then return 0 end
    local equippedCount = 0
    for _, memberID in ipairs(setInfo.members) do
        if equippedMap[memberID] then
            equippedCount = equippedCount + 1
        end
    end
    local virtualCount = equippedCount + 1
    local bonusScore = 0
    if setInfo.bonuses then
        for _, bonus in ipairs(setInfo.bonuses) do
            if bonus.count == virtualCount then
                bonusScore = bonusScore + ParseSetBonusText(bonus.text, weights)
            end
        end
    end
    return bonusScore
end

function ZaiiaPawnRecommender.IsUsable(it)
    if not it then return false end
    if not it.link then return false end
    if not IsItemLevelAllowed(it.id, it.reqLevel) then return false end
    if it.classID == 4 and it.subclassID >= 1 and it.subclassID <= 4 and it.equipLoc ~= "INVTYPE_CLOAK" then
        if not ZaiiaPawnRecommender._state.filters[it.subclassID] then return false end
    end
    local setName = ZaiiaPawn.GetCurrentSet and ZaiiaPawn.GetCurrentSet()
    if setName and ZaiiaPawn.GetSetNotUsable and ZaiiaPawn.IsEquipLocBlocked then
        local nu = ZaiiaPawn.GetSetNotUsable(setName)
        if nu and ZaiiaPawn.IsEquipLocBlocked(it.link, nu) then return false end
    end
    return true
end

function ZaiiaPawnRecommender.ScoreItem(it, weights, equippedMap)
    local baseScore = 0
    local stats = it.stats or {}
    if stats.WEAPON_DAMAGE_MIN and stats.WEAPON_DAMAGE_MAX then
        local avg = (stats.WEAPON_DAMAGE_MIN + stats.WEAPON_DAMAGE_MAX) / 2
        baseScore = baseScore + avg * (weights["WEAPON DAMAGE"] or 0)
    end
    for rawKey, val in pairs(stats) do
        if rawKey ~= "WEAPON_DAMAGE_MIN" and rawKey ~= "WEAPON_DAMAGE_MAX" then
            local key = string.gsub(rawKey, "_", " ")
            local w = weights[key]
            if w then baseScore = baseScore + val * w end
        end
    end
    local tokenScore = 0
    local tokens = ZaiiaPawnEffects and ZaiiaPawnEffects.effect_tokens and ZaiiaPawnEffects.effect_tokens[it.id]
    if tokens then
        for _, t in ipairs(tokens) do
            if t.action == "proc_damage" then
                tokenScore = tokenScore + (weights["PROCS"] or 0)
                tokenScore = tokenScore + (t.value or 0) * (weights["PROC DAMAGE"] or 0)
            end
        end
    end
    local setScore = GetSetBonusScore(it, weights, equippedMap)
    return baseScore + tokenScore + setScore, baseScore + tokenScore, setScore
end

local function InvalidateCacheIfNeeded()
    local st = ZaiiaPawnRecommender._state
    local curLevel = UnitLevel("player") or 1
    local curSet = ZaiiaPawn.GetCurrentSet and ZaiiaPawn.GetCurrentSet()
    if curLevel ~= st.cachedLevel or curSet ~= st.cachedSet then
        st.cache = {}
        st.cachedLevel = curLevel
        st.cachedSet = curSet
    end
end

local function GetEquippedIDs(slotKey)
    if slotKey == "ring" then
        return ItemIDFromLink(ZaiiaPawnRecommender.GetEquippedLink("ring1")),
               ItemIDFromLink(ZaiiaPawnRecommender.GetEquippedLink("ring2"))
    elseif slotKey == "trinket" then
        return ItemIDFromLink(ZaiiaPawnRecommender.GetEquippedLink("trinket1")),
               ItemIDFromLink(ZaiiaPawnRecommender.GetEquippedLink("trinket2"))
    else
        return ItemIDFromLink(ZaiiaPawnRecommender.GetEquippedLink(slotKey)), nil
    end
end

local function BuildEquippedMap()
    local map = {}
    for _, inv in pairs(ZaiiaPawnRecommender.INV_SLOT) do
        local link = GetInventoryItemLink("player", inv)
        if link then
            local id = ItemIDFromLink(link)
            if id then map[id] = true end
        end
    end
    return map
end

local function CreateTab(parent, slotKey)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetWidth(64)
    btn:SetHeight(24)
    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    btn.text:SetPoint("CENTER")
    btn.text:SetText(ZaiiaPawnRecommender.SLOT_NAMES[slotKey] or slotKey)
    btn.activeTex = btn:CreateTexture(nil, "BACKGROUND")
    btn.activeTex:SetAllPoints()
    btn.activeTex:SetTexture(0.2, 0.4, 0.6, 0.8)
    btn.activeTex:Hide()
    btn:SetScript("OnClick", function() ZaiiaPawnRecommender.RenderSlot(slotKey) end)
    btn.slotKey = slotKey
    return btn
end

local function CreateCheckbox(parent, subID, nameStr, xOffset)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetPoint("TOPLEFT", xOffset, 0)
    cb:SetWidth(20)
    cb:SetHeight(20)
    cb:SetHitRectInsets(0, -60, 0, 0)
    local label = cb:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("LEFT", cb, "RIGHT", 2, 0)
    label:SetText(nameStr)
    cb:SetScript("OnClick", function()
        local checked = this:GetChecked()
        if checked == 1 or checked == true then
            ZaiiaPawnRecommender._state.filters[subID] = true
        else
            ZaiiaPawnRecommender._state.filters[subID] = false
        end
        SaveFilters()
        ZaiiaPawnRecommender._state.cache[ZaiiaPawnRecommender._state.activeSlot] = nil
        ZaiiaPawnRecommender.RenderSlot(ZaiiaPawnRecommender._state.activeSlot)
    end)
    return cb
end

local function CreateRow(parent, index)
    local row = CreateFrame("Button", nil, parent)
    row:SetWidth(510)
    row:SetHeight(24)
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", 0, -(index - 1) * 24)
    row.bg = row:CreateTexture(nil, "BACKGROUND")
    row.bg:SetAllPoints()
    row.bg:SetTexture(0, 0, 0, 0.3)
    if index % 2 == 0 then row.bg:Hide() end
    local fontPath, _, fontFlags = GameFontNormal:GetFont()
    row.text = row:CreateFontString(nil, "OVERLAY")
    row.text:SetFont(fontPath, 14, fontFlags)
    row.text:SetPoint("LEFT", 4, 0)
    row.text:SetJustifyH("LEFT")
    row.scoreText = row:CreateFontString(nil, "OVERLAY")
    row.scoreText:SetFont(fontPath, 14, fontFlags)
    row.scoreText:SetPoint("RIGHT", -4, 0)
    row.scoreText:SetJustifyH("RIGHT")
    row:SetScript("OnClick", function()
        if IsShiftKeyDown() and row.itemLink then
            local editBox = GetCurrentKeyBoardFocus()
            if editBox and editBox:IsShown() then
                editBox:Insert(row.itemLink)
            end
        end
    end)
    row:SetScript("OnEnter", function()
        if row.itemLink then
            GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(row.itemLink)
            local sources = ZaiiaPawnSources and ZaiiaPawnSources.sources[row.itemID]
            if sources then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine("Sources:", 1, 1, 0)
                for _, src in ipairs(sources) do
                    local sType = src.type or "?"
                    local sName = src.name or "?"
                    GameTooltip:AddLine(sType..": "..sName, 0.8, 0.8, 0.8)
                end
            end
            GameTooltip:Show()
        end
    end)
    row:SetScript("OnLeave", function() GameTooltip:Hide() end)
    return row
end

function ZaiiaPawnRecommender.DrawList(items)
    local st = ZaiiaPawnRecommender._state
    local f = st.frame
    if not f or not f.rows then return end
    local numItems = #items
    if numItems == 0 then
        for i = 1, 20 do f.rows[i]:Hide() end
        if f.scrollBar then FauxScrollFrame_Update(f.scrollBar, 0, 20, 24) end
        return
    end
    f.scrollChild:SetHeight(math.max(1, numItems * 24))
    local offset = FauxScrollFrame_GetOffset(f.scrollBar) or 0
    if offset > numItems - 20 then offset = math.max(0, numItems - 20) end
    local eq1, eq2 = GetEquippedIDs(st.activeSlot)
    for i = 1, 20 do
        local row = f.rows[i]
        local data = items[offset + i]
        if data then
            local it = data.item
            local isEq = (it.id == eq1 or it.id == eq2)
            local prefix = isEq and " |cffffffff[Equipped]|r" or ""
            local colorCode = "|cffffffff"
            if it.link then
                local c = string.match(it.link, "|cff%x%x%x%x%x%x")
                if c then colorCode = c end
            end
            row.text:SetText(string.format("%d. %s%s|r%s", offset + i, colorCode, it.name, prefix))
            local scoreStr = string.format("%.1f", data.totalScore or 0)
            if data.setScore and data.setScore > 0 then
                scoreStr = scoreStr .. string.format(" |cff00ff00+%.1f set|r", data.setScore)
            end
            row.scoreText:SetText(scoreStr)
            row.itemLink = it.link
            row.itemID = it.id
            row:Show()
        else
            row:Hide()
        end
    end
    FauxScrollFrame_Update(f.scrollBar, numItems, 20, 24)
    f.scrollBar:Show()
end

function ZaiiaPawnRecommender.RenderSlot(slotKey)
    InvalidateCacheIfNeeded()
    local st = ZaiiaPawnRecommender._state
    st.activeSlot = slotKey
    if st.frame and st.frame.scrollBar then
        local sb = getglobal(st.frame.scrollBar:GetName() .. "ScrollBar")
        if sb then sb:SetValue(0) end
        st.frame.scrollBar:SetVerticalScroll(0)
    end
    if st.frame and st.frame.tabs then
        for _, btn in pairs(st.frame.tabs) do
            if btn.slotKey == slotKey then btn.activeTex:Show() else btn.activeTex:Hide() end
        end
    end
    if st.cache[slotKey] then
        ZaiiaPawnRecommender.DrawList(st.cache[slotKey])
        return
    end
    local classID = ZaiiaPawnRecommender.GetPlayerClassID()
    if not classID or not ZaiiaPawnByClass or not ZaiiaPawnByClass.byCS then return end
    local equipLocs = ZaiiaPawnRecommender.SLOT_TO_EQUIPLOCS[slotKey] or {}
    local setName = ZaiiaPawn.GetCurrentSet and ZaiiaPawn.GetCurrentSet()
    local weights = (setName and ZaiiaPawn.GetSetWeights and ZaiiaPawn.GetSetWeights(setName)) or (ZaiiaPawn.GetDefaultWeights and ZaiiaPawn.GetDefaultWeights()) or {}
    local equippedMap = BuildEquippedMap()
    local results = {}
    for _, equipLoc in ipairs(equipLocs) do
        local ids = ZaiiaPawnByClass.byCS[classID] and ZaiiaPawnByClass.byCS[classID][equipLoc] or {}
        for _, id in ipairs(ids) do
            local it = st.items[id] or st.items[tostring(id)]
            if it and ZaiiaPawnRecommender.IsUsable(it) then
                local total, base, setScore = ZaiiaPawnRecommender.ScoreItem(it, weights, equippedMap)
                results[#results + 1] = { item = it, totalScore = total or 0, baseScore = base or 0, setScore = setScore or 0 }
            end
        end
    end
    table.sort(results, function(a, b) return (a.totalScore or 0) > (b.totalScore or 0) end)
    st.cache[slotKey] = results
    ZaiiaPawnRecommender.DrawList(results)
end

function ZaiiaPawnRecommender.ShowWindow()
    local st = ZaiiaPawnRecommender._state
    if not st.loadedAt then ZaiiaPawnRecommender.LoadFromData() end
    if not st.frame then
        local f = CreateFrame("Frame", "ZaiiaPawnRecommenderFrame", UIParent)
        f:SetWidth(550)
        f:SetHeight(620)
        f:SetPoint("CENTER")
        f:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true, tileSize = 32, edgeSize = 32,
            insets = { left = 8, right = 8, top = 8, bottom = 8 }
        })
        f:SetFrameStrata("DIALOG")
        f:EnableMouse(true)
        f:SetMovable(true)
        f:RegisterForDrag("LeftButton")
        f:SetScript("OnDragStart", function() this:StartMoving() end)
        f:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
        local title = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
        title:SetPoint("TOP", 0, -14)
        title:SetText("ZaiiaPawn Recommender")
        local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
        close:SetPoint("TOPRIGHT", -4, -4)
        local filterContainer = CreateFrame("Frame", nil, f)
        filterContainer:SetPoint("TOPLEFT", 15, -35)
        filterContainer:SetWidth(520)
        filterContainer:SetHeight(20)
        local _, classToken = UnitClass("player")
        local allowed = ZaiiaPawnRecommender.CLASS_ARMOR[classToken] or { [1]=1 }
        local cbx = 0
        for subID = 1, 4 do
            if allowed[subID] then
                local cb = CreateCheckbox(filterContainer, subID, ZaiiaPawnRecommender.ARMOR_NAMES[subID], cbx)
                cb:SetChecked(st.filters[subID])
                cbx = cbx + 80
            end
        end
        local recalc = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
        recalc:SetWidth(60)
        recalc:SetHeight(20)
        recalc:SetPoint("TOPRIGHT", f, "TOPRIGHT", -20, -35)
        recalc:SetText("Recalc")
        recalc:SetScript("OnClick", function()
            st.cache = {}
            ZaiiaPawnRecommender.RenderSlot(st.activeSlot)
        end)
        local tabContainer = CreateFrame("Frame", nil, f)
        tabContainer:SetPoint("TOPLEFT", 15, -65)
        tabContainer:SetWidth(520)
        tabContainer:SetHeight(50)
        f.tabs = {}
        local slotsRow1 = {"head", "neck", "shoulder", "back", "chest", "wrist", "hands", "waist"}
        local slotsRow2 = {"legs", "feet", "ring", "trinket", "mainhand", "offhand", "ranged"}
        local x, y = 0, 0
        for _, slot in ipairs(slotsRow1) do
            local btn = CreateTab(tabContainer, slot)
            btn:SetPoint("TOPLEFT", x, y)
            f.tabs[slot] = btn
            x = x + 65
        end
        x, y = 0, -26
        for _, slot in ipairs(slotsRow2) do
            local btn = CreateTab(tabContainer, slot)
            btn:SetPoint("TOPLEFT", x, y)
            f.tabs[slot] = btn
            x = x + 65
        end
        local scrollFrame = CreateFrame("ScrollFrame", "ZaiiaPawnRecommenderScroll", f, "FauxScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", 15, -125)
        scrollFrame:SetWidth(510)
        scrollFrame:SetHeight(480)
        f.scrollBar = scrollFrame
        local scrollChild = CreateFrame("Frame", nil, scrollFrame)
        scrollChild:SetWidth(510)
        scrollChild:SetHeight(1)
        scrollFrame:SetScrollChild(scrollChild)
        f.scrollChild = scrollChild
        f.rows = {}
        for i = 1, 20 do
            f.rows[i] = CreateRow(scrollFrame, i)
        end
        scrollFrame:SetScript("OnVerticalScroll", function()
            FauxScrollFrame_OnVerticalScroll(24, function(offset)
                ZaiiaPawnRecommender.DrawList(st.cache[st.activeSlot] or {})
            end)
        end)
        table.insert(UISpecialFrames, "ZaiiaPawnRecommenderFrame")
        st.frame = f
    end
    InvalidateCacheIfNeeded()
    st.frame:Show()
    st.frame:Raise()
    ZaiiaPawnRecommender.RenderSlot(st.activeSlot)
end

function ZaiiaPawnRecommender.OnSlashRec()
    ZaiiaPawnRecommender.ShowWindow()
end