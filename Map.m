classdef Map < handle
    properties 
        walls = []
    end
    methods
        function c=count(obj)
            c =  size(obj.walls, 1);
        end

        function obj=addWall(obj, p1, p2)
            d = p1 - p2;
            obj.walls = [obj.walls; p1, p2 ];
        end
        function shift(map,dx, dy)
            map.walls = [map.walls(:,1) + dx, map.walls(:,2) + dy, ... 
                map.walls(:,3) + dx, map.walls(:,4) + dy];
        end
        
       function [dists, colls]=getUSCollision(map, crawler)
            [pos, n1, n2] = crawler.getUSAxis();
            us = [n1; -n1; n2; -n2];
            dists(1:4) = inf;
            colls = inf * ones(2,4);
            for j=1:4
                for i = 1:map.count()
                    [p, n] = map.getWall(i);
                    nus = us(j,:);
                    A = [nus;n];
                    b = [nus*pos ; n*p];
                    if abs(nus * n') > 1-0.001
                        X = [inf; inf];
                    else
                        X = linsolve(A,b);
                    end
                    
                    d = (X - pos).';
                    dd = norm(d);
                    l = [nus(2); -nus(1)];
                    if (d*l < 0) && (dd < dists(j))
                        dists(j) = dd;
                        colls(:,j) = X;
                    end
                end
            end
            dists = dists - abs(crawler.size);
        end
    end
    
    methods (Access=private)
       % Return point on wall, and normal
        function [p, n] = getWall(map, i)
          p = map.walls(i,1:2);
          q = map.walls(i,3:4);
          n = p - q;
          n = [n(2), -n(1)];
          n = n / norm(n);

          p = p.';
        end
    end
    
    methods (Static)
        function map = Box()
            map = Map;
            
            map.addWall([-50, -50], [-50,50]);
            map.addWall([-50,50], [50,50]);
            map.addWall([50,50], [50,-50]);
            map.addWall([50,-50], [-50,-50]);
        end
        function map = Map1()
            map = Map;
            
            map.addWall([-40, -80], [-100,80]);
            map.addWall([-100,80], [0,100]);
            map.addWall([0,100], [100,0]);
            map.addWall([100,0], [0,-100]);
            map.addWall([0,-100], [-40,-80]);
        end
        function map = Triangle()
            map = Map;
            
            map.addWall([-100, -100], [0,100]);
            map.addWall([0, 100], [100,-100]);
            map.addWall([100, -100], [-100,-100]);
        end
    end
end 