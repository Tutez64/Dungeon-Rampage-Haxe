package actor.buffs;

import actor.ActorGameObject;
import actor.ActorView;
import brain.utils.MemoryTracker;
import facade.DBFacade;
import dr_floor.FloorObject;
import gameMasterDictionary.GMBuff;
import gameMasterDictionary.StatVector;
import com.greensock.TimelineMax;

class BuffGameObject extends FloorObject {
	var mData:GMBuff;

	var mParentView:ActorView;

	var mBuffView:BuffView;

	var mActorGameObject:ActorGameObject;

	public var instanceCount:UInt = (1 : UInt);

	public var buffId:UInt = 0;

	public var swfPath:String;

	public var className:String;

	public var deltaValues:StatVector;

	public var mSortLayer:String;

	public var mCameraTweenMax:TimelineMax;

	public function new(facade:DBFacade, actorGameObject:ActorGameObject, actorView:ActorView, id:UInt, remoteId:UInt = (0 : UInt),
			attackerId:UInt = (0 : UInt)) {
		mActorGameObject = actorGameObject;
		mParentView = actorView;
		buffId = id;
		mData = ASCompat.dynamicAs(facade.gameMaster.buffById.itemFor(buffId), gameMasterDictionary.GMBuff);
		this.swfPath = DBFacade.buildFullDownloadPath(mData.VFXFilepath);
		this.className = mData.VFX;
		if (ASCompat.stringAsBool(this.className)) {
			this.className = facade.customSkinVisualsOverrideHandler.customSkinVFXVisualsOverrider(mData.VFX, attackerId);
		}
		this.deltaValues = mData.DeltaValues;
		this.mSortLayer = mData.SortLayer;
		super(facade, remoteId);
		position = mActorGameObject.position;
	}

	override public function destroy() {
		if (mActorGameObject.isOwner && mData.ShakeLocalCamera) {
			this.mDBFacade.camera.removeShakes();
			mCameraTweenMax.kill();
		}
		mData = null;
		mParentView = null;
		if (mBuffView != null) {
			mBuffView.destroy();
		}
		mBuffView = null;
		mActorGameObject = null;
		deltaValues = null;
		super.destroy();
	}

	@:isVar public var Ability(get, never):UInt;

	public function get_Ability():UInt {
		return mData.Ability;
	}

	@:isVar public var ExpMult(get, never):Float;

	public function get_ExpMult():Float {
		return mData.Exp;
	}

	@:isVar public var EventExpMult(get, never):Float;

	public function get_EventExpMult():Float {
		return mData.EventExp;
	}

	@:isVar public var attackCooldownMultiplier(get, never):Float;

	public function get_attackCooldownMultiplier():Float {
		return mData.AttackCooldownMultiplier;
	}

	@:isVar public var GoldMult(get, never):Float;

	public function get_GoldMult():Float {
		return mData.Gold;
	}

	@:isVar public var CanSwapDisplay(get, never):Bool;

	public function get_CanSwapDisplay():Bool {
		return mData.SwapDisplay;
	}

	override function buildView() {
		mBuffView = new BuffView(mDBFacade, this, mParentView, mData.TintColor, mData.TintAmountF, mData.Scale, mData.ScaleStartDelay,
			mData.ScaleUpIncrementTime, mData.ScaleUpIncrementScale);
		MemoryTracker.track(mBuffView, "BuffView - created in BuffGameObject.buildView()");
		this.view = mBuffView;
		if (mActorGameObject.isOwner) {
			if (mData.ShakeLocalCamera) {
				mCameraTweenMax = this.mDBFacade.camera.shakeX(mData.Duration, 10, (Std.int(mData.Duration * 2) : UInt));
			}
			if (mData.ShowInHUD) {
				mBuffView.showInHUD();
			}
		}
	}

	public function updateInstanceCountOnHud() {
		if (mData.ShowInHUD) {
			mDBFacade.hud.updateBuffInstance(this);
		}
	}

	@:isVar public var buffView(get, never):BuffView;

	public function get_buffView():BuffView {
		return mBuffView;
	}

	@:isVar public var buffData(get, never):GMBuff;

	public function get_buffData():GMBuff {
		return mData;
	}
}
