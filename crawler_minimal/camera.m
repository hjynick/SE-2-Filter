classdef camera < handle
       
   methods (Access = public)
       function obj = camera()
            addpath(genpath('camera'));
            
            obj.vid = cam_init();
            [obj.offsetX, obj.offsetY] = obj.getRobotPositionCm(obj.vid, 0, 0);
            obj.offsetX = obj.offsetX *-1;
            obj.offsetY = obj.offsetY *-1; 
       end
              
       function pos = getRealPosition(obj, estimated_position)
            % ATTENTION: CAREMA AXES AND STEPSIZE (MM NOT CM)
            [real_pos1, real_pos2] = obj.getRobotPositionCm(obj.vid, obj.offsetX, obj.offsetY);
            pos = [(real_pos1 / 10.0); -(real_pos2 / 10.0); estimated_position(3)];
       end
   end
   
   methods (Access = private)
        function [cm_x, cm_y] = getCameraOffsets(~, vid)
            b = getsnapshot(vid);            
            red = b(:,:,1);            
            [x,y] = find(red==max(max(red)));
            pos = mean([x,y]);
            [cm_x, cm_y] =  cam_priv_undisort(pos(1), pos(2));
        end
        
        function [cm_n_x, cm_n_y] = getRobotPositionCm(~, vid, offset_x, offset_y)            
            b = getsnapshot(vid);            
            red = b(:,:,1);           
            [redX,redY] = find(red==max(max(red)));
            pos = mean([redX,redY], 1);
            [cm_x, cm_y] =  cam_priv_undisort(pos(1), pos(2));
            cm_n_x = (cm_x - offset_x)*-1;
            cm_n_y = (cm_y - offset_y)*-1;
            disp('Found real Cameraposition:'),
            disp([cm_n_x, cm_n_y]);
        end
   end
   
   properties (Access = private)
      vid;
      offsetX;
      offsetY;
   end
end