load('data_lecture.mat');

state = initial_state;
cov = 1e-100 * eye(3);
measurement_radius = 2;
stepwise = false;

% state and covariance history
states = [];
states(1).state = state;
states(1).cov = cov;
% prediction-innovation-loop
for t_k = 1:size(odom_meas,2)-1
    [state_pred, cov_pred] = slam_prediction (state, cov, odom_meas(:,t_k), noise_odom);
    observations = get_landmark_measurements(true_poses(:,t_k+1), true_landmarks, measurement_radius, noise_observation);
    
    if (isempty(observations))
        states(t_k + 1).state = state_pred;
        states(t_k + 1).cov = cov_pred;
        state = state_pred;
        cov = cov_pred;
    else
        [state_est, cov_est] = slam_innovation (state_pred, cov_pred, observations, noise_observation);
        states(t_k + 1).state = state_est; %#ok<*SAGROW>
        states(t_k + 1).cov = cov_est;
        state = state_est;
        cov = cov_est;
    end
    states(t_k + 1).pstate = state_pred;
    states(t_k + 1).pcov = cov_pred;
    states(t_k + 1).observations = observations;
    
    slam_visualize (states, observations, [], [-8 8 -8 8]);
    if (stepwise)
        ginput;
    else
        pause (0.2);
    end
end