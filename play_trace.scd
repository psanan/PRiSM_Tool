
(
~here = Document.current.dir;
~data = FileReader.readInterpret(~here +/+ "traces/trace_0002.txt");
~pressures = ~data.slice(nil, 1);
~freqs = (~pressures * [150]) + [70];
)

s.boot

(
// a SynthDef copied from a demo
SynthDef(\test, { | out, freq = 440, amp = 0.1, nharms = 10, pan = 0, gate = 1 |
    //var audio = Blip.ar(freq, nharms, amp);
	var audio = MoogFF.ar(Saw.ar(freq, amp), freq*7.0, gain:3);
    var env = Linen.kr(gate, doneAction: Done.freeSelf);
    OffsetOut.ar(out, Pan2.ar(audio, pan, env) );
}).add;

Pbind(\instrument, \test, \freq, Pseq(~freqs, inf), \dur, 0.1).play;
)