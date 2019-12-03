function [vid] = cam_init()
% initialize camera 
% used with IS DFK31F03 - needs vcapg2.dll
% opens a window, that is not needed
% @return:      vid: cardnumber. not needed, but used for interface with
%                    VX-6000 implementation

% initialize camera
    %vid = vcapg2([],0);
    vid = videoinput('winvideo',1,'UYVY_1280x960');
    
    set(vid,'ReturnedColorSpace','rgb');

    set(getselectedsource(vid),'Brightness',0);
%     set(getselectedsource(vid),'Contrast',50);
%     set(getselectedsource(vid),'ContrastMode','manual');
%     set(getselectedsource(vid),'Gamma',0);
    set(getselectedsource(vid),'Hue',180);
    set(getselectedsource(vid),'Saturation',185);
%     set(getselectedsource(vid),'Sharpness',0);
%     set(getselectedsource(vid),'WhiteBalance',85);
    set(getselectedsource(vid),'WhiteBalanceMode','auto');

    
    
%     set(vid,'FramesPerTrigger', 1);
%     set(vid,'TimerPeriod', 1);
end