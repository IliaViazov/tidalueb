(
s.reboot {
    s.options.sampleRate           = 44100;
    s.options.numBuffers           = 1024 * 256;
    s.options.memSize              = 8192 * 128;
    s.options.numWireBufs          = 128;
    s.options.maxNodes             = 1024 * 64;
    s.options.numOutputBusChannels = 64;
    s.options.numInputBusChannels  = 64;
    s.options.blockSize_(64);
    s.options.inDevice             = "Default";
    s.options.outDevice            = "Default";
    s.latency                      = 0.3;
    s.volume                       = -7;

    s.waitForBoot {
        var root, mlFlag, spatFile;

        // this file lives in config-util/core/, project root is two levels up
        root = thisProcess.nowExecutingPath.dirname +/+ "..";

        // SuperDirt — every session needs this, regardless of ml/spat choices
        ~dirt = SuperDirt(8, s);
        ~dirt.loadSoundFiles;
        ~dirt.loadSynthDefs;
        ~dirt.start(57120, 0 ! 12);

        ~d1  = ~dirt.orbits[0];  ~d2  = ~dirt.orbits[1];  ~d3  = ~dirt.orbits[2];
        ~d4  = ~dirt.orbits[3];  ~d5  = ~dirt.orbits[4];  ~d6  = ~dirt.orbits[5];
        ~d7  = ~dirt.orbits[6];  ~d8  = ~dirt.orbits[7];  ~d9  = ~dirt.orbits[8];
        ~d10 = ~dirt.orbits[9];  ~d11 = ~dirt.orbits[10]; ~d12 = ~dirt.orbits[11];

        s.sync;

        // Read what the launcher script decided, and pull in only those modules.
        // TUSA_ML: "1" if the ML pane was requested, otherwise unset/empty.
        // TUSA_SPAT: absolute path to the chosen modules/spat/*.scd file, or empty.
        mlFlag   = "TUSA_ML".getenv;
        spatFile = "TUSA_SPAT".getenv;

        if (mlFlag == "1") {
            Require((root +/+ "modules/ml.scd").standardizePath);
        };

        if (spatFile.notNil and: { spatFile != "" }) {
            Require(spatFile.standardizePath);
        };
    };

    OSCFunc({ |msg| msg.postln }, 'status.reply', s.addr);
    s.status;
};
)
