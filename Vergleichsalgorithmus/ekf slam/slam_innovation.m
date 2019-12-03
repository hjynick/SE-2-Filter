function [ state_est, cov_est] = slam_innovation(state, cov, observations, noise_observation)
% SLAM_INNOVATION The innovation of the EKF-SLAM
% Input
%  state: The current (predicted) state
%  cov: The current (predicted) covariance matrix
%  observations: The list of observations as [ID_1, x_1, y_1; ... ID_N,
%                x_N, y_N].
%  noise_observation: The variance of the measurement (a scalar).
%
% Output
%  state_est: The estimated state
%  cov_est: The estimated covariance

num_landmarks = (length(state)-3)/2;
observation = [];
prediction = [];
H = [];
sinphi = sin(state(3));
cosphi = cos(state(3));

if (length(observations) == 0 )
    return;
end

for i=1:length(observations);
    id = observations(i).id;
    if (id > num_landmarks)
        % extend the state dynamically
        nd = 2*(id-num_landmarks);
        state = [state ; zeros(nd,1)]; %#ok<*AGROW>
        cov = [ cov, zeros(3+2*num_landmarks, nd); zeros(nd, 3+2*num_landmarks), 1e10*eye(nd)];
        [r c]=size(H);
        if (r>0)
            H = [ H, zeros(r,nd) ];
        end
        
        num_landmarks = id;
    end
    
    d = state(2+2*id:3+2*id)-state(1:2);
    prediction = [ prediction; cosphi*d(1)+sinphi*d(2); -sinphi*d(1)+cosphi*d(2) ];
    observation = [ observation; observations(i).pos ];
    Hneu = zeros (2,3+2*num_landmarks);
    Hneu (1,1:3) = [-cosphi -sinphi -sinphi*d(1)+cosphi*d(2)];
    Hneu (2,1:3) = [sinphi -cosphi -cosphi*d(1)-sinphi*d(2) ];
    Hneu (1:2,2+2*id:3+2*id) = [ cosphi sinphi; -sinphi cosphi];
    if (length(H)==0)
        H = Hneu;
    else
        H = [ H ; Hneu ];
    end
end

K = cov*H'*inv(H*cov*H'+noise_observation*eye(2*length(observations)));
state_est = state+K*(observation-prediction);
cov_est = (eye(3+2*num_landmarks)-K*H)*cov;

end

