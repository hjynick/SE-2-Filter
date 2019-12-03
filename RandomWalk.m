classdef RandomWalk < handle
    properties
        crawler
        file
        i = 0;
        records
        steps
        offset
    end
    methods
        function walk= RandomWalk(crawler, file, offset)
            walk.crawler = crawler;
            if nargin > 1
                walk.offset = offset;
                load(file);
                walk.i = 1;
                walk.records = r;
                walk.steps = s;
                walk.realStep();
            end
        end
        
        function dir = Step(obj)
            if obj.i == 0
                dir = obj.randomStep();
            else
                dir = obj.realStep();
            end
        end

        function dir= realStep(obj)
            if obj.i >= length(obj.steps)-1
                dir = 'none';
            else
                dir = obj.steps(obj.i);
                obj.crawler.pos = obj.records(obj.i, 1:2) + obj.offset;
                obj.crawler.rot = obj.records(obj.i, 3);
                obj.i = obj.i + 1;
            end
        end
        
        
        function dir= randomStep(obj)
            dir = obj.nextDir();
            obj.crawler.move(dir);
        end
        
        function dir = nextDir(obj)
            dir = "error";
            switch randi(4)
                case 1
                    dir = "fwdStep";
                case 4
                    dir = "fwdStep";
                case 2
                    dir = "turnr";
                case 3
                    dir = "turnl";
            end
        end

    end
end