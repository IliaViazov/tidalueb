(
var numChannels = ~dirt.numChannels

SynthDef("dirt_out" ++ numChannels, { |out, to, sustain = 1, fadeInTime = 0.001, fadeTime = 0.001, through = 0, amp = 1|

		var signal = In.ar(out, numChannels);
		var env = EnvGen.ar(Env([0, 1, 1, 0], [fadeInTime, sustain, fadeTime], \sin));

		Out.ar(to, signal * env * amp);
		ReplaceOut.ar(out, signal * through);

	}, [\ir, \ir, \ir, \ir, \ir, \ir, \kr]).add;  // amp can be modulated

)
