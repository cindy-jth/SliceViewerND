% SLICEVIEWERND Interactive N-dimensional MATLAB image viewer and comparator.
%
%   FIG = SLICEVIEWERND(DATA) displays slices of a real-valued numeric array.
%   The first two dimensions represent Y (rows) and X (columns); dimensions
%   3 through N are navigated using synchronized sliders and arrow keys.
%   DATA can also be a cell array of any number of arrays for comparison.
%
% SYNTAX (all inputs are positional and may be omitted from the right)
%
%   FIG = SliceViewerND(DATA)
%   [FIG,MASK] = SliceViewerND(DATA)  % waits for Finish ROI Selection
%   FIG = SliceViewerND(DATA, DISPLAYRANGE, CMAP, DIMNAMES, IMAGENAMES, ...
%       FIGNAME, FIG, NANCOLOR, SLIDERPOSITION, DIMENSIONRATIO, INITIALVIEW, EXPORTOPTIONS)
%
% INPUT ARGUMENTS
%
%   DATA
%       A nonempty real numeric array or cell array {A,B,C,...} of nonempty
%       real numeric arrays. Dimension 1 is Y; dimension 2 is X; dimensions
%       3 through N are independently navigable. All comparison images
%       share the same slice indices, averaging ranges, and orthogonal
%       positions. Arrays smaller in any dimension are padded with NaN at
%       their high-index edges to match the largest array in that dimension.
%       Padding occurs internally; the caller's arrays are not modified.
%
%   DISPLAYRANGE
%       Color limits for each image. Accepts [min max] (shared across all
%       images), an nImages-by-2 numeric matrix, or a cell array with one
%       two-element range per image. Each range must be finite, increasing.
%       Default: Per-image minimum and maximum of finite data values.
%       Constant finite data are given a range expanded by +/- 0.5;
%       images without finite values default to [0 1].
%
%   CMAP
%       An M-by-3 RGB colormap, a colormap name (e.g., 'turbo'), or a
%       cell array of colormaps/names with one entry per image. A single
%       colormap is shared; separate entries provide independent colormaps.
%       Default: gray(256).
%
%   DIMNAMES
%       String array with one name for each dimension 3 through N.
%       Example: ["Depth","Time","Repetition"]
%       Default: ["Dimension 3","Dimension 4",...].
%
%   IMAGENAMES
%       String array or cell array with one nonempty name per image.
%       Names appear in the image-selection dropdown and main image titles.
%       Default: The name of a directly passed numeric variable; for a
%       named cell-array variable, names such as datasets{1}, datasets{2};
%       otherwise "Image 1", "Image 2", etc. MATLAB cannot recover the
%       names of variables inside an inline expression such as {A,B,C}.
%
%   FIGNAME
%       Figure window title. Default: "ND Slice Viewer".
%
%   FIG
%       Existing valid MATLAB figure to reuse; its children are deleted.
%       Default: [] (creates a new UIFigure).
%
%   NANCOLOR
%       RGB color used behind transparent NaN pixels, including padding.
%       Accepts one [R G B] triplet for all images, an nImages-by-3 matrix,
%       or a cell array of one RGB triplet per image. Values must be in
%       [0,1]. Default: [0.25 0.25 0.25].
%
%   SLIDERPOSITION
%       "bottom" or "right" for dimension-navigation controls.
%       Default: "bottom".
%
%   DIMENSIONRATIO
%       Positive, finite sample-spacing ratios [X Y D]. D is the currently
%       selected orthogonal dimension. Used for display aspect ratios:
%       XY -> X:Y; X-D -> X:D; Y-D -> D:Y.
%       Default: [1 1 1].
%
%   INITIALVIEW
%       Optional struct defining the initial view. Fields (all optional):
%         .indices       1-by-(N-2) slice indices for dimensions 3:N.
%         .averageRanges (N-2)-by-2 inclusive averaging ranges; rows
%                        [NaN NaN] leave that dimension unaveraged.
%         .orthogonal    Logical flag to show orthogonal views initially.
%         .orthDimension Index 1...(N-2) of the orthogonal dimension.
%         .xyPositions   [X Y] cross-sectional positions.
%         .xyAverageRanges 2-by-2 inclusive X and Y averaging ranges;
%                        [NaN NaN] rows leave that axis unaveraged.
%         .skipROISelection Logical flag to skip ROI selection entirely;
%                        ROI editing starts disabled and MASK returns [].
%         .roiMask       Initial binary ROI mask. Missing dimensions are
%                        replicated across the data; smaller dimensions
%                        must divide their corresponding data dimensions.
%       Omitted fields use the usual defaults. Default: struct().
%
%       Example: initialView = struct('indices',[25 3], ...
%           'averageRanges',[10 30; NaN NaN]);
%
%   EXPORTOPTIONS
%       Optional scalar struct with exactly two supported fields:
%         .outputFolder  Destination folder path (string or char). Default: pwd.
%         .exportMode    One of 'figureAnnotations', 'crossSectionOnly',
%                        or 'roiMaskOnly'. Default: 'figureAnnotations'.
%       figureAnnotations exports decorated axes with annotations;
%       crossSectionOnly exports image pixels at displayed physical aspect;
%       roiMaskOnly exports an accepted ROI as a black-and-white TIFF
%       (white ROI, black background) at the same size as crossSectionOnly.
%       Both settings can be changed in the GUI before saving TIFFs.
%
% OUTPUT
%
%   FIG
%       Handle to the UIFigure containing the viewer.
%
%   MASK
%       Logical mask, initially 2D for one ROI; a second ROI in a
%       different plane returns an N-dimensional intersection mask. Requesting
%       MASK pauses the function until Finish ROI Selection is clicked;
%       close the viewer to cancel (returns []). After finishing, Add Another
%       ROI and Erase ROI are disabled. With only FIG, the viewer stays
%       nonblocking and the latest mask is available using
%       getappdata(fig,'ROISelection').mask.
%
% INTERACTIVE FEATURES
%
%   1. SYNCHRONIZED COMPARISON
%       Any number of images are arranged in a tiled layout. All panels
%       use common navigation, averaging, orthogonal-dimension selection,
%       and X/Y cross-sectional positions. Each panel has its own colormap,
%       color limits, NaN background color, and image title. The image
%       dropdown immediately left of CLim selects which panel's color
%       limits to edit; changing CLim does not alter other panels.
%
%   2. SLICE AND KEYBOARD NAVIGATION
%       Each dimension beyond X and Y has a slider; positions are rounded
%       to integer indices. Click or scroll within 20 pixels of a position slider, then use left/right
%       arrow keys to step by one index, subject to slider limits and focus.
%       Hovering within 20 pixels and scrolling selects and moves that slider;
%       four scroll units correspond to one index, with faster scrolling
%       producing proportionally larger changes.
%       Supported controls include slice sliders, averaging-window sliders,
%       and orthogonal X/Y position sliders. Disabled sliders do not move.
%
%   3. MULTIDIMENSIONAL AVERAGING
%       The Average toggle disables the corresponding slice slider and
%       averages over a user-selected inclusive Start-to-End range using
%       mean(...,dimension,'omitnan'). Multiple dimensions can be averaged.
%       The Window Position slider moves the interval without changing its
%       width and also supports single-index keyboard steps.
%
%   4. ORTHOGONAL VIEWS
%       Orthogonal Views enables three linked views for every image:
%         XY  - Main slice (Y rows, X columns)
%         X-D - Cross-section at selected Y
%         Y-D - Cross-section at selected X
%       Choose D using the Dimension dropdown. X and Y sliders control
%       cross-sectional positions. Each has an independent Average toggle,
%       inclusive Start/End range, and movable averaging-window slider.
%       Averaging Y produces an averaged X-D cross-section; averaging X
%       produces an averaged Y-D cross-section. The main XY image remains
%       unaveraged along X and Y. Window sliders support arrow-key stepping.
%       Cross-sectional positions; indicator lines show intersections and
%       the main slice or averaging interval in the orthogonal views.
%
%   5. FREEHAND REGION OF INTEREST
%       Click Freehand ROI after the yellow main-position text to open an isolated
%       copy of a displayed XY, X-D, or Y-D view. Select the dataset/view,
%       then click Draw ROI and trace a closed freehand region. Click
%       Confirm ROI to preview a translucent red mask, Restart ROI to
%       redraw, or Accept ROI to save the approved mask. Retrieve
%       the logical mask and selected pixel values using:
%           roi = getappdata(fig,'ROISelection');
%           mask = roi.mask; values = roi.pixelValues;
%       After accepting one ROI, the main toolbar changes to Add Another ROI
%       and Erase ROI. Existing masks appear red in the drawing window,
%       while new candidates appear yellow. Accept ROI closes that window.
%       Accepting computes the intersection of their extruded masks,
%       updates the main viewer, and stores a logical volume mask.
%       No source data are modified.
%
%   6. PHYSICAL ASPECT RATIOS AND DISPLAY SETTINGS
%       The X/Y/D ratio fields control each view's physical aspect ratio.
%       The D field appears when orthogonal views are enabled. Each image
%       retains its own CLim and colormap. NaN pixels reveal the specified
%       axes background color. Display changes do not alter source data.
%
%   7. SAVE CURRENT VIEWS
%       Enter an output directory in the Export folder field and click
%       Save TIFFs. One TIFF is saved per visible view and dataset.
%       Filenames encode the dataset, view, selected indices or averaging
%       ranges, orthogonal dimension, X/Y cross-sections, CLim, and ratios.
%       Existing files are not overwritten; numbered suffixes are used.
%       Cross-section only exports use the current CLim, colormap, NaN
%       background, and physical aspect ratio, without decorations/overlays.
%       Nearest-neighbor resizing preserves colors and matches the GUI aspect.
%
% EXAMPLES
%
%   Example 1: Basic 3D viewer (image title defaults to variable name)
%       volume = rand(256,512,100);
%       fig = SliceViewerND(volume);
%
%   Example 2: Custom colormap and dimension names
%       volume = rand(512,1024,200,10);
%       fig = SliceViewerND(volume,[0 1],turbo(256), ...
%           ["Depth","Time"],[],"4D Image Viewer");
%
%   Example 3: OCT volume with physical sample spacing
%       volume = rand(512,1024,256);
%       dx = 5; dy = 5; dz = 2;  % micrometers per pixel
%       fig = SliceViewerND(volume,[0 1],gray(256),"Depth",[], ...
%           "OCT Volume",[],[0.25 0.25 0.25],"right",[dx dy dz]);
%
%   Example 4: Higher-dimensional dataset
%       volume = rand(256,512,100,20,5);
%       fig = SliceViewerND(volume,[0 1],gray(256), ...
%           ["Depth","Time","Repetition"],[],"5D Viewer",[], ...
%           [0.25 0.25 0.25],"bottom",[1 1 2]);
%
%   Example 5: Three synchronized images with independent display settings
%       A = rand(128,128,40);
%       B = 10*rand(100,120,35);
%       C = 100*rand(80,90,20);
%       fig = SliceViewerND({A,B,C}, ...
%           {[0 1],[0 10],[0 100]}, ...
%           {gray(256),turbo(256),hot(256)}, ...
%           "Depth",["Structural","Angiography","Dynamics"], ...
%           "Comparison",[],[0.2 0.2 0.2],"bottom",[1 1 1]);
%
%   Example 6: Automatic names for a named cell-array variable
%       datasets = {rand(64,64,10),rand(64,64,10)};
%       fig = SliceViewerND(datasets);  % datasets{1}, datasets{2}
%
% NOTES
%
%   - The comparison grid has ceil(sqrt(nImages)) columns.
%   - NaN padding may increase memory usage substantially for large arrays.
%   - Averaging omits NaN values, including padded regions.
%   - Physical ratios affect visualization only, not the underlying data.
%   - Input arrays are not modified in the caller's workspace.
%   - Dimensionality is inferred automatically; trailing singleton dimensions
%     are not shown as separate navigation dimensions.
%
% AUTHOR AND VERSION INFORMATION
%
%   Author:       Tianhui (Cindy) Jie
%   Date:         November 22, 2026
%   Version:      1.3.1
%   License:      GNU General Public License v3.0
%
%   Copyright (c) 2026 Tianhui (Cindy) Jie
%   SPDX-License-Identifier: GPL-3.0-only
%
%   Licensed under the GNU General Public License v3.0.
%   See the LICENSE file for the complete license terms.
%
% AI ASSISTANCE
%
%   Developed by Tianhui (Cindy) Jie with assistance from
%   OpenAI ChatGPT (GPT-6, November 17, 2026).
%   AI assistance included code development, debugging, optimization,
%   user-interface design, and documentation. The author directed
%   development and is responsible for reviewing and maintaining the code.
%
%   AI Tool Citation:
%       OpenAI. (2026). ChatGPT (GPT-6) [Large language model].
%       https://chatgpt.com/
%
% VERSION HISTORY
%   v1.3.1 (2026-11-22)
%       - Added Finish ROI Selection to return the latest accepted mask
%         through the optional second output while keeping the viewer open.
%       - Updated the output mask after accepting additional ROIs, including
%         the intersection of masks selected in different planes.
%       - Disabled further ROI editing after finishing selection, while
%         preserving visualization and export controls.
%   v1.3.0 (2026-11-22)
%       - Added freehand ROI selection in XY, X-D, and Y-D views, with
%         Confirm, Restart, and Accept controls and red preview overlays.
%       - Added Show ROI, Add Another ROI, and Erase ROI controls; display
%         accepted masks as translucent red overlays in all linked views.
%       - Added sequential ROI refinement across different planes: existing
%         masks appear red, candidates yellow, and each 2-D mask is
%         replicated across omitted dimensions before N-D intersection.
%       - Added ROI initialization through initialView.roiMask, including
%         compatible-dimension replication, immediate display, refinement,
%         erasing, export, and direct return of the preloaded mask.
%       - Added optional logical MASK output and ROISelection appdata for
%         retrieving masks and selected pixels; corrected ROI mask creation
%         and overlay sizing when switching views or dimensions.
%       - Added three TIFF export modes selected from one dropdown:
%         figureAnnotations, crossSectionOnly, and roiMaskOnly. ROI-only
%         output is an 8-bit black-and-white mask aligned with the image.
%       - Updated EXPORTOPTIONS to outputFolder and exportMode, preserving
%         current display limits, colormaps, NaN colors, physical aspect
%         ratios, and collision-safe filenames in exported views.
%   v1.2.3 (2026-11-22)
%       - Added mouse-wheel navigation for slice, averaging-window, and
%         X/Y position sliders, including nearby-slider hover selection,
%         fractional scroll accumulation, and keyboard focus tracking.
%       - Inferred dimensionality automatically, removing the NDIMENSIONS
%         positional input and shifting subsequent inputs accordingly.
%       - Added INITIALVIEW to configure initial slice indices, averaging
%         ranges, orthogonal views, and X/Y cross-section positions.
%       - Added GUI TIFF export with a selectable destination folder,
%         cross-section-only option, and descriptive, collision-safe names.
%       - Added final EXPORTOPTIONS struct for outputFolder and
%         crossSectionOnly; optional struct inputs also accept [].
%       - Exported XY, X-D, and Y-D images with current colormap, CLim,
%         NaN background, and physical aspect ratios matching the GUI.
%         Cross-section-only TIFFs omit axes and overlays and use
%         nearest-neighbor resizing to preserve displayed colors.
%   v1.2.2 (2026-11-20)
%       - Placed all dimension and X/Y controls side by side in one row
%         for the bottom layout, with matching slider, Average button,
%         range-field, and averaging-window styling and spacing.
%       - Placed X/Y controls after the dimension sliders in the right
%         layout, stacked as separate full-width rows.
%       - Kept the right sidebar width fixed when toggling orthogonal views.
%   v1.2.1 (2026-11-20)
%       - Added independent X and Y averaging in orthogonal views, with
%         separate range fields and movable averaging-window sliders.
%       - Arranged X and Y orthogonal controls side by side
%         within the main dimension-slider control area.
%       - Added keyboard stepping for X/Y averaging windows.
%       - Added averaging-range indicators and updated cross-section titles.
%       - Made red and green intersection indicators dashed to match yellow.
%   v1.2.0 (2026-11-17)
%       - Added comparison of any number of synchronized image arrays.
%       - Added per-image color limits and colormaps.
%       - Added automatic NaN padding and configurable NaN background colors.
%       - Added custom image names and automatic input-variable naming.
%       - Positioned image selector immediately to the left of CLim.
%
%   v1.1.0 (2026-10-16)
%       - Added keyboard navigation for slice, averaging-window, and
%         orthogonal X/Y position sliders in one-index steps.
%       - Tracked the most recently selected slider and synchronized
%         slider positions, displayed indices, and indicator lines.
%
%   v1.0.0 (2026-10-16)
%       - Initial N-dimensional viewer with slice navigation, averaging,
%         movable averaging windows, orthogonal views, physical aspect
%         ratios, interactive display settings, and orthogonal caching.
%
% SEE ALSO
%   imagesc, sliceViewer, uifigure, uiaxes, uislider, uigridlayout,
%   daspect, caxis, clim, colormap, mean
%