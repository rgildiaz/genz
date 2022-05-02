// synthdefs

(
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
			{freq*rrand(0.975,1.025)}!8,
			mul: 1/5
		)
	};

	dust = Crackle.ar(
		{LFNoise1.kr(0.2).range(1.0, 1.9)}!3,
		0.04
	);
	dust = LPF.ar(
		dust,
		freq*rrand(2,6)
	);

	if (
		rrand(0,5) == 0,
		{sig = sig + dust}
	);

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
			[0.001, rrand(0.005, 0.007), 0.001],
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
)