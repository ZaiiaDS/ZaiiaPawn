-------------------------------------------------
-- ZaiiaPawn Tooltip/Handler.lua
-------------------------------------------------
ZaiiaPawn = ZaiiaPawn or {}

local registeredTooltips = {}

-- Adds multi-set lines if any set produces output.
-- Sets zpScored=true only on success (so OnShow-retry can fire again).
function ZaiiaPawn.AddScoreToTooltip(tooltip)
    if not tooltip then return end
    if tooltip.zpScored then return end
    if not ZaiiaPawn.AddMultiRoleLines(tooltip) then
        return -- will retry via delay
    end
    tooltip.zpScored = true
    tooltip:Show()
end

-------------------------------------------------
-- Retry queue
--
-- Some tooltips are not populated immediately (the client
-- asks for item data asynchronously), so we re-attempt
-- scoring 0.05s later.  A single shared frame drives all
-- pending retries; previously a fresh Frame was created
-- per failed attempt, which leaked frames on grey items.
-------------------------------------------------
local retryQueue = {}
local retryFrame

local function ProcessRetryQueue()
    local elapsed = arg1 or 0
    local i = 1
    while i <= table.getn(retryQueue) do
        local entry = retryQueue[i]
        entry.t = entry.t + elapsed
        if entry.t > 0.05 then
            local f = entry.frame
            if f and f:IsVisible() and not f.zpScored then
                ZaiiaPawn.AddScoreToTooltip(f)
            end
            table.remove(retryQueue, i)
        else
            i = i + 1
        end
    end
    if table.getn(retryQueue) == 0 and retryFrame then
        retryFrame:SetScript("OnUpdate", nil)
    end
end

local function ScheduleRetry(f)
    if not retryFrame then
        retryFrame = CreateFrame("Frame")
    end
    table.insert(retryQueue, { frame = f, t = 0 })
    retryFrame:SetScript("OnUpdate", ProcessRetryQueue)
end

-------------------------------------------------
-- Tooltip registration
-------------------------------------------------
local function RegisterTooltip(tip)
    if not tip or type(tip) ~= "table" then return end
    if registeredTooltips[tip] then return end
    if not tip.NumLines or not tip.GetName then return end
    local tipName = tip:GetName()
    if not tipName or tipName == "ZaiiaPawnScanTooltip" then return end
    if not getglobal(tipName .. "TextLeft1") then return end

    registeredTooltips[tip] = true

    local oldShow = tip:GetScript("OnShow")
    tip:SetScript("OnShow", function()
        if oldShow then oldShow() end
        if this.zpScored then return end
        ZaiiaPawn.AddScoreToTooltip(this)
        if not this.zpScored then
            ScheduleRetry(this)
        end
    end)

    local oldHide = tip:GetScript("OnHide")
    tip:SetScript("OnHide", function()
        this.zpScored = nil
        this.zpTotals = nil
        this.itemLink = nil
        if oldHide then oldHide() end
    end)
end

local KNOWN_TOOLTIP_NAMES = {
    "GameTooltip", "ItemRefTooltip",
    "ShoppingTooltip1", "ShoppingTooltip2",
    "AtlasCFMLootTooltip", "AtlasCFMLootTooltip2",
    "AtlasLootTooltip", "AtlasLootTooltip2",
    "AtlasTooltip", "LinkWrangler",
    "ComparisonTooltip1", "ComparisonTooltip2",
}

local function RegisterKnownTooltips()
    local i
    for i = 1, table.getn(KNOWN_TOOLTIP_NAMES) do
        local tip = getglobal(KNOWN_TOOLTIP_NAMES[i])
        if tip then RegisterTooltip(tip) end
    end
end

RegisterKnownTooltips()

local regFrame = CreateFrame("Frame")
regFrame:RegisterEvent("ADDON_LOADED")
regFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
regFrame:SetScript("OnEvent", function()
    RegisterKnownTooltips()
end)

do
    local discover = CreateFrame("Frame")
    local t = 0
    local ticks = 0
    discover:SetScript("OnUpdate", function()
        t = t + arg1
        if t < 2 then return end
        t = 0
        ticks = ticks + 1
        RegisterKnownTooltips()
        if ticks >= 15 then discover:SetScript("OnUpdate", nil) end
    end)
end

-------------------------------------------------
-- Classic Set* hooks (fast path)
-------------------------------------------------
local function hook(method, after)
    local orig = GameTooltip[method]
    if not orig then return end
    GameTooltip[method] = function(self, a1, a2, a3, a4, a5)
        self.zpScored = nil
        self.zpTotals = nil
        local result = orig(self, a1, a2, a3, a4, a5)
        if after then after(self, a1, a2) end
        ZaiiaPawn.AddScoreToTooltip(self)
        return result
    end
end

hook("SetBagItem", function(self, bag, slot)
    self.itemLink = GetContainerItemLink(bag, slot)
end)
hook("SetInventoryItem", function(self, unit, slot)
    self.itemLink = GetInventoryItemLink(unit, slot)
end)
if GameTooltip.SetHyperlink then
    hook("SetHyperlink", function(self, link) self.itemLink = link end)
end
if GameTooltip.SetAuctionItem then
    hook("SetAuctionItem", function(self, type, index)
        if GetAuctionItemLink then
            self.itemLink = GetAuctionItemLink(type, index)
        end
    end)
end
if GameTooltip.SetMerchantItem then
    hook("SetMerchantItem", function(self, slot)
        if GetMerchantItemLink then
            self.itemLink = GetMerchantItemLink(slot)
        end
    end)
end
if GameTooltip.SetLootItem then
    hook("SetLootItem", function(self, slot)
        if GetLootSlotLink then
            self.itemLink = GetLootSlotLink(slot)
        end
    end)
end