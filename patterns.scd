// patterns

(
var chord = (Pdefn(\chords).asStream.value.choose + ~root) +.x [-12, 0];

Pbindef( \shimmer,
	\instrument, \shimmer,
	\dur, Prand([
		Prand([1, 4], Pwhite(1, 4)),
		Prand((1..5), Pwhite(1, 4)),
		Prand([
			Pexprand(0.25, 5, Pwhite(1, 5)).round(0.25),
			Pwhite(0.5, 4, Pwhite(2, 3)).round(0.25)
		], Pwhite(1, 10))
	], inf),
	\freq, Prand([
		Pseq(chord[~current_motives.choose] + 12, 1),
		Prand(chord, Pwhite(1, 4))
	], inf).midicps,
	\amp, Pwhite(0.1, 0.25) * ~ampScale,
	\atk, Prand([
		Pwhite(5.0, 7.0, Pwhite(1, 100)),
		Pexprand(0.03, 4, Pwhite(1, 100))
	], inf),
	\rel, Prand([
		Pwhite(5.0, 7.0, Pwhite(1, 100)),
		Pexprand(5, 10, Pwhite(1, 100))
	], inf),
	\pan, Pwhite(-1.0, 1.0)
);

Pbindef( \choruSin,
	\instrument, \choruSin,
	\dur, Prand([
		Prand([1, 4], Pwhite(1, 4)),
		Prand((1..5), Pwhite(1, 9)),
		Prand([
			Pexprand(0.25, 5, Pwhite(4, 7)).round(0.25),
			Pwhite(0.5, 4, Pwhite(4, 9)).round(0.25)
		], Pwhite(1, 10))
	], inf),
	\freq, (Prand(chord, inf)).midicps,
	\amp, Pwhite(0.1, 0.25) * ~ampScale,
	\atk, Prand([
		Pwhite(5.0, 7.0, Pwhite(1, 100)),
		Pexprand(0.03, 4, Pwhite(1, 100))
	], inf),
	\rel, Prand([
		Pwhite(5.0, 7.0, Pwhite(1, 100)),
		Pexprand(0.03, 4, Pwhite(1, 100))
	], inf),
	\pan, Pwhite(-1.0, 1.0)
);

Pbindef( \choruSin2,
	\instrument, \choruSin,
	\dur, Prand([
		Prand([1, 4], Pwhite(1, 4)),
		Prand((1..2), Pwhite(1, 9)),
		Prand([
			Pexprand(1.0, 2, Pwhite(4, 7)).round(0.25),
			Pwhite(0.5, 3, Pwhite(4, 9)).round(0.25)
		], Pwhite(1, 10))
	], inf),
	\freq, (Prand(chord, inf) + 12).midicps,
	\amp, Pwhite(0.25, 0.5) * ~ampScale,
	\atk, Pwhite(5.0, 7.0, Pwhite(1, 100), inf),
	\rel, Pwhite(5.0, 7.0, Pwhite(1, 100), inf),
	\pan, Pwhite(-1.0, 1.0)
);

Pbindef( \sin,
	\instrument, \sin,
	\dur, Pwrand([1/8, 1/4, Rest(1/8)], [5, 1, 3].normalizeSum, inf),
	\freq, Prand((chord +.x [0, 12]).midicps, inf),
	\rel, Pexprand(0.005, 2),
	\amp, Pwhite(0.25, 0.5) * ~ampScale,
	\pan, Pwhite(-0.5, 0.5)
);

Pbindef( \sin2,
	\instrument, \sin,
	\dur, Pwrand([1/8, 1/4, Rest(1/8)], [5, 1, 3].normalizeSum, inf),
	\freq, Prand((chord +.x [0, -12]).midicps, inf),
	\rel, Pexprand(0.005, 2),
	\amp, Pwhite(0.25, 0.5) * ~ampScale,
	\pan, Pwhite(-0.5, 0.5)
);

Pbindef( \playBuf,
	\instrument, \playBuf,
	\dur, Pwrand([1/8, 1/4, Rest(1/8), Rest(1/4) , Rest(1)], [5, 1, 3, 2, 4].normalizeSum, inf),
	\buf, Prand(b[\k], inf),
	\rel, Pexprand(0.2, 3),
	\amp, Pwhite(1, 2) * ~ampScale,
	\pan, Pwhite(-1.0, 1.0)
);

Pbindef( \rchoruSin,
	\instrument, \choruSin,
	\dur, Pwrand([4, 2, 1], [5, 3, 1].normalizeSum, inf),
	\freq, Prand((chord - 12).midicps, inf),
	\amp, Pwhite(0.25, 0.5) * ~ampScale,
	\pan, Pwhite(-1.0, 1.0)
);

Pbindef( \white,
	\instrument, \white,
	\dur, Pwrand([4, 3, 8, 1], [5, 3, 1, 2].normalizeSum, inf),
	\freq, Prand((chord + 12).midicps, inf),
	\amp, Pwhite(0.05, 0.1) * ~ampScale,
	\pan, Pwhite(-1.0, 1.0),
	\sus, Pexprand(0.05, 0.5)
);

Pbindef( \guitPlayBuf,
	\instrument, \playBuf,
	\dur, Pwrand([1/8, 1/4, Rest(1/8), Rest(1/4) , Rest(1)], [5, 1, 3, 2, 4].normalizeSum, inf),
	\buf, Prand(b[\g], inf),
	\rel, Pexprand(0.2, 3),
	\amp, Pwhite(1, 2) * ~ampScale,
	\pan, Pwhite(-1.0, 1.0)
);
)