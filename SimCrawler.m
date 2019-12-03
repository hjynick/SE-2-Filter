classdef SimCrawler < AbstractCrawler
    properties(SetAccess=protected)
        noisyPos
        noisyRot
        system
    end
    properties
       noisetype = 'gaussian'
       pos
        rot
    end
    
    properties(Constant)
        noise = 0.1
        speed = 1;
        rotSpeed = 0.1;
    end
    
    methods
        function pos=get.noisyPos(obj)
            r = obj.noise * randn(2);
            pos = obj.pos + r(1,:);
        end
        function rot=get.noisyRot(obj)
            rot = obj.rot + obj.noise* randn(1);
        end
    end
    methods
        function crawler= SimCrawler(xytheta, map)
            crawler = crawler@AbstractCrawler(map);
            crawler.pos = [xytheta(1), xytheta(2)];
            crawler.rot = xytheta(3);
            crawler.system = SystemModel;
        end
        
        function imu=getIMU(obj)
            imu = obj.noisyRot;
        end
        
        function dists=getUS(obj)
            [dists, ~] = obj.map.getUSCollision(obj);
        end
        
        
        function move(obj, dir)
            switch obj.noisetype
                case 'gaussian'
                    [mean,var] = obj.system.getMove(dir);
                    move = mean + var' .* randn(3,1);
                case 'se2'
                    se = obj.system.getNoise(dir);
                    move = FromQuaternion(se.sample(1))';
%                     m = move(1);
%                     move(1) = move(2);
%                     move(2) = m;
            end
            
            t = move(1:2);
            r = move(3);
            R = RotationMat2D(obj.rot - pi/2);
            obj.rot = obj.rot + r;
            obj.pos = obj.pos + (R*t)';
        end
        
        
        function [p, n1, n2] = getUSAxis(crawler)
            theta = crawler.rot;
            p = crawler.pos.';
            n1 = [cos(theta) sin(theta)];
            n2 = [n1(2) -n1(1)];
        end
    end
    
    methods(Access=private)
        function R=getRotationMatrix(obj)
            theta = obj.rot;
            R=[cos(theta) -sin(theta); sin(theta) cos(theta)];
        end
    end
end