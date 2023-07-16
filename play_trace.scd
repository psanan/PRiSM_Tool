
s.boot
s.makeWindow
s.plotTree

(
// Filter resonant frequencies derived from pressure position (slot 1)
~base_midi = 12;
~top_midi = 73;
~pressure_to_freq = {arg x; ((x+1.0)*0.5*(~top_midi - ~base_midi) + ~base_midi).floor.midicps};
~freqs_from_file = {arg n; ~pressure_to_freq.value(FileReader.readInterpret(Document.current.dir ++ "/traces/trace_" ++ n.asString.padLeft(4, "0") ++ ".txt").slice(nil,1))};

// Pan derived from x position (slot 2)
~pans_from_file = {arg n; FileReader.readInterpret(Document.current.dir ++ "/traces/trace_" ++ n.asString.padLeft(4, "0") ++ ".txt").slice(nil,2)};

// A synth inspired by Nick Collin's lecture at
// https://composerprogrammer.com/teaching/supercollider/sctutorial/12.2%20Singing%20Voice%20Synthesis.html
SynthDef(\voice,  {
	arg
	out = 0,
	freq = 440, // Hz
	formant_frequency_base = 400, // Hz
	pan = 0,
	amp = 0.5,
	attack_time = 0.01, // s
	release_time = 0.1, // s
	vibrato_depth = 0.001,
	resonance_scaling = 30
	;

	// Periodic source
	var vibrato_noise = LFNoise1.kr(1);
	var f_mod = (1.0 + SinOsc.kr(6.0 + vibrato_noise, mul: vibrato_depth));
	var sig = HPF.ar(
		LPF.ar(
			Impulse.ar(freq * f_mod), 1000
	), 100);

	// boosts
	var sig2 = BPF.ar(sig, freq: 2000, mul: 0.1, add: sig);
	var sig3 = BPF.ar(sig2, freq: 4000, mul: 0.1, add: sig2);

	// Formant filter
	var formant_frequencies = formant_frequency_base * [1.0, 1.4375, 3.625, 4.875, 6.1875];
	var formant_amps = ([-6 ,-12, -38, -28, -56]).dbamp;
	var formant_bandwidths = [40, 45, 60, 65, 70];
	var sig4 = Mix(Formlet.ar(
		sig3,
		formant_frequencies,
		attacktime: 0.001,
		decaytime: resonance_scaling * formant_bandwidths.reciprocal,
		mul: formant_amps));

	// Envelope
	var env = EnvGen.kr(Env.perc(attack_time, release_time, level: amp, curve: -2.0), doneAction: Done.freeSelf);

	OffsetOut.ar(out, Pan2.ar(sig4, pan, level: env));
}).add;

SynthDef("end_effects",{
	arg
	in = 36,
	out = 0;
	var
	sig;

	sig = In.ar(in, 2); // stereo
	sig = HPF.ar(sig, 10); // kill very low frequencies
	sig = Compander.ar(sig, sig,
		thresh: 0.7,
		slopeBelow: 1.0,
		slopeAbove: 0.01,
		clampTime: 0.002,
		relaxTime: 0.01); // limiter
	Out.ar(out, sig);
}).add;


~num_traces = 7;

// Pulse oscillator frequencies for each trace
~frequencies = 37.7 * [1.0, 2.0, 3.0, 4.0, 5.0, 7.5, 4.0, 5.0]; // Hz

// A base time step for the sequence
~step = 0.15; // s

// A bus to and synth to collect signals and apply end effects
b = Bus.audio(s, 2);
~end = Synth.new("end_effects", [\in, b]);

// Play a sequence for each trace
i = 0;
while (
	{i < ~num_traces},
	{
		Pbind(\instrument, \voice,
			  \dur, ~step * (i+1),
			  \freq, ~frequencies.at(i),
			  \formant_frequency_base, Pseq(~freqs_from_file.value(i+1), inf),
			  \pan, Pseq(~pans_from_file.value(i+1), inf),
			  \release_time, ~step*1.2,
			  \amp, 0.5,
			\out, b
		).play;
		i = i+1;
	}
);

)
