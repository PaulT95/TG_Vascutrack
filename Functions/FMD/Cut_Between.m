function [ref_line] = Cut_Between(videoFrame)
% [ref_line] = Cut_Between(videoFrame)
% 
% Return the interpolated y pixel values of the input image based on where
% the clicks (ginput) are performed by the user.
% 
%   INPUT : 
%               x - must be an image
%
%
%   OUTPUTS:
%               ref_line - array of y values
%
% Author: Paolo Tecchio


%% cut in between
frame = imsharpen(videoFrame,"Radius",3,'Threshold',0);

%show image and click to cut in between
figure('WindowState','fullscreen')
imshow(frame); hold on
title('2 clicks to cut the image in between the two borders')

[n,m] = size(videoFrame);
[x,y] = ginputYellow(2);
ref_line = round((interp1(x(1:2),y(1:2),1:m,'linear','extrap')));
plot(ref_line,'linew',3);

pause(1.5)

close    


