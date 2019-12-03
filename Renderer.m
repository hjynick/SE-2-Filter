classdef Renderer < handle

    properties
        axes
        errors = 1
        likelihood = 0
        particles = 1
    end
    
    methods
        function obj = Renderer(axes)
            obj.axes = axes;
            set(obj.axes,'DataAspectRatio',[1 1 1],...
                'PlotBoxAspectRatio',[1 1 1]);

        end
        
        function render(obj, data)
            obj.drawMap(data('map'));
            
            hold(obj.axes,'on');
            
            obj.drawParticles(data('particles'));
            
            obj.drawCrawler(data('crawler'), data('crawlerColls'),'b');
            obj.drawCrawler(data('estimation'), data('estimationColls'),'r');
            hold(obj.axes, 'off');
            
            if obj.errors
                obj.drawErrors(data('errors'));
            end
            
            if obj.particles
                obj.drawParticles(data('particles'), 3);
            end
        end
        function fixAxes(obj)
             axis(obj.axes,'manual')
        end
        function  drawMap(obj, map)
            m = map.walls;
            x = [m(:,1), m(:,3)];
            y = [m(:,2), m(:,4)];
            plot(obj.axes, x,y,'-k');
        end
        function  drawParticles(obj, particles, fig)
            if nargin == 3
               f=figure(3);
               plot(0,0);
               axis on
               ax = f.CurrentAxes;
            else
                ax = obj.axes;
            end     
            q = quiver(ax, particles(:,1),particles(:,2), cos(particles(:,3)),sin(particles(:,3)), 'k');
            q.AutoScaleFactor = 0.5;
        end
        
        function drawErrors(obj, errors)
            figure(88);
            plot(errors);
            title('Ortungsfehler');
            xlabel('Anzahl Schritte');
            ylabel('Distanz');
        end
    end
    
    methods(Access=private)   
        

        function  drawCrawler(obj, crawler, colls, color)
            plot(obj.axes, crawler.pos(1), crawler.pos(2), '-o');
            f = crawler.size(1);
            b = crawler.size(2);
            r = crawler.size(3);
            l = crawler.size(4);
            
            P = [-1 0 1 0   f f b b f;  % x
                 0 -1 0 1   l r r l l]; % y 
                % 4 columswise unit vectors to draw US-axis
                % 4 corners of the crawler + first one to close
                
            theta = crawler.rot;
            R = RotationMat2D(theta);
            P = R*P;
            P = P + crawler.pos.';
            x = [P(1,1:2); P(1,3:4)];
            y = [P(2,1:2); P(2,3:4)];
            plot(obj.axes, x,y, strcat('--',color));
            
            area = fill(obj.axes,P(1,5:9),P(2,5:9), color);
            alpha(area, 0.2);
            obj.drawCollisions(colls, color);
            
        end
        

        
        function drawCollisions(obj,colls, color)
            plot(obj.axes,colls(1,:), colls(2,:),  strcat('*',color));
        end
    end
end

