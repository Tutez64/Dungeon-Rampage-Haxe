package actor.player;

import actor.DamageFloater;
import brain.clock.GameClock;
import brain.logger.Logger;
import brain.sound.SoundAsset;
import brain.sound.SoundHandle;
import brain.utils.MemoryTracker;
import brain.workLoop.Task;
import dBGlobals.DBGlobal;
import distributedObjects.HeroGameObject;
import dungeon.Tile;
import effects.EffectGameObject;
import effects.EffectView;
import facade.DBFacade;
import dr_floor.FloorObject;
import flash.geom.Point;
import flash.geom.Vector3D;

class HeroOwnerView extends HeroView {
	public static var HIT_AREA_HALF_WIDTH:Float = 15;

	public static var HIT_AREA_HALF_HEIGHT:Float = 25;

	public static var HIT_AREA_Y_OFFSET:Float = 10;

	public static var ACTIVATE_HEARTBEAT_AT_HEALTH_LEVEL:Float = 0.25;

	public var wantMouseEnabled:Bool = false;

	var mVisibilityTask:Task;

	var mNotEnoughManaSoundEffect:SoundAsset;

	var mFootRing:EffectGameObject;

	var mHeartbeatSoundEffect:SoundAsset;

	var mHeartbeatSoundHandle:SoundHandle;

	public function new(dbFacade:DBFacade, heroGameObject:HeroGameObject) {
		super(dbFacade, heroGameObject);
	}

	function fadeOccludingObjects(gameClock:GameClock) {
		var _loc11_:FloorObject = null;
		var _loc7_:Point = null;
		var _loc12_:ASAny = null;
		var _loc8_:ASAny = null;
		var _loc2_:Array<ASAny> = null;
		var _loc5_ = 0;
		var _loc9_ = 0;
		var _loc6_:Tile = null;
		if (mHeroPlayerObject.tile == null) {
			Logger.warn("mHeroPlayerObject.tile is null.");
			return;
		}
		var _loc4_ = new Point();
		var _loc10_:Float = 4;
		var _loc3_ = mHeroPlayerObject.distributedDungeonFloor.GetTilesAroundAvatar(_loc10_);
		if (checkNullIteratee(_loc3_))
			for (_tmp_ in _loc3_) {
				_loc6_ = _tmp_;
				_loc2_ = _loc6_.floorObjectsSnapshot;
				_loc5_ = _loc2_.length;
				_loc9_ = 0;
				while (_loc9_ < _loc5_) {
					_loc11_ = ASCompat.coerce(_loc2_[_loc9_], dr_floor.FloorObject);
					if (_loc11_.archwayAlpha && _loc11_.view.root.hitTestObject(mBody)) {
						_loc4_.x = mBody.x;
						_loc4_.y = mBody.y;
						_loc7_ = mDBFacade.designLocalToGlobal(mBody, _loc4_);
						if (_loc11_.view.root.hitTestPoint(_loc7_.x, _loc7_.y, false)) {
							_loc11_.view.doFade();
						}
					}
					_loc9_++;
				}
			}
	}

	override public function init() {
		super.init();
		this.nametag.hpBarVisible = false;
		mVisibilityTask = mLogicalWorkComponent.doEveryFrame(fadeOccludingObjects);
		if (!wantMouseEnabled) {
			root.mouseEnabled = false;
			root.mouseChildren = false;
		} else {
			setFixedMouseHitRect(-HIT_AREA_HALF_WIDTH, -HIT_AREA_HALF_HEIGHT + actor.ActorView.BODY_Y_OFFSET + HIT_AREA_Y_OFFSET, HIT_AREA_HALF_WIDTH * 2,
				HIT_AREA_HALF_HEIGHT * 2);
			root.mouseChildren = false;
		}
		mFootRing = new EffectGameObject(mDBFacade, DBFacade.buildFullDownloadPath("Resources/Art2D/FX/db_fx_library.swf"), "db_fx_player_ring", 1);
		MemoryTracker.track(mFootRing, "EffectGameObject \'db_fx_player_ring\' - created in HeroOwnerView.init()", "pool");
		mFootRing.view.root.scaleX = mFootRing.view.root.scaleY = 0.75;
		cast(mFootRing.view, EffectView).attachToParent(mBody, true);
		cast(mFootRing.view, EffectView).play(true, function() {});
		registerStatusTintAttachment(cast(mFootRing.view, EffectView));
		mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath(DBGlobal.SFX_PATH), "TEMP_Heartbeat1", function(param1:SoundAsset) {
			mHeartbeatSoundEffect = param1;
		});
	}

	override public function setHp(hp:UInt, maxHp:UInt) {
		super.setHp(hp, maxHp);
		if (hp <= maxHp * ACTIVATE_HEARTBEAT_AT_HEALTH_LEVEL) {
			if (mHeartbeatSoundHandle != null) {
				return;
			}
			if (mHeartbeatSoundEffect != null) {
				mHeartbeatSoundHandle = mSoundComponent.playSfxManaged(mHeartbeatSoundEffect);
				mHeartbeatSoundHandle.play(2147483647);
			}
		} else {
			stopHeartbeatSound();
		}
	}

	public function stopHeartbeatSound() {
		if (mHeartbeatSoundHandle == null) {
			return;
		}
		mHeartbeatSoundHandle.stop();
		mHeartbeatSoundHandle.destroy();
		mHeartbeatSoundHandle = null;
	}

	override public function set_position(pos:Vector3D):Vector3D {
		if (Math.isNaN(mPrevPosX)) {
			mPrevPosX = pos.x;
			mPrevPosY = pos.y;
		}
		mTickPosX = pos.x;
		mTickPosY = pos.y;
		mRoot.x = pos.x;
		mRoot.y = pos.y;
		return pos;
	}

	@:isVar public var outOfManaSoundEffect(get, never):SoundAsset;

	public function get_outOfManaSoundEffect():SoundAsset {
		return mNotEnoughManaSoundEffect;
	}

	override public function spawnDamageFloater(isCriticalHit:Bool, delta:Int, attackerIsOwner:Bool, attackeeIsOwner:Bool, effectiveness:Int,
			inType:UInt = (0 : UInt), floaterType:String = "DAMAGE_MOVEMENT_TYPE") {
		if (wantDamageFloaters) {
			DamageFloater.spawn(mDBFacade, delta, mParentActorObject, (0 : UInt), (24 : UInt), 1.2, 90, attackerIsOwner, attackeeIsOwner, isCriticalHit,
				effectiveness, inType, floaterType);
		}
	}

	override public function destroy() {
		mNotEnoughManaSoundEffect = null;
		mVisibilityTask.destroy();
		if (mFootRing != null) {
			unregisterStatusTintAttachment(cast(mFootRing.view, EffectView));
			mFootRing.destroy();
			mFootRing = null;
		}
		if (mHeartbeatSoundEffect != null) {
			mHeartbeatSoundEffect = null;
		}
		if (mHeartbeatSoundHandle != null) {
			mHeartbeatSoundHandle.destroy();
			mHeartbeatSoundHandle = null;
		}
		super.destroy();
	}
}
