(
s.reboot {
    s.options.numBuffers = 1024 * 256; // increase this if you need to load more samples
    s.options.memSize = 8192 * 32; // increase this if you get "alloc failed" messages
    s.options.numWireBufs = 64; // increase this if you get "exceeded number of interconnect buffers" messages
    s.options.maxNodes = 1024 * 32; // increase this if you are getting drop outs and the message "too many nodes"
    s.options.numOutputBusChannels = 2; // set this to your hardware output channel size, if necessary
    s.options.numInputBusChannels = 2; // set this to your hardware output channel size, if necessary
    // boot the server and start SuperDirt

	// adjust here if you use something else
	s.options.inDevice = "Default";
	s.options.outDevice = "Default";

    ~mlFile   = thisProcess.argv[0];
    ~spatFile = thisProcess.argv[1];
	~moduleFiles = thisProcess.argv[2..];

    s.waitForBoot {

        if (~spatFile.notNil and: {~spatFile != "!" }) {
            ~dirt = SuperDirt(8, s);
        }
        {
            ~dirt = SuperDirt(2, s);
        };

        ~dirt.loadSoundFiles;   // load samples (path containing a wildcard can be passed in)
		~dirt.loadSynthDefs;
		~dirt.startSendRMS;
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

OSCFunc({|msg| msg.postln; }, 'status.reply', s.addr);
s.status;
);

s.doWhenBooted(onComplete: {

    if (~mlFile.notNil and: { ~mlFile != "!"  } ) {
        ("Loading ML file: " ++ ~mlFile).postln;
        if (File.exists(~mlFile)) {
            Require(~mlFile.standardizePath);
        } {
            ("ERROR: ML file not found: " ++ ~mlFile).warn;
        };
    };

    s.sync;

    // Load Spat file if provided
    if (~spatFile.notNil and: { ~spatFile != "!" } ) {
        ("Loading Spat file: " ++ ~spatFile).postln;
        if (File.exists(~spatFile)) {
            Require(~spatFile.standardizePath);
        } {
            ("ERROR: Spat file not found: " ++ ~spatFile).warn;
        };
    };

    s.sync;

    // Load Module files if provided
    if (~moduleFiles.notNil and: { ~moduleFiles.size > 0 }) {
        ~moduleFiles.do { |module|
            if (module.notNil and: { module != "!" }) {
                ("Loading Module file: " ++ module).postln;
                if (File.exists(module)) {
                    Require(module.standardizePath);
                    s.sync;
                } {
                    ("ERROR: Module file not found: " ++ module).warn;
                };
            };
        };
    };

    "=== All files loaded ===".postln;
});