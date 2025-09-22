(
s.boot;
b = Bus.audio(s, 1);

SynthDef(\muse, {|freq, dur, vol|
	var env = EnvGen.kr(Env.linen(sustainTime: dur*0.925, attackTime: 0.075*dur, releaseTime: 0.01*dur), doneAction: 2);
	Out.ar(b, LPF.ar(Pulse.ar(freq, width: 0.5, mul: vol*env), 11000));
}).send(s);

SynthDef(\museverb, {
	Out.ar(0, Pan2.ar(FreeVerb.ar(In.ar(b), 0.45, 0.5)));
}).send(s);
)

(
	var counter0=0, counter1=0, shiftreg=rrand(0, pow(2,30).asInteger), handler, interval, theme, makeanote, tempo=320, basefreq=220, finefreq=0, rest=false, vol, slider, major, mminor, hminor, acc, lastmnote, mminorlook;
	var lookup;
	var mv = Synth(\museverb, [], s);
	var note = nil;
	interval = Array.with(2,8,10,20);
	theme = Array.with(5,7,25,20);
	slider = {
		|sliderval, i|
		var choice = 0;
		(sliderval == 0).if { choice = 0 }; // off
		(sliderval == 1).if { choice = 1 }; // on
		(sliderval == 2).if { choice = counter0 & 1 }; // c1/2
		(sliderval == 3).if { choice = counter0 & 2 >> 1 }; // c1
		(sliderval == 4).if { choice = counter0 & 4 >> 2 }; // c2
		(sliderval == 5).if { choice = counter0 & 8 >> 3 }; // c4
		(sliderval == 6).if { choice = counter0 & 16 >> 4 }; // c8
		(sliderval == 7).if { choice = (counter1 / 3).asInteger % 2 }; // c3
		(sliderval == 8).if { choice = (counter1 >= 6).asInteger }; // c6
		(sliderval >= 9 && (sliderval <= 39)).if { choice = (shiftreg >> (sliderval.asInteger - 9)) & 1 };
		choice;
	};		
		
	makeanote = { |freq|
		var dur;
		"makenote".postln;
		if (t == nil, { dur = 1 }, { dur = 2/t.tempo });
		
		if ((counter0 & 1) == 1 && (note != nil), 
			{note.set(\freq, freq, \vol, vol);},
			{note = Synth(\muse, [\freq, freq, \dur, dur, \vol, vol], mv, \addBefore);}
		);
	};
	
	handler = { 
		var notes, freq, parity, mnote;
		parity = theme.sum(slider).asInteger & 1;
		("shiftreg" + (shiftreg&0x7fffffff).asHexString).postln;
		notes = interval.collect(slider);
		mnote = notes[0] + (2 * notes[1]) + (4 * notes[2]);
		freq = (basefreq.cpsmidi + lookup[mnote]);
		("A"+freq).postln;
		if ((mminorlook == 1) &&
			((mnote == 5) || (mnote == 6)) &&
			(lastmnote != nil)
		, {
			if (lastmnote > mnote, {
				freq = freq - 1;
				freq.postln;
			});
		});
		lastmnote = mnote;
		freq = freq.midicps * (1 + notes[3]);
		("B"+freq).postln;
		("R"+rest).postln;
		("N"+notes.sum).postln;
		if (rest == false || (notes.sum != 0)) {
			makeanote.value(freq * finefreq);
		};
		("counter0" + counter0).postln;
		("counter1" + counter1).postln;
		if (counter0&1 == 1, {
			counter1 = (counter1+1) % 12;
			shiftreg = shiftreg << 1 | parity;
		});
		counter0 = (counter0+1) % 32;
	};
	
	Window.allWindows.do { |w| if (w.name == "The Muse") { w.close } };
	w = Window.new("The Muse", Rect(200,200,800,710));
	c = ControlSpec.new(0, 39, step: 1);
	t = TempoClock.new;
	
	EZSlider.new(w, Rect(0,0,800,75), "Interval A", c, { |ez| interval[0] = ez.value}, initAction:true);
	EZSlider.new(w, Rect(0,75,800,75), "Interval B", c, { |ez| interval[1] = ez.value}, initAction:true);
	EZSlider.new(w, Rect(0,150,800,75), "Interval C", c, { |ez| interval[2] = ez.value}, initAction:true);
	EZSlider.new(w, Rect(0,225,800,75), "Interval D", c, { |ez| interval[3] = ez.value}, initAction:true);
	EZSlider.new(w, Rect(0,300,800,75), "Theme W", c, { |ez| theme[0] = ez.value}, initAction:true);
	EZSlider.new(w, Rect(0,375,800,75), "Theme X", c, { |ez| theme[1] = ez.value}, initAction:true);
	EZSlider.new(w, Rect(0,450,800,75), "Theme Y", c, { |ez| theme[2] = ez.value}, initAction:true);
	EZSlider.new(w, Rect(0,525,800,75), "Theme Z", c, { |ez| theme[3] = ez.value}, initAction:true);
	
	EZSlider.new(w, Rect(0,600,400,40), "Volume", action: {|ez| vol = ez.value;}, initVal: 0.75, initAction:true);
	EZSlider.new(w, Rect(400,600,400,40), "Pitch", ControlSpec(0,127, step:1),action: {|ez| basefreq = ez.value.midicps;}, initVal: 32, initAction:true);
	EZSlider.new(w, Rect(0,640,400,40), "Fine Pitch", ControlSpec(1/1.0595465, 1.0595465), action: {|ez| finefreq = ez.value}, initVal: 1, initAction: true);
	~tempobutton = EZSlider.new(w, Rect(400,640,400,40), "Tempo", ControlSpec(12, 600), action: {|ez| if (t != nil) {t.tempo = ez.value / 60}}, initVal: 160, initAction: true);
	Button.new(w,Rect(0,680,80,30)).states_([["Start"],["Stop"]]).action_({
		|button|
		if ((button.value == 0), {
			"hold".postln;
			t.stop;
			t = nil;
		}, {
			"foof".postln;
			t = TempoClock.new(~tempobutton.value/60);
			mv.free;
			mv = Synth(\museverb, [], s);
			t.sched(0, { handler.value(lookup, basefreq); 1})
		});
	});
	Button.new(w,Rect(80,680,80,30)).states_([["Step"]]).action_({|button| handler.value(lookup, basefreq);});
	Button.new(w,Rect(160,680,80,30)).states_([["Reset"]]).action_({counter0 = counter1 = shiftreg = 0;});
	CheckBox.new(w, Rect(240,680,80,30), "Rest").action = { |state| rest = state.value };
	major = CheckBox.new(w, Rect(320,680,80,30), "Major").action = {
		"majorclick".postln;
		major.value.postln;
		if (major.value, {
			"majoron".postln;
			hminor.value = 0;
			mminor.value = 0;
			lookup = [0,2,4,5,7,9,11,12];
		});
		mminorlook = false;
	};
	
	hminor = CheckBox.new(w, Rect(400,680,80,30), "Harmonic").action = {
		"hminorclick".postln;
		if (hminor.value, {
			"hminoron".postln;
			major.value = 0;
			mminor.value = 0;
			lookup = [0,2,3,5,7,8,11,12]
		});
		mminorlook = false;
	};
	
	mminor = CheckBox.new(w, Rect(480,680,80,30), "Melodic").action = {
		"mminorclick".postln;
		if (mminor.value, {
			"mminor".postln;
			hminor.value = 0;
			major.value = 0;
			lookup = [0,2,3,5,7,9,11,12]
		});
		mminorlook = true;
	};
	
	major.valueAction = true;
	~display = StaticText(w,Rect(0,800,40,710)).font_("Monaco").stringColor_(Color.gray(0,1));
	w.onClose = { t.stop };
	w.front;
)
