local addonName, AddonNS = ...
local WowList = LibStub("WowList-1.5")
local GL = LibStub("MyLibrary_GUI")

local NS = AddonNS.WowListExamples
local Data = NS.SharedData

local function getClassColor(className)
    local classColor = RAID_CLASS_COLORS and RAID_CLASS_COLORS[className]
    if classColor then
        return { classColor.r, classColor.g, classColor.b, 1 }
    end
    return { 0.5, 0.5, 0.5, 1 }
end

NS:RegisterExample("example_05_texture_health_status", {
    title = "05 Health Textures",
    description = "MyArenaLog-style texture overlays: health, damage, heal, absorb.",
    build = function(self)
        local frame = self:CreateExampleFrame("HealthTexture", "WowList Example 05 - Texture Health Status", 980, 560)
        local container = CreateFrame("Frame", nil, frame)
        container:SetPoint("TOPLEFT", frame.Inset, "TOPLEFT", 10, -10)
        container:SetPoint("BOTTOMRIGHT", frame.Inset, "BOTTOMRIGHT", -10, 10)

        local info = GL.CreateFontString(container, nil, "ARTWORK",
            "Overlay bars rendered via textureDisplayFunction in zero-width helper columns.", "TOPLEFT", container,
            "TOPLEFT", 4, -5)
        info:SetTextColor(0.9, 0.9, 0.9, 1)

        local healthBarWidth = 250

        local list = WowList:CreateNew(addonName .. "_Example05List", {
            rows = 15,
            height = 360,
            columns = {
                { name = "Unit", width = 180, sortFunction = function(a, b) return tostring(a) < tostring(b) end },
                { name = "Class", width = 120, sortFunction = function(a, b) return tostring(a) < tostring(b) end },
                {
                    name = "HP",
                    width = 120,
                    sortFunction = function(a, b) return (tonumber(a) or 0) < (tonumber(b) or 0) end,
                    displayFunction = function(cellData, rowData)
                        local current = rowData[3]
                        local max = rowData[4]
                        return string.format("%d / %d", current, max)
                    end,
                },
                {
                    name = "Status Bar",
                    width = healthBarWidth,
                    displayFunction = function(_, rowData)
                        local percent = (rowData[4] > 0) and (rowData[3] / rowData[4] * 100) or 0
                        return string.format("%.1f%%", percent), { 1, 1, 1, 1 }
                    end,
                },
                {
                    name = "",
                    width = 0,
                    textureDisplayFunction = function(_, rowData)
                        local current = rowData[3]
                        local max = rowData[4]
                        if max <= 0 then
                            return
                        end
                        local width = math.max(1, healthBarWidth * current / max)
                        return nil, getClassColor(rowData[2]), width, 16, 0
                    end,
                },
                {
                    name = "",
                    width = 0,
                    textureDisplayFunction = function(_, rowData)
                        local current = rowData[3]
                        local max = rowData[4]
                        local damage = rowData[5]
                        if max <= 0 or damage <= 0 then
                            return
                        end
                        local xoffset = healthBarWidth * current / max
                        local width = math.max(1, healthBarWidth * damage / max)
                        return nil, { 1, 0.1, 0.1, 0.95 }, width, 16, xoffset
                    end,
                },
                {
                    name = "",
                    width = 0,
                    textureDisplayFunction = function(_, rowData)
                        local max = rowData[4]
                        local heal = rowData[6]
                        if max <= 0 or heal <= 0 then
                            return
                        end
                        local width = math.max(1, healthBarWidth * heal / max)
                        return nil, { 0.15, 1, 0.15, 0.65 }, width, 16, 0
                    end,
                },
                {
                    name = "",
                    width = 0,
                    textureDisplayFunction = function(_, rowData)
                        local current = rowData[3]
                        local max = rowData[4]
                        local absorb = rowData[7]
                        if max <= 0 or absorb <= 0 then
                            return
                        end
                        local width = math.max(1, healthBarWidth * absorb / max)
                        local xoffset = math.max(0, healthBarWidth * current / max - width)
                        return nil, { 0.4, 0.8, 1, 0.8 }, width, 16, xoffset
                    end,
                },
            },
        }, container)
        list:SetPoint("TOPLEFT", info, "BOTTOMLEFT", 0, -12)
        list:SetMultiSelection(false)

        local function loadRows(rows)
            list:RemoveAll()
            for i = 1, #rows do
                list:AddData(rows[i])
            end
            list:UpdateView()
        end

        local randomizeButton = CreateFrame("Button", nil, container, "UIPanelButtonTemplate")
        randomizeButton:SetSize(140, 22)
        randomizeButton:SetPoint("TOPLEFT", list, "BOTTOMLEFT", 0, -10)
        randomizeButton:SetText("Refresh Status")
        randomizeButton:SetScript("OnClick", function()
            loadRows(Data.GetHealthStatusRows())
        end)

        loadRows(Data.GetHealthStatusRows())
        return frame
    end,
})
