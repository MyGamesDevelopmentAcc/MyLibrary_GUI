local libName = "WowList-1.5";
local MAJOR, MINOR = libName, 1

--- @class WowList
local WowList, oldminor = LibStub:NewLibrary(MAJOR, MINOR);
if not WowList then return end

local GL = LibStub("MyLibrary_GUI");

local WL = {};
---@class WowListFrame : Frame
local WowListFrame = {}

WL.unselectedBackdrop = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    tile = true,
    tileSize = 32,
    edgeSize = 20,
    insets = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0
    }
}
WL.unselectedDarkBackdrop = {
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
    tile = true,
    tileSize = 32,
    edgeSize = 20,
    insets = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0
    }
}
WL.selectedBackdrop = {
    bgFile = "Interface\\Buttons\\UI-Listbox-Highlight",
    tile = false,
    tileSize = 32,
    edgeSize = 20,
    insets = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0
    }
}
WL.titleBackdrop = {
    bgFile = "Interface\\Buttons\\UI-Listbox-Highlight",
    tile = false,
    tileSize = 32,
    edgeSize = 20,
    insets = {
        left = 0,
        right = 0,
        top = 0,
        bottom = 0
    }
}

local MergeSort = {}
function MergeSort:Sort(A, compare)
    local p = 1;
    local r = #A;
    if p < r then
        local q = math.floor((p + r) / 2)
        self:MergeSort(A, p, q, compare)
        self:MergeSort(A, q + 1, r, compare)
        self:Merge(A, p, q, r, compare)
    end
end

function MergeSort:MergeSort(A, p, r, compare)
    if p < r then
        local q = math.floor((p + r) / 2)
        self:MergeSort(A, p, q, compare)
        self:MergeSort(A, q + 1, r, compare)
        self:Merge(A, p, q, r, compare)
    end
end

-- merge an array split from p-q, q-r
function MergeSort:Merge(A, p, q, r, compare)
    local n1 = q - p + 1
    local n2 = r - q
    local left = {}
    local right = {}

    for i = 1, n1 do
        left[i] = A[p + i - 1]
    end
    for i = 1, n2 do
        right[i] = A[q + i]
    end

    left[n1 + 1] = math.huge
    right[n2 + 1] = math.huge

    local i = 1
    local j = 1
    local resp;
    for k = p, r do
        if right[j] == math.huge then
            resp = false;
        elseif left[i] == math.huge then
            resp = true;
        else
            resp = compare(right[j], left[i]);
        end
        if resp then
            A[k] = right[j]
            j = j + 1
        else
            A[k] = left[i]
            i = i + 1
        end
    end
end

---
---@param name string
---@param config table
---@param parentFrame Frame
---@return WowListFrame
function WowList:CreateNew(name, config, parentFrame)
    return WL:CreateNew(name, config, parentFrame);
end

---
---@param name? string
---@param config table
---@param parentFrame Frame
---@return WowListFrame
function WL:CreateNew(name, config, parentFrame)
    local wowListFrame = CreateFrame("Frame", name, parentFrame);


    wowListFrame:SetScript("OnShow",
        function(self)
            self:UpdateView();
        end);

    wowListFrame.name = name;


    wowListFrame.rowSize = config.height / (config.rows + 1);
    wowListFrame.height = config.height;
    WL.CreateModel(wowListFrame, config);


    WowListFrame:Embed(wowListFrame); ---@cast wowListFrame WowListFrame
    return wowListFrame;
end

function WL.CreateModel(frame, config)
    frame.view = {};
    frame.rows = config.rows
    frame.columns = #config.columns
    frame.config = config;
    frame.selected = {};
    frame.filters = {};
    frame.options = { singleSelect = false };
    frame.defultRowsColor = { 1, 1, 1, 1 };
    Mixin(frame, EventRegistry);
    frame:EnableMouse(true);
    frame:EnableMouseWheel(true)
    frame:SetScript("OnMouseWheel", function(self, delta)
        local slider = frame.view.slider;
        local minValue, maxValue = slider:GetMinMaxValues()
        if slider:GetValue() - delta >= minValue and slider:GetValue() - delta <= maxValue then
            slider:SetValue(slider:GetValue() - delta);
        end
    end)
    local dist = 0;
    for x = 1, frame.columns do
        dist = dist + config.columns[x].width;
    end
    frame:SetWidth(dist + 14);
    frame.innerWidth = dist;

    local height = frame.height;
    frame:SetHeight(height);
    WL.CreateColumns(frame, config)
    WL.CreateSlider(frame, height);
    WL.CreateCells(frame, config);
    frame.data = {};
    frame.dataView = {};
end

local function getObjName(objName, dim1, dim2)
    return objName .. (dim1 and "_" or "") .. (dim1 or "") .. (dim2 and "_" or "") .. (dim2 or "");
end

function WL.CreateColumns(mainFrame, config)
    local dist = 0;
    for x = 1, mainFrame.columns do
        local columnHeaderButton = CreateFrame("Frame", nil, mainFrame, BackdropTemplateMixin and "BackdropTemplate");
        --columnHeaderButton:Raise()
        GL.CreateFontString(columnHeaderButton, nil, "ARTWORK", config.columns[x].name, "LEFT",
            columnHeaderButton, "LEFT", 0, 0);


        columnHeaderButton:SetFrameLevel(mainFrame:GetFrameLevel() + x)
        columnHeaderButton:SetWidth(config.columns[x].width == 0 and 1 or config.columns[x].width);
        columnHeaderButton:SetHeight(mainFrame.rowSize); --TODO: Arrange this maching the text size;
        columnHeaderButton:SetBackdrop(WL.unselectedBackdrop)
        columnHeaderButton:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", dist, 0);
        columnHeaderButton:EnableMouse(true);

        if config.columns[x].sortFunction then
            local sortFunction = config.columns[x].sortFunction;
            local sortReversedFunction = function(a, b)
                if sortFunction(a, b) == sortFunction(b, a) then
                    return false;
                else
                    return not sortFunction(a, b);
                end
            end
            columnHeaderButton:SetScript("OnEnter",
                function(self)
                    self:SetBackdrop(WL.selectedBackdrop)
                end)
            columnHeaderButton:SetScript("OnLeave",
                function(self)
                    self:SetBackdrop(WL.unselectedBackdrop)
                end)
            columnHeaderButton:SetScript("OnMouseDown",
                function(self)
                    if not self.sortOrder or mainFrame.lastSorted ~= x then
                        mainFrame:Sort(x, sortFunction)
                        self.sortOrder = true;
                    else
                        mainFrame:Sort(x, sortReversedFunction);
                        self.sortOrder = false;
                    end
                    mainFrame:UpdateView()
                    mainFrame.lastSorted = x;
                end)
        end
        dist = dist + config.columns[x].width;
    end
end

function WL.CreateSlider(frame, height)
    local view = frame.view;
    view["slider"] = CreateFrame("Slider", frame.name .. "_slider", frame, "OptionsSliderTemplate");
    local slider = view["slider"];
    slider:SetWidth(10)
    slider:SetHeight(height);
    slider:SetPoint('TOPRIGHT', frame, "TOPRIGHT", 0, 0);
    slider:SetOrientation('VERTICAL')
    getglobal(slider:GetName() .. "Text"):SetText("");
    getglobal(slider:GetName() .. "Low"):SetText('');
    getglobal(slider:GetName() .. "High"):SetText('');
    slider:SetMinMaxValues(0, 0)
    slider:SetValueStep(1)
    slider:SetValue(0)
    slider:SetScript("OnValueChanged", function()
        frame:SliderValueChanged();
    end)
end

function WL.CreateCells(mainFrame, config)
    local view = mainFrame.view;
    local dist = 0;


    for y = 1, config.rows do
        -- print("hej")
        local rowButton = CreateFrame("Frame", mainFrame.name .. getObjName("rowButton", y), mainFrame,
            BackdropTemplateMixin and "BackdropTemplate");
        view[getObjName("rowButton", y)] = rowButton;
        local dist = 0;

        rowButton.dataNr = y;
        rowButton.idNr = y;
        for x = 1, #config.columns do
            local cellFrame = CreateFrame("Frame", nil, rowButton);
            view[getObjName("cellFrame", x, y)] = cellFrame;

            cellFrame:SetFrameLevel(rowButton:GetFrameLevel() + x)
            cellFrame:SetWidth(config.columns[x].width > 0 and config.columns[x].width or 1);
            cellFrame:SetHeight(mainFrame.rowSize);
            cellFrame:SetPoint("LEFT", rowButton, "LEFT", dist, 0);

            local cellFontStringName = getObjName("cellFontString", x, y);
            local cellFontString = GL.CreateFontString(mainFrame, mainFrame.name .. cellFontStringName,
                "ARTWORK", cellFontStringName);

            view[getObjName("cellFontString", x, y)] = cellFontString;
            cellFontString:SetTextColor(unpack(mainFrame.defultRowsColor));
            cellFontString:SetWidth(config.columns[x].width)
            cellFontString:SetHeight(mainFrame.rowSize)
            cellFontString:SetJustifyH("LEFT")
            cellFontString:SetParent(cellFrame);
            cellFontString:SetPoint("LEFT", cellFrame, "LEFT", 0, 0);



            local cellTextureName = getObjName("cellTexture", x, y);
            local cellTexture = GL.CreateTexture(mainFrame,
                mainFrame.name .. cellTextureName, "ARTWORK", config.columns[x].width,
                mainFrame.rowSize);
            view[cellTextureName] = cellTexture
            cellTexture:Hide();
            cellTexture:SetParent(cellFrame);
            cellTexture:SetPoint("LEFT", cellFrame, "LEFT", 0, 0);
            cellTexture.baseXoffset = dist;
            dist = dist + config.columns[x].width;

            mainFrame = mainFrame;
            local cellOnEnterFunction = config.columns[x].cellOnEnterFunction;
            local cellOnLeaveFunction = config.columns[x].cellOnLeaveFunction;
            if (cellOnEnterFunction) then
                cellFrame:SetScript("OnEnter",
                    function(self)
                        cellOnEnterFunction(mainFrame.dataView[rowButton.dataNr][x], mainFrame.dataView[rowButton.dataNr
                        ], x);
                    end)
            end

            if (cellOnLeaveFunction) then
                cellFrame:SetScript("OnLeave",
                    function(self)
                        cellOnLeaveFunction(mainFrame.dataView[rowButton.dataNr][x], mainFrame.dataView[rowButton.dataNr
                        ], x);
                    end)
            end
            cellFrame:SetMouseClickEnabled(false);
        end
        rowButton:SetWidth(mainFrame.innerWidth);
        rowButton:SetHeight(mainFrame.rowSize); --TODO: Arrange this maching the text size;
        rowButton:SetBackdrop(WL.unselectedBackdrop)

        rowButton:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 0, -mainFrame.rowSize * y);

        rowButton:EnableMouse(true);



        rowButton:SetScript("OnEnter",
            function(self)
                local parent = self:GetParent()
                if parent.buttonOnEnterFunction then parent.buttonOnEnterFunction(parent.dataView[self.dataNr]) end

                if not parent.dataView[self.dataNr].isSelected then
                    self:SetBackdrop(WL.unselectedDarkBackdrop)
                end
            end)
        rowButton:SetScript("OnLeave",
            function(self)
                local parent = self:GetParent()
                if parent.buttonOnLeaveFunction then parent.buttonOnLeaveFunction(parent.dataView[self.dataNr]) end

                if parent.dataView[self.dataNr] and not parent.dataView[self.dataNr].isSelected then
                    self:SetBackdrop(WL.unselectedBackdrop)
                end
            end)
        rowButton:SetScript("OnMouseDown",
            function(self, button)
                local parent = self:GetParent()
                if parent.buttonOnMouseDownFunction then
                    parent.buttonOnMouseDownFunction(parent.dataView[self.dataNr])
                    return
                end
                local shiftClick = not IsControlKeyDown() and IsShiftKeyDown();
                local ctrlClick = IsControlKeyDown() and not IsShiftKeyDown();
                local mainFrame = self:GetParent()
                local singleSelection = self:GetParent().options.singleSelect;
                local isSelected = self:GetParent().dataView[self.dataNr].isSelected;
                --add local parent!
                if button == "LeftButton" then
                    if ctrlClick and not singleSelection then
                        if not isSelected then
                            self:SetBackdrop(WL.selectedBackdrop);
                            mainFrame.dataView[self.dataNr].isSelected = true;
                            mainFrame.lastSelected = mainFrame.dataView[self.dataNr];
                            mainFrame.lastSelectedId = self.dataNr;
                        else
                            self:SetBackdrop(WL.unselectedDarkBackdrop)
                            mainFrame.dataView[self.dataNr].isSelected = nil;
                            mainFrame.lastSelected = nil;
                        end
                    elseif shiftClick and not singleSelection then
                        if mainFrame.lastSelected == nil then
                            mainFrame.lastSelected = mainFrame.dataView[self.dataNr];
                            mainFrame.lastSelectedId = self.dataNr;
                        end
                        if mainFrame.lastSelected ~= mainFrame.dataView[mainFrame.lastSelectedId] then
                            for i = 1, #mainFrame.dataView do
                                if mainFrame.dataView[i] == mainFrame.lastSelected then
                                    mainFrame.lastSelectedId = i;
                                    break;
                                end
                            end
                        end
                        if mainFrame.lastSelected == mainFrame.dataView[mainFrame.lastSelectedId] then
                            local order = 1;
                            if mainFrame.lastSelectedId > self.dataNr then order = -1; end

                            for i = mainFrame.lastSelectedId, self.dataNr, order do
                                if not mainFrame:CheckFilters(mainFrame.dataView[i]) then
                                    mainFrame.dataView[i].isSelected = true;
                                end
                            end
                        end
                        local m = mainFrame.rows;
                        if #mainFrame.dataView < m then m = #mainFrame.dataView end
                        for y = 1, m do
                            if mainFrame.dataView[mainFrame.view[getObjName("rowButton", y)].dataNr].isSelected then
                                mainFrame.view[getObjName("rowButton", y)]:SetBackdrop(WL.selectedBackdrop)
                            end
                        end
                    else
                        --self:GetParent:UnselectAll();
                        for i = 1, #mainFrame.dataView do
                            mainFrame.dataView[i].isSelected = nil;
                        end
                        for h = 1, mainFrame.rows do
                            if h ~= self.idNr then
                                mainFrame.view[getObjName("rowButton", h)]:SetBackdrop(WL.unselectedBackdrop)
                            end
                        end

                        if not isSelected then
                            self:SetBackdrop(WL.selectedBackdrop);
                            mainFrame.dataView[self.dataNr].isSelected = true;
                            mainFrame.lastSelected = mainFrame.dataView[self.dataNr];
                            mainFrame.lastSelectedId = self.dataNr;
                        else
                            self:SetBackdrop(WL.unselectedDarkBackdrop)
                            mainFrame.dataView[self.dataNr].isSelected = nil;
                            mainFrame.lastSelected = nil;
                        end
                    end
                elseif button == "RightButton" then
                    if not isSelected then
                        for i = 1, #mainFrame.dataView do
                            mainFrame.dataView[i].isSelected = nil;
                        end
                        for y = 1, mainFrame.rows do
                            if y ~= self.idNr then
                                mainFrame.view[getObjName("rowButton", y)]:SetBackdrop(WL.unselectedBackdrop)
                            end
                        end
                        self:SetBackdrop(WL.selectedBackdrop);
                        mainFrame.dataView[self.dataNr].isSelected = true;
                        mainFrame.lastSelected = mainFrame.dataView[self.dataNr];
                        mainFrame.lastSelectedId = self.dataNr;
                    end
                end

                if button == "LeftButton" then
                    mainFrame:TriggerEvent("SelectionChanged");
                    mainFrame:TriggerEvent("LeftMouseClick", self.dataNr);
                elseif button == "MiddleButton" then
                    mainFrame:TriggerEvent("MiddleMouseClick", self.dataNr)
                elseif button == "RightButton" then
                    mainFrame:TriggerEvent("RightMouseClick", self.dataNr)
                end
            end)
    end
end

function WowListFrame:SliderValueChanged()
    if (self.view["slider"]:GetValue() ~= self.view["slider"].lastValue) then
        self.view["slider"].lastValue = self.view["slider"]:GetValue();
        self:UpdateView();
        --TODO:Fire slider value changed
    end
end

function WowListFrame:AddData(data, key)
    --assert(#data==#self.columns,"Added data must equal number of columns! Got "..#data..", expected "..#self.columns); -- ignoring as when data can be nil at the end, which woulc casue this to pop. We allow nils?...
    assert(data.isSelected == nil, "Data cannot contain field 'isSelected' as it is a restricted field."); --TODO maybe change to check if field is exists and then if its boolean leave it be.as this might be usefull for copying betwwen lists.
    data.isSelected = nil;
    table.insert(self.data, data);
    if self:CheckFilters(data) then
        table.insert(self.dataView, data);
    end
end

function WowListFrame:RemoveData(data, key)
    assert(#data == #self.columns, "Removed data must equal number of columns!");
    for i, v in ipairs(self.data) do
        if v == data then
            wipe(data);
            table.remove(self.data, i);

            break;
        end
    end
end

function WowListFrame:GetSelected()
    local retData = {};
    for i = 1, #self.dataView do
        if self.dataView[i].isSelected then
            table.insert(retData, self.dataView[i]);
        end
    end

    if #retData > 0 then return retData else return nil; end
end

function WowListFrame:GetLastSelected()
    return self.lastSelected;
end

function WowListFrame:SetData(data)
    self.data = data;
end

function WowListFrame:GetData(nr)
    return self.data[nr];
end

function WowListFrame:SetMultiSelection(val)
    self.options = { singleSelect = not val };
end

function WowListFrame:RemoveAll()
    --WL.ClearTable(self.data)
    wipe(self.data);
    wipe(self.dataView);
    self.lastSelected = nil;
    --self.data={};
    self:UpdateView();
end

function WowListFrame:GotoRow(number)
    local number = number - 1;
    self.view["slider"]:SetValue(number > #self.dataView and #self.dataView or number);
    self.view["slider"].lastValue = self.view["slider"]:GetValue();
    -- print(self.view["slider"].lastValue)
    self:UpdateView();
end

function WowListFrame:SelectRow(number)
    self.dataView[number].isSelected = true;
    self.lastSelected = self.dataView[number];
    self.lastSelectedId = number;
    for h = 1, self.rows do
        local row = self.view[getObjName("rowButton", h)];
        if (self.dataView[row.dataNr]) then
            row:SetBackdrop(self.dataView[row.dataNr].isSelected and WL.selectedBackdrop or WL.unselectedBackdrop)
        end
    end
end

function WowListFrame:GetSliderValue()
    return self.view["slider"].lastValue or 0;
end

function WowListFrame:Sort(column, compareFunction)
    MergeSort:Sort(self.data, function(a, b) return compareFunction(a[column], b[column]) end)
    self:UpdateDataView();
end

function WowListFrame:GetDataView()
    return self.dataView;
end

function WowListFrame:UpdateDataView()
    self.dataView = {};
    for i = 1, #self.data do
        if self:CheckFilters(self.data[i]) then
            table.insert(self.dataView, self.data[i]);
        end
    end
end

function WowListFrame:UpdateView()
    local line;
    local lineplusoffset;
    if not self.dataView then self:UpdateDataView(); end

    local slider = self.view["slider"];
    local dataView = self.dataView;

    if (#dataView > self.rows) then
        slider:SetMinMaxValues(0, #dataView - self.rows)
        slider:Enable()
        slider:Show();
    else
        slider:SetMinMaxValues(0, 0)
        slider:Disable();
        slider:Hide();
    end


    local view = self.view;

    lineplusoffset = math.floor(slider:GetValue());
    for y = 1, self.rows do
        local rowButton = view[getObjName("rowButton", y)]
        lineplusoffset = lineplusoffset + 1;
        if lineplusoffset <= #dataView then
            for x = 1, self.columns do
                local cellData = dataView[lineplusoffset][x]
                local cellFontString = view[getObjName("cellFontString", x, y)];
                local cellTexture = view[getObjName("cellTexture", x, y)];
                local cellFrame = view[getObjName("cellFrame", x, y)];
                if (self.config.columns[x].textureDisplayFunction) then
                    local texture, color, width, height, xoffset = self.config.columns[x].textureDisplayFunction(
                        cellData
                        , dataView[lineplusoffset], x, y);
                    if (not texture and not color or width and width == 0) then
                        cellTexture:Hide();
                    else
                        if texture then
                            cellTexture:SetTexture(texture);
                            if color then
                                cellTexture:SetVertexColor(unpack(color))
                            end
                        else
                            cellTexture:SetColorTexture(unpack(color));
                        end

                        --
                        if width then cellTexture:SetWidth(width); end
                        if height then cellTexture:SetHeight(height); end
                        -------------
                        if xoffset then
                            cellTexture:SetPoint("LEFT", cellFrame, "LEFT", xoffset, 0);
                        end
                        cellTexture:Show()
                    end
                end
                local name, color --todo remove this mock
                if self.config.columns[x].displayFunction then
                    name, color = self.config.columns[x].displayFunction(cellData, dataView[lineplusoffset], x, y);
                elseif type(cellData) == "table" then -- todo: haven't used for a long time, don't remember use case, maybe remove?
                    if cellData.name ~= nil then
                        name = tostring(dataView[lineplusoffset][x].name)
                    elseif cellData.func ~= nil then
                        name = cellData.func(lineplusoffset, y, cellData.data);
                    end
                    if cellData.color ~= nil then
                        color = cellData.color;
                    end
                elseif type(cellData) == "function" then
                    name = cellData(lineplusoffset, y);
                    cellFontString:SetTextColor(unpack(self.defultRowsColor));
                else
                    name = cellData;
                end

                if not color then
                    cellFontString:SetTextColor(unpack(self.defultRowsColor));
                else
                    cellFontString:SetTextColor(unpack(color));
                end
                cellFontString:SetText(name or "");
            end
            rowButton.dataNr = lineplusoffset;
            rowButton:Show();
            if dataView[lineplusoffset].isSelected then
                rowButton:SetBackdrop(WL.selectedBackdrop)
            else
                rowButton:SetBackdrop(WL.unselectedBackdrop)
            end
        else
            rowButton:Hide();
        end
    end
end

function WowListFrame:CheckFilters(data)
    for name, v in pairs(self.filters) do
        if not v(data) then
            return false
        end
    end
    return true;
end

function WowListFrame:AddFilter(name, filterFunc)
    self.filters[name] = filterFunc;
    self:UpdateDataView();
end

function WowListFrame:RemoveFilter(name)
    self.filters[name] = nil;
    self:UpdateDataView();
end

function WowListFrame:RemoveAllFilters()
    for i, v in pairs(self.filters) do
        self.filters[i] = nil;
        self:UpdateDataView();
    end
end

function WowListFrame:SetButtonOnEnterFunction(func)
    assert(type(func) == "function", libName .. ":SetButtonOnEnterFunction requires function as a second parameter")
    self.buttonOnEnterFunction = func;
end

function WowListFrame:SetButtonOnLeaveFunction(func)
    assert(type(func) == "function", libName .. ":SetButtonOnLeaveFunction requires function as a second parameter")
    self.buttonOnLeaveFunction = func;
end

function WowListFrame:SetButtonOnMouseDownFunction(func)
    assert(type(func) == "function", libName .. ":SetButtonOnMouseDownFunction requires function as a second parameter")
    self.buttonOnMouseDownFunction = func;
end

local mixins = {
    "CheckFilters",
    "AddFilter",
    "RemoveFilter",
    "RemoveAllFilters",
    "SetColumnSortFunction",
    "SetColumnDisplayFunction",
    "SetColumnTextureDisplayFunction",
    "SetButtonOnEnterFunction",
    "SetButtonOnLeaveFunction",
    "SetButtonOnMouseDownFunction",
    "Sort",
    "CreateModel",
    "SliderValueChanged",
    "GetSliderValue",
    -- "ChangeButtonState",
    "UpdateDataView",
    "UpdateView",
    "AddData",
    -- "GetKeySet",
    "SetData",
    "GetSelected",
    "GetLastSelected",
    --"GetDataByKey",
    "SetMultiSelection",
    "GetData",
    "RemoveAll",
    "RemoveData",
    "GotoRow",
    "GetDataView",
    "SelectRow"
}

---
---@param target Frame
---@return WowListFrame
function WowListFrame:Embed(target)
    for k, v in pairs(mixins) do
        target[v] = self[v]
    end
    return target
end
