
s.options.numOutputBusChannels = 20;
s.options.blockSize_(64);
s.volume                       = -7;

s.sync;

SynthDef(\spat, { 
    arg out;
    var sig;
    sig = In.ar(out, 8);
    sig = VSTPlugin.ar(sig, 16, id: \ambix, params: [3, 0.875]);
    sig = VSTPlugin.ar(sig, 20, id: \mcfx);
    ReplaceOut.ar(out, Limiter.ar(sig));
}).add;

s.sync;

~spat  = Synth.after(s, \spat, [\out, 0]);
~ambix = VSTPluginController(~spat, \ambix);
~mcfx  = VSTPluginController(~spat, \mcfx);
~ambix.open("ambix_encoder_i8_o3", editor: true);
~mcfx.open("mcfx_convolver24", editor: true);

s.sync;

~mcfx.readProgram("/Users/ilia_viazov/Desktop/Projects/tusa/config-util/spat/iko/test.vstpreset");

s.sync;

s.meter;
