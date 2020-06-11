function [ cnt2 ] = RemoveNearBorder( cnt,img,half_win )
%remove centroid near the border of the image within half window size
cnt2=[];
[sizey,sizex]=size(img);
maxx=sizex-half_win;
maxy=sizey-half_win;
for i=1:size(cnt,1)
    if cnt(i,1)>half_win && cnt(i,1)<maxx ...
            && cnt(i,2)>half_win && cnt(i,2)<maxy
        cnt2=[cnt2;cnt(i,:)];
    end
end
end

