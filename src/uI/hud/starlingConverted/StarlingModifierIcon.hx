package uI.hud.starlingConverted;

import brain.assetRepository.AssetLoadingComponent;
import brain.event.EventListeners;
import facade.DBFacade;
import facade.GameMasterLocale;
import gameMasterDictionary.GMLegendaryModifier;
import gameMasterDictionary.GMModifier;
import uI.modifiers.UIModifierTooltip;
import flash.display.MovieClip;
import flash.events.MouseEvent;

/*internal*/
class StarlingModifierIcon {
	@:allow(uI.hud.starlingConverted) static inline final MODIFIER_UI_SWF_NAME = "Resources/Art2D/Icons/Modifier/db_icons_modifier.swf";

	@:allow(uI.hud.starlingConverted) static inline final MODIFIER_UI_CLASS_NAME = "ui_modifier_template";

	@:allow(uI.hud.starlingConverted) static inline final MODIFIER_TOOLTIP_CLASS_NAME = "modifier_tooltip";

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
		if (!isLegendaryModifier) {
			if (constant != "") {
				mGMModifier = ASCompat.coerce(mDBFacade.gameMaster.modifiersByConstant.itemFor(constant), gameMasterDictionary.GMModifier);
			} else {
				if (id <= 0) {
					throw new Error("Invalid Starling modifier data");
				}
				mGMModifier = ASCompat.coerce(mDBFacade.gameMaster.modifiersById.itemFor(id), gameMasterDictionary.GMModifier);
			}
		} else if (legendaryModifierNum > 0) {
			mGMLegendaryModifier = ASCompat.coerce(mDBFacade.gameMaster.legendaryModifiersById.itemFor(legendaryModifierNum),
				gameMasterDictionary.GMLegendaryModifier);
		} else {
			if (!ASCompat.stringAsBool(constant)) {
				throw new Error("Invalid Starling modifier data");
			}
			mGMLegendaryModifier = ASCompat.coerce(mDBFacade.gameMaster.legendaryModifiersByConstant.itemFor(constant),
				gameMasterDictionary.GMLegendaryModifier);
		}
		if (parentMC == null || mGMModifier == null && mGMLegendaryModifier == null) {
			throw new Error("Missing Starling modifier data");
		}
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
		mParentMC = parentMC;
		setupOnUI();
	}

	function setupOnUI() {
		var iconName = mGMLegendaryModifier != null ? mGMLegendaryModifier.IconName : mGMModifier.IconName;
		HudArt.loadRuntimeSwf(mAssetLoadingComponent, "Resources/Art2D/Icons/Modifier/db_icons_modifier.swf", iconName,
			function(param1:brain.assetRepository.SwfAsset) {
				var _loc4_:MovieClip = null;
				var _loc3_ = 0;
				var _loc6_ = 0;
				if (mParentMC == null) {
					return;
				}
				var _loc7_ = HudIconBake.symbol(param1, "Resources/Art2D/Icons/Modifier/db_icons_modifier.swf", iconName);
				var _loc2_ = HudIconBake.symbol(param1, "Resources/Art2D/Icons/Modifier/db_icons_modifier.swf", "ui_modifier_template");
				mRoot = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), MovieClip);
				if (mRoot == null) {
					HudArt.fatal("Required HUD modifier template is not a MovieClip: Resources/Art2D/Icons/Modifier/db_icons_modifier.swf ui_modifier_template");
				}
				mParentMC.addChild(mRoot);
				if (ASCompat.toBool((mParentMC : ASAny).modifier_icon_frame)) {
					ASCompat.setProperty((mParentMC : ASAny).modifier_icon_frame, "visible", false);
				}
				var _loc5_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc7_, []), MovieClip);
				if (_loc5_ == null) {
					HudArt.fatal("Required HUD modifier icon is not a MovieClip: Resources/Art2D/Icons/Modifier/db_icons_modifier.swf " + iconName);
				}
				_loc5_.scaleX = _loc5_.scaleY = 0.5;
				(mRoot : ASAny).modifier_icon.addChild(_loc5_);
				if (mGMLegendaryModifier != null) {
					ASCompat.setProperty((mRoot : ASAny).modifier_icon_slot, "visible", false);
				}
				if (mGMLegendaryModifier == null) {
					_loc3_ = 5;
					_loc6_ = 0;
					while (_loc6_ < _loc3_) {
						_loc4_ = ASCompat.coerce(cast((mRoot : ASAny).modifier_icon_slot, flash.display.DisplayObjectContainer).getChildByName("star"
							+ Std.string((_loc6_ + 1))),
							flash.display.MovieClip);
						_loc4_.visible = false;
						_loc6_++;
					}
					_loc6_ = 0;
					while ((_loc6_ : UInt) < mGMModifier.Level) {
						_loc4_ = ASCompat.coerce(cast((mRoot : ASAny).modifier_icon_slot, flash.display.DisplayObjectContainer).getChildByName("star"
							+ Std.string((_loc6_ + 1))),
							flash.display.MovieClip);
						_loc4_.visible = true;
						_loc6_++;
					}
				}
				HudArt.requireClass(param1, "Resources/Art2D/Icons/Modifier/db_icons_modifier.swf", "modifier_tooltip");
				mToolTip = new UIModifierTooltip(mDBFacade, mRoot, param1,
					mGMLegendaryModifier != null ? GameMasterLocale.getGameMasterSubString("LEGENDARY_MODIFIER_NAME",
						mGMLegendaryModifier.Constant) : GameMasterLocale.getGameMasterSubString("MODIFIER_NAME", mGMModifier.Constant),
					mGMLegendaryModifier != null ? GameMasterLocale.getGameMasterSubString("LEGENDARY_MODIFIER_DESCRIPTION",
						mGMLegendaryModifier.Constant) : GameMasterLocale.getGameMasterSubString("MODIFIER_DESCRIPTION", mGMModifier.Constant));
				mToolTip.hide();
				EventListeners.add(mRoot, "rollOver", onMouseOver);
				EventListeners.add(mRoot, "rollOut", onMouseOut);
			});
	}

	function onMouseOver(mEvt:MouseEvent) {
		try {
			mToolTip.show();
		} catch (error:Dynamic) {
			StarlingHud.reportError(ASCompat.asError(error));
		}
	}

	function onMouseOut(mEvt:MouseEvent) {
		try {
			mToolTip.hide();
		} catch (error:Dynamic) {
			StarlingHud.reportError(ASCompat.asError(error));
		}
	}

	public function destroy() {
		if (mParentMC == null) {
			return;
		}
		if (ASCompat.toBool((mParentMC : ASAny).modifier_icon_frame)) {
			ASCompat.setProperty((mParentMC : ASAny).modifier_icon_frame, "visible", true);
		}
		if (mRoot != null) {
			EventListeners.remove(mRoot, "rollOver", onMouseOver);
			EventListeners.remove(mRoot, "rollOut", onMouseOut);
			if (mRoot.parent != null) {
				mRoot.parent.removeChild(mRoot);
			}
		}
		mRoot = null;
		StarlingHud.disposeResource(mAssetLoadingComponent, "destroy");
		mAssetLoadingComponent = null;
		mParentMC = null;
		if (mToolTip != null) {
			StarlingHud.disposeResource(mToolTip, "destroy");
			mToolTip = null;
		}
	}
}
