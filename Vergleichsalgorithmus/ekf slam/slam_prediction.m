function [ state_pred, cov_pred] = slam_prediction(state, cov, odom, noise_odom)
%SLAM_PREDICTION The prediction step of the extended kalman filter
% Input:
%  state: the current state 
%  cov: the current covariance matrix
%  odom: The delta motion of the agent
%  noise_odom: The covariance matrix for the delta motion
%
% Output: 
%  state_pred: The state after the prediction
%  cov_pred: The covariance after the prediction

F = [1 0 -sin(state(3))*odom(1)-cos(state(3))*odom(2); ...
     0 1  cos(state(3))*odom(1)-sin(state(3))*odom(2); ...
     0 0  1];
 
state_pred = state;
state_pred(1:2) = state(1:2) + ([cos(state(3)) -sin(state(3)); sin(state(3)) cos(state(3))]*odom(1:2));
state_pred(3) = state(3) + odom(3);
cov_pred = cov;

cov_pred(1:3,1:3) = F*cov(1:3,1:3)*F' + noise_odom;

end

