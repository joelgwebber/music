(
//Created by Eli Fieldsteel 2022 Feb 26

var shm, spectrum;

//frequency-scaling factor: closer to zero -> slow motion
var freq_scale = 0.5;

//amplitude-scaling factor: pixel radius when amplitude = 1
var amp_scale = 80;

//spectrum is provided as an array containing one or more events
//each event represents a sine wave with keys for 'freq', 'amp', and 'phs'

//uncomment for examples
/*sine (the default)*/ spectrum = [ (freq:1, amp:1, phs:0) ];
// /*harmonics 1 & 2 */ spectrum = [ (freq:1, amp:1, phs:0), (freq:2, amp:1/2, phs:0) ];
// /*harmonics 1 thru 4 */ spectrum = ((1..4).collect({ |n| (freq:n, amp:1/n, phs:0) }));
// /*sawtooth*/ spectrum = ((1..12).collect({ |n| (freq:n, amp:1/n, phs:0) }));
// /*square*/ spectrum = ((1,3..11).collect({ |n| (freq:n, amp:1/n, phs:0) }));
// /*triangle*/ spectrum = ((1,3..11).collect({ |n| (freq:n, amp:1/(n**2), phs:n.odd.asInteger*pi+(pi/2)) }));
// /*impulse (i.e. "Blip")*/ spectrum = ((1..12).collect({ |n| (freq:n, amp:1/4, phs:pi/2) }));

Window.closeAll;

shm = {
	arg input = [(freq:1, amp:1, phs:0)], freqscl=0.5, ampscl=75, datasize=200, framerate=40;
	var win, cview, wview, phs;
	var t = 0; //time/phase counter
	var wavedata = Array.newClear(datasize); //waveform y-coordinate values

	win = Window(
		"Simple Harmonic Motion Animation — (spacebar to pause/unpause)",
		Rect(100, 100, 1020, 520)
	).background_(Color.gray(0.2)).front;
	win.view.decorator_(FlowLayout(win.view.bounds, 10@10, 10@10));
	cview = UserView(win.view, 1000@500).background_(Color.gray(0.25));

	cview.drawFunc_({ |v|
		var center, newcenter, x, y;

		//dividing line between circles/waveform
		Pen.width_(2);
		Pen.strokeColor_(Color.gray(0.5));
		Pen.line(600@0, 600@520);
		Pen.stroke;

		//draw circles
		Pen.capStyle_(1);
		Pen.width_(2);
		input.do({ |sine, i|
			if (center == nil) { center = 300@250} { center = newcenter };
			x = cos(( (((t * freqscl) + (sine.phs / sine.freq ))) * sine.freq ) % 2pi) * sine.amp;
			y = sin(( (((t * freqscl) + (sine.phs / sine.freq ))) * sine.freq ) % 2pi) * sine.amp;
			newcenter = (x@y) * ampscl * Point(1,-1);
			newcenter = newcenter.translate(center);
			Pen.strokeColor_(Color.gray(i.linlin(0, input.size, 0.7, 0.5), 0.8));
			Pen.addArc(center, sine.amp * ampscl, 0, 2pi);
		});
		Pen.stroke;

		//draw radii
		center = nil;
		Pen.width_(4);
		input.do({ |sine, i|
			if (center == nil) { center = 300@250} { center = newcenter };
			x = cos(( (((t * freqscl) + (sine.phs / sine.freq ))) * sine.freq ) % 2pi) * sine.amp;
			y = sin(( (((t * freqscl) + (sine.phs / sine.freq ))) * sine.freq ) % 2pi) * sine.amp;
			newcenter = (x@y) * ampscl * Point(1,-1);
			newcenter = newcenter.translate(center);
			Pen.strokeColor_(Color(0.25, i.linlin(0, input.size-1, 0.55, 0.85), 0.95, 0.9));
			Pen.line(center, newcenter);
			Pen.stroke;
		});

		//draw horizontal line connecting radii to waveform
		Pen.width_(2);
		Pen.strokeColor_(Color.gray(1,0.3));
		Pen.line(600@(newcenter.y), newcenter);
		Pen.stroke;

		//store y-coordinate
		wavedata = wavedata.rotate(1);
		wavedata.put(0, newcenter.y);

		//draw waveform with connecting lines between adjacent wavedata values
		Pen.width_(3);
		Pen.strokeColor_(Color(1, 0.75, 0, 0.6));
		wavedata.drop(-1).do({ |y,i|
			if (y.notNil && wavedata.wrapAt(i+1).notNil)
			{Pen.line(Point(600 + (i*2), y), Point(600 + (i*2+2), wavedata.wrapAt(i+1)))};
		});
		Pen.stroke;

		//advance time
		(t = t + (2pi/framerate))%2pi;

	});

	cview.frameRate_(framerate);
	cview.animate_(true);

	//spacebar to pause
	cview.keyDownAction_({ |v, char|
		if (char == $ ) { cview.animate_(cview.animate.not) };
	});
};

shm.(spectrum, freq_scale, amp_scale); //run
)
