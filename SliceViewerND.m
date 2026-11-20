function fig = SliceViewerND(data, displayRange, cmap, dimNames, imageNames, ...
    figName, fig, nanColor, sliderPosition, nDimensions, dimensionRatio)
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
%   FIG = SliceViewerND(DATA, DISPLAYRANGE, CMAP, DIMNAMES, IMAGENAMES, ...
%       FIGNAME, FIG, NANCOLOR, SLIDERPOSITION, NDIMENSIONS, DIMENSIONRATIO)
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
%   NDIMENSIONS
%       Explicit dimensionality, including trailing singleton dimensions.
%       Must be an integer at least max(3,ndims(A),ndims(B),...).
%       Default: max(3, maximum ndims among input arrays).
%
%   DIMENSIONRATIO
%       Positive, finite sample-spacing ratios [X Y D]. D is the currently
%       selected orthogonal dimension. Used for display aspect ratios:
%       XY -> X:Y; X-D -> X:D; Y-D -> D:Y.
%       Default: [1 1 1].
%
% OUTPUT
%
%   FIG
%       Handle to the UIFigure containing the viewer.
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
%       to integer indices. Click a position slider, then use left/right
%       arrow keys to step by one index, subject to slider limits and focus.
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
%   5. PHYSICAL ASPECT RATIOS AND DISPLAY SETTINGS
%       The X/Y/D ratio fields control each view's physical aspect ratio.
%       The D field appears when orthogonal views are enabled. Each image
%       retains its own CLim and colormap. NaN pixels reveal the specified
%       axes background color. Display changes do not alter source data.
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
%           "OCT Volume",[],[0.25 0.25 0.25],"right",3,[dx dy dz]);
%
%   Example 4: Higher-dimensional dataset
%       volume = rand(256,512,100,20,5);
%       fig = SliceViewerND(volume,[0 1],gray(256), ...
%           ["Depth","Time","Repetition"],[],"5D Viewer",[], ...
%           [0.25 0.25 0.25],"bottom",5,[1 1 2]);
%
%   Example 5: Three synchronized images with independent display settings
%       A = rand(128,128,40);
%       B = 10*rand(100,120,35);
%       C = 100*rand(80,90,20);
%       fig = SliceViewerND({A,B,C}, ...
%           {[0 1],[0 10],[0 100]}, ...
%           {gray(256),turbo(256),hot(256)}, ...
%           "Depth",["Structural","Angiography","Dynamics"], ...
%           "Comparison",[],[0.2 0.2 0.2],"bottom",3,[1 1 1]);
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
%
% AUTHOR AND VERSION INFORMATION
%
%   Author:       Tianhui (Cindy) Jie
%   Date:         November 20, 2026
%   Version:      1.2.2
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
    arguments
        data
        displayRange = []
        cmap = gray(256)
        dimNames string = string.empty
        imageNames = string.empty
        figName (1,1) string = "ND Slice Viewer"
        fig = []
        nanColor = [0.25 0.25 0.25]
        sliderPosition (1,1) string {mustBeMember(sliderPosition,["bottom","right"])} = "bottom"
        nDimensions (1,1) double = NaN
        dimensionRatio (1,3) double {mustBePositive,mustBeFinite} = [1 1 1]
    end

    % Capture the caller variable name before wrapping numeric input in a cell.
    inputVarName = string(inputname(1));
    % Comparison mode: cell arrays of independently scaled datasets.
    if ~iscell(data), data = {data}; end
    nImages = numel(data);
    if isempty(imageNames)
        imageNames = "Image " + string(1:nImages);
        if strlength(inputVarName)>0
            if nImages==1
                imageNames = inputVarName;
            else
                imageNames = inputVarName + "{" + string(1:nImages) + "}";
            end
        end
    else
        imageNames = reshape(string(imageNames),1,[]);
        if numel(imageNames)~=nImages || any(ismissing(imageNames)) || ...
                any(strlength(strtrim(imageNames))==0)
            error('SliceViewerND:ImageNames', ...
                'imageNames must contain one nonempty name per image.');
        end
    end
    if nImages<1 || any(cellfun(@(a) ~isnumeric(a) || ~isreal(a) || isempty(a),data))
        error('SliceViewerND:Data','Provide nonempty real numeric arrays.');
    end
    if isnan(nDimensions)
        nDimensions = max([3,cellfun(@ndims,data)]);
    end
    if ~isscalar(nDimensions) || ~isfinite(nDimensions) || nDimensions~=fix(nDimensions) || ...
            nDimensions<max([3,cellfun(@ndims,data)])
        error('SliceViewerND:Dimensions','Invalid nDimensions.');
    end
    allSizes = ones(nImages,nDimensions);
    for k=1:nImages
        for d=1:nDimensions, allSizes(k,d)=size(data{k},d); end
    end
    commonSize = max(allSizes,[],1);
    nSliders = nDimensions-2;
    nY = commonSize(1); nX = commonSize(2);
    nDims = commonSize(3:end);
    if isempty(displayRange)
        ranges = zeros(nImages,2);
        for k=1:nImages
            finiteValues = double(data{k}(isfinite(data{k})));
            if isempty(finiteValues), ranges(k,:)=[0 1];
            else
                ranges(k,:)=[min(finiteValues) max(finiteValues)];
                if ranges(k,1)==ranges(k,2), ranges(k,:)=ranges(k,:)+[-0.5 0.5]; end
            end
        end
    elseif isnumeric(displayRange) && isequal(size(displayRange),[1 2])
        ranges = repmat(double(displayRange),nImages,1);
    elseif isnumeric(displayRange) && isequal(size(displayRange),[nImages 2])
        ranges = double(displayRange);
    elseif iscell(displayRange) && numel(displayRange)==nImages
        ranges = vertcat(displayRange{:});
    else
        error('SliceViewerND:CLim','Provide [min max], an N-by-2 matrix, or N cells.');
    end
    if any(~isfinite(ranges(:))) || any(ranges(:,1)>=ranges(:,2))
        error('SliceViewerND:CLim','Every display range must be finite and increasing.');
    end
    if ~iscell(cmap), cmap = {cmap}; end
    if numel(cmap)==1, cmap=repmat(cmap,1,nImages); end
    if numel(cmap)~=nImages, error('SliceViewerND:Colormap','Provide one colormap or one per dataset.'); end
    for k=1:nImages
        if ischar(cmap{k}) || isstring(cmap{k}), cmap{k}=feval(char(cmap{k}),256); end
        if ~isnumeric(cmap{k}) || size(cmap{k},2)~=3 || any(~isfinite(cmap{k}(:))) || ...
                any(cmap{k}(:)<0 | cmap{k}(:)>1)
            error('SliceViewerND:Colormap','Colormaps must be M-by-3 RGB arrays.');
        end
    end
    if iscell(nanColor), nanColors=vertcat(nanColor{:});
    else, nanColors=nanColor; end
    if isequal(size(nanColors),[1 3]), nanColors=repmat(nanColors,nImages,1); end
    if ~isequal(size(nanColors),[nImages 3]) || any(~isfinite(nanColors(:))) || ...
            any(nanColors(:)<0 | nanColors(:)>1)
        error('SliceViewerND:NaNColor','NaN colors must be RGB triplets in [0,1].');
    end
    % Pad each dataset once, along every dimension, without changing inputs.
    for k=1:nImages
        if ~isequal(allSizes(k,:),commonSize)
            padded = nan(commonSize);
            subs = arrayfun(@(v) 1:v,allSizes(k,:),'UniformOutput',false);
            padded(subs{:}) = double(data{k});
            data{k} = padded;
        end
    end
    if isempty(dimNames)
        dimNames = "Dimension " + string(3:nDimensions);
    else
        dimNames = reshape(dimNames,1,[]);
        if numel(dimNames)~=nSliders
            error('sliceViewerND:Names','dimNames must contain %d names.',nSliders);
        end
    end

    idx = ones(1,nSliders);
    avgEnabled = false(1,nSliders);
    avgRanges = [ones(nSliders,1),nDims(:)];
    orthEnabled = false;
    orthDim = 1;
    xPos = max(1,round(nX/2));
    yPos = max(1,round(nY/2));
    xyAvgEnabled = false(1,2); % [X Y]
    xyAvgRanges = [1 nX; 1 nY];
    currentDisplayRange = ranges;
    selectedImage = 1;
    currentDimensionRatio = dimensionRatio;
    cachedOrthVol = cell(1,nImages);
    cachedOrthDim = 0;
    activeSlider = [];  % Last operated slider (slice, averaging window, X or Y).
    activeSliderKind = '';
    activeSliderDim = [];

    if isempty(fig)
        % Choose an initial window size based on the physical XY image shape.
        % Reserve space for the toolbar, controls, and axes decorations.
        imageRatio = (nX*dimensionRatio(1))/(nY*dimensionRatio(2));
        imageRatio = max(0.25,min(5,imageRatio));
        if sliderPosition=="bottom"
            controlsHeight = 145;
            figHeight = max(750,min(1100,controlsHeight+450));
            plotHeight = max(240,figHeight-controlsHeight-110);
            figWidth = max(980,min(1900,round(plotHeight*imageRatio*min(nImages,3)+160)));
        else
            figHeight = max(700,min(1100,round(620/max(imageRatio,0.6)+100)));
            plotHeight = figHeight-110;
            figWidth = max(1050,min(1900,round(plotHeight*imageRatio*min(nImages,3)+530)));
        end
        figSize = [figWidth figHeight];
        fig = uifigure('Name',figName,'Position',[100 100 figSize]);
    else
        if ~isa(fig,'matlab.ui.Figure') || ~isvalid(fig)
            error('sliceViewerND:Figure','Invalid figure handle.');
        end
        delete(fig.Children);
        fig.Name = figName;
    end

    outerGL = uigridlayout(fig,[2 1]);
    outerGL.RowHeight = {45,'1x'};
    outerGL.ColumnWidth = {'1x'};
    outerGL.Padding = [12 12 12 12];
    outerGL.RowSpacing = 8;

    toolbarGL = uigridlayout(outerGL,[1 7]);
    toolbarGL.Layout.Row = 1;
    toolbarGL.Layout.Column = 1;
    toolbarGL.RowHeight = {'1x'};
    toolbarGL.ColumnWidth = {150,85,145,'1x',155,220,260};
    toolbarGL.ColumnSpacing = 7;
    toolbarGL.Padding = [0 0 0 0];

    orthButton = uibutton(toolbarGL,'state','Text','Orthogonal Views','Value',false);
    orthButton.Layout.Column = 1;
    orthDimLabel = uilabel(toolbarGL,'Text','Dimension:','HorizontalAlignment','right');
    orthDimLabel.Layout.Column = 2;
    orthDropdown = uidropdown(toolbarGL,'Items',cellstr(dimNames), ...
        'ItemsData',1:nSliders,'Value',1);
    orthDropdown.Layout.Column = 3;
    mainPositionLabel = uilabel(toolbarGL,'Text','', ...
        'FontColor',[0.85 0.62 0],'FontWeight','bold', ...
        'HorizontalAlignment','left','Visible','off');
    mainPositionLabel.Layout.Column = 4;

    imageSelector = uidropdown(toolbarGL,'Items',cellstr(imageNames), ...
        'ItemsData',1:nImages,'Value',1);
    imageSelector.Layout.Column = 5;

    climGL = uigridlayout(toolbarGL,[1 4]);
    climGL.Layout.Column = 6;
    climGL.ColumnWidth = {45,'1x',20,'1x'};
    climGL.RowHeight = {'1x'};
    climGL.Padding = [0 0 0 0];
    climGL.ColumnSpacing = 4;
    uilabel(climGL,'Text','CLim:','HorizontalAlignment','right');
    displayMinField = uieditfield(climGL,'numeric','Value',ranges(1,1), ...
        'ValueDisplayFormat','%.5g');
    uilabel(climGL,'Text','to','HorizontalAlignment','center');
    displayMaxField = uieditfield(climGL,'numeric','Value',ranges(1,2), ...
        'ValueDisplayFormat','%.5g');

    ratioGL = uigridlayout(toolbarGL,[1 7]);
    ratioGL.Layout.Column = 7;
    ratioGL.RowHeight = {'1x'};
    ratioGL.ColumnWidth = {45,16,'1x',16,'1x',0,0};
    ratioGL.Padding = [0 0 0 0];
    ratioGL.ColumnSpacing = 4;
    uilabel(ratioGL,'Text','Ratio:','HorizontalAlignment','right');
    uilabel(ratioGL,'Text','X','HorizontalAlignment','center');
    ratioXField = uieditfield(ratioGL,'numeric','Value',dimensionRatio(1), ...
        'Limits',[eps Inf],'ValueDisplayFormat','%.5g');
    uilabel(ratioGL,'Text','Y','HorizontalAlignment','center');
    ratioYField = uieditfield(ratioGL,'numeric','Value',dimensionRatio(2), ...
        'Limits',[eps Inf],'ValueDisplayFormat','%.5g');
    ratioDLabel = uilabel(ratioGL,'Text','D','HorizontalAlignment','center','Visible','off');
    ratioDField = uieditfield(ratioGL,'numeric','Value',dimensionRatio(3), ...
        'Limits',[eps Inf],'ValueDisplayFormat','%.5g','Visible','off');


    if sliderPosition=="bottom"
        workspaceGL = uigridlayout(outerGL,[2 1]);
        workspaceGL.RowHeight = {'1x',145};
        workspaceGL.ColumnWidth = {'1x'};
    else
        workspaceGL = uigridlayout(outerGL,[1 2]);
        workspaceGL.RowHeight = {'1x'};
        workspaceGL.ColumnWidth = {'1x',420};
    end
    workspaceGL.Layout.Row = 2;
    workspaceGL.Padding = [0 0 0 0];
    workspaceGL.RowSpacing = 8;
    workspaceGL.ColumnSpacing = 8;

    if sliderPosition=="bottom"
        imageAreaGL = uigridlayout(workspaceGL,[1 1]);
        imageAreaGL.ColumnWidth = {'1x'};
        imageAreaGL.RowHeight = {'1x'};
    else
        imageAreaGL = uigridlayout(workspaceGL,[1 1]);
        imageAreaGL.RowHeight = {'1x'};
        imageAreaGL.ColumnWidth = {'1x'};
    end
    imageAreaGL.Layout.Row = 1;
    imageAreaGL.Layout.Column = 1;
    imageAreaGL.Padding = [0 0 0 0];
    imageAreaGL.RowSpacing = 0;
    imageAreaGL.ColumnSpacing = 0;

    tileColumns = ceil(sqrt(nImages));
    tileRows = ceil(nImages/tileColumns);
    compareGL = uigridlayout(imageAreaGL,[tileRows tileColumns]);
    compareGL.Layout.Row = 1; compareGL.Layout.Column = 1;
    compareGL.RowHeight = repmat({'1x'},1,tileRows);
    compareGL.ColumnWidth = repmat({'1x'},1,tileColumns);
    compareGL.Padding = [0 0 0 0];
    compareGL.RowSpacing = 8; compareGL.ColumnSpacing = 8;
    imageGL = gobjects(1,nImages);
    axMain = gobjects(1,nImages); axXD = gobjects(1,nImages); axYD = gobjects(1,nImages);
    hMain = gobjects(1,nImages); hXD = gobjects(1,nImages); hYD = gobjects(1,nImages);
    hVertical = gobjects(1,nImages); hHorizontal = gobjects(1,nImages);
    hVerticalEnd = gobjects(1,nImages); hHorizontalEnd = gobjects(1,nImages);
    hMainXD = gobjects(nImages,2); hMainYD = gobjects(nImages,2);
    hXIndicatorXD = gobjects(nImages,2); hYIndicatorYD = gobjects(nImages,2);
    for im=1:nImages
    imageGL(im) = uigridlayout(compareGL,[2 2]);
    imageGL(im).Layout.Row = ceil(im/tileColumns);
    imageGL(im).Layout.Column = mod(im-1,tileColumns)+1;
    imageGL(im).RowHeight = {'1x',0};
    imageGL(im).ColumnWidth = {'1x',0};
    imageGL(im).RowSpacing = 0;
    imageGL(im).ColumnSpacing = 0;
    imageGL(im).Padding = [0 0 0 0];

    % Separate clipped containers prevent axes, labels, and plot boxes
    % from painting into neighboring panes during a layout transition.
    mainPane = uipanel(imageGL(im),'BorderType','none');
    mainPane.Layout.Row = 1;
    mainPane.Layout.Column = 1;
    xdPane = uipanel(imageGL(im),'BorderType','none');
    xdPane.Layout.Row = 2;
    xdPane.Layout.Column = 1;
    ydPane = uipanel(imageGL(im),'BorderType','none');
    ydPane.Layout.Row = 1;
    ydPane.Layout.Column = 2;

    mainPaneGL = uigridlayout(mainPane,[1 1], ...
        'Padding',[6 6 6 6],'RowHeight',{'1x'},'ColumnWidth',{'1x'});
    xdPaneGL = uigridlayout(xdPane,[1 1], ...
        'Padding',[12 12 12 12],'RowHeight',{'1x'},'ColumnWidth',{'1x'});
    ydPaneGL = uigridlayout(ydPane,[1 1], ...
        'Padding',[12 12 12 12],'RowHeight',{'1x'},'ColumnWidth',{'1x'});

    axMain(im) = uiaxes(mainPaneGL);
    initialSubs = repmat({1},1,nDimensions);
    initialSubs(1:2) = {':',':'};
    hMain(im) = imagesc(axMain(im),reshape(data{im}(initialSubs{:}),nY,nX));
    axMain(im).XTick = [];
    axMain(im).YTick = [];
    axMain(im).XLim = [0.5 nX+0.5];
    axMain(im).YLim = [0.5 nY+0.5];
    axMain(im).XLimMode = 'manual';
    axMain(im).YLimMode = 'manual';
    colormap(axMain(im),cmap{im});
    clim(axMain(im),currentDisplayRange(im,:));
    axMain(im).Color = nanColors(im,:);
    hMain(im).AlphaData = double(~isnan(hMain(im).CData));
    hMain(im).AlphaDataMapping = 'none';
    colorbar(axMain(im));

    axXD(im) = uiaxes(xdPaneGL);
    hXD(im) = imagesc(axXD(im),zeros(nDims(1),nX));
    colormap(axXD(im),cmap{im});
    clim(axXD(im),currentDisplayRange(im,:));
    axXD(im).Color = nanColors(im,:);
    hXD(im).AlphaDataMapping = 'none';
    axXD(im).Visible = 'off';

    axYD(im) = uiaxes(ydPaneGL);
    hYD(im) = imagesc(axYD(im),zeros(nY,nDims(1)));
    colormap(axYD(im),cmap{im});
    clim(axYD(im),currentDisplayRange(im,:));
    axYD(im).Color = nanColors(im,:);
    hYD(im).AlphaDataMapping = 'none';
    axYD(im).Visible = 'off';

    hold(axMain(im),'on');
    hVertical(im) = line(axMain(im),[xPos xPos],[0.5 nY+0.5], ...
        'Color','g','LineWidth',1.5,'LineStyle','--','Visible','off','HitTest','off');
    hHorizontal(im) = line(axMain(im),[0.5 nX+0.5],[yPos yPos], ...
        'Color','r','LineWidth',1.5,'LineStyle','--','Visible','off','HitTest','off');
    hVerticalEnd(im) = line(axMain(im),[xPos xPos],[0.5 nY+0.5], ...
        'Color','g','LineWidth',1.5,'LineStyle','--','Visible','off','HitTest','off');
    hHorizontalEnd(im) = line(axMain(im),[0.5 nX+0.5],[yPos yPos], ...
        'Color','r','LineWidth',1.5,'LineStyle','--','Visible','off','HitTest','off');
    hold(axMain(im),'off');

    
    
    hold(axXD(im),'on');
    for k=1:2
        hMainXD(im,k) = line(axXD(im),[0.5 nX+0.5],[1 1], ...
            'Color','y','LineWidth',1.5,'LineStyle','--', ...
            'Visible','off','HitTest','off');
    end
    for k=1:2
        hXIndicatorXD(im,k) = line(axXD(im),[xPos xPos],[0.5 nDims(1)+0.5], ...
            'Color','g','LineWidth',1.5,'LineStyle','--','Visible','off','HitTest','off');
    end
    hold(axXD(im),'off');
    hold(axYD(im),'on');
    for k=1:2
        hMainYD(im,k) = line(axYD(im),[1 1],[0.5 nY+0.5], ...
            'Color','y','LineWidth',1.5,'LineStyle','--', ...
            'Visible','off','HitTest','off');
    end
    for k=1:2
        hYIndicatorYD(im,k) = line(axYD(im),[0.5 nDims(1)+0.5],[yPos yPos], ...
            'Color','r','LineWidth',1.5,'LineStyle','--','Visible','off','HitTest','off');
    end
    hold(axYD(im),'off');

    end % image panels

    if sliderPosition=="bottom"
        % All dimension controls occupy one horizontal strip; X/Y use the
        % final two columns when orthogonal views are enabled.
        controlsGL = uigridlayout(workspaceGL,[1 nSliders+2]);
    else
        % Right-side controls stack vertically, with X/Y at the bottom.
        controlsGL = uigridlayout(workspaceGL,[nSliders+2 1]);
    end
    if sliderPosition=="bottom"
        controlsGL.Layout.Row = 2;
        controlsGL.Layout.Column = 1;
    else
        controlsGL.Layout.Row = 1;
        controlsGL.Layout.Column = 2;
    end
    if sliderPosition=="bottom"
        controlsGL.RowHeight = {145};
        controlsGL.ColumnWidth = [repmat({'1x'},1,nSliders),{0,0}];
        controlsGL.ColumnSpacing = 8;
    else
        controlsGL.RowHeight = [repmat({145},1,nSliders),{0,0}];
        controlsGL.ColumnWidth = {'1x'};
        controlsGL.RowSpacing = 10;
    end
    controlsGL.Padding = [0 0 0 0];

    % X/Y averaging controls mirror the controls for dimensions 3 through N.
    % Both axes can be averaged independently; cross-sections average over
    % the corresponding inclusive interval, omitting NaN values.
    if sliderPosition=="bottom"
        orthControlsGL = uigridlayout(controlsGL,[1 2]);
    else
        orthControlsGL = uigridlayout(controlsGL,[2 1]);
    end
    if sliderPosition=="bottom"
        orthControlsGL.Layout.Row = 1;
        orthControlsGL.Layout.Column = [nSliders+1 nSliders+2];
    else
        orthControlsGL.Layout.Row = [nSliders+1 nSliders+2];
        orthControlsGL.Layout.Column = 1;
    end
    if sliderPosition=="bottom"
        orthControlsGL.RowHeight = {'1x'};
        orthControlsGL.ColumnWidth = {'1x','1x'};
    else
        orthControlsGL.RowHeight = {'1x','1x'};
        orthControlsGL.ColumnWidth = {'1x'};
    end
    orthControlsGL.Padding = [0 0 0 0];
    orthControlsGL.ColumnSpacing = 8;
    orthControlsGL.RowSpacing = 10;
    orthControlsGL.Visible = 'off';

    xySliders = gobjects(1,2);
    xyLabels = gobjects(1,2);
    xyAvgButtons = gobjects(1,2);
    xyStartFields = gobjects(1,2);
    xyEndFields = gobjects(1,2);
    xyRangeLabels = gobjects(1,2);
    xyWindowSliders = gobjects(1,2);
    xyWindowLabels = gobjects(1,2);
    xySizes = [nX nY];
    xyNames = {'X','Y'};
    for xy=1:2
        xyPanel = uigridlayout(orthControlsGL,[4 2]);
        if sliderPosition=="bottom"
            xyPanel.Layout.Row = 1;
            xyPanel.Layout.Column = xy;
        else
            xyPanel.Layout.Row = xy;
            xyPanel.Layout.Column = 1;
        end
        % Match the dimension-slider panel design in both orientations.
        xyPanel.RowHeight = {25,35,35,35};
        xyPanel.ColumnWidth = {'1x',110};
        xyPanel.Padding = [5 0 5 0];
        xyPanel.RowSpacing = 5;
        xyLabels(xy) = uilabel(xyPanel,'Text','', ...
            'HorizontalAlignment','center');
        xyLabels(xy).Layout.Row = 1;
        xyLabels(xy).Layout.Column = 1;
        xySliders(xy) = uislider(xyPanel, ...
            'Limits',[1 max(2,xySizes(xy))], ...
            'Value',round(xySizes(xy)/2),'MajorTicks',[],'MinorTicks',[]);
        xySliders(xy).Layout.Row = 2;
        xySliders(xy).Layout.Column = 1;
        xyAvgButtons(xy) = uibutton(xyPanel,'state', ...
            'Text','Average','Value',false);
        xyAvgButtons(xy).Layout.Row = [1 2];
        xyAvgButtons(xy).Layout.Column = 2;

        xyRangeRow = uigridlayout(xyPanel,[1 5]);
        xyRangeRow.Layout.Row = 3;
        xyRangeRow.Layout.Column = [1 2];
        xyRangeRow.ColumnWidth = {105,65,20,65,'1x'};
        xyRangeRow.ColumnSpacing = 5;
        xyRangeRow.Padding = [0 0 0 0];
        uilabel(xyRangeRow,'Text','Average range:','HorizontalAlignment','right');
        xyStartFields(xy) = uieditfield(xyRangeRow,'numeric', ...
            'Value',1,'Limits',[1 max(2,xySizes(xy))], ...
            'RoundFractionalValues','on');
        uilabel(xyRangeRow,'Text','to','HorizontalAlignment','center');
        xyEndFields(xy) = uieditfield(xyRangeRow,'numeric', ...
            'Value',xySizes(xy),'Limits',[1 max(2,xySizes(xy))], ...
            'RoundFractionalValues','on');
        xyRangeLabels(xy) = uilabel(xyRangeRow,'Text', ...
            sprintf('(%d slices)',xySizes(xy)));

        xyWindowRow = uigridlayout(xyPanel,[1 2]);
        xyWindowRow.Layout.Row = 4;
        xyWindowRow.Layout.Column = [1 2];
        xyWindowRow.ColumnWidth = {110,'1x'};
        xyWindowRow.ColumnSpacing = 10;
        xyWindowRow.Padding = [0 0 0 0];
        xyWindowLabels(xy) = uilabel(xyWindowRow, ...
            'Text','Window position:','Visible','off');
        xyWindowSliders(xy) = uislider(xyWindowRow, ...
            'Limits',[1 max(2,xySizes(xy))], ...
            'Value',1,'MajorTicks',[],'MinorTicks',[],'Visible','off');
        if xySizes(xy)==1
            xySliders(xy).Enable = 'off';
            xyStartFields(xy).Enable = 'off';
            xyEndFields(xy).Enable = 'off';
        end
        axisId = xy;
        xySliders(xy).ValueChangingFcn = @(~,e) positionCallback(axisId,e.Value);
        xySliders(xy).ValueChangedFcn = @(~,e) positionCallback(axisId,e.Value);
        xyAvgButtons(xy).ValueChangedFcn = @(~,e) xyAverageCallback(axisId,e.Value);
        xyStartFields(xy).ValueChangedFcn = @(~,~) xyRangeCallback(axisId);
        xyEndFields(xy).ValueChangedFcn = @(~,~) xyRangeCallback(axisId);
        xyWindowSliders(xy).ValueChangingFcn = @(~,e) xyWindowCallback(axisId,e.Value);
        xyWindowSliders(xy).ValueChangedFcn = @(~,e) xyWindowCallback(axisId,e.Value);
    end
    xLabel = xyLabels(1); yLabel = xyLabels(2);
    xSlider = xySliders(1); ySlider = xySliders(2);

    sliders = gobjects(1,nSliders);
    windowSliders = gobjects(1,nSliders);
    labels = gobjects(1,nSliders);
    windowLabels = gobjects(1,nSliders);
    avgButtons = gobjects(1,nSliders);
    startFields = gobjects(1,nSliders);
    endFields = gobjects(1,nSliders);
    rangeLabels = gobjects(1,nSliders);

    for d=1:nSliders
        panel = uigridlayout(controlsGL,[4 2]);
        if sliderPosition=="bottom"
            panel.Layout.Row = 1;
            panel.Layout.Column = d;
        else
            panel.Layout.Row = d;
            panel.Layout.Column = 1;
        end
        panel.RowHeight = {25,35,35,35};
        panel.ColumnWidth = {'1x',110};
        panel.Padding = [5 0 5 0];
        panel.RowSpacing = 5;

        labels(d) = uilabel(panel,'Text','', 'HorizontalAlignment','center');
        labels(d).Layout.Row = 1;
        labels(d).Layout.Column = 1;
        sliders(d) = uislider(panel,'Limits',[1 max(2,nDims(d))], ...
            'Value',1,'MajorTicks',[],'MinorTicks',[]);
        sliders(d).Layout.Row = 2;
        sliders(d).Layout.Column = 1;
        avgButtons(d) = uibutton(panel,'state','Text','Average','Value',false);
        avgButtons(d).Layout.Row = [1 2];
        avgButtons(d).Layout.Column = 2;

        rangeRow = uigridlayout(panel,[1 5]);
        rangeRow.ColumnWidth = {105,65,20,65,'1x'};
        rangeRow.Padding = [0 0 0 0];
        rangeRow.ColumnSpacing = 5;
        rangeRow.Layout.Row = 3;
        rangeRow.Layout.Column = [1 2];
        uilabel(rangeRow,'Text','Average range:','HorizontalAlignment','right');
        startFields(d) = uieditfield(rangeRow,'numeric','Value',1, ...
            'Limits',[1 max(2,nDims(d))],'RoundFractionalValues','on');
        uilabel(rangeRow,'Text','to','HorizontalAlignment','center');
        endFields(d) = uieditfield(rangeRow,'numeric','Value',nDims(d), ...
            'Limits',[1 max(2,nDims(d))],'RoundFractionalValues','on');
        rangeLabels(d) = uilabel(rangeRow,'Text',sprintf('(%d slices)',nDims(d)));

        windowRow = uigridlayout(panel,[1 2]);
        windowRow.ColumnWidth = {110,'1x'};
        windowRow.Padding = [0 0 0 0];
        windowRow.ColumnSpacing = 10;
        windowRow.Layout.Row = 4;
        windowRow.Layout.Column = [1 2];
        windowLabels(d) = uilabel(windowRow,'Text','Window position:','Visible','off');
        windowSliders(d) = uislider(windowRow, ...
            'Limits',[1 max(2,nDims(d))],'Value',1, ...
            'MajorTicks',[],'MinorTicks',[],'Visible','off');
        if nDims(d)==1
            sliders(d).Enable = 'off';
            startFields(d).Enable = 'off';
            endFields(d).Enable = 'off';
        end
        dim = d;
        sliders(d).ValueChangingFcn = @(~,event) sliceCallback(dim,event.Value);
        sliders(d).ValueChangedFcn = @(~,event) sliceCallback(dim,event.Value);
        avgButtons(d).ValueChangedFcn = @(~,event) averageCallback(dim,event.Value);
        startFields(d).ValueChangedFcn = @(~,~) rangeCallback(dim);
        endFields(d).ValueChangedFcn = @(~,~) rangeCallback(dim);
        windowSliders(d).ValueChangingFcn = @(~,event) windowCallback(dim,event.Value);
        windowSliders(d).ValueChangedFcn = @(~,event) windowCallback(dim,event.Value);
    end

    orthButton.ValueChangedFcn = @(~,event) orthToggle(event.Value);
    orthDropdown.ValueChangedFcn = @(~,event) orthDimensionCallback(event.Value);
    xSlider.ValueChangingFcn = @(~,event) positionCallback(1,event.Value);
    xSlider.ValueChangedFcn = @(~,event) positionCallback(1,event.Value);
    ySlider.ValueChangingFcn = @(~,event) positionCallback(2,event.Value);
    ySlider.ValueChangedFcn = @(~,event) positionCallback(2,event.Value);
    displayMinField.ValueChangedFcn = @(~,~) updateDisplayRange();
    displayMaxField.ValueChangedFcn = @(~,~) updateDisplayRange();
    ratioXField.ValueChangedFcn = @(~,~) updateDimensionRatios();
    ratioYField.ValueChangedFcn = @(~,~) updateDimensionRatios();
    ratioDField.ValueChangedFcn = @(~,~) updateDimensionRatios();
    imageSelector.ValueChangedFcn = @(~,event) selectImage(event.Value);

    fig.WindowKeyPressFcn = @sliceKeyboardCallback;

    updateImages();
    updateDimensionRatios();

    function selectImage(value)
        selectedImage = value;
        displayMinField.Value = currentDisplayRange(value,1);
        displayMaxField.Value = currentDisplayRange(value,2);
    end

    function updateDisplayRange()
        newLimits = [displayMinField.Value,displayMaxField.Value];
        if any(~isfinite(newLimits)) || newLimits(1)>=newLimits(2)
            displayMinField.Value = currentDisplayRange(selectedImage,1);
            displayMaxField.Value = currentDisplayRange(selectedImage,2);
            uialert(fig,'CLim minimum must be smaller than its maximum.','Invalid Display Range');
            return;
        end
        currentDisplayRange(selectedImage,:) = newLimits;
        clim(axMain(selectedImage),newLimits);
        clim(axXD(selectedImage),newLimits);
        clim(axYD(selectedImage),newLimits);
    end

    function updateDimensionRatios()
        ratios = [ratioXField.Value,ratioYField.Value,ratioDField.Value];
        if any(~isfinite(ratios)) || any(ratios<=0)
            ratioXField.Value = currentDimensionRatio(1);
            ratioYField.Value = currentDimensionRatio(2);
            ratioDField.Value = currentDimensionRatio(3);
            uialert(fig,'X, Y, and D ratios must be finite and positive.', ...
                'Invalid Dimension Ratio');
            return;
        end
        currentDimensionRatio = ratios;
        % Each view uses only its own pair of spacings.
        % Do not resize shared grid cells when a ratio changes.
        normalizedRatios = ratios;
        % DataAspectRatio is [horizontal-unit, vertical-unit, 1].
        for im=1:nImages
            daspect(axMain(im),[normalizedRatios(1),normalizedRatios(2),1]);
            daspect(axXD(im),[normalizedRatios(1),normalizedRatios(3),1]);
            daspect(axYD(im),[normalizedRatios(3),normalizedRatios(2),1]);
        end
        % Keep pane allocations fixed; only update each axes aspect.
    end

    function updatePhysicalLayout()
        % Keep the grid allocations independent of X:Y:D ratios.
        % Changing Y must not resize the X-D pane; changing X must not
        % resize the Y-D pane. Physical scaling is enforced separately
        % by daspect() on each axes, not by coupled grid weights.
        for im=1:nImages
        if orthEnabled
            imageGL(im).RowHeight = {'1x','0.55x'};
            imageGL(im).ColumnWidth = {'1x','0.55x'};
        else
            imageGL(im).RowHeight = {'1x',0};
            imageGL(im).ColumnWidth = {'1x',0};
        end
        end
    end

    function selectSlider(handle,kind,d)
        activeSlider = handle;
        activeSliderKind = kind;
        activeSliderDim = d;
    end

    function sliceCallback(d,value)
        selectSlider(sliders(d),'slice',d);
        newIndex = min(max(round(value),1),nDims(d));
        idx(d) = newIndex;
        if sliders(d).Value ~= newIndex
            sliders(d).Value = newIndex;
        end
        updateImages();
    end

    function sliceKeyboardCallback(~,event)
        % Arrow keys step the focused slider by exactly one integer.
        if isempty(activeSlider) || ~ismember(event.Key,{'leftarrow','rightarrow'})
            return;
        end
        if ~isvalid(activeSlider) || ~strcmp(activeSlider.Enable,'on') || ...
                ~strcmp(activeSlider.Visible,'on')
            return;
        end
        % Do not hijack keyboard arrows from numeric fields, dropdowns,
        % or another UI component. CurrentObject is available in modern
        % MATLAB releases; if unavailable, use the last operated slider.
        try
            focused = fig.CurrentObject;
            if ~isequal(focused,activeSlider)
                return;
            end
        catch
        end
        delta = 1;
        if strcmp(event.Key,'leftarrow'), delta = -1; end
        d = activeSliderDim;
        switch activeSliderKind
            case 'slice'
                if avgEnabled(d), return; end
                oldIndex = idx(d);
                newIndex = min(max(oldIndex+delta,1),nDims(d));
                activeSlider.Value = newIndex;
                if newIndex ~= oldIndex, sliceCallback(d,newIndex); end
            case 'window'
                width = diff(avgRanges(d,:))+1;
                maxStart = nDims(d)-width+1;
                if maxStart<=1, return; end
                oldIndex = avgRanges(d,1);
                newIndex = min(max(oldIndex+delta,1),maxStart);
                activeSlider.Value = newIndex;
                if newIndex ~= oldIndex, windowCallback(d,newIndex); end
            case 'xywindow'
                width = diff(xyAvgRanges(d,:))+1;
                maxStart = xySizes(d)-width+1;
                if maxStart<=1, return; end
                newStart = min(max(xyAvgRanges(d,1)+delta,1),maxStart);
                activeSlider.Value = newStart;
                if newStart~=xyAvgRanges(d,1), xyWindowCallback(d,newStart); end
            case 'x' 
                oldIndex = xPos;
                newIndex = min(max(oldIndex+delta,1),nX);
                activeSlider.Value = newIndex;
                if newIndex ~= oldIndex, positionCallback(1,newIndex); end
            case 'y'
                oldIndex = yPos;
                newIndex = min(max(oldIndex+delta,1),nY);
                activeSlider.Value = newIndex;
                if newIndex ~= oldIndex, positionCallback(2,newIndex); end
        end
    end

    function averageCallback(d,value)
        avgEnabled(d) = logical(value);
        if value
            sliders(d).Enable = 'off';
            windowSliders(d).Visible = 'on';
            windowLabels(d).Visible = 'on';
            updateWindowSlider(d);
        else
            if nDims(d)>1, sliders(d).Enable = 'on'; end
            windowSliders(d).Visible = 'off';
            windowLabels(d).Visible = 'off';
        end
        updateImages();
    end

    function rangeCallback(d)
        a = min(max(round(startFields(d).Value),1),nDims(d));
        b = min(max(round(endFields(d).Value),1),nDims(d));
        if a>b, [a,b] = deal(b,a); end
        avgRanges(d,:) = [a b];
        startFields(d).Value = a;
        endFields(d).Value = b;
        rangeLabels(d).Text = sprintf('(%d slices)',b-a+1);
        updateWindowSlider(d);
        updateImages();
    end

    function windowCallback(d,value)
        selectSlider(windowSliders(d),'window',d);
        width = diff(avgRanges(d,:))+1;
        maxStart = nDims(d)-width+1;
        a = min(max(round(value),1),maxStart);
        avgRanges(d,:) = [a,a+width-1];
        if windowSliders(d).Value ~= a, windowSliders(d).Value = a; end
        startFields(d).Value = a;
        endFields(d).Value = a+width-1;
        updateImages();
    end

    function updateWindowSlider(d)
        width = diff(avgRanges(d,:))+1;
        maxStart = nDims(d)-width+1;
        s = windowSliders(d);
        % Enlarge limits before changing Value; then narrow limits safely.
        s.Limits = [1,max([2,nDims(d),s.Limits(2),s.Value])];
        if maxStart<=1
            s.Value = 1;
            s.Limits = [1 2];
            s.Enable = 'off';
        else
            s.Value = avgRanges(d,1);
            s.Limits = [1 maxStart];
            s.Enable = 'on';
        end
    end

    function xyAverageCallback(which,value)
        xyAvgEnabled(which) = logical(value);
        if value
            xySliders(which).Enable = 'off';
            xyWindowSliders(which).Visible = 'on';
            xyWindowLabels(which).Visible = 'on';
            updateXYWindowSlider(which);
        else
            if xySizes(which)>1, xySliders(which).Enable = 'on'; end
            xyWindowSliders(which).Visible = 'off';
            xyWindowLabels(which).Visible = 'off';
        end
        updateImages();
    end

    function xyRangeCallback(which)
        n = xySizes(which);
        a = min(max(round(xyStartFields(which).Value),1),n);
        b = min(max(round(xyEndFields(which).Value),1),n);
        if a>b, [a,b] = deal(b,a); end
        xyAvgRanges(which,:) = [a b];
        xyStartFields(which).Value = a;
        xyEndFields(which).Value = b;
        xyRangeLabels(which).Text = sprintf('(%d slices)',b-a+1);
        updateXYWindowSlider(which);
        updateImages();
    end

    function xyWindowCallback(which,value)
        selectSlider(xyWindowSliders(which),'xywindow',which);
        width = diff(xyAvgRanges(which,:))+1;
        maxStart = xySizes(which)-width+1;
        a = min(max(round(value),1),maxStart);
        xyAvgRanges(which,:) = [a a+width-1];
        if xyWindowSliders(which).Value~=a
            xyWindowSliders(which).Value = a;
        end
        xyStartFields(which).Value = a;
        xyEndFields(which).Value = a+width-1;
        updateImages();
    end

    function updateXYWindowSlider(which)
        width = diff(xyAvgRanges(which,:))+1;
        maxStart = xySizes(which)-width+1;
        slider = xyWindowSliders(which);
        slider.Limits = [1 max([2,xySizes(which),slider.Limits(2),slider.Value])];
        if maxStart<=1
            slider.Value = 1;
            slider.Limits = [1 2];
            slider.Enable = 'off';
        else
            slider.Value = xyAvgRanges(which,1);
            slider.Limits = [1 maxStart];
            slider.Enable = 'on';
        end
    end

    function orthToggle(value)
        orthEnabled = logical(value);
        ratioDLabel.Visible = matlab.lang.OnOffSwitchState(orthEnabled);
        ratioDField.Visible = matlab.lang.OnOffSwitchState(orthEnabled);
        for im=1:nImages
        if orthEnabled
            % Maintain enough physical room for three independent image panes.
            % MATLAB otherwise may draw axes decorations over adjacent panes.
            oldUnits = fig.Units;
            fig.Units = 'pixels';
            pos = fig.Position;
            if sliderPosition=="bottom"
                pos(3) = max(pos(3),max(1450,350*nSliders+470));
                pos(4) = max(pos(4),750);
            else
                % Keep figure width fixed when orthogonal views are toggled.
                pos(4) = max(pos(4),155+145*(nSliders+2)+10*(nSliders+1)+100);
            end
            fig.Position = pos;
            fig.Units = oldUnits;
            ratioGL.ColumnWidth = {45,16,'1x',16,'1x',16,'1x'};
            orthControlsGL.Visible = 'on';
            if sliderPosition=="bottom"
                controlsGL.ColumnWidth = repmat({'1x'},1,nSliders+2);
            else
                controlsGL.RowHeight = [repmat({145},1,nSliders),{145,145}];
            end
            mainPositionLabel.Visible = 'on';
            hVertical(im).Visible = 'on';
            hHorizontal(im).Visible = 'on';
            hVerticalEnd(im).Visible = 'off';
            hHorizontalEnd(im).Visible = 'off';
            % Settle grid dimensions before exposing orthogonal axes.
            drawnow;
            axXD(im).Visible = 'on';
            axYD(im).Visible = 'on';
            imageGL(im).RowSpacing = 24;
            imageGL(im).ColumnSpacing = 24;
            if sliderPosition=="bottom"
                workspaceGL.RowHeight = {'1x',145};
            else
                workspaceGL.ColumnWidth = {'1x',420};
            end
        else
            ratioGL.ColumnWidth = {45,16,'1x',16,'1x',0,0};
            orthControlsGL.Visible = 'off';
            if sliderPosition=="bottom"
                controlsGL.ColumnWidth = [repmat({'1x'},1,nSliders),{0,0}];
            else
                controlsGL.RowHeight = [repmat({145},1,nSliders),{0,0}];
            end
            mainPositionLabel.Visible = 'off';
            hVertical(im).Visible = 'off';
            hHorizontal(im).Visible = 'off';
            hVerticalEnd(im).Visible = 'off';
            hHorizontalEnd(im).Visible = 'off';
            axXD(im).Visible = 'off';
            axYD(im).Visible = 'off';
            set(hXIndicatorXD(im,:),'Visible','off');
            set(hYIndicatorYD(im,:),'Visible','off');
            imageGL(im).RowHeight = {'1x',0};
            imageGL(im).ColumnWidth = {'1x',0};
            imageGL(im).RowSpacing = 0;
            imageGL(im).ColumnSpacing = 0;
            if sliderPosition=="bottom"
                workspaceGL.RowHeight = {'1x',145};
            else
                workspaceGL.ColumnWidth = {'1x',420};
            end
        end
        end % panels
        updatePhysicalLayout();
        updateImages();
        % Finish layout after visibility and grid changes have settled.
        drawnow limitrate;
    end

    function orthDimensionCallback(value)
        orthDim = value;
        updatePhysicalLayout();
        updateImages();
    end

    function positionCallback(which,value)
        if which==1
            selectSlider(xSlider,'x',1);
            xPos = min(max(round(value),1),nX);
            if xSlider.Value ~= xPos, xSlider.Value = xPos; end
        else
            selectSlider(ySlider,'y',2);
            yPos = min(max(round(value),1),nY);
            if ySlider.Value ~= yPos, ySlider.Value = yPos; end
        end
        updateImages();
    end

    function img = extractData(excludeDim,im)
        subs = repmat({1},1,nDimensions);
        subs(1:2) = {':',':'};
        for d=1:nSliders
            if d==excludeDim
                subs{d+2} = 1:nDims(d);
            elseif avgEnabled(d)
                subs{d+2} = avgRanges(d,1):avgRanges(d,2);
            else
                subs{d+2} = idx(d);
            end
        end
        img = data{im}(subs{:});
        for d=1:nSliders
            if avgEnabled(d) && d~=excludeDim
                img = mean(img,d+2,'omitnan');
            end
        end
        if excludeDim==0
            img = reshape(img,nY,nX);
        else
            order = [1 2 excludeDim+2, ...
                setdiff(3:nDimensions,excludeDim+2,'stable')];
            img = permute(img,order);
            img = reshape(img,nY,nX,nDims(excludeDim));
        end
    end

    function updateMainPositionIndicators()
        for im=1:nImages
        if ~orthEnabled
            for k=1:2
                hMainXD(im,k).Visible = 'off';
                hMainYD(im,k).Visible = 'off';
            end
            continue;
        end
        if avgEnabled(orthDim)
            positions = avgRanges(orthDim,:);
            nLines = 2;
        else
            positions = idx(orthDim);
            nLines = 1;
        end
        for k=1:2
            if k<=nLines
                pos = positions(k);
                hMainXD(im,k).XData = [0.5 nX+0.5];
                hMainXD(im,k).YData = [pos pos];
                hMainYD(im,k).XData = [pos pos];
                hMainYD(im,k).YData = [0.5 nY+0.5];
                hMainXD(im,k).Visible = 'on';
                hMainYD(im,k).Visible = 'on';
            else
                hMainXD(im,k).Visible = 'off';
                hMainYD(im,k).Visible = 'off';
            end
        end
        end % panels
    end

    function updateOrthogonalIntersectionIndicators()
        for im=1:nImages
        if ~orthEnabled
            set(hXIndicatorXD(im,:),'Visible','off');
            set(hYIndicatorYD(im,:),'Visible','off');
            continue;
        end
        % Draw both averaging boundaries; draw one position line otherwise.
        if xyAvgEnabled(1), xLocations = xyAvgRanges(1,:); else, xLocations = xPos; end
        if xyAvgEnabled(2), yLocations = xyAvgRanges(2,:); else, yLocations = yPos; end
        for k=1:2
            if k<=numel(xLocations)
                hXIndicatorXD(im,k).XData = [xLocations(k) xLocations(k)];
                hXIndicatorXD(im,k).YData = [0.5 nDims(orthDim)+0.5];
                hXIndicatorXD(im,k).Visible = 'on';
            else
                hXIndicatorXD(im,k).Visible = 'off';
            end
            if k<=numel(yLocations)
                hYIndicatorYD(im,k).XData = [0.5 nDims(orthDim)+0.5];
                hYIndicatorYD(im,k).YData = [yLocations(k) yLocations(k)];
                hYIndicatorYD(im,k).Visible = 'on';
            else
                hYIndicatorYD(im,k).Visible = 'off';
            end
        end
        end % panels
    end

    function updateImages(recomputeOrth)
        if nargin<1, recomputeOrth = true; end
        titleParts = strings(1,nSliders);
        for d=1:nSliders
            if avgEnabled(d)
                labels(d).Text = sprintf('%s: Average (%d:%d)',dimNames(d),avgRanges(d,1),avgRanges(d,2));
                titleParts(d) = sprintf('%s: Avg [%d:%d]',dimNames(d),avgRanges(d,1),avgRanges(d,2));
            else
                labels(d).Text = sprintf('%s: %d / %d',dimNames(d),idx(d),nDims(d));
                titleParts(d) = sprintf('%s: %d',dimNames(d),idx(d));
            end
        end
        if xyAvgEnabled(1)
            xLabel.Text = sprintf('X: Avg [%d:%d]',xyAvgRanges(1,:));
        else
            xLabel.Text = sprintf('X: %d / %d',xPos,nX);
        end
        if xyAvgEnabled(2)
            yLabel.Text = sprintf('Y: Avg [%d:%d]',xyAvgRanges(2,:));
        else
            yLabel.Text = sprintf('Y: %d / %d',yPos,nY);
        end
        if avgEnabled(orthDim)
            mainPositionLabel.Text = sprintf('Main: %s [%d:%d] (avg)',dimNames(orthDim),avgRanges(orthDim,1),avgRanges(orthDim,2));
        else
            mainPositionLabel.Text = sprintf('Main: %s = %d',dimNames(orthDim),idx(orthDim));
        end
        for im=1:nImages
            if recomputeOrth || isempty(cachedOrthVol{im})
                img = extractData(0,im);
                hMain(im).CData = img;
                hMain(im).AlphaData = double(~isnan(img));
            end
            title(axMain(im),sprintf('%s | %s',imageNames(im),strjoin(titleParts,' | ')), ...
                'Interpreter','none');
            hVertical(im).XData = [xPos xPos];
            hVertical(im).YData = [0.5 nY+0.5];
            hHorizontal(im).XData = [0.5 nX+0.5];
            hHorizontal(im).YData = [xyAvgRanges(2,1) xyAvgRanges(2,1)] * double(xyAvgEnabled(2)) ...
                + [yPos yPos] * double(~xyAvgEnabled(2));
            if xyAvgEnabled(1)
                hVertical(im).XData = [xyAvgRanges(1,1) xyAvgRanges(1,1)];
                hVerticalEnd(im).XData = [xyAvgRanges(1,2) xyAvgRanges(1,2)];
            end
            if xyAvgEnabled(2)
                hHorizontalEnd(im).YData = [xyAvgRanges(2,2) xyAvgRanges(2,2)];
            end
            hVerticalEnd(im).Visible = matlab.lang.OnOffSwitchState(orthEnabled && xyAvgEnabled(1));
            hHorizontalEnd(im).Visible = matlab.lang.OnOffSwitchState(orthEnabled && xyAvgEnabled(2));
            if orthEnabled
                if recomputeOrth || isempty(cachedOrthVol{im}) || cachedOrthDim~=orthDim
                    cachedOrthVol{im} = extractData(orthDim,im);
                end
                vol = cachedOrthVol{im};
                if xyAvgEnabled(2)
                    ydIndices = xyAvgRanges(2,1):xyAvgRanges(2,2);
                    xdSlice = mean(vol(ydIndices,:,:),1,'omitnan');
                else
                    xdSlice = vol(yPos,:,:);
                end
                if xyAvgEnabled(1)
                    xdIndices = xyAvgRanges(1,1):xyAvgRanges(1,2);
                    ydSlice = mean(vol(:,xdIndices,:),2,'omitnan');
                else
                    ydSlice = vol(:,xPos,:);
                end
                xd = reshape(permute(xdSlice,[3 2 1]),nDims(orthDim),nX);
                yd = reshape(ydSlice,nY,nDims(orthDim));
                hXD(im).CData = xd; hXD(im).AlphaData = double(~isnan(xd));
                hYD(im).CData = yd; hYD(im).AlphaData = double(~isnan(yd));
                hXD(im).XData = [1 nX]; hXD(im).YData = [1 nDims(orthDim)];
                hYD(im).XData = [1 nDims(orthDim)]; hYD(im).YData = [1 nY];
                axXD(im).XLim = [0.5 nX+0.5];
                axXD(im).YLim = [0.5 nDims(orthDim)+0.5];
                axYD(im).XLim = [0.5 nDims(orthDim)+0.5];
                axYD(im).YLim = [0.5 nY+0.5];
                if xyAvgEnabled(2)
                    yTitle = sprintf('Y avg [%d:%d]',xyAvgRanges(2,:));
                else
                    yTitle = sprintf('Y = %d',yPos);
                end
                if xyAvgEnabled(1)
                    xTitle = sprintf('X avg [%d:%d]',xyAvgRanges(1,:));
                else
                    xTitle = sprintf('X = %d',xPos);
                end
                title(axXD(im),sprintf('X-%s | %s',dimNames(orthDim),yTitle));
                title(axYD(im),sprintf('Y-%s | %s',dimNames(orthDim),xTitle));
                xlabel(axXD(im),'X'); ylabel(axXD(im),dimNames(orthDim));
                xlabel(axYD(im),dimNames(orthDim)); ylabel(axYD(im),'Y');
            end
        end
        cachedOrthDim = orthDim;
        updateMainPositionIndicators();
        updateOrthogonalIntersectionIndicators();
    end
end