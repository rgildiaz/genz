// functions

(

/// Basic functionality ///

/*
* main wrapper function for sound events.
* ~play
*/
~play = {
	~total_section_count.do({ |i|
		"Section Number: %\n".format(i).postln;

		~chooseScene.value();
		~chooseSceneLength.value().yield;
		~changeTonality.value();
		~resetScenes.value();
	});

	~stopScenes.value();
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
			var pathFound = false;
			var pathNum = 0;
			var path = PathName(thisProcess.nowExecutingPath).parentPath;

			while( pathFound == false,
				{
					if ( File.exists(path ++ "%_%.wav".format(~record_name, pathNum)),
						{ pathNum = pathNum + 1; },
						{ pathFound = true; }
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
* Decides a new root and three new chords that use that root. It also decides how loud the next section will be using by deciding on an ~ampScale between 0.25 and 1.
* Root is stored in ~root
* Chords are stored in ~chords and in Pdefn(\chords)
*/
~changeTonality = {
	var baseCh = Array.rand(rrand(3, 7), -5.0, 12).sort;
	~chords = [
		baseCh.nearestInScale(Scale.choose.degrees),
		baseCh.nearestInScale(Scale.choose.degrees),
		baseCh.nearestInScale(Scale.choose.degrees),
	];
	Pdefn(\chords, ~chords);

	~root = rrand(45, 50);
	~ampScale = rrand(0.25, 1);
	"Root: %".format(~root).postln;
	"AmpScale: %".format(~ampScale).postln;
};
~changeTonality.value();






////  Motives ////

// !!!!!!!!!!!!!!!!!!!!!!!
// !!! NOT IMPLEMENTED !!!
// !!!!!!!!!!!!!!!!!!!!!!!

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
					if ( [true, false].wchoose(~motif_create_chance, 1 - ~motif_create_chance),
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

		},
		{}
	];

	motif = Array.fill(rrand(2, 5), motif_functions.choose);
	~current_motives = ~current_motives ++ [motif];
};
)