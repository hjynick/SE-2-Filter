
classdef GHRUF < SampleBasedRecursiveUpdateFilter & GaussHermiteLinearGaussianFilter
    % The Gauss-Hermite recursive update filter (GHRUF).
    %
    % GHRUF Methods:
    %   GHRUF                       - Class constructor.
    %   copy                        - Copy a Filter instance.
    %   copyWithName                - Copy a Filter instance and give the copy a new name/description.
    %   getName                     - Get the filter name/description.
    %   setColor                    - Set the filter color/plotting properties.
    %   getColor                    - Get the filter color/plotting properties.
    %   setState                    - Set the system state.
    %   getState                    - Get the system state.
    %   setStateMeanAndCov          - Set the system state by means of mean and covariance matrix.
    %   getStateMeanAndCov          - Get mean and covariance matrix of the system state.
    %   getStateDim                 - Get the dimension of the system state.
    %   predict                     - Perform a state prediction.
    %   update                      - Perform a measurement update.
    %   step                        - Perform a combined state prediction and measurement update.
    %   setStateDecompDim           - Set the dimension of the unobservable part of the system state.
    %   getStateDecompDim           - Get the dimension of the unobservable part of the system state.
    %   setPredictionPostProcessing - Set a post-processing method for the state prediction.
    %   getPredictionPostProcessing - Get the post-processing method for the state prediction.
    %   setUpdatePostProcessing     - Set a post-processing method for the measurement update.
    %   getUpdatePostProcessing     - Get the post-processing method for the measurement update.
    %   setMeasGatingThreshold      - Set the measurement gating threshold.
    %   getMeasGatingThreshold      - Get the measurement gating threshold.
    %   setNumRecursionSteps        - Set the number of recursion steps that are performed by a measurement update.
    %   getNumRecursionSteps        - Get the number of recursion steps that are performed by a measurement update.
    %   setNumQuadraturePoints      - Set the number of quadrature points used for state prediction and measurement update.
    %   getNumQuadraturePoints      - Get the number of quadrature points used for state prediction and measurement update.
    
    % Literature:
    %   Kazufumi Ito and Kaiqi Xiong,
    %   Gaussian Filters for Nonlinear Filtering Problems,
    %   IEEE Transactions on Automatic Control, vol. 45, no. 5, pp. 910-927, May 2000.
    %
    %   Yulong Huang, Yonggang Zhang, Ning Li, and Lin Zhao,
    %   Design of Sigma-Point Kalman Filter with Recursive Updated Measurement,
    %   Circuits, Systems, and Signal Processing, pp. 1-16, Aug. 2015.
    
    % >> This function/class is part of the Nonlinear Estimation Toolbox
    %
    %    For more information, see https://bitbucket.org/nonlinearestimation/toolbox
    %
    %    Copyright (C) 2015-2017  Jannik Steinbring <nonlinearestimation@gmail.com>
    %
    %    This program is free software: you can redistribute it and/or modify
    %    it under the terms of the GNU General Public License as published by
    %    the Free Software Foundation, either version 3 of the License, or
    %    (at your option) any later version.
    %
    %    This program is distributed in the hope that it will be useful,
    %    but WITHOUT ANY WARRANTY; without even the implied warranty of
    %    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    %    GNU General Public License for more details.
    %
    %    You should have received a copy of the GNU General Public License
    %    along with this program.  If not, see <http://www.gnu.org/licenses/>.
    
    methods
        function obj = GHRUF(name)
            % Class constructor.
            %
            % Parameters:
            %   >> name (Char)
            %      An appropriate filter name / description of the implemented
            %      filter. The Filter subclass should set this during its
            %      construction to a meaningful default value (e.g., 'EKF'),
            %      or the user should specify an appropriate name (e.g.,
            %      'PF (10k Particles)').
            %
            %      Default name: 'GHRUF'.
            %
            % Returns:
            %   << obj (GHRUF)
            %      A new GHRUF instance.
            
            if nargin < 1
                name = 'GHRUF';
            end
            
            % Call superclass constructors
            obj = obj@SampleBasedRecursiveUpdateFilter(name);
            obj = obj@GaussHermiteLinearGaussianFilter(name);
        end
    end
end
