# SliceViewerND

**An interactive N-dimensional MATLAB image viewer with orthogonal visualization, multidimensional averaging, and physical aspect-ratio control.**

**Author:** Tianhui (Cindy) Jie  
**Version:** 1.0.0  
**Date:** October 16, 2026  
**Language:** MATLAB  
**License:** GPL V3.0

Developed by Tianhui (Cindy) Jie with assistance from OpenAI ChatGPT (GPT-6, 2026).

## Overview

`SliceViewerND` is an interactive MATLAB visualization tool for exploring multidimensional image datasets. It extends conventional slice viewing by supporting independent navigation and averaging across multiple dimensions, linked orthogonal views, and user-defined physical dimension ratios.

Originally developed for optical coherence tomography (OCT) datasets, the function can be used with other multidimensional imaging data.

The first two dimensions of the input array represent the spatial Y and X axes, respectively. All additional dimensions can be navigated independently.

## Features

- **N-dimensional visualization:** Navigate multidimensional arrays using independent sliders for dimensions 3 through N.
- **Multidimensional averaging:** Average over user-defined ranges along multiple dimensions simultaneously, with NaN values omitted.
- **Movable averaging windows:** Shift averaging intervals without changing their widths.
- **Orthogonal visualization:** Display linked XY, X–D, and Y–D cross-sectional views.
- **Physical aspect ratios:** Specify relative X, Y, and D sample spacings for geometrically accurate visualization.
- **Interactive controls:** Adjust color limits, slice positions, averaging ranges, and orthogonal-view settings.
- **Flexible layout:** Position navigation controls below or to the right of the images.
- **Efficient interaction:** Cached orthogonal data reduces unnecessary recalculation when changing cross-sectional positions.

## Usage

### Basic syntax

```matlab
fig = SliceViewerND(data);

fig = SliceViewerND(data, displayRange, cmap, dimNames, ...
    figName, fig, sliderPosition, nDimensions, dimensionRatio);
```

### Input arguments

| Argument | Description | Default |
|---|---|---|
| `data` | Real-valued numeric array with dimensions `[Y, X, D1, D2, ...]` | Required |
| `displayRange` | Two-element vector `[min max]` specifying color limits | Data range |
| `cmap` | MATLAB colormap | `gray(256)` |
| `dimNames` | Names for dimensions 3 through N | Automatically generated |
| `figName` | Figure window title | `"ND Slice Viewer"` |
| `fig` | Existing figure handle or `[]` to create a new figure | `[]` |
| `sliderPosition` | `"bottom"` or `"right"` | `"bottom"` |
| `nDimensions` | Explicit number of dimensions, including trailing singleton dimensions | `max(3,ndims(data))` |
| `dimensionRatio` | Relative physical sample spacing `[X Y D]` | `[1 1 1]` |

**Output:** `fig` — Handle to the MATLAB figure containing the interactive viewer.

## Examples

### 1. Basic 3D visualization

```matlab
data = rand(256,512,100);

fig = SliceViewerND(data);
```

Opens an interactive viewer with a slider for navigating the third dimension.

### 2. Custom colormap and dimension names

```matlab
data = rand(512,1024,200,10);

fig = SliceViewerND(data,[0 1],turbo(256), ...
    ["Depth","Time"],"4D Image Viewer");
```

Creates a viewer with independent Depth and Time sliders.

### 3. Physical aspect ratios for OCT imaging

```matlab
data = rand(512,1024,256);

% Physical sample spacing (µm/pixel)
dx = 5;
dy = 5;
dz = 2;

fig = SliceViewerND(data,[0 1],gray(256), ...
    "Depth","OCT Volume",[],"right",3,[dx dy dz]);
```

The physical dimension ratios are used to preserve the relative spatial scaling of the images.

**Note:** `dimensionRatio` specifies physical sample spacing, not the total number of pixels or the physical extent of each dimension.

### 4. Higher-dimensional datasets

```matlab
data = rand(256,512,100,20,5);

fig = SliceViewerND(data,[0 1],gray(256), ...
    ["Depth","Time","Repetition"], ...
    "5D Image Viewer",[],"bottom",5,[1 1 2]);
```

Creates three independent dimension sliders, each supporting slice navigation and averaging.

## Interactive Controls

**Slice navigation:** Select an index independently along each dimension beyond X and Y.

**Averaging:** Enable averaging along any navigable dimension and specify its start and end indices. A movable window slider allows the averaging interval to shift while preserving its width.

**Orthogonal views:** Enable additional X–D and Y–D cross-sectional images. Select the orthogonal dimension and adjust X/Y intersection positions using dedicated sliders.

**Physical scaling:** Modify the X, Y, and D ratios interactively. Each view uses the physical spacing of its displayed dimensions.

**Display settings:** Adjust image color limits directly in the viewer.

## Notes

- The first two dimensions of `data` are always interpreted as Y and X.
- Dimensions 3 through N can be navigated or averaged independently.
- Averaging ignores NaN values using `mean(...,'omitnan')`.
- The orthogonal dimension D can be selected interactively.
- All image views share the same colormap and color limits.
- The input dataset is not modified.
- Large datasets may require substantial memory.

## License

Copyright © 2026 Tianhui (Cindy) Jie.

This project is licensed under the **GNU General Public License v3.0 (GPL-3.0)**.

You are free to use, modify, and redistribute this software under the terms of the GNU GPL v3.0. If you distribute modified versions or derivative works covered by the license, you must comply with its source-code availability and licensing requirements.

See the [LICENSE](LICENSE) file for the full license terms.

## Citation

If you use `SliceViewerND` in research leading to a publication, please cite this software.

Citation information is provided in [CITATION.cff](CITATION.cff).

Academic citation is appreciated but is not a legal requirement of GPL v3.

## AI Assistance

This software was developed by Tianhui (Cindy) Jie with assistance from OpenAI ChatGPT (GPT-6, October 16, 2026) for code development, debugging, optimization, and documentation.

**AI tool reference:**

OpenAI. (2026). *ChatGPT (GPT-6)* [Large language model]. https://chatgpt.com/
