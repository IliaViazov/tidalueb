(
s.reboot { // server options are only updated on reboot
    // configure the sound server: here you could add hardware specific options
    // see http://doc.sccode.org/Classes/ServerOptions.html
	s.options.sampleRate = 44100;
    s.options.numBuffers = 1024 * 256; // increase this if you need to load more samples
    s.options.memSize = 8192 * 64; // increase this if you get "alloc failed" messages
    s.options.numWireBufs = 64; // increase this if you get "exceeded number of interconnect buffers" messages
    s.options.maxNodes = 1024 * 32; // increase this if you are getting drop outs and the message "too many nodes"
    s.options.numOutputBusChannels = 8; // set this to your hardware output channel size, if necessary
    s.options.numInputBusChannels = 0; // set this to your hardware output channel size, if necessary
    // boot the server and start SuperDirt

	// adjust here if you use something else
	s.options.inDevice = "Default";
	s.options.outDevice = "Default";

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
		///here the spat

    };

    s.latency = 0.3; // increase this if you get "late" messages
};

r = Server.new('spat',NetAddr("127.0.0.1", 57111));
r.reboot {
	r.options.sampleRate = 44100;
    r.options.numBuffers = 1024 * 256; // increase this if you need to load more samples
    r.options.memSize = 8192 * 32; // increase this if you get "alloc failed" messages
    r.options.numWireBufs = 64; // increase this if you get "exceeded number of interconnect buffers" messages
    r.options.maxNodes = 1024 * 32; // increase this if you are getting drop outs and the message "too many nodes"
    r.options.numOutputBusChannels = 64; // set this to your hardware output channel size, if necessary
    r.options.numInputBusChannels = 64; // set this to your hardware output channel size, if necessary
    // boot the server and start SuperDirt

	// adjust here if you use something else
	r.options.inDevice = "Default";
	r.options.outDevice = "Default";
};
r.waitForBoot {
    r.newBusAllocators;
    ~a = Bus.control(s, 1);
    ~b = Bus.control(s, 1);
    SynthDef(\spat, {
        arg aBus = 0, bBus = 1;
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
    }).add;
    r.sync;
    ~spat = Synth(\spat, [
        \aBus, ~a.index,
        \bBus, ~b.index
    ], target: r);
    ~ambix = VSTPluginController(~spat, \ambix);
    ~mcfx  = VSTPluginController(~spat, \mcfx);
    ~ambix.open("ambix_encoder_i8_o3", editor: true);
    ~mcfx.open("mcfx_convolver24", editor: true);
	r.sync;
	~mcfx.readProgram("/Users/ilia_viazov/Desktop/Projects/tusa/config-util/Machine-Learning-IKO/test.vstpreset");
};

OSCFunc({|msg| msg.postln}, 'status.reply', s.addr);
s.status;
);
