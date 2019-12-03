classdef KalmanFilter < Observers.Observer

% KalmanFilter   Class implementing Kalman filter algorithm.



	properties

		A;  % State equation matrix (multiplied by x)

		B;  % State equation matrix (multipied by u)

		C;  % Output equation matrix (multiplied by x)

		D;  % Output equation matrix (multipied by u)

		x;  % State estimate

		z;  % Output estimate

		P;  % State covariance matrix estimate

		Q;  % Process noise covariance matrix

		R;  % Sensor noise covariance matrix

    end

    

	methods

		

		function KF = KalmanFilter(A,B,C,D,Q,R)

            % KalmanFilter  Constructor

            %   Construct a KalmanFilter object given state-space matrices

            %   A, B, C, D, Q, R.

            

            % Set all matrices

			KF.A = A;

			KF.B = B;

			KF.C = C;

			KF.D = D;

			KF.Q = Q;

			KF.R = R;

            

            % Set initialized flag

            KF.initialized = false;

        end

		

        

        function initialize(KF,t0,x0,u0)

            % initialize  Initialize the Kalman filter

            %   Initialize the KalmaFilter object given initial time,

            %   state, and inputs.

            

            % Intialize time, state, input, output, and state covariance

            KF.t = t0;

            KF.x = x0;

            KF.z = KF.C*x0 + KF.D*u0;

            KF.u = u0;

            KF.P = KF.Q;

            

            % Set initialized flag

            KF.initialized = true;

        end

		

        

		function estimate(KF,t,u,z)

            % estimate  Perform an estimation step of the Kalman filter

            %   Given new inputs and outptus, udpate the state and output

            %   estimates.

            

            % Ensure KF is initialized

            if ~KF.initialized

                error('KalmanFilter must be initialized first!');

            end

            

            % Predict state and covariance

            xkk1 = KF.A*KF.x + KF.B*KF.u;

            Pkk1 = KF.A*KF.P*KF.A' + KF.Q;

			

            % Update state, outputs, and covariance

			zk = z - (KF.C*KF.x + KF.D*u);

			Sk = KF.C*Pkk1*KF.C' + KF.R;		

			Kk = Pkk1*KF.C'/Sk;

			KF.x = xkk1 + Kk*zk;

			KF.P = (eye(length(KF.x)) - Kk*KF.C)*Pkk1;

			KF.z = KF.C*KF.x + KF.D*u;

            

            % Update time and inputs

            KF.t = t;

            KF.u = u;

        end

        

        

        function stateEstimate = getStateEstimate(KF)

            % getStateEstimate  Return a structure with mean and covariance

            %   Returns the current state estimate as a structure with

            %   fields 'mean' and 'covariance'.

            

            % Construct the data structure

            stateEstimate.mean = KF.x;

            stateEstimate.covariance = KF.P;

        end

		

	end

end