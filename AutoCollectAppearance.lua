-- AutoCollectAppearance: auto-accepts the "collect appearance" popup and
-- sweeps bags for uncollected looks.
-- /aca (toggle), /aca bags, /aca probe

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
        Print("probe done; popup left open.")
        return
    end
    if not enabled then return end
    local button = _G[frame .. "Button1"]
    if button and button:IsEnabled() then
        button:Click()
    end
end)

-- CollectItemAppearance takes the container item's GUID string, not the itemID.
-- Collecting soulbinds the item.
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

local loader = CreateFrame("Frame")
loader:RegisterEvent("PLAYER_LOGIN")
loader:SetScript("OnEvent", function()
    if GetMacroIndexByName(MACRO_NAME) == 0 then
        local ok = pcall(CreateMacro, MACRO_NAME, 1, "/aca bags", 1)
        if ok then
            Print("created macro '" .. MACRO_NAME .. "' (/aca bags).")
        else
            Print("could not create macro '" .. MACRO_NAME .. "'; make one with: /aca bags")
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
        Print("probe armed; ctrl-alt-click one item.")
    else
        enabled = not enabled
        Print("auto-accept " .. (enabled and "|cff00ff00enabled|r" or "|cffff0000disabled|r"))
    end
end
