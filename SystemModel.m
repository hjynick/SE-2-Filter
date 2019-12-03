classdef SystemModel < handle
    
    properties
        fwd = [-0.03 , 1.33]
        fwdRot = -0.01
        
        turnl = [1.11 , -0.04]
        turnlRot = 0.37
        
        turnr = [-1.08 , -0.44]
        turnrRot = -0.36
        
        fwdVar = [0.01, 0.89, 0.01]
        turnrVar = [0.06, 1.10, 0.01]
        turnlVar = [0.11, 1.21, 0.01]
    end
    
    methods
        function se=getNoise(obj, dir)
            switch dir
                case 'fwdStep'
                    if exist('fwdSE')
                        se = fwdSE;
                    else
                        load('fwd');
                        se = SE2BinghamDistribution(C);
                        %                     se.NC = NC;
                    end
                case 'turnl'
                    if exist('turnlSE')
                        se = fwdSE;
                    else
                        load('turnl');
                        se = SE2BinghamDistribution(C);
                        %                     se.NC = NC;
                    end
                case 'turnr'
                    if exist('turnrSE')
                        se = fwdSE;
                    else
                        load('turnr');
                        se = SE2BinghamDistribution(C);
                        %                     se.NC = NC;
                    end
            end
        end
        
        
        function [move, var] = getMove(obj, dir)
            switch dir
                case 'fwdStep'
                    move = [obj.fwd, obj.fwdRot]';
                    var = obj.fwdVar;
                case 'turnl'
                    move = [obj.turnl, obj.turnlRot]';
                    var = obj.turnlVar;
                case 'turnr'
                    move = [obj.turnr, obj.turnrRot]';
                    var = obj.turnrVar;
                case 'none'
                    move = [0,0,0]';
                    var = 0.03 * [1,1,1];
            end
        end
        
    end
end

