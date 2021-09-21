(
~here = Document.current.dir.postln
~data = FileReader.readInterpret(~here +/+ "traaces/trace_0001.txt");
~pressures = ~data.slice(nil, 1) // https://doc.sccode.org/Guides/J-concepts-in-SC.html
~freqs = (~pressures * [300]) + [200]
)

s.boot

(
// a SynthDef
SynthDef(\test, { | out, freq = 440, amp = 0.1, nharms = 10, pan = 0, gate = 1 |
    var audio = Blip.ar(freq, nharms, amp);
    var env = Linen.kr(gate, doneAction: Done.freeSelf);
    OffsetOut.ar(out, Pan2.ar(audio, pan, env) );
}).add;


Pbind(\instrument, \test, \freq, Pseq(~freqs, inf), \dur, 0.1).play;
)