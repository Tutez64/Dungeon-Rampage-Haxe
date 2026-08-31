package actor;

import facade.DBFacade;
import gameMasterDictionary.GMBuffColorType;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.filters.GlowFilter;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.geom.Vector3D;

class DamageFloater extends FloatingMessage {
	static inline final FLOAT_HEIGHT:Float = 80;

	static inline final DEFAULT_SCALE:Float = 1;

	static inline final SFX_SWF = "Resources/Art2D/FX/db_fx_library.swf";

	static inline final BEST_MC = "db_fx_hit_sweet";

	static inline final BETTER_MC = "db_fx_hit_super";

	static inline final NORMAL_MC = "db_fx_hit_bang";

	static inline final WORSE_MC = "db_fx_hit_weak";

	static inline final WORST_MC = "db_fx_hit_fail";

	static inline final BEST_HEX_VALUE = (16750592 : UInt);

	static inline final BETTER_HEX_VALUE = (16737536 : UInt);

	static inline final NORMAL_HEX_VALUE = (16777113 : UInt);

	static inline final CRITICAL_HEX_VALUE = (16750848 : UInt);

	static inline final HEAL_HEX_VALUE = (2293538 : UInt);

	static inline final MANA_HEX_VALUE = (9065403 : UInt);

	static inline final WORSE_HEX_VALUE = (15029422 : UInt);

	static inline final WORST_HEX_VALUE = (11613062 : UInt);

	static final CRIT_FILTER:GlowFilter = new GlowFilter((16777062 : UInt), 1, 0.4, 0.4, 30, 1);

	var mActor:ActorGameObject;

	var mFloaterText:MovieClip;

	var mBmp:Bitmap;

	var mBmpData:BitmapData;

	var mType:UInt = 0;

	public function new(dbFacade:DBFacade, delta:Float, actorGameObject:ActorGameObject, holdDuration:UInt, totalDuration:UInt, scaleDampening:Float,
			floatSpeed:Float, finishedCallback:ASFunction, attackerIsOwner:Bool, attackeeIsOwner:Bool, blit:Bool = true, isCriticalHit:Bool = false,
			effectiveness:Int = 0, type:UInt = (0 : UInt), movementType:String = "DAMAGE_MOVEMENT_TYPE") {
		mActor = actorGameObject;
		mDBFacade = dbFacade;
		mType = type;
		setup(isCriticalHit, delta, attackerIsOwner, attackeeIsOwner, blit, effectiveness);
		var _loc16_ = ASCompat.dynamicAs(blit ? mBmp : mFloaterText, flash.display.DisplayObject);
		super(_loc16_, dbFacade, holdDuration, totalDuration, scaleDampening, floatSpeed, mFloatDirection, finishedCallback, movementType);
		mDBFacade.sceneGraphManager.addChild(mRoot, 30);
	}

	function showEffectivenessFX(effectiveness:Int) {
		var _loc3_:String;
		var _loc2_:Vector3D;
		var _loc4_:Float;
		var _loc5_:Float;
		var _loc6_:String = null;
		if (mActor.isHeroType || mActor.effectivenessShown == false) {
			mActor.effectivenessShown = true;
			_loc3_ = DBFacade.buildFullDownloadPath("Resources/Art2D/FX/db_fx_library.swf");
			switch (effectiveness - -2) {
				case 0:
					_loc6_ = "db_fx_hit_fail";

				case 1:
					_loc6_ = "db_fx_hit_weak";

				case 2:
					_loc6_ = "db_fx_hit_bang";

				case 3:
					_loc6_ = "db_fx_hit_super";

				case 4:
					_loc6_ = "db_fx_hit_sweet";
			}
			_loc2_ = new Vector3D(mActor.view.root.x, mActor.view.root.y - 80, 0);
			_loc4_ = 1;
			_loc5_ = 0;
			mActor.distributedDungeonFloor.effectManager.playEffect(_loc3_, _loc6_, _loc2_, null, false, _loc4_, _loc5_, 0, 0, 0, false, "foreground");
			return;
		}
	}

	function getEffectivenessTextColor(effectiveness:Int):UInt {
		switch (effectiveness - -2) {
			case 0:
				return (11613062 : UInt);
			case 1:
				return (15029422 : UInt);
			case 2:
				return (16777113 : UInt);
			case 3:
				return (16737536 : UInt);
			case 4:
				return (16750592 : UInt);
			default:
				return (16777113 : UInt);
		}
		return 0;
	}

	function setup(isCriticalHit:Bool, delta:Float, attackerIsOwner:Bool, attackeeIsOwner:Bool, blit:Bool, effectiveness:Int) {
		var _loc9_ = 0;
		var _loc15_:String = null;
		var _loc10_:Vector3D = null;
		var _loc14_:GMBuffColorType = null;
		var _loc13_:Rectangle = null;
		var _loc7_:Matrix = null;
		mFloaterText = ASCompat.dynamicAs(ASCompat.createInstance(mDBFacade.hud.floaterTextClass, []), MovieClip);
		var _loc11_:Float = 1;
		var _loc12_:Float = 1;
		if (delta < 0) {
			if (attackerIsOwner || attackeeIsOwner) {
				if (attackeeIsOwner) {
					_loc11_ = _loc12_ = 1;
				} else {
					_loc11_ = _loc12_ = isCriticalHit ? 1 * 1.8 : 1;
				}
			}
			if (isCriticalHit) {
				_loc15_ = Std.string(delta) + "!";
			} else {
				_loc15_ = Std.string(delta);
			}
			if (attackeeIsOwner) {
				_loc9_ = 16711680;
				switch (mType - 1) {
					case 0:
						_loc9_ = 65280;

					case 1:
						_loc9_ = 9065403;
				}
			} else {
				_loc9_ = ASCompat.toInt(isCriticalHit ? 16750848 : getEffectivenessTextColor(effectiveness));
			}
			if (mType > 10) {
				_loc14_ = ASCompat.dynamicAs(mDBFacade.gameMaster.buffColorTypeById.itemFor(mType), gameMasterDictionary.GMBuffColorType);
				_loc9_ = (_loc14_.ColorHex : Int);
			}
			_loc10_ = new Vector3D((Math.random() - 0.5) * 0.5, -1, 0);
		} else {
			_loc15_ = "+" + Std.string(delta);
			_loc9_ = 9502608;
			if (attackeeIsOwner) {
				_loc11_ = _loc12_ = 1 * 1.1;
				_loc9_ = 2293538;
				switch (mType - 2) {
					case 0:
						_loc9_ = 9065403;
				}
			}
			_loc10_ = new Vector3D(0, -1, 0);
		}
		mFloatDirection = _loc10_;
		mFloatDirection.normalize();
		var _loc8_ = Math.atan2(mFloatDirection.y, mFloatDirection.x) * 180 / 3.141592653589793 + 90;
		if (effectiveness != 0) {
			this.showEffectivenessFX(effectiveness);
		}
		ASCompat.setProperty((mFloaterText : ASAny).label, "text", _loc15_);
		ASCompat.setProperty((mFloaterText : ASAny).label, "textColor", _loc9_);
		if (isCriticalHit) {
			mFloaterText.filters = cast([CRIT_FILTER]);
		}
		if (blit) {
			mBmpData = new BitmapData(Std.int(mFloaterText.width), Std.int(mFloaterText.height), true, (0 : UInt));
			_loc13_ = mFloaterText.getBounds(mFloaterText);
			_loc7_ = new Matrix();
			_loc7_.translate(-_loc13_.x, -_loc13_.y);
			mBmpData.draw(mFloaterText, _loc7_);
			mBmp = new Bitmap(mBmpData, "auto", true);
			mBmp.scaleX = _loc11_;
			mBmp.scaleY = _loc12_;
			mBmp.x = mActor.view.root.x - mBmp.width * 0.5;
			mBmp.y = mActor.view.root.y - 80;
			mBmp.rotation = _loc8_;
		} else {
			mFloaterText.scaleX = _loc11_;
			mFloaterText.scaleY = _loc12_;
			mFloaterText.x = mActor.view.root.x + mFloatDirection.x * 100;
			mFloaterText.y = mActor.view.root.y - 80;
			mFloaterText.rotation = _loc8_;
		}
	}

	override public function destroy() {
		if (mActor.view != null) {
			mDBFacade.sceneGraphManager.removeChild(mRoot);
		}
		if (mBmpData != null) {
			mBmpData.dispose();
		}
		mBmpData = null;
		mBmp = null;
		mActor = null;
		mFloaterText = null;
		super.destroy();
	}
}
