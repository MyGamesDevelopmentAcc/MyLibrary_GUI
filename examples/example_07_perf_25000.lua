local addonName, AddonNS = ...
local WowList = LibStub("WowList-1.5")
local GL = LibStub("MyLibrary_GUI")

local NS = AddonNS.WowListExamples
local Data = NS.SharedData

local PERF_ROWS = 25000

NS:RegisterExample("example_07_perf_25000", {
    title = "07 Perf 25k",
    description = "25,000 rows with manual regenerate/refresh, sorting, filtering, and stats.",
    build = function(self)
        local frame = self:CreateExampleFrame("Perf25000", "WowList Example 07 - Performance (25,000 rows)", 1160, 700)
        local container = CreateFrame("Frame", nil, frame)
        container:SetPoint("TOPLEFT", frame.Inset, "TOPLEFT", 10, -10)
        container:SetPoint("BOTTOMRIGHT", frame.Inset, "BOTTOMRIGHT", -10, 10)

        local header = GL.CreateFontString(container, nil, "ARTWORK",
            "Stress example: 25,000 deterministic rows; sort, filter, and refresh manually.", "TOPLEFT", container,
            "TOPLEFT", 4, -6)
        header:SetTextColor(0.95, 0.85, 0.2, 1)

        local searchLabel = GL.CreateFontString(container, nil, "ARTWORK", "Filter:", "TOPLEFT", header, "BOTTOMLEFT", 0, -10)
        searchLabel:SetTextColor(1, 1, 1, 1)

        local searchBox = CreateFrame("EditBox", nil, container, "SearchBoxTemplate")
        searchBox:SetSize(260, 22)
        searchBox:SetPoint("LEFT", searchLabel, "RIGHT", 6, 0)
        searchBox:SetAutoFocus(false)

        local regenerateButton = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
        regenerateButton:SetSize(130, 22)
        regenerateButton:SetPoint("LEFT", searchBox, "RIGHT", 10, 0)
        regenerateButton:SetText("Regenerate 25k")

        local refreshButton = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
        refreshButton:SetSize(110, 22)
        refreshButton:SetPoint("LEFT", regenerateButton, "RIGHT", 8, 0)
        refreshButton:SetText("Refresh View")

        local clearFilterButton = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
        clearFilterButton:SetSize(90, 22)
        clearFilterButton:SetPoint("LEFT", refreshButton, "RIGHT", 8, 0)
        clearFilterButton:SetText("Clear Filter")

        local statsText = GL.CreateFontString(container, nil, "ARTWORK", "", "TOPLEFT", searchLabel, "BOTTOMLEFT", 0, -8)
        statsText:SetTextColor(0.8, 1, 0.85, 1)
        statsText:SetWidth(1140)

        local list = WowList:CreateNew(addonName .. "_Example07List", {
            rows = 23,
            height = 530,
            columns = {
                { name = "Id", width = 90, sortFunction = function(a, b) return (tonumber(a) or 0) < (tonumber(b) or 0) end },
                { name = "Name", width = 240, sortFunction = function(a, b) return tostring(a) < tostring(b) end },
                { name = "Category", width = 160, sortFunction = function(a, b) return tostring(a) < tostring(b) end },
                { name = "Score", width = 150, sortFunction = function(a, b) return (tonumber(a) or 0) < (tonumber(b) or 0) end },
                { name = "Status", width = 140, sortFunction = function(a, b) return tostring(a) < tostring(b) end },
                { name = "Timestamp", width = 130, sortFunction = function(a, b) return tostring(a) < tostring(b) end },
            },
        }, container)
        list:SetPoint("TOPLEFT", statsText, "BOTTOMLEFT", 0, -10)
        list:SetMultiSelection(true)

        local revision = 0
        local generationMs = 0
        local refreshMs = 0

        local function applySearchFilter()
            local txt = string.lower(searchBox:GetText() or "")
            list:AddFilter("perfSearch", function(row)
                if txt == "" then
                    return true
                end
                return string.find(string.lower(tostring(row[1])), txt, 1, true)
                    or string.find(string.lower(tostring(row[2])), txt, 1, true)
                    or string.find(string.lower(tostring(row[3])), txt, 1, true)
                    or string.find(string.lower(tostring(row[5])), txt, 1, true)
                    or string.find(string.lower(tostring(row[6])), txt, 1, true)
            end)
        end

        local function refreshStats()
            statsText:SetText(string.format(
                "Rows total: %d | Visible: %d | Generation: %.2f ms | Refresh: %.2f ms | Revision: %d",
                #list.data,
                #list:GetDataView(),
                generationMs,
                refreshMs,
                revision
            ))
        end

        local function refreshView()
            local t0 = debugprofilestop()
            applySearchFilter()
            list:UpdateDataView()
            list:UpdateView()
            refreshMs = debugprofilestop() - t0
            refreshStats()
        end

        local function regenerate()
            revision = revision + 1
            local t0 = debugprofilestop()
            local rows = Data.GeneratePerfRows(PERF_ROWS, revision)
            list:SetData(rows)
            generationMs = debugprofilestop() - t0
            refreshView()
        end

        searchBox:HookScript("OnTextChanged", function()
            refreshView()
        end)

        regenerateButton:SetScript("OnClick", regenerate)
        refreshButton:SetScript("OnClick", refreshView)
        clearFilterButton:SetScript("OnClick", function()
            searchBox:SetText("")
            refreshView()
        end)

        regenerate()
        return frame
    end,
})

