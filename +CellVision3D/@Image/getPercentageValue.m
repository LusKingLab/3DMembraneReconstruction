function [th,bins,counts,threshind] = getPercentageValue( img, percent )
% Find the threshould above which the double image has percent pixes above
% Input:
%       img
%       percentage
% 11/20/2015 Yao Zhao

dimg=double(img(:));
mindimg=min(dimg);
maxdimg=max(dimg);
[counts,bins]=hist((dimg-mindimg)/(maxdimg-mindimg),0:0.01:1);

% Find threshold index for plotting histogram of counts and upper and lower 
% thresholds.
thresh = percent*sum(counts);
threshind = [];
for i = 1:length(counts)
    if sum(counts(1:i)) > thresh
        threshind = i;
        break
    end
end

cumcounts=cumsum(counts);
countfilter=cumcounts>(percent*sum(counts));
th_index=[countfilter(2:end)-countfilter(1:end-1),0];
th=bins(th_index==1)*(maxdimg-mindimg)+mindimg;
if isempty(th)
    th=0;
    warning('all image save value');
end

end

