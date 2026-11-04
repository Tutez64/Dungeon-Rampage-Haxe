package starling.styles;

import flash.geom.Matrix;
import flash.geom.Point;
import starling.core.Starling;
import starling.display.Mesh;
import starling.events.Event;
import starling.events.EventDispatcher;
import starling.rendering.*;
import starling.textures.ConcreteTexture;
import starling.textures.Texture;

/*use*/ /*namespace*/ /*starling_internal*/ class MeshStyle extends EventDispatcher {
	public static final VERTEX_FORMAT:VertexDataFormat = MeshEffect.VERTEX_FORMAT;

	static var sPoint:Point = new Point();

	var _type:Dynamic;

	var _target:Mesh;

	var _texture:Texture;

	var _textureSmoothing:String;

	var _textureRepeat:Bool = false;

	var _textureRoot:ConcreteTexture;

	var _vertexData:VertexData;

	var _indexData:IndexData;

	public function new() {
		super();
		_textureSmoothing = Starling.currentDefaultTextureSmoothing;
		_type = (ASCompat.constructorOf(this) : Dynamic);
	}

	public function copyFrom(meshStyle:MeshStyle) {
		_texture = meshStyle._texture;
		_textureRoot = meshStyle._textureRoot;
		_textureRepeat = meshStyle._textureRepeat;
		_textureSmoothing = meshStyle._textureSmoothing;
	}

	public function clone():MeshStyle {
		var _loc1_ = ASCompat.coerce(ASCompat.createInstance(_type, []), MeshStyle);
		_loc1_.copyFrom(this);
		return _loc1_;
	}

	public function createEffect():MeshEffect {
		return new MeshEffect();
	}

	public function updateEffect(effect:MeshEffect, state:RenderState) {
		effect.texture = _texture;
		effect.textureRepeat = _textureRepeat;
		effect.textureSmoothing = _textureSmoothing;
		effect.mvpMatrix3D = state.mvpMatrix3D;
		effect.alpha = state.alpha;
		effect.tinted = _vertexData.tinted;
	}

	public function canBatchWith(meshStyle:MeshStyle):Bool {
		var _loc2_:Texture = null;
		if (_type == meshStyle._type) {
			_loc2_ = meshStyle._texture;
			if (_texture == null && _loc2_ == null) {
				return true;
			}
			if (_texture != null && _loc2_ != null) {
				return _textureRoot == meshStyle._textureRoot
					&& _textureSmoothing == meshStyle._textureSmoothing
					&& _textureRepeat == meshStyle._textureRepeat;
			}
			return false;
		}
		return false;
	}

	public function batchVertexData(targetStyle:MeshStyle, targetVertexID:Int = 0, matrix:Matrix = null, vertexID:Int = 0, numVertices:Int = -1) {
		_vertexData.copyTo(targetStyle._vertexData, targetVertexID, matrix, vertexID, numVertices);
	}

	public function batchIndexData(targetStyle:MeshStyle, targetIndexID:Int = 0, offset:Int = 0, indexID:Int = 0, numIndices:Int = -1) {
		_indexData.copyTo(targetStyle._indexData, targetIndexID, offset, indexID, numIndices);
	}

	function setRequiresRedraw() {
		if (_target != null) {
			_target.setRequiresRedraw();
		}
	}

	function setVertexDataChanged() {
		if (_target != null) {
			_target.setVertexDataChanged();
		}
	}

	function setIndexDataChanged() {
		if (_target != null) {
			_target.setIndexDataChanged();
		}
	}

	function onTargetAssigned(target:Mesh) {}

	override public function addEventListener(type:String, listener:ASFunction) {
		if (type == "enterFrame" && _target != null) {
			_target.addEventListener("enterFrame", onEnterFrame);
		}
		super.addEventListener(type, listener);
	}

	override public function removeEventListener(type:String, listener:ASFunction) {
		if (type == "enterFrame" && _target != null) {
			_target.removeEventListener(type, onEnterFrame);
		}
		super.removeEventListener(type, listener);
	}

	function onEnterFrame(event:Event) {
		dispatchEvent(event);
	}

	/*starling_internal*/
	public function setTarget(target:Mesh = null, vertexData:VertexData = null, indexData:IndexData = null) {
		if (_target != target) {
			if (_target != null) {
				_target.removeEventListener("enterFrame", onEnterFrame);
			}
			if (vertexData != null) {
				vertexData.format = vertexFormat;
			}
			_target = target;
			_vertexData = vertexData;
			_indexData = indexData;
			if (target != null) {
				if (hasEventListener("enterFrame")) {
					target.addEventListener("enterFrame", onEnterFrame);
				}
				onTargetAssigned(target);
			}
		}
	}

	public function getVertexPosition(vertexID:Int, out:Point = null):Point {
		return _vertexData.getPoint(vertexID, "position", out);
	}

	public function setVertexPosition(vertexID:Int, x:Float, y:Float) {
		_vertexData.setPoint(vertexID, "position", x, y);
		setVertexDataChanged();
	}

	public function getVertexAlpha(vertexID:Int):Float {
		return _vertexData.getAlpha(vertexID);
	}

	public function setVertexAlpha(vertexID:Int, alpha:Float) {
		_vertexData.setAlpha(vertexID, "color", alpha);
		setVertexDataChanged();
	}

	public function getVertexColor(vertexID:Int):UInt {
		return _vertexData.getColor(vertexID);
	}

	public function setVertexColor(vertexID:Int, color:UInt) {
		_vertexData.setColor(vertexID, "color", color);
		setVertexDataChanged();
	}

	public function getTexCoords(vertexID:Int, out:Point = null):Point {
		if (_texture != null) {
			return _texture.getTexCoords(_vertexData, vertexID, "texCoords", out);
		}
		return _vertexData.getPoint(vertexID, "texCoords", out);
	}

	public function setTexCoords(vertexID:Int, u:Float, v:Float) {
		if (_texture != null) {
			_texture.setTexCoords(_vertexData, vertexID, "texCoords", u, v);
		} else {
			_vertexData.setPoint(vertexID, "texCoords", u, v);
		}
		setVertexDataChanged();
	}

	@:isVar var vertexData(get, never):VertexData;

	function get_vertexData():VertexData {
		return _vertexData;
	}

	@:isVar var indexData(get, never):IndexData;

	function get_indexData():IndexData {
		return _indexData;
	}

	@:isVar public var type(get, never):Dynamic;

	public function get_type():Dynamic {
		return _type;
	}

	@:isVar public var color(get, set):UInt;

	public function get_color():UInt {
		if (_vertexData.numVertices > 0) {
			return _vertexData.getColor(0);
		}
		return (0 : UInt);
	}

	function set_color(value:UInt):UInt {
		var _loc3_ = 0;
		var _loc2_ = _vertexData.numVertices;
		_loc3_ = 0;
		while (_loc3_ < _loc2_) {
			_vertexData.setColor(_loc3_, "color", value);
			_loc3_++;
		}
		if (value == 16777215 && _vertexData.tinted) {
			_vertexData.updateTinted();
		}
		setVertexDataChanged();
		return value;
	}

	@:isVar public var vertexFormat(get, never):VertexDataFormat;

	public function get_vertexFormat():VertexDataFormat {
		return VERTEX_FORMAT;
	}

	@:isVar public var texture(get, set):Texture;

	public function get_texture():Texture {
		return _texture;
	}

	function set_texture(value:Texture):Texture {
		var _loc3_ = 0;
		var _loc2_ = 0;
		if (value != _texture) {
			if (value != null) {
				_loc2_ = _vertexData != null ? _vertexData.numVertices : 0;
				_loc3_ = 0;
				while (_loc3_ < _loc2_) {
					getTexCoords(_loc3_, sPoint);
					value.setTexCoords(_vertexData, _loc3_, "texCoords", sPoint.x, sPoint.y);
					_loc3_++;
				}
				setVertexDataChanged();
			} else {
				setRequiresRedraw();
			}
			_texture = value;
			_textureRoot = ASCompat.coerce(value != null ? value.root : null, starling.textures.ConcreteTexture);
		}
		return value;
	}

	@:isVar public var textureSmoothing(get, set):String;

	public function get_textureSmoothing():String {
		return _textureSmoothing;
	}

	function set_textureSmoothing(value:String):String {
		if (value != _textureSmoothing) {
			_textureSmoothing = value;
			setRequiresRedraw();
		}
		return value;
	}

	@:isVar public var textureRepeat(get, set):Bool;

	public function get_textureRepeat():Bool {
		return _textureRepeat;
	}

	function set_textureRepeat(value:Bool):Bool {
		return _textureRepeat = value;
	}

	@:isVar public var target(get, never):Mesh;

	public function get_target():Mesh {
		return _target;
	}
}
