# MyLibrary_GUI

WoW addon library package containing:

- `MyLibrary_GUI` (general GUI helpers)
- `WowList-1.5` (scrollable, sortable, filterable multi-column list widget)

## Documentation

For loading instructions, usage patterns, and full `WowList-1.5` API details, see:

- [WowList-1.5.md](WowList-1.5.md)

## Examples

Examples are implemented in the `examples/` directory and are available when this project is loaded directly as an addon.
Open the examples menu from the Addon Compartment menu (top-right addon button area), then click `MyLibrary_GUI`.

![Menu image](https://raw.githubusercontent.com/MyGamesDevelopmentAcc/MyLibrary_GUI/main/.previews/menu.png)

### 01 Basic

Source file: [`examples/example_01_basic.lua`](examples/example_01_basic.lua)

What it shows:
- Small, minimal list setup.
- Basic row insertion and view refresh.
- Single-selection behavior with no sorting hooks.

Screenshot placeholder:
![Example 1 image](https://raw.githubusercontent.com/MyGamesDevelopmentAcc/MyLibrary_GUI/main/.previews/1.png)

### 02 Sorting

Source file: [`examples/example_02_sorting.lua`](examples/example_02_sorting.lua)

What it shows:
- Header-click sorting with per-column comparators.
- External/manual sorting through direct `Sort(...)` actions.
- Data reload flow with sorting preserved by user action.

Screenshot placeholder:
![Example 2 image](https://raw.githubusercontent.com/MyGamesDevelopmentAcc/MyLibrary_GUI/main/.previews/2.png)

### 03 Filtering (TradeChat Style)

Source file: [`examples/example_03_filtering_tradechat.lua`](examples/example_03_filtering_tradechat.lua)

What it shows:
- Text search filtering across multiple fields.
- Named filter pattern (`AddFilter`) driven by UI input.
- Visible-count behavior while filters are active.

Screenshot placeholder:
![Example 3 image](https://raw.githubusercontent.com/MyGamesDevelopmentAcc/MyLibrary_GUI/main/.previews/3.png)

### 04 Selection and Callbacks

Source file: [`examples/example_04_selection_callbacks.lua`](examples/example_04_selection_callbacks.lua)

What it shows:
- Multi-selection interactions.
- Callback events (`SelectionChanged`, mouse click callbacks).
- Programmatic selection and row navigation helpers.

Screenshot placeholder:
![Example 4 image](https://raw.githubusercontent.com/MyGamesDevelopmentAcc/MyLibrary_GUI/main/.previews/4.png)

### 05 Texture Health Status

Source file: [`examples/example_05_texture_health_status.lua`](examples/example_05_texture_health_status.lua)

What it shows:
- MyArenaLog-style texture layering in a `WowList` row.
- Health/damage/heal/absorb bar overlays in a dedicated bar region.
- Non-overlapping percentage text and in-frame color legend. (overlapping is of course possible as well)

Screenshot placeholder:
![Example 5 image](https://raw.githubusercontent.com/MyGamesDevelopmentAcc/MyLibrary_GUI/main/.previews/5.png)

### 06 Advanced Coloring

Source file: [`examples/example_06_advanced_coloring.lua`](examples/example_06_advanced_coloring.lua)

What it shows:
- Strong conditional row and cell coloring by severity/value.
- Combined sorting, filtering, and hover tooltip behavior.
- Overlay highlighting patterns for high-signal rows.

Screenshot placeholder:
![Example 6 image](https://raw.githubusercontent.com/MyGamesDevelopmentAcc/MyLibrary_GUI/main/.previews/6.png)

### 07 Performance (25,000 Rows)

Source file: [`examples/example_07_perf_25000.lua`](examples/example_07_perf_25000.lua)

What it shows:
- Large dataset handling (`25,000` rows) with deterministic data generation.
- Manual regenerate and refresh actions.
- Filtering and sorting on high-volume data plus basic timing/row-count stats.

Screenshot placeholder:
![Example 7 image](https://raw.githubusercontent.com/MyGamesDevelopmentAcc/MyLibrary_GUI/main/.previews/7.png)
