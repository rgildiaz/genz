// settings

(
s = Dictionary.newFrom([
	/*
	* Enable recording.
	* boolean
	*/
	\record_enable, false,

	/*
	* Recording name.
	* string
	*/
	\record_name, "scd",

	/*
	* Total number of sections to create.
	* int
	*/
	\total_section_count, rrand(5,7),
]);



/*
* helper func
* calculates number of spaces for printSettings.
*/
~calcSpaces = {
	arg i;
	var out = "";
	for (0, 25-i.asString.size, { out = out ++ " " });
	out;
};

/*
* prints all settings.
*/
~printSettings = {
	d = ~s.getPairs();
	forBy (0, d.size-1, 2, {
		arg i;
		"%%%".format(d[i], ~calcSpaces.value(d[i]), d[i+1]).postln;
	});
};
~printSettings.value();\
)