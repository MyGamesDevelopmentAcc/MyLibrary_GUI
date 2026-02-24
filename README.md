# MyLibrary_GUI

WoW addon library package containing:

- `MyLibrary_GUI` (general GUI helpers)
- `WowList-1.5` (scrollable, sortable, filterable multi-column list widget)

## Files

- `MyLibrary_GUI.lua`: Core helper library.
- `WowList-1.5.lua`: List widget library.
- `WowList-1.5.md`: Full `WowList-1.5` documentation with API and sample usage.
- `gui.xml`: Library load order.

## Load Order

The libraries are loaded through `gui.xml`:

1. `libs/LibStub/LibStub.lua`
2. `MyLibrary_GUI.lua`
3. `WowList-1.5.lua`

Make sure your addon loads `gui.xml` (or equivalent order in `.toc`) before calling `LibStub("MyLibrary_GUI")` or `LibStub("WowList-1.5")`.

## Quick Start (`WowList-1.5`)

```lua
local WowList = LibStub("WowList-1.5")

local list = WowList:CreateNew("ExampleList", {
    height = 200,
    rows = 8,
    columns = {
        { name = "Name", width = 160, sortFunction = function(a, b) return tostring(a) < tostring(b) end },
        { name = "Role", width = 120 },
        { name = "Score", width = 80, sortFunction = function(a, b) return (tonumber(a) or 0) < (tonumber(b) or 0) end },
    },
}, UIParent)

list:SetPoint("CENTER")
list:AddData({"Thrall", "DPS", 95})
list:AddData({"Jaina", "DPS", 99})
list:UpdateView()
```

For complete API details, events, and advanced examples, see:

- [WowList-1.5.md](WowList-1.5.md)
