classdef (Abstract) AbstractCrawler < handle
    properties
        map
    end
    properties(Constant)
        size = [1,-8.5, 3.5, -3.5] % front, back, right, left
    end
    
    
    methods (Abstract)
        dists=getUS(obj)
        move(obj, dir)
    end
    
    methods
        function crawler = AbstractCrawler(map)
            crawler.map = map;
        end
    end
            
end
        