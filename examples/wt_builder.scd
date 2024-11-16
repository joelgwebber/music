(
// ======================================
//
// Wavetable Builder with GUI
//
// SuperCollider app for building and saving single-cycle waveforms and wavetables
// Uses either a mix of sine waves or an envelope of points connected by curves
//
// To run, select all code and evaluate it (press Shift and Enter)
//
// Created by Paul Miller (palemoonrising.co.uk)
//
// GNU GPL 3 license as per SuperCollider
//
// ======================================
//
// init
var d, s;
var guiData;
d = ();   // data event
guiData = ();

// ============  Settings (initial values):  ============

d.audioOutBus = 0;
d.outLevel = 0.2;  // initial level

// d.alwaysOnTop = true;  // keeps the window in front
d.alwaysOnTop = false;

d.envMode = false;  // Sine Waves - initial mode
// d.envMode = true;  // Envelope

// buffer length in samples
d.arrBufLengthPresets = [   // must be power of 2
	["128",  128],
	["512",  512],
	["1024",  1024],
	["2048",  2048],
	["4096", 4096],
	["8192", 8192],
];
d.defaultBufLength = 2048;  // initial val
// d.defaultBufLength = 4096;
// d.defaultBufLength = 1024;

d.addBufLengthToFilename = true;  // e.g. myWavetable_2048.wav
// d.addBufLengthToFilename = false;  //  e.g. myWavetable.wav

// save file formats
d.arrSaveFormats = [  // name, headerFormat, sampleFormat
	["Wave, 16-bit Int",  "wav", "int16"],
	["Wave, 24-bit Int",  "wav", "int24"],
	["Wave, 32-bit Int",  "wav", "int32"],
	["Wave, Float", "wav", "float"],
	["Aiff, 16-bit Int",  "aiff", "int16"],
	["Aiff, 24-bit Int",  "aiff", "int24"],
	["Aiff, 32-bit Int",  "aiff", "int32"],
	["Aiff, Float", "aiff", "float"],
];
d.defaultSaveFormatIndex = 3;  // initial val

d.numSines = 16;   // initial val
// d.numSines = 24;
// d.numSines = 32;

d.maxSines = 32;  // must be >= d.numSines
// d.maxSines = 48;
// d.maxSines = 64;

d.minSineFreq = 0.1;  // must be between 0-1
// d.minSineFreq = 1;

d.maxSineFreq = 64;  // must be >= d.maxSines
// d.maxSineFreq = 32;
// d.maxSineFreq = 48;
// d.maxSineFreq = 128;

d.pulsing = true;   // synth with changing level
// d.pulsing = false;  // synth with fixed level

// frequency of note played
d.playFreq = 220;  // must be between d.minPlayFreq and d.maxPlayFreq)
d.minPlayFreq = 20;
d.maxPlayFreq = 4000;

d.windowWidth = 1000;  // or wider for >16 sines
// d.windowWidth = 1200;

d.windowHeight = 660;
// d.windowHeight = 900;

d.useMultiSlider = true;   // use multiSlider for sines
// d.useMultiSlider = false;  // use separate sliders

// colours
d.colWindow = Color(0.72, 0.77, 0.78);  // grey-green
d.colButton = Color(0.21, 0.48, 0.73);  // blue
d.colLabel = Color(0.97, 0.99, 1);  // pale blue
d.colLabelString = Color(0.03, 0.28, 0.43);  // dark blue
d.colHighlight = Color(1, 0.98, 0.67);  // pale yellow
d.colPlayActive = Color(0.47, 0.8, 0.17);  // bright green
d.colSemiGrey = Color.grey(0.85);
d.moreColors = true;  // or false
if (d.moreColors.not, {
	d.colPlay = d.colButton;
	d.colStop = d.colButton;
	d.colSave = d.colButton;
	d.colDeleteAll = d.colButton;
	d.colHelp = d.colButton;
}, {
	d.colPlay = Color(0.26, 0.54, 0.26);  // dark green
	d.colStop = Color(0.72, 0.34, 0.34);  // red
	d.colSave = Color(0.5, 0.37, 0.62);  // purple
	d.colDeleteAll = Color(0.47, 0.47, 0.54);  // grey-blue
	d.colHelp = Color(0.8, 0.39, 0);  // orange
});

// ============  End of Settings  ============

// catch errors & init
d.maxSines = d.maxSines.max(d.numSines);
d.minSineFreq = d.minSineFreq.clip(0, 1);
d.maxSineFreq = d.maxSineFreq.max(d.maxSines);
d.sineFreqSpec = ControlSpec(d.minSineFreq, d.maxSineFreq, 'lin');
d.outFreqSpec = ControlSpec(d.minPlayFreq, d.maxPlayFreq, 'exp');
d.bufLength = d.defaultBufLength;
d.saveFormatIndex = d.defaultSaveFormatIndex;
d.tablePos = 0;
d.tableCount = 0;
d.envInfoString = "Envelope";
// clipboards
d.clipboards = ();
d.clipboardIndex = 0;
// env points
d.minPoints = 3;
d.maxPoints = 16;
d.lastPointEqualsFirst = true;
d.hidePoints = false;
d.smoothType = 0;
d.arrCurveTypeOptions = [
	["Sine", \sine],
	["Curve", \curve],
	["Linear", \linear],
	["Step", \step],
	["Hold", \hold],
	["Exponential", \exp],
	["Welch", \welch],
];
d.curveSpec = ControlSpec(-20, 20, step: 0.01);
// presets
d.presetIndex = 0;
d.presets = [  // all presets use Mode: Sines
	["- Select a preset to load -", {}],
	["Sine wave (default)", {
		d.arrFreqs = d.maxSines.collect({arg i; i + 1});
		d.arrLevels = [1] ++ (0 ! (d.maxSines - 1));
		d.arrPhases = 0 ! d.maxSines;
	}],
	["Sawtooth wave using Sines", {
		d.arrFreqs = d.maxSines.collect({arg i; i + 1});
		d.arrLevels = d.maxSines.collect({arg i; (i + 1).reciprocal});
		d.arrPhases = 0 ! d.maxSines;
	}],
	["Square wave using Sines", {
		d.arrFreqs = d.maxSines.collect({arg i; i + 1});
		d.arrLevels = d.maxSines.collect({arg i;
			i.even.binaryValue * (i + 1).reciprocal});
		d.arrPhases = 0 ! d.maxSines;
	}],
	["Triangle wave using Sines", {
		d.arrFreqs = d.maxSines.collect({arg i; i + 1});
		d.arrLevels = d.maxSines.collect({arg i;
			i.even.binaryValue * (i + 1).reciprocal.squared});
		d.arrPhases = d.maxSines.collect({arg i;
			0.5 * ((i % 4) == 2).binaryValue;});
	}],
	["Impulse wave using Sines", {
		d.arrFreqs = d.maxSines.collect({arg i; i + 1});
		d.arrLevels = 1 ! d.maxSines;
		d.arrPhases = 0 ! d.maxSines;
	}],
];

// ============ create all functions ============

d.loadPreset = {
	d.envMode = false;  // all presets use Mode: Sines
	d.presets[d.presetIndex][1].value;
	d.updateBufGui;
};
d.setDefaultFormat = {
	d.bufLength = d.defaultBufLength;
	d.saveFormatIndex = d.defaultSaveFormatIndex;
	d.allocUpdateBuffers;
	d.deferMakeGui;
};
d.setDefaultSineArrays = {
	d.arrFreqs = d.maxSines.collect({arg i; i + 1});
	d.arrLevels = [1] ++ (0 ! (d.maxSines - 1));
	d.arrPhases = 0 ! d.maxSines;
};
d.setDefaultPoints = {
	d.arrPoints = [Point(0, 0), Point(0.5, 1), Point(1, 0), ];
	d.arrCurveTypes = 0 ! (d.arrPoints.size - 1);  // default type = Sine
	d.arrCurveVals = 0 ! (d.arrPoints.size - 1);
};
d.setLastPointToFirst = {
	d.arrPoints[d.arrPoints.size - 1].y = d.arrPoints[0].y;
};
// buffers
d.allocateBuffers = {
	if (d.wavetableBuf.notNil, {d.wavetableBuf.free});
	if (d.multiWTBufs.notNil, {16.do({arg i; d.multiWTBufs[i].free});});
	if (d.signalBuf.notNil, {d.signalBuf.free});
	d.wavetableBuf = Buffer.alloc(s, d.bufLength * 2, 1);
	d.multiWTBufs = Buffer.allocConsecutive(16, s, d.bufLength * 2, 1);
	d.signalBuf = Buffer.alloc(s, d.bufLength, 1);
};
d.updateBuffers = {
	var points, envSize, envSignal, envWavetable, total, holdArr, width;
	forkIfNeeded {
		s.sync;
		if (d.envMode, {
			if (d.lastPointEqualsFirst, {
				envSize = d.bufLength + 1; // last sample is trimmed
			}, {
				envSize = d.bufLength;
			});
			points = d.arrPoints;
			envSignal = Env(
				points.collect({arg item; item.y}) + 0.001,
				points.collect({arg item; item.x}).differentiate.keep(1 - points.size),
				d.getArrPointCurves,
				offset: -0.001;
			).asSignal(envSize);
			envSignal = envSignal.keep(d.bufLength.asInteger); // trim to buf length
			// smoothing
			if (d.smoothType > 0, {
				width = d.smoothType * 3;
				holdArr = envSignal.as(Array);
				holdArr = holdArr.collect({arg item, i;
					holdArr.wrapAt(i + (width.neg..width)).mean;
				});
				envSignal = holdArr.as(Signal);
			});
			envSignal.scale(2); // scale and offset to range -1/1
			envSignal.offset(-1);
			envSignal.clip(-1, 1);
			envWavetable = envSignal.asWavetable;
			// d.signalBuf.loadCollection(envSignal);
			d.signalBuf.sendCollection(envSignal);
			// d.wavetableBuf.loadCollection(envWavetable);
			d.wavetableBuf.sendCollection(envWavetable);
			d.currentWaveformData = envSignal.as(FloatArray);
		},{
			total = d.numSines;
			d.wavetableBuf.sine3(d.arrFreqs.keep(total),
				d.arrLevels.keep(total),
				d.arrPhases.keep(total) * 2pi,  // scale phase
				asWavetable: true);
			d.signalBuf.sine3(d.arrFreqs.keep(total),
				d.arrLevels.keep(total),
				d.arrPhases.keep(total) * 2pi,
				asWavetable: false);
			s.sync;
			// d.signalBuf.loadToFloatArray(action: {arg array;
			// 	d.currentWaveformData = array;
			// });
			d.signalBuf.getToFloatArray(action: {arg array;
				d.currentWaveformData = array;
			});
		});
	}; // end of forkIfNeeded
};
d.updateMultiWTBufs = {
	var outArray, outSoundFile, waveformArr, wavetable, storeInd;
	forkIfNeeded {
		s.sync;
		16.do({arg i;    // zero all buffers first
			d.multiWTBufs[i].zero;
		});
		s.sync;
		storeInd = 0;
		16.do({arg i;
			if (d.clipboards[i].notNil, {
				waveformArr = d.clipboards[i].waveformData;
				if (waveformArr.size != d.bufLength, {
					waveformArr = waveformArr.resamp1(d.bufLength);
				});
				wavetable = waveformArr.as(Signal).asWavetable;
				// d.multiWTBufs[storeInd].loadCollection(wavetable);
				d.multiWTBufs[storeInd].sendCollection(wavetable);
				storeInd = storeInd + 1;
			});
		});
		s.sync;
		if (d.multiSynthNode.notNil, {
			if (d.tableCount > 1, {
				d.rebuildSynth;
			}, {
				d.stopSynth;
			});
		});
	}; // end of forkIfNeeded
};
d.allocUpdateBuffers = {
	forkIfNeeded {
		s.sync;
		d.allocateBuffers;
		s.sync;
		d.updateBuffers;
		d.updateMultiWTBufs;
	};
};
d.updateBufGui = {
	forkIfNeeded {
		d.updateBuffers;
		d.deferMakeGui;
	};
};
d.updatePlayButtons = {
	{
		if (guiData.playWaveformBtn.notNil and: {guiData.playWaveformBtn.notClosed}, {
			if (d.synthNode.notNil, {
				guiData.playWaveformBtn.background_(d.colPlayActive);
			}, {
				guiData.playWaveformBtn.background_(d.colPlay);
			});
		});
		if (guiData.playWavetableBtn.notNil and: {guiData.playWavetableBtn.notClosed}, {
				if (d.multiSynthNode.notNil, {
				guiData.playWavetableBtn.background_(d.colPlayActive);
			}, {
				guiData.playWavetableBtn.background_(d.colPlay);
			});
		});
	}.defer;
};
// clipboards
d.storeClip = {
	var clip = ();
	clip.envMode = d.envMode.copy;
	clip.waveformData = d.currentWaveformData;
	if (d.envMode, {
		clip.smoothType = d.smoothType.copy;
		clip.arrPoints = d.arrPoints.deepCopy;
		clip.arrCurveTypes = d.arrCurveTypes.deepCopy;
		clip.arrCurveVals = d.arrCurveVals.deepCopy;
	}, {
		clip.numSines = d.numSines.copy;
		clip.arrFreqs = d.arrFreqs.deepCopy;
		clip.arrLevels = d.arrLevels.deepCopy;
		clip.arrPhases = d.arrPhases.deepCopy;
	});
	d.clipboards[d.clipboardIndex] = clip;
	d.tableCount = (d.tableCount + 1).min(16);
	d.updateMultiWTBufs;
	d.deferMakeGui;
};
d.loadClip = {
	var clip = d.clipboards[d.clipboardIndex];
	if (clip.notNil, {
		d.envMode = clip.envMode;
		if (d.envMode, {
			d.smoothType = clip.smoothType.copy;
			d.arrPoints = clip.arrPoints.deepCopy;
			d.arrCurveTypes = clip.arrCurveTypes.deepCopy;
			d.arrCurveVals = clip.arrCurveVals.deepCopy;
		}, {
			d.numSines = clip.numSines.copy;
			d.arrFreqs = clip.arrFreqs.deepCopy;
			d.arrLevels = clip.arrLevels.deepCopy;
			d.arrPhases = clip.arrPhases.deepCopy;
		});
		d.updateBufGui;
	});
};
d.clearClip = {
	d.clipboards[d.clipboardIndex] = nil;
	d.tableCount = (d.tableCount - 1).max(0);
	d.updateMultiWTBufs;
	d.deferMakeGui;
};
d.clearAllClipboards = {
	d.clipboards = ();
	d.tableCount = 0;
	d.updateMultiWTBufs;
	d.deferMakeGui;
};
// sines waveform plot
d.updatePlot = {
	if (d.envMode.not, {
		forkIfNeeded {
			s.sync;
			{	guiData.plotView.refresh;
				if (guiData.plotView.notNil, {
					guiData.plotArray = d.currentWaveformData;
					guiData.plotView.refresh;
				});
			}.defer;
		};
	});
};
d.updateBufPlot = {
	forkIfNeeded {
		s.sync;
		d.updateBuffers;
		s.sync;
		d.updatePlot;
	};
};
// synth funcs
d.playWaveSynth = {
	d.stopSynth;
	d.synthNode = SynthDef(\BufPlay, {
		arg playFreq = 220, outLevel = 0.1, gate = 1;
		Out.ar(d.audioOutBus, ([
			// static
			Env.asr(0.5, 0.5, 0.5).kr(2, gate) * outLevel,
			// pulsing
			Env.asr(0.5, 0.5, 0.5).kr(2, gate) * outLevel
			* LFTri.kr(0.5, 0.0).range(0.1, 1)
		] [d.pulsing.binaryValue]
		* LeakDC.ar(Osc.ar(d.wavetableBuf, playFreq, 0, 0.3)))
		! 2  // stereo
	)}).play(s, [\playFreq, d.playFreq, \outLevel, d.outLevel]);
};
d.playMultiWaveSynth = {
	d.stopSynth;
	if (d.tableCount > 1, {
		d.multiSynthNode = SynthDef(\MultiBufPlay, {
			arg playFreq = 220, tablePos = 0, outLevel = 0.1, gate = 1;
			var outTablePos = d.multiWTBufs[0].bufnum + (tablePos * (d.tableCount - 1.01));
			Out.ar(d.audioOutBus, ([
				// static
				Env.asr(0.5, 0.5, 0.5).kr(2, gate) * outLevel,
				// pulsing
				Env.asr(0.5, 0.5, 0.5).kr(2, gate) * outLevel
				* LFTri.kr(0.5, 0.0).range(0.1, 1)
			] [d.pulsing.binaryValue]
			* LeakDC.ar(VOsc.ar(outTablePos, playFreq, 0, 0.3)))
			! 2  // stereo
		)}).play(s, [\playFreq, d.playFreq, \tablePos, d.tablePos, \outLevel, d.outLevel]);
	});
};
d.stopSynth = {
	if (d.synthNode.notNil, {d.synthNode.set(\gate, 0); d.synthNode = nil;});
	if (d.multiSynthNode.notNil, {d.multiSynthNode.set(\gate, 0); d.multiSynthNode = nil;});
};
d.rebuildSynth = {
	if (d.synthNode.notNil, {
		d.stopSynth;
		{d.playWaveSynth}.defer(0.1);
	}, {
		if (d.multiSynthNode.notNil, {
			d.stopSynth;
			{d.playMultiWaveSynth}.defer(0.1);
		});
	});
};
d.freeAll = {  // free buffs & synths
	if (guiData.helpWindow.notNil, {guiData.helpWindow.close; guiData.helpWindow = nil});
	if (d.synthNode.notNil, {d.synthNode.free; d.synthNode = nil});
	if (d.multiSynthNode.notNil, {d.multiSynthNode.free; d.multiSynthNode = nil});
	if (d.wavetableBuf.notNil, {d.wavetableBuf.free; d.wavetableBuf = nil});
	if (d.multiWTBufs.notNil, {16.do({arg i; d.multiWTBufs[i].free}); d.multiWTBufs = nil});
	if (d.signalBuf.notNil, {d.signalBuf.free; d.signalBuf = nil});
};
// save funcs
d.saveWaveform = {
	Dialog.savePanel({ arg path;
		var headerFormat = d.arrSaveFormats[d.saveFormatIndex][1];
		var sampleFormat = d.arrSaveFormats[d.saveFormatIndex][2];
		var pathName, filename, fileExt, outPath;
		pathName = PathName(path);
		filename = pathName.fileNameWithoutExtension;

		["pathName.realEndNumber", pathName.realEndNumber].postcs;


		if (d.addBufLengthToFilename
			and: {pathName.realEndNumber != d.bufLength}, {
				filename = filename ++ "_" ++ d.bufLength.asString;
		});
		if (d.saveFormatIndex <= 3, {
			fileExt = ".wav";
		}, {
			fileExt = ".aif";
		});
		outPath = pathName.pathOnly +/+ filename ++ fileExt;
		// save file
		d.signalBuf.write(outPath, headerFormat, sampleFormat);
		"// ==================================".postln;
		"// Waveform file saved:".postln;
		("//" + outPath).postln;
		d.printSpecs;
	});
};
d.saveWavetable = {
	if (d.tableCount > 1, {
		Dialog.savePanel({ arg path;
			var headerFormat = d.arrSaveFormats[d.saveFormatIndex][1];
			var sampleFormat = d.arrSaveFormats[d.saveFormatIndex][2];
			var outArray, outSoundFile, waveform;
			var pathName, filename, fileExt, outPath;
			pathName = PathName(path);
			filename = pathName.fileNameWithoutExtension;
			if (d.addBufLengthToFilename
				and: {pathName.realEndNumber != d.bufLength}, {
					filename = filename ++ "_" ++ d.bufLength.asString;
			});
			if (d.saveFormatIndex <= 3, {
				fileExt = ".wav";
			}, {
				fileExt = ".aif";
			});
			outPath = pathName.pathOnly +/+ filename ++ fileExt;
			// build wavetable
			outArray = FloatArray(d.tableCount * d.bufLength);
			16.do({arg i;
				if (d.clipboards[i].notNil, {
					waveform = d.clipboards[i].waveformData;
					if (waveform.size != d.bufLength, {
						waveform = waveform.resamp1(d.bufLength);
					});
					outArray = outArray.addAll(waveform);
				});
			});
			// save file
			outSoundFile = SoundFile.new.numChannels_(1)
				.headerFormat_(headerFormat).sampleFormat_(sampleFormat);
			outSoundFile.openWrite(outPath);
			outSoundFile.writeData(outArray);
			outSoundFile.close;

			"// ==================================".postln;
			("// Wavetable file (" ++ d.tableCount ++ " waveforms) saved:").postln;
			("//" + outPath).postln;
			("// File Format:" + d.arrSaveFormats[d.saveFormatIndex][0]).postln;
			"// ==================================".postln;
		});
	}, {
		 "Cannot save Wavetable - at least 2 stored clipboards are needed.".postln;
	});
};
d.printSpecs = {
	var smoothString;
	"// ==================================".postln;
	"// - Single-Cycle Waveform Settings -".postln;
	("// Waveform Length:" + d.bufLength + "samples").postln;
	("// File Format:" + d.arrSaveFormats[d.saveFormatIndex][0]).postln;
	if (d.envMode, {
		("// Envelope with" + d.arrPoints.size + "points").postln;
		if (d.smoothType == 0, {
			smoothString = "Off";
		}, {
			smoothString = (d.smoothType * 3) + "samples";
		});
		("// Smoothing:" + smoothString).postln;
		"// SC Env Levels: ".postln;
		d.arrPoints.collect({arg item; item.y.linlin(0, 1, -1, 1)}).postcs;
		"// SC Env Times:".postln;
		d.arrPoints.collect({arg item; item.x}).differentiate.keep(1 - d.arrPoints.size).postcs;
		"// SC Env Curves:".postln;
		d.arrCurveTypes.collect({arg item, i;
			var curve;
			curve = d.arrCurveTypeOptions[item][1];
			if (curve == \curve, {
				curve = d.arrCurveVals[i];
			});
			curve;
		}).postcs;
	}, {
		("// Using" + d.numSines + "Sines").postln;
		"// Sine Freqs:".postln;
		d.arrFreqs.keep(d.numSines).postcs;
		"// Levels: ".postln;
		d.arrLevels.keep(d.numSines).postcs;
		"// Phases: (range 0 : 1)".postln;
		d.arrPhases.keep(d.numSines).postcs;
		"// Phases: (range 0 : 2pi)".postln;
		(d.arrPhases.keep(d.numSines) * 2pi).postcs;
	});
	"// ==================================".postln;
};
// envelope funcs
d.addNewPoint = {
	var newIndex = nil;
	var times;
	// only add if enough space
	if (d.arrPoints.size < d.maxPoints, {
		times = d.arrPoints.collect({arg item; item.x});
		newIndex = times.indexOfGreaterThan(guiData.newPoint.x);
		if (newIndex.notNil, {
			d.arrPoints = d.arrPoints.insert(newIndex, guiData.newPoint);
			d.arrCurveTypes = d.arrCurveTypes.insert(newIndex, 0);
			d.arrCurveVals = d.arrCurveVals.insert(newIndex, 0);
		}, {
			d.arrPoints = d.arrPoints.add(guiData.newPoint);
			d.arrCurveTypes = d.arrCurveTypes.add(0);
			d.arrCurveVals = d.arrCurveVals.add(0);
			newIndex = d.arrPoints.size - 1;
		});
	});
	newIndex; // return index
};
d.deletePoint = {
	if (d.deletePointIndex.notNil, {
		d.arrPoints.removeAt(d.deletePointIndex);
		d.arrCurveTypes.removeAt(d.deletePointIndex);
		d.arrCurveVals.removeAt(d.deletePointIndex);
		d.deletePointIndex = nil;
	});
};
d.refreshPointsView = {
	if (guiData.envView.notNil and: {guiData.envView.notClosed}, {
		guiData.envView.refresh;
	});
};
d.getArrPointCurves = {
	d.arrCurveTypes.collect({arg item, i;
		var curveType = d.arrCurveTypeOptions[item][1];
		if (curveType == \curve, {
			curveType = d.arrCurveVals[i];
		});
		curveType;
	});
};
d.updateEnvInfoView = {
	var point;
	if (guiData.mouseMode == \dragPoint, {
		point = d.arrPoints[guiData.dragPointInd];
		d.envInfoString = "Pt" + (guiData.dragPointInd + 1)
		+ "  X:" + point.x.round(0.001) + "  Y:" + point.y.round(0.001);
	}, {
		d.envInfoString = "Envelope";
	});
	guiData.envInfoView.string = d.envInfoString;
};
// env actions
d.arrEnvActions = [
	["- Actions -", {}],
	["Copy type from point 1 to all points",
	{d.arrCurveTypes = d.arrCurveTypes[0] ! d.arrCurveTypes.size;}],
	["Copy curve from point 1 to all points",
	{d.arrCurveVals = d.arrCurveVals[0] ! d.arrCurveVals.size;}],
	["Disturb points",
	{
		var size = d.arrPoints.size;
		var order;
		d.arrPoints = d.arrPoints.collect({arg item, i;
			var pt;
			if (i == 0 or: {i == (size - 1)}, {
				pt = Point(  // add 6% randomness
					item.x,
					(item.y + 0.03.rand2).clip(0.0, 1.0),
				)
			}, {
				pt = Point(  // add 6% randomness
					(item.x + 0.03.rand2).clip(0.001, 0.999),
					(item.y + 0.03.rand2).clip(0.0, 1.0),
				)
			});
			pt;
		});
		// sort
		order = d.arrPoints.order({ arg a, b; a.x < b.x });
		d.arrPoints = d.arrPoints.atAll(order);
		d.arrCurveTypes = d.arrCurveTypes.atAll(order.keep(d.arrCurveTypes.size));
		d.arrCurveVals = d.arrCurveVals.atAll(order.keep(d.arrCurveVals.size));
		if (d.lastPointEqualsFirst, {d.setLastPointToFirst});
	}],
	["Normalise envelope",
	{	var arrLevels = d.arrPoints.collect({arg item, i; item.y}).normalize;
		arrLevels.do({arg item, i; d.arrPoints[i].y = item});
	}],
	["Quantise curve values",
	{d.arrCurveVals = d.arrCurveVals.round(1);}],
	["Random envelope with 8 points",
	{	var size = 8;
		var numOptions = d.arrCurveTypeOptions.size;
		var arrTimes = {rrand(0.001, 0.999)} ! size;
		var arrLevels = {rrand(0.0, 1.0)} ! size;
		arrTimes[0] = 0;
		arrTimes[size - 1] = 1;
		if (d.lastPointEqualsFirst, {
			arrLevels[size - 1] = arrLevels[0];
		});
		arrLevels = arrLevels.normalize;
		d.arrPoints = arrTimes.collect({arg item, i; Point(item, arrLevels[i])});
		d.arrPoints = d.arrPoints.sort({ arg a, b; a.x < b.x });
		d.arrCurveTypes = 0 ! (size - 1);
		d.arrCurveVals = 0 ! (size - 1);
	}],
	["Random envelope with 16 points",
	{	var size = 16;
		var numOptions = d.arrCurveTypeOptions.size;
		var arrTimes = {rrand(0.001, 0.999)} ! size;
		var arrLevels = {rrand(0.0, 1.0)} ! size;
		arrTimes[0] = 0;
		arrTimes[size - 1] = 1;
		if (d.lastPointEqualsFirst, {
			arrLevels[size - 1] = arrLevels[0];
		});
		arrLevels = arrLevels.normalize;
		d.arrPoints = arrTimes.collect({arg item, i; Point(item, arrLevels[i])});
		d.arrPoints = d.arrPoints.sort({ arg a, b; a.x < b.x });
		d.arrCurveTypes = 0 ! (size - 1);
		d.arrCurveVals = 0 ! (size - 1);
	}],
	["Randomise points",
	{
		var size = d.arrPoints.size;
		var arrTimes = {rrand(0.001, 0.999)} ! size;
		var arrLevels = {rrand(0.0, 1.0)} ! size;
		arrTimes[0] = 0;
		arrTimes[size - 1] = 1;
		if (d.lastPointEqualsFirst, {
			arrLevels[size - 1] = arrLevels[0];
		});
		arrLevels = arrLevels.normalize;
		d.arrPoints = arrTimes.collect({arg item, i; Point(item, arrLevels[i])});
		d.arrPoints = d.arrPoints.sort({ arg a, b; a.x < b.x });
	}],
	["Randomise types",
	{	var size = d.arrCurveTypes.size;
		var numOptions = d.arrCurveTypeOptions.size;
		d.arrCurveTypes = {numOptions.rand} ! size;
	}],
	["Randomise curves",
	{	var size = d.arrCurveVals.size;
		// d.arrCurveVals = {rrand(-20.0, 20.0)} ! size;
		// d.arrCurveVals = {20.0.sum3rand} ! size;
		d.arrCurveVals = {1.0.rand.squared * [20.0, -20.0].choose} ! size;
	}],
	["Reset curves to 0",
	{d.arrCurveVals = 0 ! d.arrCurveVals.size;}],
	["Reset envelope to Sine wave",
	{d.setDefaultPoints}],
	["Reset types to Sine",
	{	d.arrCurveTypes = 0 ! d.arrCurveTypes.size;}],
	["Scramble envelope",
	{
		var size = d.arrPoints.size;
		var order, arrLevels, arrTimeGaps, arrTimes;
		if (size > 3, {
			//	Scramble points
			arrTimeGaps = d.arrPoints.atAll((1..(size - 1))).collect({arg item; item.x}).differentiate;
			arrTimeGaps = arrTimeGaps.scramble;
			arrTimes = ([0] ++ arrTimeGaps).integrate;
			arrTimes.do({arg item, i; d.arrPoints[i].x = item});
			// sort
			d.arrPoints = d.arrPoints.sort({ arg a, b; a.x < b.x });
			if (d.lastPointEqualsFirst, {
				arrLevels = d.arrPoints.atAll((0..(size - 2))).collect({arg item; item.y})
			}, {
				arrLevels = d.arrPoints.collect({arg item; item.y})
			});
			arrLevels = arrLevels.scramble;
			arrLevels.do({arg item, i; d.arrPoints[i].y = item});
			//	Scramble types and curves
			order = Array.iota(d.arrCurveTypes.size).scramble;
			d.arrCurveTypes = d.arrCurveTypes.atAll(order);
			d.arrCurveVals = d.arrCurveVals.atAll(order);
			if (d.lastPointEqualsFirst, {d.setLastPointToFirst});
		});
	}],
	["Scramble types and curves",
	{	var order = Array.iota(d.arrCurveTypes.size).scramble;
		d.arrCurveTypes = d.arrCurveTypes.atAll(order);
		d.arrCurveVals = d.arrCurveVals.atAll(order);
	}],
];
d.runEnvAction = {
	d.arrEnvActions.flop.slice(1).at(guiData.envActionInd).value;
};
// Freq actions
d.arrFreqActions = [
		["- Actions -",
		{}],
		["Reset",
		{d.arrFreqs = d.maxSines.collect({arg i; i + 1});}],
		["Disturb",
		{d.arrFreqs = (d.arrFreqs + ({0.25.rand2} ! d.maxSines)).clip(0.1, d.maxSineFreq);}],
		["Randomise",
		{d.arrFreqs = {d.minSineFreq.rrand(d.maxSineFreq.asFloat)} ! d.maxSines;}],
		["Scramble",
		{	var newArr = d.arrFreqs.keep(d.numSines);
			newArr = newArr.scramble;
			newArr.do({arg item, i;
				d.arrFreqs[i] = item;
			});
		}],
		["Sort <",
		{	var newArr = d.arrFreqs.keep(d.numSines);
			newArr = newArr.sort;
			newArr.do({arg item, i;
				d.arrFreqs[i] = item;
			});
		}],
		["Quantise",
		{	d.arrFreqs = d.arrFreqs.round.max(1);}],
];
d.runFreqAction = {
	d.arrFreqActions.flop.slice(1).at(guiData.holdActionInd).value;
};
// Level actions
d.arrLevelActions = [
		["- Actions -",
		{}],
		["Reset",
		{d.arrLevels = [1] ++ (0 ! (d.maxSines - 1));}],
		["Disturb",
		{d.arrLevels = (d.arrLevels + ({0.05.rand2} ! d.maxSines)).clip(0, 1);}],
		["Randomise",
		{d.arrLevels = {1.0.rand} ! d.maxSines;}],
		["Scramble",
		{	var newArr = d.arrLevels.keep(d.numSines);
			newArr = newArr.scramble;
			newArr.do({arg item, i;
				d.arrLevels[i] = item;
			});
		}],
		["Scramble > 1",
		{	var newArr = d.arrLevels.keep(d.numSines);
			newArr = [newArr[0]] ++  newArr.keep(1 - newArr.size).scramble;
			newArr.do({arg item, i;
				d.arrLevels[i] = item;
			});
		}],
		["Reverse",
		{	var newArr = d.arrLevels.keep(d.numSines);
			newArr = newArr.reverse;
			newArr.do({arg item, i;
				d.arrLevels[i] = item;
			});
		}],
		["Invert",
		{	var newArr = d.arrLevels.keep(d.numSines);
			newArr.do({arg item, i;
				d.arrLevels[i] = 1 - item;
			});
		}],
		["Sort  >",
		{	var newArr = d.arrLevels.keep(d.numSines);
			newArr = newArr.sort.reverse;
			newArr.do({arg item, i;
				d.arrLevels[i] = item;
			});
		}],
		["Bias Up",
		{d.arrLevels = d.arrLevels.collect({arg item, i; item.lincurve(0, 1, 0, 1, -1)});}],
		["Bias Down",
		{d.arrLevels = d.arrLevels.collect({arg item, i; item.lincurve(0, 1, 0, 1, 1)});}],
		["Bias 1/N",
		{d.arrLevels = d.arrLevels.collect({arg item, i; item.blend(item / (i + 1), 0.5)});}],
		["Bias 1/N.squared",
		{d.arrLevels = d.arrLevels.collect({arg item, i; item.blend(item / (i + 1).squared, 0.5)});}],
		["Zero if even",
		{d.arrLevels = d.arrLevels.collect({arg item, i; if (i.odd, 0, item)});}],
		["Zero odd > 1",
		{d.arrLevels = d.arrLevels.collect({arg item, i; if (i > 0 and: {i.even}, 0, item)});}],
		["Copy 1-> all",
		{d.arrLevels = d.arrLevels[0] ! d.maxSines;}],
		["Normalise",
		{	var newArr = d.arrLevels.keep(d.numSines);
			newArr = newArr.normalize;
			newArr.do({arg item, i;
				d.arrLevels[i] = item;
			});
		}],
		["1/N",
		{d.arrLevels = d.arrLevels.size.collect({arg i; (i + 1).reciprocal});}],
		["1/N.squared",
		{d.arrLevels = d.arrLevels.size.collect({arg i; (i + 1).squared.reciprocal});}],

];
d.runLevelAction = {
	d.arrLevelActions.flop.slice(1).at(guiData.holdActionInd).value;
};
// Phase actions
d.arrPhaseActions = [
		["- Actions -",
		{}],
		["Reset",
		{d.arrPhases = 0 ! d.maxSines;}],
		["Disturb",
		{d.arrPhases = (d.arrPhases + ({0.05.rand2} ! d.maxSines)).clip(0, 1);}],
		["Randomise",
		{d.arrPhases = {1.0.rand} ! d.maxSines;}],
		["Scramble",
		{	var newArr = d.arrPhases.keep(d.numSines);
			newArr = newArr.scramble;
			newArr.do({arg item, i;
				d.arrPhases[i] = item;
			});
		}],
		["Reverse",
		{	var newArr = d.arrPhases.keep(d.numSines);
			newArr = newArr.reverse;
			newArr.do({arg item, i;
				d.arrPhases[i] = item;
			});
		}],
		["Invert",
		{	var newArr = d.arrPhases.keep(d.numSines);
			newArr.do({arg item, i;
				d.arrPhases[i] = 1 - item;
			});
		}],
		["Phase shift 1/4",
		{d.arrPhases = (d.arrPhases + 0.25).wrap(0, 1);}],
		["Phase shift 1/8",
		{d.arrPhases = (d.arrPhases + 0.125).wrap(0, 1);}],
		["Quantise 1/4",
		{d.arrPhases = d.arrPhases.round(0.25);}],
		["Quantise 1/8",
		{d.arrPhases = d.arrPhases.round(0.125);}],
		["Copy 1-> all",
		{d.arrPhases = d.arrPhases[0] ! d.maxSines;}],
		["Pattern A",
		{d.arrPhases = d.maxSines.collect({arg i; [0, 0.5].wrapAt(i)});}],
		["Pattern B",
		{d.arrPhases = d.maxSines.collect({arg i; [0, 0, 0.5, 0].wrapAt(i)});}],
		["Pattern C",
		{d.arrPhases = d.maxSines.collect({arg i; [0, 0.25, 0.5, 0.75].wrapAt(i)});}],
];
d.runPhaseAction = {
	d.arrPhaseActions.flop.slice(1).at(guiData.holdActionInd).value;
};
//
// gui --- components are built before assembling layout
//
d.makeGui = {
	var topRowViews, leftPanelLayout, w, pointWidth;
	// init
	w = guiData.window;  // store window if present
	guiData = ();  //  clear old data
	Font.default = Font("Helvetica", 11);
	guiData.titleFont =  Font("Helvetica", 12);
	guiData.window = w; // restore window
	// create window if needed
	if (guiData.window.isNil, {
		guiData.window = Window(
			"Wavetable Builder",
			Rect(0, 0, d.windowWidth,  d.windowHeight)
		).front;
		w = guiData.window;
		w.view.resize_(5);
		w.view.background_(d.colWindow);
		w.alwaysOnTop = d.alwaysOnTop;
		w.onClose_({
			d.freeAll;
		});
	}, {
		guiData.window.view.removeAll;
	});
	// play freq slider & numbox
	guiData.playFreqSlider = Slider().thumbSize_(8).orientation_(\horizontal)
	.minWidth_(180).maxWidth_(260).minHeight_(20).maxHeight_(20)
	.background_(Color.white).knobColor_(d.colButton)
	.action_({arg view;
		d.playFreq = d.outFreqSpec.map(view.value);
		guiData.playFreqNumbox.value_(d.playFreq);
		d.synthNode.set(\playFreq, d.playFreq);
		d.multiSynthNode.set(\playFreq, d.playFreq);
	})
	.value_(d.outFreqSpec.unmap(d.playFreq));
	guiData.playFreqNumbox = NumberBox().maxDecimals_(2)
	.minWidth_(40).maxWidth_(40).minHeight_(20).maxHeight_(20)
	.action_({arg view;
		d.playFreq = view.value;
		guiData.playFreqSlider.value = d.outFreqSpec.unmap(d.playFreq);
		d.synthNode.set(\playFreq, d.playFreq);
		d.multiSynthNode.set(\playFreq, d.playFreq);
	})
	.value_(d.playFreq);
	// mode - sines or envelope
	guiData.modeViews = HLayout(
		// mode popup
		ListView().minWidth_(96).maxWidth_(96).minHeight_(30).maxHeight_(30)
		.items_(["Mode: Sines", "Mode: Envelope"])
		.stringColor_(d.colLabelString).background_(d.colHighlight)
		.value_(d.envMode.binaryValue)
		.action_({arg view;
			var val = view.value.asBoolean;
			d.envMode = val;
			d.hidePoints = false;
			d.updateBufGui;
		}),
	);
	if (d.envMode, {
		guiData.modeViews.add(
			View().minWidth_(84).maxWidth_(84).maxHeight_(24);  // spacer
		);
	}, {
		guiData.modeViews.add(
			// num sines popup
			PopUpMenu().minWidth_(80).maxWidth_(80).maxHeight_(24)
			.items_((4..d.maxSines).collect({ arg i; i.asString + "Sines"}))
			.stringColor_(d.colLabelString).background_(d.colHighlight)
			.value_(d.numSines - 4)
			.action_({arg view;
				d.numSines = view.value + 4;
				d.updateBufGui;
			}),
		);
	});
	// top row
	topRowViews = HLayout(
		guiData.modeViews,
		20, // spacer
		// Help button
		StaticText().string_("Help").align_(\center)
		.minWidth_(50).maxWidth_(50).minHeight_(20).maxHeight_(20)
		.stringColor_(Color.white).background_(d.colHelp)
		.mouseDownAction_({d.showHelpWindow}),
		20, // spacer
		// Print button
		StaticText().string_("Print Specs").align_(\center)
		.minWidth_(80).maxWidth_(80).minHeight_(20).maxHeight_(20)
		.stringColor_(Color.white).background_(d.colButton)
		.mouseDownAction_({d.printSpecs;}),
		20, // spacer
		// checkbox
		Button().states_([
			["[ ] Window on top", d.colButton, Color.white],
			["[X] Window on top", Color.white, d.colButton]])
		.minWidth_(114).maxWidth_(114).minHeight_(20).maxHeight_(20)
		.action_({arg view;
			var val = view.value.asBoolean;
			d.alwaysOnTop = val;
			guiData.window.alwaysOnTop = val;
		})
		.value_(d.alwaysOnTop.binaryValue),
		nil, // spacer
	);
	// build left panel
	if (d.envMode, {
		// envelope controls
		pointWidth = (60 - (3 * (d.arrPoints.size - 9).max(0))).max(40);
		// Point labels
		guiData.pointLabels = [
			// label
			StaticText().minWidth_(50).maxWidth_(50).minHeight_(20).maxHeight_(20).align_(\center)
			.string_("Points").stringColor_(d.colLabelString).background_(d.colLabel),
		]
		++ d.arrPoints.size.collect({arg i;
			// label
			StaticText().string_(i + 1).align_(\center)
			.minWidth_(pointWidth).maxWidth_(60).minHeight_(20).maxHeight_(20)
			.stringColor_(d.colLabelString).background_(d.colLabel)
		})
		++ [nil];
		// Point delete buttons
		guiData.pointDelBtns = [
			// label
			StaticText().minWidth_(50).maxWidth_(50).minHeight_(20).maxHeight_(20).align_(\center)
			.string_("Delete").stringColor_(d.colLabelString).background_(d.colLabel),
		]
		++ d.arrPoints.size.collect({arg i;
			if (d.minPoints == d.arrPoints.size or: {i == 0} or: {i == (d.arrPoints.size - 1)}, {
				View().background_(d.colSemiGrey)
				.minWidth_(pointWidth).maxWidth_(60).minHeight_(20).maxHeight_(20)
			}, {
				// button
				StaticText().string_("x").align_(\center)
				.minWidth_(pointWidth).maxWidth_(60).minHeight_(20).maxHeight_(20)
				.stringColor_(Color.black).background_(Color.white)
				.mouseDownAction_({arg view;
					d.deletePointIndex = i;
					d.deletePoint;
					d.updateBufGui;
				});
			});
		})
		++ [nil];
		// Point curve type popups
		guiData.pointCurveTypeBtns = [
			// label
			StaticText().minWidth_(50).maxWidth_(50).minHeight_(20).maxHeight_(20).align_(\center)
			.string_("Type").stringColor_(d.colLabelString).background_(d.colLabel),
		]
		++ d.arrPoints.size.collect({arg i;
			if (i == (d.arrPoints.size - 1), {
				View().background_(Color.clear)
				.minWidth_(pointWidth).maxWidth_(60).minHeight_(20).maxHeight_(20)
			}, {
				// popup
				PopUpMenu()
				.minWidth_(pointWidth).maxWidth_(60).minHeight_(20).maxHeight_(20)
				.items_(d.arrCurveTypeOptions.collect({ arg i; i[0]}))
				.stringColor_(Color.black).background_(Color.white)
				.value_(d.arrCurveTypes[i])
				.action_({arg view;
					d.arrCurveTypes[i] = view.value;
					d.updateBufGui;
				});
			});
		})
		++ [nil];
		// Point curve sliders
		guiData.pointCurveSldrs = [
			// label
			StaticText().align_(\center)
			.minWidth_(50).maxWidth_(50).minHeight_(200)
			.string_("Curve").stringColor_(d.colLabelString).background_(d.colLabel);
		]
		++ d.arrPoints.size.collect({arg i;
			if (i == (d.arrPoints.size - 1), {
				View().background_(Color.clear)
					.minWidth_(pointWidth).maxWidth_(60).minHeight_(200)
			}, {
				if (d.arrCurveTypes[i] != 1, {
					View().background_(d.colSemiGrey)
					.minWidth_(pointWidth).maxWidth_(60).minHeight_(200)
				}, {
					// slider
					Slider().thumbSize_(8)
					.minWidth_(pointWidth).maxWidth_(60).minHeight_(200)
					.background_(Color.white).knobColor_(d.colButton)
					.action_({arg view;
						var val = d.curveSpec.map(view.value);
						d.arrCurveVals[i] = val;
						guiData.pointCurveNumboxes[i + 1].value = val;
						d.refreshPointsView;
					})
					.mouseUpAction_({
						d.updateBufPlot;
					})
					.value_(d.curveSpec.unmap(d.arrCurveVals[i]))
				})
			})
		})
		++ [nil];
		// Point curve numboxes
		guiData.pointCurveNumboxes = [
			// label
			View().minWidth_(50).maxWidth_(50).minHeight_(20).maxHeight_(20),
		]
		++ d.arrPoints.size.collect({arg i;
			if (i == (d.arrPoints.size - 1), {
				View().background_(Color.clear)
				.minWidth_(pointWidth).maxWidth_(60).minHeight_(20).maxHeight_(20)
			}, {
				if (d.arrCurveTypes[i] != 1, {
					View().minWidth_(pointWidth).maxWidth_(60).minHeight_(20).maxHeight_(20)
				}, {
					// button
					NumberBox().maxDecimals_(2)
					.minWidth_(pointWidth).maxWidth_(60).minHeight_(20).maxHeight_(20)
					.font_(Font("Ariel", 9))
					.action_({arg view;
						view.value = d.curveSpec.constrain(view.value);
						d.arrCurveVals[i] = view.value;
						guiData.pointCurveSldrs[i + 1].value = d.curveSpec.unmap(view.value);
						d.updateBufPlot;
						d.refreshPointsView;
					})
					.value_(d.arrCurveVals[i])
				})
			})
		})
		++ [nil];
		// env view
		guiData.envView = UserView().background_(Color.white)
		.minWidth_(520).minHeight_(250).maxHeight_(600)
		.drawFunc_({arg view;
			var margin = 4;
			var width = view.bounds.width - (margin * 2);
			var height = view.bounds.height - (margin * 2);
			var points = d.arrPoints;
			var envArray, radius, holdArr;
			if (d.smoothType == 0, { // no smoothing
				envArray = Env(
					points.collect({arg item; item.y + 0.001}),
					points.collect({arg item; item.x}).differentiate.keep(1 - points.size),
					d.getArrPointCurves,
					offset: -0.001,
				).asSignal(width).as(Array);
			}, {
				envArray = Env(
					points.collect({arg item; item.y + 0.001}),
					points.collect({arg item; item.x}).differentiate.keep(1 - points.size),
					d.getArrPointCurves,
					offset: -0.001
				).asSignal(d.bufLength).as(Array);
				// smoothing
				radius = d.smoothType * 3;
				holdArr = envArray.collect({arg item, i;
					envArray.wrapAt(i + (radius.neg..radius)).mean;
				});
				// resize
				envArray = holdArr.resamp1(width);
			});
			// outline
			Pen.color = Color.grey(0.85);
			Pen.addRect(Rect(0, 0, view.bounds.width, margin));
			Pen.addRect(Rect(0, view.bounds.height - margin, view.bounds.width, margin));
			Pen.addRect(Rect(0, 0, margin, view.bounds.height));
			Pen.addRect(Rect(view.bounds.width - margin, 0, margin, view.bounds.height));
			Pen.fill;
			// curve
			Pen.color = Color.grey(0.85).blend(d.colButton);
			envArray.do({arg item, i;
				Pen.moveTo((margin + i) @ (view.bounds.height * 0.5));
				Pen.lineTo((margin + i) @ (view.bounds.height - (item * height + margin)));
				Pen.stroke;
			});
			// points
			if (d.hidePoints.not, {
				points.do({arg item, i;
					var dataStringPt = Point(0, 8);
					var point = Point(
						(item.x * width) + margin,
						view.bounds.height - ((item.y * height) + margin)
					);
					Pen.color = Color.blue;
					Pen.addArc(point, 4, 0, 2pi );
					Pen.stroke;
					Pen.stringAtPoint((i + 1).asString, Point(
						(point.x + 5).clip(10, view.bounds.width - 18),
						(point.y - 12).clip(3, view.bounds.height - 18),
					));
					if (guiData.mouseMode == \dragPoint and: {guiData.dragPointInd == i}, {
						Pen.color = Color.grey;
						Pen.moveTo(point.x @ margin);
						Pen.lineTo(point.x @ (view.bounds.height - margin));
						Pen.moveTo(margin @ point.y);
						Pen.lineTo((view.bounds.width - margin) @ point.y);
						Pen.stroke;
					});
				});
			});
		})
		.mouseDownAction_({arg view, x, y, modifiers;
			var margin = 5;
			var width = view.bounds.width - (margin * 2);
			var height = view.bounds.height - (margin * 2);
			var points = d.arrPoints;
			var posx = (x - margin) / width;
			var posy = (view.bounds.height - y - margin) / height;
			var found = false;
			var ind, pointX, pointY, diffx, diffy;
			if (d.hidePoints.not, {
				guiData.mouseMode = nil;
				guiData.dragPointInd = nil;
				ind = 0;
				// if near to existing point, select that
				while {found.not and: {ind < points.size}} {
					pointX = (points[ind].x * width) + margin;
					pointY = (points[ind].y * height) + margin;
					diffx = pointX - x;
					diffy = pointY - (view.bounds.height - y);
					if ((diffx.abs < 6) and: {diffy.abs < 6}, {
						found = true;
						guiData.dragPointInd = ind;
					});
					ind = ind + 1;
				};
				if (found, {
					guiData.mouseMode = \dragPoint;
				}, {
					guiData.newPoint = Point(posx.clip(0.0001, 0.9999), posy.clip(0, 1));
					guiData.dragPointInd = d.addNewPoint;
					if (guiData.dragPointInd.notNil, {
						guiData.mouseMode = \dragPoint;
					});
				});
				view.refresh;
				d.updateEnvInfoView;
			});
		})
		.mouseMoveAction_({arg view, x, y, modifiers;
			var margin, width, height, posx, posy, points, point;
			var  prevx, nextx;
			if (guiData.mouseMode == \dragPoint, {
				margin = 5;
				width = view.bounds.width - (margin * 2);
				height = view.bounds.height - (margin * 2);
				posx = (x - margin).clip(0, width) / width;
				posy = (view.bounds.height - y - margin) / height;
				points = d.arrPoints;
				point = points[guiData.dragPointInd];
				// if first point
				if (guiData.dragPointInd == 0, {
					point.y = posy.clip(0, 1);
					if (d.lastPointEqualsFirst == true, {
						points[points.size - 1].y = point.y;
					});
				}, {
					// if last point
					if (guiData.dragPointInd == (points.size - 1), {
						point.y = posy.clip(0, 1);
						if (d.lastPointEqualsFirst == true, {
							points.first.y = point.y;
						});
					}, {
						// else
						prevx = points[guiData.dragPointInd - 1].x;
						nextx = points[guiData.dragPointInd + 1].x;
						point.x = posx.clip(prevx + 0.0001, nextx - 0.0001);
						point.y = posy.clip(0, 1);
					});
				});
				view.refresh;
				d.updateEnvInfoView;
			});
		})
		.mouseUpAction_({arg view, x, y, modifiers;
			if (guiData.mouseMode == \dragPoint, {
				if (guiData.newPoint.notNil, {
					d.updateBufGui;
				}, {
					d.updateBuffers;
				});
			});
			guiData.mouseMode = nil;
			guiData.dragPointInd = nil;
			guiData.newPoint = nil;
			view.refresh;
			d.updateEnvInfoView;
		});
		// info view
		guiData.envInfoView = StaticText().align_(\center)
		.minWidth_(150).maxWidth_(150).minHeight_(20).maxHeight_(20)
		.stringColor_(d.colLabelString).background_(d.colLabel)
		.string_(d.envInfoString).font_(guiData.titleFont);
		// left panel
		leftPanelLayout = VLayout(
			// top row
			topRowViews,
			// line
			View().minHeight_(1).maxHeight_(1).background_(d.colLabel),
			2, // spacer
			// env controls
			HLayout(
				// envInfo
				guiData.envInfoView,
				View().minWidth_(2).maxWidth_(40), // spacer
				// checkbox
				Button().states_([
					["[ ] Hide points", d.colButton, Color.white],
					["[X] Hide points", Color.white, d.colButton]])
				.minWidth_(95).maxWidth_(95).minHeight_(20).maxHeight_(20)
				.action_({arg view;
					d.hidePoints = view.value.asBoolean;
					guiData.envView.refresh;
				})
				.value_(d.hidePoints.binaryValue),
				View().minWidth_(2).maxWidth_(40), // spacer
				// Smoothing popup
				PopUpMenu().minWidth_(160).maxWidth_(160).minHeight_(20).maxHeight_(20)
				.items_(11.collect({arg i; var ind;
					if (i == 0,
						{ind = "Smoothing: Off (default)"},
						{ind = "Smoothing:" + (i * 3).asString + "Samples"}
					);
					ind;
				})).stringColor_(Color.black).background_(d.colHighlight)
				.value_(d.smoothType)
				.action_({arg view;
					d.smoothType = view.value;
					d.updateBuffers;
					guiData.envView.refresh;
				}),
				View().minWidth_(2).maxWidth_(40), // spacer
				// checkbox
				Button().states_([
					["[ ] Last point = first", d.colButton, Color.white],
					["[X] Last point = first", Color.white, d.colButton]])
				.minWidth_(120).maxWidth_(120).minHeight_(20).maxHeight_(20)
				.action_({arg view;
					var val = view.value.asBoolean;
					d.lastPointEqualsFirst = val;
					if (val, {
						d.setLastPointToFirst;
						d.updateBufGui;
					});
				})
				.value_(d.lastPointEqualsFirst.binaryValue),
				nil,  // spacer
			).spacing_(8),
			1, // spacer
			[guiData.envView, stretch: 1],
			1, // spacer
			HLayout(*guiData.pointLabels.collect({arg item; [item, stretch: 1]})).spacing_(2),
			1, // spacer
			HLayout(*guiData.pointDelBtns.collect({arg item; [item, stretch: 1]})).spacing_(2),
			1, // spacer
			HLayout(*guiData.pointCurveTypeBtns.collect({arg item; [item, stretch: 1]})).spacing_(2),
			1, // spacer
			[HLayout(*guiData.pointCurveSldrs.collect({arg item; [item, stretch: 1]})).spacing_(2), stretch: 0.5],
			1, // spacer
			HLayout(*guiData.pointCurveNumboxes.collect({arg item; [item, stretch: 1]})).spacing_(2),
			// nil,  // spacer
		).spacing_(6);
	}, {
		// build left panel for sine controls
		guiData.leftPanelViews =  [
			// bank: name, spec, arrFuncionNames, functionAction
			["Sine Freqs", d.arrFreqs, d.sineFreqSpec, d.arrFreqActions.flop.slice(0), {d.runFreqAction}],
			["Levels", d.arrLevels, ControlSpec(0, 1), d.arrLevelActions.flop.slice(0), {d.runLevelAction}],
			["Phases", d.arrPhases, ControlSpec(0, 1), d.arrPhaseActions.flop.slice(0), {d.runPhaseAction}],
		].collect({arg layer, layerInd;
			var title = layer[0];
			var arrVals = layer[1];
			var controlSpec = layer[2];
			var arrActionNames = layer[3];
			var functionAction = layer[4];
			var maxHeight = layer[5];
			var titleViews, controlViews, multiSliderView;
			// title panel
			titleViews = VLayout(
				// label
				StaticText().minWidth_(96).minHeight_(20).maxHeight_(20).align_(\center)
				.font_(guiData.titleFont)
				.string_(title).stringColor_(d.colLabelString).background_(d.colLabel),
				// action list
				ListView().minHeight_(50)
				.items_(arrActionNames)
				.action_({arg view;
					guiData.holdActionInd = view.value;
					functionAction.value;
					d.updateBufGui;
				}),
				2, // spacer
			);
			// Sine controls
			if (d.useMultiSlider, {
				controlViews = d.numSines.collect({ arg i;
					var numbox = NumberBox().maxDecimals_(4)
					.font_(Font("Ariel", 9))
					.action_({arg view;
						view.value = controlSpec.constrain(view.value);
						arrVals[i] = view.value;
						multiSliderView.value = d.numSines.collect({arg i; controlSpec.unmap(arrVals[i])});
						d.updateBufPlot;
					})
					.value_(arrVals[i]);
					if ((i % 2) == 0, {numbox.background_(d.colHighlight)});
					numbox;
				});
				multiSliderView = MultiSliderView().size_(d.numSines).elasticMode_(1)
				.thumbSize_(30).isFilled_(true).fillColor_(d.colButton.blend(Color.white, 0.7))
				.minWidth_(d.numSines * 20).maxHeight_(170)
				.background_(Color.white)
				.action_({arg view;
					var arrViewVals = view.value.collect({arg argVal, i;
						var val = controlSpec.map(argVal);
						arrVals[i] = val;
						controlViews[i].value = val;
					});
				})
				.mouseUpAction_({
					d.updateBufPlot;
				})
				.value_(d.numSines.collect{arg i; controlSpec.unmap(arrVals[i])});
				HLayout(titleViews,
					VLayout(
						multiSliderView,
						HLayout(*controlViews).margins_(3, 0, 8, 0)
					).spacing_(0)
				).spacing_(2);
			}, {
				controlViews =  d.numSines.collect({ arg i;
					var slider, numbox;
					slider = Slider().thumbSize_(8).maxHeight_(170)
					.background_(Color.white).knobColor_(d.colButton)
					.action_({arg view;
						var val = controlSpec.map(view.value);
						arrVals[i] = val;
						numbox.value = val;
					})
					.mouseUpAction_({
						d.updateBufPlot;
					})
					.value_(controlSpec.unmap(arrVals[i]));
					numbox = NumberBox().maxDecimals_(4)
					.font_(Font("Ariel", 9))
					.action_({arg view;
						view.value = controlSpec.constrain(view.value);
						arrVals[i] = view.value;
						slider.value = controlSpec.unmap(view.value);
						d.updateBufPlot;
					})
					.value_(arrVals[i]);
					if ((i % 2) == 0, {numbox.background_(d.colHighlight)});
					VLayout(slider, numbox)
					.spacing_(2)
					.margins_([0, 0, 0, 10]);  // bottom margin
				});
				HLayout( *([titleViews] ++ controlViews) ).spacing_(2);
			});
		});
		leftPanelLayout = VLayout (*([topRowViews] ++ guiData.leftPanelViews));
	});  // end of build left panel
	// clipboard buttons
	guiData.storeBtns = [
		// label
		StaticText().minWidth_(80).maxWidth_(80).minHeight_(20).maxHeight_(20).align_(\center)
		.string_("Store").stringColor_(d.colLabelString).background_(d.colLabel),
	]
	++ 16.collect({arg i;
		// only show store button if data not found
		if (d.clipboards[i].isNil, {
			// button
			StaticText().string_(i + 1)
			.minWidth_(21).maxWidth_(21).minHeight_(20).maxHeight_(20).align_(\center)
			.stringColor_(Color.white).background_(d.colButton.blend(Color.white, 0.2))
			.mouseDownAction_({
				d.clipboardIndex = i;
				d.storeClip;
			});
		}, {
			// spacer
			View().background_(d.colSemiGrey)
			.minWidth_(21).maxWidth_(21).minHeight_(20).maxHeight_(20);
		});
	})
	++ [nil];
	guiData.loadBtns = [
		// label
		StaticText().minWidth_(80).maxWidth_(80).minHeight_(20).maxHeight_(20).align_(\center)
		.string_("Load").stringColor_(d.colLabelString).background_(d.colLabel),
	]
	++ 16.collect({arg i;
		// only show load button if data found
		if (d.clipboards[i].notNil, {
			// button
			StaticText().string_(i + 1)
			.minWidth_(21).maxWidth_(21).minHeight_(20).maxHeight_(20).align_(\center)
			.stringColor_(Color.white).background_(d.colButton.blend(Color.black, 0.2))
			.mouseDownAction_({arg view;
				d.clipboardIndex = i;
				d.loadClip;
			});
		}, {
			// spacer
			View().background_(d.colSemiGrey)
			.minWidth_(21).maxWidth_(21).minHeight_(20).maxHeight_(20);
		});
	})
	++ [nil];
	// presets
	guiData.presetView = ListView()
	.minHeight_(80).maxHeight_(80)
	.items_(d.presets.flop.slice(0))
	.action_({arg view;
		d.presetIndex = view.value;
		d.loadPreset;
	});
	guiData.deleteBtns = [
		// label
		StaticText().minWidth_(80).maxWidth_(80).minHeight_(20).maxHeight_(20).align_(\center)
		.string_("Delete").stringColor_(d.colLabelString).background_(d.colLabel),
	]
	++ 16.collect({arg i;
		// only show clear button if data found
		if (d.clipboards[i].notNil, {
			// button
			StaticText().string_("x")
			.minWidth_(21).maxWidth_(21).minHeight_(20).maxHeight_(20).align_(\center)
			.stringColor_(Color.white).background_(d.colButton.blend(Color.black, 0.2))
			.mouseDownAction_({arg view;
				d.clipboardIndex = i;
				d.clearClip;
			});
		}, {
			// spacer
			View().background_(d.colSemiGrey)
			.minWidth_(21).maxWidth_(21).minHeight_(20).maxHeight_(20);
		});
	})
	++ [nil];
	// lower right view
	if (d.envMode, {
		// env actions popup
		guiData.lowerRightView = VLayout(
			// label
			StaticText().string_("Envelope Actions").font_(guiData.titleFont)
			.minHeight_(20).maxHeight_(20).align_(\center)
			.stringColor_(d.colLabelString).background_(d.colLabel),
			ListView()
			.minHeight_(210).maxHeight_(210)
			.items_(d.arrEnvActions.flop.slice(0))
			.stringColor_(Color.black).background_(Color.white)
			.action_({arg view;
				guiData.envActionInd = view.value;
				d.runEnvAction;
				d.updateBufGui;
			}),
			nil,  // spacer
		);
	}, {
		// waveform plot
		guiData.plotView = UserView()
		.minWidth_(420).maxWidth_(700).minHeight_(240).maxHeight_(700)
		.background_(d.colLabel);
		guiData.plotView.drawFunc = {arg view;
			var margin = 1;
			var plotWidth = view.bounds.width - (margin * 2);
			var plotHeight = view.bounds.height - (margin * 2);
			var plotArray;
			if (guiData.plotArray.notNil, {
				plotArray = guiData.plotArray.resamp1(plotWidth).linlin(-1, 1, 0, 1);
				Pen.color = Color.grey(0.85).blend(d.colButton);
			// outline
			Pen.moveTo(margin @ margin);
			Pen.lineTo(margin @ (plotHeight + margin));
			Pen.lineTo((plotWidth + margin) @ (plotHeight + margin));
			Pen.lineTo((plotWidth + margin) @ margin);
			Pen.lineTo(margin @ margin);
			Pen.stroke;
			// curve
				plotArray.do({arg item, i;
					Pen.moveTo((margin + i) @ (view.bounds.height * 0.5));
					Pen.lineTo((margin + i) @ (view.bounds.height - (item * plotHeight + margin)));
					Pen.stroke;
				});
			});
		};
		guiData.lowerRightView = guiData.plotView;
	});
	// Table position slider
	guiData.tablePosSlider = HLayout(
		// label
		StaticText().string_("Position").align_(\center)
		.minWidth_(60).maxWidth_(60).minHeight_(20).maxHeight_(20)
		.font_(guiData.titleFont)
		.stringColor_(d.colLabelString).background_(d.colLabel),
		// slider
		Slider().thumbSize_(8).orientation_(\horizontal)
		.minWidth_(130).maxWidth_(150).minHeight_(20).maxHeight_(20)
		.background_(Color.white).knobColor_(d.colButton)
		.action_({arg view;
			d.tablePos = view.value;
			d.multiSynthNode.set(\tablePos, d.tablePos);
		})
		.value_(d.tablePos)
	).spacing_(2);
	// play waveform button
	guiData.playWaveformBtn = StaticText().string_("Play Waveform").align_(\center)
	.minWidth_(96).maxWidth_(96).minHeight_(22).maxHeight_(22)
	.stringColor_(Color.white).background_(d.colPlay)
	.mouseDownAction_({d.playWaveSynth; d.updatePlayButtons;});
	// play wavetable button
	guiData.playWavetableBtn = StaticText().string_("Play Wavetable")
	.minWidth_(96).maxWidth_(96)
	.minHeight_(22).maxHeight_(22).align_(\center)
	.stringColor_(Color.white).background_(d.colPlay)
	.mouseDownAction_({d.playMultiWaveSynth; d.updatePlayButtons;});
	if (d.tableCount > 1, {
		guiData.wavetableRow = HLayout(
			guiData.playWavetableBtn,
			nil, // spacer
			// stop button
			StaticText().string_("Stop")
			.minWidth_(42).maxWidth_(42)
			.minHeight_(22).maxHeight_(22).align_(\center)
			.stringColor_(Color.white).background_(d.colStop)
			.mouseDownAction_({d.stopSynth; d.updatePlayButtons;}),
			View().maxWidth_(20), // spacer
			nil, // spacer
			// table pos slider
			guiData.tablePosSlider,
			nil, // spacer
			// Save Wavetable button
			StaticText().string_("Save Wavetable")
			.minWidth_(100).maxWidth_(100)
			.minHeight_(22).maxHeight_(22).align_(\center)
			.stringColor_(Color.white).background_(d.colSave)
			.mouseDownAction_({d.saveWavetable;}),
		).spacing_(2);
	}, {
		// info text
		guiData.wavetableRow =
			StaticText().string_("Store at least 2 waveforms in clipboards to see the Wavetable controls")
			.minHeight_(22).maxHeight_(22).align_(\center)
			.stringColor_(d.colLabelString).background_(Color.white);
	});
	// assemble window layout
	guiData.window.layout = HLayout(  // split panels
		// left panel
		[leftPanelLayout, stretch: 1],
		// line
		View().minWidth_(1).maxWidth_(1).background_(d.colLabel),
		// right panel
		VLayout(
			5, // spacer
			HLayout(  // Row of controls
				// label
				StaticText().string_("Waveform")
				.font_(guiData.titleFont)
				.minHeight_(20).maxHeight_(20).align_(\center)
				.stringColor_(d.colLabelString).background_(d.colLabel),
			),
			HLayout(  // Row of controls
				// Samples popup
				PopUpMenu()
				.minWidth_(160).maxWidth_(160).minHeight_(20).maxHeight_(20)
				.items_(d.arrBufLengthPresets.flop.slice(0).collect({arg item;
					"Length: " + item + "Samples"}))
				.stringColor_(Color.black).background_(d.colHighlight)
				.value_(d.arrBufLengthPresets.flop.slice(1).indexOfEqual(d.bufLength))
				.action_({arg view;
					d.bufLength = d.arrBufLengthPresets.flop.slice(1)[view.value];
					d.allocUpdateBuffers;
				}),
				nil, // spacer
				// File format popup
				PopUpMenu()
				.minWidth_(190).maxWidth_(190).minHeight_(20).maxHeight_(20)
				.items_(d.arrSaveFormats.collect({ arg item; "File Format: " + item[0]}))
				.stringColor_(Color.black).background_(d.colHighlight)
				.value_(d.saveFormatIndex)
				.action_({arg view;
					d.saveFormatIndex = view.value;
				}),
				nil, // spacer
				// Load defaults button
				StaticText().string_("Default Settings").align_(\center)
				.minWidth_(100).maxWidth_(100).minHeight_(20).maxHeight_(20)
				.stringColor_(Color.white).background_(d.colButton)
				.mouseDownAction_({d.setDefaultFormat}),
			).spacing_(8),
			HLayout(  // Row of controls
				guiData.playWaveformBtn,
				// stop button
				StaticText().string_("Stop")
				.minWidth_(42).maxWidth_(42)
				.minHeight_(22).maxHeight_(22).align_(\center)
				.stringColor_(Color.white).background_(d.colStop)
				.mouseDownAction_({d.stopSynth; d.updatePlayButtons;}),
				// checkbox
				Button().states_([
					["[ ] Pulsing", d.colButton, Color.white],
					["[X] Pulsing", Color.white, d.colButton]])
				.minWidth_(74).maxWidth_(74).minHeight_(22).maxHeight_(22)
				.action_({arg view;
					var val = view.value.asBoolean;
					d.pulsing = val;
					d.rebuildSynth;
				})
				.value_(d.pulsing.binaryValue),
				// checkbox
				Button().states_([
					["[ ] Add length to name", d.colButton, Color.white],
					["[X] Add length to name", Color.white, d.colButton]])
				.minWidth_(140).maxWidth_(140).minHeight_(22).maxHeight_(22)
				.action_({arg view;
					var val = view.value.asBoolean;
					d.addBufLengthToFilename = val;
					d.rebuildSynth;
				})
				.value_(d.addBufLengthToFilename.binaryValue),
				nil, // spacer
				// Save Waveform button
				StaticText().string_("Save Waveform")
				.minWidth_(100).maxWidth_(100)
				.minHeight_(22).maxHeight_(22).align_(\center)
				.stringColor_(Color.white).background_(d.colSave)
				.mouseDownAction_({d.saveWaveform;}),
			).spacing_(8),
			HLayout(
				HLayout(
					// label
					StaticText().string_("Play Freq")
					.minWidth_(64).maxWidth_(64).maxHeight_(20).align_(\center)
					.stringColor_(d.colLabelString).background_(d.colLabel),
					// freq slider/numbox
					guiData.playFreqSlider,
					guiData.playFreqNumbox,
				).spacing_(2),
				nil, // spacer
				HLayout(
					// label
					StaticText().string_("Vol")
					.minWidth_(30).maxWidth_(30).maxHeight_(20).align_(\center)
					.stringColor_(d.colLabelString).background_(d.colLabel),
					// vol slider
					Slider().thumbSize_(8).orientation_(\horizontal)
					.minWidth_(100).maxWidth_(140).minHeight_(20).maxHeight_(20)
					.background_(Color.white).knobColor_(d.colButton)
					.action_({arg view;
						d.outLevel = view.value;
						d.synthNode.set(\outLevel, view.value);
						d.multiSynthNode.set(\outLevel, view.value);
					})
					.value_(d.outLevel),
				).spacing_(2),
			),
			// line
			View().minHeight_(1).maxHeight_(1).background_(d.colLabel),
			// Clipboards
			HLayout(
				// label
				StaticText().string_("Wavetable / Clipboards")
				.minHeight_(20).maxHeight_(20).align_(\center)
				.font_(guiData.titleFont)
				.stringColor_(d.colLabelString).background_(d.colLabel),
				// Delete All button
				StaticText().string_("Delete All")
				.minWidth_(70).maxWidth_(70)
				.minHeight_(20).maxHeight_(20).align_(\center)
				.stringColor_(Color.white).background_(d.colDeleteAll)
				.mouseDownAction_({
					if (d.multiSynthNode.notNil, {
						d.multiSynthNode.set(\gate, 0); d.multiSynthNode = nil;
					});
					d.clearAllClipboards;
				}),
			).spacing_(8),
			HLayout(*guiData.storeBtns).spacing_(4),
			HLayout(*guiData.loadBtns).spacing_(4),
			HLayout(*guiData.deleteBtns).spacing_(4),
			2,
			guiData.wavetableRow,
			// line
			View().minHeight_(1).maxHeight_(1).background_(d.colLabel),
			// Presets
			StaticText().string_("Presets").font_(guiData.titleFont)
			.minHeight_(20).maxHeight_(20).align_(\center)
			.stringColor_(d.colLabelString).background_(d.colLabel),
			guiData.presetView,
			// line
			View().minHeight_(1).maxHeight_(1).background_(d.colLabel),
			// Waveform plot or env actions
			guiData.lowerRightView,
			nil,  // spacer
		);  // end of right panel
	).spacing_(8);
	d.updatePlot;
	d.updatePlayButtons;
};
// end of d.makeGui
d.deferMakeGui = {
	{
		s.sync;
		{d.makeGui}.defer(0.05);
	}.forkIfNeeded(AppClock);
};
// help window
d.showHelpWindow = {
	{ // defer
		// create window if needed
		if (guiData.helpWindow.isNil, {
			guiData.helpWindow = Window(
				"Help for Wavetable Builder",
				Rect(0, 0, 640, 620),
				scroll: true
			).front;
			guiData.helpWindow.alwaysOnTop = d.alwaysOnTop;
			guiData.helpWindow.view.resize_(5);
			guiData.helpWindow.view.background_(Color.white);
			guiData.helpWindow.onClose_({
				guiData.helpWindow = nil;
			});
			StaticText(guiData.helpWindow, Rect(20, 20, 600, 590)).align_(\left)
			.stringColor_(d.colLabelString).background_(Color.white)
			.font_(Font("Helvetica", 12))
			.string_("Wavetable Builder\n\n"
++ "This app is for building single-cycle waveforms and wavetables containing 2-16 waveforms.\n"
++ "These can then be saved as sound files and used with wavetable synths.\n\n"

++ "Before starting, choose the Waveform Length and the File Format in the top right of the screen.\n\n"

++ "For building waveforms there are 2 different modes - Sines and Envelope:\n\n"

++ "In Sines mode, sine waves of different frequencies are mixed together to create the waveform. \n"
++ "You can set the frequencies, levels and phases of the sine waves.\n"
++ "There are a few Presets available for waveforms that use Sines mode to create some standard synth waveforms.\n\n"

++ "In Envelope mode, you create the waveform shape using points linked together. You can drag the points around or click in an empty space to add a new point.\n"
++ "For each point (apart from the last one) you can set the Type of line linking it to the next point. If you set the Type to Curve, you can set the curvature with a slider.\n"
++ "Smoothing can be set using the yellow popup menu above the envelope. This can reduce aliasing with sharp-edged waveforms.\n\n"

++ "In both Sines and Envelope modes, there are various panels with named Actions in them to change the waveform settings in various ways.\n\n"

++ "Use the Play Waveform button to hear the waveform while you are changing the controls.\n"
++ "Note: the sound will not change immediately when you are dragging sliders or envelope points, but only when the mouse button is released.\n"
++ "If the Pulsing switch is turned on, the sound level will pulse slowly in and out.\n\n"

++ "Once you have built a waveform, you can use the Save Waveform button to save it to a sound file. The 'Add length to name' switch will extend the given file name by adding the waveform length to the end.\n\n"

++ "16 clipboards are available for storing waveforms temporarily. Once stored, a load button will restore all the settings for the stored waveform.\n\n"

++ "Once you have stored at least 2 waveforms in clipboards, wavetable controls will be shown below the clipboard buttons.\n"
++ "Play Wavetable uses the Position slider to morph between the different stored waveforms.\n"
++ "Save Wavetable joins all the stored waveforms together and saves them to a sound file.\n");
		}, {
			guiData.helpWindow.front;
		});
	}.defer;
};
//
// ============ start up ============
//
// start server if needed
s = Server.default;
if (s.serverRunning.not, {s.boot});
s.doWhenBooted({
	fork{
		// allocate buffers
		d.allocateBuffers;
		s.sync;
		// init vals
		d.setDefaultSineArrays;
		d.setDefaultPoints;
		// start gui
		d.deferMakeGui;
		{ // delayed
			d.updateBufPlot;
		}.defer(0.1);
	};
});
"---  Starting Wavetable Builder ...".postln;
"";
)
