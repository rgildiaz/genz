// patterns

(
~r1 = Pbindef( \r1,
	\instrument, \playBuf,
	\dur, 1/8,
	\amp, Pwhite(0.5, 1, inf),
	\buf, Prand(b.choose, inf),
	\pan, Pwhite(-1.0, 1.0, inf)
);
)