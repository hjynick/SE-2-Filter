filter = SE2Filter;

system = SystemModel;

filter.predict(system, 'fwdStep');

PlotSE2BinghamDist(filter.getEstimate());