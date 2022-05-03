// init

(
s.waitForBoot({
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