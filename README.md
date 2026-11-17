# SliceViewerND

### Interactive N-Dimensional Image Viewer for MATLAB

**Version:** 1.2.0  
**Author:** Tianhui (Cindy) Jie  
**Last Updated:** November 17, 2026  
**License:** GNU General Public License v3.0 (GPL-3.0-only)

SliceViewerND is an interactive MATLAB visualization tool for exploring multidimensional image arrays.

It supports synchronized multi-image comparison, independent slice navigation, multidimensional averaging, movable averaging windows, linked orthogonal views, physical aspect-ratio adjustments, and per-image display controls.

Designed for scientific imaging applications, including optical coherence tomography (OCT), microscopy, volumetric imaging, and time-resolved datasets.

---

## What's New in v1.2.0

Version 1.2.0 introduces **multi-image comparison** for viewing any number of N-dimensional datasets side by side, with shared navigation and independent display settings.

- **Multi-image comparison:** Pass a cell array of datasets to display them in automatically arranged panels.
- **Synchronized navigation:** Slice indices, averaging ranges, and orthogonal cross-section positions are shared across datasets.
- **Independent display settings:** Configure separate color limits (CLim), colormaps, and NaN background colors for each dataset.
- **Automatic NaN padding:** Smaller arrays are padded at their high-index edges to accommodate different dataset sizes.
- **Custom image names:** Supply labels through `imageNames`, or use automatically detected input variable names where available.
- **Image selector:** Choose which image's CLim to edit from the toolbar dropdown immediately left of the CLim controls.

All existing single-image navigation and visualization features remain supported.

## Features

### 1. Multi-Image Comparison (New in v1.2.0)

Pass `{A, B, C, ...}` to view multiple real-valued numeric arrays in a tiled layout. The viewer uses a common size based on the largest extent in each dimension and pads smaller datasets with NaNs. Navigation, averaging, orthogonal positioning, and physical aspect-ratio controls are synchronized, while color limits, colormaps, and NaN colors can differ between images.

### 2. N-Dimensional Slice Navigation

- Supports real-valued numeric arrays with three or more dimensions.
- Displays dimensions 1 and 2 as the Y and X image axes.
- Provides an independent navigation slider for every dimension beyond the first two.
- Supports interactive slice selection with integer-index snapping.
- Preserves the selected indices of other dimensions during navigation.
- Allows custom dimension names.

### 3. Keyboard Navigation (New in v1.1.0)

Use the **left and right arrow keys** to navigate any selected position slider by exactly one integer step.

Supported controls:

- **Dimension sliders:** Move backward or forward by one slice.
- **Averaging window-position sliders:** Shift the averaging interval by one index while preserving its width.
- **Orthogonal X/Y location sliders:** Move the cross-sectional location by one pixel.

To use keyboard navigation:

1. Click the slider you want to control.
2. Press **←** to decrease its value by one.
3. Press **→** to increase its value by one.

Each keypress:

- Changes the selected slider value by exactly one integer.
- Moves the visible slider thumb to the new position.
- Updates the displayed images and associated position indicators.
- Preserves unrelated slider values and settings.
- Respects the minimum and maximum limits of the selected slider.

Disabled sliders cannot be navigated using arrow keys.

### 4. Multidimensional Averaging

Each navigable dimension includes an independent averaging toggle.

When averaging is enabled:

- The dimension's slice-selection slider is disabled.
- Data are averaged over a user-defined interval.
- Start and End fields define the averaging range.
- A Window Position slider controls the location of the averaging interval.
- NaN values are excluded using `mean(...,'omitnan')`.

Multiple dimensions can be averaged simultaneously.

### 5. Movable Averaging Windows

Averaging intervals can be shifted interactively without changing their widths.

For example:

```text
Original averaging interval: [10, 20]
Shifted averaging interval:  [30, 40]
```

The averaging window remains within the valid dimension bounds.

**New in v1.1.0:** Click the Window Position slider and use the left/right arrow keys to shift the entire averaging interval by exactly one index.

### 6. Linked Orthogonal Views

Optional orthogonal visualization provides three linked views:

| View | Description |
|------|-------------|
| XY | Main image |
| X–D | Cross-section at the selected Y location |
| Y–D | Cross-section at the selected X location |

The orthogonal dimension **D** can be selected interactively.

Additional features include:

- Independent X and Y cross-sectional location sliders.
- Linked position indicators across views.
- Automatic updates when positions or dimensions change.
- Consistent colormap and color limits across the three views of each image; different images may use different settings.
- Independent image geometry to prevent overlapping views.

**New in v1.1.0:** The X and Y location sliders support one-pixel keyboard navigation using the left/right arrow keys.

### 7. Physical Aspect-Ratio Control

Specify relative physical sample spacing along X, Y, and D using:

```matlab
dimensionRatio = [X Y D];
```

Each view maintains the appropriate physical aspect ratio:

| View | Physical axes |
|------|---------------|
| XY | X : Y |
| X–D | X : D |
| Y–D | D : Y |

The ratios affect visualization geometry without modifying the underlying image data.

Each view is scaled independently, so changing one physical dimension does not unnecessarily alter views that do not contain that dimension.

### 8. Interactive Display Settings

- Adjustable image color limits.
- Custom MATLAB colormaps.
- Independent CLim per dataset, shared across that dataset's XY and orthogonal views.
- Per-dataset colormaps and NaN background colors.
- Image selector for choosing which dataset's CLim to edit.
- Interactive updates without modifying the original data.

---

## Installation

Download `SliceViewerND.m` from this repository.

Add the directory containing the function to your MATLAB path:

```matlab
addpath('/path/to/SliceViewerND')
```

Alternatively, place `SliceViewerND.m` in your current MATLAB working directory.

No additional third-party dependencies are required.

---

## Usage

### Basic Syntax

```matlab
fig = SliceViewerND(data);
```

### Full Syntax

```matlab
fig = SliceViewerND(data, displayRange, cmap, dimNames, imageNames, ...
    figName, fig, nanColor, sliderPosition, nDimensions, dimensionRatio);
```

### Input Arguments

| Argument | Description | Default |
|----------|-------------|---------|
| `data` | Real-valued N-dimensional numeric array, or cell array of such arrays | Required |
| `displayRange` | `[min max]`, one N-by-2 matrix, or N-cell array of ranges | Per-dataset finite data range |
| `cmap` | One M-by-3 RGB colormap (or colormap name), or a cell array of N colormaps | `gray(256)` |
| `dimNames` | Names for dimensions 3 through N | Automatically generated |
| `imageNames` | N image labels; input variable name(s) used when detectable | Automatic labels |
| `figName` | Figure window title | `"ND Slice Viewer"` |
| `fig` | Existing figure handle | `[]` |
| `nanColor` | RGB triplet, N-by-3 RGB matrix, or N-cell array of RGB triplets | `[0.25 0.25 0.25]` |
| `sliderPosition` | Position of navigation controls (`"bottom"` or `"right"`) | `"bottom"` |
| `nDimensions` | Explicit number of dimensions | `max(3, max(ndims of datasets))` |
| `dimensionRatio` | Relative physical spacing `[X Y D]` | `[1 1 1]` |

### Output

`fig` — Handle to the MATLAB UIFigure containing the interactive viewer.

---

## Examples

### Example 0: Compare Multiple Datasets (New in v1.2.0)

```matlab
A = rand(128,128,40);
B = 2*rand(100,120,35);
C = 3*rand(80,90,20);

fig = SliceViewerND({A,B,C}, ...
    {[0 1],[0 2],[0 3]}, ...
    {gray(256),turbo(256),hot(256)}, ...
    "Depth", ...
    ["Structural","Angiography","Dynamics"], ...
    "Multi-Image Comparison");
```

Each dataset appears in its own panel. Smaller arrays are NaN-padded, and all panels share navigation and averaging controls. Each panel retains its own colormap and CLim.

**Image naming:** For a single named array such as `SliceViewerND(A)`, the viewer uses `A` by default. For a named cell variable such as `datasets = {A,B,C}; SliceViewerND(datasets)`, labels default to `datasets{1}`, `datasets{2}`, etc. MATLAB cannot recover individual variable names from an inline `{A,B,C}` expression, so specify `imageNames` explicitly if desired.


### Example 1: Basic 3D Visualization

```matlab
data = rand(256,512,100);

fig = SliceViewerND(data);
```

Creates a viewer with one slider for navigating the third dimension.

### Example 2: Custom Colormap and Dimension Names

```matlab
data = rand(512,1024,200,10);

fig = SliceViewerND(data,[0 1],turbo(256), ...
    ["Depth","Time"],[],"4D Image Viewer");
```

Creates a four-dimensional viewer with independent Depth and Time sliders.

### Example 3: OCT Volume with Physical Sample Spacing

```matlab
data = rand(512,1024,256);

dx = 5;  % micrometers/pixel
dy = 5;
dz = 2;

fig = SliceViewerND(data,[0 1],gray(256), ...
    "Depth",[],"OCT Volume",[],[0.25 0.25 0.25],"right",3,[dx dy dz]);
```

The physical sample spacing is used to preserve the relative dimensions of the displayed cross-sections.

### Example 4: Higher-Dimensional Dataset

```matlab
data = rand(256,512,100,20,5);

fig = SliceViewerND(data,[0 1],gray(256), ...
    ["Depth","Time","Repetition"],[], ...
    "5D Viewer",[],[0.25 0.25 0.25],"bottom",5,[1 1 2]);
```

Creates a five-dimensional viewer with independent navigation and averaging controls for Depth, Time, and Repetition.

### Example 5: Keyboard Navigation

```matlab
data = rand(256,512,100);

fig = SliceViewerND(data);
```

**Dimension navigation**

1. Click the third-dimension slider.
2. Press **→** to advance by one slice.
3. Press **←** to return to the previous slice.

**Averaging window navigation**

1. Enable averaging for the third dimension.
2. Define the averaging interval using the Start and End fields.
3. Click the Window Position slider.
4. Use **←** and **→** to shift the averaging interval by one index.

The averaging window width remains unchanged.

**Orthogonal position navigation**

1. Enable Orthogonal Views.
2. Click the X or Y location slider.
3. Use **←** and **→** to move the cross-sectional location by one pixel.

The orthogonal images and position indicators update automatically.

---

## Interactive Controls

| Control | Function | Keyboard Navigation |
|---------|----------|---------------------|
| Dimension slider | Select image slice | ← / → (±1 slice) |
| Average toggle | Enable/disable averaging | — |
| Start field | Set averaging interval start | — |
| End field | Set averaging interval end | — |
| Window Position slider | Shift averaging interval | ← / → (±1 index) |
| Orthogonal Views toggle | Show/hide orthogonal views | — |
| Orthogonal dimension dropdown | Select cross-sectional dimension D | — |
| X Location slider | Select X cross-sectional location | ← / → (±1 pixel) |
| Y Location slider | Select Y cross-sectional location | ← / → (±1 pixel) |
| X/Y/D ratio controls | Adjust physical sample spacing | — |
| Image selector | Choose dataset whose CLim is edited | — |
| Color-limit controls | Adjust selected dataset's display range | — |

### Keyboard Navigation Notes

- Click a supported slider before using the arrow keys.
- Each arrow keypress changes the selected value by exactly one integer.
- Slider thumbs remain synchronized with the selected values.
- Values cannot move beyond the slider's valid limits.
- Averaging-window navigation preserves the interval width.
- Keyboard navigation does not modify unrelated controls.

---

## Dimension Convention

SliceViewerND follows MATLAB's standard array dimension ordering:

```matlab
data(Y, X, D1, D2, D3, ...)
```

Where:

- **Y:** Image rows (dimension 1).
- **X:** Image columns (dimension 2).
- **D1:** First navigable dimension (dimension 3).
- **D2:** Second navigable dimension (dimension 4).
- **D3:** Third navigable dimension (dimension 5).

For example:

```matlab
data = rand(512,1024,200,20);
```

Corresponds to:

```text
Y:     512 pixels
X:    1024 pixels
D1:    200 slices
D2:     20 frames
```

The viewer displays the XY image while providing independent controls for D1 and D2.

---

## Performance Considerations

SliceViewerND is designed for interactive exploration of multidimensional datasets.

For large arrays:

- Memory usage depends on dataset sizes and numeric precision; NaN padding of smaller datasets can require additional memory.
- Multidimensional averaging may require additional computation.
- Orthogonal visualization requires extraction of cross-sectional images.
- Cached orthogonal data can reduce repeated computations.
- Display responsiveness depends on dataset size and available hardware.

For very large datasets, consider using `single` precision where appropriate.

---

## MATLAB Compatibility

SliceViewerND uses MATLAB's modern UI components, including:

- `uifigure`
- `uigridlayout`
- `uiaxes`
- `uislider`

The implementation also uses `clim` for setting color limits.

For MATLAB versions earlier than R2022a, `clim` can be replaced with `caxis` where appropriate.

Compatibility may depend on the MATLAB release and availability of the required UI components.

---

## Version History

### v1.2.0 — November 17, 2026

**Multi-Image Comparison & Custom Display Controls**

- Added tiled side-by-side visualization for any number of N-dimensional datasets.
- Synchronized slice navigation, multidimensional averaging, and orthogonal views across datasets.
- Added independent colormaps, CLim ranges, and NaN background colors for each dataset.
- Added automatic NaN padding for differently sized arrays.
- Added optional `imageNames` and automatic input-variable naming where supported.
- Added an image selector immediately left of the CLim controls.
- Expanded documentation and examples for comparison mode.


### v1.1.0 — October 16, 2026

**Keyboard Navigation Update**

Added precise integer-step keyboard navigation for all supported position sliders.

- Added left/right arrow navigation for dimension slice sliders.
- Added left/right arrow navigation for averaging window-position sliders.
- Added left/right arrow navigation for orthogonal X/Y location sliders.
- Automatically tracks the most recently selected slider.
- Moves slider values by exactly one integer per keypress.
- Synchronizes visible slider-thumb positions with selected indices.
- Preserves averaging-window width during keyboard navigation.
- Updates images and linked position indicators automatically.
- Constrains keyboard navigation to valid slider limits.

### v1.0.0 — October 16, 2026

**Initial Release**

- Interactive N-dimensional slice navigation.
- Independent dimension sliders.
- Multidimensional averaging.
- Movable averaging windows.
- Linked orthogonal XY, X–D, and Y–D views.
- Physical aspect-ratio controls.
- Independent image scaling and nonoverlapping layout.
- Interactive colormap and display-range controls.
- Orthogonal data caching.

---

## License

Copyright (c) 2026 Tianhui (Cindy) Jie.

This project is licensed under the **GNU General Public License v3.0 (GPL-3.0-only)**.

You may use, modify, and redistribute the software under the terms of the GNU General Public License v3.0.

See the [LICENSE](LICENSE) file for the complete license terms.

---

## Author

**Tianhui (Cindy) Jie**

Developed for interactive visualization and analysis of multidimensional scientific imaging datasets.

GitHub: [cindy-jth](https://github.com/cindy-jth)

---

## AI Assistance

SliceViewerND was developed by Tianhui (Cindy) Jie with assistance from **OpenAI ChatGPT (GPT-6, October 16, 2026)**.

AI assistance included:

- MATLAB code development and debugging.
- Interactive user-interface design.
- Implementation of visualization and navigation features.
- Code optimization and documentation.

The author directed development and is responsible for reviewing, validating, and maintaining the implementation.

**AI Tool Citation:**

OpenAI. (2026). *ChatGPT (GPT-6)* [Large language model]. https://chatgpt.com/

---

## Feedback and Contributions

Bug reports, feature suggestions, and contributions are welcome.

Please use the repository's [GitHub Issues](https://github.com/cindy-jth/SliceViewerND/issues) page to report problems or suggest improvements.
