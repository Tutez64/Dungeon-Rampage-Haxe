package doobers;

import brain.clock.GameClock;
import brain.utils.MemoryTracker;
import brain.workLoop.LogicalWorkComponent;
import distributedObjects.HeroGameObjectOwner;
import events.FirstTreasureCollectedEvent;
import events.FirstTreasureNearbyEvent;
import facade.DBFacade;
import dr_floor.FloorObject;
import gameMasterDictionary.GMDoober;
import generatedCode.DistributedDooberGameObjectNetworkComponent;
import generatedCode.IDistributedDooberGameObject;
import flash.geom.Vector3D;

class DooberGameObject extends FloorObject implements IDistributedDooberGameObject {
	public var mDooberData:GMDoober;

	var mDooberView:DooberView;

	var mSwfPath:String;

	var mClassName:String;

	var mDooberId:UInt = 0;

	var hasOwnership:Bool = false;

	var mLogicalWorkComponent:LogicalWorkComponent;

	var mTutorialStarted:Bool = false;

	public function new(facade:DBFacade, remoteId:UInt = (0 : UInt)) {
		super(facade, remoteId);
		this.layer = 20;
		this.mSwfPath = DBFacade.buildFullDownloadPath("Resources/Art2D/Items/db_items_doobers.swf");
		hasOwnership = false;
	}

	override function buildView() {
		mDooberView = new DooberView(mDBFacade, this);
		MemoryTracker.track(mDooberView, "DooberView - created in DooberGameObject.buildView()");
		this.view = mDooberView;
	}

	override public function set_position(pos:Vector3D):Vector3D {
		super.position = pos;
		return this.mDooberView.position = pos;
	}

	@:isVar public var swfPath(get, never):String;

	public function get_swfPath():String {
		return this.mSwfPath;
	}

	@:isVar public var className(get, never):String;

	public function get_className():String {
		return this.mClassName;
	}

	@:isVar public var type(get, set):UInt;

	public function get_type():UInt {
		return this.mDooberId;
	}

	function set_type(value:UInt):UInt {
		mDooberId = value;
		this.mDooberData = ASCompat.dynamicAs(mDBFacade.gameMaster.dooberById.itemFor(mDooberId), gameMasterDictionary.GMDoober);
		this.mClassName = mDooberData.AssetClassName;
		mSwfPath = DBFacade.buildFullDownloadPath(mDooberData.SwfFilePath);
		return value;
	}

	public function postGenerate() {
		this.init();
		if (!mDBFacade.dbAccountInfo.dbAccountParams.hasChestNearbyTutorialParam()) {
			if (mDooberData.DooberType == "TREASURE") {
				mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade, "DooberGameObject");
				mLogicalWorkComponent.doEveryFrame(checkForTutorialPopUp);
			}
		}
	}

	public function takeOwnership(isHeroOwner:Bool, heroId:UInt) {
		var _loc5_:HeroGameObjectOwner = null;
		var _loc4_ = Math.NaN;
		var _loc3_ = 0;
		hasOwnership = true;
		mDooberView.collectedEffect(isHeroOwner, heroId, animationComplete);
		if (this.distributedDungeonFloor != null && mDooberData != null) {
			if (mDooberData.Exp > 0) {
				this.distributedDungeonFloor.addCollectedExp(mDooberData.Exp);
			} else if (mDooberData.DooberType == "TREASURE") {
				this.distributedDungeonFloor.addCollectedTreasure(mDooberId);
				if (!mDBFacade.dbAccountInfo.dbAccountParams.hasChestCollectedTutorialParam()) {
					mDBFacade.eventManager.dispatchEvent(new FirstTreasureCollectedEvent());
				}
				mTutorialStarted = true;
			} else if (isHeroOwner && mDooberData.isFood()) {
				_loc5_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(heroId), HeroGameObjectOwner);
				_loc4_ = Math.fround(mDooberData.HPPercentage * _loc5_.maxHitPoints);
				_loc3_ = 0;
				_loc5_.heroView.spawnHealFloater(Std.int(_loc4_), true, true, _loc3_, (0 : UInt), "DAMAGE_MOVEMENT_TYPE");
			} else if (isHeroOwner && mDooberData.DooberType == "MANA") {
				_loc5_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId(heroId), HeroGameObjectOwner);
				_loc4_ = Math.fround(mDooberData.MPPercentage * _loc5_.maxManaPoints);
				_loc3_ = 0;
				_loc5_.heroView.spawnHealFloater(Std.int(_loc4_), true, true, _loc3_, (2 : UInt), "DAMAGE_MOVEMENT_TYPE");
			}
		}
	}

	function animationComplete() {
		if (hasOwnership) {
			if (mDooberData.DooberType == "EXP") {
				mDBFacade.hud.bulgeXpBar();
			} else if (mDooberData.DooberType == "FOOD") {
				mDBFacade.hud.bulgeProfileBox();
			}
			this.destroy();
		}
	}

	public function collectedBy(heroId:UInt) {}

	public function spawnFrom(pos:Vector3D) {
		this.mDooberView.animateDooberBounce(pos, this.position);
	}

	override public function destroy() {
		mDooberView = null;
		if (mLogicalWorkComponent != null) {
			mLogicalWorkComponent.destroy();
			mLogicalWorkComponent = null;
		}
		super.destroy();
	}

	public function setNetworkComponentDistributedDooberGameObject(iface:DistributedDooberGameObjectNetworkComponent) {}

	public function checkForTutorialPopUp(gameClock:GameClock) {
		if (!mTutorialStarted
			&& mDistributedDungeonFloor.activeOwnerAvatar != null
			&& Vector3D.distance(mDistributedDungeonFloor.activeOwnerAvatar.actorView.position, mPosition) < 500) {
			mTutorialStarted = true;
			if (!mDBFacade.dbAccountInfo.dbAccountParams.hasChestNearbyTutorialParam()) {
				mDBFacade.eventManager.dispatchEvent(new FirstTreasureNearbyEvent());
			}
			mLogicalWorkComponent.clear();
			mLogicalWorkComponent.destroy();
			mLogicalWorkComponent = null;
		}
	}
}
