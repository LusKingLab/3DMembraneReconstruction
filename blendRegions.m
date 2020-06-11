function [img] = blendRegions(img)
% Function for blending regions of image, interpolates image intensity from
% outside inward. - JW, 20200318
    imgnorm = zeros(size(img)); % Preallocate for speed.
    imgfill = zeros(size(img)); % Preallocate for speed.
    imgrev = zeros(size(img)); % Preallocate for speed.
    h = figure(1); set(h,'WindowStyle','docked')
    for i = 1:size(img,3) 
        imgnorm(:,:,i) = img(:,:,i)/max(max(img(:,:,i))); % Normalize
                                                          % image to
                                                          % visualize w/ im
                                                          % tools.
        imshow(imgnorm(:,:,i))
        prompt = 'Do you want to blend? [y/n] ';
        str = input(prompt,'s');
        if str == 'n'
            imgrev(:,:,i) = imgnorm(:,:,i)*max(max(img(:,:,i))); % Revert.
        elseif str == 'y'
            [~,xi,yi] = roipoly(imgnorm(:,:,i)); % Use polygon tool to 
                                                  % draw polygon around 
                                                  % region to be blended.
                                                  % When finished closing 
                                                  % polygon, double click 
                                                  % in center of polygon
                                                  % to save polygon mask.
            imgfill(:,:,i) = regionfill(imgnorm(:,:,i),xi,yi);
            imgrev(:,:,i) = imgfill(:,:,i)*max(max(img(:,:,i))); % Revert.
        end
    end
    img = imgrev;
end