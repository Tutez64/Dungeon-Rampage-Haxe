package collision;

import box2D.collision.shapes.B2CircleShape;
import box2D.collision.shapes.B2PolygonShape;
import box2D.collision.shapes.B2Shape;
import box2D.common.math.B2Math;
import box2D.common.math.B2Transform;
import box2D.common.math.B2Vec2;
import box2D.common.B2Color;
import box2D.dynamics.B2World;
import brain.clock.GameClock;
import brain.collision.Box2DVisualizer;
import brain.logger.Logger;
import brain.sceneGraph.SceneGraphComponent;
import brain.workLoop.PreRenderWorkComponent;
import distributedObjects.Floor;
import facade.DBFacade;
import box2D.collision.shapes.B2CircleShape;
import box2D.collision.shapes.B2PolygonShape;
import box2D.collision.shapes.B2Shape;
import box2D.common.math.B2Transform;
import box2D.common.math.B2Vec2;

class DBBox2DVisualizer extends Box2DVisualizer {
	static inline final DEFAULT_LIFETIME = (24 : UInt);

	var mDBFacade:DBFacade;

	var mSceneGraphComponent:SceneGraphComponent;

	var mPreRenderWorkComponent:PreRenderWorkComponent;

	var mFloor:Floor;

	var mHeroCircleAttacks:Vector<CircleAttackRecord>;

	var mHeroPolyAttacks:Vector<PolygonShapeRecord>;

	var mRayCasts:Vector<RayCastDraw>;

	var mPolysToShow:Vector<PolygonShapeRecord> = new Vector();

	var mCirclesToShow:Vector<ShapeRecord> = new Vector();

	public function new(dbFacade:DBFacade, box2dWorld:B2World, wantAllCollisions:Bool = false, wantCombatCollisions:Bool = false,
			wantNavigationCollisions:Bool = false, wantAStarVisuals:Bool = false) {
		super(box2dWorld, wantAllCollisions, wantCombatCollisions, wantNavigationCollisions, wantAStarVisuals);
		mDBFacade = dbFacade;
		mSceneGraphComponent = new SceneGraphComponent(mDBFacade, "DBBox2DVisualizer");
		mPreRenderWorkComponent = new PreRenderWorkComponent(mDBFacade, "DBBox2DVisualizer");
		mSceneGraphComponent.addChild(rootSprite, (30 : UInt));
		mPreRenderWorkComponent.doEveryFrame(update);
		mDebugDraw.SetDrawScale(50);
		mHeroCircleAttacks = new Vector<CircleAttackRecord>();
		mHeroPolyAttacks = new Vector<PolygonShapeRecord>();
		mRayCasts = new Vector<RayCastDraw>();
	}

	override public function update(gameClock:GameClock) {
		var _loc5_:B2PolygonShape = null;
		var _loc4_:PolygonShapeRecord = null;
		var _loc7_ = (0 : UInt);
		var _loc8_ = (0 : UInt);
		var _loc9_:B2CircleShape = null;
		var _loc2_ = Math.NaN;
		super.update(gameClock);
		if (mWantAllCollisions || mWantCombatCollisions) {
			drawCombatCollisions();
		}
		var _loc3_ = new Vector<PolygonShapeRecord>();
		var _loc6_ = new B2Color(0, 0, 1);
		_loc7_ = (0 : UInt);
		while (_loc7_ < (mPolysToShow.length:UInt)) {
			_loc4_ = mPolysToShow[(_loc7_ : Int)];
			_loc5_ = _loc4_.mShape;
			mDebugDraw.DrawPolygon(_loc4_.mVerticies, _loc5_.GetVertexCount(), _loc6_);
			_loc4_.mLife--;
			if (_loc4_.mLife > 0) {
				_loc3_.push(_loc4_);
			}
			_loc7_++;
		}
		mPolysToShow = _loc3_;
		_loc8_ = (0 : UInt);
		while (_loc8_ < (mCirclesToShow.length:UInt)) {
			_loc9_ = ASCompat.reinterpretAs(mCirclesToShow[(_loc8_ : Int)].mShape, B2CircleShape);
			_loc2_ = _loc9_.GetRadius();
			mDebugDraw.DrawCircle(mCirclesToShow[(_loc8_ : Int)].mTransform.position, _loc2_, _loc6_);
			_loc8_++;
		}
	}

	function drawCombatCollisions() {
		var _loc10_ = (0 : UInt);
		var _loc9_:CircleAttackRecord = null;
		var _loc14_:B2CircleShape = null;
		var _loc7_:B2Vec2 = null;
		var _loc15_ = Math.NaN;
		var _loc8_:B2Vec2 = null;
		var _loc4_:B2Color = null;
		var _loc5_:PolygonShapeRecord = null;
		var _loc6_:B2PolygonShape = null;
		var _loc2_:B2Color = null;
		var _loc3_:RayCastDraw = null;
		var _loc1_ = new Vector<CircleAttackRecord>();
		_loc10_ = (0 : UInt);
		while (_loc10_ < (mHeroCircleAttacks.length:UInt)) {
			_loc9_ = mHeroCircleAttacks[(_loc10_ : Int)];
			_loc14_ = _loc9_.mCircle;
			_loc14_.GetLocalPosition();
			_loc7_ = B2Math.MulX(_loc9_.mTransform, _loc14_.GetLocalPosition());
			_loc15_ = _loc14_.GetRadius();
			_loc8_ = _loc9_.mTransform.R.col1;
			_loc4_ = new B2Color(1, 1, 1);
			_loc9_.mlife--;
			if (_loc9_.mlife > 0) {
				_loc1_.push(_loc9_);
			}
			mDebugDraw.DrawSolidCircle(_loc7_, _loc15_, _loc8_, _loc4_);
			_loc10_++;
		}
		mHeroCircleAttacks = _loc1_;
		var _loc12_ = new Vector<PolygonShapeRecord>();
		_loc10_ = (0 : UInt);
		while (_loc10_ < (mHeroPolyAttacks.length:UInt)) {
			_loc5_ = mHeroPolyAttacks[(_loc10_ : Int)];
			_loc5_.buildVerticies();
			_loc6_ = _loc5_.mShape;
			_loc2_ = new B2Color(1, 1, 1);
			mDebugDraw.DrawSolidPolygon(_loc5_.mVerticiesAsVector, _loc6_.GetVertexCount(), _loc2_);
			_loc5_.mLife--;
			if (_loc5_.mLife > 0) {
				_loc12_.push(_loc5_);
			}
			_loc10_++;
		}
		mHeroPolyAttacks = _loc12_;
		var _loc11_ = new B2Color(1, 0, 0);
		var _loc13_ = new Vector<RayCastDraw>();
		_loc10_ = (0 : UInt);
		while (_loc10_ < (mRayCasts.length:UInt)) {
			_loc3_ = mRayCasts[(_loc10_ : Int)];
			_loc3_.life--;
			mDebugDraw.DrawSegment(_loc3_.point1, _loc3_.point2, _loc11_);
			if (_loc3_.life > 0) {
				_loc13_.push(_loc3_);
			}
			_loc10_++;
		}
		mRayCasts = _loc13_;
	}

	public function reportCircleAttack(transform:B2Transform, circle:B2CircleShape, lifetimeInFrames:UInt = (24 : UInt)) {
		var _loc4_ = new CircleAttackRecord();
		_loc4_.mCircle = circle;
		_loc4_.mTransform = transform;
		_loc4_.mlife = lifetimeInFrames;
		mHeroCircleAttacks.push(_loc4_);
	}

	public function reportPolyAttack(transform:B2Transform, poly:B2PolygonShape, lifetimeInFrames:UInt = (24 : UInt)) {
		var _loc4_ = new PolygonShapeRecord();
		_loc4_.mShape = poly;
		_loc4_.mTransform = transform;
		_loc4_.mLife = lifetimeInFrames;
		_loc4_.buildVerticies();
		mHeroPolyAttacks.push(_loc4_);
	}

	public function reportShape(shape:B2Shape, transform:B2Transform, lifeTimeInFrames:UInt = (24 : UInt)) {
		var _loc4_:PolygonShapeRecord = null;
		var _loc5_:ShapeRecord = null;
		if (Std.isOfType(shape, B2PolygonShape)) {
			_loc4_ = new PolygonShapeRecord();
			_loc4_.mLife = lifeTimeInFrames;
			_loc4_.mShape = ASCompat.reinterpretAs(shape, B2PolygonShape);
			_loc4_.mTransform = transform;
			_loc4_.buildVerticies();
			mPolysToShow.push(_loc4_);
		} else if (Std.isOfType(shape, B2CircleShape)) {
			_loc5_ = new ShapeRecord();
			_loc5_.mLife = lifeTimeInFrames;
			_loc5_.mShape = shape;
			_loc5_.mTransform = transform;
			mCirclesToShow.push(_loc5_);
		} else {
			Logger.warn("Shape is neither a b2Polygon nor a b2circle.  Unable to visualize.");
		}
	}

	public function reportRayCast(point1:B2Vec2, point2:B2Vec2, lifeTimeInFrames:UInt = (24 : UInt)) {
		var _loc4_ = new RayCastDraw();
		_loc4_.point1 = point1.Copy();
		_loc4_.point2 = point2.Copy();
		_loc4_.life = lifeTimeInFrames;
		mRayCasts.push(_loc4_);
	}

	public function destroy() {
		mSceneGraphComponent.destroy();
		mSceneGraphComponent = null;
		mPreRenderWorkComponent.destroy();
		mPreRenderWorkComponent = null;
		mHeroCircleAttacks = null;
		mHeroPolyAttacks = null;
		mRayCasts = null;
		mPolysToShow = null;
		mCirclesToShow = null;
	}
}

private class CircleAttackRecord {
	public var mTransform:B2Transform;

	public var mCircle:B2CircleShape;

	public var mlife:UInt = 0;

	public function new() {}
}

private class PolygonShapeRecord {
	public var mVerticies:Array<ASAny>;

	public var mVerticiesAsVector:Vector<B2Vec2>;

	public var mShape:B2PolygonShape;

	public var mTransform:B2Transform;

	public var mLife:UInt = 0;

	public function new() {}

	public function buildVerticies() {
		var _loc3_ = (0 : UInt);
		var _loc2_:B2Vec2 = null;
		var _loc1_ = mShape;
		mVerticies = [];
		mVerticiesAsVector = new Vector<B2Vec2>();
		_loc3_ = (0 : UInt);
		while (_loc3_ < (_loc1_.GetVertexCount():UInt)) {
			_loc2_ = new B2Vec2(ASCompat.toNumberField(_loc1_.GetVertices()[(_loc3_ : Int)], "x"),
				ASCompat.toNumberField(_loc1_.GetVertices()[(_loc3_ : Int)], "y"));
			_loc2_.Add(mTransform.position);
			mVerticiesAsVector.push(_loc2_);
			mVerticies.push(_loc2_);
			_loc3_++;
		}
	}
}

private class ShapeRecord {
	public var mShape:B2Shape;

	public var mTransform:B2Transform;

	public var mLife:UInt = 0;

	public function new() {}
}

private class RayCastDraw {
	public var point1:B2Vec2;

	public var point2:B2Vec2;

	public var life:UInt = 0;

	public function new() {}
}
