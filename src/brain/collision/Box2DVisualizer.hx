package brain.collision;

import box2D.dynamics.B2DebugDraw;
import box2D.dynamics.B2World;
import brain.clock.GameClock;
import flash.display.Sprite;

class Box2DVisualizer {
	var mB2World:B2World;

	var mRootSprite:Sprite;

	var mDebugDraw:B2DebugDraw;

	var mWantAllCollisions:Bool = false;

	var mWantNavigationCollisions:Bool = false;

	var mWantCombatCollisions:Bool = false;

	var mWantAStarVisuals:Bool = false;

	public function new(box2dWorld:B2World, wantAllCollisions:Bool = false, wantCombatCollisions:Bool = false, wantNavigationCollisions:Bool = false,
			wantAStarVisuals:Bool = false) {
		mB2World = box2dWorld;
		mRootSprite = new Sprite();
		mWantAllCollisions = wantAllCollisions;
		mWantNavigationCollisions = wantNavigationCollisions;
		mWantCombatCollisions = wantCombatCollisions;
		mWantAStarVisuals = wantAStarVisuals;
		setupDebugDraw();
	}

	function setupDebugDraw() {
		mRootSprite = new Sprite();
		mDebugDraw = new B2DebugDraw();
		var _loc1_ = new Sprite();
		mRootSprite.addChild(_loc1_);
		mDebugDraw.SetSprite(mRootSprite);
		mDebugDraw.SetDrawScale(1);
		mDebugDraw.SetAlpha(1);
		mDebugDraw.SetFillAlpha(0.5);
		mDebugDraw.SetLineThickness(1);
		if (mWantAllCollisions || mWantNavigationCollisions) {
			mDebugDraw.SetFlags(((B2DebugDraw.e_shapeBit : Int) | (B2DebugDraw.e_jointBit : Int) | (B2DebugDraw.e_controllerBit : Int) | (B2DebugDraw.e_aabbBit : Int) | (B2DebugDraw.e_pairBit : Int) | (B2DebugDraw.e_centerOfMassBit : Int) : UInt));
		}
		mB2World.SetDebugDraw(mDebugDraw);
		mRootSprite.x = 0;
		mRootSprite.y = 0;
	}

	@:isVar public var rootSprite(get, never):Sprite;

	public function get_rootSprite():Sprite {
		return mRootSprite;
	}

	public function update(gameClock:GameClock) {
		mB2World.DrawDebugData();
	}
}
