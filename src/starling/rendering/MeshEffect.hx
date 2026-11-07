package starling.rendering;

import flash.display3D.Context3D;

class MeshEffect extends FilterEffect {
	public static final VERTEX_FORMAT:VertexDataFormat = FilterEffect.VERTEX_FORMAT.extend("color:bytes4");

	static var sRenderAlpha:Vector<Float> = new Vector((4 : UInt), true);

	var _alpha:Float = Math.NaN;

	var _tinted:Bool = false;

	var _optimizeIfNotTinted:Bool = false;

	public function new() {
		super();
		_alpha = 1;
		_optimizeIfNotTinted = ASCompat.getQualifiedClassName(this) == "starling.rendering::MeshEffect";
	}

	override function get_programVariantName():UInt {
		var _loc1_ = ((if (_optimizeIfNotTinted && !_tinted && _alpha == 1) 1 else 0) : UInt);
		return ((super.programVariantName : Int) | (_loc1_ : Int) << 3 : UInt);
	}

	override function createProgram():Program {
		var _loc2_:String = null;
		var _loc1_:String = null;
		if (texture != null) {
			if (_optimizeIfNotTinted && !_tinted && _alpha == 1) {
				return super.createProgram();
			}
			_loc1_ = "m44 op, va0, vc0 \nmov v0, va1      \nmul v1, va2, vc4 \n";
			_loc2_ = FilterEffect.tex("ft0", "v0", 0, texture) + "mul oc, ft0, v1  \n";
		} else {
			_loc1_ = "m44 op, va0, vc0 \nmul v0, va2, vc4 \n";
			_loc2_ = "mov oc, v0       \n";
		}
		return Program.fromSource(_loc1_, _loc2_);
	}

	override function beforeDraw(context:Context3D) {
		super.beforeDraw(context);
		sRenderAlpha[0] = sRenderAlpha[1] = sRenderAlpha[2] = sRenderAlpha[3] = _alpha;
		context.setProgramConstantsFromVector("vertex", 4, sRenderAlpha);
		if (_tinted || _alpha != 1 || !_optimizeIfNotTinted || texture == null) {
			vertexFormat.setVertexBufferAt(2, vertexBuffer, "color");
		}
	}

	override function afterDraw(context:Context3D) {
		context.setVertexBufferAt(2, null);
		super.afterDraw(context);
	}

	override public function get_vertexFormat():VertexDataFormat {
		return VERTEX_FORMAT;
	}

	@:isVar public var alpha(get, set):Float;

	public function get_alpha():Float {
		return _alpha;
	}

	function set_alpha(value:Float):Float {
		return _alpha = value;
	}

	@:isVar public var tinted(get, set):Bool;

	public function get_tinted():Bool {
		return _tinted;
	}

	function set_tinted(value:Bool):Bool {
		return _tinted = value;
	}
}
