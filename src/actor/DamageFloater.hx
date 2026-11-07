package actor;

import actor.starlingConvertedOverlay.FloaterStyle;
import actor.starlingConvertedOverlay.StarlingOverlays;
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

	static final CRIT_FILTER:GlowFilter = FloaterStyle.CRIT_GLOW;

	static final sStyle:FloaterStyle = new FloaterStyle();

	var mActor:ActorGameObject;

	var mFloaterText:MovieClip;

	var mBmp:Bitmap;

	var mBmpData:BitmapData;

	var mType:UInt = 0;

	public function new(dbFacade:DBFacade, delta:Float, actorGameObject:ActorGameObject, holdDuration:UInt, totalDuration:UInt, scaleDampening:Float,
			floatSpeed:Float, finishedCallback:ASFunction, attackerIsOwner:Bool, attackeeIsOwner:Bool, blit:Bool = true, isCriticalHit:Bool = false,
			effectiveness:Int = 0, inType:UInt = (0 : UInt), movementType:String = "DAMAGE_MOVEMENT_TYPE") {
		mActor = actorGameObject;
		mDBFacade = dbFacade;
		mType = inType;
		setup(isCriticalHit, delta, attackerIsOwner, attackeeIsOwner, blit, effectiveness);
		var _loc16_ = ASCompat.coerce(blit ? mBmp : mFloaterText, flash.display.DisplayObject);
		super(_loc16_, dbFacade, holdDuration, totalDuration, scaleDampening, floatSpeed, mFloatDirection, finishedCallback, movementType);
		mDBFacade.sceneGraphManager.addChild(mRoot, 30);
	}

	public static function spawn(dbFacade:DBFacade, delta:Float, actorGameObject:ActorGameObject, holdDuration:UInt, totalDuration:UInt, scaleDampening:Float,
			floatSpeed:Float, attackerIsOwner:Bool, attackeeIsOwner:Bool, isCriticalHit:Bool, effectiveness:Int, inType:UInt, movementType:String) {
		var _loc14_:DisplayObject = null;
		if (StarlingOverlays.drawsFloaters(dbFacade)) {
			describe(dbFacade, delta, inType, isCriticalHit, attackerIsOwner, attackeeIsOwner, effectiveness, sStyle);
			_loc14_ = actorGameObject.view.root;
			if (StarlingOverlays.get(dbFacade)
				.spawnFloater(sStyle, _loc14_.x, _loc14_.y - 80, holdDuration, totalDuration, scaleDampening, floatSpeed,
					movementType == "BUFF_DAMAGE_MOVEMENT_TYPE")) {
				if (effectiveness != 0) {
					showEffectivenessFX(actorGameObject, effectiveness);
				}
				return;
			}
		}
		if (dbFacade.hud == null || dbFacade.hud.floaterTextClass == null) {
			return;
		}
		new DamageFloater(dbFacade, delta, actorGameObject, holdDuration, totalDuration, scaleDampening, floatSpeed, null, attackerIsOwner, attackeeIsOwner,
			true, isCriticalHit, effectiveness, inType, movementType);
	}

	static function showEffectivenessFX(actor:ActorGameObject, effectiveness:Int) {
		var _loc4_:String;
		var _loc3_:Vector3D;
		var _loc5_:Float;
		var _loc6_:Float;
		var _loc7_:String = null;
		if (actor.isHeroType || !actor.effectivenessShown) {
			actor.effectivenessShown = true;
			_loc4_ = DBFacade.buildFullDownloadPath("Resources/Art2D/FX/db_fx_library.swf");
			switch (effectiveness - -2) {
				case 0:
					_loc7_ = "db_fx_hit_fail";

				case 1:
					_loc7_ = "db_fx_hit_weak";

				case 2:
					_loc7_ = "db_fx_hit_bang";

				case 3:
					_loc7_ = "db_fx_hit_super";

				case 4:
					_loc7_ = "db_fx_hit_sweet";
			}
			_loc3_ = new Vector3D(actor.view.root.x, actor.view.root.y - 80, 0);
			_loc5_ = 1;
			_loc6_ = 0;
			actor.distributedDungeonFloor.effectManager.playEffect(_loc4_, _loc7_, _loc3_, null, false, _loc5_, _loc6_, 0, 0, 0, false, "foreground");
			return;
		}
	}

	static function getEffectivenessTextColor(effectiveness:Int):UInt {
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

	public static function describe(dbFacade:DBFacade, delta:Float, type:UInt, isCriticalHit:Bool, attackerIsOwner:Bool, attackeeIsOwner:Bool,
			effectiveness:Int, style:FloaterStyle) {
		var _loc10_ = 0;
		var _loc15_:String = null;
		var _loc13_:GMBuffColorType = null;
		var _loc11_:Float = 1;
		var _loc12_:Float = 1;
		var _loc14_:Float = 0;
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
				_loc10_ = 16711680;
				switch (type - 1) {
					case 0:
						_loc10_ = 65280;

					case 1:
						_loc10_ = 9065403;
				}
			} else {
				_loc10_ = ASCompat.toInt(isCriticalHit ? 16750848 : getEffectivenessTextColor(effectiveness));
			}
			if (type > 10) {
				_loc13_ = ASCompat.coerce(dbFacade.gameMaster.buffColorTypeById.itemFor(type), gameMasterDictionary.GMBuffColorType);
				_loc10_ = (_loc13_.ColorHex : Int);
			}
			_loc14_ = (Math.random() - 0.5) * 0.5;
		} else {
			_loc15_ = "+" + Std.string(delta);
			_loc10_ = 9502608;
			if (attackeeIsOwner) {
				_loc11_ = _loc12_ = 1 * 1.1;
				_loc10_ = 2293538;
				switch (type - 2) {
					case 0:
						_loc10_ = 9065403;
				}
			}
		}
		var _loc9_ = Math.sqrt(_loc14_ * _loc14_ + 1);
		style.text = _loc15_;
		style.color = (_loc10_ : UInt);
		style.scale = _loc11_;
		style.directionX = _loc14_ / _loc9_;
		style.directionY = -1 / _loc9_;
		style.rotation = Math.atan2(style.directionY, style.directionX) * 180 / 3.141592653589793 + 90;
		style.crit = isCriticalHit;
	}

	function setup(isCriticalHit:Bool, delta:Float, attackerIsOwner:Bool, attackeeIsOwner:Bool, blit:Bool, effectiveness:Int) {
		var _loc12_:Rectangle = null;
		var _loc7_:Matrix = null;
		mFloaterText = ASCompat.dynamicAs(ASCompat.createInstance(mDBFacade.hud.floaterTextClass, []), MovieClip);
		describe(mDBFacade, delta, mType, isCriticalHit, attackerIsOwner, attackeeIsOwner, effectiveness, sStyle);
		var _loc13_ = sStyle.text;
		var _loc9_ = sStyle.color;
		var _loc10_ = sStyle.scale;
		var _loc11_ = sStyle.scale;
		mFloatDirection = new Vector3D(sStyle.directionX, sStyle.directionY, 0);
		var _loc8_ = sStyle.rotation;
		if (effectiveness != 0) {
			showEffectivenessFX(mActor, effectiveness);
		}
		ASCompat.setProperty((mFloaterText : ASAny).label, "text", _loc13_);
		ASCompat.setProperty((mFloaterText : ASAny).label, "textColor", _loc9_);
		if (isCriticalHit) {
			mFloaterText.filters = cast([CRIT_FILTER]);
		}
		if (blit) {
			mBmpData = new BitmapData(ASCompat.floatToInt(mFloaterText.width), ASCompat.floatToInt(mFloaterText.height), true, (0 : UInt));
			_loc12_ = mFloaterText.getBounds(mFloaterText);
			_loc7_ = new Matrix();
			_loc7_.translate(-_loc12_.x, -_loc12_.y);
			mBmpData.draw(mFloaterText, _loc7_);
			mBmp = new Bitmap(mBmpData, "auto", true);
			mBmp.scaleX = _loc10_;
			mBmp.scaleY = _loc11_;
			mBmp.x = mActor.view.root.x - mBmp.width * 0.5;
			mBmp.y = mActor.view.root.y - 80;
			mBmp.rotation = _loc8_;
		} else {
			mFloaterText.scaleX = _loc10_;
			mFloaterText.scaleY = _loc11_;
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
