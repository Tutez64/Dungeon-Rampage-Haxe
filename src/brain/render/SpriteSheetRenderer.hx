package brain.render;

import brain.assetRepository.SpriteSheetAsset;
import brain.clock.GameClock;
import brain.utils.MemoryTracker;
import brain.workLoop.WorkComponent;
import flash.display.BitmapData;
import flash.geom.Point;

class SpriteSheetRenderer extends BitmapRenderer {
	var mSpriteSheet:SpriteSheetAsset;

	var mXIndex:UInt = (0 : UInt);

	var mYIndex:UInt = (0 : UInt);

	public function new(workComponent:WorkComponent, sheet:SpriteSheetAsset) {
		super(workComponent);
		mSpriteSheet = sheet;
		MemoryTracker.track(this, "SpriteSheetRenderer - created in SpriteSheetRenderer()", "brain");
	}

	override public function destroy() {
		mSpriteSheet = null;
		super.destroy();
	}

	@:isVar public var spriteSheet(never, set):SpriteSheetAsset;

	public function set_spriteSheet(value:SpriteSheetAsset):SpriteSheetAsset {
		return mSpriteSheet = value;
	}

	public function setFrameIndexes(x:UInt, y:UInt) {
		mXIndex = x;
		mYIndex = y;
	}

	function getCurrentFrame():BitmapData {
		return mSpriteSheet.getFrame(mXIndex, mYIndex);
	}

	function getCurrentCenter():Point {
		return mSpriteSheet.getCenter(mXIndex, mYIndex);
	}

	public function updateToCurrentFrame() {
		this.center = getCurrentCenter();
		this.bitmapData = getCurrentFrame();
	}

	override function onFrame(gameClock:GameClock) {
		super.onFrame(gameClock);
		this.updateToCurrentFrame();
	}

	public function play(startingFrame:UInt = (0 : UInt), loop:Bool = true, finishedCallback:ASFunction = null) {
		setFrame(startingFrame);
	}

	public function stop() {}

	@:isVar public var currentFrame(get, never):UInt;

	public function get_currentFrame():UInt {
		return mXIndex;
	}

	@:isVar public var heading(get, set):Float;

	public function set_heading(value:Float):Float {
		return value;
	}

	@:isVar public var loop(get, never):Bool;

	public function get_loop():Bool {
		return false;
	}

	public function setFrame(frameNumber:UInt) {
		this.mXIndex = frameNumber;
	}

	function get_heading():Float {
		return 0;
	}
}
