// init
(
"settings.scd".loadRelative;
"synthdefs.scd".loadRelative;
"functions".loadRelative;
"buffers.scd".loadRelative;

s.waitForBoot({
	r = Routine.new({
		~recordStart.value()

		s.sync;

		rrand(5,7).postln.do({
			|i|
			"Iteration: %".format(i).postln;
			~chordPool = [];

			// add at least 2 random chords to the chord pool and make sure they aren't duplicates
			rrand(2, ~chords.size-1).do({
				~chordPool.add(~chords.removeAt(rrand(0,~chords.size-1)));
			});

			s.sync;

			p.play(t);
			n.play(t);
			rrand(60, 120).yield;
			~changeTonality.value();
			p.reset;
			n.reset;
		});

		p.stop;
		n.stop;

		~recordEnd.value();

	}).play(t);
}, onFailure: "waitForBootFAILED".throw);

)