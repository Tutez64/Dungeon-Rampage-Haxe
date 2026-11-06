package starling.text;

import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.StyleSheet;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.MeshBatch;
import starling.display.Quad;
import starling.display.Sprite;
import starling.rendering.Painter;
import starling.styles.MeshStyle;
import starling.utils.RectangleUtil;
import starling.utils.SystemUtil;
import flash.errors.ArgumentError;

class TextField extends DisplayObjectContainer {
	static inline final COMPOSITOR_DATA_NAME = "starling.display.TextField.compositors";

	static var sDefaultTextureFormat:String = "bgraPacked4444";

	static var sMatrix:Matrix = new Matrix();

	static var sDefaultCompositor:ITextCompositor = new TrueTypeCompositor();

	static var sStringCache:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var _text:String;

	var _options:TextOptions;

	var _format:TextFormat;

	var _textBounds:Rectangle;

	var _hitArea:Rectangle;

	var _compositor:ITextCompositor;

	var _requiresRecomposition:Bool = false;

	var _border:DisplayObjectContainer;

	var _meshBatch:MeshBatch;

	var _customStyle:MeshStyle;

	var _defaultStyle:MeshStyle;

	var _recomposing:Bool = false;

	public function new(width:Int, height:Int, text:String = "", format:TextFormat = null, options:TextOptions = null) {
		super();
		_text = ASCompat.stringAsBool(text) ? text : "";
		_hitArea = new Rectangle(0, 0, width, height);
		_requiresRecomposition = true;
		_compositor = sDefaultCompositor;
		_format = format != null ? format.clone() : new TextFormat();
		_format.addEventListener("change", (cast setRequiresRecomposition));
		_options = options != null ? options.clone() : new TextOptions();
		_options.addEventListener("change", (cast setRequiresRecomposition));
		_meshBatch = new MeshBatch();
		_meshBatch.touchable = false;
		_meshBatch.pixelSnapping = true;
		addChild(_meshBatch);
	}

	@:isVar public static var defaultTextureFormat(get, set):String;

	static public function get_defaultTextureFormat():String {
		return sDefaultTextureFormat;
	}

	static function set_defaultTextureFormat(value:String):String {
		return sDefaultTextureFormat = value;
	}

	@:isVar public static var defaultCompositor(get, set):ITextCompositor;

	static public function get_defaultCompositor():ITextCompositor {
		return sDefaultCompositor;
	}

	static function set_defaultCompositor(value:ITextCompositor):ITextCompositor {
		return sDefaultCompositor = value;
	}

	public static function updateEmbeddedFonts() {
		SystemUtil.updateEmbeddedFonts();
	}

	public static function registerCompositor(compositor:ITextCompositor, fontName:String) {
		if (fontName == null) {
			throw new ArgumentError("fontName must not be null");
		}
		compositors[convertToLowerCase(fontName)] = compositor;
	}

	public static function unregisterCompositor(fontName:String, dispose:Bool = true) {
		fontName = convertToLowerCase(fontName);
		if (dispose && compositors.exists(fontName)) {
			compositors[fontName].dispose();
		}
		compositors.remove(fontName);
	}

	public static function getCompositor(fontName:String):ITextCompositor {
		return ASCompat.coerce(compositors[convertToLowerCase(fontName)], starling.text.ITextCompositor);
	}

	public static function registerBitmapFont(bitmapFont:BitmapFont, name:String = null):String {
		if (name == null) {
			name = bitmapFont.name;
		}
		registerCompositor(bitmapFont, name);
		return name;
	}

	public static function unregisterBitmapFont(name:String, dispose:Bool = true) {
		unregisterCompositor(name, dispose);
	}

	public static function getBitmapFont(name:String):BitmapFont {
		return ASCompat.reinterpretAs(getCompositor(name), BitmapFont);
	}

	@:isVar static var compositors(get, never):ASDictionary<ASAny, ASAny>;

	static function get_compositors():ASDictionary<ASAny, ASAny> {
		var _loc1_ = ASDictionary.asDictionary(Starling.painter.sharedData["starling.display.TextField.compositors"]);
		if (_loc1_ == null) {
			_loc1_ = new ASDictionary<ASAny, ASAny>();
			Starling.painter.sharedData["starling.display.TextField.compositors"] = _loc1_;
		}
		return _loc1_;
	}

	static function convertToLowerCase(string:String):String {
		var _loc2_:String = sStringCache[string];
		if (_loc2_ == null) {
			_loc2_ = string.toLowerCase();
			sStringCache[string] = _loc2_;
		}
		return _loc2_;
	}

	override public function dispose() {
		_format.removeEventListener("change", (cast setRequiresRecomposition));
		_options.removeEventListener("change", (cast setRequiresRecomposition));
		_compositor.clearMeshBatch(_meshBatch);
		super.dispose();
	}

	override public function render(painter:Painter) {
		if (_requiresRecomposition) {
			recompose();
		}
		super.render(painter);
	}

	function recompose() {
		var _loc1_:String = null;
		var _loc2_:ITextCompositor = null;
		if (_requiresRecomposition) {
			_recomposing = true;
			_compositor.clearMeshBatch(_meshBatch);
			_loc1_ = _format.font;
			_loc2_ = getCompositor(_loc1_);
			if (_loc2_ == null && _loc1_ == "mini") {
				_loc2_ = new BitmapFont();
				registerCompositor(_loc2_, _loc1_);
			}
			_compositor = _loc2_ != null ? _loc2_ : sDefaultCompositor;
			updateText();
			updateBorder();
			_requiresRecomposition = false;
			_recomposing = false;
		}
	}

	function updateText() {
		var _loc1_ = _hitArea.width;
		var _loc2_ = _hitArea.height;
		if (isHorizontalAutoSize && !_options.isHtmlText) {
			_loc1_ = 100000;
		}
		if (isVerticalAutoSize) {
			_loc2_ = 100000;
		}
		_meshBatch.x = _meshBatch.y = 0;
		_options.textureScale = Starling.contentScaleFactor;
		_compositor.fillMeshBatch(_meshBatch, _loc1_, _loc2_, _text, _format, _options);
		if (_customStyle != null) {
			_meshBatch.style = _customStyle;
		} else {
			_defaultStyle = _compositor.getDefaultMeshStyle(_defaultStyle, _format, _options);
			if (_defaultStyle != null) {
				_meshBatch.style = _defaultStyle;
			}
		}
		if (_options.autoSize != "none") {
			_textBounds = _meshBatch.getBounds(_meshBatch, _textBounds);
			if (isHorizontalAutoSize) {
				_meshBatch.x = _textBounds.x = -_textBounds.x;
				_hitArea.width = _textBounds.width;
				_textBounds.x = 0;
			}
			if (isVerticalAutoSize) {
				_meshBatch.y = _textBounds.y = -_textBounds.y;
				_hitArea.height = _textBounds.height;
				_textBounds.y = 0;
			}
		} else {
			_textBounds = null;
		}
	}

	function updateBorder() {
		if (_border == null) {
			return;
		}
		var _loc4_ = _hitArea.width;
		var _loc6_ = _hitArea.height;
		var _loc1_ = ASCompat.reinterpretAs(_border.getChildAt(0), Quad);
		var _loc3_ = ASCompat.reinterpretAs(_border.getChildAt(1), Quad);
		var _loc5_ = ASCompat.reinterpretAs(_border.getChildAt(2), Quad);
		var _loc2_ = ASCompat.reinterpretAs(_border.getChildAt(3), Quad);
		_loc1_.width = _loc4_;
		_loc1_.height = 1;
		_loc5_.width = _loc4_;
		_loc5_.height = 1;
		_loc2_.width = 1;
		_loc2_.height = _loc6_;
		_loc3_.width = 1;
		_loc3_.height = _loc6_;
		_loc3_.x = _loc4_ - 1;
		_loc5_.y = _loc6_ - 1;
		_loc1_.color = _loc3_.color = _loc5_.color = _loc2_.color = _format.color;
	}

	public function setRequiresRecomposition() {
		if (!_recomposing) {
			_requiresRecomposition = true;
			setRequiresRedraw();
		}
	}

	@:isVar var isHorizontalAutoSize(get, never):Bool;

	function get_isHorizontalAutoSize():Bool {
		return _options.autoSize == "horizontal" || _options.autoSize == "bothDirections";
	}

	@:isVar var isVerticalAutoSize(get, never):Bool;

	function get_isVerticalAutoSize():Bool {
		return _options.autoSize == "vertical" || _options.autoSize == "bothDirections";
	}

	@:isVar public var textBounds(get, never):Rectangle;

	public function get_textBounds():Rectangle {
		return getTextBounds(this);
	}

	override public function getBounds(targetSpace:DisplayObject, out:Rectangle = null):Rectangle {
		if (_requiresRecomposition) {
			recompose();
		}
		getTransformationMatrix(targetSpace, sMatrix);
		return RectangleUtil.getBounds(_hitArea, sMatrix, out);
	}

	public function getTextBounds(targetSpace:DisplayObject, out:Rectangle = null):Rectangle {
		if (_requiresRecomposition) {
			recompose();
		}
		if (_textBounds == null) {
			_textBounds = _meshBatch.getBounds(this);
		}
		getTransformationMatrix(targetSpace, sMatrix);
		return RectangleUtil.getBounds(_textBounds, sMatrix, out);
	}

	override public function hitTest(localPoint:Point):DisplayObject {
		if (!visible || !touchable || !hitTestMask(localPoint)) {
			return null;
		}
		if (_hitArea.containsPoint(localPoint)) {
			return this;
		}
		return null;
	}

	override public function set_width(value:Float):Float {
		_hitArea.width = value / ASCompat.toNumber(if (ASCompat.floatAsBool(scaleX)) scaleX else 1);
		setRequiresRecomposition();
		return value;
	}

	override public function set_height(value:Float):Float {
		_hitArea.height = value / ASCompat.toNumber(if (ASCompat.floatAsBool(scaleY)) scaleY else 1);
		setRequiresRecomposition();
		return value;
	}

	@:isVar public var text(get, set):String;

	public function get_text():String {
		return _text;
	}

	function set_text(value:String):String {
		if (value == null) {
			value = "";
		}
		if (_text != value) {
			_text = value;
			setRequiresRecomposition();
		}
		return value;
	}

	@:isVar public var format(get, set):TextFormat;

	public function get_format():TextFormat {
		return _format;
	}

	function set_format(value:TextFormat):TextFormat {
		if (value == null) {
			throw new ArgumentError("format cannot be null");
		}
		_format.copyFrom(value);
		return value;
	}

	@:isVar var options(get, never):TextOptions;

	function get_options():TextOptions {
		return _options;
	}

	@:isVar public var border(get, set):Bool;

	public function get_border():Bool {
		return _border != null;
	}

	function set_border(value:Bool):Bool {
		var _loc2_ = 0;
		if (value && _border == null) {
			_border = new Sprite();
			addChild(_border);
			_loc2_ = 0;
			while (_loc2_ < 4) {
				_border.addChild(new Quad(1, 1));
				_loc2_++;
			}
			updateBorder();
		} else if (!value && _border != null) {
			_border.removeFromParent(true);
			_border = null;
		}
		return value;
	}

	@:isVar public var autoScale(get, set):Bool;

	public function get_autoScale():Bool {
		return _options.autoScale;
	}

	function set_autoScale(value:Bool):Bool {
		return _options.autoScale = value;
	}

	@:isVar public var autoSize(get, set):String;

	public function get_autoSize():String {
		return _options.autoSize;
	}

	function set_autoSize(value:String):String {
		return _options.autoSize = value;
	}

	@:isVar public var wordWrap(get, set):Bool;

	public function get_wordWrap():Bool {
		return _options.wordWrap;
	}

	function set_wordWrap(value:Bool):Bool {
		return _options.wordWrap = value;
	}

	@:isVar public var batchable(get, set):Bool;

	public function get_batchable():Bool {
		return _meshBatch.batchable;
	}

	function set_batchable(value:Bool):Bool {
		return _meshBatch.batchable = value;
	}

	@:isVar public var isHtmlText(get, set):Bool;

	public function get_isHtmlText():Bool {
		return _options.isHtmlText;
	}

	function set_isHtmlText(value:Bool):Bool {
		return _options.isHtmlText = value;
	}

	@:isVar public var styleSheet(get, set):StyleSheet;

	public function get_styleSheet():StyleSheet {
		return _options.styleSheet;
	}

	function set_styleSheet(value:StyleSheet):StyleSheet {
		return _options.styleSheet = value;
	}

	@:isVar public var padding(get, set):Float;

	public function get_padding():Float {
		return _options.padding;
	}

	function set_padding(value:Float):Float {
		return _options.padding = value;
	}

	@:isVar public var pixelSnapping(get, set):Bool;

	public function get_pixelSnapping():Bool {
		return _meshBatch.pixelSnapping;
	}

	function set_pixelSnapping(value:Bool):Bool {
		return _meshBatch.pixelSnapping = value;
	}

	@:isVar public var style(get, set):MeshStyle;

	public function get_style():MeshStyle {
		if (_requiresRecomposition) {
			recompose();
		}
		return _meshBatch.style;
	}

	function set_style(value:MeshStyle):MeshStyle {
		_customStyle = value;
		setRequiresRecomposition();
		return value;
	}
}
