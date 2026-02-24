local addonName, AddonNS = ...
local WowList = LibStub("WowList-1.5")
local GL = LibStub("MyLibrary_GUI")

local NS = AddonNS.WowListExamples
local Data = NS.SharedData

NS:RegisterExample("example_04_selection_callbacks", {
    title = "04 Callbacks",
    description = "Selection behavior and callback events.",
    build = function(self)
        local frame = self:CreateExampleFrame("Callbacks", "WowList Example 04 - Selection and Callbacks", 940, 560)
        local container = CreateFrame("Frame", nil, frame)
        container:SetPoint("TOPLEFT", frame.Inset, "TOPLEFT", 10, -10)
        container:SetPoint("BOTTOMRIGHT", frame.Inset, "BOTTOMRIGHT", -10, 10)

        local list = WowList:CreateNew(addonName .. "_Example04List", {
            rows = 16,
            height = 390,
            columns = {
                { name = "Id", width = 60, sortFunction = function(a, b) return (tonumber(a) or 0) < (tonumber(b) or 0) end },
                { name = "Name", width = 180, sortFunction = function(a, b) return tostring(a) < tostring(b) end },
                { name = "Role", width = 120, sortFunction = function(a, b) return tostring(a) < tostring(b) end },
                { name = "Class", width = 140, sortFunction = function(a, b) return tostring(a) < tostring(b) end },
                { name = "Priority", width = 120, sortFunction = function(a, b) return (tonumber(a) or 0) < (tonumber(b) or 0) end },
            },
        }, container)
        list:SetPoint("TOPLEFT", container, "TOPLEFT", 4, -34)
        list:SetMultiSelection(true)

        local statusText = GL.CreateFontString(container, nil, "ARTWORK", "", "TOPLEFT", list, "TOPRIGHT", 14, 0)
        statusText:SetTextColor(0.85, 0.95, 1, 1)
        statusText:SetJustifyH("LEFT")
        statusText:SetWidth(280)

        local function updateStatus(label)
            local selected = list:GetSelected()
            local last = list:GetLastSelected()
            statusText:SetText(string.format(
                "%s\nSelected count: %d\nLast selected: %s",
                label or "Ready",
                selected and #selected or 0,
                last and tostring(last[2]) or "none"
            ))
        end

        local selectMages = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
        selectMages:SetSize(130, 22)
        selectMages:SetPoint("TOPLEFT", list, "BOTTOMLEFT", 0, -10)
        selectMages:SetText("Select Priests")
        selectMages:SetScript("OnClick", function()
            list:SelectRowByPredicate(function(row)
                return row[4] == "Priest"
            end)
            updateStatus("Selected first Priest")
        end)

        local gotoTop = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
        gotoTop:SetSize(100, 22)
        gotoTop:SetPoint("LEFT", selectMages, "RIGHT", 8, 0)
        gotoTop:SetText("Goto #50")
        gotoTop:SetScript("OnClick", function()
            list:GotoRow(50)
            updateStatus("Moved view to row 50")
        end)

        list:RegisterCallback("SelectionChanged", function(owner)
            local selected = owner:GetSelected()
            updateStatus(string.format("SelectionChanged fired (%d rows)", selected and #selected or 0))
        end, list)

        list:RegisterCallback("LeftMouseClick", function(owner, visibleRow)
            local row = owner:GetDataView()[visibleRow]
            if row then
                updateStatus("Left click on " .. tostring(row[2]))
            end
        end, list)

        list:RegisterCallback("RightMouseClick", function(owner, visibleRow)
            local row = owner:GetDataView()[visibleRow]
            if row then
                updateStatus("Right click on " .. tostring(row[2]))
            end
        end, list)

        local rows = Data.GetCallbackRows()
        for i = 1, #rows do
            list:AddData(rows[i])
        end
        list:UpdateView()
        updateStatus("Ready")

        return frame
    end,
})

