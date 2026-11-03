package starling.display;

import flash.geom.Point;
import flash.geom.Rectangle;
import starling.geom.Polygon;
import starling.rendering.IndexData;
import starling.rendering.Painter;
import starling.rendering.VertexData;
import starling.rendering.VertexDataFormat;
import starling.styles.MeshStyle;
import starling.textures.Texture;
import starling.utils.MatrixUtil;
import starling.utils.MeshUtil;
import flash.errors.ArgumentError;

/*use*/ /*namespace*/ /*starling_internal*/ class Mesh extends DisplayObject {
	static var sDefaultStyleFactory:ASFunction = null;

	static var sDefaultStyle:Dynamic = MeshStyle;

	@:allow(starling.display) var _style:MeshStyle;

	@:allow(starling.display) var _vertexData:VertexData;

	@:allow(starling.display) var _indexData:IndexData;

	@:allow(starling.display) var _pixelSnapping:Bool = false;

	public function new(vertexData:VertexData, indexData:IndexData, style:MeshStyle = null) {
		super();
		if (vertexData == null) {
			throw new ArgumentError("VertexData must not be null");
		}
		if (indexData == null) {
			throw new ArgumentError("IndexData must not be null");
		}
		_vertexData = vertexData;
		_indexData = indexData;
		setStyle(style, false);
	}

	public static function createDefaultStyle(instance:Mesh = null):MeshStyle {
		var _loc2_:MeshStyle = null;
		if (sDefaultStyleFactory != null) {
			if (sDefaultStyleFactory.length == 0) {
				_loc2_ = ASCompat.coerce(sDefaultStyleFactory(), starling.styles.MeshStyle);
			} else {
				_loc2_ = ASCompat.coerce(sDefaultStyleFactory(instance), starling.styles.MeshStyle);
			}
		}
		if (_loc2_ == null) {
			_loc2_ = ASCompat.dynamicAs(ASCompat.createInstance(sDefaultStyle, []), MeshStyle);
		}
		return _loc2_;
	}

	@:isVar public static var defaultStyle(get, set):Dynamic;

	static public function get_defaultStyle():Dynamic {
		return sDefaultStyle;
	}

	static function set_defaultStyle(value:Dynamic):Dynamic {
		return sDefaultStyle = value;
	}

	@:isVar public static var defaultStyleFactory(get, set):ASFunction;

	static public function get_defaultStyleFactory():ASFunction {
		return sDefaultStyleFactory;
	}

	static function set_defaultStyleFactory(value:ASFunction):ASFunction {
		return sDefaultStyleFactory = value;
	}

	public static function fromPolygon(polygon:Polygon, style:MeshStyle = null):Mesh {
		var _loc3_ = new VertexData(null, polygon.numVertices);
		var _loc4_ = new IndexData(polygon.numTriangles);
		polygon.copyToVertexData(_loc3_);
		polygon.triangulate(_loc4_);
		return new Mesh(_loc3_, _loc4_, style);
	}

	override public function dispose() {
		_vertexData.clear();
		_indexData.clear();
		super.dispose();
	}

	override public function hitTest(localPoint:Point):DisplayObject {
		if (!visible || !touchable || !hitTestMask(localPoint)) {
			return null;
		}
		return ASCompat.coerce(MeshUtil.containsPoint(_vertexData, _indexData, localPoint) ? this : null, starling.display.DisplayObject);
	}

	override public function getBounds(targetSpace:DisplayObject, out:Rectangle = null):Rectangle {
		return MeshUtil.calculateBounds(_vertexData, this, targetSpace, out);
	}

	override public function render(painter:Painter) {
		if (_pixelSnapping) {
			MatrixUtil.snapToPixels(painter.state.modelviewMatrix, painter.pixelSize);
		}
		painter.batchMesh(this);
	}

	public function setStyle(meshStyle:MeshStyle = null, mergeWithPredecessor:Bool = true) {
		if (meshStyle == null) {
			meshStyle = createDefaultStyle(this);
		} else {
			if (meshStyle == _style) {
				return;
			}
			if (meshStyle.target != null) {
				meshStyle.target.setStyle();
			}
		}
		if (_style != null) {
			if (mergeWithPredecessor) {
				meshStyle.copyFrom(_style);
			}
			_style.setTarget();
		}
		_style = meshStyle;
		_style.setTarget(this, _vertexData, _indexData);
		setRequiresRedraw();
	}

	public function setVertexDataChanged() {
		setRequiresRedraw();
	}

	public function setIndexDataChanged() {
		setRequiresRedraw();
	}

	public function getVertexPosition(vertexID:Int, out:Point = null):Point {
		return _style.getVertexPosition(vertexID, out);
	}

	public function setVertexPosition(vertexID:Int, x:Float, y:Float) {
		_style.setVertexPosition(vertexID, x, y);
	}

	public function getVertexAlpha(vertexID:Int):Float {
		return _style.getVertexAlpha(vertexID);
	}

	public function setVertexAlpha(vertexID:Int, alpha:Float) {
		_style.setVertexAlpha(vertexID, alpha);
	}

	public function getVertexColor(vertexID:Int):UInt {
		return _style.getVertexColor(vertexID);
	}

	public function setVertexColor(vertexID:Int, color:UInt) {
		_style.setVertexColor(vertexID, color);
	}

	public function getTexCoords(vertexID:Int, out:Point = null):Point {
		return _style.getTexCoords(vertexID, out);
	}

	public function setTexCoords(vertexID:Int, u:Float, v:Float) {
		_style.setTexCoords(vertexID, u, v);
	}

	@:isVar var vertexData(get, never):VertexData;

	function get_vertexData():VertexData {
		return _vertexData;
	}

	@:isVar var indexData(get, never):IndexData;

	function get_indexData():IndexData {
		return _indexData;
	}

	@:isVar public var style(get, set):MeshStyle;

	public function get_style():MeshStyle {
		return _style;
	}

	function set_style(value:MeshStyle):MeshStyle {
		setStyle(value);
		return value;
	}

	@:isVar public var texture(get, set):Texture;

	public function get_texture():Texture {
		return _style.texture;
	}

	function set_texture(value:Texture):Texture {
		return _style.texture = value;
	}

	@:isVar public var color(get, set):UInt;

	public function get_color():UInt {
		return _style.color;
	}

	function set_color(value:UInt):UInt {
		return _style.color = value;
	}

	@:isVar public var textureSmoothing(get, set):String;

	public function get_textureSmoothing():String {
		return _style.textureSmoothing;
	}

	function set_textureSmoothing(value:String):String {
		return _style.textureSmoothing = value;
	}

	@:isVar public var textureRepeat(get, set):Bool;

	public function get_textureRepeat():Bool {
		return _style.textureRepeat;
	}

	function set_textureRepeat(value:Bool):Bool {
		return _style.textureRepeat = value;
	}

	@:isVar public var pixelSnapping(get, set):Bool;

	public function get_pixelSnapping():Bool {
		return _pixelSnapping;
	}

	function set_pixelSnapping(value:Bool):Bool {
		return _pixelSnapping = value;
	}

	@:isVar public var numVertices(get, set):Int;

	public function get_numVertices():Int {
		return _vertexData.numVertices;
	}

	@:isVar public var numIndices(get, set):Int;

	public function get_numIndices():Int {
		return _indexData.numIndices;
	}

	@:isVar public var numTriangles(get, never):Int;

	public function get_numTriangles():Int {
		return _indexData.numTriangles;
	}

	@:isVar public var vertexFormat(get, never):VertexDataFormat;

	public function get_vertexFormat():VertexDataFormat {
		return _style.vertexFormat;
	}

	function set_numVertices(value:Int):Int {
		return value;
	}

	function set_numIndices(value:Int):Int {
		return value;
	}
}
