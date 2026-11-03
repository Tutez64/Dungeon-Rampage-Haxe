package dungeon;

import actor.ActorGameObject;
import box2D.dynamics.B2World;
import brain.logger.Logger;
import brain.sceneGraph.SceneGraphComponent;
import collections.Set;
import collision.LocalHeroProximitySensor;
import distributedObjects.DistributedDungeonFloor;
import distributedObjects.NPCGameObject;
import facade.DBFacade;
import dr_floor.FloorObject;
import projectile.ChainProjectileGameObject;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Vector3D;

class Tile extends FloorObject {
	public static inline final TILE_WIDTH = (900 : UInt);

	public static inline final TILE_HEIGHT = (900 : UInt);

	static inline final EXIT_BACKSTOP_DEPTH:Float = 60;

	var mNumberOfProps:UInt = 0;

	var mPropsAdded:UInt = (0 : UInt);

	var mFloorObjects:Set = new Set();

	var mFloorObjectsSnapshot:Array<ASAny>;

	var mOwnedFloorObjects:Set = new Set();

	var mActorGameObjects:Set = new Set();

	var mNPCGameObjects:Set = new Set();

	var mProjectileGameObjects:Set = new Set();

	var mBounds:Rectangle;

	var mBackground:Prop;

	var mSceneGraphComponent:SceneGraphComponent;

	var mOnStage:Bool = false;

	var mIsFiller:Bool = false;

	var mIsGeneratedFiller:Bool = false;

	var mLocalHeroProximitySensors:Vector<LocalHeroProximitySensor>;

	public function new(facade:DBFacade, numberOfProps:UInt, isFiller:Bool) {
		super(facade);
		mIsFiller = isFiller;
		mBounds = new Rectangle(0, 0, 900, 900);
		mSceneGraphComponent = new SceneGraphComponent(facade, "Tile");
		mNumberOfProps = numberOfProps + 1;
		mLocalHeroProximitySensors = new Vector<LocalHeroProximitySensor>();
		checkIfFinished();
		this.init();
	}

	public function isFiller():Bool {
		return mIsFiller;
	}

	@:isVar public var isGeneratedFiller(get, set):Bool;

	public function get_isGeneratedFiller():Bool {
		return mIsGeneratedFiller;
	}

	function set_isGeneratedFiller(value:Bool):Bool {
		return mIsGeneratedFiller = value;
	}

	public function addBackgroundNavCollisions(backgroundJson:ASObject, navCollisions:Array<ASAny>, box2DWorld:B2World) {
		var _loc15_ = Math.NaN;
		var _loc12_ = Math.NaN;
		var _loc6_:Vector3D = null;
		var _loc4_ = Math.NaN;
		var _loc5_:NavCollider = null;
		var _loc10_ = ASCompat.toNumber(ASCompat.toBool(backgroundJson.scale) ? backgroundJson.scale : 1);
		var _loc16_:Float = ASCompat.toBool(backgroundJson.flip) ? -1 : 1;
		var _loc8_ = ASCompat.toBool(backgroundJson.rotation) ? ASCompat.toNumberField(backgroundJson, "rotation") * 3.141592653589793 / 180 : 0;
		var _loc7_ = ASCompat.toNumber(backgroundJson.x ?? 0);
		var _loc9_ = ASCompat.toNumber(backgroundJson.y ?? 0);
		var _loc14_ = new Vector3D(_loc10_, _loc10_, 1);
		var _loc11_ = buildFilter();
		var _loc13_:ASObject;
		if (checkNullIteratee(navCollisions))
			for (_tmp_ in navCollisions) {
				_loc13_ = _tmp_;
				_loc15_ = (ASCompat.toBool(_loc13_.x) ? ASCompat.toNumberField(_loc13_, "x") : 0) * _loc10_ * _loc16_;
				_loc12_ = (ASCompat.toBool(_loc13_.y) ? ASCompat.toNumberField(_loc13_, "y") : 0) * _loc10_;
				_loc6_ = new Vector3D(_loc7_
					+ _loc15_ * Math.cos(_loc8_)
					- _loc12_ * Math.sin(_loc8_),
					_loc9_
					+ _loc15_ * Math.sin(_loc8_)
					+ _loc12_ * Math.cos(_loc8_));
				_loc4_ = ASCompat.toBool(_loc13_.rotation) ? ASCompat.toNumberField(_loc13_, "rotation") * 3.141592653589793 / 180 : 0;
				_loc5_ = NavCollider.buildNavColliderFromJson(mDBFacade, _loc13_, null, _loc6_, _loc8_ + _loc16_ * _loc4_, _loc14_, box2DWorld, _loc11_);
				if (_loc5_ != null) {
					_loc5_.position = this.position;
					addNavCollision(_loc5_);
				}
			}
	}

	public function addExitBackstops(tileJson:ASObject, box2DWorld:B2World) {
		var _loc13_ = Math.NaN;
		var _loc14_ = Math.NaN;
		var _loc5_:Array<ASAny> = null;
		var _loc3_ = 0;
		var _loc9_ = 0;
		var _loc11_ = false;
		var _loc15_ = Math.NaN;
		var _loc7_ = Math.NaN;
		var _loc6_ = Math.NaN;
		var _loc4_ = Math.NaN;
		var _loc10_:RectangleNavCollider = null;
		var _loc8_:Array<ASAny> = [];
		var _loc12_:ASObject;
		final __ax4_iter_440:Array<ASAny> = tileJson.LEObjects;
		if (checkNullIteratee(__ax4_iter_440))
			for (_tmp_ in __ax4_iter_440) {
				_loc12_ = _tmp_;
				if (_loc12_.constant == "JASONS_DUNGEON_EXIT") {
					_loc13_ = ASCompat.toNumber(_loc12_.x ?? 0);
					_loc14_ = ASCompat.toNumber(_loc12_.y ?? 0);
					_loc5_ = [_loc14_, 900 - _loc13_, 900 - _loc14_, _loc13_];
					_loc3_ = 0;
					_loc9_ = 1;
					while (_loc9_ < 4) {
						if (_loc5_[_loc9_] < _loc5_[_loc3_]) {
							_loc3_ = _loc9_;
						}
						_loc9_++;
					}
					if (!(ASCompat.toBool(_loc8_[_loc3_])
						|| ASCompat.toBool(tileJson.exits)
						&& ASCompat.toNumber(tileJson.exits[_loc3_]) > 0)) {
						_loc8_[_loc3_] = true;
						_loc11_ = _loc3_ == 0 || _loc3_ == 2;
						_loc15_ = _loc11_ ? 900 * 0.5 : 60 * 0.5;
						_loc7_ = _loc11_ ? 60 * 0.5 : 900 * 0.5;
						_loc6_ = ASCompat.toNumber([900 * 0.5, 900 + _loc15_, 900 * 0.5, -_loc15_][_loc3_]);
						_loc4_ = ASCompat.toNumber([-_loc7_, 900 * 0.5, 900 + _loc7_, 900 * 0.5][_loc3_]);
						_loc10_ = new RectangleNavCollider(mDBFacade, null, new Vector3D(_loc6_, _loc4_), 0, box2DWorld, _loc15_, _loc7_, buildFilter());
						_loc10_.position = this.position;
						addNavCollision(_loc10_);
					}
				}
			}
	}

	public function addOwnedFloorObject(floorObject:FloorObject):Bool {
		return mOwnedFloorObjects.add(floorObject);
	}

	public function removeOwnedFloorObject(floorObject:FloorObject):Bool {
		return mOwnedFloorObjects.remove(floorObject);
	}

	public function hasOwnedFloorObject(floorObject:FloorObject):Bool {
		return mOwnedFloorObjects.has(floorObject);
	}

	override public function destroy() {
		var _loc2_:FloorObject = null;
		var _loc1_ = mOwnedFloorObjects.iterator();
		while (_loc1_.hasNext()) {
			_loc2_ = ASCompat.coerce(_loc1_.next(), dr_floor.FloorObject);
			_loc2_.destroy();
		}
		mOwnedFloorObjects.clear();
		mOwnedFloorObjects = null;
		_loc1_ = mProjectileGameObjects.iterator();
		while (_loc1_.hasNext()) {
			_loc2_ = ASCompat.coerce(_loc1_.next(), dr_floor.FloorObject);
			_loc2_.destroy();
		}
		mProjectileGameObjects = null;
		mFloorObjects.clear();
		mFloorObjects = null;
		mFloorObjectsSnapshot = null;
		mActorGameObjects.clear();
		mActorGameObjects = null;
		mNPCGameObjects.clear();
		mNPCGameObjects = null;
		mBackground = null;
		mSceneGraphComponent.destroy();
		mSceneGraphComponent = null;
		super.destroy();
	}

	override public function set_position(value:Vector3D):Vector3D {
		super.position = value;
		mBounds.x = this.position.x;
		mBounds.y = this.position.y;
		return value;
	}

	@:isVar public var bounds(get, never):Rectangle;

	public function get_bounds():Rectangle {
		return mBounds;
	}

	@:isVar public var isOnStage(get, never):Bool;

	public function get_isOnStage():Bool {
		return mOnStage;
	}

	public function contains(x:Float, y:Float):Bool {
		return mBounds.contains(x, y);
	}

	public function containsPoint(pos:Vector3D):Bool {
		return mBounds.containsPoint(new Point(pos.x, pos.y));
	}

	@:isVar public var floorObjects(get, never):Set;

	public function get_floorObjects():Set {
		return mFloorObjects;
	}

	@:isVar public var floorObjectsSnapshot(get, never):Array<ASAny>;

	public function get_floorObjectsSnapshot():Array<ASAny> {
		if (mFloorObjectsSnapshot == null) {
			mFloorObjectsSnapshot = mFloorObjects.toArray();
		}
		return mFloorObjectsSnapshot;
	}

	@:isVar public var actorGameObjects(get, never):Set;

	public function get_actorGameObjects():Set {
		return mActorGameObjects;
	}

	@:isVar public var NPCGameObjects(get, never):Set;

	public function get_NPCGameObjects():Set {
		return mNPCGameObjects;
	}

	function checkIfFinished() {
		if (mPropsAdded == mNumberOfProps) {}
	}

	public function expandBounds(floorObject:FloorObject) {
		expandBoundsRect(floorObject.view.root.getBounds(mFacade.sceneGraphManager.worldTransformNode));
	}

	public function expandBoundsRect(rect:Rectangle) {
		mBounds = mBounds.union(rect);
	}

	public function addFloorObject(floorObject:FloorObject) {
		mFloorObjects.add(floorObject);
		mFloorObjectsSnapshot = null;
		if (Std.isOfType(floorObject, ActorGameObject)) {
			mActorGameObjects.add(floorObject);
		}
		if (Std.isOfType(floorObject, NPCGameObject)) {
			mNPCGameObjects.add(floorObject);
		}
		if (Std.isOfType(floorObject, ChainProjectileGameObject)) {
			mProjectileGameObjects.add(floorObject);
		}
		mPropsAdded = mPropsAdded + 1;
		checkIfFinished();
		if (mOnStage) {
			floorObject.view.addToStage();
		} else {
			floorObject.view.removeFromStage();
		}
	}

	public function removeFloorObject(floorObject:FloorObject) {
		if (mFloorObjects != null) {
			mFloorObjects.remove(floorObject);
		}
		mFloorObjectsSnapshot = null;
		if (Std.isOfType(floorObject, ActorGameObject) && mActorGameObjects != null) {
			mActorGameObjects.remove(floorObject);
		}
		if (Std.isOfType(floorObject, NPCGameObject) && mNPCGameObjects != null) {
			mNPCGameObjects.remove(floorObject);
		}
		if (Std.isOfType(floorObject, ChainProjectileGameObject) && mProjectileGameObjects != null) {
			mProjectileGameObjects.remove(floorObject);
		}
	}

	public function ignoredAProp() {
		mPropsAdded = mPropsAdded + 1;
		checkIfFinished();
	}

	@:isVar public var background(get, set):Prop;

	public function set_background(backgroundProp:Prop):Prop {
		mBackground = backgroundProp;
		if (mOnStage) {
			mSceneGraphComponent.addChildAt(mBackground.view.root, (5 : UInt), (0 : UInt));
		}
		mPropsAdded = mPropsAdded + 1;
		checkIfFinished();
		return backgroundProp;
	}

	function get_background():Prop {
		return mBackground;
	}

	public function addToStage() {
		var _loc2_:FloorObject = null;
		if (mOnStage) {
			return;
		}
		var _loc1_ = mFloorObjects.iterator();
		while (_loc1_.hasNext()) {
			_loc2_ = ASCompat.coerce(_loc1_.next(), dr_floor.FloorObject);
			if (_loc2_.view == null) {
				Logger.warn("floorObject with null view attempted addToStage id: " + _loc2_.id);
			} else {
				_loc2_.view.addToStage();
			}
		}
		if (mBackground != null) {
			mBackground.view.root.parent.setChildIndex(mBackground.view.root, 0);
		}
		mOnStage = true;
	}

	public function removeFromStage() {
		var _loc2_:FloorObject = null;
		if (!mOnStage) {
			return;
		}
		var _loc1_ = mFloorObjects.iterator();
		while (_loc1_.hasNext()) {
			_loc2_ = ASCompat.coerce(_loc1_.next(), dr_floor.FloorObject);
			if (_loc2_.view == null) {
				Logger.warn("floorObject with null view attempted removeFromStage id: " + _loc2_.id);
			} else {
				_loc2_.view.removeFromStage();
			}
		}
		mOnStage = false;
	}

	public function createLocalEventCollision(distributedDungeonFloor:DistributedDungeonFloor, x:UInt, y:UInt, radius:UInt, triggerOnce:Bool,
			onCollisionCallback:ASFunction) {
		mLocalHeroProximitySensors.push(new LocalHeroProximitySensor(mDBFacade, distributedDungeonFloor, (ASCompat.floatToInt(this.position.x + x) : UInt),
			(ASCompat.floatToInt(this.position.y + y) : UInt), radius, triggerOnce, onCollisionCallback));
	}
}
