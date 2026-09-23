-------------------------------------------------
-- ZaiiaPawn UI/Paperdoll.lua
-------------------------------------------------
ZaiiaPawn = ZaiiaPawn or {}

local playerHolder, playerFS
local inspectHolder, inspectFS
local hookedFrames = {}
local inspectDelayFrame

local function ScoreColor(n)
    n = n or 0
    if n >= 1700 then return 1.0, 0.15, 0.15
    elseif n >= 1200 then return 1.0, 0.5, 0.0
    elseif n >= 700 then return 0.64, 0.21, 0.93
    elseif n >= 400 then return 0.0, 0.44, 0.87
    elseif n >= 200 then return 0.12, 1.0, 0.0
    elseif n >= 100 then return 1.0, 1.0, 1.0
    else return 0.6, 0.6, 0.6 end
end

local function ColorHex(n)
    local r, g, b = ScoreColor(n)
    return string.format("%02x%02x%02x", r * 255, g * 255, b * 255)
end

local function FormatScoreLine(setName, n)
    n = n or 0
    return setName .. ": |cFF" .. ColorHex(n) .. string.format("%.1f|r", n)
end

-------------------------------------------------
-- Resolve set names + weights for a unit/class.
-- isSelf=true  -> player's active sets.
-- isSelf=false -> per-class inspect set, or default roles of that class.
-------------------------------------------------
local function ResolveForClass(class, isSelf)
    if isSelf then
        local active = ZaiiaPawn.GetActiveSets()
        local out = {}
        for _, name in ipairs(active) do
            if ZaiiaPawn.GetSet(name) then
                local w = ZaiiaPawn.GetSetWeights(name)
                if next(w) ~= nil then
                    table.insert(out, {
                        name = name,
                        weights = w,
                        notUsable = ZaiiaPawn.GetSetNotUsable(name),
                    })
                end
            end
        end
        if table.getn(out) == 0 then
            local cur = ZaiiaPawn.GetCurrentSet()
            if cur and ZaiiaPawn.GetSet(cur) then
                local w = ZaiiaPawn.GetSetWeights(cur)
                if next(w) ~= nil then
                    out = { {
                        name = cur,
                        weights = w,
                        notUsable = ZaiiaPawn.GetSetNotUsable(cur),
                    } }
                end
            end
        end
        return out
    end

    -- Inspect: per-class inspect set if set, else default roles of that class.
    local inspectSet = ZaiiaPawn.GetInspectSet and ZaiiaPawn.GetInspectSet(class)
    if inspectSet and ZaiiaPawn.GetSet(inspectSet) then
        local w = ZaiiaPawn.GetSetWeights(inspectSet)
        if next(w) ~= nil then
            return { {
                name = inspectSet,
                weights = w,
                notUsable = ZaiiaPawn.GetSetNotUsable(inspectSet),
            } }
        end
    end

    -- Default roles (no notUsable filter, no per-role filter info)
    local out = {}
    local roles = ZaiiaPawn.GetRolesForClass(class)
    for _, role in ipairs(roles) do
        local w = ZaiiaPawn.GetBaseWeights(class, role)
        if next(w) ~= nil then
            table.insert(out, { name = role, weights = w, notUsable = nil })
        end
    end
    return out
end

local function BuildScoreText(unit, class, isSelf)
    local entries = ResolveForClass(class, isSelf)
    if table.getn(entries) == 0 then
        return "ZaiiaPawn: (no active sets)"
    end
    local lines = {}
    local first = true
    for _, e in ipairs(entries) do
        local score
        if isSelf then
            score = ZaiiaPawn.ScoreUnitEquipped(
                "player", e.weights, e.name, e.notUsable) or 0
        else
            score = ZaiiaPawn.ScoreUnitEquipped(
                unit, e.weights, e.name, e.notUsable) or 0
        end
        local prefix = first and "ZaiiaPawn " or "          "
        table.insert(lines, prefix .. FormatScoreLine(e.name, score))
        first = false
    end
    return table.concat(lines, "\n")
end

-------------------------------------------------
-- Player (Character Frame)
-------------------------------------------------
local function EnsurePlayerUI()
    if playerHolder then return end
    local parent = PaperDollFrame or CharacterFrame
    if not parent then return end

    playerHolder = CreateFrame("Frame", "ZaiiaPawnPlayerScoreFrame", parent)
    playerHolder:SetWidth(280); playerHolder:SetHeight(72)
    playerHolder:SetFrameStrata("HIGH")
    playerHolder:SetFrameLevel((parent.GetFrameLevel and parent:GetFrameLevel()
        or 0) + 20)
    playerHolder:SetPoint("TOP", parent, "TOP", 0, -60)

    playerFS = playerHolder:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    playerFS:SetPoint("TOP", playerHolder, "TOP", 0, 0)
    playerFS:SetJustifyH("CENTER")
    playerFS:SetText("ZaiiaPawn: ...")
    playerHolder:Show()
end

function ZaiiaPawn_UpdatePlayerPaperScore()
    EnsurePlayerUI()
    if not playerFS then return end
    local class = ZaiiaPawn.GetClass()
    playerFS:SetText(BuildScoreText("player", class, true))
    if playerHolder then playerHolder:Show() end
end

-------------------------------------------------
-- Inspect (Inspect Frame)
-------------------------------------------------
local function EnsureInspectUI()
    if inspectHolder then return end
    local parent = InspectPaperDollFrame or InspectFrame
    if not parent then return end

    inspectHolder = CreateFrame("Frame", "ZaiiaPawnInspectScoreFrame", parent)
    inspectHolder:SetWidth(280); inspectHolder:SetHeight(72)
    inspectHolder:SetFrameStrata("HIGH")
    inspectHolder:SetFrameLevel((parent.GetFrameLevel and parent:GetFrameLevel()
        or 0) + 20)
    inspectHolder:SetPoint("TOP", parent, "TOP", 0, -60)

    inspectFS = inspectHolder:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    inspectFS:SetPoint("TOP", inspectHolder, "TOP", 0, 0)
    inspectFS:SetJustifyH("CENTER")
    inspectFS:SetText("ZaiiaPawn: ...")
    inspectHolder:Show()
end

function ZaiiaPawn_UpdateInspectPaperScore()
    EnsureInspectUI()
    if not inspectFS then return end
    if not UnitExists("target") or not UnitIsPlayer("target") then
        inspectFS:SetText("ZaiiaPawn: --")
        return
    end
    local _, class = UnitClass("target")
    inspectFS:SetText(BuildScoreText("target", class, false))
end

-------------------------------------------------
-- Hooks
-------------------------------------------------
-- Guard against multiple hooking: each frame is hooked exactly once.
local function HookShowOnce(frame, cb)
    if not frame then return end
    if hookedFrames[frame] then return end
    hookedFrames[frame] = true
    local old = frame:GetScript("OnShow")
    frame:SetScript("OnShow", function()
        if old then old() end
        cb()
    end)
end

-- Single shared delayed-execution frame for inspect (0.2s).
local function ScheduleInspectUpdate()
    if not inspectDelayFrame then
        inspectDelayFrame = CreateFrame("Frame")
    end
    local elapsed = 0
    inspectDelayFrame:SetScript("OnUpdate", function()
        elapsed = elapsed + arg1
        if elapsed > 0.2 then
            inspectDelayFrame:SetScript("OnUpdate", nil)
            ZaiiaPawn_UpdateInspectPaperScore()
        end
    end)
end

local function TryHookAll()
    HookShowOnce(CharacterFrame, ZaiiaPawn_UpdatePlayerPaperScore)
    HookShowOnce(PaperDollFrame, ZaiiaPawn_UpdatePlayerPaperScore)
    HookShowOnce(InspectFrame, ScheduleInspectUpdate)
    HookShowOnce(InspectPaperDollFrame, ZaiiaPawn_UpdateInspectPaperScore)
end

local ef = CreateFrame("Frame")
ef:RegisterEvent("PLAYER_ENTERING_WORLD")
ef:RegisterEvent("UNIT_INVENTORY_CHANGED")
ef:RegisterEvent("ADDON_LOADED")
ef:RegisterEvent("PLAYER_TARGET_CHANGED")
ef:SetScript("OnEvent", function()
    if event == "PLAYER_ENTERING_WORLD" then
        TryHookAll()
        if CharacterFrame and CharacterFrame:IsShown() then
            ZaiiaPawn_UpdatePlayerPaperScore()
        end
    elseif event == "ADDON_LOADED" and arg1 == "Blizzard_InspectUI" then
        TryHookAll()
    elseif event == "UNIT_INVENTORY_CHANGED" then
        if arg1 == "player" and CharacterFrame and CharacterFrame:IsShown() then
            ZaiiaPawn_UpdatePlayerPaperScore()
        elseif InspectFrame and InspectFrame:IsShown() then
            ZaiiaPawn_UpdateInspectPaperScore()
        end
    elseif event == "PLAYER_TARGET_CHANGED" then
        if InspectFrame and InspectFrame:IsShown() then
            ZaiiaPawn_UpdateInspectPaperScore()
        end
    end
end)

TryHookAll()