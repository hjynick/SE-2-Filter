classdef SE2Filter < SE2BinghamFilter
    properties
        Property1
    end
    
    methods
        function obj = SE2Filter()
            obj@SE2BinghamFilter();
        end

        function predict(this, sysModel, dir)
            % Prediction step using a noisy identity model.
            %
            %  This prediction step assumes the system to evolve according to
            %        x_{t+1} = x_t [+] v,
            %  where v is the system noise and x_t is the current system state.

            
            [eSamples, eWeights] = this.curEstimate.sampleDeterministic();
            [nSamples, nWeights] = sysModel.getNoise(dir).sampleDeterministic();
            
            % Number of samples (these values may differ once more sampling
            % schemes are implemented).
            eNumSamples = length(eWeights);
            nNumSamples = length(nWeights);
            
            rSamples = zeros(4,eNumSamples*nNumSamples);
            rWeights = zeros(1,eNumSamples*nNumSamples);
            
            % Perform dual quaternion multiplication
            % This needs vectorization for better perfomance
            k = 1;
            for i=1:eNumSamples
                for j=1:nNumSamples
                    state = FromQuaternion(eSamples(:,i));
                    move = FromQuaternion(nSamples(:,i));
                     rSamples(:,k) = ToQuaternion(ApplyMove(state, move));
                     %rSamples(:,k) = SE2.dualQuaternionMultiply(eSamples(:,i),nSamples(:,j));
                    
                    rWeights(k) = eWeights(i)*nWeights(j);
                    k = k+1;
                end
            end
            
            % Fit new samples.
            this.curEstimate = SE2BinghamDistribution.fit(rSamples, rWeights);
        end
        

    end
end

