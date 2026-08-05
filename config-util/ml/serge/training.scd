~src = FluidLoadFolder(Quarks.folder ++ "/Dirt-Samples/print").play;
~src = ~src.buffer;

~src = Buffer.read(s, "/Users/ilia_viazov/Desktop/Projects/documentation/room-playing/serge/serge.wav");

(
{
	var sig = PlayBuf.ar(1, ~src,loop:  1);
	var slices = FluidOnsetSlice.ar(sig,metric: 9,threshold: 0.5);
	[sig, slices]
}.play;
)

(
~indices = Buffer(s);
FluidBufOnsetSlice.processBlocking(s, ~src, metric: 9, threshold: 0.5, indices: ~indices, action: {"done".postln});
)

(
~indices.loadToFloatArray(action: {
	arg fa;
	fa.postln;
	fa.size.postln;
});
)

FluidWaveform(~src, ~indices);

(
~play_slice = {
	arg index;
	{
		var startsamp = Index.kr(~indices,index);
		var stopsamp = Index.kr(~indices,index+1);
		var phs = Phasor.ar(0,BufRateScale.ir(~src),startsamp,stopsamp);
		var sig = BufRd.ar(1,~src,phs);
		var dursecs = (stopsamp - startsamp) / BufSampleRate.ir(~src);
		var env = EnvGen.kr(Env([0,1,1,0],[0.03,dursecs-0.06,0.03]),doneAction:2);
		sig.dup * env;
	}.play;
};
)



(
fork {
	(~indices.numFrames - 1).do{
		arg i;
		~play_slice.(i);
		1.wait;
	};
}
)

~play_slice.(1);



//analysis

(
~analyses = FluidDataSet(s);
~indices.loadToFloatArray(action: {
	arg fa;
	var spec = Buffer(s);
	var stats = Buffer(s);
	var stats2 = Buffer(s);
	var loudness = Buffer(s);
	var point = Buffer(s);

	//takes pares [0, 1], [1, 2] etc
	fa.doAdjacentPairs{
		//parces us frame borders and index i
		arg start, end, i;
		var num = end - start;
		start.postln;
		end.postln;
		i.postln;

		//take the source buffer, and analyse it with spectral centroid by given frame borders, write into the buffer called spec
		FluidBufSpectralShape.processBlocking(s, ~src, start, num, features:spec, select: [\centroid]);
		//take the specs and calculate the mean of spectral centroid over the length of a sample and write it into the stats. Reducing to a single value because array could be of different shape
		FluidBufStats.processBlocking(s, spec, stats: stats, select:[\mean]);
		//the same process
		FluidBufLoudness.processBlocking(s, ~src, start, num, features: loudness, select:[\loudness]);
		FluidBufStats.processBlocking(s, loudness, stats: stats2, select:[\mean]);

		FluidBufCompose.processBlocking(s, stats, destination:point, destStartFrame:0);

		FluidBufCompose.processBlocking(s, stats2, destination:point, destStartFrame:1);

		~analyses.addPoint(i, point);
	};

	s.sync;

	~analyses.print; //lives on the server, not in the language
});
)

(
~normed = FluidDataSet(s);
FluidNormalize(s).fitTransform(~analyses, ~normed);
)

~tree = FluidKDTree(s);
~tree.fit(~normed);

~normed.write(Platform.defaultTempDir+/+"temp_dataset.json")

Platform.defaultTempDir+/+"temp_dataset.json"
(
~normed.dump({
	arg dict;
	var point = Buffer.alloc(s,2);
	var previous = nil;
	dict.postln;
	defer {
		FluidPlotter(dict: dict, mouseMoveAction: {
			arg view, x, y;
			[x,y].postln;
			point.setn(0, [x,y]);

			~tree.kNearest(point, 1, {
				arg nearest;
				if(nearest != previous){
				nearest.postln;
				view.highlight_(nearest);
				~play_slice.(nearest.asInteger);
				previous = nearest;
				}
			});
		});
	}
});
)
