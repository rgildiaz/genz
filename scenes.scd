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

	Pbindef( \sin2 ).play;

	Pbindef( \playBuf ).play;

	Pbindef( \guitPlayBuf ).play;

	Pbindef( \rchoruSin	).play;

	Pbindef( \white	).play;
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
	markers, pat;

	e = ~events[i];
	scene = ~scenes_list[e[\scene]];	// \scene is either 1 or 0, so it can be an index.
	length = e[\length];
	chord = e[\chord];
	amp = e[\amp];

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
		2.do({
			switch( rrand(0,3),
				0, func = ~dropInstrument,
				1, func = ~addInstrument
			);
		});
		func.value;

		/*// chance to change some pbindefs
		pat = ~current_patterns.choose.postln;
		Pbindef(pat,
			\amp, Env.new(
				[rrand(0.1, 0.75), rrand(0.5, 0.9), rrand(0.0, 1)],
				[rrand(1.0, 10.0), rrand(1.0, 10.0)],
				'exp').asPseg,
			\dur, Env.new(
				[rrand(0.25, 4), rrand(0.25, 5), rrand(0.25, 10)],
				[rrand(1.0, 10.0), rrand(1.0, 10.0)],
				'exp').asPseg.round(0.25),
		);*/
	});

	// on the last marker, start transition

	// wait the last amount
	(length - markers[2]).yield;
};

~dropInstrument = {
	var pat = rrand(0, ~current_patterns.size - 1);
	"drop %".format(~current_patterns[pat]).postln;
	Pbindef(~current_patterns[pat]).stop;
	~current_patterns.removeAt(pat);
};

~addInstrument = {
	var pat = ~patterns_list.choose;
	Pbindef(pat).play(t);
	"add %".format(pat).postln;
	~current_patterns = ~current_patterns ++ [pat];
};

/*
* Stop  all currently active patterns.
*/
~stopPatterns = {
	~current_patterns.do({|i| Pbindef(i).stop});
	~current_patterns = [];
};
)