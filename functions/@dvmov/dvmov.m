classdef dvmov < handle
    %load movie
    properties
        filename
        path
        numstacks
        numframes
        startframe
        endframe
        pix
        vox
        sizeX
        sizeY
        sizeZ
        mov
    end
    properties (Hidden=true)
        omeMeta
        fformat
    end
    properties (Dependent)
        filein
    end
    methods
        %initialize
        function obj=dvmov(varargin)
            %loadmovie from file or select movie to load
            if isempty(varargin)
                [obj.filename,obj.path]=uigetfile(fullfile(obj.path,'*.dv'),...
                    'Please choose file to analyze');
            elseif length(varargin)==1 && exist(varargin{1})
                [obj.path,obj.filename,ext]=fileparts(varargin{1});
                if strcmp(ext,'.dv')==0
                    warning('dv file needed');
                end
            elseif ~exist(varargin{1})
                 error('file doesn''t exist');
            else
                error('wrong file input type');
            end
        end
        %load dv movie
        function obj=loadmovie(obj,varargin)
            if ~exist(obj.filein)
                warning('invalid dv movie data path');
            else
                if nargin==1
                    data=bfopen(obj.filein);
                else
                    data=bfopenSelect(obj.filein,varargin{1});
                end
                obj.mov=data{1}(:,1);
                obj.fformat=data{1}(:,2);
%                 obj.startframe=1;
%                 obj.endframe=obj.numframes;
                omeMeta1=data{4};
                obj.omeMeta=omeMeta1;
                obj.pix=omeMeta1.getPixelsPhysicalSizeX(0).getValue();
                obj.vox=omeMeta1.getPixelsPhysicalSizeZ(0).getValue();
                obj.sizeX=omeMeta1.getPixelsSizeX(0).getValue();
                obj.sizeY=omeMeta1.getPixelsSizeY(0).getValue();
                obj.sizeZ=omeMeta1.getPixelsSizeZ(0).getValue();
                obj.numstacks=obj.sizeZ;
                obj.numframes=omeMeta1.getPixelsSizeT(0).getValue();
                
                % If .dv file contains transmitted light reference z stacks
                % along with fluorescent images, the following code removes 
                % transmitted light images from obj.mov (Jess - 20170202).
                if numel(obj.mov) == obj.endframe*obj.numstacks
                    obj.mov = obj.mov;
                    % If the number of total images equals the product of
                    % z-stack number and time points, assume .dv file only
                    % contains fluorescent images. Proceed as usual.
                else numel(obj.mov) == 2*obj.endframe*obj.numstacks
                    obj.mov = [];
                    for i = 1:2:2*obj.endframe
                        fl = data{1}((i*obj.numstacks + 1):(i*obj.numstacks...
                            + obj.numstacks),1);
                        obj.mov = vertcat(obj.mov,fl);
                    end
                    % However, if the total number of images actually
                    % equals twice the product of z-stack number and time
                    % points, then we assume there are transmitted light
                    % z-stacks included. Above for-loop picks out only the
                    % fluorescent z-stacks starting at image 11.
                end
            end
        end

        %grab frame
        function img=grab(obj,iframe,istack)
            img=double(obj.mov{istack+obj.numstacks*(iframe-1)});
        end
        %grab frame 3d
        function img=grab3(obj,iframe)
            img=zeros(obj.sizeY,obj.sizeX,obj.sizeZ);
            for istack=1:obj.numstacks
                img(:,:,istack)=double(obj.mov{istack+obj.numstacks*(iframe-1)});
            end
        end
        function img=proj(obj,iframe)
            img=0;
            for i=1:obj.numstacks
            img=img+double(obj.mov{i+obj.numstacks*(iframe-1)});
            end
            img=img/obj.numstacks;
        end
        %dependent properties
        function filein=get.filein(obj)
            filein=fullfile(obj.path,[obj.filename,'.dv']);
        end
    end
end
