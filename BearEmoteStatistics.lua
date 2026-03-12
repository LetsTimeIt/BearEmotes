local FILTERED_BEAR_SENT_KEYS = {}
local FILTERED_BEAR_RECEIVED_KEYS = {}

local function GetFallbackBearEmotePath()
    return "Interface\\AddOns\\BearEmotes\\Emotes\\beargun.tga:28:28"
end

local function BuildBearStatTextureString(fullEmotePath)
    local animdata = BearEmotes_animation_metadata[fullEmotePath]
    if animdata ~= nil then
        return BearEmotes_BuildEmoteFrameStringWithDimensions(fullEmotePath, animdata, 0, 16, 16)
    end

    local size = string.match(fullEmotePath, ":(.*)")
    if size == nil then
        return "|T" .. fullEmotePath .. ":16:16|t"
    end
    return "|T" .. string.gsub(fullEmotePath, size, "16:16") .. "|t"
end

local function ApplyBearStatsFilter(searchText)
    if searchText == nil or searchText == "" then
        FILTERED_BEAR_SENT_KEYS = BearEmoteSentStatKeys
        FILTERED_BEAR_RECEIVED_KEYS = BearEmoteRecievedStatKeys
        return
    end

    local pattern = "^.*" .. searchText:lower() .. ".*"

    FILTERED_BEAR_SENT_KEYS = {}
    for i = 1, #BearEmoteSentStatKeys do
        if string.find(BearEmoteSentStatKeys[i]:lower(), pattern) == 1 then
            FILTERED_BEAR_SENT_KEYS[#FILTERED_BEAR_SENT_KEYS + 1] = BearEmoteSentStatKeys[i];
        end
    end

    FILTERED_BEAR_RECEIVED_KEYS = {}
    for i = 1, #BearEmoteRecievedStatKeys do
        if string.find(BearEmoteRecievedStatKeys[i]:lower(), pattern) == 1 then
            FILTERED_BEAR_RECEIVED_KEYS[#FILTERED_BEAR_RECEIVED_KEYS + 1] = BearEmoteRecievedStatKeys[i];
        end
    end
end

function BearStatsScreen_OnLoad()
    BearEmoteSentStatKeys = {}
    local totalEmotesSent = 0;
    for k, v in pairs(BearEmoteStatistics) do
        if BearEmotes_defaultpack[k] ~= nil and v[2] > 0 then
            totalEmotesSent = totalEmotesSent + v[2];
            BearEmoteSentStatKeys[#BearEmoteSentStatKeys + 1] = k;
        end
    end

    BearStatsScreenSentListTitle:SetText("Sent " .. totalEmotesSent .. " emotes")
    table.sort(BearEmoteSentStatKeys, function(left, right)
        return BearEmoteStatistics[left][2] > BearEmoteStatistics[right][2]
    end);

    BearEmoteRecievedStatKeys = {}
    local totalEmotesSeen = 0;
    for k, v in pairs(BearEmoteStatistics) do
        if BearEmotes_defaultpack[k] ~= nil and v[3] > 0 then
            totalEmotesSeen = totalEmotesSeen + v[3];
            BearEmoteRecievedStatKeys[#BearEmoteRecievedStatKeys + 1] = k;
        end
    end

    BearStatsScreenSeenListTitle:SetText("Seen " .. totalEmotesSeen .. " emotes")
    table.sort(BearEmoteRecievedStatKeys, function(left, right)
        return BearEmoteStatistics[left][3] > BearEmoteStatistics[right][3]
    end);

    ApplyBearStatsFilter(BearStatsScreen.searchBox and BearStatsScreen.searchBox:GetText() or "")

    BearStatsScreen:SetBackdrop({
        bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background-Dark',
        edgeFile = 'Interface\\DialogFrame\\UI-DialogBox-Background-Dark',
        tile = true,
        tileSize = 32,
        edgeSize = 1,
        insets = {
            left = 0,
            right = 0,
            top = 0,
            bottom = 0
        }
    })

    if not BearStatsScreen.closeButton then
        BearStatsScreen.closeButton = CreateFrame('Button', "BearStatsCloseButton", BearStatsScreen, 'UIPanelCloseButtonNoScripts')
        BearStatsScreen.closeButton:SetScript('OnClick', function() BearStatsScreen:Hide() end)
        BearStatsScreen.closeButton:SetPoint('TOPRIGHT', 0, 2)
    end

    local engineeringGemTexture = "Interface\\ItemSocketingFrame\\UI-EngineeringSockets";
    local emoteBorderTex = {tex = engineeringGemTexture, w = 43, h = 43, left = 0.01562500, right = 0.68750000, top = 0.41210938, bottom = 0.49609375};

    if not BearStatsScreen.topSentEmoteBorder then
        BearStatsScreen.topSentEmoteBorder = BearStatsScreen:CreateTexture(nil, "BACKGROUND", nil, 1);
        BearStatsScreen.topSentEmoteBorder:SetTexture(emoteBorderTex.tex);
        BearStatsScreen.topSentEmoteBorder:SetWidth(emoteBorderTex.w * 2);
        BearStatsScreen.topSentEmoteBorder:SetHeight(emoteBorderTex.h * 2);
        BearStatsScreen.topSentEmoteBorder:SetTexCoord(emoteBorderTex.left, emoteBorderTex.right, emoteBorderTex.top, emoteBorderTex.bottom);
        BearStatsScreen.topSentEmoteBorder:SetPoint('CENTER', BearStatsScreen, "TOPLEFT", 128, -108)
        BearStatsScreen.topSentEmoteBorder:Show();
    end

    if not BearStatsScreen.topSeenEmoteBorder then
        BearStatsScreen.topSeenEmoteBorder = BearStatsScreen:CreateTexture(nil, "BACKGROUND", nil, 1);
        BearStatsScreen.topSeenEmoteBorder:SetTexture(emoteBorderTex.tex);
        BearStatsScreen.topSeenEmoteBorder:SetWidth(emoteBorderTex.w * 2);
        BearStatsScreen.topSeenEmoteBorder:SetHeight(emoteBorderTex.h * 2);
        BearStatsScreen.topSeenEmoteBorder:SetTexCoord(emoteBorderTex.left, emoteBorderTex.right, emoteBorderTex.top, emoteBorderTex.bottom);
        BearStatsScreen.topSeenEmoteBorder:SetPoint('CENTER', BearStatsScreen, "TOPLEFT", 384, -108)
        BearStatsScreen.topSeenEmoteBorder:Show();
    end

    local topSentImagePath = BearEmotes_defaultpack[BearEmoteSentStatKeys[1]] or GetFallbackBearEmotePath();
    local animdata = BearEmotes_animation_metadata[topSentImagePath]
    BearStatsScreen.topSentEmoteTexture = BearStatsScreen.topSentEmoteTexture or BearStatsScreen:CreateTexture(nil, "BACKGROUND", nil, 2);
    if animdata ~= nil then
        BearStatsScreen.topSentEmoteTexture:SetTexture(topSentImagePath);
        BearStatsScreen.topSentEmoteTexture:SetTexCoord(BearEmotes_GetTexCoordsForFrame(animdata, 0))
    else
        local size = string.match(topSentImagePath, ":(.*)")
        if size then
            topSentImagePath = string.gsub(topSentImagePath, size, "")
        end
        BearStatsScreen.topSentEmoteTexture:SetTexture(topSentImagePath);
    end
    BearStatsScreen.topSentEmoteTexture:SetWidth(70);
    BearStatsScreen.topSentEmoteTexture:SetHeight(70);
    BearStatsScreen.topSentEmoteTexture:SetPoint('CENTER', BearStatsScreen, "TOPLEFT", 128, -108)
    BearStatsScreen.topSentEmoteTexture:Show();

    local topSeenImagePath = BearEmotes_defaultpack[BearEmoteRecievedStatKeys[1]] or GetFallbackBearEmotePath();
    animdata = BearEmotes_animation_metadata[topSeenImagePath]
    BearStatsScreen.topSeenEmoteTexture = BearStatsScreen.topSeenEmoteTexture or BearStatsScreen:CreateTexture(nil, "BACKGROUND", nil, 2);
    if animdata ~= nil then
        BearStatsScreen.topSeenEmoteTexture:SetTexture(topSeenImagePath);
        BearStatsScreen.topSeenEmoteTexture:SetTexCoord(BearEmotes_GetTexCoordsForFrame(animdata, 0))
    else
        local size = string.match(topSeenImagePath, ":(.*)")
        if size then
            topSeenImagePath = string.gsub(topSeenImagePath, size, "")
        end
        BearStatsScreen.topSeenEmoteTexture:SetTexture(topSeenImagePath);
    end
    BearStatsScreen.topSeenEmoteTexture:SetWidth(70);
    BearStatsScreen.topSeenEmoteTexture:SetHeight(70);
    BearStatsScreen.topSeenEmoteTexture:SetPoint('CENTER', BearStatsScreen, "TOPLEFT", 384, -108)
    BearStatsScreen.topSeenEmoteTexture:Show();

    if #BearEmoteSentStatKeys >= 1 and BearEmoteStatistics[BearEmoteSentStatKeys[1]][2] > 0 then
        BearStatsScreenTopSentText:SetText(BearEmoteSentStatKeys[1] .. " sent " .. BearEmoteStatistics[BearEmoteSentStatKeys[1]][2] .. "x")
    else
        BearStatsScreenTopSentText:SetText("No emotes sent yet");
    end

    if #BearEmoteRecievedStatKeys >= 1 and BearEmoteStatistics[BearEmoteRecievedStatKeys[1]][3] > 0 then
        BearStatsScreenTopRecievedText:SetText(BearEmoteRecievedStatKeys[1] .. " seen " .. BearEmoteStatistics[BearEmoteRecievedStatKeys[1]][3] .. "x")
    else
        BearStatsScreenTopRecievedText:SetText("No emotes seen yet");
    end

    if not BearStatsScreen.searchBox then
        BearStatsScreen.searchBox = CreateFrame("EditBox", "BearStatsSearchBox", BearStatsScreen, "InputBoxTemplate")
        BearStatsScreen.searchBox:SetFrameStrata("DIALOG")
        BearStatsScreen.searchBox:SetSize(150, 16)
        BearStatsScreen.searchBox:SetAutoFocus(false)
        BearStatsScreen.searchBox:SetText("")
        BearStatsScreen.searchBox:SetPoint("TOPLEFT", 55, -185)
        BearStatsScreen.searchBox:HookScript("OnTextChanged", function(editbox)
            ApplyBearStatsFilter(editbox:GetText());
            BearStatsSentScrollBar_Update();
            BearStatsRecievedScrollBar_Update();
        end)
    end

    if not BearStatsScreen.entriesInitialized then
        for i = 2, 17 do
            local bearStatSentScrollEntry = CreateFrame('Button', "BearStatsSentEntry" .. i, BearStatsScreen, 'BearStatsEntryTemplate')
            bearStatSentScrollEntry:SetPoint("TOPLEFT", "BearStatsSentEntry" .. (i - 1), "BOTTOMLEFT", 0, 0);

            local bearStatRecievedScrollEntry = CreateFrame('Button', "BearStatsRecievedEntry" .. i, BearStatsScreen, 'BearStatsEntryTemplate')
            bearStatRecievedScrollEntry:SetPoint("TOPLEFT", "BearStatsRecievedEntry" .. (i - 1), "BOTTOMLEFT", 0, 0);
        end
        BearStatsScreen.entriesInitialized = true
    end

    BearStatsScreen:Show()
    BearStatsSentScrollBar:Show()
    BearStatsRecievedScrollBar:Show()
    BearStatsSentScrollBar_Update()
    BearStatsRecievedScrollBar_Update()
end

function BearStatsSentScrollBar_Update()
    local nrOfItemsVisible = 17
    local filteredStatKeys = FILTERED_BEAR_SENT_KEYS or BearEmoteSentStatKeys

    FauxScrollFrame_Update(BearStatsSentScrollBar, #filteredStatKeys, nrOfItemsVisible, 16);
    for line = 1, nrOfItemsVisible do
        local lineplusoffset = line + FauxScrollFrame_GetOffset(BearStatsSentScrollBar);
        if lineplusoffset <= #filteredStatKeys then
            local cEmote = filteredStatKeys[lineplusoffset];
            local fullEmotePath = BearEmotes_defaultpack[cEmote];
            local texturestr = BuildBearStatTextureString(fullEmotePath)

            getglobal("BearStatsSentEntry" .. line):SetText("|cFFfce703" .. lineplusoffset .. ".|r " .. texturestr .. " |cFF00FF00" .. cEmote .. "|r sent: " .. BearEmoteStatistics[cEmote][2] .. "x");
            getglobal("BearStatsSentEntry" .. line):Show();
        else
            getglobal("BearStatsSentEntry" .. line):Hide();
        end
    end
end

function BearStatsRecievedScrollBar_Update()
    local nrOfItemsVisible = 17
    local filteredStatKeys = FILTERED_BEAR_RECEIVED_KEYS or BearEmoteRecievedStatKeys

    FauxScrollFrame_Update(BearStatsRecievedScrollBar, #filteredStatKeys, nrOfItemsVisible, 16);
    for line = 1, nrOfItemsVisible do
        local lineplusoffset = line + FauxScrollFrame_GetOffset(BearStatsRecievedScrollBar);
        if lineplusoffset <= #filteredStatKeys then
            local cEmote = filteredStatKeys[lineplusoffset];
            local fullEmotePath = BearEmotes_defaultpack[cEmote]
            local texturestr = BuildBearStatTextureString(fullEmotePath)

            getglobal("BearStatsRecievedEntry" .. line):SetText("|cFFfce703" .. lineplusoffset .. ".|r " .. texturestr .. " |cFF00FF00" .. cEmote .. "|r seen: " .. BearEmoteStatistics[cEmote][3] .. "x");
            getglobal("BearStatsRecievedEntry" .. line):Show();
        else
            getglobal("BearStatsRecievedEntry" .. line):Hide();
        end
    end
end
