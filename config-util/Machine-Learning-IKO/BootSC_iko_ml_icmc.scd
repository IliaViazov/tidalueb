(
s.reboot { // server options are only updated on reboot
    // configure the sound server: here you could add hardware specific options
    // see http://doc.sccode.org/Classes/ServerOptions.html
	s.options.sampleRate = 44100;
    s.options.numBuffers = 1024 * 256; // increase this if you need to load more samples
    s.options.memSize = 8192 * 128; // increase this if you get "alloc failed" messages
    s.options.numWireBufs = 128; // increase this if you get "exceeded number of interconnect buffers" messages
    s.options.maxNodes = 1024 * 64; // increase this if you are getting drop outs and the message "too many nodes"
    s.options.numOutputBusChannels = 66; // set this to your hardware output channel size, if necessary
    s.options.numInputBusChannels = 64; // set this to your hardware output channel size, if necessary
    // boot the server and start SuperDirt

	// adjust here if you use something else
	s.options.inDevice = "Default";
	s.options.outDevice = "Default";
	s.volume = -12;

    s.waitForBoot {
        ~dirt = SuperDirt(8, s); // two output channels, increase if you want to pan across more channels
        ~dirt.loadSoundFiles;   // load samples (path containing a wildcard can be passed in)
		~dirt.loadSynthDefs;
        // for example: ~dirt.loadSoundFiles("/Users/myUserName/Dirt/samples/*");
        // s.sync; // optionally: wait for samples to be read
        ~dirt.start(57120, 0 ! 12);   // start listening on port 57120, create two busses each sending audio to channel 0

        // optional, needed for convenient access from sclang:
        (
            ~d1 = ~dirt.orbits[0]; ~d2 = ~dirt.orbits[1]; ~d3 = ~dirt.orbits[2];
            ~d4 = ~dirt.orbits[3]; ~d5 = ~dirt.orbits[4]; ~d6 = ~dirt.orbits[5];
            ~d7 = ~dirt.orbits[6]; ~d8 = ~dirt.orbits[7]; ~d9 = ~dirt.orbits[8];
            ~d10 = ~dirt.orbits[9]; ~d11 = ~dirt.orbits[10]; ~d12 = ~dirt.orbits[11];
        );
		///here is the ML
		(
			~src = Buffer.read(
				s,
				"/Users/ilia_viazov/Desktop/Projects/documentation/room-playing/serge/serge.wav"
			);

			~normed = FluidDataSet(s);
			~normed.read("/Users/ilia_viazov/Desktop/Projects/tusa/config-util/Machine-Learning-IKO/temp_dataset.json");

			~indices = Buffer.read(s, "/Users/ilia_viazov/Desktop/Projects/tusa/config-util/Machine-Learning-IKO/indices.wav");

			~tree = FluidKDTree(s);
			~tree.fit(~normed);


			~position = Buffer.alloc(s, 2, 1);
			~sliceBus = Bus.control(s, 1);
		);
		s.sync;
	///here the spat, the buses are for future, don't use now but I wouldnt like to program it again later, so it should be here
		s.newBusAllocators;
    ~a = Bus.control(s, 1);
    ~b = Bus.control(s, 1);
    SynthDef(\spat, {
        arg aBus = 0, bBus = 1, in_bus = 0;
        var sig, a, b;
        a = In.kr(aBus, 1);
        b = In.kr(bBus, 1);
		sig = [SoundIn.ar(30),SoundIn.ar(31),SoundIn.ar(32),SoundIn.ar(33),SoundIn.ar(34),SoundIn.ar(35),SoundIn.ar(36),SoundIn.ar(37)];
        sig = VSTPlugin.ar(
            sig,
            16,
            id: \ambix,
			params: [3, 0.875]
        );
        sig = VSTPlugin.ar(
            sig,
            20,
            id: \mcfx
        );
		Out.ar(32, Limiter.ar(sig));
		Out.ar(64, sig.sum/20.0);
    }).add;
    s.sync;
    ~spat = Synth(\spat, [
        \aBus, ~a.index,
        \bBus, ~b.index
    ], target: s);
    ~ambix = VSTPluginController(~spat, \ambix);
    ~mcfx  = VSTPluginController(~spat, \mcfx);
    ~ambix.open("ambix_encoder_i8_o3", editor: true);
    ~mcfx.open("mcfx_convolver24", editor: true);
	s.sync;
	~mcfx.readProgram("/Users/ilia_viazov/Desktop/Projects/tusa/config-util/Machine-Learning-IKO/test.vstpreset");
};

OSCFunc({|msg| msg.postln}, 'status.reply', s.addr);
s.status;

    s.latency = 0.3; // increase this if you get "late" messages

	s.doWhenBooted(onComplete: {
	5.wait;
	(
/*
n - play slice in history order
pan - pan
rate - rate of Buffer phaser
freq - frequency of lfo to start position
lfo - amount of modulation
*/
SynthDef(\sergeXY, { |out = 0, gain = 0.2, sliceBus = 128, n=0, pan, rate = 1, freq = 0, lfo = 0 |
    var sliceIndex, start, end, phs, sig;

    sliceIndex = In.kr(~sliceBus).clip(0, ~indices.numFrames - 2);

    start = BufRd.kr(1, ~indices, sliceIndex + n, interpolation: 1);
    end   = BufRd.kr(1, ~indices, sliceIndex + 1 + n, interpolation: 1);

    phs = Phasor.ar(
        trig: 0,
        rate: (BufRateScale.ir(~src)*rate),
				start: start+(SinOsc.kr(freq)*lfo*(end-start)),
        end: end
    );

    sig = BufRd.ar(2, ~src, phs, loop: 1, interpolation: 4);
    sig = (sig * gain * 10).tanh;

    Out.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;
);

(
(
{
    BufWr.kr(MouseX.kr(0, 1), ~position, 0);
    BufWr.kr(MouseY.kr(0, 1), ~position, 1);
}.play;
);

(
~knnRoutine = Routine {
    loop {
        ~tree.kNearest(~position, 1, { |nearest|
            var sliceIndex;

            // nearest is a Symbol like '1907'
            sliceIndex = nearest.asInteger;

            ~sliceBus.set(sliceIndex);
        });

        0.02.wait;
    }
}.play;
);
);
});

s.meter;

});

s.scope