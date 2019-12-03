function measurements = get_landmark_measurements(true_pose, landmarks, radius, noise_measurement)
    num_meas = 0;
    measurements = [];
    phi = true_pose(3);
    for i = 1:size(landmarks,2)
        delta = landmarks(:,i) - true_pose(1:2);
        R = [ cos(phi) sin(phi); ...
             -sin(phi) cos(phi)];
        % check for distance
        if (delta'*delta <= radius*radius)
            num_meas = num_meas + 1;
            measurements(num_meas).id = i; %#ok<*AGROW>
            measurements(num_meas).pos = R*delta + normrnd(0,sqrt(noise_measurement),2,1);
        end
    end
end

