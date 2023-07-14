local BEAREMOTES_TimeSinceLastUpdate = 0
local BEAREMOTES_T = 0;

function BearEmotesAnimator_OnUpdate(self, elapsed)

    if (BEAREMOTES_TimeSinceLastUpdate >= 0.033) then
        -- Update animated emotes in chat windows
        for i = 1, NUM_CHAT_WINDOWS do
            for _, visibleLine in ipairs(_G["ChatFrame" .. i].visibleLines) do
                if(_G["ChatFrame" .. i]:IsShown() and visibleLine.messageInfo ~= BearEmotes_HoverMessageInfo) then 
                    BearEmotesAnimator_UpdateEmoteInFontString(visibleLine, 28, 28);
                end
            end
        end

        -- Update animated emotes in suggestion list
        if (EditBoxAutoCompleteBox and EditBoxAutoCompleteBox:IsShown() and
            EditBoxAutoCompleteBox.existingButtonCount ~= nil) then
            for i = 1, EditBoxAutoCompleteBox.existingButtonCount do
                local cBtn = EditBoxAutoComplete_GetAutoCompleteButton(i);
                if (cBtn:IsVisible()) then
                    BearEmotesAnimator_UpdateEmoteInFontString(cBtn, 16, 16);
                else
                    break
                end
            end
        end

        -- Update animated emotes in statistics screen
        if(BearStatsScreen:IsVisible()) then
           
            local topSentImagePath = BearEmotes_defaultpack[BearEmoteSentStatKeys[1]] or "Interface\\AddOns\\BearEmotes\\Emotes\\1337.tga";
            local animdata = BearEmotes_animation_metadata[topSentImagePath:match("(Interface\\AddOns\\BearEmotes\\Emotes.-.tga)")]
            
            if(animdata ~= nil) then
                local cFrame = BearEmotes_GetCurrentFrameNum(animdata)
                BearStatsScreen.topSentEmoteTexture:SetTexCoord(BearEmotes_GetTexCoordsForFrame(animdata, cFrame)) 
            end
                

            local topSeenImagePath = BearEmotes_defaultpack[BearEmoteRecievedStatKeys[1]] or "Interface\\AddOns\\BearEmotes\\Emotes\\1337.tga";
            local animdata = BearEmotes_animation_metadata[topSeenImagePath:match("(Interface\\AddOns\\BearEmotes\\Emotes.-.tga)")]
            if(animdata ~= nil) then
                local cFrame = BearEmotes_GetCurrentFrameNum(animdata)
                BearStatsScreen.topSeenEmoteTexture:SetTexCoord(BearEmotes_GetTexCoordsForFrame(animdata, cFrame)) 
            end
            

            for line=1, 17 do
                local sentEntry = getglobal("BearStatsSentEntry"..line)
                local recievedEntry = getglobal("BearStatsRecievedEntry"..line)

                if(sentEntry:IsVisible()) then
                    BearEmotesAnimator_UpdateEmoteInFontString(sentEntry, 16, 16);
                end

                if(recievedEntry:IsVisible()) then
                    BearEmotesAnimator_UpdateEmoteInFontString(recievedEntry, 16, 16);
                end
            end
        end
        

        BEAREMOTES_TimeSinceLastUpdate = 0;
    end

    BEAREMOTES_T = BEAREMOTES_T + elapsed
    BEAREMOTES_TimeSinceLastUpdate = BEAREMOTES_TimeSinceLastUpdate +
                                        elapsed;
end

local function escpattern(x)
    return (
            --x:gsub('%%', '%%%%')
             --:gsub('^%^', '%%^')
             --:gsub('%$$', '%%$')
             --:gsub('%(', '%%(')
             --:gsub('%)', '%%)')
             --:gsub('%.', '%%.')
             --:gsub('%[', '%%[')
             --:gsub('%]', '%%]')
             --:gsub('%*', '%%*')
             x:gsub('%+', '%%+')
             :gsub('%-', '%%-')
             --:gsub('%?', '%%?'))
            )
end

-- This will update the texture escapesequence of an animated emote
-- if it exsists in the contents of the fontstring
function BearEmotesAnimator_UpdateEmoteInFontString(fontstring, widthOverride, heightOverride)
    local txt = fontstring:GetText();
    if (txt ~= nil) then
        for emoteTextureString in txt:gmatch("(|TInterface\\AddOns\\BearEmotes\\Emotes.-|t)") do
            local imagepath = emoteTextureString:match("|T(Interface\\AddOns\\BearEmotes\\Emotes.-.tga).-|t")

            local animdata = BearEmotes_animation_metadata[imagepath];
            if (animdata ~= nil) then
                local framenum = BearEmotes_GetCurrentFrameNum(animdata);
                local nTxt;
                if(widthOverride ~= nil or heightOverride ~= nil) then
                    nTxt = txt:gsub(escpattern(emoteTextureString),
                                        BearEmotes_BuildEmoteFrameStringWithDimensions(
                                        imagepath, animdata, framenum, widthOverride, heightOverride))
                else
                    nTxt = txt:gsub(escpattern(emoteTextureString),
                                      BearEmotes_BuildEmoteFrameString(
                                        imagepath, animdata, framenum))
                end

                -- If we're updating a chat message we need to alter the messageInfo as wel
                if (fontstring.messageInfo ~= nil) then
                    fontstring.messageInfo.message = nTxt
                end
                fontstring:SetText(nTxt);
                txt = nTxt;
            end
        end
    end
end



function BearEmotes_GetAnimData(imagepath)
    return BearEmotes_animation_metadata[imagepath]
end

function BearEmotes_GetCurrentFrameNum(animdata)
    return math.floor((BEAREMOTES_T * animdata.framerate) % animdata.nFrames);
end

function BearEmotes_GetTexCoordsForFrame(animdata, framenum)
    local fHeight = 1/animdata.nFrames
    return 0, 1 ,framenum * fHeight, (framenum * fHeight) + fHeight
end

function BearEmotes_BuildEmoteFrameString(imagepath, animdata, framenum)
    local top = framenum * animdata.frameHeight;
    local bottom = top + animdata.frameHeight;

    local emoteStr = "|T" .. imagepath .. ":" .. animdata.frameWidth .. ":" ..
                        animdata.frameHeight .. ":0:0:" .. animdata.imageWidth ..
                        ":" .. animdata.imageHeight .. ":0:" ..
                        animdata.frameWidth .. ":" .. top .. ":" .. bottom ..
                        "|t";
    return emoteStr
end

function BearEmotes_BuildEmoteFrameStringWithDimensions(imagepath, animdata,
                                                        framenum, framewidth,
                                                        frameheight)
    local top = framenum * animdata.frameHeight;
    local bottom = top + animdata.frameHeight;

    local emoteStr = "|T" .. imagepath .. ":" .. framewidth .. ":" ..
                        frameheight .. ":0:0:" .. animdata.imageWidth .. ":" ..
                        animdata.imageHeight .. ":0:" .. animdata.frameWidth ..
                        ":" .. top .. ":" .. bottom .. "|t";
    return emoteStr
end