classdef ParticleFilter < handle
    
    properties
        crawler
        system
        pf
        lastBestGuess
        map
    end
    
    methods
        function obj = ParticleFilter(crawler, startVariance)
            obj.crawler = crawler;
            obj.system = SystemModel;
            obj.map = crawler.map;
            obj.lastBestGuess = [crawler.pos, crawler.rot];
            
            obj.pf=robotics.ParticleFilter;
            obj.pf.StateEstimationMethod='mean';
            obj.pf.ResamplingMethod='systematic';
            initialize( obj.pf, 1000, obj.lastBestGuess, diag(startVariance), 'CircularVariables', [0 0 1]);
            
            obj.pf.StateTransitionFcn = @(pf, prevParticles, dir) obj.stateTransition( prevParticles, dir);
            obj.pf.MeasurementLikelihoodFcn = @(pf, predictParticles, measurement, map) obj.measurementLikelihood(predictParticles, measurement, map);
            
            % Last best estimation for x, y and theta
            
        end
        
        function crawler = predictAndUpdate(obj, dir, measurement)
            % Predict the carbot pose based on the motion model
            [statePred, covPred] = predict(obj.pf, dir);
            [stateCorrected, covCorrected] = correct(obj.pf, measurement', obj.map);
            obj.lastBestGuess = stateCorrected(1:3);
            crawler = SimCrawler(obj.lastBestGuess, obj.map);
        end
        
        function predictParticles = stateTransition(obj, prevParticles, dir)
            
            thetas = prevParticles(:,3);
            
            l = length(prevParticles);
            [move, var] = obj.system.getMove(dir);
            
%             moves = move + var .* randn(l,3);r
           
             moves(:,1) = move(1) + var(1)*randn(l,1);
             moves(:,2) = move(2) + var(2)*randn(l,1);
             moves(:,3) = move(3) + var(3)*randn(l,1);
            moves = bsxfun(@obj.rotate, moves', thetas');
            
            predictParticles = prevParticles +  moves';
            
        end
        
        function w=rotate(~,v,theta)
            w = [RotationMat2D(theta-pi/2) * v(1:2); v(3)];
        end
        
        
        function  likelihood = measurementLikelihood(~, predictParticles, measurement, map)
            
            l = length(predictParticles);
            
            predictMeasurement = zeros(l,4);
            for i = 1:l
                predictMeasurement(i,:) = SimCrawler(predictParticles(i,:), map).getUS();
            end
            
            measurementError = bsxfun(@minus, predictMeasurement, measurement');
            measurementErrorNorm = sqrt(sum(measurementError.^2, 2));
            
            measurementNoise = eye(3);
            
            likelihood = 1/sqrt((2*pi).^3 * det(measurementNoise)) * exp(-0.5 * measurementErrorNorm);
        end
        
        
        
        function f = likelihood(obj, z,x)
            f = obj.update.likelihood(z,x)
        end
    end
    
end

