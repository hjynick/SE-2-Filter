function [x, y] = cam_priv_undisort(x,y)
%calculates undisorted coordinates of given pixel coordinates
%camera intrinsic (Imaging Source DFK31F03)
%for further information about intrinsic and extrinsic camera parameter
% see: http://www.vision.caltech.edu/bouguetj/calib_doc/htmls/parameters.html
    %@parameter:x: disorted pixel x coordinate
    %           y: disorted pixel y coordinate
    %@return:   x: undisorted pixel or world x coordinate (see options)
    %           y: undisorted pixel or world y coordinate (see options)

% options
    %if to use pixel-coordinates or world-coordinates
        usePixelCoord = false;

% Parameter:    
%  Intrinsic

% Focal Length:          fc = [ 951.44994   950.95317 ] ± [ 9.75092   9.75402 ]
% Principal point:       cc = [ 617.90374   429.39850 ] ± [ 9.02905   9.10677 ]
% Skew:             alpha_c = [ 0.00000 ] ± [ 0.00000  ]   => angle of pixel axes = 90.00000 ± 0.00000 degrees
% Distortion:            kc = [ -0.30748   0.09612   -0.00268   -0.00103  0.00000 ] ± [ 0.00890   0.00834   0.00184   0.00124  0.00000 ]
% Pixel error:          err = [ 1.12604   1.08078 ]

    %-- Focal length:
    fc = [ 1342.15355;   1344.58773 ];

    %-- Principal point:
    cc = [ 483.58321;   500.80000 ];

    %-- Skew coefficient:
    alpha_c = 0.000000000000000;

    %-- Distortion coefficients:
    kc = [ -0.36791;   0.39428;   -0.02451;   -0.00747;  0.00000; ];

    %-- Camera matrix
    KK = [fc(1) alpha_c*fc(1) cc(1);0 fc(2) cc(2) ; 0 0 1];

    
%  Extrinsic

%%%old
% Translation vector: Tc_ext = [ -1711.705657 	 879.576006 	 2444.211119 ]
% Rotation vector:   omc_ext = [ 3.119749 	 -0.062955 	 -0.051665 ]
% Rotation matrix:    Rc_ext = [ 0.998638 	 -0.039983 	 -0.033514
%                                -0.040671 	 -0.998970 	 -0.020104
%                                -0.032676 	 0.021440 	 -0.999236 ]
% Pixel error:           err = [ 0.09615 	 0.10301 ]

%%%17.05.2010
% Translation vector: Tc_ext = [ -1298.973027 	 862.883162 	 2420.652297 ]
% Rotation vector:   omc_ext = [ 3.110658 	 -0.055083 	 -0.045974 ]
% Rotation matrix:    Rc_ext = [ 0.998937 	 -0.034944 	 -0.030069
%                                -0.035834 	 -0.998920 	 -0.029572
%                                -0.029003 	 0.030618 	 -0.999110 ]
% Pixel error:           err = [ 0.18373 	 0.17304 ]


    %Translation vector: 
    Tc_ext = [ -1010.258502; 840.630920; 2692.330646 ];

    %Rotation matrix:    
    Rc_ext = [  0.980072 -0.010071 -0.198385;
               -0.025958 -0.996643 -0.077644;
               -0.196937 0.081246 -0.977044 ];

    
% calculates normalized coordinates of the disorted pixel-coordinates
% Xn has the form [x;y]
    Xn = cam_priv_normalize([x;y],fc,cc,kc,alpha_c);


 if(usePixelCoord)
% calculates undisorted pixel-coordinates
    Xp=KK*[Xn;1];
    x=Xp(1);
    y=Xp(2);

 else
% calculates undsiorted world-coordinates (in mm)
% this calculation may be not fully correct yet. see project documentation.

%   Xw_old = inv(Rc_ext)*(Tc_ext(3)*[Xn;1]-Tc_ext)

    Xw = inv([Rc_ext(:,1:2) Tc_ext])*[Xn;1];
    Xw_new = Xw/Xw(3) - [0;0;1];


    x=Xw_new(1);
    y=Xw_new(2);

 end
