local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, addon)
    if event == "ADDON_LOADED" and addon == "sync-friends-and-ignores" then
        SendAddonMessage("sync-friends-and-ignores", "addon loaded")
    end
end)