(
fork {
    s.options.numWireBufs = 256 * 64; // start high — see note below
    s.options.memSize = 8192 * 32;
    s.options.numInputBusChannels = 2;
    s.options.numOutputBusChannels = 20;
    s.sync;
    // NOTE: options only take effect on (re)boot — see below

    ~folder = PathName("/Users/ilia_viazov/Desktop/Projects/tusa/config-util/spat/iko/IKO001020");
    ~files = ~folder.files.select({ |f| f.extension == "wav" });
    ~files = ~files.sort({ |a, b|
        var numA, numB;
        numA = a.fileNameWithoutExtension.findRegexp("In(\\d+)")[1][1].asInteger;
        numB = b.fileNameWithoutExtension.findRegexp("In(\\d+)")[1][1].asInteger;
        numA < numB;
    });

    ~numSH = 16;
    ~numDrivers = 20;

    ~irBuffers = Array.fill(~numSH, { |i|
        Array.fill(~numDrivers, { |j|
            Buffer.readChannel(s, ~files[i].fullPath, channels: [j]);
        });
    });

    s.sync; // NOW this actually blocks, because we're inside a Routine

    ~fftSize = 512;

    SynthDef(\spatIKO, { |out = 0, in = 0|
        var sig, hoa, drivers;
        sig = Pulse.ar((1..2));
        hoa = sig.collect({ |sg, i|
            HoaEncodeDirection.ar(sg, theta: LFSaw.kr(1).bipolar(pi), phi: 0, radius: 0.1, order: 3);
        });
        hoa = hoa.sum / hoa.size.sqrt;

        drivers = Array.fill(~numDrivers, { |j|
            var sum = 0;
            ~numSH.do({ |i|
                sum = sum + Convolution2L.ar(
                    hoa[i],
                    ~irBuffers[i][j].bufnum,
                    trigger: 1,
                    framesize: ~fftSize
                );
            });
            sum;
        });

        ReplaceOut.ar(out, Limiter.ar(drivers));
    }).add;

    s.sync; // wait for SynthDef compile to finish server-side

    x = Synth.after(s, \spatIKO);
};
)

s.meter
