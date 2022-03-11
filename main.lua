local frame = CreateFrame("Frame")

frame:RegisterEvent("ADDON_LOADED")

local STATUS_FRIEND = "friend"
local STATUS_REMOVED = "removed"

local function addon_print(msg)
    print("|cff00FF00[SyncFriendsAndIgnores]|r " .. msg)
end

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "SyncFriendsAndIgnores" then

            if FRIENDS_AND_IGNORES == nil then
                FRIENDS_AND_IGNORES = {}
            end

            self:UnregisterEvent("ADDON_LOADED")
            self:RegisterEvent("PLAYER_LOGIN")
        end
    end

    if event == "PLAYER_LOGIN" then

        -- Sync friends
        for name, data in pairs(FRIENDS_AND_IGNORES) do
            if data.status == STATUS_FRIEND then
                if not C_FriendList.IsFriend(data.guid) then
                    C_FriendList.AddFriend(name)
                end
            end

            if data.status == STATUS_REMOVED then
                if C_FriendList.IsFriend(data.guid) then
                    C_FriendList.RemoveFriend(name)
                end
            end
        end
        
        -- Add friends that this character has that are not synched
        for i = 1, C_FriendList.GetNumFriends(), 1 do
            local friend = C_FriendList.GetFriendInfoByIndex(i)
            if FRIENDS_AND_IGNORES[friend.name] == nil then
                FRIENDS_AND_IGNORES[friend.name] = {}
                FRIENDS_AND_IGNORES[friend.name]["guid"] = friend.guid
                FRIENDS_AND_IGNORES[friend.name]["status"] = STATUS_FRIEND
            end 
        end

        self:UnregisterEvent("PLAYER_LOGIN")
        self:RegisterEvent("FRIENDLIST_UPDATE")
    end

    if event == "FRIENDLIST_UPDATE" then
        local synchedFriends = {}
        local numSynchedFriends = 0
        for name, data in pairs(FRIENDS_AND_IGNORES) do
            if data.status == STATUS_FRIEND then
                synchedFriends[name] = data
                numSynchedFriends = numSynchedFriends + 1
            end
        end

        local numFriends = C_FriendList.GetNumFriends()

        -- Friends have been added, sync them as STATUS_FRIEND
        if numFriends > numSynchedFriends then
            for i = 1, numFriends, 1 do
                local friend = C_FriendList.GetFriendInfoByIndex(i)
                if FRIENDS_AND_IGNORES[friend.name] == nil or FRIENDS_AND_IGNORES[friend.name]["status"] ~= STATUS_FRIEND then
                    FRIENDS_AND_IGNORES[friend.name] = {}
                    FRIENDS_AND_IGNORES[friend.name]["guid"] = friend.guid
                    FRIENDS_AND_IGNORES[friend.name]["status"] = STATUS_FRIEND
                end 
            end
        end
        
        -- Friends have been removed, sync them as STATUS_REMOVED
        if numFriends < numSynchedFriends then
            for name, data in pairs(synchedFriends) do
                if not C_FriendList.IsFriend(data.guid) then
                    FRIENDS_AND_IGNORES[name]["status"] = STATUS_REMOVED
                end
            end
        end
    end
end)
