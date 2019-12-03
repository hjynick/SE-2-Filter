classdef crawler < handle
       
    methods (Access = public)
        
        function obj = crawler(withCamera)
            addpath(genpath('communication'));
            
            if nargin == 0
                withCamera = 0;
            end
            if nargin > 0 && withCamera
                obj.camera = camera(); 
            end
            
            obj.isCameraEnabled = withCamera;
        end
        
        function execute_movement(obj, steps)       
            obj.performRotation(steps(3));
            obj.performTranslation(steps(1), steps(2));                                                  
        end               
        
        function pos = get_real_position(~, est_position)
            if obj.isCameraEnabled
                pos = obj.camera.getRealPosition(est_position);
            else
                pos = est_position;
            end
        end 
        
        function dist = perform_US_measurement(~, id)
           dist = tcpUS(id,1); 
        end
    end
    
    % --- protected methods -----------------------------------------------
    
    methods (Access = protected)        
        
        function performTranslation(obj, moveCountX, moveCountY)                        
            if moveCountY ~= 0
               obj.performTranslationY(moveCountY); 
            end            
            if moveCountX ~= 0 
                obj.performTranslationX(moveCountX);
            end                        
        end
        
        function zyx = performTranslationX(~, moveCountX)
             xSteps = 1:abs(moveCountX);             
             if moveCountX > 0
                zyx = tcpMove(movement_primitives.right, ...
                    100, xSteps);
             else
                zyx = tcpMove(movement_primitives.left, ...
                    100, xSteps);                
             end            
        end
        
        function zyx = performTranslationY(~, moveCountY)
            ySteps = abs(moveCountY);                                 

            if moveCountY > 0
                zyx = tcpMove(movement_primitives.forward, ...
                    100, ySteps);                
            else
                zyx = tcpMove(movement_primitives.backward, ...
                    100, ySteps);                    
            end 
        end
        
        function performRotation(obj, rotationCount)
           if rotationCount ~= 0
               obj.performRotationZ(rotationCount);               
           end
        end
        
        function zyx = performRotationZ(~, rotationCount)
          rSteps = abs(rotationCount);            
           if rotationCount > 0
                zyx = tcpMove(movement_primitives.turn_right, ...
                    100, rSteps);                    
           else
                zyx = tcpMove(movement_primitives.turn_left, ...
                    100, rSteps);                    
           end  
        end        
    end
    
    properties (Access = private)
       isCameraEnabled; 
       camera
    end
end