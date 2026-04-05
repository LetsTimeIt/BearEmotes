local LDB = LibStub("LibDataBroker-1.1")
local LDBIcon = LibStub("LibDBIcon-1.0")
local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")
local isMidnight = (select(4, GetBuildInfo()) >= 120000)
local InChatMessagingLockdown = (C_ChatInfo and C_ChatInfo.InChatMessagingLockdown) or function()
    return false
end
local issecretvalue = issecretvalue or function()
    return false
end
local addonName, addonTable = ...

BearEmoticons_Settings = {
    ["CHAT_MSG_COMMUNITIES_CHANNEL"] = true, -- 1
    ["CHAT_MSG_GUILD"] = true, -- 2
    ["CHAT_MSG_PARTY"] = true, -- 3
    ["CHAT_MSG_PARTY_LEADER"] = true, -- dont count, tie to 3
    ["CHAT_MSG_PARTY_GUIDE"] = true, -- dont count, tie to 3
    ["CHAT_MSG_RAID"] = true, -- 4
    ["CHAT_MSG_RAID_LEADER"] = true, -- dont count, tie to 4
    ["CHAT_MSG_RAID_WARNING"] = true, -- dont count, tie to 4
    ["CHAT_MSG_SAY"] = true, -- 5
    ["CHAT_MSG_YELL"] = true, -- 6
    ["CHAT_MSG_WHISPER"] = true, -- 7
    ["CHAT_MSG_WHISPER_INFORM"] = true, -- dont count, tie to 7
    ["CHAT_MSG_CHANNEL"] = true, -- 8
    ["CHAT_MSG_BN_WHISPER"] = true, -- 9
    ["CHAT_MSG_BN_WHISPER_INFORM"] = true, -- dont count, tie to 9
    ["CHAT_MSG_BN_CONVERSATION"] = true, -- 10
    ["CHAT_MSG_INSTANCE_CHAT"] = true, -- 11
    ["CHAT_MSG_INSTANCE_CHAT_LEADER"] = true, -- dont count, tie to 11
    ["MAIL"] = true,
    ["MINIMAPBUTTON"] = true,
	["MINIMAPDATA"] = {minimapPos=135},
    ["LARGEEMOTES"] = false,
	["ENABLE_CLICKABLEEMOTES"] = true,
    ["ENABLE_AUTOCOMPLETE"] = true,
    ["ENABLE_ANIMATEDEMOTES"] = true,
    ["AUTOCOMPLETE_CONFIRM_WITH_TAB"] = false,
    ["FAVEMOTES"] = {
        true, true, true, true, true, true, true, true, true, true, true, true,
        true, true, true, true, true, true, true, true, true, true, true, true,
        true, true, true
    }
};

local origsettings = {
    ["CHAT_MSG_COMMUNITIES_CHANNEL"] = true,
    ["CHAT_MSG_GUILD"] = true,
    ["CHAT_MSG_PARTY"] = true,
    ["CHAT_MSG_PARTY_LEADER"] = true,
    ["CHAT_MSG_PARTY_GUIDE"] = true,
    ["CHAT_MSG_RAID"] = true,
    ["CHAT_MSG_RAID_LEADER"] = true,
    ["CHAT_MSG_RAID_WARNING"] = true,
    ["CHAT_MSG_SAY"] = true,
    ["CHAT_MSG_YELL"] = true,
    ["CHAT_MSG_WHISPER"] = true,
    ["CHAT_MSG_WHISPER_INFORM"] = true,
    ["CHAT_MSG_BN_WHISPER"] = true,
    ["CHAT_MSG_BN_WHISPER_INFORM"] = true,
    ["CHAT_MSG_BN_CONVERSATION"] = true,
    ["CHAT_MSG_CHANNEL"] = true,
    ["CHAT_MSG_INSTANCE_CHAT"] = true,
    ["MAIL"] = true,
    ["MINIMAPBUTTON"] = true,
	["MINIMAPDATA"] = {minimapPos=135},
    ["LARGEEMOTES"] = false,
	["ENABLE_CLICKABLEEMOTES"] = true,
    ["ENABLE_AUTOCOMPLETE"] = true,
    ["ENABLE_ANIMATEDEMOTES"] = true,
    ["AUTOCOMPLETE_CONFIRM_WITH_TAB"] = false,
    ["FAVEMOTES"] = {
        true, true, true, true, true, true, true, true, true, true, true, true,
        true, true, true, true, true, true, true, true, true, true, true, true,
        true, true, true
    }
};

local accept_stat_updates = false
local iconregistered = false
local autocompleteInited = false
local Broker_BearEmotes
local BearEmotes_N_CHATFRAMES = 0
local _G = getfenv(0)

local function BearEmotes_MinimapButton_OnClick(btn)
    if IsShiftKeyDown() then
        BearStatsScreen_OnLoad();
    else
        LibDD:ToggleDropDownMenu(1, nil, BearEmoticonMiniMapDropDown,"cursor", 0, 0);
    end
end

local lastmsgID = -1;
local function BearEmoticons_InsertEmoticons(msg, senderGUID, msgID)
    local normal = '28:28'
    local large = '64:64'
    local xlarge = '128:128'
    local xxlarge = '256:256'
    local delimiters = "%s,'<>?-%.!"

    for word in string.gmatch(msg, "[^" .. delimiters .. "]+") do
        local emote = BearEmotes_emoticons[word]

        if BearEmotes_defaultpack[emote] ~= nil then
            --print("Inserting ", emote, msgID,  UnitGUID("player"));
            if accept_stat_updates then
                if msgID ~= lastmsgID then -- Only handle 
                    local localPlayerGUID = UnitGUID("player");
                    if localPlayerGUID == senderGUID then --We sent this message
                        BearUpdateEmoteStats(emote, false, true, false);
                    else -- someone else sent this message
                        BearUpdateEmoteStats(emote, false, false, true);
                    end
                end
            end
            
            -- print("Detected " .. emote)
            -- Get the size of the emote, if not a standard size
            local path_and_size = BearEmotes_defaultpack[emote]
            local path = string.match(path_and_size, "(.*%.tga)")
            local size = string.match(path_and_size, ":(.*)")
            -- Make a copy of the file path so we don't modify the original value
            local animdata = BearEmotes_GetAnimData(path);
            
            if(animdata == nil) then
                -- Check if the user has large emotes enabled. 
                -- If not, replace the size with the standard size of 28:28,
                -- else set it to the standard large size of 64:64
                if not BearEmoticons_Settings["LARGEEMOTES"] then
                    if ( size == 'LARGE' or size == 'XLARGE' or size == 'XXLARGE' ) then
                        path_and_size = string.gsub(BearEmotes_defaultpack[emote], size, normal)
                    end
                else
                    if ( size == 'LARGE' ) then
                        path_and_size = string.gsub(BearEmotes_defaultpack[emote], size, large)
                    elseif ( size == 'XLARGE' ) then
                        path_and_size = string.gsub(BearEmotes_defaultpack[emote], size, xlarge)
                    elseif ( size == 'XXLARGE') then
                        path_and_size = string.gsub(BearEmotes_defaultpack[emote], size, xxlarge)
                    end
                end
            else 
                path_and_size = BearEmotes_BuildEmoteFrameString(path, animdata, 0):gsub("|T", ""):gsub("|t", "");
            end
            

            local wrapPattern = "([" .. delimiters .. "]+)"

            if BearEmoticons_Settings["ENABLE_CLICKABLEEMOTES"] then
				msg = string.gsub(msg, wrapPattern .. word .. wrapPattern, 
				"%1|Htel:".. word .. "|h|T" .. path_and_size .. "|t|h%2", 1);
				msg = string.gsub(msg, wrapPattern .. word .. "$", 
				"%1|Htel:".. word .. "|h|T" .. path_and_size .. "|t|h", 1);
				msg = string.gsub(msg, "^" .. word .. wrapPattern, 
				"|Htel:".. word .. "|h|T" .. path_and_size .. "|t|h%1", 1);
				msg = string.gsub(msg, "^" .. word .. "$", 
				"|Htel:".. word .. "|h|T" .. path_and_size .. "|t|h", 1);
				msg = string.gsub(msg, wrapPattern .. word .. "(%c)", 
				"%1|Htel:".. word .. "|h|T" .. path_and_size .. "|t|h%2", 1);
				msg = string.gsub(msg, wrapPattern .. word .. wrapPattern, 
				"%1|Htel:".. word .. "|h|T" .. path_and_size .. "|t|h%2", 1);
			else
				msg = string.gsub(msg, wrapPattern .. word .. wrapPattern, "%1|T" .. path_and_size .. "|t%2", 1);
				msg = string.gsub(msg, wrapPattern .. word .. "$", "%1|T" .. path_and_size .. "|t", 1);
				msg = string.gsub(msg, "^" .. word .. wrapPattern, "|T" .. path_and_size .. "|t%1", 1);
				msg = string.gsub(msg, "^" .. word .. "$", "|T" .. path_and_size .. "|t");
				msg = string.gsub(msg, wrapPattern .. word .. "(%c)", "%1|T" .. path_and_size .. "|t%2", 1);
				msg = string.gsub(msg, wrapPattern .. word .. wrapPattern, "%1|T" .. path_and_size .. "|t%2", 1);
			end
        end
    end

    lastmsgID = msgID; -- we only save stats of unique messages (this function is called multiple times per message, for each chat frame)
    return msg;
end

local function BearEmoticons_RunReplacement(msg, senderGUID, msgID)
    -- remember to watch out for |H|h|h's

    local outstr = "";
    local origlen = #msg;
    local startpos = 1;
    local endpos;

    -- We need to ignore links, as to not break them.
    local linkStart, linkEnd = string.find(msg, "%[.+%]", startpos) 
    while(linkStart) do
        local link = string.sub(msg, linkStart, linkEnd)

        if startpos < linkStart then
            outstr = outstr .. BearEmoticons_InsertEmoticons(string.sub(msg, startpos, linkStart - 1), senderGUID, msgID); -- the bit before the current link
    end
        outstr = outstr .. link -- don't run replacement on the link, just add it to the return string
        startpos = linkEnd + 1
    
        linkStart, linkEnd = string.find(msg, "%[.+-.+%]+", startpos) -- find next link
    end

    outstr = outstr .. BearEmoticons_InsertEmoticons(string.sub(msg, startpos, #msg), senderGUID, msgID); -- the bit after the last link (or the whole message when no links found)

    return outstr;
end

local ItemTextFrameSetText = ItemTextPageText.SetText;
function ItemTextPageText.SetText(self, msg, ...)
    if (BearEmoticons_Settings["MAIL"] and msg ~= nil) then
        local msgID = select(10, ...);
        local senderGUID = select(11, ...)
        msg = BearEmoticons_RunReplacement(msg, senderGUID, msgID, false);
    end
    ItemTextFrameSetText(self, msg, ...);
end

local OpenMailBodyTextSetText = OpenMailBodyText.SetText;
function OpenMailBodyText.SetText(self, msg, ...)
    if (BearEmoticons_Settings["MAIL"] and msg ~= nil) then
        local msgID = select(10, ...);
        local senderGUID = select(11, ...)
        msg = BearEmoticons_RunReplacement(msg, senderGUID, msgID, false);
    end
    OpenMailBodyTextSetText(self, msg, ...);
end

function BearEmoticons_LoadMiniMapDropdown(self, level, menuList)
    local info = LibDD:UIDropDownMenu_CreateInfo();
    -- local info = UIDropDownMenu_CreateInfo();
    info.isNotRadio = true;
    info.notCheckable = true;
    info.notClickable = false;
    if (level or 1) == 1 then
        for k, v in ipairs(BearEmotes_dropdown_options) do
            if (BearEmoticons_Settings["FAVEMOTES"][k]) then
                info.hasArrow = true;
                info.text = v[1];
                info.value = false;
                info.menuList = k;
                LibDD:UIDropDownMenu_AddButton(info);
                -- UIDropDownMenu_AddButton(info);
            end
        end
    else
        local first = true;
        for ke, va in ipairs(BearEmotes_dropdown_options[menuList]) do
            if (first) then
                first = false;
            else
                -- if(BearEmotes_defaultpack[va] == nil) then
                --     print(ke.." " .. va .. " is broken");
                -- end
                
                info.text = "|T" .. BearEmotes_defaultpack[va] .. "|t " .. va;
                info.value = va;
                info.func = BearEmoticons_Dropdown_OnClick;
                LibDD:UIDropDownMenu_AddButton(info, level);
                -- UIDropDownMenu_AddButton(info, level);
            end
        end
    end
end

function BearEmoticons_Dropdown_OnClick(self, arg1, arg2, arg3)
    if (ACTIVE_CHAT_EDIT_BOX ~= nil) and not InChatMessagingLockdown() then
        ACTIVE_CHAT_EDIT_BOX:Insert(self.value);
    end
end

local sm = SendMail;
function SendMail(recipient, subject, msg, ...)
    if msg ~= nil then
        if BearEmoticons_Settings["ENABLE_CLICKABLEEMOTES"] then
            msg = BearEmotes_Message_StripEscapes(msg) 
        end
        sm(recipient, subject, msg, ...);
    end
end

if isMidnight then
    EventRegistry:RegisterCallback(
        "ChatFrame.OnEditBoxPreSendText",
        function(self, editBox)
            if not BearEmoticons_Settings["ENABLE_CLICKABLEEMOTES"] then
                return
            end

            local msg = editBox:GetText()
            if not msg or issecretvalue(msg) or msg:match("^%s*$") then
                return
            end

            local newMsg = BearEmotes_Message_StripEscapes(msg)
            if newMsg ~= msg then
                if InChatMessagingLockdown() then
                    print("Can't send emotes during combat - Midnight messaging restrictions in effect.")
                    return
                end
                editBox:SetText(newMsg)
            end
        end,
        addonTable
    )
else
    local scm = C_ChatInfo.SendChatMessage;
    function C_ChatInfo.SendChatMessage(msg, ...)
        if msg ~= nil then
            if BearEmoticons_Settings["ENABLE_CLICKABLEEMOTES"] then
                msg = BearEmotes_Message_StripEscapes(msg)
            end
            scm(msg, ...);
        end
    end
end

local bnsw = BNSendWhisper;
function BNSendWhisper(id, msg, ...)
    if msg ~= nil then
        if BearEmoticons_Settings["ENABLE_CLICKABLEEMOTES"] then
            msg = BearEmotes_Message_StripEscapes(msg) 
        end
        bnsw(id, msg, ...);
    end
end

local function escpattern(x)
    return (x:gsub('%%', '%%%%')
             :gsub('^%^', '%%^')
             :gsub('%$$', '%%$')
             :gsub('%(', '%%(')
             :gsub('%)', '%%)')
             :gsub('%.', '%%.')
             :gsub('%[', '%%[')
             :gsub('%]', '%%]')
             :gsub('%*', '%%*')
             :gsub('%+', '%%+')
             :gsub('%-', '%%-')
             :gsub('%?', '%%?'))
 end

-- Strip the bear emote link and texture escapes from the message before sending.
-- (to allow for sending shift-clicked emotes, we are not allowed to send messages with a '|T' sequence in it)
function BearEmotes_Message_StripEscapes(msg)

	--find a bear emote link in the message
	for str in string.gmatch(msg, "(|Htel:.-|h.-|h)") do
		--find the emote string in the bear emote link
		for emotestr in string.gmatch(str, "|Htel:(.-)|h.-|h") do
			msg = msg:gsub(escpattern(str), " " .. emotestr .. " "); -- Replace the link and texture with the plain emote key (and a space)
			break;
		end
	end
		
	return msg
end

function BearEmoticons_UpdateChatFilters()
    -- todo: this should only check the keys that start with CHAT_MSG_
    for k, v in pairs(BearEmoticons_Settings) do
        if k ~= "MAIL" then
            if (v) then
                ChatFrame_AddMessageEventFilter(k, BearEmoticons_MessageFilter)
            else
                ChatFrame_RemoveMessageEventFilter(k, BearEmoticons_MessageFilter);
            end
        end
    end
end

-- TODO: Find a way to ignore the elvui chat history..
function BearEmoticons_MessageFilter(self, event, message, ...)
    local msgID = select(10, ...);
    local senderGUID = select(11, ...)
    
    message = BearEmoticons_RunReplacement(message, senderGUID, msgID);

    return false, message, ...
end

function BearEmoticons_OnEvent(self, event, ...)
    if (event == "ADDON_LOADED" and select(1, ...) == "BearEmotes") then
        for k, v in pairs(origsettings) do
            if (BearEmoticons_Settings[k] == nil) then
                BearEmoticons_Settings[k] = v;
            end
        end

        BearEmotesUpdateFrame = CreateFrame("Frame", "BearEmotes_EventFrame", UIParent)
        BearEmotesUpdateFrame:SetScript('OnUpdate', BearEmotes_Update)
        BearEmoticons_EnableAnimatedEmotes(BearEmoticons_Settings["ENABLE_ANIMATEDEMOTES"])

        -- layout is BearEmoteStatistics[emote] = {nrTimesAutoCompleted, nrTimesSent, nrTimesSeen}
        BearEmoteStatistics = BearEmoteStatistics or {}; -- saved in savedvariables. (might slow ui loading if the dict gets big?)
        
        BearEmoticons_UpdateChatFilters();
        BearEmoticons_SetLargeEmotes(BearEmoticons_Settings["LARGEEMOTES"]);
        BearEmoticons_SetClickableEmotes(BearEmoticons_Settings["ENABLE_CLICKABLEEMOTES"]);
        BearEmoticons_InitChannelSettings();
		
		-- TODO: Waiting 1 second is kinda arbitrary, find a nicer solution.
		-- We don't accept Emote stat updates before ElvUI has posted it's chat history
		-- else they will be counted twice
		C_Timer.After(1, function()
			accept_stat_updates = true;
		end)
        
        Broker_BearEmotes = LDB:NewDataObject("BearEmotes", {
            type = "launcher",
            text = "BearEmotes",
            icon = "Interface\\AddOns\\BearEmotes\\Emotes\\beargun.tga",
            OnClick = BearEmotes_MinimapButton_OnClick
        })
        
        if(BearEmoticons_Settings["MINIMAPBUTTON"]) then
            LDBIcon:Register("BearEmotes", Broker_BearEmotes, BearEmoticons_Settings["MINIMAPDATA"])
            iconregistered = true
        end

        BearEmoticons_SetMinimapButton(BearEmoticons_Settings["MINIMAPBUTTON"])

        AllBearEmoteNames = {};
        BearEmoticons_SetAutoComplete(BearEmoticons_Settings["ENABLE_AUTOCOMPLETE"])
    elseif (event == "ADDON_LOADED" and select(1, ...) == "WIM" and BearEmoticons_Settings["ENABLE_AUTOCOMPLETE"]) then
        local module = WIM.CreateModule("BearEmotes", true);
        function module:OnWindowCreated(win)
            local editbox = win.widgets.msg_box
            editbox:SetScript("OnKeyDown", editbox:GetScript("OnKeyDown") or function() end)

            local suggestionList = AllBearEmoteNames;
            local maxButtonCount = 20;
            local autocompletesettings = {
                perWord = true,
                activationChar = ':',
                closingChar = ':',
                minChars = 2,
                fuzzyMatch = true,
                onSuggestionApplied = function(suggestion)
                    BearUpdateEmoteStats(suggestion, true, false, false);
                end,
                renderSuggestionFN = BearEmoticons_RenderSuggestionFN,
                suggestionBiasFN = function(suggestion, text)
                    if BearEmoteStatistics[suggestion] ~= nil then
                        return BearEmoteStatistics[suggestion][1] * 5
                    end
                    return 0;
                end,
                interceptOnEnterPressed = true,
                addSpace = true,
                useTabToConfirm = BearEmoticons_Settings["AUTOCOMPLETE_CONFIRM_WITH_TAB"],
                useArrowButtons = true,
            }

            SetupAutoComplete(editbox, suggestionList, maxButtonCount, autocompletesettings);
        end
    end
end

function BearEmoticons_InitChannelSettings()
    local channels = {
        "CHAT_MSG_GUILD",
        "CHAT_MSG_PARTY",
        "CHAT_MSG_PARTY_LEADER",
        "CHAT_MSG_PARTY_GUIDE",
        "CHAT_MSG_RAID",
        "CHAT_MSG_RAID_LEADER",
        "CHAT_MSG_RAID_WARNING",
        "CHAT_MSG_SAY",
        "CHAT_MSG_YELL",
        "CHAT_MSG_WHISPER",
        "CHAT_MSG_WHISPER_INFORM",
        "CHAT_MSG_CHANNEL",
        "CHAT_MSG_BN_WHISPER",
        "CHAT_MSG_BN_WHISPER_INFORM",
        "CHAT_MSG_BN_CONVERSATION",
        "CHAT_MSG_INSTANCE_CHAT",
        "CHAT_MSG_INSTANCE_CHAT_LEADER",
        "MAIL"
    }

    for i = 1, #channels do
        local channel = channels[i];
        local frame = getglobal("BearEmoticonsOptionsControlsPanel" .. channel);
        if frame ~= nil then
            frame:SetChecked(BearEmoticons_Settings[channel]);
        end
    end
end

--this function transforms the text in the autocomplete suggestions (we add the emote image here)
function BearEmoticons_RenderSuggestionFN(text)
    local fullEmotePath = BearEmotes_defaultpack[text]
    if(fullEmotePath ~= nil) then
        local animdata = BearEmotes_animation_metadata[fullEmotePath]
        if animdata ~= nil then
            return BearEmotes_BuildEmoteFrameStringWithDimensions(fullEmotePath, animdata, 0, 16, 16) .. text;
        else
            local size = string.match(fullEmotePath, ":(.*)")
            local path_and_size = "";
            if(size ~= nil) then
                path_and_size = string.gsub(fullEmotePath, size, "16:16")
            else
                path_and_size = fullEmotePath .. "16:16";
            end
            return "|T".. path_and_size .."|t " .. text;
        end
    end
end

local function setAllBearFav(value)
    for n, category in ipairs(BearEmotes_dropdown_options) do
        BearEmoticons_Settings["FAVEMOTES"][n] = value;

        local checkbox = getglobal("favCheckButton_" .. category[1] .. "Bear");
        if checkbox ~= nil then
            checkbox:SetChecked(value);
        end
    end
end

function BearEmoticons_OptionsWindow_OnShow(self)

    if BearEmoticons_Settings["MINIMAPBUTTON"] then
        getglobal("$showMinimapButtonButton"):SetChecked(true);
    end

    if BearEmoticons_Settings["LARGEEMOTES"] then
        getglobal("$showLargeEmotesButton"):SetChecked(true);
	end

    if BearEmoticons_Settings["ENABLE_CLICKABLEEMOTES"] then
        getglobal("$showClickableEmotesButton"):SetChecked(true);
    end

    if BearEmoticons_Settings["ENABLE_AUTOCOMPLETE"] then
        getglobal("$autocompleteCheckButton"):SetChecked(true);
    end

    if BearEmoticons_Settings["AUTOCOMPLETE_CONFIRM_WITH_TAB"] then
        getglobal("$autocompleteUseTabToComplete"):SetChecked(true);
    end
    

    -- getglobal("$autocompleteCheckButton").tooltipText = "Start with a ':' to show a list of emotes.";

    getglobal("$autocompleteUseTabToComplete").tooltipText = "This will disable cycling the selected suggestion with tab, the arrow keys will still work.";

    if favframe_GlobalNameBear ~= nil then
        for index, category in ipairs(BearEmotes_dropdown_options) do
            local checkbox = getglobal("favCheckButton_" .. category[1] .. "Bear");
            if checkbox ~= nil then
                checkbox:SetChecked(BearEmoticons_Settings["FAVEMOTES"][index]);
            end
        end
        return
    end

    local favall = CreateFrame("CheckButton", "favall_GlobalNameBear", BearEmoticonsOptionsControlsPanel, "UIPanelButtonTemplate");
    favall:SetWidth(85);
    favall:SetScript("OnClick", function()
        setAllBearFav(true);
    end)
    favall:SetPoint("TOPLEFT", 17, -350);
    favall:SetText("Check all");
    favall.tooltip = "Check all boxes below.";

    local favnone = CreateFrame("CheckButton", "favnone_GlobalNameBear", BearEmoticonsOptionsControlsPanel, "UIPanelButtonTemplate");
    favnone:SetWidth(85);
    favnone:SetScript("OnClick", function()
        setAllBearFav(false);
    end)
    favnone:SetPoint("TOPLEFT", 130, -350);
    favnone:SetText("Check none");
    favnone.tooltip = "Uncheck all boxes below.";

    local favframe = CreateFrame("Frame", "favframe_GlobalNameBear", favall_GlobalNameBear);
    favframe:SetPoint("TOPLEFT", 0, -24);
    favframe:SetSize(590, 175);

    local first = true;
    local itemcnt = 0;
    local anchor;
    for index, category in ipairs(BearEmotes_dropdown_options) do
        local favCheckButton = CreateFrame(
            "CheckButton",
            "favCheckButton_" .. category[1] .. "Bear",
            favframe_GlobalNameBear,
            "ChatConfigCheckButtonTemplate"
        );

        if first then
            first = false;
            favCheckButton:SetPoint("TOPLEFT", 0, 0);
        else
            favCheckButton:SetParent(getglobal("favCheckButton_" .. anchor .. "Bear"));
            if ((itemcnt % 10) ~= 0) then
                favCheckButton:SetPoint("TOPLEFT", 0, -16);
            else
                favCheckButton:SetPoint("TOPLEFT", 110, 9 * 16);
            end
        end

        itemcnt = itemcnt + 1;
        anchor = category[1];

        getglobal(favCheckButton:GetName() .. "Text"):SetText(category[1]);
        favCheckButton:SetChecked(BearEmoticons_Settings["FAVEMOTES"][index]);
        favCheckButton.tooltip = "Checked boxes will show in the dropdown list.";
        favCheckButton:SetScript("OnClick", function(button)
            BearEmoticons_Settings["FAVEMOTES"][index] = button:GetChecked() and true or false;
        end);
    end
end

function BearEmoticons_SetMinimapButton(state)
    BearEmoticons_Settings["MINIMAPBUTTON"] = state;
    
    if (state) then
        if not iconregistered then
            LDBIcon:Register("BearEmotes", Broker_BearEmotes, BearEmoticons_Settings["MINIMAPDATA"])
            iconregistered = true
        end
        LDBIcon:Show("BearEmotes");
    else
        LDBIcon:Hide("BearEmotes");
    end
end


function BearEmoticons_SetConfirmWithTab(state)
    BearEmoticons_Settings["AUTOCOMPLETE_CONFIRM_WITH_TAB"] = state;
    for _, frameName in pairs(CHAT_FRAMES) do
        local frame = _G[frameName]

        local editbox = frame.editBox;
        if editbox ~= nil and editbox.settings ~= nil then
            editbox.settings.useTabToConfirm = BearEmoticons_Settings["AUTOCOMPLETE_CONFIRM_WITH_TAB"];
        end
    end
end

function BearEmoticons_SetLargeEmotes(state)
    BearEmoticons_Settings["LARGEEMOTES"] = state;
end

function BearEmoticons_SetClickableEmotes(state)
    BearEmoticons_Settings["ENABLE_CLICKABLEEMOTES"] = state;
end

function BearEmoticons_EnableAnimatedEmotes(state)
    BearEmoticons_Settings["ENABLE_ANIMATEDEMOTES"] = state;
end

function BearEmotes_Update(self, elapsed)
    local nChatFrames = #CHAT_FRAMES;
    if nChatFrames ~= BearEmotes_N_CHATFRAMES then
        BearEmotes_N_CHATFRAMES = nChatFrames
        BearEmotes_SetupChatFrames();
    end

    if BearEmoticons_Settings["ENABLE_ANIMATEDEMOTES"] then
        BearEmotesAnimator_OnUpdate(self, elapsed);
    end
end

function BearEmotes_SetupChatFrames()
    for _, frameName in pairs(CHAT_FRAMES) do
        local frame = _G[frameName]

        frame:HookScript("OnHyperlinkEnter", BearEmoticons_OnHyperlinkEnter)
        frame:HookScript("OnHyperlinkLeave", BearEmoticons_OnHyperlinkLeave)
    end
end

--pass false or nil to leave a value as is, otherwise it gets incremented by one {nrTimesAutoCompleted, nrTimesSent, nrTimesSeen}
function BearUpdateEmoteStats(emote, nrTimesAutoCompleted, nrTimesSent, nrTimesSeen)
    
    if BearEmoteStatistics[emote] == nil then
        BearEmoteStatistics[emote] = {0, 0, 0};
    end

    local newautocompleted = (nrTimesAutoCompleted and BearEmoteStatistics[emote][1] + 1) or BearEmoteStatistics[emote][1];
    local newnrTimesSent = (nrTimesSent and BearEmoteStatistics[emote][2] + 1) or BearEmoteStatistics[emote][2];
    local newnrTimesSeen = (nrTimesSeen and BearEmoteStatistics[emote][3] + 1) or BearEmoteStatistics[emote][3];
    --print("registered emote stat, {nrTimesAutoCompleted, nrTimesSent, nrTimesSeen}: ", nrTimesAutoCompleted, nrTimesSent, nrTimesSeen)
    --print("new values: ", newautocompleted, newnrTimesSent, newnrTimesSeen)
    BearEmoteStatistics[emote] = {newautocompleted, newnrTimesSent,  newnrTimesSeen}
end

function BearEmoticons_SetAutoComplete(state)
    
    BearEmoticons_Settings["ENABLE_AUTOCOMPLETE"] = state

    if BearEmoticons_Settings["ENABLE_AUTOCOMPLETE"] and not autocompleteInited then
        AllBearEmoteNames = {};

        local i = 1;
        for k, v in pairs(BearEmotes_defaultpack) do
            --Some values in emoticons don't have a corresponding key in BearEmotes_defaultpack
            --we need to filter these out because we don't have an emote to show for these
            -- if BearEmotes_defaultpack[v] ~= nil then
                local excluded = false;
                for j=1, #BearEmotes_ExcludedSuggestions do
                    if k == BearEmotes_ExcludedSuggestions[j] then
                        excluded = true;
                        break;
                    end
                end

                if excluded == false then
                    AllBearEmoteNames[i] = k;
                    i = i + 1;
                end
            -- end
        end

        --Sort the list alphabetically
        table.sort(AllBearEmoteNames)

        for _, frameName in pairs(CHAT_FRAMES) do
            local frame = _G[frameName]

            local editbox = frame.editBox;
            local suggestionList = AllBearEmoteNames;
            local maxButtonCount = 20;

            local autocompletesettings = {
                perWord = true,
                activationChar = ':',
                closingChar = ':',
                minChars = 2,
                fuzzyMatch = true,
                onSuggestionApplied = function(suggestion)
                    BearUpdateEmoteStats(suggestion, true, false, false);
                end,
                renderSuggestionFN = BearEmoticons_RenderSuggestionFN,
                suggestionBiasFN = function(suggestion, text)
                    --Bias the sorting function towards the most autocompleted emotes
                    if BearEmoteStatistics[suggestion] ~= nil then
                        return BearEmoteStatistics[suggestion][1] * 5
                    end
                    return 0;
                end,
                interceptOnEnterPressed = true,
                addSpace = true,
                useTabToConfirm = BearEmoticons_Settings["AUTOCOMPLETE_CONFIRM_WITH_TAB"],
                useArrowButtons = true,
            }

            SetupAutoComplete(editbox, suggestionList, maxButtonCount, autocompletesettings);
            
        end
    
        autocompleteInited = true;
    end

end

function BearEmoticons_SetType(chattype, state)
    if (state) then
        state = true;
    else
        state = false;
    end
    if (chattype == "CHAT_MSG_RAID") then
        BearEmoticons_Settings["CHAT_MSG_RAID_LEADER"] = state;
        BearEmoticons_Settings["CHAT_MSG_RAID_WARNING"] = state;
    end
    if (chattype == "CHAT_MSG_PARTY") then
        BearEmoticons_Settings["CHAT_MSG_PARTY_LEADER"] = state;
        BearEmoticons_Settings["CHAT_MSG_PARTY_GUIDE"] = state;
    end
    if (chattype == "CHAT_MSG_WHISPER") then
        BearEmoticons_Settings["CHAT_MSG_WHISPER_INFORM"] = state;
    end
    if (chattype == "CHAT_MSG_INSTANCE_CHAT") then
        BearEmoticons_Settings["CHAT_MSG_INSTANCE_CHAT_LEADER"] = state;
    end
    if (chattype == "CHAT_MSG_BN_WHISPER") then
        BearEmoticons_Settings["CHAT_MSG_BN_WHISPER_INFORM"] = state;
    end

    BearEmoticons_Settings[chattype] = state;
    BearEmoticons_UpdateChatFilters();
end

function BearEmoticons_RegisterPack(name, newEmoticons, pack)
    for k, v in pairs(newEmoticons) do
        BearEmotes_emoticons[k] = v
    end

    for k, v in pairs(pack) do
        BearEmotes_defaultpack[k] = v
    end
end

BearEmotes = BearEmotes or {};
function BearEmotes:AddCategory(name, emotes)
    local category = {name};

    for _, emote in ipairs(emotes) do
        table.insert(category, emote);
    end

    local nextCategoryIndex = (#BearEmotes_dropdown_options + 1);
    BearEmotes_dropdown_options[nextCategoryIndex] = category;
    BearEmoticons_Settings["FAVEMOTES"][nextCategoryIndex] = true;
end

function BearEmotes:AddEmote(id, name, path)
    BearEmotes_defaultpack[id] = path;
    BearEmotes_emoticons[name] = id;
end

BearEmotes_HoverMessageInfo = nil;
function BearEmoticons_OnHyperlinkEnter(frame, link, message, fontstring, ...)
    local linkType, linkContent = link:match("^([^:]+):(.+)")
    if (linkType == "tel") then
        BearEmotes_HoverMessageInfo = fontstring and fontstring.messageInfo or nil;

        GameTooltip:SetOwner(frame, "ANCHOR_CURSOR");
        GameTooltip:SetText(linkContent, 255, 210, 0);
        GameTooltip:Show();
    end
end

function BearEmoticons_OnHyperlinkLeave(frame, ...)
    GameTooltip:Hide()
    BearEmotes_HoverMessageInfo = nil
end

local oldsethyperlink = ItemRefTooltip.SetHyperlink
function ItemRefTooltip:SetHyperlink(link)
    if (string.sub(link, 1, 3) ~= "tel") then
        oldsethyperlink(self, link)
    end
end
