// birthday soundscape
// for mom

(
s.quit;
s.options.memSize = 2**20; // ran into some memory issues while working

~recordEnable = true;

t = TempoClock.new(60/60).permanent_(false);

s.waitForBoot({

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

	// Groups
	~srcGrp = Group.new;
	~fxGrp  = Group.new(~srcGrp, 'addAfter');

	// Busses
	s.newBusAllocators;
	~delBus = Bus.audio(s, 2);
	~revBus = Bus.audio(s, 2);

	////////////////////////////////

	///////////////////////////////

	////////////////////////////////

	// SynthDefs //////////////////

	////////////////////////////////

	SynthDef.new( \samp, {
		arg buf=0, rate=1, spos=0, loop=0,
		atk=0, sus=0.2, rel=0.2,
		lp=20000, hp=20, pan=0, amp=1, out=0;
		var sig, env;

		sig = PlayBuf.ar(
			1, buf, BufRateScale.ir(buf) * rate,
			startPos: spos, loop: loop
		);

		sig = LPF.ar(sig, lp);
		sig = HPF.ar(sig, hp);

		env = EnvGen.ar(
			Env.new([0,1,1,0],[atk,sus,rel],[1,0,-1]),
			doneAction:2
		);

		sig = sig * env;
		sig = Pan2.ar(sig, pan, amp);

		Out.ar(out, sig);
	}).add;

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
		atk=10, rel=10, gate=1,
		bpffreq=300, rq=5, crcklrt=0.5;
		var sig, env, dust;

		amp = amp/3;

		env = EnvGen.ar(
			Env.asr(atk, 1, rel),
			gate: gate,
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
			freq*rrand(2,6),
			2,
		);

		sig = sig + dust;

		sig = BPF.ar(sig, bpffreq, rq);

		sig = Splay.ar(sig,rrand(0.1, 0.2), amp, pan);

		// add moving dust
		sig = sig*(1/crcklrt) + {Pan2.ar(
			in:    Dust.ar(LFNoise1.kr(0.5).range(20,80)),
			pos:   LFNoise1.kr(3).range(-0.8, 0.8),
			level: LFNoise1.kr(2).range(0.03, 0.1)*crcklrt
		)/5}!5;

		sig = sig * env;

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
				[0.001, rrand(0.005, 0.015), 0.001],
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
		mix=0.5, room=0.9, damp=0.5;
		var sig;

		sig = In.ar(in, 2);
		sig = FreeVerb2.ar(sig[0], sig[1], mix, room, damp, amp);

		Out.ar(out, sig);
	}).add;

	s.sync;

	Synth(\reverb, [\in, ~revBus, \out, 0], ~fxGrp);

	s.sync;



	////////////////////////////////

	///////////////////////////////

	////////////////////////////////

	// Funcs //////////////////////

	////////////////////////////////



	// Define possible chords
	~changeTonality = {
		var baseCh = Array.rand(5, -5.0, 12).sort.postln;
		~chords = [
			baseCh.floor(),
			baseCh.round(),
			baseCh.ceil(),
			baseCh.nearestInScale(Scale.choose.degrees),
			baseCh.nearestInScale(Scale.choose.degrees),
			baseCh.nearestInScale(Scale.choose.degrees),
		];
		Pdefn(\chords, ~chords);

		~root = rrand(45, 50);
		~ampScale = linrand(0.25, 1);
		"AmpScale: %".format(~ampScale).postln;
	};
	~changeTonality.value();

	s.sync;



	////////////////////////////////

	///////////////////////////////

	////////////////////////////////

	// Routines ///////////////////

	////////////////////////////////

	// player
	p = Routine.new({
		var currentChord = ~chordPool[0];
		var func = {};

		// choose if noise will play
		if (
			[true, false].choose,
			{
				"Noise".postln;
				~noise = Synth.new( \noise, [
					\atk,		rrand(3, 5),
					\rel,		rrand(5, 10),
					\freq, 	rrand(150, 250),
					\amp, 	rrand(0.01, 0.05) * ~ampScale,
					\crcklrt,	rrand(0.0, 1.0),
					\gate,	1
				]).register;
			},
			{
				if (
					~noise.isPlaying,
					{ ~noise.set(\gate, 0) }
				);
				"no noise".postln;
			}
		);

		// 1/2 chance between variations
		switch ( rrand(0,1) )
		{0} {
			"func0".postln;
			func = {
				// 1/5 chance to change current chord
				if ( rrand(0, 4) == 0,
					{
						currentChord = ~chordPool.choose;
					},
				);

				3.do({
					if ( rrand(0, 1) == 0,
						{
							Synth.new( \choruSin, [
								\freq, 	(~root + currentChord.choose).midicps,
								\amp,		rrand(0.02, 0.2) * ~ampScale,
								\atk,		rrand(2, 5),
								\rel,		rrand(5, 10)
							]);
						},
					);
				});

				3.do({
					if ( rrand(0, 1) == 0,
						{
							Synth.new( \shimmer, [
								\freq, 	(~root + 12 + currentChord.choose).midicps,
								\amp,		rrand(0.05, 0.3) * ~ampScale,
								\atk,		rrand(2, 5),
								\rel,		rrand(5, 10)
							]);
						},
					);

					if ( rrand(0, 5) == 0,
						{
							Synth.new( \shimmer, [
								\freq, 	(~root + 24 + currentChord.choose).midicps,
								\amp,		rrand(0.05, 0.3) * ~ampScale,
								\atk,		rrand(5, 7),
								\rel,		rrand(5, 10)
							]);
						},
					)
				});

				if ( rrand(0, 1) == 0,
					{
						Synth.new( \sqPunch, [
							\freq, 	(~root - 12 + currentChord.choose).midicps,
							\amp,		rrand(0.02, 0.5) * ~ampScale,
							\rel,		rrand(5, 10)
						]);
					},
				);

				rrand(1,5).yield;
			}
		}
		{1} {
			"func1".postln;
			func = {
				// 1/9 chance to change current chord
				if ( rrand(0, 8) == 0,
					{
						currentChord = ~chordPool.choose;
					},
				);

				6.do({
					if ( rrand(0, 1) == 0,
						{
							Synth.new( \choruSin, [
								\freq, 	(~root + currentChord.choose).midicps,
								\amp,		rrand(0.02, 0.3) * ~ampScale,
								\atk,		rrand(2, 5),
								\rel,		rrand(5, 10)
							]);
						},
					);
				});

				1.do({
					if ( rrand(0, 4) == 0,
						{
							Synth.new( \shimmer, [
								\freq, 	(~root + 12 + currentChord.choose).midicps,
								\amp,		rrand(0.05, 0.2) * ~ampScale,
								\atk,		rrand(2, 5),
								\rel,		rrand(5, 10)
							]);
						},
					);

					if ( rrand(0, 5) == 0,
						{
							Synth.new( \shimmer, [
								\freq, 	(~root + 24 + currentChord.choose).midicps,
								\amp,		rrand(0.05, 0.4) * ~ampScale,
								\atk,		rrand(5, 7),
								\rel,		rrand(5, 10)
							]);
						},
					)
				});

				if ( rrand(0, 1) == 0,
					{
						Synth.new( \sqPunch, [
							\freq, 	(~root + currentChord.choose).midicps,
							\amp,		rrand(0.02, 0.3) * ~ampScale,
							\rel,		rrand(5, 10)
						]);
					},
				);

				rrand(1,5).yield;
			}
		};

		inf.do(func);
	});

	// folley
	n = Routine.new({
		var soundSet = [\b, \f].choose;

		if (
			[false, true].choose,
			{
				"Sampling".postln;
				inf.do({

					Synth.new( \samp, [
						\buf, 	b[soundSet][rrand(0, b[soundSet].size-1)],
						\amp, 	rrand(0.01, 0.5) * ~ampScale,
						\sus,		rrand(0.1, 0.4),
						\rel,		rrand(0.1, 0.3),
						\spos, 	rrand(0, b[soundSet][0].numFrames - 1),
						\out,		[0, ~revBus].choose,
						\pan,		rrand(-1, 1),
					]);

					rrand(0.0, 6).yield;
				});
			},
			{ "Not Sampling".postln; }
		);
	});

	// wrapper
	r = Routine.new({
		var climax = true;
		var pathFound = false;
		var pathNum = 0;
		var path = PathName(thisProcess.nowExecutingPath).parentPath;

		"start".postln;

		// Find valid path if record enabled
		if ( ~recordEnable,
			{
				while(
					{ pathFound == false },
					{
						if ( File.exists(path ++ "brth_%.wav".format(pathNum)),
							{ pathNum = pathNum + 1; },
							{ pathFound = true; }
						);
					}
				);
				s.record(path ++ "brth_%.wav".format(pathNum), numChannels: 2)
			}
		);

		s.sync;

		rrand(10,20).postln.do({
			|i|
			"Iteration: %".format(i).postln;
			~chordPool = [];

			// add at least 2 random chords to the chord pool and make sure they aren't duplicates
			rrand(2, ~chords.size-1).do({
				~chordPool.add(~chords.removeAt(rrand(0,~chords.size-1)));
			});

			s.sync;

			p.play(t);
			n.play(t);
			rrand(60, 120).yield;
			~changeTonality.value();
			p.reset;
			n.reset;
		});

		"end".postln;
		s.stopRecording();
	}).play(t);

}, onFailure: { \waitForBootFAILED.postln }
);
)
