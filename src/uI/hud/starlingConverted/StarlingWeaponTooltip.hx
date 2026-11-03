package uI.hud.starlingConverted;

import brain.assetRepository.AssetLoadingComponent;
import brain.utils.TextUtil;
import combat.weapon.WeaponGameObject;
import facade.DBFacade;
import facade.GameMasterLocale;
import facade.Locale;
import gameMasterDictionary.GMRarity;
import uI.inventory.UIWeaponTooltip;
import flash.display.MovieClip;

class StarlingWeaponTooltip extends MovieClip {
	@:allow(UI.Hud.StarlingConverted) static inline final ABILITY_SWF = "Resources/Art2D/Icons/weapon_ability/db_icons_weapon_ability.swf";

	var mFacade:DBFacade;

	var mRoot:MovieClip;

	var mAssets:AssetLoadingComponent;

	var mModifiers:Vector<StarlingModifierIcon> = new Vector((0 : UInt));

	var mGeneration:UInt = 0;

	public function new(facade:DBFacade, template:Dynamic) {
		super();
		mFacade = facade;
		mRoot = ASCompat.dynamicAs(ASCompat.createInstance(template, []), MovieClip);
		HudArtConverter.stopTree(mRoot);
		addChild(mRoot);
		mRoot.scaleX = mRoot.scaleY = UIWeaponTooltip.tooltipScale(ASCompat.coerce((mRoot : ASAny).title_label, flash.text.TextField), 1.09);
		Locale.setText(ASCompat.coerce((mRoot : ASAny).power.attack_label, flash.text.TextField), "POWER");
	}

	public function setWeaponItemFromWeaponGameObject(weapon:WeaponGameObject) {
		var _loc4_ = 0;
		clearAllIcons();
		mAssets = new AssetLoadingComponent(mFacade);
		var _loc6_ = ASCompat.coerce(mFacade.gameMaster.rarityById.itemFor(weapon.rarity), gameMasterDictionary.GMRarity);
		ASCompat.setProperty((mRoot : ASAny).title_label, "textColor", _loc6_ != null
			&& _loc6_.TextColor != 0 ? _loc6_.TextColor : 15463921);
		TextUtil.setText(ASCompat.coerce((mRoot : ASAny).power.label, flash.text.TextField), Std.string(weapon.power));
		TextUtil.setText(ASCompat.coerce((mRoot : ASAny).level_label, flash.text.TextField),
			Locale.getString("ITEM_CARD_LEVEL_REQUIREMENT") + weapon.requiredLevel);
		var _loc3_ = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME", weapon.weaponAesthetic.Constant);
		var _loc2_ = "";
		var _loc5_ = weapon.modifierList;
		_loc4_ = 0;
		while (_loc4_ < _loc5_.length) {
			mModifiers.push(new StarlingModifierIcon(mFacade, ASCompat.reinterpretAs(mRoot.getChildByName("modifier_icon_" + (_loc4_ + 1)), MovieClip),
				_loc5_[_loc4_].Constant));
			_loc2_ += GameMasterLocale.getGameMasterSubString("MODIFIER_NAME", _loc5_[_loc4_].Constant).toUpperCase() + " ";
			_loc4_++;
		}
		_loc3_ = _loc2_ + _loc3_;
		if (weapon.legendaryModifier != null) {
			mModifiers.push(new StarlingModifierIcon(mFacade, ASCompat.reinterpretAs(mRoot.getChildByName("modifier_icon_3"), MovieClip), "", (0 : UInt),
				true, weapon.legendaryModifier.Id));
			_loc3_ = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME", weapon.weaponData.getWeaponAesthetic((0 : UInt), true).Constant);
		}
		TextUtil.setText(ASCompat.coerce((mRoot : ASAny).title_label, flash.text.TextField), _loc3_.toUpperCase());
		loadIcon(weapon.weaponData.TapIcon, ASCompat.coerce((mRoot : ASAny).tap_icon, flash.display.MovieClip));
		loadIcon(weapon.weaponData.HoldIcon, ASCompat.coerce((mRoot : ASAny).icon, flash.display.MovieClip));
	}

	function loadIcon(name:String, parent:MovieClip) {
		var generation:UInt;
		var swf:String;
		if (name == null || name.length == 0) {
			return;
		}
		generation = mGeneration;
		swf = "Resources/Art2D/Icons/weapon_ability/db_icons_weapon_ability.swf";
		HudArt.loadRuntimeSwf(mAssets, swf, name, function(param1:brain.assetRepository.SwfAsset) {
			if (mRoot == null || generation != mGeneration) {
				return;
			}
			var _loc2_ = HudIconBake.symbol(param1, swf, name);
			var _loc3_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), MovieClip);
			if (_loc3_ == null) {
				HudArt.fatal("Required HUD tooltip icon is not a MovieClip: " + swf + " " + name);
			}
			_loc3_.scaleX = _loc3_.scaleY = 0.5;
			parent.addChildAt(_loc3_, 1);
		});
	}

	public function clearAllIcons() {
		var _loc1_:StarlingModifierIcon = null;
		mGeneration = mGeneration + 1;
		if (mAssets != null) {
			mAssets.destroy();
		}
		mAssets = null;
		while (ASCompat.toNumberField((mRoot : ASAny).tap_icon, "numChildren") > 1) {
			(mRoot : ASAny).tap_icon.removeChildAt(1);
		}
		while (ASCompat.toNumberField((mRoot : ASAny).icon, "numChildren") > 1) {
			(mRoot : ASAny).icon.removeChildAt(1);
		}
		final __ax4_iter_185 = mModifiers;
		if (checkNullIteratee(__ax4_iter_185))
			for (_tmp_ in __ax4_iter_185) {
				_loc1_ = _tmp_;
				try {
					_loc1_.destroy();
				} catch (error:Dynamic) {
					StarlingHud.reportError(error);
				}
			}
		mModifiers.length = 0;
	}

	public function destroy() {
		clearAllIcons();
		if (parent != null) {
			parent.removeChild(this);
		}
		removeChild(mRoot);
		mRoot = null;
		mFacade = null;
	}
}
