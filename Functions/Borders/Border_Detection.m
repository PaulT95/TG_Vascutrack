function [bordo_inferiore, bordo_superiore] = Border_Detection(videoFrame, ref_line, Filter)
% [bordo_inferiore, bordo_superiore] = Border_Detection(videoFrame, ref_line, Filter)
%
% Return the interpolated y pixel values of the vessel borders detected from the input
% input image. 
% 
%   INPUT : 
%               videoFrame - must be the image
%               ref_line - array of y pixel where to cut the image in two
%   OPTIONAL:   Filter(boolean) - apply or not the vessel filter (by T.
%   Jerman)
%
%
%   OUTPUTS:
%               Bordo_inferiore - array of y values of the lower vessel
%               border detected
%               Bordo_superiore - array of y values of the top vessel
%               border detected
%
% Author: Paolo Tecchio
if nargin < 3
    Filter = false;
end

data = videoFrame;
%
% tmp = data;
% tmp(tmp < 255/255) = 0; %--> detect white lines
% data = double(data .* ~tmp);
%
[~, m] = size(data);
%increase sharpness
data = imsharpen(data,'Radius',5,'Threshold',0);
%% vesselness  filter
 if Filter == true
    data = (vesselness2D(data, 0.2:1, [0.5 1], 0.75, false));
 end

%% Canny edge
img_filt = edge(data,"canny");

%% split the img in two for the border detection
updata = img_filt;
downdata = img_filt;

for ii = 1:m

    updata(ref_line(ii):end,ii) = 0;
    downdata(1:ref_line(ii),ii) = 0;

end

top_obj = bwpropfilt(updata,'MajorAxisLength',10);
deep_obj = bwpropfilt(downdata,'MajorAxisLength',10);

%go thourgh each pixel column to check the last pixel (or first) to catch
for col = 1:m
    tmp_val = (find(top_obj(:,col),1,'last'));
    if(isempty(tmp_val) || (ref_line(col)- tmp_val)/ ref_line(col) > 0.80 )
        bordo_superiore(col) = nan;
    else
        bordo_superiore(col) =  tmp_val;
    end

    tmp_val =  (find(deep_obj(:,col),1,'first'));
    if(isempty(tmp_val) || (tmp_val - ref_line(col))/ ref_line(col) > 0.55 )
        bordo_inferiore(col) = nan;
    else
        bordo_inferiore(col) =  tmp_val ;
    end
end

clear tmp_val

%fill the nan 
bordo_superiore = fillmissing(bordo_superiore,"linear");
bordo_inferiore = fillmissing(bordo_inferiore,"linear");
% 
% bordo_inferiore = bordo_inferiore(~isnan(bordo_inferiore));
% bordo_superiore = bordo_superiore(~isnan(bordo_superiore));



end