local addonName, AddonNS = ...
local GL = LibStub("MyLibrary_GUI")

local NS = AddonNS.WowListExamples
NS.registry = NS.registry or {}
NS.instances = NS.instances or {}
NS.order = NS.order or {}

local launcher

function NS:RegisterExample(id, def)
    assert(type(id) == "string" and #id > 0, "WowListExamples:RegisterExample requires string id")
    assert(type(def) == "table", "WowListExamples:RegisterExample requires table definition")
    assert(type(def.title) == "string" and #def.title > 0, "WowListExamples:RegisterExample requires title")
    assert(type(def.description) == "string" and #def.description > 0, "WowListExamples:RegisterExample requires description")
    assert(type(def.build) == "function", "WowListExamples:RegisterExample requires build function")

    if not self.registry[id] then
        table.insert(self.order, id)
    end
    self.registry[id] = def
end

function NS:CreateExampleFrame(id, title, width, height)
    local frameName = addonName .. "_WowListExample_" .. id
    local frame = GL:CreateButtonFrame(frameName, width or 820, height or 560)
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata("DIALOG")
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    if frame.TitleText then
        frame.TitleText:SetText(title)
    end
    return frame
end

local function getContainer(frame)
    local container = CreateFrame("Frame", nil, frame)
    if frame.Inset then
        container:SetPoint("TOPLEFT", frame.Inset, "TOPLEFT", 10, -10)
        container:SetPoint("BOTTOMRIGHT", frame.Inset, "BOTTOMRIGHT", -10, 10)
    else
        container:SetPoint("TOPLEFT", frame, "TOPLEFT", 12, -26)
        container:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -12, 12)
    end
    return container
end

function NS:OpenExample(id)
    local existing = self.instances[id]
    if existing then
        existing:Show()
        return existing
    end

    local def = self.registry[id]
    if not def then
        return nil
    end

    local frame = def.build(self)
    if not frame then
        return nil
    end

    self.instances[id] = frame
    frame:Show()
    return frame
end

local function ensureLauncher()
    if launcher then
        return launcher
    end

    launcher = GL:CreateButtonFrame(addonName .. "_WowListExamplesLauncher", 540, 500)
    launcher:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    launcher:SetFrameStrata("DIALOG")
    if launcher.TitleText then
        launcher.TitleText:SetText("WowList Examples")
    end

    launcher.container = getContainer(launcher)
    launcher.title = GL.CreateFontString(launcher.container, nil, "ARTWORK", "Examples of WowList-1.5 usage", "TOPLEFT",
        launcher.container, "TOPLEFT", 6, -6)
    launcher.title:SetTextColor(1, 0.85, 0.2, 1)

    launcher.description = GL.CreateFontString(launcher.container, nil, "ARTWORK",
        "Click any entry to create/open that example.", "TOPLEFT", launcher.title, "BOTTOMLEFT", 0, -6)
    launcher.description:SetTextColor(0.85, 0.85, 0.85, 1)

    launcher.rows = {}

    return launcher
end

function NS:RefreshLauncher()
    local frame = ensureLauncher()
    local parent = frame.container

    for i = 1, #frame.rows do
        frame.rows[i]:Hide()
        if frame.rows[i].text then
            frame.rows[i].text:Hide()
        end
    end

    for idx, id in ipairs(self.order) do
        local def = self.registry[id]
        local row = frame.rows[idx]
        if not row then
            row = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
            row:SetSize(220, 22)
            row.text = GL.CreateFontString(row, nil, "ARTWORK", "", "TOPLEFT", row, "TOPRIGHT", 10, -2)
            row.text:SetTextColor(0.9, 0.9, 0.9, 1)
            frame.rows[idx] = row
        end

        row:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, -40 - ((idx - 1) * 34))
        row:SetText(def.title)
        row:SetScript("OnClick", function()
            NS:OpenExample(id)
        end)
        row.text:SetText(def.description)
        row:Show()
        row.text:Show()
    end
end

function NS:OpenLauncher()
    local frame = ensureLauncher()
    self:RefreshLauncher()
    frame:Show()
end

function MyLibrary_GUI_Examples_OnClick()
    NS:OpenLauncher()
end
