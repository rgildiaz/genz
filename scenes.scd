// scenes

(
~rhythm_list = [\sin, \sin2, \playBuf, \guitPlayBuf, \rchoruSin, \white];
~soundscape_list = [\shimmer, \choruSin, \choruSin2];

// A list of all available patterns.
~patterns_list = ~rhythm_list ++ ~soundscape_list;

~soundscape = {
	Pbindef( \shimmer ).play;

	Pbindef( \choruSin ).play;

	Pbindef( \choruSin2	).play;
};


~rhythm = {
	Pbindef( \sin ).play;

	if ([true, false].choose, {
		Pbindef( \sin2 ).play;
	});

	if ([true, false].choose, {
		Pbindef( \playBuf ).play;
		Pbindef( \guitPlayBuf ).play;
		Pbindef( \white	).play;
	});

	Pbindef( \choruSin ).play;
};


// A list of all available scenes.
~scenes_list = [~soundscape, ~rhythm];

/*
* A list of currently active scenes.
*/
~current_scenes = [];

~current_patterns = [];

/*
* Chooses a scene from the ~scenes_list (located in scenes.scd)
* ~scenes_list is a list of routines, each representing a different routine.
*/
~chooseScene = {
	var scene;
	scene = ~scenes_list.choose;
	~current_scenes = ~current_scenes ++ [scene];
	Routine(scene).play(t);
};

/*
* Chooses the length of each scene based on the ~section_length setting.
*/
~chooseSceneLength = {
	rrand(~section_length[0], ~section_length[1]);
};


~playScene = {
	arg i;
	var scene, length, chord, amp,
	markers, pat, next_e;

	e = ~events[i];
	scene = ~scenes_list[e[\scene]];	// \scene is either 1 or 0, so it can be an index.
	length = e[\length];
	chord = e[\chord];
	amp = e[\amp];

	// set global chord
	Pdefn(\chord, chord);

	// define markers within section length
	markers = Array.fill(3, { rrand(1.0, length) }).sort.normalizeSum;
	markers = markers * length;

	// start playing the scene
	Routine(scene).play(t);
	switch (e[\scene],
		0, ~current_patterns = ~current_patterns ++ ~soundscape_list,
		1, ~current_patterns = ~current_patterns ++ ~rhythm_list
	);

	// then make changes at each marker
	markers.do({ |i|
		var func;
		i.postln;
		i.yield;

		// chance to add/drop instruments
		switch( rrand(0,3),
			0, func = ~dropInstrument,
			1, func = ~addInstrument,
			3, Pbindef( \guitPlayBuf ).play
		);
		func.value;

		// chance to change some pbindefs
		pat = ~current_patterns.choose.postln;
		Pbindef(pat,
			\amp, Env.new(
				[rrand(0.1, 0.75), rrand(0.5, 0.9), rrand(0.0, 1)],
				[rrand(1.0, 10.0), rrand(1.0, 10.0)],
				'exp').asPseg * ~ampScale,
			\dur, Env.new(
				[rrand(0.25, 4), rrand(0.25, 5), rrand(0.25, 10)],
				[rrand(1.0, 10.0), rrand(1.0, 10.0)],
				'exp').asPseg.round(0.25),
		);
	});

	next_e = ~events[i + 1];

	// on the last marker, start transition
	if (next_e.isNil, {/*next scene is nil*/}, {
		if (e[\scene] == 0,
			{ // scene is soundscape
				if (next_e[\scene] == 0,
					{ // next scene is soundscape
						"to soundscape".postln;
						Pbind(
							\instrument, \choruSin,
							\dur, Env(
								[5.0, 0.5],
								[length - markers[2]],
								\exp
							).asPseg,
							\amp, Env(
								[0.01, 0.5],
								[length - markers[2]],
								\exp
							).asPseg,
							\freq, Prand(next_e[\chord].midicps, inf)
						).play;
					},
					{ // next scene is rhythmic
						"to rhythm".postln;
						Pbind(
							\instrument, \choruSin,
							\dur, Env(
								[5, 1.0],
								[length - markers[2]],
								\exp
							).asPseg,
							\amp, Env(
								[0.01, 0.5],
								[length - markers[2]],
								\exp
							).asPseg * ~ampScale,
							\atk, Pwhite(0.02, 0.2),
							\rel, Env(
								[rrand(3.0, 4.5), rrand(0.04, 0.1)],
								[length - markers[2]],
								\exp
							).asPseg,
							\freq, Prand(next_e[\chord].midicps, inf)
						).play;

						Pbind(
							\instrument, \playBuf,
							\dur, 1/8,
							\buf, Prand(b[\g], inf),
							\rel, Pexprand(0.2, 3),
							\amp, Env(
								[0.0001, 0.5],
								[length - markers[2]],
								\exp
							).asPseg * ~ampScale,
							\pan, Pwhite(-0.5, 0.5),
							\rate, Env(
								[0.8, 1.5],
								[length - markers[2]],
								\exp
							).asPseg
						).play;
					}
				)
			},
			{ // scene is rhythmic
				if (next_e[\scene] == 0,
					{ // next scene is soundscape
						"to soundscape".postln;
						Pbind(
							\instrument, \sin,
							\dur, Env(
								[0.5, 5],
								[length - markers[2]],
								\exp
							).asPseg,
							\amp, Env(
								[0.01, 0.25],
								[length - markers[2]],
								\exp
							).asPseg * ~ampScale,
							\atk, Env(
								[rrand(0.04, 0.1), rrand(3.0, 4.5)],
								[length - markers[2]],
								\exp
							).asPseg,
							\rel, Env(
								[rrand(0.04, 0.1), rrand(3.0, 4.5)],
								[length - markers[2]],
								\exp
							).asPseg,
							\freq, [next_e[\chord].choose, next_e[\chord].choose, next_e[\chord].choose]
						).play;

						Pbindef( \sin,
							\amp, Env(
								[0.25, 0.001],
								[length - markers[2]],
								\exp
							).asPseg * ~ampScale,
							\dur, Env(
								[0.5, 5],
								[length - markers[2]],
								\exp
							).asPseg
						).play;

						Pbindef( \sin2,
							\amp, Env(
								[0.25, 0.001],
								[length - markers[2]],
								\exp
							).asPseg * ~ampScale,
							\dur, Env(
								[0.5, 5],
								[length - markers[2]],
								\exp
							).asPseg
						).play;
					},
					{ // next scene is rhythmic
						"to rhythm".postln;
						Pbind(
							\instrument, \sin,
							\dur, Pwrand([1/8, 1/4, Rest(1/8)], [5, 1, 3].normalizeSum, inf),
							\amp, Env(
								[0.01, 0.2],
								[length - markers[2]],
								\exp
							).asPseg * ~ampScale,
							\atk, Env(
								[rrand(0.04, 0.1), rrand(0.2, 0.5)],
								[length - markers[2]],
								\exp
							).asPseg,
							\rel, Env(
								[rrand(0.04, 0.1), rrand(0.2, 0.5)],
								[length - markers[2]],
								\exp
							).asPseg,
							\freq, Prand(next_e[\chord].midicps, inf)
						).play;
					}
				)
			}
	)}
	);

	// wait the last amount
	(length - markers[2]).yield;
};

~dropInstrument = {
	var pat = rrand(0, ~current_patterns.size - 1);
	Pbindef(~current_patterns[pat]).stop;
	~current_patterns.removeAt(pat);
	"drop %".format(~current_patterns[pat]).postln;
	~current_patterns.postln;
};

~addInstrument = {
	var pat = ~patterns_list.choose;
	Pbindef(pat).play(t);
	"add %".format(pat).postln;
	~current_patterns = ~current_patterns ++ [pat];
	~current_patterns.postln;
};

/*
* Stop  all currently active patterns.
*/
~stopPatterns = {
	~patterns_list.do({|i| Pbindef(i).stop});
	~current_patterns = [];
};
)