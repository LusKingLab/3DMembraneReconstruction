function [ img2 ] = imerode3( img, se )
%3d erode image
%se is a 3d kernal image
%use non zero area to define the shape, se consist of only 0 and 1
% mask values are not enabled yet, will be adjusted in the future

[wy,wx,wz]=size(img);
[wy1,wx1,wz1]=size(se);
hwy=(wy1-1)/2;
hwx=(wx1-1)/2;
hwz=(wz1-1)/2;

img2=zeros(wy+wy1-1,wx+wx1-1,wz+wz1-1)+inf;
img2(hwy+1:hwy+wy,hwx+1:hwx+wx,hwz+1:hwz+wz)=img;

for i=hwy+1:hwy+wy
    i
    for j=hwx+1:hwx+wx
        for k=hwz+1:hwz+wz
            wimg=img2(i-hwy:i+hwy,j-hwx:j+hwx,k-hwz:k+hwz);
            wimg(se==0)=inf;
            img2(i,j,k)= min(wimg(:));
        end
    end
end

end


