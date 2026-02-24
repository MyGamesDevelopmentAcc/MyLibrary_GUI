local addonName, AddonNS = ...
local WowList = LibStub("WowList-1.5")
local GL = LibStub("MyLibrary_GUI")

local NS = AddonNS.WowListExamples
local Data = NS.SharedData

NS:RegisterExample("example_02_sorting", {
    title = "02 Sorting",
    description = "Header sorting + external Sort(...) calls and reset.",
    build = function(self)
        local frame = self:CreateExampleFrame("Sorting", "WowList Example 02 - Sorting", 860, 520)
        local container = CreateFrame("Frame", nil, frame)
        container:SetPoint("TOPLEFT", frame.Inset, "TOPLEFT", 10, -10)
        container:SetPoint("BOTTOMRIGHT", frame.Inset, "BOTTOMRIGHT", -10, 10)

        local info = GL.CreateFontString(container, nil, "ARTWORK",
            "Use header clicks OR external buttons below (calls list:Sort directly).", "TOPLEFT", container, "TOPLEFT", 4,
            -4)
        info:SetTextColor(0.9, 0.9, 0.9, 1)

        local list = WowList:CreateNew(addonName .. "_Example02List", {
            rows = 14,
            height = 350,
            columns = {
                { name = "Name", width = 220, sortFunction = function(a, b) return tostring(a) < tostring(b) end },
                { name = "Class", width = 160, sortFunction = function(a, b) return tostring(a) < tostring(b) end },
                { name = "Level", width = 100, sortFunction = function(a, b) return (tonumber(a) or 0) < (tonumber(b) or 0) end },
                { name = "Score", width = 130, sortFunction = function(a, b) return (tonumber(a) or 0) < (tonumber(b) or 0) end },
                { name = "Rank", width = 120, sortFunction = function(a, b) return tostring(a) < tostring(b) end },
            },
        }, container)
        list:SetPoint("TOPLEFT", info, "BOTTOMLEFT", 0, -10)
        list:SetMultiSelection(true)

        local function loadRows()
            list:RemoveAll()
            local rows = Data.GetSortingRows()
            for i = 1, #rows do
                list:AddData(rows[i])
            end
            list:UpdateView()
        end

        local reloadButton = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
        reloadButton:SetSize(140, 22)
        reloadButton:SetPoint("TOPLEFT", list, "BOTTOMLEFT", 0, -10)
        reloadButton:SetText("Reload Data")
        reloadButton:SetScript("OnClick", loadRows)

        local sortScoreAsc = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
        sortScoreAsc:SetSize(130, 22)
        sortScoreAsc:SetPoint("LEFT", reloadButton, "RIGHT", 8, 0)
        sortScoreAsc:SetText("Sort Score Asc")
        sortScoreAsc:SetScript("OnClick", function()
            list:Sort(4, function(a, b)
                return (tonumber(a) or 0) < (tonumber(b) or 0)
            end)
            list:UpdateView()
        end)

        local sortScoreDesc = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
        sortScoreDesc:SetSize(130, 22)
        sortScoreDesc:SetPoint("LEFT", sortScoreAsc, "RIGHT", 8, 0)
        sortScoreDesc:SetText("Sort Score Desc")
        sortScoreDesc:SetScript("OnClick", function()
            list:Sort(4, function(a, b)
                return (tonumber(a) or 0) > (tonumber(b) or 0)
            end)
            list:UpdateView()
        end)

        local sortNameAsc = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
        sortNameAsc:SetSize(130, 22)
        sortNameAsc:SetPoint("LEFT", sortScoreDesc, "RIGHT", 8, 0)
        sortNameAsc:SetText("Sort Name Asc")
        sortNameAsc:SetScript("OnClick", function()
            list:Sort(1, function(a, b)
                return tostring(a) < tostring(b)
            end)
            list:UpdateView()
        end)

        loadRows()
        return frame
    end,
})
