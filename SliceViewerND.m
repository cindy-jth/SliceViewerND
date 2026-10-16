function fig = SliceViewerND(data, displayRange, cmap, dimNames, ...
    figName, fig, sliderPosition, nDimensions, dimensionRatio)
% SLICEVIEWERND Interactive N-dimensional image viewer with orthogonal views.
%
% AUTHOR AND VERSION INFORMATION
%
%   Author:       Tianhui (Cindy) Jie
%   Date:         October 16, 2026
%   Version:      1.0.0
%
%   AI Assistance:
%       This function was developed by Tianhui (Cindy) Jie with the
%       assistance of OpenAI ChatGPT (GPT-6, October 16, 2026).
%
%       AI assistance was used for MATLAB code development, debugging,
%       optimization, user-interface design, and documentation.
%
%       The author directed the development, specified the functional
%       requirements, and is responsible for reviewing, validating,
%       and maintaining the final implementation.
%
%   AI Tool Citation:
%       OpenAI. (2026). ChatGPT (GPT-6) [Large language model].
%       https://chatgpt.com/
%
%   Version History:
%       v1.0.0 (2026-10-16)
%           - Interactive visualization of N-dimensional image arrays.
%           - Orthogonal XY, X-D, and Y-D image views.
%           - Independent dimension navigation and averaging controls.
%           - Movable averaging windows.
%           - Adjustable color limits and colormaps.
%           - User-defined physical X:Y:D dimension ratios.
%           - Independent aspect-ratio scaling for each image view.
%           - Improved layout management to prevent image overlap.
%           - Optimized image loading and interactive performance.
%
% DESCRIPTION
%
%   FIG = SLICEVIEWERND(DATA) opens an interactive viewer for visualizing
%   multidimensional numeric arrays. The first two dimensions of DATA are
%   interpreted as the spatial Y and X dimensions, respectively, while
%   dimensions 3 through N can be navigated using independent sliders.
%
%   The viewer supports interactive slice selection, averaging over
%   arbitrary ranges of higher dimensions, orthogonal visualization,
%   adjustable display limits, and physically scaled image rendering.
%
% SYNTAX
%   FIG = SliceViewerND(DATA)
%   FIG = SliceViewerND(DATA, DISPLAYRANGE)
%   FIG = SliceViewerND(DATA, DISPLAYRANGE, CMAP)
%   FIG = SliceViewerND(DATA, DISPLAYRANGE, CMAP, DIMNAMES)
%   FIG = SliceViewerND(DATA, DISPLAYRANGE, CMAP, DIMNAMES, FIGNAME)
%   FIG = SliceViewerND(DATA, DISPLAYRANGE, CMAP, DIMNAMES, FIGNAME, FIG)
%   FIG = SliceViewerND(DATA, DISPLAYRANGE, CMAP, DIMNAMES, FIGNAME, FIG, ...
%                       SLIDERPOSITION, NDIMENSIONS, DIMENSIONRATIO)
%
% INPUT ARGUMENTS
%
%   DATA
%       Real-valued numeric array containing the image data.
%
%       Dimension convention:
%           Dimension 1: Y (image rows)
%           Dimension 2: X (image columns)
%           Dimension 3: First navigable dimension
%           Dimension 4: Second navigable dimension
%           ...
%           Dimension N: (N-2)th navigable dimension
%
%       Supported array sizes include:
%           [Y, X]
%           [Y, X, Z]
%           [Y, X, Z, T]
%           [Y, X, Z, T, R]
%           ...
%
%       Each dimension beyond the first two receives an independent
%       slice-selection slider and averaging controls.
%
%   DISPLAYRANGE
%       Two-element numeric vector specifying the image color limits:
%
%           [minimum maximum]
%
%       Default:
%           [min(DATA(:)), max(DATA(:))]
%
%       The display range can be modified interactively using the
%       CLim controls in the figure toolbar.
%
%       Changing CLim affects only the displayed intensity mapping
%       and does not modify the underlying image data.
%
%   CMAP
%       MATLAB colormap used to display the images.
%
%       Default:
%           gray(256)
%
%       Examples:
%           gray(256)
%           turbo(256)
%           hot(256)
%           parula(256)
%
%   DIMNAMES
%       String array specifying the names of dimensions 3 through N.
%
%       The number of names must equal NDIMENSIONS - 2.
%
%       Default:
%           ["Dimension 3", "Dimension 4", ...]
%
%       Example:
%           ["Depth", "Time", "Repetition"]
%
%       These names appear in the dimension sliders, image titles,
%       and orthogonal-view selection menu.
%
%   FIGNAME
%       String specifying the figure window title.
%
%       Default:
%           "ND Slice Viewer"
%
%   FIG
%       Optional existing MATLAB figure or UIFigure handle.
%
%       If empty, a new UIFigure is created.
%
%       If an existing figure is supplied, its contents are cleared
%       and the viewer is constructed inside that figure.
%
%       Default:
%           []
%
%   SLIDERPOSITION
%       Location of the dimension-navigation controls.
%
%       Options:
%           "bottom"  - Sliders arranged below the image viewer.
%           "right"   - Sliders arranged to the right of the images.
%
%       Default:
%           "bottom"
%
%   NDIMENSIONS
%       Number of dimensions to represent in the viewer.
%
%       This argument is useful when the data contains trailing
%       singleton dimensions that MATLAB does not report through
%       NDIMS(DATA).
%
%       Default:
%           max(3, ndims(DATA))
%
%       Example:
%           size(DATA) = [256 512 100]
%
%           NDIMENSIONS = 5
%
%       The viewer treats DATA as having dimensions:
%           [256 512 100 1 1]
%
%       NDIMENSIONS must be at least max(3, ndims(DATA)).
%
%   DIMENSIONRATIO
%       Three-element positive numeric vector specifying the relative
%       physical spacing of the X, Y, and selected orthogonal dimension D.
%
%       Format:
%           [X Y D]
%
%       Default:
%           [1 1 1]
%
%       Example:
%           [1 1 2]
%
%       This indicates that one sample along D represents twice the
%       physical distance of one sample along X or Y.
%
%       The ratios are applied independently to the three image views:
%
%           XY view:
%               Horizontal axis = X
%               Vertical axis   = Y
%               Aspect ratio    = X:Y
%
%           X-D view:
%               Horizontal axis = X
%               Vertical axis   = D
%               Aspect ratio    = X:D
%
%           Y-D view:
%               Horizontal axis = D
%               Vertical axis   = Y
%               Aspect ratio    = D:Y
%
%       Ratios can be modified interactively using the X, Y, and D
%       numeric fields in the figure toolbar.
%
%       The D field is visible only when orthogonal views are enabled.
%
%       Each view is scaled independently so that changing one
%       dimension ratio does not unnecessarily resize a view that
%       does not contain that dimension.
%
% OUTPUT ARGUMENT
%
%   FIG
%       Handle to the UIFigure containing the interactive viewer.
%
%       The returned handle can be used to:
%           - Change the figure size or position
%           - Modify figure properties
%           - Close the viewer programmatically
%
%       Example:
%           FIG.Position = [100 100 1600 900];
%
%
% INTERACTIVE FEATURES
%
%   1. SLICE NAVIGATION
%
%       Each dimension beyond X and Y has an independent slider.
%
%       Moving a slider updates the displayed XY image while keeping
%       the other dimensions fixed at their currently selected indices.
%
%       Slider values are rounded to integer indices.
%
%
%   2. DIMENSION AVERAGING
%
%       Each navigable dimension includes an Average toggle.
%
%       When averaging is enabled:
%           - The corresponding slice-selection slider is disabled.
%           - The selected range of slices is averaged.
%           - The averaging range is controlled by Start and End fields.
%           - A Window Position slider becomes available.
%
%       Averaging is performed using:
%
%           mean(DATA, dimension, 'omitnan')
%
%       NaN values are ignored during averaging.
%
%       Multiple dimensions can be averaged simultaneously.
%
%
%   3. MOVABLE AVERAGING WINDOW
%
%       The Window Position slider shifts the averaging interval
%       without changing its width.
%
%       Example:
%           Initial averaging range: [10 20]
%           Window width:            11 slices
%
%           Moving the window to 30 produces:
%           New averaging range:     [30 40]
%
%       The averaging window is constrained to remain within the
%       valid indices of the corresponding dimension.
%
%       If the averaging window spans the entire dimension, its
%       position cannot change.
%
%
%   4. ORTHOGONAL VIEWS
%
%       The Orthogonal Views button enables two additional images:
%
%           XY  - Main image
%           X-D - Cross-section at the selected Y position
%           Y-D - Cross-section at the selected X position
%
%       D corresponds to the higher dimension selected in the
%       Dimension dropdown.
%
%       For example, if D is the third dimension:
%
%           XY = DATA(:,:,d)
%           XD = squeeze(DATA(y,:,:))
%           YD = squeeze(DATA(:,x,:))
%
%       The X and Y position sliders select the intersection
%       coordinates used to construct the orthogonal images.
%
%       The three views are linked through position indicators.
%
%
%   5. POSITION INDICATORS
%
%       The main XY image contains:
%           Green vertical line - Selected X position
%           Red horizontal line - Selected Y position
%
%       The orthogonal views contain corresponding intersection
%       indicators and yellow dashed lines identifying the
%       selected D position or averaging interval.
%
%       When averaging is enabled along D, two yellow dashed lines
%       indicate the beginning and end of the averaging range.
%
%
%   6. PHYSICAL ASPECT RATIO
%
%       Image aspect ratios are determined by the physical spacing
%       of the displayed dimensions.
%
%       The viewer uses MATLAB's DataAspectRatio property to
%       preserve the specified relative physical dimensions.
%
%       Each image view is handled independently to prevent
%       unrelated dimension-ratio changes from shrinking other views.
%
%       The layout separates the three views to prevent overlapping
%       images when orthogonal visualization is enabled.
%
%       Some unused space may remain when preserving the physical
%       aspect ratio within a fixed-size figure.
%
%
%   7. DISPLAY RANGE AND COLORMAP
%
%       All image views share the same colormap and color limits.
%
%       The CLim minimum and maximum can be modified interactively.
%
%       These adjustments change visualization only and do not
%       modify DATA.
%
%
% USAGE EXAMPLES
%
%   EXAMPLE 1: Basic 3D image stack
%
%       data = rand(256,512,100);
%
%       fig = SliceViewerND(data);
%
%       Opens a viewer displaying 2D slices of a 3D array.
%       The third dimension is controlled by a slider.
%
%
%   EXAMPLE 2: Custom display range and colormap
%
%       data = rand(256,512,100);
%
%       fig = SliceViewerND(data,[0 1],turbo(256));
%
%       Displays the image using the turbo colormap with
%       color limits between 0 and 1.
%
%
%   EXAMPLE 3: Multidimensional OCT dataset
%
%       data = rand(512,1024,200,10,5);
%
%       dimNames = ["B-scan","Repetition","Cycle"];
%
%       fig = SliceViewerND(data,[0 1],gray(256),dimNames);
%
%       Creates a viewer with three independent navigation sliders.
%
%       Dimensions:
%           Y          = 512 pixels
%           X          = 1024 pixels
%           B-scan     = 200
%           Repetition = 10
%           Cycle      = 5
%
%
%   EXAMPLE 4: Place sliders on the right
%
%       data = rand(256,512,100,20);
%
%       fig = SliceViewerND(data,[0 1],turbo(256), ...
%           ["Depth","Time"],"4D Image Viewer",[],"right");
%
%       Places the dimension sliders to the right of the image.
%
%
%   EXAMPLE 5: Specify physical dimension ratios
%
%       data = rand(256,512,100);
%
%       dimensionRatio = [1 1 2];
%
%       fig = SliceViewerND(data,[0 1],gray(256), ...
%           "Depth","Physical Image Viewer",[],"right",3, ...
%           dimensionRatio);
%
%       Uses relative physical sample spacings:
%           X = 1
%           Y = 1
%           D = 2
%
%       When orthogonal views are enabled, the D dimension is
%       displayed with twice the physical spacing of X and Y.
%
%
%   EXAMPLE 6: OCT volume with anisotropic voxel spacing
%
%       data = rand(512,1024,256,10);
%
%       % Physical sample spacing in micrometers
%       dx = 5;
%       dy = 5;
%       dz = 2;
%
%       dimensionRatio = [dx dy dz];
%
%       fig = SliceViewerND(data,[0 1],gray(256), ...
%           ["Depth","Repetition"], ...
%           "OCT Volume",[], ...
%           "right",4,dimensionRatio);
%
%       The viewer uses the relative physical spacing to render
%       geometrically scaled cross-sectional images.
%
%       Note that D always corresponds to the dimension currently
%       selected in the orthogonal-view dropdown.
%
%       If different higher dimensions have different physical
%       spacings, update the D ratio when changing the selected
%       orthogonal dimension.
%
%
%   EXAMPLE 7: Explicit trailing singleton dimensions
%
%       data = rand(256,512,100);
%
%       fig = SliceViewerND(data,[0 1],gray(256), ...
%           ["Depth","Time","Cycle"], ...
%           "5D Viewer",[],"bottom",5);
%
%       Treats the input as a five-dimensional array with size:
%
%           [256 512 100 1 1]
%
%
%   EXAMPLE 8: Display a processed OCT image stack
%
%       % Example logarithmic intensity image
%       data = rand(512,1024,100);
%       dataDB = 20*log10(data + eps);
%
%       fig = SliceViewerND(dataDB,[-60 0],gray(256), ...
%           "B-scan","OCT Intensity (dB)",[],"right",3, ...
%           [1 1 1]);
%
%       Displays the logarithmic OCT intensity with a fixed
%       dynamic range of -60 to 0 dB.
%
%
% NOTES
%
%   - The first two dimensions are always interpreted as Y and X.
%   - Orthogonal views can be enabled or disabled interactively.
%   - D refers to the selected higher dimension, not necessarily
%     the third dimension of DATA.
%   - Averaging is performed independently across enabled dimensions.
%   - NaN values are ignored during averaging.
%   - Physical dimension ratios control visualization geometry only.
%   - The original input array is not modified.
%   - Large multidimensional datasets may require substantial memory.
%   - Interactive performance depends on dataset size and averaging range.
%   - The viewer uses UIFigure, UIAxes, and UIGridLayout components.
%
% SEE ALSO
%   imagesc, sliceViewer, uifigure, uiaxes, uislider, uigridlayout,
%   daspect, clim, colormap, mean
%

    arguments
        data {mustBeNumeric,mustBeReal}
        displayRange (1,2) double = [min(data(:)), max(data(:))]
        cmap = gray(256)
        dimNames string = string.empty
        figName (1,1) string = "ND Slice Viewer"
        fig = []
        sliderPosition (1,1) string {mustBeMember(sliderPosition,["bottom","right"])} = "bottom"
        nDimensions (1,1) double = NaN
        dimensionRatio (1,3) double {mustBePositive,mustBeFinite} = [1 1 1]
    end

    if isempty(data)
        error('sliceViewerND:EmptyData','data must not be empty.');
    end
    if any(~isfinite(displayRange)) || displayRange(1)>=displayRange(2)
        error('sliceViewerND:CLim','displayRange must be finite and increasing.');
    end
    if isnan(nDimensions)
        nDimensions = max(3,ndims(data));
    end
    if ~isfinite(nDimensions) || nDimensions~=fix(nDimensions) || ...
            nDimensions<max(3,ndims(data))
        error('sliceViewerND:Dimensions','Invalid nDimensions.');
    end
    nSliders = nDimensions-2;
    nY = size(data,1);
    nX = size(data,2);
    nDims = arrayfun(@(d) size(data,d+2),1:nSliders);
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
    currentDisplayRange = displayRange;
    currentDimensionRatio = dimensionRatio;
    cachedOrthVol = [];
    cachedOrthDim = 0;

    if isempty(fig)
        % Choose an initial window size based on the physical XY image shape.
        % Reserve space for the toolbar, controls, and axes decorations.
        imageRatio = (nX*dimensionRatio(1))/(nY*dimensionRatio(2));
        imageRatio = max(0.25,min(5,imageRatio));
        if sliderPosition=="bottom"
            controlsHeight = 145*nSliders+10*max(0,nSliders-1);
            figHeight = max(750,min(1100,controlsHeight+450));
            plotHeight = max(240,figHeight-controlsHeight-110);
            figWidth = max(980,min(1750,round(plotHeight*imageRatio+160)));
        else
            figHeight = max(700,min(1100,round(620/max(imageRatio,0.6)+100)));
            plotHeight = figHeight-110;
            figWidth = max(1050,min(1750,round(plotHeight*imageRatio+530)));
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

    toolbarGL = uigridlayout(outerGL,[1 6]);
    toolbarGL.Layout.Row = 1;
    toolbarGL.Layout.Column = 1;
    toolbarGL.RowHeight = {'1x'};
    toolbarGL.ColumnWidth = {150,85,160,'1x',245,320};
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

    climGL = uigridlayout(toolbarGL,[1 4]);
    climGL.Layout.Column = 5;
    climGL.ColumnWidth = {45,'1x',20,'1x'};
    climGL.RowHeight = {'1x'};
    climGL.Padding = [0 0 0 0];
    climGL.ColumnSpacing = 4;
    uilabel(climGL,'Text','CLim:','HorizontalAlignment','right');
    displayMinField = uieditfield(climGL,'numeric','Value',displayRange(1), ...
        'ValueDisplayFormat','%.5g');
    uilabel(climGL,'Text','to','HorizontalAlignment','center');
    displayMaxField = uieditfield(climGL,'numeric','Value',displayRange(2), ...
        'ValueDisplayFormat','%.5g');

    ratioGL = uigridlayout(toolbarGL,[1 7]);
    ratioGL.Layout.Column = 6;
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
        workspaceGL.RowHeight = {'1x',145*nSliders+10*(nSliders-1)};
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
        imageAreaGL = uigridlayout(workspaceGL,[1 2]);
        imageAreaGL.ColumnWidth = {'1x',0};
        imageAreaGL.RowHeight = {'1x'};
    else
        imageAreaGL = uigridlayout(workspaceGL,[2 1]);
        imageAreaGL.RowHeight = {'1x',0};
        imageAreaGL.ColumnWidth = {'1x'};
    end
    imageAreaGL.Layout.Row = 1;
    imageAreaGL.Layout.Column = 1;
    imageAreaGL.Padding = [0 0 0 0];
    imageAreaGL.RowSpacing = 0;
    imageAreaGL.ColumnSpacing = 0;

    imageGL = uigridlayout(imageAreaGL,[2 2]);
    imageGL.Layout.Row = 1;
    imageGL.Layout.Column = 1;
    imageGL.RowHeight = {'1x',0};
    imageGL.ColumnWidth = {'1x',0};
    imageGL.RowSpacing = 0;
    imageGL.ColumnSpacing = 0;
    imageGL.Padding = [0 0 0 0];

    % Separate clipped containers prevent axes, labels, and plot boxes
    % from painting into neighboring panes during a layout transition.
    mainPane = uipanel(imageGL,'BorderType','none');
    mainPane.Layout.Row = 1;
    mainPane.Layout.Column = 1;
    xdPane = uipanel(imageGL,'BorderType','none');
    xdPane.Layout.Row = 2;
    xdPane.Layout.Column = 1;
    ydPane = uipanel(imageGL,'BorderType','none');
    ydPane.Layout.Row = 1;
    ydPane.Layout.Column = 2;

    mainPaneGL = uigridlayout(mainPane,[1 1], ...
        'Padding',[6 6 6 6],'RowHeight',{'1x'},'ColumnWidth',{'1x'});
    xdPaneGL = uigridlayout(xdPane,[1 1], ...
        'Padding',[12 12 12 12],'RowHeight',{'1x'},'ColumnWidth',{'1x'});
    ydPaneGL = uigridlayout(ydPane,[1 1], ...
        'Padding',[12 12 12 12],'RowHeight',{'1x'},'ColumnWidth',{'1x'});

    axMain = uiaxes(mainPaneGL);
    initialSubs = repmat({1},1,nDimensions);
    initialSubs(1:2) = {':',':'};
    hMain = imagesc(axMain,reshape(data(initialSubs{:}),nY,nX));
    axMain.XTick = [];
    axMain.YTick = [];
    axMain.XLim = [0.5 nX+0.5];
    axMain.YLim = [0.5 nY+0.5];
    axMain.XLimMode = 'manual';
    axMain.YLimMode = 'manual';
    colormap(axMain,cmap);
    clim(axMain,currentDisplayRange);
    colorbar(axMain);

    axXD = uiaxes(xdPaneGL);
    hXD = imagesc(axXD,zeros(nDims(1),nX));
    colormap(axXD,cmap);
    clim(axXD,currentDisplayRange);
    axXD.Visible = 'off';

    axYD = uiaxes(ydPaneGL);
    hYD = imagesc(axYD,zeros(nY,nDims(1)));
    colormap(axYD,cmap);
    clim(axYD,currentDisplayRange);
    axYD.Visible = 'off';

    hold(axMain,'on');
    hVertical = line(axMain,[xPos xPos],[0.5 nY+0.5], ...
        'Color','g','LineWidth',1.5,'Visible','off','HitTest','off');
    hHorizontal = line(axMain,[0.5 nX+0.5],[yPos yPos], ...
        'Color','r','LineWidth',1.5,'Visible','off','HitTest','off');
    hold(axMain,'off');

    hMainXD = gobjects(1,2);
    hMainYD = gobjects(1,2);
    hold(axXD,'on');
    for k=1:2
        hMainXD(k) = line(axXD,[0.5 nX+0.5],[1 1], ...
            'Color','y','LineWidth',1.5,'LineStyle','--', ...
            'Visible','off','HitTest','off');
    end
    hXIndicatorXD = line(axXD,[xPos xPos],[0.5 nDims(1)+0.5], ...
        'Color','g','LineWidth',1.5,'Visible','off','HitTest','off');
    hold(axXD,'off');
    hold(axYD,'on');
    for k=1:2
        hMainYD(k) = line(axYD,[1 1],[0.5 nY+0.5], ...
            'Color','y','LineWidth',1.5,'LineStyle','--', ...
            'Visible','off','HitTest','off');
    end
    hYIndicatorYD = line(axYD,[0.5 nDims(1)+0.5],[yPos yPos], ...
        'Color','r','LineWidth',1.5,'Visible','off','HitTest','off');
    hold(axYD,'off');

    orthControlsGL = uigridlayout(imageAreaGL,[2 2]);
    if sliderPosition=="bottom"
        orthControlsGL.Layout.Row = 1;
        orthControlsGL.Layout.Column = 2;
        orthControlsGL.RowHeight = {100,100};
        orthControlsGL.ColumnWidth = {85,'1x'};
    else
        orthControlsGL.Layout.Row = 2;
        orthControlsGL.Layout.Column = 1;
        orthControlsGL.RowHeight = {30,35};
        orthControlsGL.ColumnWidth = {'1x','1x'};
    end
    orthControlsGL.Padding = [10 10 10 10];
    orthControlsGL.RowSpacing = 10;
    orthControlsGL.ColumnSpacing = 10;
    orthControlsGL.Visible = 'off';

    xLabel = uilabel(orthControlsGL,'Text',sprintf('X: %d / %d',xPos,nX), ...
        'HorizontalAlignment','center');
    xSlider = uislider(orthControlsGL,'Limits',[1 max(2,nX)],'Value',xPos, ...
        'MajorTicks',[],'MinorTicks',[]);
    yLabel = uilabel(orthControlsGL,'Text',sprintf('Y: %d / %d',yPos,nY), ...
        'HorizontalAlignment','center');
    ySlider = uislider(orthControlsGL,'Limits',[1 max(2,nY)],'Value',yPos, ...
        'MajorTicks',[],'MinorTicks',[]);
    if sliderPosition=="bottom"
        xLabel.Layout.Row = 1; xLabel.Layout.Column = 1;
        xSlider.Layout.Row = 1; xSlider.Layout.Column = 2;
        yLabel.Layout.Row = 2; yLabel.Layout.Column = 1;
        ySlider.Layout.Row = 2; ySlider.Layout.Column = 2;
    else
        xLabel.Layout.Row = 1; xLabel.Layout.Column = 1;
        xSlider.Layout.Row = 2; xSlider.Layout.Column = 1;
        yLabel.Layout.Row = 1; yLabel.Layout.Column = 2;
        ySlider.Layout.Row = 2; ySlider.Layout.Column = 2;
    end
    if nX==1, xSlider.Enable = 'off'; end
    if nY==1, ySlider.Enable = 'off'; end

    controlsGL = uigridlayout(workspaceGL,[nSliders 1]);
    if sliderPosition=="bottom"
        controlsGL.Layout.Row = 2;
        controlsGL.Layout.Column = 1;
    else
        controlsGL.Layout.Row = 1;
        controlsGL.Layout.Column = 2;
    end
    controlsGL.RowHeight = repmat({145},1,nSliders);
    controlsGL.ColumnWidth = {'1x'};
    controlsGL.RowSpacing = 10;
    controlsGL.Padding = [0 0 0 0];

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
        panel.Layout.Row = d;
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

    updateImages();
    updateDimensionRatios();

    function updateDisplayRange()
        newLimits = [displayMinField.Value,displayMaxField.Value];
        if any(~isfinite(newLimits)) || newLimits(1)>=newLimits(2)
            displayMinField.Value = currentDisplayRange(1);
            displayMaxField.Value = currentDisplayRange(2);
            uialert(fig,'CLim minimum must be smaller than its maximum.', ...
                'Invalid Display Range');
            return;
        end
        currentDisplayRange = newLimits;
        clim(axMain,newLimits);
        clim(axXD,newLimits);
        clim(axYD,newLimits);
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
        daspect(axMain,[normalizedRatios(1),normalizedRatios(2),1]); % XY
        daspect(axXD,  [normalizedRatios(1),normalizedRatios(3),1]); % X-D
        daspect(axYD,  [normalizedRatios(3),normalizedRatios(2),1]); % Y-D
        % Keep pane allocations fixed; only update each axes aspect.
    end

    function updatePhysicalLayout()
        % Keep the grid allocations independent of X:Y:D ratios.
        % Changing Y must not resize the X-D pane; changing X must not
        % resize the Y-D pane. Physical scaling is enforced separately
        % by daspect() on each axes, not by coupled grid weights.
        if orthEnabled
            imageGL.RowHeight = {'1x','0.55x'};
            imageGL.ColumnWidth = {'1x','0.55x'};
        else
            imageGL.RowHeight = {'1x',0};
            imageGL.ColumnWidth = {'1x',0};
        end
    end

    function sliceCallback(d,value)
        idx(d) = min(max(round(value),1),nDims(d));
        updateImages();
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
        width = diff(avgRanges(d,:))+1;
        maxStart = nDims(d)-width+1;
        a = min(max(round(value),1),maxStart);
        avgRanges(d,:) = [a,a+width-1];
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

    function orthToggle(value)
        orthEnabled = logical(value);
        ratioDLabel.Visible = matlab.lang.OnOffSwitchState(orthEnabled);
        ratioDField.Visible = matlab.lang.OnOffSwitchState(orthEnabled);
        if orthEnabled
            % Maintain enough physical room for three independent image panes.
            % MATLAB otherwise may draw axes decorations over adjacent panes.
            oldUnits = fig.Units;
            fig.Units = 'pixels';
            pos = fig.Position;
            if sliderPosition=="bottom"
                pos(3) = max(pos(3),1100);
                pos(4) = max(pos(4),700);
            else
                pos(3) = max(pos(3),1250);
                pos(4) = max(pos(4),720);
            end
            fig.Position = pos;
            fig.Units = oldUnits;
            ratioGL.ColumnWidth = {45,16,'1x',16,'1x',16,'1x'};
            orthControlsGL.Visible = 'on';
            mainPositionLabel.Visible = 'on';
            hVertical.Visible = 'on';
            hHorizontal.Visible = 'on';
            updatePhysicalLayout();
            % Settle grid dimensions before exposing orthogonal axes.
            drawnow;
            axXD.Visible = 'on';
            axYD.Visible = 'on';
            imageGL.RowSpacing = 24;
            imageGL.ColumnSpacing = 24;
            if sliderPosition=="bottom"
                imageAreaGL.ColumnWidth = {'1x',250};
                imageAreaGL.ColumnSpacing = 8;
            else
                imageAreaGL.RowHeight = {'1x',95};
                imageAreaGL.RowSpacing = 8;
            end
        else
            ratioGL.ColumnWidth = {45,16,'1x',16,'1x',0,0};
            orthControlsGL.Visible = 'off';
            mainPositionLabel.Visible = 'off';
            hVertical.Visible = 'off';
            hHorizontal.Visible = 'off';
            axXD.Visible = 'off';
            axYD.Visible = 'off';
            hXIndicatorXD.Visible = 'off';
            hYIndicatorYD.Visible = 'off';
            imageGL.RowHeight = {'1x',0};
            imageGL.ColumnWidth = {'1x',0};
            imageGL.RowSpacing = 0;
            imageGL.ColumnSpacing = 0;
            if sliderPosition=="bottom"
                imageAreaGL.ColumnWidth = {'1x',0};
                imageAreaGL.ColumnSpacing = 0;
            else
                imageAreaGL.RowHeight = {'1x',0};
                imageAreaGL.RowSpacing = 0;
            end
        end
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
            xPos = min(max(round(value),1),nX);
        else
            yPos = min(max(round(value),1),nY);
        end
        updateImages();
    end

    function img = extractData(excludeDim)
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
        img = data(subs{:});
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
        if ~orthEnabled
            for k=1:2
                hMainXD(k).Visible = 'off';
                hMainYD(k).Visible = 'off';
            end
            return;
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
                hMainXD(k).XData = [0.5 nX+0.5];
                hMainXD(k).YData = [pos pos];
                hMainYD(k).XData = [pos pos];
                hMainYD(k).YData = [0.5 nY+0.5];
                hMainXD(k).Visible = 'on';
                hMainYD(k).Visible = 'on';
            else
                hMainXD(k).Visible = 'off';
                hMainYD(k).Visible = 'off';
            end
        end
    end

    function updateOrthogonalIntersectionIndicators()
        if ~orthEnabled
            hXIndicatorXD.Visible = 'off';
            hYIndicatorYD.Visible = 'off';
            return;
        end
        hXIndicatorXD.XData = [xPos xPos];
        hXIndicatorXD.YData = [0.5 nDims(orthDim)+0.5];
        hXIndicatorXD.Visible = 'on';
        hYIndicatorYD.XData = [0.5 nDims(orthDim)+0.5];
        hYIndicatorYD.YData = [yPos yPos];
        hYIndicatorYD.Visible = 'on';
    end

    function updateImages(recomputeOrth)
        if nargin<1, recomputeOrth = true; end
        % Position-only changes reuse the already extracted orthogonal volume.
        if recomputeOrth || isempty(cachedOrthVol)
            hMain.CData = extractData(0);
        end
        titleParts = strings(1,nSliders);
        for d=1:nSliders
            if avgEnabled(d)
                labels(d).Text = sprintf('%s: Average (%d:%d)', ...
                    dimNames(d),avgRanges(d,1),avgRanges(d,2));
                titleParts(d) = sprintf('%s: Avg [%d:%d]', ...
                    dimNames(d),avgRanges(d,1),avgRanges(d,2));
            else
                labels(d).Text = sprintf('%s: %d / %d', ...
                    dimNames(d),idx(d),nDims(d));
                titleParts(d) = sprintf('%s: %d',dimNames(d),idx(d));
            end
        end
        title(axMain,strjoin(titleParts,' | '));
        xLabel.Text = sprintf('X: %d / %d',xPos,nX);
        yLabel.Text = sprintf('Y: %d / %d',yPos,nY);
        hVertical.XData = [xPos xPos];
        hVertical.YData = [0.5 nY+0.5];
        hHorizontal.XData = [0.5 nX+0.5];
        hHorizontal.YData = [yPos yPos];
        if avgEnabled(orthDim)
            mainPositionLabel.Text = sprintf('Main: %s [%d:%d] (avg)', ...
                dimNames(orthDim),avgRanges(orthDim,1),avgRanges(orthDim,2));
        else
            mainPositionLabel.Text = sprintf('Main: %s = %d', ...
                dimNames(orthDim),idx(orthDim));
        end
        if orthEnabled
            if recomputeOrth || isempty(cachedOrthVol) || cachedOrthDim~=orthDim
                cachedOrthVol = extractData(orthDim);
                cachedOrthDim = orthDim;
            end
            vol = cachedOrthVol;
            hXD.CData = reshape(permute(vol(yPos,:,:),[3 2 1]), ...
                nDims(orthDim),nX);
            hYD.CData = reshape(vol(:,xPos,:),nY,nDims(orthDim));
            hXD.XData = [1 nX];
            hXD.YData = [1 nDims(orthDim)];
            hYD.XData = [1 nDims(orthDim)];
            hYD.YData = [1 nY];
            axXD.XLim = [0.5 nX+0.5];
            axXD.YLim = [0.5 nDims(orthDim)+0.5];
            axYD.XLim = [0.5 nDims(orthDim)+0.5];
            axYD.YLim = [0.5 nY+0.5];
            title(axXD,sprintf('X-%s | Y = %d',dimNames(orthDim),yPos));
            title(axYD,sprintf('Y-%s | X = %d',dimNames(orthDim),xPos));
            xlabel(axXD,'X'); ylabel(axXD,dimNames(orthDim));
            xlabel(axYD,dimNames(orthDim)); ylabel(axYD,'Y');
        end
        updateMainPositionIndicators();
        updateOrthogonalIntersectionIndicators();
    end
end
