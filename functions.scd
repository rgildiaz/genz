// functions

(
/*
* main wrapper function for sound events.
*/
~play = {
	~tempoStart.value();

	~total_section_count.do({ |i|
		"\nSection Number: %".format(i).postln;

		p.play(t);
		n.play(t);
		rrand(60, 120).yield;
		~changeTonality.value();
		p.reset;
		n.reset;
	});

	p.stop;
	n.stop;
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

~tempoStart = {
	t = TempoClock.new(60/60).permanent_(false);
};

~changeTonality = {
	var baseCh = Array.rand(5, -5.0, 12).sort.postln;
	~chords = [
		baseCh.nearestInScale(Scale.choose.degrees),
		baseCh.nearestInScale(Scale.choose.degrees),
		baseCh.nearestInScale(Scale.choose.degrees),
	];
	Pdefn(\chords, ~chords);

	~root = rrand(45, 50);
	~ampScale = rrand(0.25, 1);
	"AmpScale: %".format(~ampScale).postln;
};
~changeTonality.value();
)