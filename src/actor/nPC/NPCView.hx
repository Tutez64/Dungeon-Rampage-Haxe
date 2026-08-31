package actor.nPC;

import actor.ActorRenderer;
import actor.ActorView;
import brain.sound.SoundAsset;
import distributedObjects.NPCGameObject;
import facade.DBFacade;
import flash.display.Sprite;
import flash.geom.Vector3D;

class NPCView extends ActorView {
	public static var HIT_AREA_HALF_WIDTH:Float = Math.NaN;

	public static var HIT_AREA_HALF_HEIGHT:Float = Math.NaN;

	public static var HIT_AREA_Y_OFFSET:Float = Math.NaN;

	var mParentNPCObject:NPCGameObject;

	var mBodyOffAnimRenderer:ActorRenderer;

	var mActivateSoundEffect:SoundAsset;

	var mDeactivateSoundEffect:SoundAsset;

	public function new(facade:DBFacade, npcGameObject:NPCGameObject) {
		super(facade, npcGameObject);
		mParentNPCObject = npcGameObject;
		HIT_AREA_HALF_WIDTH = mDBFacade.dbConfigManager.getConfigNumber("enemy_hit_area_half_width", 100);
		HIT_AREA_HALF_HEIGHT = mDBFacade.dbConfigManager.getConfigNumber("enemy_hit_area_half_height", 100);
		HIT_AREA_Y_OFFSET = mDBFacade.dbConfigManager.getConfigNumber("enemy_hit_area_y_offset", 10);
	}

	override public function init() {
		var hitSprite:Sprite;
		mWantNametag = mParentNPCObject.gmNpc.HasHealthbar;
		super.init();
		if (!mParentNPCObject.isAttackable) {
			mRoot.mouseEnabled = false;
			mRoot.mouseChildren = false;
		}
		if (mParentNPCObject.gmNpc.IsMover) {
			hitSprite = new Sprite();
			hitSprite.mouseEnabled = false;
			hitSprite.graphics.beginFill((0 : UInt), 0);
			hitSprite.graphics.drawRect(-HIT_AREA_HALF_WIDTH, -HIT_AREA_HALF_HEIGHT + ActorView.BODY_Y_OFFSET + HIT_AREA_Y_OFFSET, HIT_AREA_HALF_WIDTH * 2,
				HIT_AREA_HALF_HEIGHT * 2);
			hitSprite.graphics.endFill();
			hitSprite.name = "NPCViewRoot.hitArea";
			root.mouseChildren = false;
			root.hitArea = hitSprite;
			root.addChild(root.hitArea);
		}
		if (ASCompat.stringAsBool(mParentNPCObject.gmNpc.ActivateSound)) {
			mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"), mParentNPCObject.gmNpc.ActivateSound,
				function(param1:SoundAsset) {
					mActivateSoundEffect = param1;
				});
		}
		if (ASCompat.stringAsBool(mParentNPCObject.gmNpc.DeactivateSound)) {
			mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"), mParentNPCObject.gmNpc.DeactivateSound,
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
		root.hitArea = null;
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

	@:isVar public var triggerState(never, set):Bool;

	public function set_triggerState(value:Bool):Bool {
		var _loc2_ = mParentNPCObject.triggerState != value;
		if (value) {
			if (_loc2_ && mActivateSoundEffect != null) {
				mSoundComponent.playSfxOneShot(mActivateSoundEffect, worldCenter, 0, mParentNPCObject != null ? mParentNPCObject.gmNpc.ActivateVolume : 1);
			}
			if (mBodyOffAnimRenderer != null) {
				mBodyOffAnimRenderer.stop();
			}
			if (mBodyAnimRenderer != null) {
				mBodyAnimRenderer.play(mAnimName, 0, true);
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
			}
			if (mBodyOffAnimRenderer != null) {
				mBodyOffAnimRenderer.play(mAnimName, 0, true);
			}
			if (_loc2_) {
				mouseOverUnhighlight();
				disableMouse();
			}
		}
		return value;
	}
}
