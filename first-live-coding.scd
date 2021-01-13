s = Server.local;
s.boot;


d = Dictionary.new;
d.add(\air ->
	PathName("/Users/carmanwong/Desktop/SC/sounds/air/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);


SynthDef.new(\sine, {
		arg freq=1000, atk=0.2, rel=0.25, amp=0.2, pan=0, out=0;
		var sig, env;
		sig = SinOsc.ar(freq);
		env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]), doneAction:2);
		sig = Pan2.ar(sig, pan, amp);
		sig = sig*env;
		Out.ar(out, sig);
	}).add;


SynthDef.new(\beginning, {
		arg mul1=0, mul2=0, mul3=0, mul4=0, mul5=0, mul6=0, mul7=0, amp=0.1,atk=0.1, rel=0.5, out;
		var env;
		env = EnvGen.kr(Env.new([0,amp,0],[atk,rel]), doneAction:2);
		Out.ar(out,
			[LFTri.ar(freq: LFPulse.ar(freq:[1,5],mul:mul1,add:0),mul:amp)*env,
				LFTri.ar(freq: LFPulse.ar(freq:[1,5],mul:mul2,add:0),mul:amp)*env,
				LFTri.ar(freq: LFPulse.ar(freq:[1,5],mul:mul3,add:0),mul:amp)*env,
				LFTri.ar(freq: LFPulse.ar(freq:[1,5],mul:mul4,add:0),mul:amp)*env,
				LFTri.ar(freq: LFPulse.ar(freq:[1,5],mul:mul5,add:0),mul:amp)*env,
				LFTri.ar(freq: LFPulse.ar(freq:[1,5],mul:mul6,add:0),mul:amp)*env,
				LFTri.ar(freq: LFPulse.ar(freq:[1,5],mul:mul7,add:0),mul:amp)*env
			]
		);
	}).add;


(
	Pdef(
	\intro,
	Pbind(
	\instrument,  \sine,
	\harmonic, 2,
	\atk, Pwhite(0.1, 4),
	\rel, Pwhite(5),
//	\amp, Pexprand(0.02, 0.1),
	\amp, 0.04,
	\pan, Pwhite(-1,1),
	\dur, Pseq([4], inf),
	\strech, 16,
	\midinote, 36,
	);
	).quant_(1);
)


(
Pdef(
	\beginning_sweet,
	Pbind(
	\instrument,  \beginning,
	\harmonic, 1,
	\atk, Pwhite(0.1, 4),
	\dur, Pseq([1/2], inf),
	\strech, 1.875,
	\mul1, 97.midicps, \mul2, 93.midicps,
//	\amp, Pexprand(0.02, 0.1),
	\amp, 0.04,
	);
	).quant_(1);
)


SynthDef(\playBufWPitchShift, {
		arg out=0, bufnum, amp=0.5;
		var sig;
		sig = PlayBuf.ar(1, bufnum, MouseX.kr(0,4), loop:1);
		sig = PitchShift.ar(
			sig,
			0.1,
			MouseY.kr(0,2),
			0,
			0.004
		);
		Out.ar(out*amp, sig!2);
}).add;


a = Pbindf(Pdef(\intro), \midinote, Pseq([73,69,73,69,73,69,73,69], inf)).play(quant:1);
a.stop;
b = Pbindf(Pdef(\beginning_sweet), \mul1, 97.midicps, \mul2, 93.midicps).play(quant:1);
b.stop;
c = Pbindf(Pdef(\intro), \midinote, Pseq([78,83,78,83,78,83], inf)).play(quant:1);
c.stop;
d = Pbindf(Pdef(\beginning_sweet), \mul1, 102.midicps, \mul2, 107.midicps, \mul3, 110.midicps).play(quant:1);
d.stop;


//insert the captain annoucement while flying in the sky

n = Synth.new(\playBufWPitchShift, [\bufnum, ~captain_announcement.bufnum, \amp]);
n.stop;
