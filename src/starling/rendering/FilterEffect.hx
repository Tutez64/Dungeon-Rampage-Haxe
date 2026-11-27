package starling.rendering;

import flash.display3D.Context3D;
import starling.core.Starling;
import starling.textures.Texture;
import starling.utils.RenderUtil;

class FilterEffect extends Effect {
	public static inline final STD_VERTEX_SHADER = "m44 op, va0, vc0 \nmov v0, va1";

	public static final VERTEX_FORMAT:VertexDataFormat = Effect.VERTEX_FORMAT.extend("texCoords:float2");

	var _texture:Texture;

	var _textureSmoothing:String;

	var _textureRepeat:Bool = false;

	public function new() {
		super();
		_textureSmoothing = Starling.currentDefaultTextureSmoothing;
	}

	static function tex(resultReg:String, uvReg:String, sampler:Int, texture:Texture, convertToPmaIfRequired:Bool = true):String {
		return RenderUtil.createAGALTexOperation(resultReg, uvReg, sampler, texture, convertToPmaIfRequired);
	}

	override function get_programVariantName():UInt {
		return RenderUtil.getTextureVariantBits(_texture);
	}

	override function createProgram():Program {
		var _loc1_:String = null;
		var _loc2_:String = null;
		if (_texture != null) {
			_loc1_ = "m44 op, va0, vc0 \nmov v0, va1";
			_loc2_ = tex("oc", "v0", 0, _texture);
			return Program.fromSource(_loc1_, _loc2_);
		}
		return super.createProgram();
	}

	override function beforeDraw(context:Context3D) {
		var _loc2_ = false;
		super.beforeDraw(context);
		if (_texture != null) {
			_loc2_ = _textureRepeat && _texture.root.isPotTexture;
			RenderUtil.setSamplerStateAt(0, _texture.mipMapping, _textureSmoothing, _loc2_);
			context.setTextureAt(0, _texture.base);
			vertexFormat.setVertexBufferAt(1, vertexBuffer, "texCoords");
		}
	}

	override function afterDraw(context:Context3D) {
		if (_texture != null) {
			context.setTextureAt(0, null);
			context.setVertexBufferAt(1, null);
		}
		super.afterDraw(context);
	}

	override public function get_vertexFormat():VertexDataFormat {
		return VERTEX_FORMAT;
	}

	@:isVar public var texture(get, set):Texture;

	public function get_texture():Texture {
		return _texture;
	}

	function set_texture(value:Texture):Texture {
		return _texture = value;
	}

	@:isVar public var textureSmoothing(get, set):String;

	public function get_textureSmoothing():String {
		return _textureSmoothing;
	}

	function set_textureSmoothing(value:String):String {
		return _textureSmoothing = value;
	}

	@:isVar public var textureRepeat(get, set):Bool;

	public function get_textureRepeat():Bool {
		return _textureRepeat;
	}

	function set_textureRepeat(value:Bool):Bool {
		return _textureRepeat = value;
	}
}
