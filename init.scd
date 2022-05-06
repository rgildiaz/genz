// init

(
s.waitForBoot({
	t = TempoClock.new(~tempo/60).permanent_(false);

	// post the randseed to save for later
	"\n\nthisThread.randData: %\n\n".format(thisThread.randData).postln;

	s.sync;

	"settings.scd".loadRelative;
	"synthdefs.scd".loadRelative;
	"functions.scd".loadRelative;
	"patterns.scd".loadRelative;
	"scenes.scd".loadRelative;

	s.sync;

	~makeBuffers.value();
	~recordStart.value();
	~play.value();
	~recordEnd.value();
});
)