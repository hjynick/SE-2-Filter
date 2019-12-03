map = Map.Triangle();
crawler = SimCrawler([0,0, 0], map);


pf=robotics.ParticleFilter;
pf.StateEstimationMethod='mean';
pf.ResamplingMethod='systematic';
initialize(pf, 100, [0, -1, 0.2], diag([1,1,0.5]), 'CircularVariables',[0 0 1]);

pf.StateTransitionFcn = @stateTransition;
pf.MeasurementLikelihoodFcn = @measurementLikelihood;

% Last best estimation for x, y and theta
lastBestGuess = [0 0 0];
simulationTime = 0;

figure(1);
r = robotics.Rate(1);
% Reset the fixed-rate object
reset(r);

while simulationTime < 40
    dir = 'fwdStep';
    crawler.move(dir);
    
    % Predict the carbot pose based on the motion model
    [statePred, covPred] = predict(pf, dir);
    
    measurement = crawler.getUS();
    
    
    [stateCorrected, covCorrected] = correct(pf, measurement', map);
    lastBestGuess = stateCorrected(1:3);
    
    % Update plot
    if ~isempty(get(groot,'CurrentFigure')) % if figure is not prematurely killed
        updatePlot(crawler, pf, lastBestGuess);
    else
        break
    end
    
    waitfor(r);
    simulationTime = simulationTime + 1;
end



function updatePlot(crawler, pf, lastBestGuess)
figure(1);
hold on
plot(pf.Particles(:,1),pf.Particles(:,2),'g+');
plot(lastBestGuess(1),lastBestGuess(2),'ro');
plot(crawler.pos(1),crawler.pos(2),'b*');
hold off
end

function predictParticles = stateTransition(pf, prevParticles, dir)

    thetas = prevParticles(:,3);
    move = getMove(dir);

    l = length(prevParticles);

    % Generate velocity samples
    sd1 = 0.7;
    sd2 = 1.5;
    sd3 = 0.02;
    moves(:,1) = move(1) + (sd1)^2*randn(l,1);
    moves(:,2) = move(2) + (sd2)^2*randn(l,1);
    moves(:,3) = move(3) + (sd3)^2*randn(l,1);
    moves = bsxfun(@rotate, moves', thetas');

    % Convert velocity samples to pose samples
    predictParticles = prevParticles +  moves';

end

function w=rotate(v,theta)
w = [RotationMat2D(theta+pi/2) * v(1:2); v(3)];
end

function  likelihood = measurementLikelihood(pf, predictParticles, measurement, map)

l = length(predictParticles);

predictMeasurement = zeros(l,4);
for i = 1:l
    predictMeasurement(i,:) = SimCrawler(predictParticles(i,:), map).getUS();
end

measurementError = bsxfun(@minus, predictMeasurement, measurement');
measurementErrorNorm = sqrt(sum(measurementError.^2, 2));

measurementNoise = eye(3);

likelihood = 1/sqrt((2*pi).^3 * det(measurementNoise)) * exp(-0.5 * measurementErrorNorm);
end


function move=getMove(dir)
move= [0;1;0];
end


