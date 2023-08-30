function [pixeltocm] = spatial_calibration(video_file,n_frame)
%  function [pixeltocm] = spatial_calibration()
% This demo allows you to spatially calibrate your image and then make distance or area measurements.
pixeltocm = 0;
global calibration;
global originalImage;

% Check that user has the Image Processing Toolbox installed.
clc;    % Clear the command window.
close all;  % Close all figures (except those of imtool.)
workspace;  % Make sure the workspace panel is showing.
format long g;
format compact;
fontSize = 20;

hasIPT = license('test', 'image_toolbox');
if ~hasIPT
	% User does not have the toolbox installed.
	message = sprintf('Sorry, but you do not seem to have the Image Processing Toolbox.\nDo you want to try to continue anyway?');
	reply = questdlg(message, 'Toolbox missing', 'Yes', 'No', 'Yes');
	if strcmpi(reply, 'No')
		% User said No, so exit.
		return;
	end
end

% Filter = {'*.mp4'}
% [FileName, PathName] = uigetfile(Filter, 'choose file')
% video = VideoReader(FileName);

% Read in the chosen standard MATLAB demo image. --> read first frame
%originalImage = read(video_file,1);
originalImage = read(video_file,n_frame);
%data = read(video,1);

% Get the dimensions of the image.
% numberOfColorBands should be = 1.
[rows, columns, numberOfColorBands] = size(originalImage);
% Display the original gray scale image.
% figureHandle = figure;
% subplot(1,2, 1);
% imshow(originalImage, []);
% axis on;
% title('Original Grayscale Image', 'FontSize', fontSize);
% % Enlarge figure to full screen.
% set(gcf, 'units','normalized','outerposition',[0 0 1 1]);
% % Give a name to the title bar.
% set(gcf,'name','Demo by ImageAnalyst','numbertitle','off')

figure;
imshow(originalImage); title('Raw Image');

message = sprintf('First you will be doing spatial calibration.');
reply = questdlg(message, 'Calibrate spatially', 'OK', 'Cancel', 'OK');
if strcmpi(reply, 'Cancel')
	% User said Cancel, so exit.
	return;
end
button = 1; % Allow it to enter loop.

while button ~= 4
	if button > 1
		% Let them choose the task, once they have calibrated.
		button = menu('Select a task', 'Re-Calibrate', 'Proceed Analyzing Video');
	end
	switch button
		case 1
			 [pixeltocm] = Calibrate(calibration);
            
			% If they get to here, they clicked properly
			% Change to something else so it will ask them
			% for the task on the next time through the loop.
			button = 99;
		otherwise
			%close(figure); 
            close all;
			break;
	end
end

end

%=====================================================================
function [value] = Calibrate (calibration)
global lastDrawnHandle;

 
try
	%success = false;
	instructions = sprintf('Left click to anchor first endpoint of line.\nRight-click or double-left-click to anchor second endpoint of line.\n\nAfter that I will ask for the real-world distance of the line.');
	title(instructions);
	msgboxw(instructions);

	[cx, cy, rgbValues, xi,yi] = improfile(1000);
	% rgbValues is 1000x1x3.  Call Squeeze to get rid of the singleton dimension and make it 1000x3.
	rgbValues = squeeze(rgbValues);
	distanceInPixels = sqrt( (xi(2)-xi(1)).^2 + (yi(2)-yi(1)).^2);
	if length(xi) < 2
		return;
	end
	% Plot the line.
	hold on;
	lastDrawnHandle = plot(xi, yi, 'y-', 'LineWidth', 4);

	% Ask the user for the real-world distance.
	userPrompt = {'Enter real world units (e.g. mm):','Enter distance in those units:'};
	dialogTitle = 'Specify calibration information';
	numberOfLines = 1;
	def = {'cm', '1'};
	answer = inputdlg(userPrompt, dialogTitle, numberOfLines, def);
	if isempty(answer)
		return;
	end
	calibration.units = answer{1};
	calibration.distanceInPixels = distanceInPixels;
	calibration.distanceInUnits = str2double(answer{2});
	calibration.distancePerPixel = calibration.distanceInUnits / distanceInPixels;
    value = distanceInPixels / calibration.distanceInUnits;
	
	message = sprintf('The distance you drew is %.2f pixels = %f %s.\nThe number of %s per pixel is %f.\nThe number of pixels per %s is %f',...
		distanceInPixels, calibration.distanceInUnits, calibration.units, ...
		calibration.units, calibration.distancePerPixel, ...
		calibration.units, 1/calibration.distancePerPixel);
	uiwait(msgbox(message));
catch ME
	errorMessage = sprintf('Error in function Calibrate().\nDid you first left click and then right click?\n\nError Message:\n%s', ME.message);
	fprintf(1, '%s\n', errorMessage);
	WarnUser(errorMessage);
end

return;	% from Calibrate()
end
%=====================================================================
function msgboxw(message)
	uiwait(msgbox(message));
end
%=====================================================================
function WarnUser(message)
	uiwait(msgbox(message));
end

