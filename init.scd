// init
(
"settings.scd".loadRelative;
"synthdefs.scd".loadRelative;
"functions".loadRelative;
"buffers.scd".loadRelative;

s.sync;

"patterns.scd".loadRelative;

s.waitForBoot({
	~makeBuffers.value();

	s.sync;

	r = Routine.new({
		~recordStart.value();

		s.sync;

		~play.value();
		~recordEnd.value();

	}).play(t);
}, onFailure: "waitForBootFAILED".throw;
);
)