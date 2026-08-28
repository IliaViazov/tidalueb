s.options.numOutputBusChannels = 20;
s.options.blockSize_(64);
s.volume                       = -7;

s.sync;

~numChans = 20;
~order = 3; 

//optimize over total \energy or its \spreadE for spherical design
~optimize = 'energy';

//basic, energy, controlled
//hyper-cardioid, super-cardioid, cardioid
~beamShape = 'basic';
~match = 'beam'

// design spherical design & decoder
~directions = TDesign.newHoa(~numChans, ~optimize, 2).directions;
~decoder = HoaMatrixDecoder.newDirections(~directions, ~beamShape, ~match, ~order);

// TDesign.newHoa(~numChans, ~optimize, 2).visualize
s.sync;

SynthDef(\spat, { 
    arg out, azimuth, elevation, spreadAz, spreadEl, radius;
    var sigs;

    azimuth = In.kr(azimuth, 1).range(pi, -pi);
    elevation = In.kr(elevation, 1).range(pi, -pi);
    spreadAz = In.kr(spreadAz, 1).range(0, 45);
    spreadEl = In.kr(spreadEl, 1).range(0, 45);
    radius = In.kr(radius, 1).range(0.1, 1.5);

    sigs = In.ar(out, 8); //8channel input
    
    //encode 8channel to 8x16 matrix of HOA
    sigs = sigs.collect({
        |sig, i|
        var theta = (i*spreadAz).degrad+azimuth;
        var phi = (i*spreadEl).degrad+elevation;
        HoaEncodeDirection.ar(sig, theta: theta, phi: phi, radius: radius, order: 3);
    });
    //Sum this matrix into a normalized 16ch HOA signal
    sigs = sigs.sum / sigs.size.sqrt;
    sigs = HoaDecodeMatrix.ar(sigs, ~decoder);
    ReplaceOut.ar(out, Limiter.ar(sigs));
}).add;

s.sync;

~spat  = Synth.after(s, \spat, [\out, 0]);
