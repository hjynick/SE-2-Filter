classdef Estimation < handle
    
    properties
        crawler
        system
        update
        filter
        particles
        pf
    end
    
    methods
        function obj = Estimation(crawler)
            obj.crawler = crawler;
            obj.system = SystemModel;
            obj.update = ProgressiveUpdate(crawler.map);
            obj.filter = SE2Filter;
            obj.pf = ParticleFilter(crawler, [0.5, 0.5, 0.05]);
            
            Q = SE2(crawler.rot, crawler.pos).asDualQuaternionMatrix();
            c = 2;
            C = 10*diag([-1,-c,-c,-c]);
            C = Q' * C * Q;
            C = (C + C.')/2
            obj.filter.setState( SE2BinghamDistribution(C));
        end
        
        function crawler = predictAndUpdate(obj, dir, measurement, method)
            if nargin == 3
                method = 'se2';
            end
            switch method
                case 'se2'
                    crawler = obj.se2(dir, measurement);
                case 'particle'
                    crawler = obj.particle(dir, measurement);
            end
        end
         
        function crawler = se2(obj, dir, measurement)
            if dir == "none"
            else
                obj.filter.predict(obj.system, dir);
            end
            state = obj.filter.getEstimate();
            state =  obj.update.progressive(measurement, state, @(z,x)obj.update.measurementLikelihood(z,x));
            xytheta = FromQuaternion(state.mode());
            crawler = SimCrawler(xytheta, obj.crawler.map);
            obj.filter.setState(state);
            
            [samples, ~] = state.sampleDeterministic();
            l = size(samples,2);
            for i = 1:l
                obj.particles(i,:) = FromQuaternion(samples(:,i));
            end
        end
        
        function crawler = particle(obj, dir, measurement)
            crawler = obj.pf.predictAndUpdate(dir, measurement);
            obj.particles = obj.pf.pf.Particles;
        end
        
        function f = likelihood(obj, z,x)
            f = obj.update.likelihood(z,x)
        end
    end
    
end

