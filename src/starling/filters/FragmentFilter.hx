package starling.filters;

import flash.errors.IllegalOperationError;
import flash.geom.Matrix3D;
import flash.geom.Rectangle;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.Stage;
import starling.events.Event;
import starling.events.EventDispatcher;
import starling.rendering.FilterEffect;
import starling.rendering.IndexData;
import starling.rendering.Painter;
import starling.rendering.VertexData;
import starling.textures.Texture;
import starling.utils.ContextRestoreRegistry;
import starling.utils.MatrixUtil;
import starling.utils.Padding;
import starling.utils.Pool;
import starling.utils.RectangleUtil;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import starling.display.DisplayObject;
import starling.display.Mesh;
import starling.rendering.IndexData;
import starling.rendering.VertexData;
import starling.textures.Texture;
import flash.errors.ArgumentError;

/*use*/ /*namespace*/ /*starling_internal*/ class FragmentFilter extends EventDispatcher {
	static var sRestoreRegistry:ContextRestoreRegistry = new ContextRestoreRegistry(0, restoreFilter);

	static var sMatrix3D:Matrix3D = new Matrix3D();

	var _quad:FilterQuad;

	var _target:DisplayObject;

	var _effect:FilterEffect;

	var _vertexData:VertexData;

	var _indexData:IndexData;

	var _padding:Padding;

	var _helper:FilterHelper;

	var _resolution:Float = Math.NaN;

	var _antiAliasing:Int = 0;

	var _textureFormat:String;

	var _textureSmoothing:String;

	var _alwaysDrawToBackBuffer:Bool = false;

	var _maintainResolutionAcrossPasses:Bool = false;

	var _cacheRequested:Bool = false;

	var _cached:Bool = false;

	var _restoreList:ASDictionary<ASAny, ASAny>;

	public function new() {
		super();
		_resolution = 1;
		_textureFormat = "bgra";
		_textureSmoothing = Starling.currentDefaultTextureSmoothing;
		_restoreList = sRestoreRegistry.add(this, Starling.current.stage3D);
	}

	static function restoreFilter(filter:FragmentFilter, event:ASObject) {
		filter.onContextCreated(event);
	}

	public function dispose() {
		_restoreList.remove(this);
		if (_helper != null) {
			_helper.dispose();
		}
		if (_effect != null) {
			_effect.dispose();
		}
		if (_quad != null) {
			_quad.dispose();
		}
		_effect = null;
		_quad = null;
	}

	function onContextCreated(event:ASObject) {
		setRequiresRedraw();
	}

	public function render(painter:Painter) {
		if (_target == null) {
			throw new IllegalOperationError("Cannot render filter without target");
		}
		if (_target.is3D) {
			_cached = _cacheRequested = false;
		}
		if (!_cached || _cacheRequested) {
			renderPasses(painter, _cacheRequested);
			_cacheRequested = false;
		} else if (_quad.visible) {
			_quad.render(painter);
		}
	}

	function renderPasses(painter:Painter, forCache:Bool) {
		var _loc4_:Rectangle = null;
		var _loc3_:Texture = null;
		if (_helper == null) {
			_helper = new FilterHelper(_textureFormat);
		}
		if (_quad == null) {
			_quad = new FilterQuad(_textureSmoothing);
		} else {
			_helper.putTexture(_quad.texture);
			_quad.texture = null;
		}
		var _loc11_ = Pool.getRectangle();
		var _loc10_ = false;
		var _loc12_ = _resolution;
		var _loc6_ = ASCompat.coerce(if (_target.stage != null) _target.stage else _target.parent, starling.display.DisplayObject);
		var _loc7_ = Std.isOfType(_loc6_, Stage);
		var _loc8_ = Starling.current.stage;
		if (!forCache && (_alwaysDrawToBackBuffer || _target.requiresRedraw)) {
			_loc10_ = painter.state.alpha == 1 && (!_maintainResolutionAcrossPasses || _resolution == 1);
			painter.excludeFromCache(_target);
		}
		if (_target == Starling.current.root) {
			_loc8_.getStageBounds(_target, _loc11_);
		} else {
			_target.getBounds(_loc6_, _loc11_);
			if (!forCache && _loc7_) {
				_loc4_ = _loc8_.getStageBounds(null, Pool.getRectangle());
				RectangleUtil.intersect(_loc11_, _loc4_, _loc11_);
				Pool.putRectangle(_loc4_);
			}
		}
		_quad.visible = !_loc11_.isEmpty();
		if (!_quad.visible) {
			Pool.putRectangle(_loc11_);
			return;
		}
		if (_padding != null) {
			RectangleUtil.extend(_loc11_, _padding.left, _padding.right, _padding.top, _padding.bottom);
		}
		RectangleUtil.extendToWholePixels(_loc11_, Starling.contentScaleFactor);
		_helper.textureScale = Starling.contentScaleFactor * _resolution;
		_helper.projectionMatrix3D = painter.state.projectionMatrix3D;
		_helper.renderTarget = painter.state.renderTarget;
		_helper.clipRect = painter.state.clipRect;
		_helper.targetBounds = _loc11_;
		_helper.target = _target;
		_helper.start(numPasses, _loc10_);
		_quad.setBounds(_loc11_);
		_resolution = 1;
		var _loc9_ = painter.cacheEnabled;
		var _loc5_ = _helper.getTexture();
		painter.cacheEnabled = false;
		painter.pushState();
		painter.state.alpha = 1;
		painter.state.clipRect = null;
		painter.state.setRenderTarget(_loc5_, true, _antiAliasing);
		painter.state.setProjectionMatrix(_loc11_.x, _loc11_.y, _loc5_.root.width, _loc5_.root.height, _loc8_.stageWidth, _loc8_.stageHeight,
			_loc8_.cameraPosition);
		_target.render(painter);
		painter.finishMeshBatch();
		painter.state.setModelviewMatricesToIdentity();
		_loc3_ = process(painter, _helper, _loc5_);
		painter.popState();
		painter.cacheEnabled = _loc9_;
		if (_loc3_ != null) {
			painter.pushState();
			if (_target.is3D) {
				painter.state.setModelviewMatricesToIdentity();
			} else {
				_quad.moveVertices(_loc6_, _target);
			}
			_quad.texture = _loc3_;
			_quad.render(painter);
			painter.finishMeshBatch();
			painter.popState();
		}
		_helper.target = null;
		_helper.putTexture(_loc5_);
		_resolution = _loc12_;
		Pool.putRectangle(_loc11_);
	}

	public function process(painter:Painter, helper:IFilterHelper, input0:Texture = null, input1:Texture = null, input2:Texture = null,
			input3:Texture = null):Texture {
		var _loc8_:Matrix3D = null;
		var _loc10_:Texture = null;
		var _loc9_ = this.effect;
		var _loc7_ = helper.getTexture(_resolution);
		var _loc11_:Rectangle = null;
		if (_loc7_ != null) {
			_loc10_ = _loc7_;
			_loc8_ = MatrixUtil.createPerspectiveProjectionMatrix(0, 0, _loc7_.root.width / _resolution, _loc7_.root.height / _resolution, 0, 0, null,
				sMatrix3D);
		} else {
			_loc11_ = helper.targetBounds;
			_loc10_ = ASCompat.reinterpretAs(helper, FilterHelper).renderTarget;
			_loc8_ = ASCompat.reinterpretAs(helper, FilterHelper).projectionMatrix3D;
			_loc9_.textureSmoothing = _textureSmoothing;
			painter.state.clipRect = ASCompat.reinterpretAs(helper, FilterHelper).clipRect;
			painter.state.projectionMatrix3D.copyFrom(_loc8_);
		}
		painter.state.renderTarget = _loc10_;
		painter.prepareToDraw();
		painter.drawCount += 1;
		input0.setupVertexPositions(vertexData, 0, "position", _loc11_);
		input0.setupTextureCoordinates(vertexData);
		_loc9_.texture = input0;
		_loc9_.mvpMatrix3D = _loc8_;
		_loc9_.uploadVertexData(vertexData);
		_loc9_.uploadIndexData(indexData);
		_loc9_.render(0, indexData.numTriangles);
		return _loc7_;
	}

	function createEffect():FilterEffect {
		return new FilterEffect();
	}

	public function cache() {
		_cached = _cacheRequested = true;
		setRequiresRedraw();
	}

	public function clearCache() {
		_cached = _cacheRequested = false;
		setRequiresRedraw();
	}

	override public function addEventListener(type:String, listener:ASFunction) {
		if (type == "enterFrame" && _target != null) {
			_target.addEventListener("enterFrame", onEnterFrame__starling_filters_FragmentFilter);
		}
		super.addEventListener(type, listener);
	}

	override public function removeEventListener(type:String, listener:ASFunction) {
		if (type == "enterFrame" && _target != null) {
			_target.removeEventListener(type, onEnterFrame__starling_filters_FragmentFilter);
		}
		super.removeEventListener(type, listener);
	}

	function onEnterFrame__starling_filters_FragmentFilter /*redefined private*/ (event:Event) {
		dispatchEvent(event);
	}

	@:isVar var effect(get, never):FilterEffect;

	function get_effect():FilterEffect {
		if (_effect == null) {
			_effect = createEffect();
		}
		return _effect;
	}

	@:isVar var vertexData(get, never):VertexData;

	function get_vertexData():VertexData {
		if (_vertexData == null) {
			_vertexData = new VertexData(effect.vertexFormat, 4);
		}
		return _vertexData;
	}

	@:isVar var indexData(get, never):IndexData;

	function get_indexData():IndexData {
		if (_indexData == null) {
			_indexData = new IndexData(6);
			_indexData.addQuad((0 : UInt), (1 : UInt), (2 : UInt), (3 : UInt));
		}
		return _indexData;
	}

	function setRequiresRedraw() {
		dispatchEventWith("change");
		if (_target != null) {
			_target.setRequiresRedraw();
		}
		if (_cached) {
			_cacheRequested = true;
		}
	}

	@:isVar public var numPasses(get, never):Int;

	public function get_numPasses():Int {
		return 1;
	}

	function onTargetAssigned(target:DisplayObject) {}

	@:isVar public var padding(get, set):Padding;

	public function get_padding():Padding {
		if (_padding == null) {
			_padding = new Padding();
			_padding.addEventListener("change", (cast setRequiresRedraw));
		}
		return _padding;
	}

	function set_padding(value:Padding):Padding {
		padding.copyFrom(value);
		return value;
	}

	@:isVar public var isCached(get, never):Bool;

	public function get_isCached():Bool {
		return _cached;
	}

	@:isVar public var resolution(get, set):Float;

	public function get_resolution():Float {
		return _resolution;
	}

	function set_resolution(value:Float):Float {
		if (value != _resolution) {
			if (value <= 0) {
				throw new ArgumentError("resolution must be > 0");
			}
			_resolution = value;
			setRequiresRedraw();
		}
		return value;
	}

	@:isVar var maintainResolutionAcrossPasses(get, set):Bool;

	function get_maintainResolutionAcrossPasses():Bool {
		return _maintainResolutionAcrossPasses;
	}

	function set_maintainResolutionAcrossPasses(value:Bool):Bool {
		return _maintainResolutionAcrossPasses = value;
	}

	@:isVar public var antiAliasing(get, set):Int;

	public function get_antiAliasing():Int {
		return _antiAliasing;
	}

	function set_antiAliasing(value:Int):Int {
		if (value != _antiAliasing) {
			_antiAliasing = value;
			setRequiresRedraw();
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
			if (_quad != null) {
				_quad.textureSmoothing = value;
			}
			setRequiresRedraw();
		}
		return value;
	}

	@:isVar public var textureFormat(get, set):String;

	public function get_textureFormat():String {
		return _textureFormat;
	}

	function set_textureFormat(value:String):String {
		if (value != _textureFormat) {
			_textureFormat = value;
			if (_helper != null) {
				_helper.textureFormat = value;
			}
			setRequiresRedraw();
		}
		return value;
	}

	@:isVar public var alwaysDrawToBackBuffer(get, set):Bool;

	public function get_alwaysDrawToBackBuffer():Bool {
		return _alwaysDrawToBackBuffer;
	}

	function set_alwaysDrawToBackBuffer(value:Bool):Bool {
		return _alwaysDrawToBackBuffer = value;
	}

	/*starling_internal*/
	public function setTarget(target:DisplayObject) {
		var _loc2_:DisplayObject = null;
		if (target != _target) {
			_loc2_ = _target;
			_target = target;
			if (target == null) {
				if (_helper != null) {
					_helper.purge();
				}
				if (_effect != null) {
					_effect.purgeBuffers();
				}
				if (_quad != null) {
					_quad.disposeTexture();
				}
			}
			if (_loc2_ != null) {
				_loc2_.filter = null;
				_loc2_.removeEventListener("enterFrame", onEnterFrame__starling_filters_FragmentFilter);
			}
			if (target != null) {
				if (hasEventListener("enterFrame")) {
					target.addEventListener("enterFrame", onEnterFrame__starling_filters_FragmentFilter);
				}
				onTargetAssigned(target);
			}
		}
	}
}

private class FilterQuad extends Mesh {
	static var sMatrix:Matrix = new Matrix();

	public function new(smoothing:String) {
		var _loc2_ = new VertexData(null, 4);
		_loc2_.numVertices = 4;
		var _loc3_ = new IndexData(6);
		_loc3_.addQuad((0 : UInt), (1 : UInt), (2 : UInt), (3 : UInt));
		super(_loc2_, _loc3_);
		textureSmoothing = smoothing;
		pixelSnapping = false;
	}

	override public function dispose() {
		disposeTexture();
		super.dispose();
	}

	public function disposeTexture() {
		if (texture != null) {
			texture.dispose();
			texture = null;
		}
	}

	public function moveVertices(sourceSpace:DisplayObject, targetSpace:DisplayObject) {
		if (targetSpace.is3D) {
			throw new Error("cannot move vertices into 3D space");
		}
		if (sourceSpace != targetSpace) {
			targetSpace.getTransformationMatrix(sourceSpace, sMatrix).invert();
			vertexData.transformPoints("position", sMatrix);
		}
	}

	public function setBounds(bounds:Rectangle) {
		var _loc2_ = this.vertexData;
		var _loc3_ = "position";
		_loc2_.setPoint(0, _loc3_, bounds.x, bounds.y);
		_loc2_.setPoint(1, _loc3_, bounds.right, bounds.y);
		_loc2_.setPoint(2, _loc3_, bounds.x, bounds.bottom);
		_loc2_.setPoint(3, _loc3_, bounds.right, bounds.bottom);
	}

	override public function set_texture(value:Texture):Texture {
		super.texture = value;
		if (value != null) {
			value.setupTextureCoordinates(vertexData);
		}
		return value;
	}
}
