local addonName, AddonNS = ...
local WowList = LibStub("WowList-1.5")
local GL = LibStub("MyLibrary_GUI")

local NS = AddonNS.WowListExamples
local Data = NS.SharedData

local severityColor = {
    TRACE = { 0.7, 0.7, 0.7, 1 },
    INFO = { 0.45, 0.75, 1, 1 },
    WARN = { 1, 0.85, 0.25, 1 },
    ERROR = { 1, 0.4, 0.3, 1 },
    CRITICAL = { 1, 0.2, 0.8, 1 },
}

NS:RegisterExample("example_06_advanced_coloring", {
    title = "06 Advanced Colors",
    description = "Complex formatting, filters, tooltips, and row overlays.",
    build = function(self)
        local frame = self:CreateExampleFrame("Advanced", "WowList Example 06 - Advanced Coloring and UX", 1040, 620)
        local container = CreateFrame("Frame", nil, frame)
        container:SetPoint("TOPLEFT", frame.Inset, "TOPLEFT", 10, -10)
        container:SetPoint("BOTTOMRIGHT", frame.Inset, "BOTTOMRIGHT", -10, 10)

        local filterLabel = GL.CreateFontString(container, nil, "ARTWORK", "Search:", "TOPLEFT", container, "TOPLEFT", 4, -7)
        filterLabel:SetTextColor(1, 1, 1, 1)

        local searchBox = CreateFrame("EditBox", nil, container, "SearchBoxTemplate")
        searchBox:SetSize(280, 22)
        searchBox:SetPoint("LEFT", filterLabel, "RIGHT", 6, 0)
        searchBox:SetAutoFocus(false)

        local onlyCritical = CreateFrame("CheckButton", nil, container, "UICheckButtonTemplate")
        onlyCritical:SetPoint("LEFT", searchBox, "RIGHT", 12, 0)
        onlyCritical.text:SetText("Only critical")

        local helper = GL.CreateFontString(container, nil, "ARTWORK",
            "Hover details column to see tooltip. Filters combine text + severity.", "TOPLEFT", filterLabel, "BOTTOMLEFT",
            0, -8)
        helper:SetTextColor(0.85, 0.85, 0.95, 1)

        local list = WowList:CreateNew(addonName .. "_Example06List", {
            rows = 18,
            height = 430,
            columns = {
                {
                    name = "",
                    width = 0,
                    textureDisplayFunction = function(_, rowData)
                        local severity = rowData[3]
                        if severity == "CRITICAL" then
                            return nil, { 0.8, 0.1, 0.6, 0.18 }, 960, 18, 0
                        elseif severity == "ERROR" then
                            return nil, { 1, 0, 0, 0.10 }, 960, 18, 0
                        elseif severity == "WARN" then
                            return nil, { 1, 0.85, 0, 0.08 }, 960, 18, 0
                        end
                    end,
                },
                { name = "Id", width = 70, sortFunction = function(a, b) return (tonumber(a) or 0) < (tonumber(b) or 0) end },
                {
                    name = "Severity",
                    width = 120,
                    sortFunction = function(a, b) return tostring(a) < tostring(b) end,
                    displayFunction = function(cellData)
                        return tostring(cellData), severityColor[cellData] or { 1, 1, 1, 1 }
                    end,
                },
                { name = "Source", width = 130, sortFunction = function(a, b) return tostring(a) < tostring(b) end },
                { name = "Owner", width = 120, sortFunction = function(a, b) return tostring(a) < tostring(b) end },
                {
                    name = "Value",
                    width = 100,
                    sortFunction = function(a, b) return (tonumber(a) or 0) < (tonumber(b) or 0) end,
                    displayFunction = function(cellData)
                        local val = tonumber(cellData) or 0
                        local color = val >= 4000 and { 1, 0.1, 0.1, 1 } or val >= 2500 and { 1, 0.8, 0.2, 1 } or
                            { 0.7, 1, 0.7, 1 }
                        return tostring(val), color
                    end,
                },
                {
                    name = "Details",
                    width = 420,
                    cellOnEnterFunction = function(cellData, rowData)
                        GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
                        GameTooltip:ClearLines()
                        GameTooltip:AddLine("Event Details", 1, 0.82, 0)
                        GameTooltip:AddLine("Id: " .. tostring(rowData[2]))
                        GameTooltip:AddLine("Severity: " .. tostring(rowData[3]))
                        GameTooltip:AddLine("Tag: " .. tostring(rowData[8]))
                        GameTooltip:AddLine(cellData or "")
                        GameTooltip:Show()
                    end,
                    cellOnLeaveFunction = function()
                        GameTooltip:Hide()
                    end,
                },
            },
        }, container)
        list:SetPoint("TOPLEFT", helper, "BOTTOMLEFT", 0, -10)
        list:SetMultiSelection(true)

        local function applyFilter()
            local search = string.lower(searchBox:GetText() or "")
            local criticalOnly = onlyCritical:GetChecked()
            list:AddFilter("advancedFilter", function(row)
                local severityMatch = (not criticalOnly) or row[3] == "CRITICAL"
                if not severityMatch then
                    return false
                end
                if search == "" then
                    return true
                end
                return string.find(string.lower(tostring(row[3])), search, 1, true)
                    or string.find(string.lower(tostring(row[4])), search, 1, true)
                    or string.find(string.lower(tostring(row[5])), search, 1, true)
                    or string.find(string.lower(tostring(row[7])), search, 1, true)
                    or string.find(string.lower(tostring(row[8])), search, 1, true)
            end)
            list:UpdateView()
        end

        searchBox:HookScript("OnTextChanged", applyFilter)
        onlyCritical:SetScript("OnClick", applyFilter)

        local rows = Data.GetAdvancedRows()
        for i = 1, #rows do
            local r = rows[i]
            list:AddData({ false, r[1], r[2], r[3], r[4], r[5], r[6], r[7] })
        end
        list:UpdateView()

        return frame
    end,
})
