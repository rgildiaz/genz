// init

(
s.waitForBoot({
	t = TempoClock.new(60/60).permanent_(false);

	// Set a seed I like
	"\n\nthisThread.randData: %\n\n".format(thisThread.randData).postln;

	s.sync;

	"settings.scd".loadRelative;
	"synthdefs.scd".loadRelative;
	"functions.scd".loadRelative;
	"buffers.scd".loadRelative;
	"patterns.scd".loadRelative;

	s.sync;

	"scenes.scd".loadRelative;

	~makeBuffers.value();

	s.sync;

	r = Routine.new({
		~recordStart.value();

		s.sync;

		~play.value();
		~recordEnd.value();

	}).play(t);
});
)