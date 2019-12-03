function cam_properties(src)
% property settings for webcam - MS VX-6000
    %@parameter:    src is an object that hold all possible camera
    %                   properties to adjust.
    %                   src is returned by src = getselectedsource(vid) see cam_init
    %                   vid is returend by vid = videoinput('winvideo',1,'RGB24_1280x1024');
    %                   for further information see cam_init
    %               isLightOn: if roomlight is on use "true" else use "false"
 
    
    % 'Exposure' setting differs if roomlight is lit.... value between 2
    % and 5
    set(src, 'Exposure', 2);
    set(src, 'Brightness', 0);
    set(src, 'Contrast', 100);
    set(src, 'FrameRate', '5.0000');
    set(src, 'Gamma', 100);
    set(src, 'Hue', 180);
    set(src, 'Saturation', 299);
    set(src, 'Sharpness', 0);

end %function