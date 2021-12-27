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
	b[dir.folderName.asSymbol] = bufArray;
});
)



(
~series=[
	[5,7,4,2,0,12,7,5,7,4,2,0],
	[5,7,4,2,0,12,4,7,5,0],
	[-5,2,0,4,7,12,5,2,7,4,0,7,2,5,5,2,4,0],
	[7,7,2,4,4,4,2,0,7,0,0],
];


~chords = [
	[
		[1, 9, 7, 1],
		[0, -3, 3, 5],
		[0, -2, 2, 5],
		[1, -1, 5, 7]
	],
	[
		[1, 9, 7, 1],
		[0, -3, 3, 5],
		[0, -2, 2, 5],
		[1, -1, 5, 7]
	]
];

~intro = {
	var chords;
	chords = ~chords.removeAt(rrand(0, ~chords.size-1));
};

~outro = {
	var chords;
	chords = ~chords.removeAt(rrand(0, ~chords.size-1));
};

// c is an array of the events
c = [
	~intro.value(),
	~outro.value();
];
)

(
s.newBusAllocators;
~delBus = Bus.new();
~revBus = Bus.new();

SynthDef.new( \sqPunch, {
	arg freq=50, amp=0.5, pan=0, out=0,
	atk=0.1, rel=5,
	width=0.5;
	var sig, env, filtfreq,
	trans, transenv;

	filtfreq = freq*LFNoise1.kr(LFNoise1.kr(1).range(0.2, 1)).range(3, 7);

	env = EnvGen.ar(
		Env.new(
			[0.0001, 1, 0.0001],
			[atk, rel],
			['lin', 'exp']
		),
		doneAction: 2
	);
	transenv = EnvGen.ar(
		Env.new(
			[0.0001, 1, 0.0001],
			[0.02, 0.2],
			['lin', 'exp']
		)
	);

	trans = WhiteNoise.ar(0.5);
	trans = BPF.ar(
		trans,
		XLine.ar(
			{freq*rrand(2.0,3.0)}!5,
			0.001,
			0.2
		),
		0.1,
		1,
	);
	trans = trans + SinOsc.ar(freq, mul: 0.5);
	trans = trans * transenv;

	sig = Pulse.ar([freq, freq*rrand(0.99,1.01)], width, 0.3);
	sig = LPF.ar(sig, filtfreq);
	sig = sig + (
		{
			BPF.ar(
				Dust2.ar(1,0.8)+
				Dust2.ar(7,0.4)+
				Dust2.ar(17,0.2)+
				Dust2.ar(33,0.1)+
				Dust2.ar(66,0.05),
				freq*rrand(5,10)
			)
		}!2
		*rrand(0.5,0.75)
	);

	sig = sig * env;
	sig = sig + trans;
	sig = Pan2.ar(sig, pan, amp);

	Out.ar(out, sig);
}).add;


SynthDef.new( \noise, {
	arg freq=200, amp=0.5, pan=0, out=0,
	atk=5, rel=5;
	var sig, env, dust;

	env = EnvGen.ar(
		Env.new(
			[0.0001, 1, 0.0001],
			[atk, rel],
			['lin', 'exp']
		),
		doneAction: 2
	);

	sig = {
		SinOsc.ar(
			{freq*rrand(0.975,1.025)}!10 *
			Crackle.ar(
				LFNoise1.kr(1).range(1.0, 2.0)
			),
			mul: 1/5
		)
	};

	dust = Crackle.ar(
		LFNoise1.kr(1).range(1.0, 2.0),
		0.04
	);
	dust = BPF.ar(
		dust,
		freq*rrand(2,6)
	);

	// sig = sig + dust;

	sig = Pan2.ar(sig, pan);
	sig = sig * amp * env;


	Out.ar(out, sig);
}).add;

SynthDef.new( \choruSin, {
	arg freq=200, amp=0.5, pan=0, out=0,
	atk=5, rel=5;
	var sig, env, dust;

	env = EnvGen.ar(
		Env.new(
			[0.0001, 1, 0.0001],
			[atk, rel],
			['lin', 'exp']
		),
		doneAction: 2
	);

	sig = {
		SinOsc.ar(
			{freq*rrand(0.975,1.025)}!10,
			mul: 1/5
		)
	};

	dust = Crackle.ar(
		{LFNoise1.kr(0.2).range(1.0, 1.9)}!5,
		0.04
	);
	dust = BPF.ar(
		dust,
		freq*rrand(2,6)
	);

	// sig = sig + dust;

	sig = Splay.ar(sig, rrand(0.1, 0.3), center: pan);
	sig = sig * amp * env;


	Out.ar(out, sig);
}).add;

SynthDef.new( \shimmer, {
	arg freq=400, amp=0.25, pan=0, out=~revBus,
	atk=2, rel=5, detune=0;
	var sig, env,
	fm, fmenv, fmamt,
	spec, randtrans;

	amp = amp * rrand(0.8, 1);

	spec 	= [1, 1/3, 1/5, 1/7].normalizeSum * amp;
	spec = spec.collect({
		|i|
		i * rrand(0.6, 1);
	});

	randtrans	= Rand(0, atk/2);
	atk = atk - randtrans;
	rel = rel + randtrans;

	env 		= EnvGen.ar(
		Env.new(
			[0.001, 1, 0.001],
			[atk, rel],
			['lin', 'exp']
		),
		doneAction: 2
	);

	fmenv 	= EnvGen.ar(
		Env.new(
			[rrand(0.2, 0.5), 1, 0],
			[atk, rel],
			'lin'
		),
	);

	fmamt 	= EnvGen.ar(
		Env.new(
			[0.001, rrand(0.01, 0.02), 0.001],
			[atk, rel],
			'exp'
		),
	);

	fm 		= SinOsc.ar(rand(6.0, 10.0)*fmenv, mul: fmamt).unipolar;

	freq		= freq * fm;

	sig 		=
	SinOsc.ar(freq, rrand(0,pi), spec[0]) +
	SinOsc.ar(freq*2*(1 + rrand(0, detune)), rrand(0, pi), spec[1]) +
	SinOsc.ar(freq*3*(1 + rrand(0, detune)), rrand(0, pi), spec[2]) +
	SinOsc.ar(freq*4*(1 + rrand(0, detune)), rrand(0, pi), spec[3]);

	sig = sig.tanh;

	sig = HPF.ar(sig, freq*rrand(2.0, 3.0));

	sig = sig * env;
	sig = Pan2.ar(sig, pan);

	Out.ar(out, sig);
}).add;

SynthDef.new( \delay, {
	arg in=~delBus, out=0, amp=1,
	maxdelay=1, delay=0.3;
	var sig;

	sig = In.ar(in, 2);
	sig = sig + DelayL.ar(sig, maxdelay, delay, amp);

	Out.ar(out, sig);
}).add;

SynthDef.new( \reverb, {
	arg in=~revBus, out=0, amp=1,
	mix=0.33, room=0.5, damp=0.5;
	var sig;

	sig = In.ar(in, 2);
	sig = FreeVerb2.ar(sig[0], sig[1], mix, room, damp, amp);

	Out.ar(out, sig);
}).add;
)



Synth.new(\sqPunch);
Synth.new(\choruSin);
Synth.new(\noise);
(
Synth.new(\shimmer, [\freq, 800]);
Synth.new(\shimmer, [\freq, 600]);
Synth.new(\shimmer, [\freq, 640]);
)
(
t = TempoClock.new(120/60).permanent_(false);

Routine.new({
	~series.do({
		|i|
		i.do({
			|j|
			j.postln;
			Synth.new(\shimmer, [
				\freq, (j + 30).midicps,
				\rel, 1,
				\pan, rrand(-0.2, 0.2)
			]);
			1.yield;
		});
		4.yield;
	});
}).play(t);
)

(
t = TempoClock.new(120/60).permanent_(false);

r = Routine.new({
	c.do({
		|i|
		i.do({
			|j|
			j.postln;
			j.do({
				|k|
				k = k + 80;
				k = k.midicps;
				Synth.new(\choruSin, [
				\freq, k,
				\rel, rrand(5,10),
				\atk, rrand(5,10),
				\pan, rrand(-0.2, 0.2)
			]);
			});

			20.yield;
		});
	});
}).play(t);
)
