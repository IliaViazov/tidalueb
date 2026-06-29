(
s.reboot {
    s.options.sampleRate           = 44100;
    s.options.numBuffers           = 1024 * 256;
    s.options.memSize              = 8192 * 128;
    s.options.numWireBufs          = 128;
    s.options.maxNodes             = 1024 * 64;
    s.options.numOutputBusChannels = 64;
    s.options.numInputBusChannels  = 64;
    s.options.inDevice             = "Default";
    s.options.outDevice            = "Default";
    s.latency                      = 0.3;
    s.volume                       = -9;

    s.waitForBoot {
        // SuperDirt
        ~dirt = SuperDirt(8, s);
        ~dirt.loadSoundFiles;
        ~dirt.loadSynthDefs;
        ~dirt.start(57120, 0 ! 12);

        ~d1  = ~dirt.orbits[0];  ~d2  = ~dirt.orbits[1];  ~d3  = ~dirt.orbits[2];
        ~d4  = ~dirt.orbits[3];  ~d5  = ~dirt.orbits[4];  ~d6  = ~dirt.orbits[5];
        ~d7  = ~dirt.orbits[6];  ~d8  = ~dirt.orbits[7];  ~d9  = ~dirt.orbits[8];
        ~d10 = ~dirt.orbits[9];  ~d11 = ~dirt.orbits[10]; ~d12 = ~dirt.orbits[11];

        // ML
        ~src     = Buffer.read(s, "/Users/ilia_viazov/Desktop/Projects/documentation/room-playing/serge/serge.wav");
        ~indices = Buffer.read(s, "/Users/ilia_viazov/Desktop/Projects/tusa/config-util/Machine-Learning-IKO/indices.wav");

        ~normed = FluidDataSet(s);
        ~normed.read("/Users/ilia_viazov/Desktop/Projects/tusa/config-util/Machine-Learning-IKO/temp_dataset.json");

        ~tree = FluidKDTree(s);
        ~tree.fit(~normed);

        ~position = Buffer.alloc(s, 2, 1);
        ~sliceBus = Bus.control(s, 1);

        s.sync;

        // Spatialisation — ~a and ~b reserved for future use
        s.newBusAllocators;
        ~a = Bus.control(s, 1);
        ~b = Bus.control(s, 1);

        SynthDef(\spat, { |aBus = 0, bBus = 1|
            var sig;
            sig = SoundIn.ar([30, 31, 32, 33, 34, 35, 36, 37]);
            sig = VSTPlugin.ar(sig, 16, id: \ambix, params: [3, 0.875]);
            sig = VSTPlugin.ar(sig, 20, id: \mcfx);
            Out.ar(32, Limiter.ar(sig));
        }).add;

        s.sync;

        ~spat  = Synth(\spat, [\aBus, ~a.index, \bBus, ~b.index], target: s);
        ~ambix = VSTPluginController(~spat, \ambix);
        ~mcfx  = VSTPluginController(~spat, \mcfx);
        ~ambix.open("ambix_encoder_i8_o3", editor: true);
        ~mcfx.open("mcfx_convolver24", editor: true);

        s.sync;

        ~mcfx.readProgram("/Users/ilia_viazov/Desktop/Projects/tusa/config-util/Machine-Learning-IKO/test.vstpreset");
    };

    OSCFunc({ |msg| msg.postln }, 'status.reply', s.addr);
    s.status;
};
);

s.doWhenBooted(onComplete: {
    7.wait;

    /*
    n     - play slice in history order
    pan   - pan
    rate  - rate of Buffer phaser
    freq  - frequency of lfo to start position
    lfo   - amount of lfo modulation
    mouse - blend between mouse (1.0) and x/y args (0.0)
    x, y  - manual position when mouse = 0
    */
    SynthDef(\sergeXY, { |out = 0, gain = 0.2, sliceBus = 128, n = 0, pan,
                          rate = 1, freq = 0, lfo = 0, x = 0, y = 0, mouse = 1.0|
        var sliceIndex, start, end, phs, sig;
        var xQue, yQue;

        sliceIndex = In.kr(sliceBus).clip(0, ~indices.numFrames - 2);

        xQue = (MouseX.kr(0, 1) * mouse) + (x * (1 - mouse));
        yQue = (MouseY.kr(0, 1) * mouse) + (y * (1 - mouse));

        BufWr.kr(xQue, ~position, 0);
        BufWr.kr(yQue, ~position, 1);

        start = BufRd.kr(1, ~indices, sliceIndex + n,     interpolation: 1);
        end   = BufRd.kr(1, ~indices, sliceIndex + 1 + n, interpolation: 1);

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
            ~tree.kNearest(~position, 4, { |nearest|
                ~sliceBus.set(nearest.asInteger);
            });
            0.02.wait;
        }
    }.play;
});