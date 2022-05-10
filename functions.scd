// functions

(
/// Basic functionality ///


/*
* makes a plan
*/
~setup = {
	// ~events is a list of dictionaries which represent major sections of the piece
	~events = [];
	~total_section_count.do({ |i|
		var event = Dictionary.newFrom([
			\index, i,
			\scene, (0..1).choose,					// 0 = soundscape, 1 = rhythm
			\length, ~chooseSceneLength.value,
			\chord, ~chooseChord.value,
			\amp, ~chooseAmp.value
		]);
		~events = ~events ++ [event];
	});
	~events;
};

/*
* main wrapper function for sound events.
*/
~play = {
	~events.do({ |i|
		"%".format(i).postln;
		~chooseMotif.value();
		~playScene.value(i[\index]);
		~stopPatterns.value();
	});
};

/*
* loads all sound files in the "audio/" subfolder into a buffer event b.
*/
~makeBuffers = {
	var path, subfolders;
	b = ();
	path = PathName(thisProcess.nowExecutingPath).parentPath;
	subfolders = PathName(path ++ "audio/").entries;
	subfolders.do({
		arg dir;
		var bufArray;
		bufArray = dir.entries.collect({
			arg file;
			Buffer.readChannel(s, file.fullPath, channels:[0])
		});
		b[dir.folderName.asSymbol] = bufArray;
	});
};

/*
* Finds an empty path for recording and starts the recording.
* ~record_enable enables and disables this function.
*/
~recordStart = {
	if ( ~record_enable,
		{
			var pathNotFound = true;
			var pathNum = 0;
			var path = PathName(thisProcess.nowExecutingPath).parentPath;

			while( pathNotFound,
				{
					if ( File.exists(path ++ "%_%.wav".format(~record_name, pathNum)),
						{ pathNum = pathNum + 1; },
						{ pathNotFound = false; }
					);
				}
			);
			s.record(path ++ "%_%.wav".format(~record_name, pathNum), numChannels: 2)
		}
	);
};

/*
* Ends a recording started by ~recordStart.
* ~record_enable enables and disables this function.
*/
~recordEnd = {
	if ( ~record_enable,
		{
			10.yield;
			s.stopRecording();
		}
	)
};

/*
* Decides a new root and chord. It also decides how loud the next section will be using by deciding on an ~ampScale between 0.25 and 1.
* Root is stored in ~root
* Chords are stored in ~chords and in Pdefn(\chords)
*/
~changeTonality = {
	var baseCh = Array.rand(6, -5.0, 12).sort;
	~chords = [
		baseCh.nearestInScale(Scale.choose.degrees),
		baseCh.nearestInScale(Scale.choose.degrees),
		baseCh.nearestInScale(Scale.choose.degrees),
	];
	Pdefn(\chords, ~chords);

	~root = rrand(45, 50);
	~ampScale = rrand(0.3, 1);
};
~changeTonality.value();


// returns an ampScale. called by setup.
~chooseAmp = {
	rrand(0.4, 0.9);
};

// returns a 7 note chord. called by setup. root is always the first pitch.
~chooseChord = {
	var chord = Array.rand(6, 1, 12).sort;
	var scale = Scale.choose.degrees;
	[~root_range] ++ (chord + ~root_range).nearestInScale(scale);
};



////  Motives ////

/*
* A list of currently active motives. Modified and accessed by ~chooseMotif.
*/
~current_motives = [];

/*
* Tracks and chooses motives each time a new scene is chosen.
* Motives are stored as arrays []
* Returns one of the  motifs from the motif list.
*/
~chooseMotif = {
	// If at max number of motives, chance to drop one
	if ( ~current_motives.size >= ~max_motives,
		{
			if ( [false, true].wchoose(~motif_retention_chance, 1 - ~motif_retention_chance),
				{
					~current_motives.removeAt(rrand(~current_motives.size/2, ~current_motives.size).floor);
				}
			);
		}

	);

	// add a motif if there isn't one in the list
	if ( ~current_motives.size == 0,
		{ ~newMotif.value() },
		{
			// If there are between 1 and ~max_motives in the list, there is a chance to create a new one.
			if ( ~current_motives.size < ~max_motives,
				{
					if ( [true, false].wchoose([~motif_create_chance, 1 - ~motif_create_chance]),
						{
							~newMotif.value()
						}
					);
				}
			);
		}
	);

	~current_motives.choose;
};

/*
* Generates a new motif.
* motives are created as arrays of midi keynums
*/
~newMotif = {
	var motif, motif_functions;

	motif_functions = [
		{
			arg i;
			i % 7
		},
		{
			rrand(0, 6)
		}
	];

	motif = Array.fill(rrand(2, 5), motif_functions.choose);
	~current_motives = ~current_motives ++ [motif];
};

~newMotif.value()
)