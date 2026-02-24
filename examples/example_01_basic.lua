local addonName, AddonNS = ...
local WowList = LibStub("WowList-1.5")
local GL = LibStub("MyLibrary_GUI")

local NS = AddonNS.WowListExamples
local Data = NS.SharedData

NS:RegisterExample("example_01_basic", {
    title = "01 Basic",
    description = "Minimal list without sorting: CreateNew + AddData + UpdateView.",
    build = function(self)
        local frame = self:CreateExampleFrame("Basic", "WowList Example 01 - Basic", 760, 480)
        local container = CreateFrame("Frame", nil, frame)
        container:SetPoint("TOPLEFT", frame.Inset, "TOPLEFT", 10, -10)
        container:SetPoint("BOTTOMRIGHT", frame.Inset, "BOTTOMRIGHT", -10, 10)

        local info = GL.CreateFontString(container, nil, "ARTWORK",
            "Minimal usage with three columns and single selection (no sortFunction).", "TOPLEFT", container, "TOPLEFT",
            4, -4)
        info:SetTextColor(0.9, 0.9, 0.9, 1)

        local list = WowList:CreateNew(addonName .. "_Example01List", {
            rows = 12,
            height = 300,
            columns = {
                { name = "Name", width = 220 },
                { name = "Class", width = 180 },
                { name = "Item Level", width = 120 },
            },
        }, container)
        list:SetPoint("TOPLEFT", info, "BOTTOMLEFT", 0, -10)
        list:SetMultiSelection(false)

        local rows = Data.GetBasicRows()
        for i = 1, #rows do
            list:AddData(rows[i])
        end
        list:UpdateView()

        return frame
    end,
})
