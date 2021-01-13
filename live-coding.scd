(
s = Server.local;
s.boot;
s.options.sampleRate_(44100);
s.options.memSize_(2.pow(20));
s.newBusAllocators;
ServerBoot.removeAll;
ServerTree.removeAll;
ServerQuit.removeAll;

~out = 0;

d = Dictionary.new;
d.add(\air ->
	PathName("/Users/carmanwong/Desktop/SC/sounds/air/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);

d.add(\airport ->
	PathName("/Users/carmanwong/Desktop/SC/sounds/airport/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);

d.add(\german ->
	PathName("/Users/carmanwong/Desktop/SC/sounds/german/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);

d.add(\hk ->
	PathName("/Users/carmanwong/Desktop/SC/sounds/hk/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);

d.add(\phone ->
	PathName("/Users/carmanwong/Desktop/SC/sounds/phone/").entries.collect({
		arg sf;
		Buffer.read(s, sf.fullPath);
	});
);

~makeBusses = {
	~bus = Dictionary.new;
};

~cleanup = {
	s.newBusAllocators;
	ServerBoot.removeAll;
	ServerTree.removeAll;
	ServerQuit.removeAll;
};

~makeNodes = {
	s.bind({
		~mainGrp = Group.new;
		~reverbGrp = Group.after(~mainGrp);
	});
};

ServerBoot.add(~makeBuffers);
ServerBoot.add(~makeBusses);
ServerQuit.add(~cleanup);



	SynthDef.new(\sine, {
		arg freq=1000, atk=0.2, rel=0.25, amp=0.2, pan=0, out=0;
		var sig, env;
		sig = SinOsc.ar(freq);
		env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]), doneAction:2);
		sig = Pan2.ar(sig, pan, amp);
		sig = sig*env;
		Out.ar(out, sig);
	}).add;

	SynthDef.new(\source2, {
		arg freq=440, atk=0.005, rel=0.3, amp=0.5, pan=0, out=0;
		var sig, env;
		sig = SinOsc.ar(freq);
		env = EnvGen.kr(Env.new([0,1,0],[atk,rel],[1,-1]), doneAction:2);
		sig = Pan2.ar(sig, pan, amp);
		sig = sig*env;
		Out.ar(out, sig);
	}).add;

	SynthDef.new(\playbuf, {
		arg atk=0.2, rel=0.25, amp=0.2, t_trig=1, pan=0, out=0, buf, freq=1;
		var sig;
		sig = PlayBuf.ar(2, buf, BufRateScale.kr(buf)*(freq*20.midiratio), t_trig);
		sig = Pan2.ar(sig, pan, amp);
		Out.ar(out, sig);
	}).add;

	SynthDef.new(\mysterious_wave, {
			var trig,out,delay;
			trig=Impulse.kr(15);
			out=Blip.ar(
				TRand.kr(10,15,trig).midicps,
				TRand.kr(90,100,trig),
				max(0,TRand.kr(-0.5,0.4,trig))
			);
			out=Pan2.ar(out,TRand.kr(-1.0,1.0,trig));
			out=out*EnvGen.kr(Env.perc(0,1),trig);
			out=Mix.ar({out}.dup(6))*0.2;
			delay=CombL.ar(out,2.0,4/6,6);

		//			Out.ar(out, out+delay);

			Out.ar(out, out);
	}).add;

SynthDef.new(\horro_white_noise, {
			Out.ar(0, Mix.ar(
				Array.fill(2,   //no.oscillators
					{arg c;
						Pan2.ar(SinOsc.ar(
						LFSaw.ar((c*10+1)/3,mul:10,add:(MouseX.kr(2,1000,1)).round(100))  //add greater than mul
						),LFNoise0.kr(10000))  //pan speed
					}
				),
			)*0.1);
	}).add;


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


Pdef(
	\canon_cloud_soft,
	Pbind(
			\instrument, \sine,
			\harmonic, 2,
			\atk, Pwhite(0.2, 0.5),
			\rel, Pwhite(1.0, 2.0),
			\amp, Pexprand(0.01, 0.2),
			\pan, Pwhite(-0.8,0.8),
	\dur, Pseq([1/2], inf),
			\midinote, Pseq([36,43,48,52,31,38,43,47,33,40,45,48,28,40,43,47,29,41,45,48,[24,36],40,43,48,29,38,45,48,31,38,43,47], inf),
	);
).quant_(1);

Pdef(
	\canon_cloud_harmonic2,
	Pbind(
	\instrument,  \sine,
	\harmonic, 2,
	\atk, Pwhite(0.1, 0.2),
	\rel, Pwhite(0.1, 0.2),
	\amp, Pexprand(1, 2),
	\pan, Pwhite(-1,1),
		\dur, Pseq([1/2], inf),
	\strech, 16,
		\midinote, Pseq([36,43,48,52,31,38,43,47,33,40,45,48,28,40,43,47,29,41,45,48,[24,36],40,43,48,29,38,45,48,31,38,43,47], inf),
		);
).quant_(1);

	Pdef(
	\canon_cloud_harmonic3,
	Pbind(
	\instrument, \sine,
	\harmonic, 6,
	\atk, Pwhite(0.1, 0.2),
	\rel, Pwhite(0.1, 0.2),
	\amp, Pexprand(1, 2),
	\pan, Pwhite(-1,1),
	\dur, Pseq([1/4], inf),
	\strech, 16,
		\midinote, Pseq([36,43,48,52,31,38,43,47,33,40,45,48,28,40,43,47,29,41,45,48,[24,36],40,43,48,29,38,45,48,31,38,43,47], inf),
		);
).quant_(1);


Pdef(
	\canon_base2,
	Pbind(
	\instrument, \sine,
	\harmonic, 2,
	\atk, Pwhite(0.1, 0.5),
	\rel, Pwhite(0.1, 0.5),
	\amp, Pexprand(0.5, 1),
	\pan, Pwhite(-0.8,0.8),
	\dur, Pseq([1/4], inf),
	\strech, 16,
		\midinote, Pseq([36,43,48,52,31,38,43,47,33,40,45,48,28,40,43,47,29,41,45,48,[24,36],40,43,48,29,38,45,48,31,38,43,47], inf),
		);
).quant_(1);


Pdef(
	\canon_beginning_old,
	Pbind(
	\instrument, \sine,
	\harmonic, Pexprand(1),
	\atk, Pwhite(0.5, 1),
	\rel, Pwhite(0.5, 1),
	\amp, Pexprand(1, 2),
	\pan, Pwhite(-0.8,0.8),
	\dur, Pseq([1/4*4], inf),
	\strech, 16,
		\midinote, Pseq([76,71,72,67,[65,69],[64,72],[65,69],[67,71]], inf),
		);
).quant_(1);

Pdef(
	\canon_beginning_new,
	Pbind(
	\instrument, \sine,
	\atk, Pwhite(0.1, 1),
	\rel, Pwhite(0.1, 1),
	\amp, Pexprand(0.5, 1),
	\pan, Pwhite(-0.8,0.8),
	\dur, Pseq([1/4*4], inf),
	\strech, 16,
		\midinote, Pseq([72,67,69,64,65,60,65,67,76,74,72,71,69,67,69,71,72,71,69,67,65,64,65,62], inf),
		);
).quant_(1);

Pdef(
	\canon_base_wait_to_use,
	Pbind(
	\instrument, \sine,
	\harmonic, 2,
	\atk, Pwhite(0.1, 0.5),
	\rel, Pwhite(0.1, 0.5),
	\amp, Pexprand(0.5, 1),
	\pan, Pwhite(-0.8,0.8),
	\dur, Pseq([1/4], inf),
	\strech, 16,
		\midinote, Pseq([36, 43, 48,0,31,38,43,0,33,40,45,0,28,35,40,0], inf),
		);
).quant_(1);


Pdef(
	\main_melody_01,
	Pbind(
	\instrument, \sine,
	\harmonic, Pexprand(1),
	\atk, Pwhite(0.1, 0.5),
	\rel, Pwhite(0.1, 0.5),
	\amp, Pexprand(0.5, 1),
	\pan, Pwhite(-0.8,0.8),
	\dur, Pseq([1/4], inf),
	\strech, 16,
		\midinote, Pseq([72,69,72,60,59,67,62,64,60,72,71,69,71,64,67,69,77,76,74,77,76,74,72,71,69,67,65,64,62,65,65,62], inf),
		);
).quant_(1);


Pdef(
	\main_melody_02,
	Pbind(
	\instrument, \sine,
	\harmonic, Pexprand(1),
	\atk, Pwhite(0.1, 0.5),
	\rel, Pwhite(0.1, 0.5),
	\amp, Pexprand(0.5, 1),
	\pan, Pwhite(-0.8,0.8),
	\dur, Pseq([1/4], inf),
	\strech, 16,
		\midinote, Pseq([60,62,64,65,67,62,67,65,64,69,67,65,67,65,64,62,60,69,69,71,72,71,69,67,65,64,62,69,67,69,67,65,64,76,74,0,0,0,72,76,0,69,0,67,0,69,0,71,72,72,71,0,0,69,72,0,72,0,0,72,72,77,74,79], inf),
		);
).quant_(1);

Pdef(
	\main_melody_main_main,
	Pbind(
	\instrument, \sine,
	\harmonic, Pexprand(1),
	\atk, Pwhite(0.1, 0.5),
	\rel, Pwhite(0.1, 0.5),
	\amp, Pexprand(0.5, 1),
	\pan, Pwhite(-0.8,0.8),
	\dur, Pseq([1/4], inf),
	\strech, 16,
		\midinote, Pseq([79,0,76,77,79,0,76,77,79,67,69,71,72,74,76,77,76,0,72,74,76,0,64,65,67,69,67,65,67,64,65,67,65,0,69,67,65,0,64,62,64,62,60,62,64,65,67,69,65,0,69,67,69,0,71,72,67,69,71,72,74,76,77,79], inf),
		);
).quant_(1);


Pdef(
	\main_melody_after_main_main,
	Pbind(
	\instrument, \sine,
	\harmonic, Pexprand(1),
	\atk, Pwhite(0.1, 0.5),
	\rel, Pwhite(0.1, 0.5),
	\amp, Pexprand(0.5, 1),
	\pan, Pwhite(-0.8,0.8),
	\dur, Pseq([1/4], inf),
	\strech, 16,
		\midinote, Pseq([76,0,72,74,76,0,74,72,74,67,69,74,76,74,72,71,72,0,69,71,72,0,60,62,64,65,64,62,64,72,71,72,69,0,72,71,69,0,67,65,67,65,64,65,67,69,71,72,69,0,72,71,72,0,71,69,71,72,74,72,71,72,69,71], inf),
		);
).quant_(1);

Pdef(
	\canon_end,
	Pbind(
	\instrument, \sine,
	\atk, Pwhite(0.1, 1),
	\rel, Pwhite(0.1, 1),
	\amp, Pexprand(0.01, 0.2),
	\pan, Pwhite(-0.8,0.8),
	\dur, Pseq([1/4*2], inf),
	\strech, 16,
		\midinote, Pseq([88,88,88,88,86,86,86,86,84,84,84,84,83,83,83,83,81,81,81,81,79,79,79,79,81,81,81,81,83,83,83,83]*0.85, inf),
		);
).quant_(1);


~inflight = d[\air][3];
~captain_announcement = d[\air][0];
~chimes = d[\air][2];
~skype = d[\phone][2];
~iphone_pop = d[\phone][1];
~hkmtr = d[\hk][1];
~airportwalking = d[\airport][1];
~german = d[\german][0];


    "done".postln;
)






//////////////////////////////////////////Beginning Bell Sound/////////////////////////////////////
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

a = Pbindf(Pdef(\intro), \midinote, Pseq([73,69,73,69,73,69,73,69], inf)).play(quant:1);

a.stop;
b = Pbindf(Pdef(\beginning_sweet), \mul1, 97.midicps, \mul2, 93.midicps).play(quant:1);
b.stop;



c = Pbindf(Pdef(\intro), \midinote, Pseq([78,83,78,83,78,83], inf)).play(quant:1);
c.stop;

d = Pbindf(Pdef(\beginning_sweet), \mul1, 102.midicps, \mul2, 107.midicps, \mul3, 110.midicps).play(quant:1);
d.stop;

e = Pbindf(Pdef(\intro), \midinote, Pseq([90,98], inf)).play(quant:1);
e.stop;
f = Pbindf(Pdef(\beginning_sweet), \mul1, 114.midicps, \mul2, 110.midicps, \mul3, 102.midicps).play(quant:1);
f.stop;
g = Pbindf(Pdef(\intro), \midinote, Pseq([81], inf)).play(quant:1);
g.stop;
h = Pbindf(Pdef(\beginning_sweet), \mul1, 114.midicps, \mul2, 110.midicps, \mul3, 102.midicps, \mul3, 105.midicps).play(quant:1);
h.stop;
i = Pbindf(Pdef(\beginning_sweet), \mul1, 109.midicps, \mul2, 107.midicps, \mul3, 97.midicps).play(quant:1);
i.stop;
j = Pbindf(Pdef(\beginning_sweet), \mul1, 93.midicps).play(quant:1);
j.stop;


k = Pbindf(Pdef(\intro), \midinote, Pseq([74], inf)).play(quant:1);
k.stop;
l = Pbindf(Pdef(\beginning_sweet), \mul1, 98.midicps).play(quant:1);
l.stop;
m = Pbindf(Pdef(\beginning_sweet), \mul1, 88.midicps).play(quant:1);
m.stop;
//////////////////////////////////////////////Flight Sound//////////////////////////////////////////
~skype.play;
~iphone_pop.play;
~hkmtr.play;
~inflight.play;
~captain_announcement.play;
~chimes.play;
~airportwalking.play;
~german.play;
n = Synth.new(\playBufWPitchShift, [\bufnum, ~captain_announcement.bufnum, \amp]);
n.free;
o = Synth.new(\playBufWPitchShift, [\bufnum, ~airportwalking.bufnum]);
o.free;
p = Synth.new(\playBufWPitchShift, [\bufnum, ~skype.bufnum]);
p.free;
q = Synth.new(\playBufWPitchShift, [\bufnum, ~chimes.bufnum]);
q.free;
r = Synth.new(\playBufWPitchShift, [\bufnum, ~airportwalking.bufnum]);
r.free;
s = Synth.new(\playBufWPitchShift, [\bufnum, ~hkmtr.bufnum]);
s.free;
t = Synth.new(\playBufWPitchShift, [\bufnum, ~german.bufnum]);
t.free;
//very slowly speaking german
u = Synth.new(\playbuf, [\buf, ~german, \freq, 1/2]);
u.stop;
//////////////////////////////////////////Add the Wired Sound/////////////////////////////////////
//Can Subsitute the sound source for others
Synth.new(\horro_white_noise);
Synth.new(\mysterious_wave, [\rate, -7.midiratio] );
Synth.new(\mysterious_wave, [\rate, -1.midiratio] );
Synth.new(\mysterious_wave, [\rate, 20.midiratio] );
//electronic
{Blip.ar(25, LFNoise0.kr([5,10],12,15), 0.3)}.play

//////////////////////////////////////////CANON/////////////////////////////////////

v = Pbindf(Pdef(\canon_cloud_soft), \dur, 1/2).play(quant:1);
v.stop;
w = Pbindf(Pdef(\canon_cloud_harmonic2), \dur, 1/2, \amp, Pexprand(0.01, 0.2)).play(quant:1);
w.stop;
x = Pbindf(Pdef(\canon_cloud_harmonic2), \dur, 1/2, \harmonic, 4, \amp, Pexprand(0.01, 0.2)).play(quant:1);
x.stop;
y = Pbindf(Pdef(\canon_cloud_harmonic3), \dur, 1/2, \harmonic, 6, \amp, Pexprand(0.01, 0.2)).play(quant:1);
y.stop;
//Drop
z = Pbindf(Pdef(\canon_beginning_old), \dur, 2, \amp, 0.5).play(quant:1);
z.stop;
~aa = Pbindf(Pdef(\canon_beginning_old), \dur, 2, \amp, 0.5, \harmonic, 6).play(quant:1);
~aa.stop;
//very low sound
~bb = Pbindf(Pdef(\canon_cloud_harmonic2), \amp, Pexprand(0.1, 0.2), \harmonic, 1).play(quant:1);
~bb.stop;
//Very fast
~cc = Pbindf(Pdef(\canon_cloud), \harmonic, 2, \instrument, \source2, \dur, Pwhite(1/3, 1/4)).play(quant:1);
~cc.stop;
//Drop New
~dd = Pbindf(Pdef(\canon_beginning_new), \dur, 2).play(quant:1);
~dd.stop;
~ee = Pbindf(Pdef(\main_melody_01), \dur, 1/2).play(quant:1);
~ee.stop;
~ff = Pbindf(Pdef(\main_melody_02), \dur, 1/2).play(quant:1);
~ff.stop;
~gg = Pbindf(Pdef(\main_melody_main_main), \dur, 1/4).play(quant:1);
~gg.stop;
~hh = Pbindf(Pdef(\main_melody_after_main_main), \dur, 1/2).play(quant:1);
~hh.stop;
~ii = Pbindf(Pdef(\canon_end), \dur, 1/4, \amp, 0.2, \harmonic, 1).play(quant:1);
~ii.stop;





s.plotTree;
s.meter;






