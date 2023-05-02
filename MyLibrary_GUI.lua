--[[
    This file used to contain libraries which allowed for easy creation of frames and then to resking them easily. I have since remove skins and no longer use them. This file would need to be cleaned up, but nobody got time for this ;)
]]

local MAJOR, MINOR = "MyLibrary_GUI", 1
local MyLibrary_GUI, oldminor = LibStub:NewLibrary(MAJOR, MINOR);
if not MyLibrary_GUI then return end -- No upgrade needed

local GL = MyLibrary_GUI;
GL.colors = {
    blue = "|cff3366ff",
    red = "|cffff0000",
    green = "|cff00ff00",
    yellow = "|cffffff00",
    grey = "|cffaaaaaa",
    white = "|cffffffff",
    close = "|r",
    class = {
        ["Death Knight"] = { 0.77, 0.12, 0.23, 1.00, "|CFFC41F3B" },
        Druid = { 1.00, 0.49, 0.04, 1.00, "|CFFFF7D0A" },
        Hunter = { 0.67, 0.83, 0.45, 1.00, "|CFFABD473" },
        Mage = { 0.41, 0.80, 0.94, 1.00, "|CFF69CCF0" },
        Paladin = { 0.96, 0.55, 0.73, 1.00, "|CFFF58CBA" },
        Priest = { 1.00, 1.00, 1.00, 1.00, "|CFFFFFFFF" },
        Rogue = { 1.00, 0.96, 0.41, 1.00, "|CFFFFF569" },
        Shaman = { 0.14, 0.35, 1.00, 1.00, "|CFF2459FF" },
        Warlock = { 0.58, 0.51, 0.79, 1.00, "|CFF9482C9" },
        Warrior = { 0.78, 0.61, 0.43, 1.00, "|CFFC79C6E" },
        Monk = { 0.33, 0.54, 0.52, 1.0, "|CFF00FF96" },
        unknown = { 0.50, 0.50, 0.50, 1.00, "|CFF666666" }
    }
}


local function printTable(t, s)
    if s == nil then s = ""; end
    for i, v in pairs(t) do
        print(s .. i .. "=", v);
        if type(v) == "table" then printTable(v, s .. "   ") end
    end
end

function GL:GetLayout()
    return GL.layouts[GL.layoutName];
end

function GL:SetLayout(name)
    if GL.layouts[name] ~= nil then
        GL.layoutName = name;
    else
        self:Print("There is no such layout."); --todo maybe print available layouts
    end
end

function GL:SetFontLook(f)
    local l = self:GetLayout();
    local font = CreateFont(tostring(self) .. "guiskinfont");
    if f:IsObjectType("FontString") then
        font:SetFont(l.font, l.fontsize);
        font:SetTextColor(unpack(l.fontcolor))
        f:SetFontObject(font)
    elseif f:IsObjectType("Button") then
        local fontHighlight = CreateFont(tostring(self) .. "guiskinfonthighlight");
        local fontDisabled = CreateFont(tostring(self) .. "guiskinfontdiabled");
        font:SetFont(l.font, l.fontsize);
        fontDisabled:SetFont(l.font, l.fontsize);
        fontHighlight:SetFont(l.font, l.fontsize);
        font:SetTextColor(unpack(l.fontbuttonnormal));
        fontDisabled:SetTextColor(unpack(l.fontbuttondisabled));
        fontHighlight:SetTextColor(unpack(l.fontbuttonhighlight));
        f:SetNormalFontObject(font);
        f:SetDisabledFontObject(fontDisabled);
        f:SetHighlightFontObject(fontHighlight);
    end
end

function GL:SetButtonLook(f)
    local l = self:GetLayout();
    self:SetFontLook(f)
    if l.skinbuttons == true then
        self:SetFrameLook(f, true)
        f:SetNormalTexture("")
        f:SetHighlightTexture("")
        f:SetPushedTexture("")
        f:SetDisabledTexture("")
        f:SetScript("OnEnter", function()
            f:SetBackdropColor(unpack(l.buttonbackdropcolorin))
            f:SetBackdropBorderColor(unpack(l.buttonbordercolorin))
        end)
        f:SetScript("OnLeave", function()
            f:SetBackdropColor(unpack(l.buttonbackdropcolorout))
            f:SetBackdropBorderColor(unpack(l.buttonbordercolorout))
        end)

        f:SetBackdropColor(unpack(l.buttonbackdropcolorout))
        f:SetBackdropBorderColor(unpack(l.buttonbordercolorout))
    else
        self:SetFrameLook(f, true)
        f:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
        f:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
        f:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
        f:SetDisabledTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
        f:SetScript("OnEnter", function()
        end)
        f:SetScript("OnLeave", function()
        end)
    end
end

-- set Frame look
function GL:SetFrameLook(f, backgroundPicture)
    local l = GL:GetLayout();

    if (f:IsObjectType("Button") or backgroundPicture == nil) then --goNormal is used mainly for buttons - cuz they are also frames, but we dont want them to be skinned as other frames :)
        f:SetBackdrop({
            bgFile = GL.blank,
            edgeFile = GL.blank,
            tile = false, tileSize = 0, edgeSize = 1,
            insets = { left = -1, right = -1, top = -1, bottom = -1 }
        })
        f:SetBackdropColor(unpack(l.backdropcolor))
        f:SetBackdropBorderColor(unpack(l.bordercolor))
    else

        local bgpic = backgroundPicture;

        f:SetBackdrop({
            bgFile = bgpic, -- DkpBidder["media"].blank,  -- path to the background texture
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", -- path to the border texture

            tile = false, -- true to repeat the background texture to fill the frame, false to scale it
            tileSize = 32, -- size (width or height) of the square repeating background tiles (in pixels)
            edgeSize = 12, -- thickness of edge segments and square size of edge corners (in pixels)
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        if backgroundPicture == nil then f:SetBackdropColor(unpack(l.backdropcolor)) end


    end
end

-- create Texture function
function GL.CreateTexture(frame, name, level, width, height, point, relativeTo, point2, x, y, texturePath)
    local texture = frame:CreateTexture(name, level);


    texture:SetWidth(width);
    texture:SetHeight(height);
    texture:SetTexCoord(0, 1, 0, 1);
    if (point) then
        texture:SetPoint(point, relativeTo, point2, x, y);
        if texturePath then
            texture:SetTexture(texturePath); --[[Interface\TaxiFrame\UI-TaxiFrame-TopRight]]
        end
    end

    texture:SetAlpha(1);
    texture:Show();
    return texture;
end

function GL:CreateFontString(name, level, text, point, relativeTo, point2, x, y)

    local fs = self:CreateFontString(name, level, "GameFontNormal");
    if point then fs:SetPoint(point, relativeTo, point2, x, y); end
    fs:SetText(text);
    return fs;
end

function GL:CreateCheckBox(text)
    local frame = CreateFrame("CheckButton", nil, self, "InterfaceOptionsCheckButtonTemplate");
    frame:SetWidth(24);
    frame:SetHeight(24);
    frame.text = GL.CreateFontString(self, nil, "ARTWORK", text, "LEFT", frame, "RIGHT", 0, 0);
    frame.text:SetTextColor(1, 1, 1, 1);
    return frame;
end

---CreateFrame(self.ver.."_RosterFrame","DKP Roster","BASIC",400,415,'LEFT',UIParent,'LEFT',100 ,0);--400 375

function GL:CreateSimpleFrame(frameName, width, height)
    width = width or 665;
    height = height or 395;
    local f = CreateFrame("Frame", frameName, UIParent, "SimplePanelTemplate");
    _G[frameName]=f;
    table.insert(_G.UISpecialFrames, frameName);


    f:SetWidth(width);
    f:SetHeight(height);
    --f:EnableMouse(true); ?? co to robi?
    f:SetMovable(true);
    f:SetPoint('CENTER', UIParent, 'CENTER', -100, 0)
    f:SetScript("OnMouseDown",
        function(self)
            self:StartMoving();
        end)
    f:SetScript("OnMouseUp",
        function(self)
            self:StopMovingOrSizing();
        end)
    f:SetScript("OnShow",
        function(self)
            PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
            ---
        end)
    f:SetScript("OnHide",
        function(self)
            PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
            ---
        end)


    f:SetFrameStrata("MEDIUM");
    f:SetToplevel(true);

    --close button
    local cb = CreateFrame("Button", frameName .. "closeButton", f, "UIPanelCloseButton");
    cb:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0);
    cb:SetWidth(32);
    cb:SetHeight(32);

    return f;
end

function GL:CreateButtonFrame(frameName, width, height)
    width = width or 665;
    height = height or 395;
    local f = CreateFrame("Frame", frameName, UIParent, "ButtonFrameTemplate");
    _G[frameName]=f;
    table.insert(_G.UISpecialFrames, frameName);
    ButtonFrameTemplate_HidePortrait(f);


    f:SetWidth(width);
    f:SetHeight(height);
    --f:EnableMouse(true); ?? co to robi?
    f:SetMovable(true);
    f:SetPoint('CENTER', UIParent, 'CENTER', -100, 0)
    f:SetScript("OnMouseDown",
        function(self)
            self:StartMoving();
        end)
    f:SetScript("OnMouseUp",
        function(self)
            self:StopMovingOrSizing();
        end)
    f:SetScript("OnShow",
        function(self)
            PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN);
            ---
        end)
    f:SetScript("OnHide",
        function(self)
            PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE);
            ---
        end)


    f:SetFrameStrata("MEDIUM");
    f:SetToplevel(true);


    return f;
end

function GL:CreateFrame(name, title, frameType, width, height, point, relativeTo, point2, x, y) -- naming should be adjusted
    local f = CreateFrame("Frame", name, UIParent, "BackdropTemplate");
    table.insert(_G.UISpecialFrames, name);
    f:SetWidth(width);
    f:SetHeight(height);
    f:Show();
    f:EnableMouse(true);
    f:SetMovable(true);
    f:SetPoint(point, relativeTo, point2, x, y)
    f:SetScript("OnMouseDown",
        function(self)
            self:StartMoving();
        end)
    f:SetScript("OnMouseUp",
        function(self)
            self:StopMovingOrSizing();
        end)
    f:SetFrameStrata("MEDIUM");
    f:SetToplevel(true);

    if frameType == "BASIC" then
        f:SetBackdrop({
            bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]],
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = false,
            tileSize = 32,
            edgeSize = 32,
            insets = { left = 11, right = 11, top = 12, bottom = 10 }
        })
    end
    --close button
    f.view = {};
    f.view["closeButton"] = CreateFrame("Button", name .. "closeButton", f, "UIPanelCloseButton");
    local cb = f.view["closeButton"];
    cb:SetPoint("TOPRIGHT", f, "TOPRIGHT", -4, -4);
    cb:SetWidth(32);
    cb:SetHeight(32);
    --//

    --titleframe and text
    local v = f.view;
    v.titleFrame = CreateFrame("Frame", name .. "_titleFrame", f)
    v.titleString = self.CreateFontString(v.titleFrame, name .. "_title", "ARTWORK", title, "TOP", v.titleFrame, "TOP",
        18, -14);
    v.titleString:SetFont([[Fonts\MORPHEUS.ttf]], 14);
    v.titleString:SetTextColor(1, 1, 1, 1); --shadow??

    v.titleFrame:SetHeight(40)
    v.titleFrame:SetWidth(width / 3); --v.titleString:GetWidth() + 40);
    ----print("TUTAJ "..v.Title:GetWidth())

    v.titleString:SetPoint("TOP", f, "TOP", 0, 2);
    v.titleFrame:SetPoint("TOP", v.titleString, "TOP", 0, 12);
    v.titleFrame:SetMovable(true)
    v.titleFrame:EnableMouse(true)
    v.titleFrame:SetScript("OnMouseDown", function()
        f:StartMoving()
    end)
    v.titleFrame:SetScript("OnMouseUp", function()
        f:StopMovingOrSizing()
    end)
    v.titleFrame.texture = self.CreateTexture(v.titleFrame, name .. "_titleFrameTexture", "ARTWORK", 300, 68, "TOP",
        v.titleFrame, "TOP", 0, 2, [[Interface\DialogFrame\UI-DialogBox-Header]]);
    return f;
end
