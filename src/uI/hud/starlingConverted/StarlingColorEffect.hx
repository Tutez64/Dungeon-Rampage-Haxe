package uI.hud.starlingConverted;

import flash.display3D.Context3D;
import starling.rendering.MeshEffect;
import starling.rendering.Program;

class StarlingColorEffect extends MeshEffect {
	public var values:Vector<Float>;

	public function new() {
		super();
	}

	override function createProgram():Program {
		var _loc2_ = "m44 op, va0, vc0\nmov v0, va1\nmul v1, va2, vc4\n";
		var _loc1_ = starling.rendering.FilterEffect.tex("ft0", "v0", 0, texture)
			+ "mul ft1, ft0, fc0\n"
			+ "mul ft2, ft0.www, fc1\n"
			+ "add ft1.xyz, ft1.xyz, ft2.xyz\n"
			+ "sat ft1.xyz, ft1.xyz\n"
			+ "min ft1.xyz, ft1.xyz, ft0.www\n"
			+ "mul oc, ft1, v1\n";
		return Program.fromSource(_loc2_, _loc1_);
	}

	override function beforeDraw(context:Context3D) {
		super.beforeDraw(context);
		context.setProgramConstantsFromVector("fragment", 0, values, 2);
	}
}
