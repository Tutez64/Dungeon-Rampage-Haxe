package uI.modifiers;

import brain.assetRepository.AssetLoadingComponent;
import brain.logger.Logger;
import facade.DBFacade;
import facade.GameMasterLocale;
import gameMasterDictionary.GMLegendaryModifier;
import gameMasterDictionary.GMModifier;
import flash.display.MovieClip;
import flash.events.MouseEvent;

class UIModifier {
	public static inline final MODIFIER_UI_SWF_NAME = "Resources/Art2D/Icons/Modifier/db_icons_modifier.swf";

	public static inline final MODIFIER_UI_CLASS_NAME = "ui_modifier_template";

	var mParentMC:MovieClip;

	var mRoot:MovieClip;

	var mGMModifier:GMModifier;

	var mGMLegendaryModifier:GMLegendaryModifier;

	var mToolTip:UIModifierTooltip;

	var mDBFacade:DBFacade;

	var mAssetLoadingComponent:AssetLoadingComponent;

	public function new(dbFacade:DBFacade, parentMC:MovieClip, constant:String, id:UInt = (0 : UInt), isLegendaryModifier:Bool = false,
			legendaryModifierNum:UInt = (0 : UInt)) {
		mDBFacade = dbFacade;
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
		if (!isLegendaryModifier) {
			if (constant != "") {
				mGMModifier = ASCompat.dynamicAs(mDBFacade.gameMaster.modifiersByConstant.itemFor(constant), gameMasterDictionary.GMModifier);
			} else {
				if (id <= 0) {
					Logger.error("Creating UIModifierRegular with invalid data");
					return;
				}
				mGMModifier = ASCompat.dynamicAs(mDBFacade.gameMaster.modifiersById.itemFor(id), gameMasterDictionary.GMModifier);
			}
		} else if (legendaryModifierNum > 0) {
			mGMLegendaryModifier = ASCompat.dynamicAs(mDBFacade.gameMaster.legendaryModifiersById.itemFor(legendaryModifierNum),
				gameMasterDictionary.GMLegendaryModifier);
		} else {
			if (!ASCompat.stringAsBool(constant)) {
				Logger.error("Creating UIModifierLegendary with invalid data");
				return;
			}
			mGMLegendaryModifier = ASCompat.dynamicAs(mDBFacade.gameMaster.legendaryModifiersByConstant.itemFor(constant),
				gameMasterDictionary.GMLegendaryModifier);
		}
		mParentMC = parentMC;
		setupOnUI();
	}

	@:isVar public var gmModifier(get, never):GMModifier;

	public function get_gmModifier():GMModifier {
		return mGMModifier;
	}

	public function setupOnUI() {
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Modifier/db_icons_modifier.swf"),
			function(param1:brain.assetRepository.SwfAsset) {
				var _loc4_:MovieClip = null;
				var _loc3_ = 0;
				var _loc6_ = 0;
				if (mParentMC == null) {
					return;
				}
				var _loc2_ = param1.getClass("ui_modifier_template");
				mRoot = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), MovieClip);
				mParentMC.addChild(mRoot);
				if (ASCompat.toBool((mParentMC : ASAny).modifier_icon_frame)) {
					ASCompat.setProperty((mParentMC : ASAny).modifier_icon_frame, "visible", false);
				}
				var _loc7_ = param1.getClass(mGMLegendaryModifier != null ? mGMLegendaryModifier.IconName : mGMModifier.IconName);
				var _loc5_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc7_, []), MovieClip);
				_loc5_.scaleX = _loc5_.scaleY = 0.5;
				(mRoot : ASAny).modifier_icon.addChild(_loc5_);
				if (mGMLegendaryModifier != null) {
					ASCompat.setProperty((mRoot : ASAny).modifier_icon_slot, "visible", false);
				}
				if (mGMLegendaryModifier == null) {
					_loc3_ = 5;
					_loc6_ = 0;
					while (_loc6_ < _loc3_) {
						_loc4_ = ASCompat.dynamicAs(cast((mRoot : ASAny).modifier_icon_slot, flash.display.DisplayObjectContainer).getChildByName("star"
							+ Std.string((_loc6_ + 1))),
							flash.display.MovieClip);
						_loc4_.visible = false;
						_loc6_++;
					}
					_loc6_ = 0;
					while ((_loc6_ : UInt) < mGMModifier.Level) {
						_loc4_ = ASCompat.dynamicAs(cast((mRoot : ASAny).modifier_icon_slot, flash.display.DisplayObjectContainer).getChildByName("star"
							+ Std.string((_loc6_ + 1))),
							flash.display.MovieClip);
						_loc4_.visible = true;
						_loc6_++;
					}
				}
				mToolTip = new UIModifierTooltip(mDBFacade, mRoot, param1,
					mGMLegendaryModifier != null ? GameMasterLocale.getGameMasterSubString("LEGENDARY_MODIFIER_NAME",
						mGMLegendaryModifier.Constant) : GameMasterLocale.getGameMasterSubString("MODIFIER_NAME", mGMModifier.Constant),
					mGMLegendaryModifier != null ? GameMasterLocale.getGameMasterSubString("LEGENDARY_MODIFIER_DESCRIPTION",
						mGMLegendaryModifier.Constant) : GameMasterLocale.getGameMasterSubString("MODIFIER_DESCRIPTION", mGMModifier.Constant));
				mToolTip.hide();
				mRoot.addEventListener("rollOver", onMouseOver);
				mRoot.addEventListener("rollOut", onMouseOut);
			});
	}

	public function onMouseOver(mEvt:MouseEvent) {
		mToolTip.show();
	}

	public function onMouseOut(mEvt:MouseEvent) {
		mToolTip.hide();
	}

	public function destroy() {
		if (ASCompat.toBool((mParentMC : ASAny).modifier_icon_frame)) {
			ASCompat.setProperty((mParentMC : ASAny).modifier_icon_frame, "visible", true);
		}
		if (mRoot != null) {
			mRoot.removeEventListener("rollOver", onMouseOver);
			mRoot.removeEventListener("rollOut", onMouseOut);
			mParentMC.removeChild(mRoot);
		}
		mRoot = null;
		mAssetLoadingComponent.destroy();
		mAssetLoadingComponent = null;
		mParentMC = null;
		if (mToolTip != null) {
			mToolTip.destroy();
			mToolTip = null;
		}
	}
}
