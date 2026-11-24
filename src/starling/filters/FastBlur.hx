package starling.filters;

import flash.display3D.Context3D;
import starling.rendering.FilterEffect;
import starling.rendering.Painter;
import starling.rendering.Program;
import starling.textures.Texture;

/**
	BlurFilter's passes in fewer draws. Starling blurs by `strength` texels in a pass of five samples, then
	by half of it, and so on down to one texel: five passes a direction for a blur of 12. Those passes are
	one convolution, by a kernel that is theirs convolved together; FastBlur draws it in one pass a
	direction, with one sample for each two texels of the kernel.

	A blur of more than `MAX_STRENGTH` texels would need too many samples: its input is first drawn
	smaller, by 2 or 4 a pass (each texel the mean of the texels it covers), and blurred there by the
	kernel of the strength divided likewise. The texture returned is then smaller than the input, as
	BlurFilter's is with a `resolution` under 1, and is drawn enlarged by whatever uses it.

	Up to `MAX_STRENGTH` the result is the passes' own, but for the rounding they do between passes.

	Off with `DRH_BLUR=stock`.
**/
@:access(starling.filters.FragmentFilter)
class FastBlur {
	/** The blur, in texels, one pass draws: 21 samples at most. **/
	public static inline final MAX_STRENGTH = 4.0;

	public static inline final MAX_PAIRS = 12;

	public static var enabled:Bool = Sys.getEnv("DRH_BLUR") != "stock";

	static var copy:FastBlurPass;

	static var quarter:FastBlurPass;

	static var blur:FastBlurPass;

	static final kernels:Map<Int, FastBlurKernel> = [];

	/** By how much the input is drawn smaller before it is blurred. **/
	static function factor(strengthX:Float, strengthY:Float, quality:Float):Int {
		var strength = (strengthX > strengthY ? strengthX : strengthY) / quality;
		var result = 1;
		while (strength / result > MAX_STRENGTH && result < 64) {
			result *= 2;
		}
		return result;
	}

	public static function numPasses(strengthX:Float, strengthY:Float, quality:Float):Int {
		var passes = (strengthX > 0 ? 1 : 0) + (strengthY > 0 ? 1 : 0);
		var left = factor(strengthX, strengthY, quality);
		while (left > 1) {
			left = left >= 4 ? left >> 2 : left >> 1;
			passes++;
		}
		return passes;
	}

	public static function process(painter:Painter, helper:IFilterHelper, input:Texture, strengthX:Float, strengthY:Float, quality:Float):Texture {
		if (blur == null) {
			copy = new FastBlurPass(FastBlurEffect.COPY);
			quarter = new FastBlurPass(FastBlurEffect.QUARTER);
			blur = new FastBlurPass(FastBlurEffect.KERNEL);
		}
		var smaller = factor(strengthX, strengthY, quality);
		var output = input;
		var previous:Texture;
		var scale = 1;
		while (scale < smaller) {
			var pass = smaller / scale >= 4 ? quarter : copy;
			scale *= pass == quarter ? 4 : 2;
			pass._resolution = 1 / scale;
			previous = output;
			output = pass.process(painter, helper, previous);
			if (previous != input) {
				helper.putTexture(previous);
			}
		}
		blur._resolution = 1 / smaller;
		var effect = blur.blurEffect;
		if (strengthX > 0) {
			effect.kernel = kernel(strengthX / smaller, quality);
			effect.horizontal = true;
			previous = output;
			output = blur.process(painter, helper, previous);
			if (previous != input) {
				helper.putTexture(previous);
			}
		}
		if (strengthY > 0) {
			effect.kernel = kernel(strengthY / smaller, quality);
			effect.horizontal = false;
			previous = output;
			output = blur.process(painter, helper, previous);
			if (previous != input) {
				helper.putTexture(previous);
			}
		}
		return output;
	}

	/** The kernel of BlurFilter's passes for a blur of `strength` texels. **/
	static function kernel(strength:Float, quality:Float):FastBlurKernel {
		var key = Std.int(strength * 4096) * 1024 + Std.int(quality * 1000);
		var found = kernels[key];
		if (found == null) {
			found = new FastBlurKernel(strength, quality);
			kernels[key] = found;
		}
		return found;
	}
}

/** The weights of the texels around one, on one side (the other is the same), paired for sampling. **/
class FastBlurKernel {
	/** The weight of the texel itself, then of each pair. **/
	public final weights:flash.Vector<Float> = new flash.Vector<Float>((16 : UInt), true);

	/** Where each pair is sampled, in texels from the texel itself: between its two texels, by their weights. **/
	public final offsets:flash.Vector<Float> = new flash.Vector<Float>((12 : UInt), true);

	public var pairs:Int = 0;

	public function new(strength:Float, quality:Float) {
		// the passes BlurFilter.process runs, each as the weights of the texels it reads
		var total:Array<Float> = [1.0];
		var left = strength;
		while (true) {
			total = convolve(total, pass(left, quality));
			if (left <= 1) {
				break;
			}
			left /= 2;
		}
		// `total` holds the texel itself at its middle: drop the far texels that weigh nothing
		var radius = total.length >> 1;
		var middle = radius;
		var dropped = 0.0;
		while (radius > 0 && (dropped + 2 * total[middle + radius] < 0.002 || radius > FastBlur.MAX_PAIRS * 2)) {
			dropped += 2 * total[middle + radius];
			radius--;
		}
		var scale = 1 / (1 - dropped);
		for (i in 0...16) {
			weights[i] = 0;
		}
		for (i in 0...12) {
			offsets[i] = 0;
		}
		weights[0] = total[middle] * scale;
		pairs = (radius + 1) >> 1;
		for (pair in 0...pairs) {
			var near = 2 * pair + 1;
			var first = total[middle + near];
			var second = near + 1 <= radius ? total[middle + near + 1] : 0.0;
			var sum = first + second;
			weights[pair + 1] = sum * scale;
			offsets[pair] = sum > 0 ? (near * first + (near + 1) * second) / sum : near;
		}
	}

	/** One pass of BlurEffect of the given strength, as the weights of the texels it reads through its five
		samples: a sample between two texels reads both, by how near it is to each. **/
	static function pass(strength:Float, quality:Float):Array<Float> {
		var weight0:Float;
		var weight1:Float;
		var weight2:Float;
		var offset1:Float;
		var offset2:Float;
		if (strength <= 1) {
			// BlurEffect.updateParameters
			var sigma = strength * 2;
			var twoSigmaSquare = 2 * sigma * sigma;
			var multiplier = 1 / Math.sqrt(twoSigmaSquare * 3.141592653589793);
			var tmp = [for (i in 0...5) multiplier * Math.exp(-i * i / twoSigmaSquare)];
			weight0 = tmp[0];
			weight1 = tmp[1] + tmp[2];
			weight2 = tmp[3] + tmp[4];
			var inverse = 1 / (weight0 + 2 * weight1 + 2 * weight2);
			weight0 *= inverse;
			weight1 *= inverse;
			weight2 *= inverse;
			offset1 = (tmp[1] + 2 * tmp[2]) / weight1;
			offset2 = (3 * tmp[3] + 4 * tmp[4]) / weight2;
		} else {
			weight0 = 0.29412;
			weight1 = 0.23529;
			weight2 = 0.11765;
			offset1 = strength * 1.3;
			offset2 = strength * 2.3;
		}
		offset1 /= quality;
		offset2 /= quality;
		var radius = Math.floor(offset2) + 1;
		var texels = [for (i in 0...2 * radius + 1) 0.0];
		texels[radius] = weight0;
		spread(texels, radius, offset1, weight1);
		spread(texels, radius, offset2, weight2);
		return texels;
	}

	static function spread(texels:Array<Float>, middle:Int, offset:Float, weight:Float) {
		var whole = Math.floor(offset);
		var part = offset - whole;
		texels[middle + whole] += weight * (1 - part);
		texels[middle - whole] += weight * (1 - part);
		texels[middle + whole + 1] += weight * part;
		texels[middle - whole - 1] += weight * part;
	}

	static function convolve(a:Array<Float>, b:Array<Float>):Array<Float> {
		var result = [for (i in 0...a.length + b.length - 1) 0.0];
		for (i in 0...a.length) {
			var value = a[i];
			if (value != 0) {
				for (j in 0...b.length) {
					result[i + j] += value * b[j];
				}
			}
		}
		return result;
	}
}

/** A pass of FastBlur: FragmentFilter's, with FastBlurEffect. **/
class FastBlurPass extends FragmentFilter {
	final mode:Int;

	public function new(mode:Int) {
		super();
		this.mode = mode;
	}

	override function createEffect():FilterEffect {
		return new FastBlurEffect(mode);
	}

	public var blurEffect(get, never):FastBlurEffect;

	function get_blurEffect():FastBlurEffect {
		return cast effect;
	}
}

class FastBlurEffect extends FilterEffect {
	/** The texture as it is: drawn half as large, each texel is the mean of the four it covers. **/
	public static inline final COPY = 0;

	/** Four samples, for a texture drawn a quarter as large: each texel is the mean of the sixteen it covers. **/
	public static inline final QUARTER = 1;

	public static inline final KERNEL = 2;

	static final sConstants:flash.Vector<Float> = new flash.Vector<Float>((12 : UInt), true);

	public var kernel:FastBlurKernel;

	public var horizontal:Bool = true;

	final mode:Int;

	public function new(mode:Int) {
		super();
		this.mode = mode;
	}

	override function get_programVariantName():UInt {
		var bits = mode == KERNEL ? (0x200 | kernel.pairs << 12) : mode << 8;
		return ((super.get_programVariantName() : Int) | bits : UInt);
	}

	override function createProgram():Program {
		if (mode == COPY) {
			return super.createProgram();
		}
		var vertex = "m44 op, va0, vc0 \nmov v0, va1";
		var lines:Array<String> = [];
		if (mode == QUARTER) {
			// fc0 and fc1: one texel along each diagonal; fc2.x: a quarter
			lines.push("add ft0, v0, fc0");
			lines.push(FilterEffect.tex("ft1", "ft0", 0, texture));
			lines.push("sub ft0, v0, fc0");
			lines.push(FilterEffect.tex("ft2", "ft0", 0, texture));
			lines.push("add ft1, ft1, ft2");
			lines.push("add ft0, v0, fc1");
			lines.push(FilterEffect.tex("ft2", "ft0", 0, texture));
			lines.push("add ft1, ft1, ft2");
			lines.push("sub ft0, v0, fc1");
			lines.push(FilterEffect.tex("ft2", "ft0", 0, texture));
			lines.push("add ft1, ft1, ft2");
			lines.push("mul oc, ft1, fc2.xxxx");
		} else {
			// fc0: one texel along the direction; fc1 to fc3: where the pairs are; fc4 to fc7: the weights
			var components = "xyzw";
			lines.push(FilterEffect.tex("ft0", "v0", 0, texture));
			lines.push("mul ft5, ft0, fc4.xxxx");
			for (pair in 0...kernel.pairs) {
				var offset = "fc" + (1 + (pair >> 2)) + "." + StringTools.rpad("", components.charAt(pair & 3), 4);
				var weight = "fc" + (4 + ((pair + 1) >> 2)) + "." + StringTools.rpad("", components.charAt((pair + 1) & 3), 4);
				lines.push("mul ft1, fc0, " + offset);
				lines.push("add ft2, v0, ft1");
				lines.push(FilterEffect.tex("ft3", "ft2", 0, texture));
				lines.push("sub ft2, v0, ft1");
				lines.push(FilterEffect.tex("ft4", "ft2", 0, texture));
				lines.push("add ft3, ft3, ft4");
				lines.push("mul ft3, ft3, " + weight);
				lines.push("add ft5, ft5, ft3");
			}
			lines.push("mov oc, ft5");
		}
		return Program.fromSource(vertex, lines.join("\n"));
	}

	override function beforeDraw(context:Context3D) {
		super.beforeDraw(context);
		if (mode == COPY) {
			return;
		}
		var root = texture.root;
		var texelX = 1 / root.nativeWidth;
		var texelY = 1 / root.nativeHeight;
		var constants = sConstants;
		if (mode == QUARTER) {
			constants[0] = texelX;
			constants[1] = texelY;
			constants[2] = 0;
			constants[3] = 0;
			constants[4] = texelX;
			constants[5] = -texelY;
			constants[6] = 0;
			constants[7] = 0;
			constants[8] = 0.25;
			constants[9] = 0;
			constants[10] = 0;
			constants[11] = 0;
			context.setProgramConstantsFromVector("fragment", 0, constants, 3);
		} else {
			constants[0] = horizontal ? texelX : 0;
			constants[1] = horizontal ? 0 : texelY;
			constants[2] = 0;
			constants[3] = 0;
			context.setProgramConstantsFromVector("fragment", 0, constants, 1);
			context.setProgramConstantsFromVector("fragment", 1, kernel.offsets, 3);
			context.setProgramConstantsFromVector("fragment", 4, kernel.weights, 4);
		}
	}
}
