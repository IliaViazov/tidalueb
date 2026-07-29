(
s.reboot { // server options are only updated on reboot
	// configure the sound server: here you could add hardware specific options
	// see http://doc.sccode.org/Classes/ServerOptions.html
	s.options.numBuffers = 1024 * 256; // increase this if you need to load more samples
	s.options.memSize = 8192 * 64; // increase this if you get "alloc failed" messages
	s.options.numWireBufs = 64; // increase this if you get "exceeded number of interconnect buffers" messages
	s.options.maxNodes = 1024 * 32; // increase this if you are getting drop outs and the message "too many nodes"
	s.options.numOutputBusChannels = 2; // set this to your hardware output channel size, if necessary
	s.options.numInputBusChannels = 2; // set this to your hardware output channel size, if necessary
	// boot the server and start SuperDirt
	s.options.maxLogins = 2;
	// adjust here if you use something else
	s.options.inDevice = "Default";
	s.options.outDevice = "Default";
	s.options.bindAddress = "0.0.0.0";

	s.waitForBoot {
		~dirt = SuperDirt(2, s); // two output channels, increase if you want to pan across more channels
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
		(
			~src = Buffer.read(
				s,
				"/Users/ilia_viazov/Desktop/Projects/documentation/room-playing/serge/serge.wav"
			);

			~normed = FluidDataSet(s);
			~normed.read("/Users/ilia_viazov/Desktop/Projects/tusa/config-util/Machine-Learning-IKO/temp_dataset.json");

			~indices = Buffer.read(s, "/Users/ilia_viazov/Desktop/Projects/tusa/config-util/Machine-Learning-IKO/indices.wav");

			~tree1 = FluidKDTree(s);
			~tree1.fit(~normed);

			~tree2 = FluidKDTree(s);
			~tree2.fit(~normed);

			~tree3 = FluidKDTree(s);
			~tree3.fit(~normed);

			~tree4 = FluidKDTree(s);
			~tree4.fit(~normed);


			~position1 = Buffer.alloc(s, 2, 1);
			~sliceBus1 = Bus.control(s, 1);
			~position2 = Buffer.alloc(s, 2, 1);
			~sliceBus2 = Bus.control(s, 1);
			~position3 = Buffer.alloc(s, 2, 1);
			~sliceBus3 = Bus.control(s, 1);
			~position4 = Buffer.alloc(s, 2, 1);
			~sliceBus4 = Bus.control(s, 1);
		);
	};


	s.latency = 0.3;
	OSCFunc({|msg| msg.postln}, 'status.reply', s.addr);
	s.status;// increase this if you get "late" messages
};
);


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
		SynthDef(\serge1, { |out = 0, gain = 0.2, sliceBus = 128, n=0, pan, rate = 1, freq = 0, lfo = 0, x = 0, y = 0, mouse = 0, index = 0 |
			var sliceIndex, start, end, phs, sig;

			sliceIndex = In.kr(~sliceBus1).clip(0, ~indices.numFrames - 2);

			start = BufRd.kr(1, ~indices, sliceIndex + n, interpolation: 1);
			end   = BufRd.kr(1, ~indices, sliceIndex + 1 + n, interpolation: 1);

			phs = Phasor.ar(
				trig: 0,
				rate: (BufRateScale.ir(~src)*rate),
				start: start+(SinOsc.kr(freq)*lfo*(end-start)),
				end: end
			);

			BufWr.kr(MouseX.kr(0, 1) * mouse + x, ~position1, 0);
			BufWr.kr(MouseY.kr(0, 1) * mouse + y, ~position1, 1);

			sig = BufRd.ar(2, ~src, phs, loop: 1, interpolation: 4);
			sig = (sig * gain * 10).tanh;

			Out.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
		}).add;

		SynthDef(\serge2, { |out = 0, gain = 0.2, sliceBus = 129, n=0, pan, rate = 1, freq = 0, lfo = 0, x = 0, y = 0, mouse = 0, index = 0 |
			var sliceIndex, start, end, phs, sig;

			sliceIndex = In.kr(~sliceBus2).clip(0, ~indices.numFrames - 2);

			start = BufRd.kr(1, ~indices, sliceIndex + n, interpolation: 1);
			end   = BufRd.kr(1, ~indices, sliceIndex + 1 + n, interpolation: 1);

			phs = Phasor.ar(
				trig: 0,
				rate: (BufRateScale.ir(~src)*rate),
				start: start+(SinOsc.kr(freq)*lfo*(end-start)),
				end: end
			);

			BufWr.kr(MouseX.kr(0, 1) * mouse + x, ~position2, 0);
			BufWr.kr(MouseY.kr(0, 1) * mouse + y, ~position2, 1);

			sig = BufRd.ar(2, ~src, phs, loop: 1, interpolation: 4);
			sig = (sig * gain * 10).tanh;

			Out.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
		}).add;

		SynthDef(\serge3, { |out = 0, gain = 0.2, sliceBus = 130, n=0, pan, rate = 1, freq = 0, lfo = 0, x = 0, y = 0, mouse = 0, index = 0 |
			var sliceIndex, start, end, phs, sig;

			sliceIndex = In.kr(~sliceBus3).clip(0, ~indices.numFrames - 2);

			start = BufRd.kr(1, ~indices, sliceIndex + n, interpolation: 1);
			end   = BufRd.kr(1, ~indices, sliceIndex + 1 + n, interpolation: 1);

			phs = Phasor.ar(
				trig: 0,
				rate: (BufRateScale.ir(~src)*rate),
				start: start+(SinOsc.kr(freq)*lfo*(end-start)),
				end: end
			);

			BufWr.kr(MouseX.kr(0, 1) * mouse + x, ~position3, 0);
			BufWr.kr(MouseY.kr(0, 1) * mouse + y, ~position3, 1);

			sig = BufRd.ar(2, ~src, phs, loop: 1, interpolation: 4);
			sig = (sig * gain * 10).tanh;

			Out.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
		}).add;

		SynthDef(\serge4, { |out = 0, gain = 0.2, sliceBus = 131, n=0, pan, rate = 1, freq = 0, lfo = 0, x = 0, y = 0, mouse = 0, index = 0 |
			var sliceIndex, start, end, phs, sig;

			sliceIndex = In.kr(~sliceBus4).clip(0, ~indices.numFrames - 2);

			start = BufRd.kr(1, ~indices, sliceIndex + n, interpolation: 1);
			end   = BufRd.kr(1, ~indices, sliceIndex + 1 + n, interpolation: 1);

			phs = Phasor.ar(
				trig: 0,
				rate: (BufRateScale.ir(~src)*rate),
				start: start+(SinOsc.kr(freq)*lfo*(end-start)),
				end: end
			);

			BufWr.kr(MouseX.kr(0, 1) * mouse + x, ~position4, 0);
			BufWr.kr(MouseY.kr(0, 1) * mouse + y, ~position4, 1);

			sig = BufRd.ar(2, ~src, phs, loop: 1, interpolation: 4);
			sig = (sig * gain * 10).tanh;

			Out.ar(out, DirtPan.ar(sig, ~dirt.numChannels, pan));
		}).add;

		s.sync;
	);

	(

		(
			~knnRoutine = Routine {
				loop {
					~tree1.kNearest(~position1, 1, { |nearest|
						var sliceIndex;

						// nearest is a Symbol like '1907'
						sliceIndex = nearest.asInteger;

						~sliceBus1.set(sliceIndex);
					});

					~tree2.kNearest(~position2, 1, { |nearest|
						var sliceIndex;

						// nearest is a Symbol like '1907'
						sliceIndex = nearest.asInteger;

						~sliceBus2.set(sliceIndex);
					});

					~tree3.kNearest(~position3, 1, { |nearest|
						var sliceIndex;

						// nearest is a Symbol like '1907'
						sliceIndex = nearest.asInteger;

						~sliceBus3.set(sliceIndex);
					});

					~tree4.kNearest(~position4, 1, { |nearest|
						var sliceIndex;

						// nearest is a Symbol like '1907'
						sliceIndex = nearest.asInteger;

						~sliceBus4.set(sliceIndex);
					});

					0.02.wait;
				}
			}.play;
		);
	);
});