function Hline_range = positionXaxis(imgBW)
% Hline_range = positionXaxis(imgBW)
%
% Return the y pixel values of the horizontal x axis at 0 from the input
% input image based on the longest element, using the Hough transformation.
% 
%   INPUT : 
%               imgBW - must be the BW image
%   OUTPUTS:
%               Hline_range - array of y values of the detected x 
%
% Author: Paolo Tecchio

% Step 1: Rotate the image by 90 degrees
rotatedImage = imrotate(imgBW, 90);

% Step 2: Perform Hough transform
[H, theta, rho] = hough(rotatedImage,"Theta",0);

% Step 3: Find the peaks in the Hough transform
numPeaks = 1; % Set the number of peaks to be detected
peaks = houghpeaks(H, numPeaks);

% Step 4: Retrieve parameter values for the detected lines
lines = houghlines(rotatedImage, theta, rho, peaks);

% Step 5: Find the longest horizontal line
longestLineLength = 0;
longestLineIndex = 0;

for k = 1:length(lines)
    if abs(lines(k).theta) < .1 % Check if the line is approximately horizontal
        lineLength = norm(lines(k).point1 - lines(k).point2);
        if lineLength > longestLineLength
            longestLineLength = lineLength;
            longestLineIndex = k;
        end
    end
end

%if it does not detect any horizontal because of wrong parms, just return
%an empty 
if longestLineIndex==0
    Hline_range = [];
    return
end

xy = [lines(longestLineIndex).point1; lines(longestLineIndex).point2];

%Display the longest horizontal line
% figure;
% imshow(imgBW);
% hold on;
% plot( xy(:, 2),xy(:, 1), 'LineWidth', 2, 'Color', 'red');
% title('Longest Horizontal Line');

%return position (-1 and +1 because it's always a thick line of 3 pixels)
Hline_range = mean(xy(:,1))-1 : 1 : mean(xy(:,1))+1;