(
"settings.scd".loadRelative;

s.waitForBoot({
	Buffer.freeAll;

	t = TempoClock.new(~tempo/60).permanent_(false);

	// post the randseed to save for later
	"\n\nthisThread.randData: %\n".format(thisThread.randData).postln;

	s.sync;

	"synthdefs.scd".loadRelative;
	"scenes.scd".loadRelative;
	"functions.scd".loadRelative;
	"patterns.scd".loadRelative;

	s.sync;

	~makeBuffers.value();
	~recordStart.value();
	~setup.value();
	~play.value();
	~recordEnd.value();
	"end".postln;
});
) 