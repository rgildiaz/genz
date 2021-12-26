// untitled

////////
//test//
////////

(
// Load the buffers

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
	b[dir.folderName.asSymbol] = bufArray;\
});
)


t = TempoClock.new(120/60).permanent_(false);



~chords = [
	[
		[], [],
	],
	[],
];

~intro = {
	var chords;
	chords = ~chords.removeAt(rrand(0, ~chords.size-1));

};


// c is an array of the events
c = [
	~intro,
	~outro
];

(
SynthDef.new( \sqHarm, {
	arg freq=200, amp=0.5, pan=0, out=0,
	atk=5, rel=5,
	width=0.5, filtfreq=1000;
	var sig, env;

	env = EnvGen.ar(
		Env.new(
			[0.0001, 1, 0.0001],
			[atk, rel],
			'lin'
		),
		doneAction: 2
	);

	sig = Pulse.ar(freq, width);
	sig = LPF.ar(sig, filtfreq);

	sig = Pan2.ar(sig, pan, amp);
	sig = sig * env;

	Out.ar(out, sig);
}).add;


SynthDef.new( \choruSin, {
	arg freq=200, amp=0.5, pan=0, out=0,
	atk=0.5, rel=0.5;
	var sig, env;

	env = EnvGen.ar(
		Env.new(
			[0.0001, 1, 0.0001],
			[atk, rel],
			'exp'
		),
		doneAction: 2
	);

	sig = {SinOsc.ar(freq*rrand(0.99,1.01))}!10;

	sig = Pan2.ar(sig, pan);
	sig = sig * amp * env/10;

	Out.ar(out, sig);
}).add;
)

Synth.new(\sqHarm);



r = Routine.new({
	c.do({
		|i|
		var wait;
		wait = i.value();
		wait.yield;
	});
}).play(t);