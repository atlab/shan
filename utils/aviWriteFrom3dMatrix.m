function  aviFileObj = aviWriteFrom3dMatrix(aviFileName,imageStack,varargin)
% % AVIWRITEFROM3DMATRIX - Writes an avi file from the given 3D image
% stack. By default, movie is made with 60 frames per second. To set a
% different frame rate, pass the desired value as optional argument under
% param name 'fps'.
% function  aviFileObj = aviWriteFrom3dMatrix(aviFileName,imageStack,param1,paramVal1,param2,paramVal2,...)
%-----------------------------------------------------------------------------------------
% Example:
% aviWriteFrom3dMatrix('z:\users\mani\temp\testMovie.avi',rand(300,400,50),'fps',100);
%
% This function is called by:
% This function calls:
% MAT-files required:
%
% See also: avifile,movie2avi,addframe,im2frame

% Author: Mani Subramaniyan
% Date created: 2009-11-15
% Last revision: 2009-11-15
% Created in Matlab version: 7.5.0.342 (R2007b)
%-----------------------------------------------------------------------------------------
params.fps = 60;
params.compression = 'none'; % Indeo3 and Indeo5 don't work. If you want compression, use 'CinePak'
params.quality = 100;
% params = parseVarArgs(params,varargin{:});
nFrames = size(imageStack,3);

% Open an avi file
% argList = struct2argList(params);
aviFileObj = avifile(aviFileName,'fps',params.fps,'compression',params.compression,...
    'quality',params.quality);
figure(1);
imshow(imageStack(:,:,1));
cmap = colormap;
for iFrame = 1:nFrames
    f = im2frame(imageStack(:,:,iFrame),cmap);
    aviFileObj = addframe(aviFileObj,f);
%     displayProgress(iFrame,nFrames);
end
aviFileObj = close(aviFileObj);