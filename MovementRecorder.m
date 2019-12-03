classdef MovementRecorder < handle
    properties
        crawler
        records % (n x 8)    x y theta dir1 dir2 dir3 dir4 imu
        steps   % (n x 1)    direction
    end
    
    methods
        function obj = MovementRecorder(crawler)
            obj.crawler = crawler;
            obj.record("start");
        end
        
        function move(obj, dir, param)
            if nargin > 2
                obj.crawler.move(dir,param);
            else
                obj.crawler.move(dir);
            end
            obj.record(dir);
        end
        
        function record(obj, dir)
            obj.records = [obj.records; [obj.crawler.pos, ...
                                         obj.crawler.rot, ...
                                         obj.crawler.getUS(), ...
                                         obj.crawler.getIMU]];
            obj.steps = [obj.steps; dir];
        end
        
        function save(obj)
            filename = datestr(datetime('now'));
            filename = strrep(filename, ':', '');
            r = obj.records;
            s = obj.steps;
            save(filename, 'r', 's');
        end
        
        function load(obj, filename)
            load(filename,'r', 's');
            obj.records = r;
            if exist('s')
                obj.steps = s;
            end
        end
        
        function plot(obj)
            s = obj.records;
            
            figure(1)
            q = quiver(s(:,1),s(:,2), -sin(s(:,3)), cos(s(:,3)));
            q.AutoScaleFactor = 0.2;
            q.Marker = 'o';
            hold on
            plot(s(:,1),s(:,2));
            hold off;
            axis equal
            xlabel('x')
            ylabel('y')
        end
        

    end
    
    methods(Static)
        %   exclude (1 x n)
        %       step indices to exclude from analysis
        function diffs=analyse(filename,dir)
            if nargin <= 2
                exclude = [];
            end
            if nargin <=1
                dir = 'none';
            end
            obj = MovementRecorder(SimCrawler([0,0,0],Map));
            obj.load(filename);
            obj.plot();
            n = size(obj.records, 1) - size(exclude,1);
            diffs = [];
            for i = 2:n
                theta = obj.records(i-1, 3);
                if  ((size(obj.steps,1)>=i) && obj.steps(i) ~= dir) || ...
                    isnan(theta) || isnan(obj.records(i, 3))
                    continue;
                end

                R = RotationMat2D(-theta);
                xy = (obj.records(i-1,1:2) - obj.records(i,1:2))';
                diffs = [diffs; [(-R * xy)', ... %positions
                        MovementRecorder.angleDiff(obj.records(i,3),obj.records(i-1,3)), ... %rotation
                        i-1]]; 
            end
            fprintf('Analysed %i %s steps\n' , size(diffs,1), dir);
            
             figure(22);
%             figure('Name','Shift');
            q = quiver(0,0, 0, 1, 'b*');
            q.AutoScaleFactor = 0.5;
            hold on
            q =quiver(diffs(:,1),diffs(:,2), -sin(diffs(:,3)), cos(diffs(:,3)));
            q.AutoScaleFactor = 0.2;
            q.Marker = 'o';
            hold off
            
            axis([-2 2 -2 2])
            
            figure(3);
%             figure('Name','Rotation');
            plot(diffs(:,3));
            axis([-inf inf -pi pi])
            
            fprintf('Mean: %.4f\n' , mean(diffs));
            fprintf('Variance: %.4f\n', var(diffs));
            MovementRecorder.createSystemNoise(diffs);
        end
        function createSystemNoise(diffs)
            N = size(diffs,1);
            qs = zeros(4,N);
            for i = 1:N
                qs(:,i) = ToQuaternion(diffs(i,:))';
            end
            se = SE2BinghamDistribution.fit(qs);
            se.C
            fprintf('NC: %.8f\n' , se.NC);
            
            PlotSE2BinghamDist(se);
        end
        
        function test()
            m = Map;
            c = SimCrawler([0,0,0],m);
            mr = MovementRecorder(c);  
            
            mr.load('data ffff');
            mr.plot();
        end
    end
    methods(Static, Access=private)
        function diff=angleDiff(a,b)
            diff = a - b;
            
            if diff > pi
                diff = diff - 2*pi;
            end
            if diff < -pi
                diff = diff + 2*pi;
            end
        end
    end

end