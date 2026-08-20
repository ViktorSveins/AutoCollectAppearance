-- AutoCollectAppearance
-- Auto-accepts the Ascension "collect appearance" confirmation popup
-- (shown when ctrl-alt-clicking an item to add its look to your collection),
-- and provides a bag sweep that collects every uncollected appearance.
--
-- Commands:
--   /aca        - toggle auto-accept on/off
--   /aca bags   - collect the appearance of every eligible item in your bags
--
-- On login the addon creates a per-character macro "CollectLooks" (/aca bags).
--
-- Note: collecting an appearance SOULBINDS the item (that is what the
-- confirmation popup warns about); the item is not consumed.

local TOKEN = "CONFIRM_COLLECT_APPEARANCE"
local MACRO_NAME = "CollectLooks"
local enabled = true
local probing = false

local function Print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cff33ff99AutoCollectAppearance:|r " .. msg)
end

local function DumpVal(v, depth)
    if type(v) == "table" then
        if (depth or 0) > 1 then return "{...}" end
        local parts = {}
        for k, val in pairs(v) do
            parts[#parts + 1] = tostring(k) .. "=" .. DumpVal(val, (depth or 0) + 1)
        end
        return "{" .. table.concat(parts, ", ") .. "}"
    end
    return tostring(v)
end

-- Auto-accept the confirmation popup
hooksecurefunc("StaticPopup_Show", function(which)
    if which ~= TOKEN then return end
    local frame = StaticPopup_Visible(TOKEN)
    if not frame then return end
    if probing then
        probing = false
        local fr = _G[frame]
        Print("PROBE which=" .. tostring(fr.which))
        Print("PROBE data=" .. DumpVal(fr.data))
        Print("PROBE data2=" .. DumpVal(fr.data2))
        Print("PROBE text_arg1=" .. tostring(fr.text_arg1) .. " text_arg2=" .. tostring(fr.text_arg2))
        local d = StaticPopupDialogs[TOKEN]
        if d then
            local keys = {}
            for k, v in pairs(d) do keys[#keys + 1] = tostring(k) .. ":" .. type(v) end
            table.sort(keys)
            Print("PROBE dialog fields: " .. table.concat(keys, ", "))
        end
        Print("probe done - popup left open, accept or cancel it manually.")
        return
    end
    if not enabled then return end
    local button = _G[frame .. "Button1"]
    if button and button:IsEnabled() then
        button:Click()
    end
end)

-- Sweep bags 0-4 and collect every uncollected appearance.
-- The collect call takes the bag item's GUID string (same payload the
-- CONFIRM_COLLECT_APPEARANCE popup's OnAccept receives), NOT the itemID.
-- WARNING: collecting soulbinds the item.
local function CollectBags()
    if not (C_Appearance and C_AppearanceCollection and GetContainerItemGUID
            and C_Appearance.GetItemAppearanceID
            and C_AppearanceCollection.IsAppearanceCollected
            and C_AppearanceCollection.CollectItemAppearance) then
        Print("appearance API not available on this client.")
        return
    end
    local collected, seen = 0, {}
    for bag = 0, 4 do
        for slot = 1, (GetContainerNumSlots(bag) or 0) do
            local itemID = GetContainerItemID(bag, slot)
            local guid = itemID and GetContainerItemGUID(bag, slot)
            if guid then
                local appearanceID = C_Appearance.GetItemAppearanceID(itemID)
                if appearanceID and not seen[appearanceID]
                        and not C_AppearanceCollection.IsAppearanceCollected(appearanceID) then
                    seen[appearanceID] = true
                    local link = GetContainerItemLink(bag, slot)
                    C_AppearanceCollection.CollectItemAppearance(guid)
                    collected = collected + 1
                    Print("collecting " .. (link or ("item " .. itemID)))
                end
            end
        end
    end
    Print(collected .. " new appearance(s) collected.")
end

-- Create the per-character macro once
local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function()
    if GetMacroIndexByName(MACRO_NAME) == 0 then
        local ok = pcall(CreateMacro, MACRO_NAME, 1, "/aca bags", 1)
        if ok then
            Print("created macro '" .. MACRO_NAME .. "' (/aca bags). Find it in the per-character macro tab.")
        else
            Print("could not create macro '" .. MACRO_NAME .. "' (macro slots full?). Make one yourself with body: /aca bags")
        end
    end
end)

SLASH_AUTOCOLLECTAPPEARANCE1 = "/aca"
SlashCmdList["AUTOCOLLECTAPPEARANCE"] = function(msg)
    msg = (msg or ""):lower():match("^%s*(.-)%s*$")
    if msg == "bags" then
        CollectBags()
    elseif msg == "probe" then
        probing = true
        Print("probe armed - now ctrl-alt-click ONE item and paste the PROBE lines back.")
    else
        enabled = not enabled
        Print("auto-accept " .. (enabled and "|cff00ff00enabled|r" or "|cffff0000disabled|r"))
    end
end
