function varargout = prostate_segmentation(varargin)
% PROSTATE_SEGMENTATION MATLAB code for prostate_segmentation.fig
%      PROSTATE_SEGMENTATION, by itself, creates a new PROSTATE_SEGMENTATION or raises the existing
%      singleton*.
%
%      H = PROSTATE_SEGMENTATION returns the handle to a new PROSTATE_SEGMENTATION or the handle to
%      the existing singleton*.
%
%      PROSTATE_SEGMENTATION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PROSTATE_SEGMENTATION.M with the given input arguments.
%
%      PROSTATE_SEGMENTATION('Property','Value',...) creates a new PROSTATE_SEGMENTATION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before prostate_segmentation_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to prostate_segmentation_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help prostate_segmentation

% Last Modified by GUIDE v2.5 17-May-2018 00:35:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @prostate_segmentation_OpeningFcn, ...
                   'gui_OutputFcn',  @prostate_segmentation_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before prostate_segmentation is made visible.
function prostate_segmentation_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to prostate_segmentation (see VARARGIN)

% Choose default command line output for prostate_segmentation
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes prostate_segmentation wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = prostate_segmentation_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in Load.
function Load_Callback(hObject, eventdata, handles)
% hObject    handle to Load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Load the images in the folder DICOM
filename = imgetfile;
global File;
File = dicomread(filename);
%Display
axes(handles.Input);
imshow(File,[0 255]);

% --- Executes on button press in Save.
function Save_Callback(hObject, eventdata, handles)
% hObject    handle to Save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)




% --- Executes on button press in Segmentation.
function Segmentation_Callback(hObject, eventdata, handles)
% hObject    handle to Segmentation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
regionP = imfreehand();
setColor(regionP,'g');


% Create a binary image ("mask") from the ROI object.
binaryImage = regionP.createMask();
handles.binaryImagesZP(:,:,handles.sizeRegions)=binaryImage;

% Get coordinates of the boundary of the freehand drawn region.
structBoundaries = bwboundaries(binaryImage);
xy=structBoundaries{1}; % Get n by 2 array of x,y coordinates.
y = xy(:, 1); % Rows.
x = xy(:, 2); % Columns.


handles.boundaryImagesZP(:,:,handles.sizeRegions)=zeros(size(binaryImage));
for i=1:size(x)
    handles.boundaryImagesZP(y(i),x(i),handles.sizeRegions)=255;
end

% Mask the image outside the mask, and display it.
% Will keep only the part of the image that's inside the mask, zero outside mask.
[X, map] = dicomread([handles.pathname handles.filenames{1,handles.currentSegmentImage}]);
grayImage = mat2gray(X);
blackMaskedImage = grayImage;
blackMaskedImage(~binaryImage) = 0;
handles.blackMaskedImagesZP(:,:,handles.sizeRegions)=blackMaskedImage;

% Now crop the image.
handles.leftColumnZP(handles.sizeRegions) = min(x);
handles.rightColumnZP(handles.sizeRegions) = max(x);
handles.topLineZP(handles.sizeRegions) = min(y);
handles.bottomLineZP(handles.sizeRegions) = max(y);
handles.widthZP(handles.sizeRegions) = handles.rightColumnZP(handles.sizeRegions) - handles.leftColumnZP(handles.sizeRegions) + 1;
handles.heightZP(handles.sizeRegions) = handles.bottomLineZP(handles.sizeRegions) - handles.topLineZP(handles.sizeRegions) + 1;

guidata(hObject, handles);



% --- Executes on button press in GraphCut.
function GraphCut_Callback(hObject, eventdata, handles)
% hObject    handle to GraphCut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


global File;

% energy function
G = imageSegmenter(File)
axes(handles.Output);
imshow(G);

% --- Executes on button press in Labelling.
function Labelling_Callback(hObject, eventdata, handles)
% hObject    handle to Labelling (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in LevelSet.
function LevelSet_Callback(hObject, eventdata, handles)
% hObject    handle to LevelSet (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Display the DICE similarity coeff 
%set(handles.text18, 'String', 'Loading Done!');
%set(handles.text17,'String',info_original(1).InstanceNumber);


% --- Executes on button press in DICE.
function DICE_Callback(hObject, eventdata, handles)
% hObject    handle to DICE (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
