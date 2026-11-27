package uI;

import brain.assetRepository.AssetLoadingComponent;
import brain.render.MovieClipRenderController;
import brain.render.MovieClipRenderer;
import brain.render.tweens.TweenHandle;
import brain.uI.UIObject;
import brain.utils.MemoryTracker;
import brain.utils.TextUtil;
import facade.DBFacade;
import facade.Locale;
import gameMasterDictionary.GMHero;
import gameMasterDictionary.GMNpc;
import gameMasterDictionary.GMSkin;
import steamAchievements.SteamAPINames;
import town.TownHeader;
import uI.popup.DBUIOneButtonPopup;
import flash.display.MovieClip;

class UIBragFeedPost {
	public function new() {}

	public static function buyHeroSuccess(townHeader:TownHeader, gmHero:GMHero, facade:DBFacade, assetLoadingComponent:AssetLoadingComponent) {
		var gloatPopup:MovieClip;
		var popupCenterButtonText:String;
		var popupTitle = Locale.getString("BRAG_BUY_HERO_SUCCESS_POPUP_TITLE");
		var avatarPicScale:Float = 0.4;
		facade.steamAchievementsHelper.unlockAchievement(SteamAPINames.getUnlockHeroAchievementAPIName(gmHero.Constant));
		popupCenterButtonText = Locale.getString("SWEET");
		assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),
			function(param1:brain.assetRepository.SwfAsset) {
				var swfAsset = param1;
				var tooltipClass = swfAsset.getClass("weapon_tavern_tooltip");
				var gloatPopupClassName = "avatar_purchase_popup";
				var gloatPopupClass = swfAsset.getClass(gloatPopupClassName);
				gloatPopup = ASCompat.coerce(ASCompat.createInstance(gloatPopupClass, []), flash.display.MovieClip);
				gloatPopup.x += 40;
				assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmHero.PortraitName), function(param1:brain.assetRepository.SwfAsset) {
					var TeamBonusUI:UIObject;
					var teamBonusUIMCRenderer:MovieClipRenderer;
					var TeamBonusUIHeader:UIObject;
					var teamBonusUIHeaderMCRenderer:MovieClipRenderer;
					var onCompleteFunc:ASFunction = null;
					var onCompleteHeaderFunc:ASFunction = null;
					var teamBonusUITween:TweenHandle;
					var teamBonusUIHeaderTween:TweenHandle;
					var cleanupFunc:ASFunction;
					var popup:DBUIOneButtonPopup;
					var swfAsset = param1;
					var picClass = swfAsset.getClass(gmHero.PortraitClassName);
					var avatarPic = ASCompat.coerce(ASCompat.createInstance(picClass, []), flash.display.MovieClip);
					var movieClipRenderer = new MovieClipRenderController(facade, avatarPic);
					movieClipRenderer.play();
					avatarPic.scaleX = avatarPic.scaleY = avatarPicScale;
					if (ASCompat.toNumberField((gloatPopup : ASAny).avatar, "numChildren") > 0) {
						(gloatPopup : ASAny).avatar.removeChildAt(0);
					}
					(gloatPopup : ASAny).avatar.addChildAt(avatarPic, 0);
					TextUtil.setText(ASCompat.coerce((gloatPopup : ASAny).gloat_text, flash.text.TextField),
						Locale.getString("BRAG_BUY_HERO_SUCCESS_POPUP_TEXT") + gmHero.Name.toUpperCase());
					TeamBonusUI = new UIObject(facade, ASCompat.coerce((gloatPopup : ASAny).crewbonus, flash.display.MovieClip));
					Locale.setText(ASCompat.coerce((TeamBonusUI.tooltip : ASAny).title_label, flash.text.TextField), "TEAM_BONUS_TOOLTIP_TITLE");
					Locale.setText(ASCompat.coerce((TeamBonusUI.tooltip : ASAny).description_label, flash.text.TextField), "TEAM_BONUS_TOOLTIP_DESCRIPTION");
					TextUtil.setText(ASCompat.coerce((TeamBonusUI.root : ASAny).header_crew_bonus_number, flash.text.TextField),
						Std.string((facade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() : Float) - 2), 0.73);
					teamBonusUIMCRenderer = new MovieClipRenderer(facade,
						ASCompat.coerce((TeamBonusUI.root : ASAny).header_crew_bonus_anim, flash.display.MovieClip), onCompleteFunc);
					teamBonusUIMCRenderer.play();
					TeamBonusUIHeader = new UIObject(facade, ASCompat.coerce((gloatPopup : ASAny).crewbonus_header, flash.display.MovieClip));
					Locale.setText(ASCompat.coerce((TeamBonusUIHeader.tooltip : ASAny).title_label, flash.text.TextField), "TEAM_BONUS_TOOLTIP_TITLE");
					Locale.setText(ASCompat.coerce((TeamBonusUIHeader.tooltip : ASAny).description_label, flash.text.TextField),
						"TEAM_BONUS_TOOLTIP_DESCRIPTION");
					TextUtil.setText(ASCompat.coerce((TeamBonusUIHeader.root : ASAny).header_crew_bonus_number, flash.text.TextField),
						Std.string((facade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() : Float) - 2), 0.73);
					teamBonusUIHeaderMCRenderer = new MovieClipRenderer(facade,
						ASCompat.coerce((TeamBonusUIHeader.root : ASAny).header_crew_bonus_anim, flash.display.MovieClip), onCompleteHeaderFunc);
					teamBonusUIHeaderMCRenderer.play();
					onCompleteFunc = function() {
						TextUtil.setText(ASCompat.coerce((TeamBonusUI.root : ASAny).header_crew_bonus_number, flash.text.TextField),
							Std.string((facade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() : Float) - 1), 0.73);
					};
					onCompleteHeaderFunc = function() {
						TextUtil.setText(ASCompat.coerce((TeamBonusUIHeader.root : ASAny).header_crew_bonus_number, flash.text.TextField),
							Std.string((facade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() : Float) - 1), 0.73);
					};
					teamBonusUITween = facade.mTween.tweenMaxTo((TeamBonusUI.root : ASAny).header_crew_bonus_number, 1.4, {"onComplete": onCompleteFunc});
					teamBonusUIHeaderTween = facade.mTween.tweenMaxTo((TeamBonusUIHeader.root : ASAny).header_crew_bonus_number, 1.4,
						{"onComplete": onCompleteHeaderFunc});
					cleanupFunc = function() {
						facade.mTween.killTween(teamBonusUITween);
						facade.mTween.killTween(teamBonusUIHeaderTween);
						TeamBonusUI.destroy();
						TeamBonusUI = null;
						TeamBonusUIHeader.destroy();
						TeamBonusUIHeader = null;
					};
					popup = new DBUIOneButtonPopup(facade, "BRAG_FEED_POPUP", popupTitle, gloatPopup, popupCenterButtonText, cleanupFunc, true, cleanupFunc);
					MemoryTracker.track(popup, "DBUIOneButtonPopup - created in UIBragFeedPost.buyHeroSuccess()");
					popup.root.x = 100;
					popup.root.y = -180;
					avatarPic.y -= avatarPic.height / 2;
					avatarPic.x -= 150 * avatarPicScale;
					townHeader.updateTeamBonusUI();
				});
			});
	}

	public static function buySkinSuccess(gmSkin:GMSkin, facade:DBFacade, assetLoadingComponent:AssetLoadingComponent) {
		var gloatPopup:MovieClip;
		var popupTitle = Locale.getString("BRAG_BUY_HERO_SUCCESS_POPUP_TITLE");
		var avatarPicScale:Float = 0.45;
		var popupCenterButtonText = Locale.getString("SWEET");
		assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),
			function(param1:brain.assetRepository.SwfAsset) {
				var swfAsset = param1;
				var tooltipClass = swfAsset.getClass("weapon_tavern_tooltip");
				var gloatPopupClass = swfAsset.getClass("tavern_gloat");
				gloatPopup = ASCompat.coerce(ASCompat.createInstance(gloatPopupClass, []), flash.display.MovieClip);
				gloatPopup.x += 40;
				assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmSkin.PortraitName), function(param1:brain.assetRepository.SwfAsset) {
					var _loc5_ = param1.getClass(gmSkin.PortraitClassName);
					var _loc2_ = ASCompat.coerce(ASCompat.createInstance(_loc5_, []), flash.display.MovieClip);
					var _loc4_ = new MovieClipRenderController(facade, _loc2_);
					_loc4_.play();
					_loc2_.scaleX = _loc2_.scaleY = avatarPicScale;
					_loc2_.y -= _loc2_.height / 2;
					_loc2_.x -= 150 * avatarPicScale;
					if (ASCompat.toNumberField((gloatPopup : ASAny).avatar, "numChildren") > 0) {
						(gloatPopup : ASAny).avatar.removeChildAt(0);
					}
					(gloatPopup : ASAny).avatar.addChildAt(_loc2_, 0);
					TextUtil.setText(ASCompat.coerce((gloatPopup : ASAny).gloat_text, flash.text.TextField),
						Locale.getString("BRAG_BUY_HERO_SUCCESS_POPUP_TEXT") + gmSkin.Name.toUpperCase());
					var _loc3_ = new DBUIOneButtonPopup(facade, "BRAG_FEED_POPUP", popupTitle, gloatPopup, popupCenterButtonText, null);
					MemoryTracker.track(_loc3_, "DBUIOneButtonPopup - created in UIBragFeedPost.buySkinSuccess()");
				});
			});
	}

	public static function buyPetSuccess(gmPet:GMNpc, facade:DBFacade, assetLoadingComponent:AssetLoadingComponent) {
		var gloatPopup:MovieClip;
		var popupTitle = Locale.getString("BRAG_BUY_PET_SUCCESS_POPUP_TITLE");
		var avatarPicScale:Float = 1;
		var popupCenterButtonText = Locale.getString("SWEET");
		assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),
			function(param1:brain.assetRepository.SwfAsset) {
				var swfAsset = param1;
				var tooltipClass = swfAsset.getClass("weapon_tavern_tooltip");
				var gloatPopupClass = swfAsset.getClass("tavern_gloat");
				gloatPopup = ASCompat.coerce(ASCompat.createInstance(gloatPopupClass, []), flash.display.MovieClip);
				gloatPopup.x += 40;
				assetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmPet.IconSwfFilepath), function(param1:brain.assetRepository.SwfAsset) {
					var _loc5_ = param1.getClass(gmPet.IconName);
					var _loc2_ = ASCompat.coerce(ASCompat.createInstance(_loc5_, []), flash.display.MovieClip);
					var _loc4_ = new MovieClipRenderController(facade, _loc2_);
					_loc4_.play();
					_loc2_.scaleX = _loc2_.scaleY = avatarPicScale;
					_loc2_.y -= _loc2_.height / 2;
					_loc2_.x = 0;
					if (ASCompat.toNumberField((gloatPopup : ASAny).avatar, "numChildren") > 0) {
						(gloatPopup : ASAny).avatar.removeChildAt(0);
					}
					(gloatPopup : ASAny).avatar.addChildAt(_loc2_, 0);
					TextUtil.setText(ASCompat.coerce((gloatPopup : ASAny).gloat_text, flash.text.TextField),
						Locale.getString("BRAG_BUY_PET_SUCCESS_POPUP_TEXT") + gmPet.Name.toUpperCase());
					var _loc3_ = new DBUIOneButtonPopup(facade, "BRAG_FEED_POPUP", popupTitle, gloatPopup, popupCenterButtonText, null);
					MemoryTracker.track(_loc3_, "DBUIOneButtonPopup - created in UIBragFeedPost.buyPetSuccess()");
				});
			});
	}
}
