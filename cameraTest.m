m = Map;
crawler = RealCrawler([0,0,0], m);

rec = MovementRecorder(crawler);

rec.move('turnl');
rec.move('turnl');
rec.move('turnl');
rec.move('turnl');
rec.move('turnl');
rec.move('turnl');
rec.move('turnl');
rec.move('turnl');
rec.move('turnl');
rec.move('turnl');


rec.save();
rec.plot();