// scenes

(
~soundscape = Routine.new({
	var chords = Pdefn(\chords).asStream.value().choose;
	var variation = rrand(0, 1);
	var func = {};

	// Choose a variation by setting the func.
	func = switch ( variation )
	{ 0 } {{
		4.do({
			if ( rrand(0, 2) == 0, {
				Synth.new( \choruSin, [
					\freq, 	(~root + chords.choose).midicps,
					\amp,		rrand(0.02, 0.2) * ~ampScale,
					\atk,		rrand(2, 5),
					\rel,		rrand(5, 10),
					\pan,		rrand(-1, 1),
				]);
			});
		});

		5.do({
			if ( rrand(0, 3) == 0, {
				Synth.new( \shimmer, [
					\freq, 	(~root + 12 + chords.choose).midicps,
					\amp,		rrand(0.05, 0.3) * ~ampScale,
					\atk,		rrand(2, 5),
					\rel,		rrand(5, 10),
					\pan,		rrand(-1, 1),
				]);
				Synth.new( \shimmer, [
					\freq, 	(~root + 12 + chords.choose).midicps,
					\amp,		rrand(0.05, 0.3) * ~ampScale,
					\atk,		rrand(2, 5),
					\rel,		rrand(5, 10),
					\pan,		rrand(-1, 1),
				]);
			});

			if ( rrand(0, 5) == 0, {
				Synth.new( \shimmer, [
					\freq, 	(~root + 24 + chords.choose).midicps,
					\amp,		rrand(0.05, 0.3) * ~ampScale,
					\atk,		rrand(5, 7),
					\rel,		rrand(5, 10),
					\pan,		rrand(-0.2, 0.2),
				]);
			})
		});

		if ( rrand(0, 1) == 0, {
			Synth.new( \choruSin, [
				\freq, 	(~root - 12 + chords.choose).midicps,
				\amp,		rrand(0.02, 0.5) * ~ampScale,
				\rel,		rrand(5, 10)
			]);
		});

		// Wait 1-5 beats
		rrand(1,5).yield;
	}}
	{ 1 } {{
		3.do({
			if ( rrand(0, 1) == 0, {
				Synth.new( \choruSin, [
					\freq, 	(~root + chords.choose).midicps,
					\amp,		rrand(0.02, 0.3) * ~ampScale,
					\atk,		rrand(2, 5),
					\rel,		rrand(5, 10),
					\pan,		rrand(-1, 1),
				]);
			});
		});

		3.do({
			if ( rrand(0, 1) == 0, {
				Synth.new( \choruSin, [
					\freq, 	(~root + 12 + chords.choose).midicps,
					\amp,		rrand(0.02, 0.3) * ~ampScale,
					\atk,		rrand(2, 5),
					\rel,		rrand(5, 10),
					\pan,		rrand(-1, 1),
				]);
			});
		});

		3.do({
			if ( rrand(0, 4) == 0, {
				Synth.new( \shimmer, [
					\freq, 	(~root + 12 + chords.choose).midicps,
					\amp,		rrand(0.05, 0.2) * ~ampScale,
					\atk,		rrand(2, 5),
					\rel,		rrand(5, 10),
					\pan,		rrand(-1, 1),
				]);
			});

			if ( rrand(0, 5) == 0, {
				Synth.new( \shimmer, [
					\freq, 	(~root + 24 + chords.choose).midicps,
					\amp,		rrand(0.05, 0.4) * ~ampScale,
					\atk,		rrand(5, 7),
					\rel,		rrand(5, 10),
					\pan,		rrand(-1, 1),
				]);
			})
		});

		if ( rrand(0, 1) == 0, {
			Synth.new( \choruSin, [
				\freq, 	(~root + chords.choose).midicps,
				\amp,		rrand(0.02, 0.3) * ~ampScale,
				\rel,		rrand(5, 10)
			]);
		});

		rrand(1,5).yield;
	}};

	// after choosing a func, run it 1000 times
	// this is 1000.do and not inf.do to avoid accidental infinite loops.
	1000.do(func);
});

~rhythm_list = [\sin, \playBuf, \choruSin, \white];

~rhythm = Routine.new({
	var chord = Pdefn(\chords).asStream.value().choose + ~root + 12;

	Pbindef( \sin,
		\instrument, \sin,
		\dur, Pwrand([1/8, 1/4, Rest(1/8)], [5, 1, 3].normalizeSum, inf),
		\freq, Prand((chord +.x [0, 12]).midicps, inf),
		\rel, Pexprand(0.005, 2),
		\amp, Pwhite(0.25, 0.75) * ~ampScale,
		\pan, Pwhite(-0.5, 0.5)
	).play;

	Pbindef( \playBuf,
		\instrument, \playBuf,
		\dur, Pwrand([1/8, 1/4, Rest(1/8), Rest(1/4)], [5, 1, 3, 2].normalizeSum, inf),
		\buf, Prand(b[\k], inf),
		\rel, Pexprand(0.2, 3),
		\amp, Pwhite(1, 2) * ~ampScale,
		\pan, Pwhite(-1.0, 1.0)
	).play;

	Pbindef( \choruSin,
		\instrument, \choruSin,
		\dur, Pwrand([4, 2, 1], [5, 3, 1].normalizeSum, inf),
		\freq, Prand((chord - 12).midicps, inf),
		\amp, Pwhite(0.25, 0.5) * ~ampScale,
		\pan, Pwhite(-1.0, 1.0)
	).play;

	Pbindef( \white,
		\instrument, \white,
		\dur, Pwrand([4, 3, 8, 1], [5, 3, 1, 2].normalizeSum, inf),
		\freq, Prand((chord + 12).midicps, inf),
		\amp, Pwhite(0.05, 0.1) * ~ampScale,
		\pan, Pwhite(-1.0, 1.0),
		\sus, Pexprand(0.05, 0.5)
	).play;
});





// A list of all available scenes.
~scenes_list = [~rhythm, ~soundscape].postln;

/*
* A list of currently active scenes.
*/
~current_scenes = [];

/*
* Chooses a scene from the ~scenes_list (located in scenes.scd)
* ~scenes_list is a list of routines, each representing a different routine.
*/
~chooseScene = {
	var scene;
	scene = ~scenes_list.choose;
	~current_scenes = ~current_scenes ++ [scene];
	scene.play(t);
};

/*
* Chooses the length of each scene based on the ~section_length setting.
*/
~chooseSceneLength = {
	rrand(~section_length[0], ~section_length[1]);
};

/*
* Reset all currently active scenes.
*/
~resetScenes = {
	~current_scenes.do({|i| i.reset});
	~rhythm_list.do({|i| Pbindef(i).stop});
};

/*
* Stop  all currently active scenes.
*/
~stopScenes = {
	~current_scenes.do({|i| i.stop});
	~rhythm_list.do({|i| Pbindef(i).stop});
};
)