(
//after running code, esc key to close window and abort animation

~mainRoutine = {
	var input, transfer, output,
	inputVertAxis, transferHorizAxis,
	win, inputView, transferView, outputView,
	inc=(0), animate=true;

	/*----------------------------------*/
	//user can set "input" and "transfer"
	//variables to be any Signal of size 384
	//
	//animation will show the output signal
	//that results from waveshaping
	/*----------------------------------*/

	//sine wave
	input = Signal.sineFill(384,[1],[0]);

	//uncomment for other input options, or DIY
	//input = Signal.sineFill(384, reverse(sort({exprand(0.1,1)}!5)), [pi,pi,pi,0,pi/3]);
	//input = Env({rrand(-0.99,0.99)}!15,({exprand(0.1,1)}!14),({rrand(-10.0,10.0)}!14)).discretize(384);
	//input = Env([0,1,-1,0],[1,2,1],[0,0,0]).asSignal(384).cubed;

	//identity transfer function
	transfer = Env([-1,1],[1],[0]).asSignal(384);

	//uncomment for other transfer options, or DIY:
	//transfer = Env([-0.5,0.5],[1],[0]).asSignal(384);
	//transfer = Env([-0.8,0,0.8],[1,1],[8,-8]).asSignal(384);
	//transfer = Env([-0.5,-0.2,-0.9,0.9,0.2,0.5],[1,1,2,1,1],\sine).asSignal(384);

	//do not edit output variable:
	//output is calculated from input & transfer above
	output = Signal.newClear(384);
	output = output.waveFill({
		arg x, old, i;
		transfer.blendAt(input[i].linlin(-1,1,0,384));
	});

	Window.closeAll;
	win = Window.new("", Window.screenBounds, false, false).front;
	win.view.background_(Color.gray(0.1));
	win.view.keyDownAction_({
		arg view, char, mod, uni;

		//esc to abort & close window
		if(uni == 27, {~animate.stop;~mainRoutine.stop;win.close;})
	});

	StaticText(win, Rect(60,634,384,48))
	.font_(Font(Font.defaultSansFace, 36))
	.stringColor_(Color.gray(0.8))
	.string_("input signal")
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

	inputVertAxis = UserView.new(win, Rect(20,180,26,384)).background_(Color.clear);

	inputVertAxis.drawFunc_({
		Pen.width_(5);
		Pen.strokeColor_(Color.new(0,0.75,1,0.5));

		Pen.addArc(
			Point(
				13,
				input[inc].linlin(-1.02,1.02,384,0)
			),
			10, 0, 2pi
		);
		Pen.stroke;

	});

	inputView = UserView.new(win, Rect(60,180,384,384)).background_(Color.clear);
	inputView.clearOnRefresh_(true);
	inputView.drawFunc = {nil};
	inputView.refresh;
	inputView.drawFunc_({
		Pen.strokeColor_(Color.gray(0.2));
		Pen.width_(2);
		Pen.line(192@0, 192@384);
		Pen.line(0@192,384@192);
		Pen.stroke;
		Pen.strokeColor_(Color.gray(0.4));
		Pen.width_(5);
		Pen.moveTo(0@384);

		(input.size-1).do{
			arg i;
			Pen.line(
				Point(i, input[i].linlin(-1.02,1.02,384,0)),
				Point(i+1, input[i+1].linlin(-1.02,1.02,384,0))
			);
			Pen.stroke;
		};

	});

	StaticText(win, Rect(517,634,384,48))
	.font_(Font(Font.defaultSansFace, 36))
	.stringColor_(Color.gray(0.8))
	.string_("transfer function")
	.align_(\center);


	StaticText(win, Rect(870,347,50,20))
	.font_(Font(Font.defaultSansFace, 18))
	.stringColor_(Color.gray(0.8))
	.string_("+1")
	.align_(\center);

	StaticText(win, Rect(492,347,50,20))
	.font_(Font(Font.defaultSansFace, 18))
	.stringColor_(Color.gray(0.8))
	.string_("-1")
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

	transferHorizAxis = UserView.new(win, Rect(517,140,384,26)).background_(Color.clear);

	transferHorizAxis.drawFunc_({
		Pen.width_(5);
		Pen.strokeColor_(Color.new(0,0.75,1,0.5));

		Pen.addArc(
			Point(
				input[inc].linlin(-1.02,1.02,0,384),
				13
			),
			10, 0, 2pi
		);
		Pen.stroke;

	});

	transferView = UserView.new(win, Rect(517,180,384,384)).background_(Color.clear);
	transferView.clearOnRefresh_(true);
	transferView.drawFunc = {nil};
	transferView.refresh;
	transferView.drawFunc_({
		Pen.strokeColor_(Color.gray(0.2));
		Pen.width_(2);
		Pen.line(192@0, 192@384);
		Pen.line(0@192,384@192);
		Pen.stroke;
		Pen.strokeColor_(Color.gray(0.4));
		Pen.width_(5);
		Pen.moveTo(0@384);

		(transfer.size-1).do{
			arg i;
			Pen.line(
				Point(i, transfer[i].linlin(-1.02,1.02,384,0)),
				Point(i+1, transfer[i+1].linlin(-1.02,1.02,384,0))
			);
			Pen.stroke;
		};

	});
	transferView.refresh;

	StaticText(win, Rect(974,634,384,48))
	.font_(Font(Font.defaultSansFace, 36))
	.stringColor_(Color.gray(0.8))
	.string_("output signal")
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

	outputView = UserView.new(win, Rect(974,180,384,384)).background_(Color.clear);
	outputView.clearOnRefresh_(true);
	outputView.drawFunc = {nil};
	outputView.refresh;
	outputView.drawFunc_({
		Pen.strokeColor_(Color.gray(0.2));
		Pen.width_(2);
		Pen.line(192@0, 192@384);
		Pen.line(0@192,384@192);
		Pen.stroke;
		Pen.strokeColor_(Color.gray(0.4));
		Pen.width_(5);
		Pen.moveTo(0@384);
		// (input.size-1).do{
		// 	arg i;
		// 	Pen.line(
		// 		Point(i, input[i].linlin(-1.02,1.02,384,0)),
		// 		Point(i+1, input[i+1].linlin(-1.02,1.02,384,0))
		// 	);
		// 	Pen.stroke;
		// };
		Pen.stroke;
	});
	outputView.refresh;

	1.wait;

	if(animate, {

		{
			inc = -1;

			inputView.clearOnRefresh_(false);
			inputView.drawFunc_({
				Pen.strokeColor_(Color.gray(0.9));
				Pen.width_(5);
				Pen.line(
					Point(inc, input[inc].linlin(-1.02,1.02,384,0)),
					Point(inc+1, input[inc+1].linlin(-1.02,1.02,384,0))
				);
				Pen.stroke;
			});

			transferView.clearOnRefresh_(true);
			transferView.drawFunc_({
				Pen.strokeColor_(Color.gray(0.2));
				Pen.width_(2);
				Pen.line(192@0, 192@384);
				Pen.line(0@192,384@192);
				Pen.stroke;
				Pen.strokeColor_(Color.gray(0.4));
				Pen.width_(5);
				Pen.moveTo(0@384);

				(transfer.size-1).do{
					arg i;
					Pen.line(
						Point(i, transfer[i].linlin(-1.02,1.02,384,0)),
						Point(i+1, transfer[i+1].linlin(-1.02,1.02,384,0))
					);
					Pen.stroke;
				};
				Pen.strokeColor_(Color.new(0,0.75,1));
				Pen.addArc(
					Point(
						input[inc].linlin(-1.02,1.02,0,384),
						transfer[input[inc].linlin(-1.02,1.02,0,384)].linlin(-1.02,1.02,384,0)
					),
					10, 0, 2pi
				);
				Pen.stroke;
			});

			outputView.clearOnRefresh_(false);
			outputView.drawFunc_({
				Pen.strokeColor_(Color.gray(0.9));
				Pen.width_(5);
				Pen.line(
					Point(inc, output[inc].linlin(-1.02,1.02,384,0)),
					Point(inc+1, output[inc+1].linlin(-1.02,1.02,384,0))
				);
				Pen.stroke;
			});

			~animate = {
				while(
					{inc<(input.size-2)},
					{
						inputView.refresh;
						inputVertAxis.refresh;
						transferView.refresh;
						transferHorizAxis.refresh;
						outputView.refresh;
						inc = inc + 1;
						0.02.wait;}
				)
			}.fork(AppClock);
		}.fork(AppClock);
	});
}.fork(AppClock);
)
