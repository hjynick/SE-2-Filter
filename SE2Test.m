Q = SE2.dualQuaternionToMatrix(SE2(0,[5,5]).asDualQuaternion());
C = diag([100,-1,-1,-1]);
C = Q' * C * Q;
PlotSE2BinghamDist(SE2BinghamDistribution(C));