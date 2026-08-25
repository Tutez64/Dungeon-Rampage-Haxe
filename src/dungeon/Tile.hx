package dungeon;

import actor.ActorGameObject;
import brain.logger.Logger;
import brain.sceneGraph.SceneGraphComponent;
import collision.LocalHeroProximitySensor;
import distributedObjects.DistributedDungeonFloor;
import distributedObjects.NPCGameObject;
import facade.DBFacade;
import dr_floor.FloorObject;
import projectile.ChainProjectileGameObject;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.geom.Vector3D;
import org.as3commons.collections.Set;

class Tile extends FloorObject {
	public static inline final TILE_WIDTH = (900 : UInt);

	public static inline final TILE_HEIGHT = (900 : UInt);

	var mNumberOfProps:UInt = 0;

	var mPropsAdded:UInt = (0 : UInt);

	var mFloorObjects:Set = new Set();

	var mOwnedFloorObjects:Set = new Set();

	var mActorGameObjects:Set = new Set();

	var mNPCGameObjects:Set = new Set();

	var mProjectileGameObjects:Set = new Set();

	var mBounds:Rectangle;

	var mBackground:Prop;

	var mSceneGraphComponent:SceneGraphComponent;

	var mOnStage:Bool = false;

	var mIsFiller:Bool = false;

	var mLocalHeroProximitySensors:Vector<LocalHeroProximitySensor>;

	public function new(facade:DBFacade, numberOfProps:UInt, isfiller:Bool) {
		super(facade);
		mIsFiller = isfiller;
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
			_loc2_ = ASCompat.dynamicAs(_loc1_.next(), dr_floor.FloorObject);
			_loc2_.destroy();
		}
		mOwnedFloorObjects.clear();
		mOwnedFloorObjects = null;
		_loc1_ = mProjectileGameObjects.iterator();
		while (_loc1_.hasNext()) {
			_loc2_ = ASCompat.dynamicAs(_loc1_.next(), dr_floor.FloorObject);
			_loc2_.destroy();
		}
		mProjectileGameObjects = null;
		mFloorObjects.clear();
		mFloorObjects = null;
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
		mBounds = mBounds.union(floorObject.view.root.getBounds(mFacade.sceneGraphManager.worldTransformNode));
	}

	public function addFloorObject(floorObject:FloorObject) {
		mFloorObjects.add(floorObject);
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
			_loc2_ = ASCompat.dynamicAs(_loc1_.next(), dr_floor.FloorObject);
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
			_loc2_ = ASCompat.dynamicAs(_loc1_.next(), dr_floor.FloorObject);
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
		mLocalHeroProximitySensors.push(new LocalHeroProximitySensor(mDBFacade, distributedDungeonFloor, (Std.int(this.position.x + x) : UInt),
			(Std.int(this.position.y + y) : UInt), radius, triggerOnce, onCollisionCallback));
	}
}
