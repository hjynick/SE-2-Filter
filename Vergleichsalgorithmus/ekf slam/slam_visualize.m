function [  ] = slam_visualize( states, observations, true_landmarks, dim_axis)
%SLAM_VISUALIZE Summary of this function goes here
%   Detailed explanation goes here

state=states(length(states)).state;
covariance=states(length(states)).cov;
for i=1:length(states)
    history(:,i)=states(i).state(1:2);
end
num_landmarks = (length(state)-3)/2;
ids = [];
for i=1:length(observations)
    ids = [ ids observations(i).id ];
end
plot (history(1,:),history(2,:),'k-','LineWidth',2);
hold on
covellipse (state(1:2), covariance(1:2,1:2), 'k','LineWidth',2);
if (length(true_landmarks)>0)
    plot (true_landmarks(1,:), true_landmarks(2,:), 'xg','LineWidth',2);
end
for i=1:num_landmarks
    if (state(2+2*i)~=0 || state(3+2*i)~=0)
        if (ismember (i, ids))
            color1 = 'r-';
            color2 = 'r+';
        else
            color1 = 'b-';
            color2 = 'b+';
        end
        plot (state(2+2*i), state(3+2*i), color2,'LineWidth',2);
        covellipse (state(2+2*i:3+2*i), covariance (2+2*i:3+2*i,2+2*i:3+2*i), color1,'LineWidth',2);
    end
end
%plot (states(length(states)).pstate(1), states(length(states)).pstate(2), 'g*','LineWidth',2);
hold off;
axis equal
axis (dim_axis);

end

