s.reboot;

(
~src = Buffer.read(
    s,
    "/Users/ilia_viazov/Desktop/Projects/documentation/room-playing/serge/serge.wav"
);

~normed = FluidDataSet(s);
~normed.read("/Users/ilia_viazov/Desktop/Projects/tcii/temp_dataset.json");

~indices = Buffer.read(s, "/Users/ilia_viazov/Desktop/Projects/tcii/indices.wav");

~tree = FluidKDTree(s);
~tree.fit(~normed);


~position = Buffer.alloc(s, 2, 1);
~sliceBus = Bus.control(s, 1);
)

(
SynthDef(\sergeXY, { |out = 0, gain = 0.2, sliceBus = 128, pan|
    var sliceIndex, start, end, phs, sig;

    sliceIndex = In.kr(sliceBus).clip(0, ~indices.numFrames - 2);

    start = BufRd.kr(1, ~indices, sliceIndex, interpolation: 1);
    end   = BufRd.kr(1, ~indices, sliceIndex + 1, interpolation: 1);

    phs = Phasor.ar(
        trig: 0,
        rate: BufRateScale.ir(~src),
        start: start,
        end: end
    );

    sig = BufRd.ar(2, ~src, phs, loop: 1, interpolation: 4);
    sig = (sig * gain * 10).tanh;
	SendReply.kr(
        Impulse.kr(100),   // trigger rate
        '/label',        // OSC address
        sliceIndex);

    Out.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
}).add;


OSCdef(\send, { |msg|
    var blobData, ints;

    // msg[3] is the BLOB
    blobData = msg[3];  // this is a ByteString

    // Convert to an array of integers
    ints = blobData;

    // Send to another OSC target
    NetAddr("127.0.0.1", 3000).sendMsg("/label", ints);
}, '/label');

)

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

x = Synth(\sergeXY)