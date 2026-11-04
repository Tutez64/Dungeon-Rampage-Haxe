package starling.filters;

import flash.geom.Point;
import starling.rendering.FilterEffect;
import starling.rendering.Painter;
import starling.textures.Texture;
import flash.display3D.Context3D;
import starling.filters.CompositeMode;
import starling.rendering.FilterEffect;
import starling.rendering.Program;
import starling.rendering.VertexDataFormat;
import starling.textures.Texture;
import starling.utils.Color;
import starling.utils.RenderUtil;
import starling.utils.StringUtil;
import flash.errors.ArgumentError;

class CompositeFilter extends FragmentFilter {
	public function new() {
		super();
	}

	override public function process(painter:Painter, helper:IFilterHelper, input0:Texture = null, input1:Texture = null, input2:Texture = null,
			input3:Texture = null):Texture {
		compositeEffect.texture = input0;
		compositeEffect.getLayerAt(1).texture = input1;
		compositeEffect.getLayerAt(2).texture = input2;
		compositeEffect.getLayerAt(3).texture = input3;
		if (input1 != null) {
			input1.setupTextureCoordinates(vertexData, 0, "texCoords1");
		}
		if (input2 != null) {
			input2.setupTextureCoordinates(vertexData, 0, "texCoords2");
		}
		if (input3 != null) {
			input3.setupTextureCoordinates(vertexData, 0, "texCoords3");
		}
		return super.process(painter, helper, input0, input1, input2, input3);
	}

	override function createEffect():FilterEffect {
		return new CompositeEffect();
	}

	public function getOffsetAt(layerID:Int, out:Point = null):Point {
		if (out == null) {
			out = new Point();
		}
		out.x = compositeEffect.getLayerAt(layerID).x;
		out.y = compositeEffect.getLayerAt(layerID).y;
		return out;
	}

	public function setOffsetAt(layerID:Int, x:Float, y:Float) {
		compositeEffect.getLayerAt(layerID).x = x;
		compositeEffect.getLayerAt(layerID).y = y;
	}

	public function getColorAt(layerID:Int):UInt {
		return compositeEffect.getLayerAt(layerID).color;
	}

	public function getReplaceColorAt(layerID:Int):Bool {
		return compositeEffect.getLayerAt(layerID).replaceColor;
	}

	public function setColorAt(layerID:Int, color:UInt, replace:Bool = false) {
		compositeEffect.getLayerAt(layerID).color = color;
		compositeEffect.getLayerAt(layerID).replaceColor = replace;
	}

	public function getAlphaAt(layerID:Int):Float {
		return compositeEffect.getLayerAt(layerID).alpha;
	}

	public function setAlphaAt(layerID:Int, alpha:Float) {
		compositeEffect.getLayerAt(layerID).alpha = alpha;
	}

	public function getModeAt(layerID:Int):String {
		return compositeEffect.getLayerAt(layerID).mode;
	}

	public function setModeAt(layerID:Int, mode:String) {
		compositeEffect.getLayerAt(layerID).mode = mode;
	}

	public function getInvertAlphaAt(layerID:Int):Bool {
		return compositeEffect.getLayerAt(layerID).invertAlpha;
	}

	public function setInvertAlphaAt(layerID:Int, value:Bool = true) {
		compositeEffect.getLayerAt(layerID).invertAlpha = value;
	}

	@:isVar var compositeEffect(get, never):CompositeEffect;

	function get_compositeEffect():CompositeEffect {
		return ASCompat.reinterpretAs(this.effect, CompositeEffect);
	}
}

private class CompositeEffect extends FilterEffect {
	public static final VERTEX_FORMAT:VertexDataFormat = FilterEffect.VERTEX_FORMAT.extend("texCoords1:float2, texCoords2:float2, texCoords3:float2");

	static var sLayers:Array<ASAny>;

	static var sOffset:Vector<Float> = Vector.ofArray(([0, 0, 0, 0] : Array<Float>));

	static var sColor:Vector<Float> = Vector.ofArray(([0, 0, 0, 0] : Array<Float>));

	var _layers:Vector<CompositeLayer>;

	public function new(numLayers:Int = 4) {
		var _loc2_ = 0;
		super();
		if (numLayers < 1 || numLayers > 4) {
			throw new ArgumentError("number of layers must be between 1 and 4");
		}
		_layers = new Vector<CompositeLayer>((numLayers : UInt), true);
		_loc2_ = 0;
		while (_loc2_ < numLayers) {
			_layers[_loc2_] = new CompositeLayer();
			_loc2_++;
		}
	}

	public function getLayerAt(layerID:Int):CompositeLayer {
		return _layers[layerID];
	}

	function getUsedLayers(out:Array<ASAny> = null):Array<ASAny> {
		if (out == null) {
			out = [];
		} else {
			out.resize(0);
		}
		var _loc2_:CompositeLayer;
		final __ax4_iter_530 = _layers;
		if (checkNullIteratee(__ax4_iter_530))
			for (_tmp_ in __ax4_iter_530) {
				_loc2_ = _tmp_;
				if (_loc2_.texture != null) {
					out[out.length] = _loc2_;
				}
			}
		return out;
	}

	override function createProgram():Program {
		var _loc6_ = 0;
		var _loc3_:Array<ASAny> = null;
		var _loc9_:CompositeLayer = null;
		var _loc5_:Array<ASAny> = null;
		var _loc7_:String = null;
		var _loc8_:String = null;
		var _loc2_:String = null;
		var _loc4_ = getUsedLayers(sLayers);
		var _loc1_ = _loc4_.length;
		if (_loc1_ != 0) {
			_loc3_ = ["m44 op, va0, vc0"];
			_loc9_ = _layers[0];
			_loc6_ = 0;
			while (_loc6_ < _loc1_) {
				_loc3_.push(StringUtil.format("add v{0}, va{1}, vc{2}", _loc6_, _loc6_ + 1, _loc6_ + 4));
				_loc6_++;
			}
			_loc5_ = ["sge ft5, v0, v0"];
			_loc6_ = 0;
			while (_loc6_ < _loc1_) {
				_loc7_ = "ft" + _loc6_;
				_loc8_ = "fc" + _loc6_;
				_loc2_ = "v" + _loc6_;
				_loc9_ = _layers[_loc6_];
				_loc5_.push(FilterEffect.tex(_loc7_, _loc2_, _loc6_, ASCompat.coerce(_loc4_[_loc6_].texture, starling.textures.Texture)));
				if (_loc9_.replaceColor) {
					if (_loc9_.invertAlpha) {
						_loc5_.push("sub " + _loc7_ + ".w, ft5.w, " + _loc7_ + ".w");
					}
					ASCompat.ASArray.pushMultiple(_loc5_, "mul "
						+ _loc7_
						+ ".w,   "
						+ _loc7_
						+ ".w,   "
						+ _loc8_
						+ ".w",
						"sat "
						+ _loc7_
						+ ".w,   "
						+ _loc7_
						+ ".w    ", "mul "
						+ _loc7_
						+ ".xyz, "
						+ _loc8_
						+ ".xyz, "
						+ _loc7_
						+ ".www");
				} else {
					_loc5_.push("mul " + _loc7_ + ", " + _loc7_ + ", " + _loc8_);
				}
				if (_loc6_ == 0) {
					_loc6_++;
					continue;
				}
				switch (_loc9_.mode) {
					case "normal":
						ASCompat.ASArray.pushMultiple(_loc5_, "sub ft4, ft5, " + _loc7_ + ".wwww", "mul ft0, ft0, ft4", "add ft0, ft0, " + _loc7_);

					case "inside":
						ASCompat.ASArray.pushMultiple(_loc5_, "mul ft4, ft0.wwww, " + _loc7_, "sub ft6, ft5, " + _loc7_ + ".wwww", "mul ft6, ft6, ft0",
							"add ft0, ft6, ft4");

					case "insideKnockout":
						_loc5_.push("mul ft0, ft0.wwww, " + _loc7_);

					case "outside":
						ASCompat.ASArray.pushMultiple(_loc5_, "sub ft4, ft5, ft0.wwww", "mul ft4, ft4, " + _loc7_, "add ft0, ft0, ft4");

					case "outsideKnockout":
						ASCompat.ASArray.pushMultiple(_loc5_, "sub ft4, ft5, ft0.wwww", "mul ft0, ft4, " + _loc7_);

					default:
						throw new ArgumentError("Invalid composite mode: " + _loc9_.mode);
				}
				_loc6_++;
			}
			_loc5_.push("mov oc, ft0");
			return Program.fromSource(_loc3_.join("\n"), _loc5_.join("\n"));
		}
		return super.createProgram();
	}

	override function get_programVariantName():UInt {
		var _loc4_ = (0 : UInt);
		var _loc8_ = (0 : UInt);
		var _loc3_ = (0 : UInt);
		var _loc10_ = (0 : UInt);
		var _loc6_ = (0 : UInt);
		var _loc9_:CompositeLayer = null;
		var _loc7_ = 0;
		var _loc2_ = (0 : UInt);
		var _loc5_ = getUsedLayers(sLayers);
		var _loc1_ = _loc5_.length;
		_loc7_ = 0;
		while (_loc7_ < _loc1_) {
			_loc9_ = ASCompat.coerce(_loc5_[_loc7_], CompositeLayer);
			_loc3_ = RenderUtil.getTextureVariantBits(_loc9_.texture);
			_loc8_ = (CompositeMode.getIndex(_loc9_.mode) : UInt);
			_loc6_ = (ASCompat.toInt(_loc9_.replaceColor) : UInt);
			_loc10_ = (ASCompat.toInt(_loc9_.invertAlpha) : UInt);
			_loc4_ = ((_loc3_ : Int) | (_loc8_ : Int) << 3 | (_loc6_ : Int) << 6 | (_loc10_ : Int) << 7 : UInt);
			_loc2_ = ((_loc2_ | ((_loc4_ : Int) << _loc7_ * 8 : UInt) : UInt) : UInt);
			_loc7_++;
		}
		return _loc2_;
	}

	override function beforeDraw(context:Context3D) {
		var _loc5_ = 0;
		var _loc6_:CompositeLayer = null;
		var _loc3_:Texture = null;
		var _loc7_ = Math.NaN;
		super.beforeDraw(context);
		var _loc4_ = getUsedLayers(sLayers);
		var _loc2_ = _loc4_.length;
		if (_loc2_ != 0) {
			_loc5_ = 0;
			while (_loc5_ < _loc2_) {
				_loc6_ = ASCompat.coerce(_loc4_[_loc5_], CompositeLayer);
				_loc3_ = _loc6_.texture;
				_loc7_ = _loc6_.replaceColor ? 1 : _loc6_.alpha;
				sOffset[0] = -_loc6_.x / (_loc3_.root.nativeWidth / _loc3_.scale);
				sOffset[1] = -_loc6_.y / (_loc3_.root.nativeHeight / _loc3_.scale);
				sColor[0] = Color.getRed(_loc6_.color) * _loc7_ / 255;
				sColor[1] = Color.getGreen(_loc6_.color) * _loc7_ / 255;
				sColor[2] = Color.getBlue(_loc6_.color) * _loc7_ / 255;
				sColor[3] = _loc6_.alpha;
				context.setProgramConstantsFromVector("vertex", _loc5_ + 4, sOffset);
				context.setProgramConstantsFromVector("fragment", _loc5_, sColor);
				if (_loc5_ > 0) {
					context.setTextureAt(_loc5_, _loc3_.base);
					RenderUtil.setSamplerStateAt(_loc5_, _loc3_.mipMapping, textureSmoothing);
					vertexFormat.setVertexBufferAt(_loc5_ + 1, vertexBuffer, "texCoords" + _loc5_);
				}
				_loc5_++;
			}
		}
	}

	override function afterDraw(context:Context3D) {
		var _loc4_ = 0;
		var _loc3_ = getUsedLayers(sLayers);
		var _loc2_ = _loc3_.length;
		_loc4_ = 1;
		while (_loc4_ < _loc2_) {
			context.setTextureAt(_loc4_, null);
			context.setVertexBufferAt(_loc4_ + 1, null);
			_loc4_++;
		}
		super.afterDraw(context);
	}

	override public function get_vertexFormat():VertexDataFormat {
		return VERTEX_FORMAT;
	}

	@:isVar public var numLayers(get, never):Int;

	public function get_numLayers():Int {
		return _layers.length;
	}

	override public function set_texture(value:Texture):Texture {
		_layers[0].texture = value;
		return super.texture = value;
	}

	static function __init__() {
		sLayers = [];
	}
}

private class CompositeLayer {
	public var texture:Texture;

	public var x:Float = Math.NaN;

	public var y:Float = Math.NaN;

	public var color:UInt = 0;

	public var alpha:Float = Math.NaN;

	public var replaceColor:Bool = false;

	public var invertAlpha:Bool = false;

	public var mode:String;

	public function new() {
		x = y = 0;
		alpha = 1;
		color = (16777215 : UInt);
		mode = "normal";
	}
}
