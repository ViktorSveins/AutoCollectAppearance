-- AutoCollectAppearance
-- Auto-accepts the Ascension "collect appearance" confirmation popup
-- (shown when ctrl-alt-clicking an item to add its look to your collection).
--
-- Toggle at runtime with /aca

local TOKEN = "CONFIRM_COLLECT_APPEARANCE"
local enabled = true

hooksecurefunc("StaticPopup_Show", function(which)
    if not enabled or which ~= TOKEN then return end
    local frame = StaticPopup_Visible(TOKEN)
    if frame then
        local button = _G[frame .. "Button1"]
        if button and button:IsEnabled() then
            button:Click()
        end
    end
end)

SLASH_AUTOCOLLECTAPPEARANCE1 = "/aca"
SlashCmdList["AUTOCOLLECTAPPEARANCE"] = function()
    enabled = not enabled
    DEFAULT_CHAT_FRAME:AddMessage("AutoCollectAppearance: " .. (enabled and "|cff00ff00enabled|r" or "|cffff0000disabled|r"))
end
