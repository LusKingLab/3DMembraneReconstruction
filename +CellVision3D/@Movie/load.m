function [ obj ]=load(obj,varargin)
%load movie
% 3/21/2015
% Yao Zhao

if ~exist(obj.filein,'file')
    warning('invalid movie data path');
    
    
else
    % ui select
    isUI=0;
    if nargin==1
        data=bfopen(obj.filein);
    else
        if isa(varargin{1},'function_handle')
            data=bfopen(obj.filein,varargin{:});
            isUI=1;
        elseif isa(varargin{1},'numeric')
            data=bfopenSelect(obj.filein,varargin{1});
        end
    end
    
    
    % load
    mov=data{1}(:,1);
    %     obj.fformat=data{1}(:,2);
    % meta data
    omeMeta1=data{4};
    %     obj.omeMeta=omeMeta1;
    try
        if isempty(obj.pix2um)
            obj.pix2um=omeMeta1.getPixelsPhysicalSizeY(0).getValue();
        else
            warning('pixel to micron ratio already set, skip reading metadata');
        end
    catch
        if isUI
            query=CellVision3D.UIPopupQuestion(...
                ['Can''t find the pixel information in the metadata',...
                'Please input the pixel size in microns:']);
            waitfor(query.getFigureHandle);
            obj.pix2um=str2double(query.getAnswer);
        else
            warning('no pixel to um information')
        end
    end
    try
        if isempty(obj.vox2um)
            obj.vox2um=omeMeta1.getPixelsPhysicalSizeZ(0).getValue();
        else
            warning('voxel to micron ratio already set, skip reading metadata');
        end
    catch
        if isUI
            query=CellVision3D.UIPopupQuestion(...
                ['Can''t find the voxel information in the metadata',...
                'Please input the interval between z slices in microns:']);
            waitfor(query.getFigureHandle);
            obj.vox2um=str2double(query.getAnswer);
        else
            warning('no voxel to um information');
        end
    end
    try
        obj.sizeX=omeMeta1.getPixelsSizeX(0).getValue();
        obj.sizeY=omeMeta1.getPixelsSizeY(0).getValue();
        obj.sizeZ=omeMeta1.getPixelsSizeZ(0).getValue();
    catch
        warning('incomplete or no image size information');
    end
    obj.numstacks=obj.sizeZ;
    obj.numframes=omeMeta1.getPixelsSizeT(0).getValue();
    
    if ~isnan(obj.startframe) && ~isnan(obj.endframe)
        obj.numframes = obj.endframe - obj.startframe + 1;
    else
        obj.startframe = 1;
        obj.endframe = obj.numframes;
    end
    
    % JW - added if statement for movies with alternating channels.
    for ichannel=1:obj.numchannels
        if contains(data{1}(1,2),'Z=1') && contains(data{1}(2,2),'Z=1')
            chooseind = ceil(mod((0:length(mov)-1)/obj.numchannels,1)) ...
                == ichannel-1;
        else
            chooseind=mod(floor((0:length(mov)-1)/obj.numstacks),...
                obj.numchannels)==ichannel-1;
        end       
        channelmov = mov(chooseind);
        obj.channels(ichannel).load(channelmov(...
            (obj.startframe-1)*obj.numstacks+1:obj.endframe*obj.numstacks),obj);
    end
    
end


end