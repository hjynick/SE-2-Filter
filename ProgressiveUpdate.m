classdef ProgressiveUpdate < handle
    properties 
        map
    end
    properties(Constant)
        s = 20
        sigma = 20 * [1, 1, 1, 1]
        penalty = 1000
    end
    methods
        function obj = ProgressiveUpdate(map)
            obj.map = map;
        end
       
        %   measurement (1 x n) 
        %       measured data
        %   prediction (SE2BinghamDistribution)
        %   likelihood ( (measurement, state) => likelihood )
        %       f(measurement | state)
        function estimate=progressive(obj, measurement, prediction, f)
            tau = 0.1;
            Lambda = 1;
            state = prediction;
            n = 0;
            while Lambda > 0 && n < 50
                n = n+ 1;
                [samples, weights] = prediction.sampleDeterministic();
                L = size(samples, 2);
                likelihoods = zeros(1,L);
                for i = 1:L
                    likelihoods(i) = f(measurement, samples(:,i));
                end
                wmin = min(weights);
                wmax= max(weights);
                fmin = min(likelihoods);
                fmax = max(likelihoods);
                lambda = min([Lambda, log(tau * wmax/wmin)/log(fmin/fmax)]);
                    
                weights = weights .* (likelihoods.^lambda); 
                weights = weights / sum(weights);
                state = SE2BinghamDistribution.fit(samples, weights);
                Lambda = Lambda - lambda;

                PlotSE2BinghamDist(state);
            end
            estimate = state;
%             disp (i);
        end
        
        

        %   state (1 x 4 dual quaternion)
        %   measurement (1 x n) 
        %       measured data
        function f=likelihood(obj, measurement, state)
            f= obj.likelihoodXYTheta( measurement, FromQuaternion(state));
        end
        
        
        function f=likelihoodXYTheta(obj, measurement, xytheta)
            mean = SimCrawler(xytheta, obj.map).getUS();
            mean = min(obj.penalty,mean);
            f = prod( arrayfun(@ProgressiveUpdate.Gaussian, mean - measurement));
            %%f=obj.NGaussian(measurement, obj.sigma, mean);
        end
        
        function  likelihood = measurementLikelihood(obj,measurement, state)
            likelihood = obj.measurementLikelihoodXYTheta( measurement, FromQuaternion(state));
        end
      
        
        function  likelihood = measurementLikelihoodXYTheta(obj,  measurement, xytheta)
            predictMeasurement = SimCrawler(xytheta, obj.map).getUS();
            
            
            measurementError = predictMeasurement - measurement;
            measurementErrorNorm = sqrt(sum(measurementError.^2, 2));
            
            measurementNoise = eye(3);
            
            likelihood = 1/sqrt((2*pi).^3 * det(measurementNoise)) * exp(-0.5 * measurementErrorNorm);
        end
  
    end
    methods
        function test(p)
            xytheta = [1,2,3];
            q = SE2(0,[0,0]).asDualQuaternion();
            q1 = ProgressiveUpdate.ToQuaternion([0,1,0.1]);
            q2 = ProgressiveUpdate.ToQuaternion(xytheta);
            
            C1 = -diag([1 1]);
            C2 = [5 0; 0 5];
            C3 = -diag([1 1]);
%             C =[50     1     5     -1;
%                  1    -2     0     2;
%                  5     0    -3     0;
%                  -1     2     0    -1];
             C = diag([50,-1,-1,-1]);

%             x = 3;
%             y = 2;
%             Z = diag([-1 0]);
%             M = diag([x y]);
%             C = M * Z * M';
            
            prediction = SE2BinghamDistribution(C);
            measurement = [50,150,150,50];
%             ProgressiveUpdate.FromQuaternion(prediction.mode())

            
            
%             p.progressive([0.5 0.5 0.5 0.5], prediction, @(z, x) norm(z -x))
            for i = 1:50
                prediction = p.progressive(measurement, prediction, @p.likelihood   );
                 disp(p.FromQuaternion(prediction.mode()))
            end
            p.plotLikelihood(measurement);
        end
        
        
        
        function plotLikelihood(p, measurement, theta)
            N = 50;
            s = ProgressiveUpdate.s * 1.1;
            x = linspace(-s,s,N) ;
            y = linspace(-s,s,N) ;

            T = zeros(N);
                for i=1:N
                    for j=1:N
                        T(i,j) = p.likelihoodXYTheta(measurement, [y(j), x(i), theta]);
                    end
                end
            figure(1);
            plot = pcolor(x,y,T) ;

            pbaspect([1 1 1]);
        end
            
    end
    methods(Static)
        function pu=testInstance()
            s = ProgressiveUpdate.s;
            m = Map;
            m.addWall([-s -s], [-s s]);
            m.addWall([-s s], [s s]);
            m.addWall([s s], [s -s]);
            m.addWall([s -s], [-s -s]);
            m.shift(1,0);
            pu = ProgressiveUpdate(m);
        end
        
        function f = NGaussian(xy, sigma, mean)
            f = exp(-sum((xy-mean).^2./(2*sigma.^2)));
            f = f / ( 2 * prod(sigma));
        end
        
        function f=gaussian2D(xy)
            sigma =  1*[1 1];
            mean = [0 0];
            f = exp(-sum((xy-mean).^2./(2*sigma.^2)));
            f = f / ( 2 * prod(sigma));
        end
        
        function f = Gaussian(x)
            sigma = ProgressiveUpdate.sigma(1);
            f = exp(-(x^2) / (2*sigma^2));
            f = f / ( sigma * sqrt(2*pi) );
        end

    end
end

