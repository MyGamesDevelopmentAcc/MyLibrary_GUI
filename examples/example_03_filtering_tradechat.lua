local addonName, AddonNS = ...
local WowList = LibStub("WowList-1.5")
local GL = LibStub("MyLibrary_GUI")

local NS = AddonNS.WowListExamples
local Data = NS.SharedData

NS:RegisterExample("example_03_filtering_tradechat", {
    title = "03 Filtering",
    description = "TradeChat-like search filtering over multiple fields.",
    build = function(self)
        local frame = self:CreateExampleFrame("Filtering", "WowList Example 03 - Filtering (TradeChat Style)", 960, 560)
        local container = CreateFrame("Frame", nil, frame)
        container:SetPoint("TOPLEFT", frame.Inset, "TOPLEFT", 10, -10)
        container:SetPoint("BOTTOMRIGHT", frame.Inset, "BOTTOMRIGHT", -10, 10)

        local filterLabel = GL.CreateFontString(container, nil, "ARTWORK", "Filter:", "TOPLEFT", container, "TOPLEFT", 4, -7)
        filterLabel:SetTextColor(1, 1, 1, 1)

        local searchBox = CreateFrame("EditBox", nil, container, "SearchBoxTemplate")
        searchBox:SetSize(280, 22)
        searchBox:SetPoint("LEFT", filterLabel, "RIGHT", 6, 0)
        searchBox:SetAutoFocus(false)

        local clearButton = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
        clearButton:SetSize(80, 22)
        clearButton:SetPoint("LEFT", searchBox, "RIGHT", 8, 0)
        clearButton:SetText("Clear")

        local countText = GL.CreateFontString(container, nil, "ARTWORK", "", "LEFT", clearButton, "RIGHT", 10, 0)
        countText:SetTextColor(0.8, 0.95, 1, 1)

        local list = WowList:CreateNew(addonName .. "_Example03List", {
            rows = 16,
            height = 390,
            columns = {
                { name = "Id", width = 80, sortFunction = function(a, b) return tostring(a) < tostring(b) end },
                { name = "Message", width = 520 },
                { name = "Channel", width = 110, sortFunction = function(a, b) return tostring(a) < tostring(b) end },
                { name = "Topic", width = 120, sortFunction = function(a, b) return tostring(a) < tostring(b) end },
                { name = "Quality", width = 100, sortFunction = function(a, b) return tostring(a) < tostring(b) end },
            },
        }, container)
        list:SetPoint("TOPLEFT", filterLabel, "BOTTOMLEFT", 0, -12)
        list:SetMultiSelection(false)

        local function refreshCount()
            countText:SetText(string.format("Visible: %d / %d", #list:GetDataView(), #list.data))
        end

        local function applyFilter()
            local txt = string.lower(searchBox:GetText() or "")
            list:AddFilter("search", function(row)
                if txt == "" then
                    return true
                end
                return string.find(string.lower(tostring(row[1])), txt, 1, true)
                    or string.find(string.lower(tostring(row[2])), txt, 1, true)
                    or string.find(string.lower(tostring(row[3])), txt, 1, true)
                    or string.find(string.lower(tostring(row[4])), txt, 1, true)
                    or string.find(string.lower(tostring(row[5])), txt, 1, true)
            end)
            list:UpdateView()
            refreshCount()
        end

        searchBox:HookScript("OnTextChanged", applyFilter)
        clearButton:SetScript("OnClick", function()
            searchBox:SetText("")
            applyFilter()
        end)

        local rows = Data.GetTradeLikeRows()
        for i = 1, #rows do
            list:AddData(rows[i])
        end
        list:UpdateView()
        refreshCount()

        return frame
    end,
})

