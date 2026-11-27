package starling.core;

import flash.geom.Rectangle;
import flash.system.System;
import starling.display.DisplayObject;
import starling.display.Quad;
import starling.display.Sprite;
import starling.events.EnterFrameEvent;
import starling.rendering.Painter;
import starling.styles.MeshStyle;
import starling.text.TextField;

/*internal*/
class StatsDisplay extends Sprite {
	static inline final UPDATE_INTERVAL:Float = 0.5;

	static inline final B_TO_MB:Float = 9.5367431640625e-7;

	var _background:Quad;

	var _labels:TextField;

	var _values:TextField;

	var _frameCount:Int = 0;

	var _totalTime:Float = 0;

	var _fps:Float = 0;

	var _memory:Float = 0;

	var _gpuMemory:Float = 0;

	var _drawCount:Int = 0;

	var _skipCount:Int = 0;

	var _showSkipped:Bool = false;

	public function new() {
		var _loc1_:String = null;
		_loc1_ = "mini";
		var _loc3_ = Math.NaN;
		_loc3_ = -1;
		var _loc4_ = 0;
		_loc4_ = 16777215;
		var _loc2_ = Math.NaN;
		_loc2_ = 90;
		var _loc5_ = Math.NaN;
		_loc5_ = 45;
		super();
		_labels = new TextField(90, 45);
		_labels.format.setTo("mini", -1, (16777215 : UInt), "left", "top");
		_labels.batchable = true;
		_labels.x = 2;
		_values = new TextField(90 - 1, 45, "");
		_values.format.setTo("mini", -1, (16777215 : UInt), "right", "top");
		_values.batchable = true;
		_background = new Quad(90, 45, (0 : UInt));
		updateLabels();
		if (_background.style.type != MeshStyle) {
			_background.style = new MeshStyle();
		}
		if (_labels.style.type != MeshStyle) {
			_labels.style = new MeshStyle();
		}
		if (_values.style.type != MeshStyle) {
			_values.style = new MeshStyle();
		}
		addChild(_background);
		addChild(_labels);
		addChild(_values);
		addEventListener("addedToStage", (cast onAddedToStage));
		addEventListener("removedFromStage", (cast onRemovedFromStage));
	}

	function onAddedToStage() {
		addEventListener("enterFrame", onEnterFrame);
		Starling.current.addEventListener("skipFrame", (cast onSkipFrame));
		_totalTime = _frameCount = _skipCount = 0;
		update();
	}

	function onRemovedFromStage() {
		removeEventListener("enterFrame", onEnterFrame);
		Starling.current.removeEventListener("skipFrame", (cast onSkipFrame));
	}

	function onEnterFrame(event:EnterFrameEvent) {
		_totalTime += event.passedTime;
		_frameCount = _frameCount + 1;
		if (_totalTime > 0.5) {
			update();
			_frameCount = _skipCount = ASCompat.floatToInt(_totalTime = 0);
		}
	}

	function onSkipFrame() {
		_skipCount += 1;
	}

	public function update() {
		_background.color = (_skipCount > _frameCount / 2 ? (16128 : UInt) : (0 : UInt) : UInt);
		_fps = _totalTime > 0 ? _frameCount / _totalTime : 0;
		_memory = System.totalMemory * 9.5367431640625e-7;
		_gpuMemory = supportsGpuMem ? ASCompat.toNumber((Starling.context : ASAny)["totalGPUMemory"]) * 9.5367431640625e-7 : -1;
		var _loc5_ = _totalTime > 0 ? _skipCount / _totalTime : 0;
		var _loc6_ = _showSkipped ? ASCompat.toFixed(_loc5_, (_loc5_ < 100 ? (1 : UInt) : (0 : UInt) : UInt)) : "";
		var _loc1_ = ASCompat.toFixed(_fps, (_fps < 100 ? (1 : UInt) : (0 : UInt) : UInt));
		var _loc3_ = ASCompat.toFixed(_memory, (_memory < 100 ? (1 : UInt) : (0 : UInt) : UInt));
		var _loc2_ = ASCompat.toFixed(_gpuMemory, (_gpuMemory < 100 ? (1 : UInt) : (0 : UInt) : UInt));
		var _loc4_ = Std.string((_totalTime > 0 ? _drawCount - 2 : _drawCount));
		_values.text = _loc1_ + "\n" + (_showSkipped ? _loc6_ + "\n" : "") + _loc3_ + "\n" + (_gpuMemory >= 0 ? _loc2_ + "\n" : "") + _loc4_;
	}

	function updateLabels() {
		var _loc1_:Array<ASAny> = ["frames/sec:"];
		if (_showSkipped) {
			_loc1_.insert(_loc1_.length, "skipped/sec:");
		}
		_loc1_.insert(_loc1_.length, "std memory:");
		if (supportsGpuMem) {
			_loc1_.insert(_loc1_.length, "gpu memory:");
		}
		_loc1_.insert(_loc1_.length, "draw calls:");
		_labels.text = _loc1_.join("\n");
		_background.height = _labels.textBounds.height + 4;
	}

	override public function render(painter:Painter) {
		painter.excludeFromCache(this);
		painter.finishMeshBatch();
		super.render(painter);
	}

	override public function getBounds(targetSpace:DisplayObject, out:Rectangle = null):Rectangle {
		return _background.getBounds(targetSpace, out);
	}

	@:isVar var supportsGpuMem(get, never):Bool;

	function get_supportsGpuMem():Bool {
		return (Starling.context : ASAny).hasOwnProperty("totalGPUMemory");
	}

	@:isVar public var drawCount(get, set):Int;

	public function get_drawCount():Int {
		return _drawCount;
	}

	function set_drawCount(value:Int):Int {
		return _drawCount = value;
	}

	@:isVar public var fps(get, set):Float;

	public function get_fps():Float {
		return _fps;
	}

	function set_fps(value:Float):Float {
		return _fps = value;
	}

	@:isVar public var memory(get, set):Float;

	public function get_memory():Float {
		return _memory;
	}

	function set_memory(value:Float):Float {
		return _memory = value;
	}

	@:isVar public var gpuMemory(get, set):Float;

	public function get_gpuMemory():Float {
		return _gpuMemory;
	}

	function set_gpuMemory(value:Float):Float {
		return _gpuMemory = value;
	}

	@:isVar public var showSkipped(get, set):Bool;

	public function get_showSkipped():Bool {
		return _showSkipped;
	}

	function set_showSkipped(value:Bool):Bool {
		_showSkipped = value;
		updateLabels();
		update();
		return value;
	}
}
