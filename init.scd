(
"settings.scd".loadRelative;

s.waitForBoot({
	t = TempoClock.new(~tempo/60).permanent_(false);

	// post the randseed to save for later
	"\n\nthisThread.randData: %\n".format(thisThread.randData).postln;

	s.sync;

	"synthdefs.scd".loadRelative;
	"scenes.scd".loadRelative;
	"functions.scd".loadRelative;

	s.sync;

	~makeBuffers.value();
	~recordStart.value();
	~play.value();
	~recordEnd.value();
});
)