{ {|i| SinOsc.ar(1 + i)}.dup(7) }.plot(1);

(
var root = 440;
{[
    SinOsc.ar(root),
    SinOsc.ar(root * 3 / 2)
]}.plot(0.05);
)

(
var size = 512;
var fct = Signal.fftCosTable(size);
var imag = Signal.newClear(size);
var real = Signal.sineFill(size, 3);
var complex = fft(real, imag, fct);

[
    real,
    imag,
    (complex.magnitude) / size
]
.plot("fft", Window.screenBounds.insetBy(*200!2))
.axisLabelX_(["Signal (real, samples)", "Signal (imaginary, samples)", "FFT spectrum (bins)"])
.axisLabelY_(["Amplitude", "Amplitude", "Magnitude"])
.plotMode_([\linear, \linear, \steps]);
)

