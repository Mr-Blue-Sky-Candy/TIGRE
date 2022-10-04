%% DEMO 8:  Algorithms 03. Krylov subspace
%
%
% In this demo the usage of the the Krylov subspace family is explained.
% This family of algorithms iterates trhough the eigenvectors of the
% residual (Ax-b) of the problem in descending order, achieving increased
% convergence rates comparing to SART family. 
% 
% In cases where the data is good quality, SART type families tend to reach
% to a better image, but when the data gets very big, or has bad quality,
% CGLS is a good and fast algorithm
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
% This file is part of the TIGRE Toolbox
% 
% Copyright (c) 2015, University of Bath and 
%                     CERN-European Organization for Nuclear Research
%                     All rights reserved.
%
% License:            Open Source under BSD. 
%                     See the full license at
%                     https://github.com/CERN/TIGRE/blob/master/LICENSE
%
% Contact:            tigre.toolbox@gmail.com
% Codes:              https://github.com/CERN/TIGRE/
% Coded by:           Ander Biguri 
%--------------------------------------------------------------------------
%% Initialize
clear;
close all;

%% Define Geometry
geo=defaultGeometry('nVoxel',[256,256,256]','nDetector',[256,256]);                     

%% Load data and generate projections 
% see previous demo for explanation
angles=linspace(0,2*pi,100);
head=headPhantom(geo.nVoxel);
projections=Ax(head,geo,angles,'interpolated');
noise_projections=addCTnoise(projections);

%% Usage CGLS
%
%
%  CGLS has the common 4 inputs for iterative algorithms in TIGRE:
%
%  Projections, geometry, angles, and number of iterations 
%
% Additionally it contains optional initialization tehcniques, but we
% reccomend not using them. CGLS is already quite fast and using them may
% lead to divergence.
% The options are:
%  'Init'    Describes diferent initialization techniques.
%             �  'none'     : Initializes the image to zeros (default)
%             �  'FDK'      : intializes image to FDK reconstrucition
%             �  'multigrid': Initializes image by solving the problem in
%                            small scale and increasing it when relative
%                            convergence is reached.
%             �  'image'    : Initialization using a user specified
%                            image. Not recomended unless you really
%                            know what you are doing.
%  'InitImg'    an image for the 'image' initialization. Avoid.
 
% use CGLS
[imgCGLS, residual_CGLS]=CGLS(noise_projections,geo,angles,60);
% use LSQR
[imgLSQR, residual_LSQR]=LSQR(noise_projections,geo,angles,60);
% use hybrid LSQR (note, this algorithm requires tons of memory, 
% [niter x size(image)] memory. Do not use for large images. 
[imghLSQR, residual_hLSQR]=hybrid_LSQR(noise_projections,geo,angles,60);
% use LSMR
[imgLSMR, residual_LSMR]=LSMR(noise_projections,geo,angles,60);
% use LSMR with a lambda value
[imgLSMR_lambda, residual_LSMR_lambda]=LSMR(noise_projections,geo,angles,60,'lambda',10);
% SIRT for comparison.
[imgSIRT, residual_SIRT]=SIRT(noise_projections,geo,angles,60);

%% plot results
%
% We can see that CGLS gets to the same L2 error in less amount of
% iterations.

len=max([length(residual_LSQR),
        length(residual_CGLS),
        length(residual_SIRT), 
        length(residual_LSMR),
        length(residual_LSMR_lambda),
        length(residual_hLSQR)]);


plot([[residual_SIRT nan(1,len-length(residual_SIRT))];
      [residual_CGLS nan(1,len-length(residual_CGLS))];
      [residual_LSQR nan(1,len-length(residual_LSQR))];
      [residual_hLSQR nan(1,len-length(residual_hLSQR))];
      [residual_LSMR nan(1,len-length(residual_LSMR))];
      [residual_LSMR_lambda nan(1,len-length(residual_LSMR_lambda))]]');
title('Residual')
legend('SIRT','CGLS','LSQR','hybrid LSQR','LSMR','LSMR lambda')

% plot images
plotImg([imgLSQR imgCGLS, imgLSMR;imghLSQR imgLSMR_lambda, imgSIRT],'Dim','Z','Step',2)
%plot errors
plotImg(abs([head-imgLSQR head-imgCGLS head-imgLSMR; head-imghLSQR head-imgLSMR_lambda head-imgSIRT]),'Dim','Z','Slice',64,'clims',[0, 0.3])
