package actor.nPC;

import actor.ActorRenderer;
import actor.ActorView;
import brain.sound.SoundAsset;
import dBGlobals.DBGlobal;
import distributedObjects.NPCGameObject;
import facade.DBFacade;
import flash.geom.Vector3D;

class NPCView extends ActorView {
	public static var HIT_AREA_HALF_WIDTH:Float = Math.NaN;

	public static var HIT_AREA_HALF_HEIGHT:Float = Math.NaN;

	public static var HIT_AREA_Y_OFFSET:Float = Math.NaN;

	static var RAISED_TRAP_MARKERS:Array<ASAny>;

	var mParentNPCObject:NPCGameObject;

	var mBodyOffAnimRenderer:ActorRenderer;

	var mAuthoredLayer:Int = 0;

	var mActivateSoundEffect:SoundAsset;

	var mDeactivateSoundEffect:SoundAsset;

	public function new(dbFacade:DBFacade, npcGameObject:NPCGameObject) {
		super(dbFacade, npcGameObject);
		mParentNPCObject = npcGameObject;
		HIT_AREA_HALF_WIDTH = mDBFacade.dbConfigManager.getConfigNumber("enemy_hit_area_half_width", 100);
		HIT_AREA_HALF_HEIGHT = mDBFacade.dbConfigManager.getConfigNumber("enemy_hit_area_half_height", 100);
		HIT_AREA_Y_OFFSET = mDBFacade.dbConfigManager.getConfigNumber("enemy_hit_area_y_offset", 10);
	}

	override public function init() {
		mWantNametag = mParentNPCObject.gmNpc.HasHealthbar;
		super.init();
		if (!mParentNPCObject.isAttackable) {
			mRoot.mouseEnabled = false;
			mRoot.mouseChildren = false;
		}
		if (mParentNPCObject.gmNpc.IsMover) {
			setFixedMouseHitRect(-HIT_AREA_HALF_WIDTH, -HIT_AREA_HALF_HEIGHT + ActorView.BODY_Y_OFFSET + HIT_AREA_Y_OFFSET, HIT_AREA_HALF_WIDTH * 2,
				HIT_AREA_HALF_HEIGHT * 2);
			root.mouseChildren = false;
		}
		if (ASCompat.stringAsBool(mParentNPCObject.gmNpc.ActivateSound)) {
			mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath(DBGlobal.SFX_PATH), mParentNPCObject.gmNpc.ActivateSound,
				function(param1:SoundAsset) {
					mActivateSoundEffect = param1;
				});
		}
		if (ASCompat.stringAsBool(mParentNPCObject.gmNpc.DeactivateSound)) {
			mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath(DBGlobal.SFX_PATH), mParentNPCObject.gmNpc.DeactivateSound,
				function(param1:SoundAsset) {
					mDeactivateSoundEffect = param1;
				});
		}
	}

	function initOffRenderer() {
		if (mNametag != null) {
			mNametag.visible = false;
		}
		if (mBodyOffAnimRenderer == null && mParentNPCObject.isInitialized) {
			mBodyOffAnimRenderer = new ActorRenderer(mDBFacade, mParentNPCObject, false);
			mBodyOffAnimRenderer.loadAssets();
			mBody.addChild(mBodyOffAnimRenderer);
			applyColor(mBodyOffAnimRenderer);
			mBodyOffAnimRenderer.heading = mParentNPCObject.heading;
		}
	}

	override public function destroy() {
		if (mBodyOffAnimRenderer != null) {
			mBodyOffAnimRenderer.destroy();
			mBodyOffAnimRenderer = null;
		}
		mParentNPCObject = null;
		super.destroy();
	}

	override public function actionsForDeadState() {
		super.actionsForDeadState();
		if (mNametag != null) {
			mNametag.visible = false;
		}
		if (ASCompat.stringAsBool(mParentNPCObject.gmNpc.ViolentDeathClassName)
			&& ASCompat.stringAsBool(mParentNPCObject.gmNpc.ViolentDeathFilePath)
			&& mParentNPCObject.distributedDungeonFloor != null) {
			mParentNPCObject.distributedDungeonFloor.effectManager.playEffect(DBFacade.buildFullDownloadPath(mParentNPCObject.gmNpc.ViolentDeathFilePath),
				mParentNPCObject.gmNpc.ViolentDeathClassName, new Vector3D(0, ActorView.BODY_Y_OFFSET), mParentNPCObject, false);
		}
	}

	override public function set_heading(angle:Float):Float {
		super.heading = angle;
		if (mBodyOffAnimRenderer != null) {
			mBodyOffAnimRenderer.heading = angle;
		}
		if (mBodyAnimRenderer != null) {
			mBodyAnimRenderer.heading = angle;
		}
		return angle;
	}

	override public function get_bodyAnimRenderer():ActorRenderer {
		if (mParentNPCObject.triggerState) {
			return mBodyAnimRenderer;
		}
		return mBodyOffAnimRenderer;
	}

	@:isVar var isRaisedTrap(get, never):Bool;

	function get_isRaisedTrap():Bool {
		var _loc1_ = mParentNPCObject.actorData != null ? mParentNPCObject.actorData.constant : null;
		if (_loc1_ == null) {
			return false;
		}
		var _loc2_:String;
		final __ax4_iter_145 = RAISED_TRAP_MARKERS;
		if (checkNullIteratee(__ax4_iter_145))
			for (_tmp_ in __ax4_iter_145) {
				_loc2_ = _tmp_;
				if (_loc1_.indexOf(_loc2_) >= 0) {
					return true;
				}
			}
		return false;
	}

	@:isVar var onStateLayer(get, never):Int;

	function get_onStateLayer():Int {
		if (this.layer != mAuthoredLayer || mAuthoredLayer != 10 || mParentNPCObject.isDead() || !isRaisedTrap) {
			return this.layer;
		}
		return 20;
	}

	override public function addToStage() {
		if (mAuthoredLayer == 0) {
			mAuthoredLayer = this.layer;
		}
		super.addToStage();
		if (mParentNPCObject.triggerState && mBodyAnimRenderer != null) {
			mBodyAnimRenderer.setLayer(onStateLayer);
		}
	}

	@:isVar public var triggerState(never, set):Bool;

	public function set_triggerState(value:Bool):Bool {
		var _loc2_ = mParentNPCObject.triggerState != value;
		if (value) {
			if (_loc2_ && mActivateSoundEffect != null) {
				mSoundComponent.playSfxOneShot(mActivateSoundEffect, worldCenter, 0, mParentNPCObject != null ? mParentNPCObject.gmNpc.ActivateVolume : 1);
			}
			if (mBodyOffAnimRenderer != null) {
				mBodyOffAnimRenderer.stop();
				mBodyOffAnimRenderer.setLayer(0);
				mBodyOffAnimRenderer.visible = false;
			}
			if (mBodyAnimRenderer != null) {
				if (mSceneGraphComponent.contains(root, (this.layer : UInt))) {
					mBodyAnimRenderer.setLayer(onStateLayer);
				}
				mBodyAnimRenderer.visible = true;
				mBodyAnimRenderer.play(mAnimName, 0, _loc2_, mBodyAnimRenderer.loop);
			}
		} else {
			initOffRenderer();
			if (_loc2_) {
				if (mDeactivateSoundEffect != null) {
					mSoundComponent.playSfxOneShot(mDeactivateSoundEffect, worldCenter, 0,
						mParentNPCObject != null ? mParentNPCObject.gmNpc.DeactivateVolume : 1);
				} else if (mDeathSoundEffect != null && mParentNPCObject.gmNpc.PermCorpse) {
					mSoundComponent.playSfxOneShot(mDeathSoundEffect, worldCenter, 0, mParentNPCObject != null ? mParentNPCObject.gmNpc.DeathVolume : 1);
				}
			}
			if (mBodyAnimRenderer != null) {
				mBodyAnimRenderer.stop();
				mBodyAnimRenderer.setLayer(0);
				mBodyAnimRenderer.visible = false;
			}
			if (mBodyOffAnimRenderer != null) {
				if (mSceneGraphComponent.contains(root, (this.layer : UInt))) {
					mBodyOffAnimRenderer.setLayer(this.layer);
				}
				mBodyOffAnimRenderer.visible = true;
				mBodyOffAnimRenderer.play(mAnimName, 0, _loc2_, mBodyOffAnimRenderer.loop);
			}
			if (_loc2_) {
				mouseOverUnhighlight();
				disableMouse();
			}
		}
		return value;
	}

	static function __init__() {
		RAISED_TRAP_MARKERS = [
			"TRAP_SPIKE",
			"TRAP_SPEAR",
			"SPIKETRAP",
			"FLAMESPIKES",
			"PALACE_SPIKES",
			"PALACE_SLICER",
			"NORDIC_CAVE_EMITTER"
		];
	}
}
