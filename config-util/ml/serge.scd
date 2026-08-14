~src     = Buffer.read(s, "/Users/ilia_viazov/Desktop/Projects/documentation/room-playing/serge/serge.wav");
~indices = Buffer.read(s, "/Users/ilia_viazov/Desktop/Projects/tusa/config-util/ml/serge/indices.wav");

~normed  = FluidDataSet(s);
~normed.read("/Users/ilia_viazov/Desktop/Projects/tusa/config-util/ml/serge/temp_dataset.json");

~tree = FluidKDTree(s);
~tree.fit(~normed);

~knnQuant = Buffer.alloc(s, 1, 1);
~position = Buffer.alloc(s, 2, 1);
~sliceBus = Bus.control(s, 1);

10.yield();

s.sync;

SynthDef(\sergeXY, { |out = 0, gain = 0.2, n = 0, pan,
                          rate = 1, freq = 0, lfo = 0, x = 0, y = 0, k = 4, mX = 1.0, mY = 1.0|
    var sliceIndex, start, end, phs, sig;
    var xQue, yQue;

    sliceIndex = In.kr(~sliceBus).clip(0, ~indices.numFrames - 2);

    xQue = (MouseX.kr(0, 1) * mouseX) + (x * (1 - mouseX));
    yQue = (MouseY.kr(0, 1) * mouseY) + (y * (1 - mouseY));

    BufWr.kr(kNN, ~knnQuant, 0);
    BufWr.kr(xQue, ~position, 0);
    BufWr.kr(yQue, ~position, 1);

    start = BufRd.kr(1, ~indices, sliceIndex + n,         interpolation: 1);
    end   = BufRd.kr(1, ~indices, sliceIndex + 1 + n,     interpolation: 1);

    phs = Phasor.ar(
        trig:  0,
        rate:  BufRateScale.ir(~src) * rate,
        start: start + (SinOsc.kr(freq) * lfo * (end - start)),
        end:   end
    );

    sig = BufRd.ar(2, ~src, phs, loop: 1, interpolation: 4);
    sig = (sig * gain * 10).tanh;
    Out.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;

s.sync;

~knnRoutine = Routine {
    loop {
        ~knnQuant.getn(0, 1, { |val|
            val[0].asInteger.postln;
            ~tree.kNearest(~position, val[0].asInteger.max(1), { |nearest|
                ~sliceBus.set(nearest.asInteger);
            });
        });
        0.02.wait;
    }
}.play;
