-------------------------------------------------
-- ZaiiaPawn Core/Init.lua
-------------------------------------------------
ZaiiaPawn = ZaiiaPawn or {}
ZaiiaPawnDB = ZaiiaPawnDB or nil

local function EnsureDB()
    if type(ZaiiaPawnDB) ~= "table" then ZaiiaPawnDB = {} end
    if type(ZaiiaPawnDB.sets) ~= "table" then ZaiiaPawnDB.sets = {} end
    if type(ZaiiaPawnDB.activeSets) ~= "table" then ZaiiaPawnDB.activeSets = {} end
    if type(ZaiiaPawnDB.dr) ~= "table" then ZaiiaPawnDB.dr = {} end
    if ZaiiaPawnDB.compareEnabled == nil then ZaiiaPawnDB.compareEnabled = true end
    if ZaiiaPawnDB.seeded == nil then ZaiiaPawnDB.seeded = false end
end

local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
initFrame:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" then
        if arg1 ~= "ZaiiaPawn" then return end
        EnsureDB()

    elseif event == "PLAYER_ENTERING_WORLD" then
        this:UnregisterEvent("PLAYER_ENTERING_WORLD")

        if not ZaiiaPawnDB.seeded then
            local class = ZaiiaPawn.GetClass()
            if class then ZaiiaPawn.SeedSetsFromDefaults(class) end
            ZaiiaPawnDB.seeded = true
        end

        if not ZaiiaPawnDB.currentSet
            or not ZaiiaPawnDB.sets[ZaiiaPawnDB.currentSet] then
            local names = ZaiiaPawn.GetAllSetNames()
            if table.getn(names) > 0 then
                ZaiiaPawnDB.currentSet = names[1]
            else
                DEFAULT_CHAT_FRAME:AddMessage(
                    "|cFF00FF00ZaiiaPawn|r: no sets configured. "
                    .. "Open /zp or click the minimap icon to create one.")
            end
        end

        if ZaiiaPawn_OnDBReady then ZaiiaPawn_OnDBReady() end
    end
end)

-------------------------------------------------
-- Slash command
-------------------------------------------------
SLASH_ZAIIAPAWN1 = "/zp"
SlashCmdList["ZAIIAPAWN"] = function(msg)
    msg = msg or ""
    local cmd = string.lower(string.gsub(msg, "^%s*(.-)%s*$", "%1"))
    if cmd == "rec" or cmd == "recommender" then
        if ZaiiaPawnRecommender and ZaiiaPawnRecommender.OnSlashRec then
            ZaiiaPawnRecommender.OnSlashRec()
        end
        return
    end
    if ToggleConfigFrame then ToggleConfigFrame() end
end

function ZaiiaPawn_OnDBReady() end