function [ output_args ] = covellipse( mu, sigma, varargin )
%COVELLIPSE plot a covariance ellipse with mean mu and cov matrix sigma
%[] = covellipse ( mu, sigma, plotting-properties )

[V D]=eig(sigma);
unit1 = sqrt(D(1,1)/(V(1,1)*V(1,1)+V(2,1)*V(2,1)))*V(:,1);
unit2 = sqrt(D(2,2)/(V(1,2)*V(1,2)+V(2,2)*V(2,2)))*V(:,2);
sinterms = sin([0:96]*pi/48);
costerms = cos([0:96]*pi/48);
points = mu*ones(1,97)+unit1*costerms+unit2*sinterms;
plot (points(1,:),points(2,:),varargin{:});

end

