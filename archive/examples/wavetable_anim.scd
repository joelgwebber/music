(
//after running code, esc key to close window and abort animation

var wt0, wt1, result,
wt0view, wt1view, resultView, animateFn, wmean, numSteps, animate, wtIndex,
win, wtPosBox, wtPosView;

animateFn.stop;
numSteps = 101;
animate = true;
wtIndex = 0.0;

//weighted mean function
wmean = {
	arg coll, weights;
	coll.sum({arg n,i; n*weights[i]}) / weights.sum;
};

/*----------------------------------*/
//user can edit "wt0" and "wt1" variables
//to be any Signal of size 384
//
//code will animate interpolation
//between these two wavetables
/*----------------------------------*/

//wavetable 0: 8 lowest harmonics at equal phases and amplitudes
wt0 = Signal.sineFill(384, 1/(1..8),0!8);

//other options for wavetable 0, or DIY:
//wt0 = Env({rrand(-1.0,1.0)}!8, {rrand(0,20)}!7, {rrand(-10,10)}!7).asSignal(384);

//wavetable 1: partials 1,3,4,5 at various amplitudes and phases
wt1 = Signal.sineFill(384, [1,0,1/2,1,1/4],[0,0,pi,0,pi]);

//(or make your own DIY Signal for wt1)

//do not edit "result" (calculated from wt0 and wt1)
result = Signal.fill(384, {
	arg i;
	wmean.([wt0,wt1].flop[i],[1 - wtIndex, wtIndex]);
});

Window.closeAll;
win = Window.new("", Window.screenBounds, false, false).front;
win.view.background_(Color.gray(0.1));
win.view.keyDownAction_({
	arg view, char, mod, uni;

	//esc to abort & close window
	if(uni == 27, {animateFn.stop;win.close;})
});

StaticText(win, Rect(60,100,384,48))
.font_(Font(Font.defaultSansFace, 36))
.stringColor_(Color.gray(0.8))
.string_("wavetable 0")
.align_(\center);

StaticText(win, Rect(400,347,50,20))
.font_(Font(Font.defaultSansFace, 18))
.stringColor_(Color.gray(0.8))
.string_("time")
.align_(\center);

StaticText(win, Rect(218,170,30,20))
.font_(Font(Font.defaultSansFace, 18))
.stringColor_(Color.gray(0.8))
.string_("+1")
.align_(\center);

StaticText(win, Rect(219,554,30,20))
.font_(Font(Font.defaultSansFace, 18))
.stringColor_(Color.gray(0.8))
.string_("-1")
.align_(\center);

wt0view = UserView.new(win, Rect(60,180,384,384)).background_(Color.clear);
wt0view.clearOnRefresh_(true);
wt0view.drawFunc = {nil};
wt0view.refresh;
wt0view.drawFunc_({
	Pen.strokeColor_(Color.gray(0.2));
	Pen.width_(2);
	Pen.line(192@0, 192@384);
	Pen.line(0@192,384@192);
	Pen.stroke;
	Pen.strokeColor_(Color.gray(0.35));
	Pen.width_(5);
	Pen.moveTo(0@384);

	(wt0.size-1).do{
		arg i;
		Pen.line(
			Point(i, wt0[i].linlin(-1.02,1.02,384,0)),
			Point(i+1, wt0[i+1].linlin(-1.02,1.02,384,0))
		);
		Pen.stroke;
	};

});

StaticText(win, Rect(517,100,384,48))
.font_(Font(Font.defaultSansFace, 36))
.stringColor_(Color.gray(0.8))
.string_("result")
.align_(\center);

StaticText(win, Rect(855,347,50,20))
.font_(Font(Font.defaultSansFace, 18))
.stringColor_(Color.gray(0.8))
.string_("time")
.align_(\center);

StaticText(win, Rect(673,170,30,20))
.font_(Font(Font.defaultSansFace, 18))
.stringColor_(Color.gray(0.8))
.string_("+1")
.align_(\center);

StaticText(win, Rect(674,554,30,20))
.font_(Font(Font.defaultSansFace, 18))
.stringColor_(Color.gray(0.8))
.string_("-1")
.align_(\center);


resultView = UserView.new(win, Rect(517,180,384,384)).background_(Color.clear);
resultView.clearOnRefresh_(true);
resultView.drawFunc = {nil};
resultView.refresh;

resultView.drawFunc_({

	result = Signal.fill(384, {
		arg i;
		wmean.([wt0,wt1].flop[i],[1 - wtIndex, wtIndex]);
	});

	Pen.strokeColor_(Color.gray(0.2));
	Pen.width_(2);
	Pen.line(192@0, 192@384);
	Pen.line(0@192,384@192);
	Pen.stroke;
	Pen.strokeColor_(Color.gray(0.75));
	Pen.width_(5);
	Pen.moveTo(0@384);


	(result.size-1).do{
		arg i;
		Pen.line(
			Point(i, result[i].linlin(-1.02,1.02,384,0)),
			Point(i+1, result[i+1].linlin(-1.02,1.02,384,0))
		);
		Pen.stroke;
	};

});
resultView.refresh;

StaticText(win, Rect(974,100,384,48))
.font_(Font(Font.defaultSansFace, 36))
.stringColor_(Color.gray(0.8))
.string_("wavetable 1")
.align_(\center);

StaticText(win, Rect(1314,347,50,20))
.font_(Font(Font.defaultSansFace, 18))
.stringColor_(Color.gray(0.8))
.string_("time")
.align_(\center);

StaticText(win, Rect(1132,170,30,20))
.font_(Font(Font.defaultSansFace, 18))
.stringColor_(Color.gray(0.8))
.string_("+1")
.align_(\center);

StaticText(win, Rect(1133,554,30,20))
.font_(Font(Font.defaultSansFace, 18))
.stringColor_(Color.gray(0.8))
.string_("-1")
.align_(\center);

wt1view = UserView.new(win, Rect(974,180,384,384)).background_(Color.clear);
wt1view.clearOnRefresh_(true);
wt1view.drawFunc = {nil};
wt1view.refresh;
wt1view.drawFunc_({
	Pen.strokeColor_(Color.gray(0.2));
	Pen.width_(2);
	Pen.line(192@0, 192@384);
	Pen.line(0@192,384@192);
	Pen.stroke;
	Pen.strokeColor_(Color.gray(0.35));
	Pen.width_(5);
	Pen.moveTo(0@384);
	(wt1.size-1).do{
		arg i;
		Pen.line(
			Point(i, wt1[i].linlin(-1.02,1.02,384,0)),
			Point(i+1, wt1[i+1].linlin(-1.02,1.02,384,0))
		);
		Pen.stroke;
	};
	Pen.stroke;
});
wt1view.refresh;

StaticText(win, Rect(483,680,358,50))
.font_(Font(Font.defaultSansFace, 36))
.stringColor_(Color.new(0,0.75,1,0.6))
.string_("wavetable position:")
.align_(\center);

wtPosBox = NumberBox(win, Rect(853,685,85,40))
.font_(Font(Font.defaultSansFace, 36))
.background_(Color.gray(0.1))
.normalColor_(Color.new(0,0.75,1,0.8))
.decimals_(2)
.value_(wtIndex)
.enabled_(false);

wtPosView = UserView.new(win, Rect(60,740,1298,26)).background_(Color.clear);
wtPosView.drawFunc_({
	Pen.strokeColor_(Color.gray(0.2));
	Pen.width_(2);
	Pen.line(195@13, 1103@13);
	Pen.stroke;
	Pen.width_(5);
	Pen.strokeColor_(Color.new(0,0.75,1,0.8));
	Pen.addArc(
		Point(
			wtIndex.linlin(0,1,195,1103),
			13
		),
		10, 0, 2pi
	);
	Pen.stroke;
});

if(animate, {
	animateFn = {
		1.wait;
		Array.interpolation(numSteps,0,1).do({
			arg n;
			wtIndex = n;
			resultView.drawFunc_({

				result = Signal.fill(384, {
					arg i;
					wmean.([wt0,wt1].flop[i],[1 - wtIndex, wtIndex]);
				});

				Pen.strokeColor_(Color.gray(0.2));
				Pen.width_(2);
				Pen.line(192@0, 192@384);
				Pen.line(0@192,384@192);
				Pen.stroke;
				Pen.strokeColor_(Color.gray(0.75));
				Pen.width_(5);
				Pen.moveTo(0@384);


				(result.size-1).do{
					arg i;
					Pen.line(
						Point(i, result[i].linlin(-1.02,1.02,384,0)),
						Point(i+1, result[i+1].linlin(-1.02,1.02,384,0))
					);
					Pen.stroke;
				};

			});
			resultView.refresh;
			wtPosView.refresh;
			wtPosBox.value_(wtIndex);
			0.02.wait;
		});
	}.fork(AppClock);
});
)
