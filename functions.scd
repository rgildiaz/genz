// functions
// setings use snake_case, functions use camelCase

(

/*
* Finds an empty path for recording and starts the recording.
* ~record_enable enables and disables this function.
*/
~recordStart = {
	// Find valid path if record enabled
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
	if ( ~recordEnable,
		{
			10.yield;
			s.stopRecording();
		}
	)
};
)