# WowList-1.5

`WowList-1.5` is a LibStub-based table/list UI for WoW addons.
It renders rows and columns, supports sorting, filtering, selection, and callback events.

## Load Order

Your `.toc`/XML must load these files in this order:

1. `libs/LibStub/LibStub.lua`
2. `MyLibrary_GUI.lua`
3. `WowList-1.5.lua`

`gui.xml` in this addon already does that so you can also use .pkgmeta to import:

```
externals:
  Libs/MyLibrary_GUI:
    url: https://github.com/MyGamesDevelopmentAcc/MyLibrary_GUI.git
    tag: latest
```

and then add to your toc `Libs/MyLibrary_GUI/gui.xml`.

## Getting The Library

```lua
local WowList = LibStub("WowList-1.5")
```

## CreateNew

```lua
local list = WowList:CreateNew(name, config, parentFrame)
```

Arguments:

- `name` (`string|nil`): Global frame name prefix used for child frames.
- `config` (`table`): List layout/settings (see below).
- `parentFrame` (`Frame`): Parent container frame.

Returns:

- `WowListFrame` (Frame with embedded list methods).

## Config Schema

Required keys:

- `height` (`number`): Total list height.
- `rows` (`number`): Number of visible data rows (header row is added automatically).
- `columns` (`table[]`): Ordered column definitions.

Column definition keys:

- `name` (`string`): Header text.
- `width` (`number`): Column width in pixels.
- `sortFunction` (`function(a, b) -> boolean`, optional): Comparator for this column; clicking header toggles asc/desc.
- `displayFunction` (`function(cellData, rowData, columnIndex, visibleRowIndex) -> text, color?`, optional):
  returns cell text and optional RGBA color.
- `textureDisplayFunction` (`function(cellData, rowData, columnIndex, visibleRowIndex) -> texturePath?, color?, width?, height?, xoffset?`, optional):
  controls texture overlay in the cell.
- `cellOnEnterFunction` (`function(cellData, rowData, columnIndex)`, optional): Cell hover enter.
- `cellOnLeaveFunction` (`function(cellData, rowData, columnIndex)`, optional): Cell hover leave.

## Data Model

Each row is an array-like table where index `1..#columns` maps to columns.

Example row:

```lua
{ "Thrall", "Shaman", 489 }
```

Notes:

- Field `isSelected` is reserved by the library and must not be set before `AddData`.
- `data` is the full backing array.
- `dataView` is the currently filtered/sorted view used by rendering and selection.

## Events (CallbackRegistryMixin)

`WowListFrame` mixes in `CallbackRegistryMixin` and enables undefined event names, so you can register directly:

```lua
list:RegisterCallback("SelectionChanged", function(owner) ... end, list)
```

Built-in events triggered by the list:

- `SelectionChanged`
- `LeftMouseClick` (arg: visible row index)
- `MiddleMouseClick` (arg: visible row index)
- `RightMouseClick` (arg: visible row index)

Callback signature:

- Function callbacks receive `owner` as first arg, then event payload args.

## Public Methods

- `AddData(row)`: Append one row (if it passes active filters).
- `RemoveData(row)`: Remove row by identity from backing data.
- `SetData(rows)`: Replace backing data table.
- `GetData(index)`: Return backing row by 1-based index.
- `GetDataView()`: Return current filtered view.
- `UpdateDataView()`: Rebuild filtered view from `data`.
- `UpdateView()`: Redraw currently visible rows.
- `RemoveAll()`: Clear data and selection.
- `Sort(columnIndex, compareFn)`: Sort backing data by column.
- `AddFilter(name, filterFn)`: Add/replace named filter; refreshes view model.
- `RemoveFilter(name)`: Remove named filter; refreshes view model.
- `RemoveAllFilters()`: Remove all filters.
- `GetSelected()`: Return array of selected rows, or `nil`.
- `GetLastSelected()`: Return last selected row, or `nil`.
- `SetMultiSelection(enabled)`: `true` enables multi-select; `false` single-select.
- `SelectRow(visibleIndex)`: Select a row in `dataView`.
- `SelectRowByPredicate(predicateFn)`: Select first row where predicate returns true.
- `GotoRow(visibleIndex)`: Scroll so that row is at top.
- `GetSliderValue()`: Current vertical offset.
- `SetButtonOnEnterFunction(fn)`: Row `OnEnter`.
- `SetButtonOnLeaveFunction(fn)`: Row `OnLeave`.
- `SetButtonOnMouseDownFunction(fn, doNotOverride)`: Row mouse handler.
- `SetButtonOnReceiveDragFunction(fn)`: Row drag-receive handler.

## Sample Usage

```lua
local WowList = LibStub("WowList-1.5")

local demoFrame = CreateFrame("Frame", "MyDemoListHost", UIParent, "BackdropTemplate")
demoFrame:SetSize(420, 220)
demoFrame:SetPoint("CENTER")
demoFrame:Show()

local list = WowList:CreateNew("MyDemoWowList", {
    height = 200,
    rows = 8,
    columns = {
        {
            name = "Name",
            width = 170,
            sortFunction = function(a, b)
                return tostring(a) < tostring(b)
            end,
        },
        {
            name = "Class",
            width = 120,
            sortFunction = function(a, b)
                return tostring(a) < tostring(b)
            end,
            displayFunction = function(cellData)
                return cellData
            end,
        },
        {
            name = "iLvl",
            width = 80,
            sortFunction = function(a, b)
                return (tonumber(a) or 0) < (tonumber(b) or 0)
            end,
            displayFunction = function(cellData)
                local ilvl = tonumber(cellData) or 0
                if ilvl >= 500 then
                    return ilvl, {0.2, 1.0, 0.2, 1.0}
                end
                return ilvl, {1.0, 1.0, 1.0, 1.0}
            end,
        },
    },
}, demoFrame)

list:SetPoint("TOPLEFT", demoFrame, "TOPLEFT", 10, -10)
list:SetMultiSelection(true)

-- Optional row hover hooks
list:SetButtonOnEnterFunction(function(row)
    -- row is a dataView row
end)

-- Callback events from internal TriggerEvent calls
list:RegisterCallback("SelectionChanged", function(owner)
    local selected = owner:GetSelected()
    print("Selection changed. Count:", selected and #selected or 0)
end, list)

list:RegisterCallback("RightMouseClick", function(owner, visibleIndex)
    local row = owner:GetDataView()[visibleIndex]
    if row then
        print("Right clicked:", row[1], row[2], row[3])
    end
end, list)

-- Add data rows: each row maps to columns 1..N
list:AddData({"Thrall", "Shaman", 489})
list:AddData({"Jaina", "Mage", 503})
list:AddData({"Anduin", "Priest", 476})
list:AddData({"Valeera", "Rogue", 498})

-- Apply a filter
list:AddFilter("minIlvl", function(row)
    return (tonumber(row[3]) or 0) >= 485
end)

list:UpdateDataView()
list:UpdateView()
```

## Behavioral Notes

- Header clicks only sort if that column has `sortFunction`.
- `RemoveData` removes by table identity (same row object), not by value.
- `GotoRow`/`SelectRow` use indices in `dataView` (filtered/sorted view), not raw `data`.
