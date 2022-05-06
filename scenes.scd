// scenes

(
~rhythmic = Routine.new({

});

~melodic = Routine.new({
});

~soundscape = Routine.new({
	var chords = Pdefn(\chords).asStream.value();
	var variation = rrand(0, 1);
	// this is 1000.do and not inf.do to avoid accidental infinite loops.
	1000.do({

	});
});

~scenes_list = [~soundscape];
)


(
p = Routine.new({
	var currentChord = Pdefn(\chords).asStream.value().choose();
	var func = {};

	switch ( rrand(0,1).postln; )
		{0} {
			"func0".postln;
			func = {
				4.do({
					if ( rrand(0, 2) == 0,
						{
							Synth.new( \choruSin, [
								\freq, 	(~root + currentChord.choose).midicps,
								\amp,		rrand(0.02, 0.2) * ~ampScale,
								\atk,		rrand(2, 5),
								\rel,		rrand(5, 10),
								\pan,		rrand(-1, 1),
							]);
						},
					);
				});

				5.do({
					if ( rrand(0, 3) == 0,
						{
							Synth.new( \shimmer, [
								\freq, 	(~root + 12 + currentChord.choose).midicps,
								\amp,		rrand(0.05, 0.3) * ~ampScale,
								\atk,		rrand(2, 5),
								\rel,		rrand(5, 10),
								\pan,		rrand(-1, 1),
							]);
							Synth.new( \shimmer, [
								\freq, 	(~root + 12 + currentChord.choose).midicps,
								\amp,		rrand(0.05, 0.3) * ~ampScale,
								\atk,		rrand(2, 5),
								\rel,		rrand(5, 10),
								\pan,		rrand(-1, 1),
							]);
						},
					);

					if ( rrand(0, 5) == 0,
						{
							Synth.new( \shimmer, [
								\freq, 	(~root + 24 + currentChord.choose).midicps,
								\amp,		rrand(0.05, 0.3) * ~ampScale,
								\atk,		rrand(5, 7),
								\rel,		rrand(5, 10),
								\pan,		rrand(-0.2, 0.2),
							]);
						},
					)
				});

				if ( rrand(0, 1) == 0,
					{
						Synth.new( \choruSin, [
							\freq, 	(~root - 12 + currentChord.choose).midicps,
							\amp,		rrand(0.02, 0.5) * ~ampScale,
							\rel,		rrand(5, 10)
						]);
					},
				);

				rrand(1,5).yield;
			}
		}
		{1} {
			"func1".postln;
			func = {
				/*// 1/5 chance to change current chord
				if ( rrand(0, 4) == 0,
					{
						currentChord = ~chordPool.choose;
					},
				);*/
				3.do({
					if ( rrand(0, 1) == 0,
						{
							Synth.new( \choruSin, [
								\freq, 	(~root + currentChord.choose).midicps,
								\amp,		rrand(0.02, 0.3) * ~ampScale,
								\atk,		rrand(2, 5),
								\rel,		rrand(5, 10),
								\pan,		rrand(-1, 1),
							]);
						},
					);
				});

				3.do({
					if ( rrand(0, 1) == 0,
						{
							Synth.new( \choruSin, [
								\freq, 	(~root + 12 + currentChord.choose).midicps,
								\amp,		rrand(0.02, 0.3) * ~ampScale,
								\atk,		rrand(2, 5),
								\rel,		rrand(5, 10),
								\pan,		rrand(-1, 1),
							]);
						},
					);
				});

				3.do({
					if ( rrand(0, 4) == 0,
						{
							Synth.new( \shimmer, [
								\freq, 	(~root + 12 + currentChord.choose).midicps,
								\amp,		rrand(0.05, 0.2) * ~ampScale,
								\atk,		rrand(2, 5),
								\rel,		rrand(5, 10),
								\pan,		rrand(-1, 1),
							]);
						},
					);

					if ( rrand(0, 5) == 0,
						{
							Synth.new( \shimmer, [
								\freq, 	(~root + 24 + currentChord.choose).midicps,
								\amp,		rrand(0.05, 0.4) * ~ampScale,
								\atk,		rrand(5, 7),
								\rel,		rrand(5, 10),
								\pan,		rrand(-1, 1),
							]);
						},
					)
				});

				if ( rrand(0, 1) == 0,
					{
						Synth.new( \choruSin, [
							\freq, 	(~root + currentChord.choose).midicps,
							\amp,		rrand(0.02, 0.3) * ~ampScale,
							\rel,		rrand(5, 10)
						]);
					},
				);

				rrand(1,5).yield;
			}
		};

		200.do(func);
});

// foley
n = Routine.new({
	var soundSet = [\b, \f].choose;

	if (
		[false, true].choose,
		{
			"Sampling".postln;
			100.do({

				Synth.new( \samp, [
					\buf, 	b[soundSet][rrand(0, b[soundSet].size-1)],
					\amp, 	rrand(0.01, 0.5) * ~ampScale,
					\sus,	rrand(0.1, 0.4),
					\rel,	rrand(0.1, 0.3),
					\spos, 	rrand(0, b[soundSet][0].numFrames - 1),
					\out,	[0, ~revBus].choose,
					\pan,	rrand(-1, 1),
				]);

				rrand(0.01, 6).yield;
			});
		},
		{ "Not Sampling".postln; }
	);

	if (
		~noise.isPlaying,
		{ ~noise.set(\gate, 0) }
	);

	// choose if noise will play
	if (
		[true, false].choose,
		{
			"Noise".postln;
			~noise = Synth.new( \noise, [
				\atk,		rrand(5, 10),
				\rel,		rrand(5, 10),
				\freq, 		rrand(150, 250),
				\amp, 		rrand(0.01, 0.05) * ~ampScale,
				\crcklrt,	rrand(0.0, 1.0),
				\gate,		1
			]).register;
		},
		{
			"No Noise".postln;
		}
	);
});
)