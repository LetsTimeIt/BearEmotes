function BearStatsScreen_OnLoad()
    
    BearEmoteSentStatKeys = {}
    local n = 0;
    local totalEmotesSent = 0;
    for k,v in pairs(BearEmoteStatistics) do
        if BearEmotes_defaultpack[k] ~= nil and v[2] > 0 then -- Only add if the emote still exsists
            n=n+1;
            totalEmotesSent = totalEmotesSent + v[2];
            BearEmoteSentStatKeys[n]=k;
        end
    end

    BearStatsScreenSentListTitle:SetText("Sent " .. totalEmotesSent .. " emotes")
    
    --Sort the sent stats list by usage
    table.sort(BearEmoteSentStatKeys, function(left, right)
        return BearEmoteStatistics[left][2] > BearEmoteStatistics[right][2]
    end);

    BearEmoteRecievedStatKeys = {}
    local n = 0;
    local totalEmotesSeen = 0;
    for k,v in pairs(BearEmoteStatistics) do
        if BearEmotes_defaultpack[k] ~= nil and v[3] > 0 then -- Only add if the emote still exsists
            n=n+1;
            totalEmotesSeen = totalEmotesSeen + v[3];
            BearEmoteRecievedStatKeys[n]=k;
        end
    end
    BearStatsScreenSeenListTitle:SetText("Seen " .. totalEmotesSeen .. " emotes")

    --Sort the seen stats list by nr of times seen
    table.sort(BearEmoteRecievedStatKeys, function(left, right)
        return BearEmoteStatistics[left][3] > BearEmoteStatistics[right][3]
    end);

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

    BearStatsScreen.closeButton = CreateFrame('Button', "BearStatsCloseButton", BearStatsScreen, 'UIPanelCloseButtonNoScripts')
	BearStatsScreen.closeButton:SetScript('OnClick', function() BearStatsScreen:Hide() end)
	BearStatsScreen.closeButton:SetPoint('TOPRIGHT', 0, 2)

    local engineeringGemTexture = "Interface\\ItemSocketingFrame\\UI-EngineeringSockets";
    local emoteBorderTex = {tex=engineeringGemTexture, w=43, h=43, left=0.01562500, right=0.68750000, top=0.41210938, bottom=0.49609375, r=1, g=1, b=1, CBx=49, CBy=47, CBLeft=0.01562500, CBRight=0.78125000, CBTop=0.22070313, CBBottom=0.31250000, OBx=49, OBy=47, OBLeft=0.01562500, OBRight=0.78125000, OBTop=0.31640625, OBBottom=0.40820313};
    local topEmoteBorder = BearStatsScreen:CreateTexture(nil, "BACKGROUND", nil, 1);
    topEmoteBorder:SetTexture(emoteBorderTex.tex);
    topEmoteBorder:SetWidth(emoteBorderTex.w * 2);
    topEmoteBorder:SetHeight(emoteBorderTex.h * 2);
    topEmoteBorder:SetTexCoord(emoteBorderTex.left, emoteBorderTex.right, emoteBorderTex.top, emoteBorderTex.bottom);
    topEmoteBorder:SetPoint('CENTER', BearStatsScreen, "TOPLEFT", 128, -108)
    topEmoteBorder:Show();

    local topSentImagePath = BearEmotes_defaultpack[BearEmoteSentStatKeys[1]] or "Interface\\AddOns\\BearEmotes\\Emotes\\1337.tga";
    local animdata = BearEmotes_animation_metadata[topSentImagePath]
    BearStatsScreen.topSentEmoteTexture = BearStatsScreen.topSentEmoteTexture or BearStatsScreen:CreateTexture(nil, "BACKGROUND", nil, 2);
    local topEmoteTexture = BearStatsScreen.topSentEmoteTexture

    if animdata ~= nil then
        topEmoteTexture:SetTexture(topSentImagePath);
        topEmoteTexture:SetTexCoord(BearEmotes_GetTexCoordsForFrame(animdata, 0)) 
    else
        local size = string.match(topSentImagePath, ":(.*)")
        if size then
            topSentImagePath = string.gsub(topSentImagePath, size, "")
        end

        topEmoteTexture:SetTexture(topSentImagePath);
    end
    
    topEmoteTexture:SetWidth(70);
    topEmoteTexture:SetHeight(70);
    topEmoteTexture:SetPoint('CENTER', BearStatsScreen, "TOPLEFT", 128, -108)
    topEmoteTexture:Show();

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

    topEmoteBorder = BearStatsScreen:CreateTexture(nil, "BACKGROUND", nil, 1);
    topEmoteBorder:SetTexture(emoteBorderTex.tex);
    topEmoteBorder:SetWidth(emoteBorderTex.w * 2);
    topEmoteBorder:SetHeight(emoteBorderTex.h * 2);
    topEmoteBorder:SetTexCoord(emoteBorderTex.left, emoteBorderTex.right, emoteBorderTex.top, emoteBorderTex.bottom);
    topEmoteBorder:SetPoint('CENTER', BearStatsScreen, "TOPLEFT", 384, -108)
    topEmoteBorder:Show();

    local topSeenImagePath = BearEmotes_defaultpack[BearEmoteRecievedStatKeys[1]] or "Interface\\AddOns\\BearEmotes\\Emotes\\1337.tga";
    local animdata = BearEmotes_animation_metadata[topSeenImagePath]

    BearStatsScreen.topSeenEmoteTexture = BearStatsScreen.topSeenEmoteTexture or BearStatsScreen:CreateTexture(nil, "BACKGROUND", nil, 2);
    topEmoteTexture = BearStatsScreen.topSeenEmoteTexture;

    if animdata ~= nil then
        topEmoteTexture:SetTexture(topSeenImagePath);
        topEmoteTexture:SetTexCoord(BearEmotes_GetTexCoordsForFrame(animdata, 0)) 
    else
        local size = string.match(topSeenImagePath, ":(.*)")
        if size then
            topSeenImagePath = string.gsub(topSeenImagePath, size, "")
        end

        topEmoteTexture:SetTexture(topSeenImagePath);
    end

    topEmoteTexture:SetWidth(70);
    topEmoteTexture:SetHeight(70);
    topEmoteTexture:SetPoint('CENTER', BearStatsScreen, "TOPLEFT", 384, -108)
    topEmoteTexture:Show();

    --Instantiate the scroll list entries
    for i=2, 17  do
        local bearStatSentScrollEntry = CreateFrame('Button', "BearStatsSentEntry"..i, BearStatsScreen, 'BearStatsEntryTemplate')
        bearStatSentScrollEntry:SetPoint("TOPLEFT", "BearStatsSentEntry"..(i-1), "BOTTOMLEFT", 0, 0);

        local bearStatRecievedScrollEntry = CreateFrame('Button', "BearStatsRecievedEntry"..i, BearStatsScreen, 'BearStatsEntryTemplate')
        bearStatRecievedScrollEntry:SetPoint("TOPLEFT", "BearStatsRecievedEntry"..(i-1), "BOTTOMLEFT", 0, 0);
        --print("constructed BearStatsSentEntry" .. i .. " (parent BearStatsSentEntry" ..(i-1) )
    end

    BearStatsScreen:Show()
    BearStatsSentScrollBar:Show()
    BearStatsRecievedScrollBar:Show()
end

function BearStatsSentScrollBar_Update()
    local nrOfItemsVisible = 17
    local lineplusoffset; -- an index into our data calculated from the scroll offset
    
    FauxScrollFrame_Update(BearStatsSentScrollBar,#BearEmoteSentStatKeys,nrOfItemsVisible,16);
    for line=1, nrOfItemsVisible do
      lineplusoffset = line + FauxScrollFrame_GetOffset(BearStatsSentScrollBar);
      if lineplusoffset <= #BearEmoteSentStatKeys then
        local cEmote = BearEmoteSentStatKeys[lineplusoffset];
        local fullEmotePath = BearEmotes_defaultpack[cEmote];
        local animdata = BearEmotes_animation_metadata[fullEmotePath]
        local texturestr = nil
        if animdata ~= nil then
            texturestr = BearEmotes_BuildEmoteFrameStringWithDimensions(fullEmotePath, animdata, 0, 16, 16)
        else
            local size = string.match(fullEmotePath, ":(.*)")
            texturestr = "|T"..string.gsub(fullEmotePath, size, "16:16").."|t"
        end

        getglobal("BearStatsSentEntry"..line):SetText("|cFFfce703" .. lineplusoffset ..".|r ".. texturestr .." " .. " |cFF00FF00"..cEmote.."|r sent: " .. BearEmoteStatistics[cEmote][2] .. "x");
        getglobal("BearStatsSentEntry"..line):Show();
        
      else
        getglobal("BearStatsSentEntry"..line):Hide();
      end
    end
end

function BearStatsRecievedScrollBar_Update()
    local nrOfItemsVisible = 17
    local lineplusoffset; -- an index into our data calculated from the scroll offset

    FauxScrollFrame_Update(BearStatsRecievedScrollBar,#BearEmoteRecievedStatKeys,nrOfItemsVisible,16);
    for line=1, nrOfItemsVisible do
      lineplusoffset = line + FauxScrollFrame_GetOffset(BearStatsRecievedScrollBar);
      if lineplusoffset <= #BearEmoteRecievedStatKeys then
        local cEmote = BearEmoteRecievedStatKeys[lineplusoffset];
        local fullEmotePath = BearEmotes_defaultpack[cEmote]

        local animdata = BearEmotes_animation_metadata[fullEmotePath]
        local texturestr = nil
        if animdata ~= nil then
            texturestr = BearEmotes_BuildEmoteFrameStringWithDimensions(fullEmotePath, animdata, 0, 16, 16)
        else
            local size = string.match(fullEmotePath, ":(.*)")
            texturestr = "|T"..string.gsub(fullEmotePath, size, "16:16").."|t"
        end
        
        getglobal("BearStatsRecievedEntry"..line):SetText("|cFFfce703" .. lineplusoffset ..".|r ".. texturestr .." " .. " |cFF00FF00"..cEmote.."|r seen: " .. BearEmoteStatistics[cEmote][3] .. "x");
        getglobal("BearStatsRecievedEntry"..line):Show();
        
      else
        getglobal("BearStatsRecievedEntry"..line):Hide();
      end
    end
end