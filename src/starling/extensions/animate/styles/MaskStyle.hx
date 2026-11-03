package starling.extensions.animate.styles;

import starling.rendering.MeshEffect;
import starling.styles.MeshStyle;
import flash.display3D.Context3D;
import starling.rendering.MeshEffect;
import starling.rendering.Program;

class MaskStyle extends MeshStyle {
	public function new() {
		super();
	}

	override public function createEffect():MeshEffect {
		return new MaskEffect();
	}
}

private class MaskEffect extends MeshEffect {
	static final sThreshold:Vector<Float> = Vector.ofArray([0.5, 0.5, 0.5, 0.5]);

	public function new() {
		super();
	}

	override function createProgram():Program {
		if (texture == null) {
			return super.createProgram();
		}
		var _loc1_ = "m44 op, va0, vc0 \nmov v0, va1      \nmul v1, va2, vc4 \n";
		var _loc2_ = starling.rendering.FilterEffect.tex("ft0", "v0", 0, texture)
			+ "sub ft1, ft0.wwww, fc0 \n"
			+ "kil ft1.x              \n"
			+ "mul oc, ft0, v1        \n";
		return Program.fromSource(_loc1_, _loc2_);
	}

	override function beforeDraw(context:Context3D) {
		super.beforeDraw(context);
		context.setProgramConstantsFromVector("fragment", 0, sThreshold);
	}
}
