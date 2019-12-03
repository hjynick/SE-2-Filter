classdef MoveTest < handle
    properties
        rec
        step
    end

    methods
        function test= MoveTest(map)
            crawler = RealCrawler([0,0,0], map);
            test.rec = MovementRecorder(crawler);
            test.step="start";
        end
            
        function next(obj, other)
            dir = "error";
            i = 1
            while true
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

                if (dir == obj.step) && other
                else
                    break;
                end
            end
            obj.step = dir
        end

        function moveAndNext(obj)
            obj.rec.move(obj.step);
            obj.rec.plot();
            obj.next(0);
        end
    end
end

