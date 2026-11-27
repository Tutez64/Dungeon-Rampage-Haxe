package uI.map;

import brain.assetRepository.SwfAsset;
import brain.render.MovieClipRenderController;
import brain.uI.UIButton;
import brain.uI.UIObject;
import brain.uI.UIProgressBar;
import brain.utils.TextUtil;
import brain.workLoop.LogicalWorkComponent;
import brain.workLoop.Task;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import facade.GameMasterLocale;
import facade.Locale;
import gameMasterDictionary.GMColiseumTier;
import gameMasterDictionary.GMHero;
import gameMasterDictionary.GMMapNode;
import gameMasterDictionary.GMSkin;
import uI.popup.DBUIPopup;
import flash.display.MovieClip;
import flash.events.KeyboardEvent;
import flash.geom.Point;

class UIMapBattlePopup extends DBUIPopup {
	static inline final SWF_PATH = "Resources/Art2D/UI/db_UI_screens.swf";

	static inline final POPUP_CLASS_NAME = "battle_popup";

	static inline final POPUP_CLASS_NAME_CONSUMABLES = "battle_popup_consumables";

	static var sPersistedPrivateToggle:Bool = false;

	static final BATTLE_POPUP_POSITION:Point = new Point(250, 0);

	var mLogicalWorkComponent:LogicalWorkComponent;

	var mActiveStacks:Vector<UIButton>;

	var mActiveHeroPortrait:MovieClip;

	var mMapNodeOpen:Bool = false;

	var mCurrentDungeon:GMMapNode;

	var mBattleButton:UIButton;

	var mChangeHeroButton:UIButton;

	var mChangeStatButton:UIButton;

	var mChangeStatReleaseCallback:ASFunction;

	var mChangeHeroReleaseCallback:ASFunction;

	var mChangeShopReleaseCallback:ASFunction;

	var mBattleReleaseCallback:ASFunction;

	var mPrivateButton:UIButton;

	public var IsPrivate:Bool = sPersistedPrivateToggle;

	var mTeamBonusUI:UIObject;

	var isPopupActive:Bool = false;

	var mArrowCursorKey:UInt = (0 : UInt);

	var mPopupNavigationLinkDelay:Task;

	var mOwnsNavigationLayer:Bool = false;

	public function new(dbFacade:DBFacade, changeHeroReleaseCallback:ASFunction, changeStatReleaseCallback:ASFunction, changeShopReleaseCallback:ASFunction,
			battleReleaseCallback:ASFunction, titleText:String) {
		mBattleReleaseCallback = battleReleaseCallback;
		mChangeHeroReleaseCallback = changeHeroReleaseCallback;
		mChangeStatReleaseCallback = changeStatReleaseCallback;
		mChangeShopReleaseCallback = changeShopReleaseCallback;
		super(dbFacade, "", titleText, null, true, false);
		mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade, "UIMapBattlePopup");
	}

	override function getSwfPath():String {
		return "Resources/Art2D/UI/db_UI_screens.swf";
	}

	override function getClassName():String {
		return "battle_popup_consumables";
	}

	function togglePrivate() {
		IsPrivate = !IsPrivate;
		sPersistedPrivateToggle = IsPrivate;
		mPrivateButton.selected = IsPrivate;
	}

	override function setupUI(swfAsset:SwfAsset, titleText:String, content:ASAny, allowClose:Bool, closeCallback:ASFunction) {
		var activeHeroSkin:GMSkin;
		var gmHero:GMHero;
		var currentXp:UInt;
		var level:UInt;
		var levelIndex:UInt;
		var lastLevelExp:UInt;
		var max:UInt;
		var xpBar:UIProgressBar;
		super.setupUI(swfAsset, titleText, content, allowClose, closeCallback);
		mPopup.visible = false;
		if (ASCompat.toBool((mPopup : ASAny).text_activeBooster)) {
			Locale.setText(ASCompat.coerce((mPopup : ASAny).text_activeBooster, flash.text.TextField), "WORLD_MAP_STATS");
		}
		if (ASCompat.toBool((mPopup : ASAny).text_victorRewards)) {
			Locale.setText(ASCompat.coerce((mPopup : ASAny).text_victorRewards, flash.text.TextField), "WORLD_MAP_VICTORY_REWARDS");
		}
		Locale.setText(ASCompat.coerce((mPopup : ASAny).private_dungeon_label, flash.text.TextField), "PRIVATE_DUNGEON_LABEL");
		Locale.setText(ASCompat.coerce((mPopup : ASAny).population_label, flash.text.TextField), "PLAYER_ACTIVITY_POPULATION");
		mPrivateButton = new UIButton(mDBFacade, ASCompat.coerce((mPopup : ASAny).radio_button, flash.display.MovieClip));
		mPrivateButton.releaseCallback = togglePrivate;
		mPrivateButton.selected = IsPrivate;
		activeHeroSkin = mDBFacade.gameMaster.getSkinByType(mDBFacade.dbAccountInfo.activeAvatarInfo.skinId);
		gmHero = ASCompat.coerce(mDBFacade.gameMaster.heroByConstant.itemFor(activeHeroSkin.ForHero), gameMasterDictionary.GMHero);
		TextUtil.setText(ASCompat.coerce((mPopup : ASAny).txt_avatar, flash.text.TextField),
			GameMasterLocale.getGameMasterSubString("SKIN_NAME", gmHero.Constant).toUpperCase());
		mActiveHeroPortrait = ASCompat.coerce((mPopup : ASAny).avatarContainer.avatar, flash.display.MovieClip);
		currentXp = mDBFacade.dbAccountInfo.activeAvatarInfo.experience;
		level = gmHero.getLevelFromExp(currentXp, mDBFacade.dbAccountInfo.activeAvatarInfo.mAscensionLevel);
		levelIndex = (gmHero.getLevelIndex(currentXp, (mDBFacade.dbAccountInfo.activeAvatarInfo.mAscensionLevel : Int)) : UInt);
		lastLevelExp = (ASCompat.toInt(levelIndex > 0 ? gmHero.getExpFromIndex(levelIndex - 1) : 0) : UInt);
		max = gmHero.getExpFromIndex(levelIndex);
		if (currentXp < max) {
			xpBar = new UIProgressBar(mFacade, ASCompat.coerce((mPopup : ASAny).UI_XP.xp_bar, flash.display.MovieClip));
			ASCompat.setProperty((mPopup : ASAny).UI_XP.xp_bar_delta, "visible", false);
			TextUtil.setText(ASCompat.coerce((mPopup : ASAny).UI_XP.xp_points, flash.text.TextField), currentXp + "/" + max);
			xpBar.maximum = max;
			xpBar.minimum = lastLevelExp;
			xpBar.value = currentXp;
		} else {
			TextUtil.setText(ASCompat.coerce((mPopup : ASAny).UI_XP.xp_points, flash.text.TextField), Std.string(currentXp));
		}
		TextUtil.setText(ASCompat.coerce((mPopup : ASAny).UI_XP.xp_level, flash.text.TextField), Std.string(level));
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(activeHeroSkin.PortraitName), function(param1:SwfAsset) {
			var _loc5_ = param1.getClass(activeHeroSkin.BackgroundClassName);
			var _loc3_ = param1.getClass(activeHeroSkin.PortraitClassName);
			if (_loc5_ == null || _loc3_ == null) {
				return;
			}
			var _loc4_ = new MovieClip();
			_loc4_.addChild(ASCompat.coerce(ASCompat.createInstance(_loc5_, []), flash.display.DisplayObject));
			_loc4_.addChild(ASCompat.coerce(ASCompat.createInstance(_loc3_, []), flash.display.DisplayObject));
			var _loc2_ = new MovieClipRenderController(mDBFacade, _loc4_);
			_loc2_.play();
			if (mActiveHeroPortrait.numChildren > 0) {
				mActiveHeroPortrait.removeChildAt(0);
			}
			mActiveHeroPortrait.addChildAt(_loc4_, 0);
		});
		mChangeHeroButton = new UIButton(mDBFacade, ASCompat.coerce((mPopup : ASAny).button_swapAvatar, flash.display.MovieClip));
		mChangeHeroButton.dontKillMyChildren = true;
		mChangeHeroButton.releaseCallback = function() {
			removeNavigationLayer();
			mChangeHeroReleaseCallback();
		};
		mChangeHeroButton.rollOverCursor = "POINT";
		Locale.setText(ASCompat.coerce((mChangeHeroButton.root : ASAny).swap, flash.text.TextField), "WORLD_MAP_CHANGE_HERO_BUTTON");
		ASCompat.setProperty((mPopup : ASAny).button_battle.battle_text, "mouseChildren", false);
		ASCompat.setProperty((mPopup : ASAny).button_battle.battle_text, "mouseEnabled", false);
		mBattleButton = new UIButton(mDBFacade, ASCompat.coerce((mPopup : ASAny).button_battle, flash.display.MovieClip));
		mBattleButton.dontKillMyChildren = true;
		if (mDBFacade.dbAccountInfo.inventoryInfo.getEquipedItemsOnAvatar(mDBFacade.dbAccountInfo.activeAvatarInfo.id).length == 0) {
			mBattleButton.releaseCallback = function() {
				mDBFacade.errorPopup("Warning", "Cannot enter dungeon with no weapons equipped.", "NO_WEAPONS_DUNGEON_ERROR_POPUP");
				mDBFacade.metrics.log("NoWeaponsEquippedWarning");
			};
		} else {
			mBattleButton.releaseCallback = function() {
				removeNavigationLayer();
				mBattleReleaseCallback();
			};
		}
		mBattleButton.rollOverCursor = "POINT";
		if (mCloseButton != null) {
			mCloseButton.dontKillMyChildren = true;
			mCloseButton.releaseCallback = function() {
				animatePopupOut();
				removeNavigationLayer();
			};
			mCloseButton.rollOverCursor = "POINT";
		}
		if (ASCompat.toBool((mPopup : ASAny).crewbonus)) {
			mTeamBonusUI = new UIObject(mDBFacade, ASCompat.coerce((mPopup : ASAny).crewbonus, flash.display.MovieClip));
			Locale.setText(ASCompat.coerce((mTeamBonusUI.tooltip : ASAny).title_label, flash.text.TextField), "TEAM_BONUS_TOOLTIP_TITLE");
			Locale.setText(ASCompat.coerce((mTeamBonusUI.tooltip : ASAny).description_label, flash.text.TextField), "TEAM_BONUS_TOOLTIP_DESCRIPTION");
			Locale.setText(ASCompat.coerce((mTeamBonusUI.root : ASAny).header_crew_bonus_txt1, flash.text.TextField), "TEAM_BONUS_TITLE_CREW", null, 0.82);
			Locale.setText(ASCompat.coerce((mTeamBonusUI.root : ASAny).header_crew_bonus_txt2, flash.text.TextField), "TEAM_BONUS_TITLE_BONUS", null, 0.82);
			TextUtil.setText(ASCompat.coerce((mTeamBonusUI.root : ASAny).header_crew_bonus_number, flash.text.TextField),
				Std.string((mDBFacade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() : Float) - 1), 0.73);
			TextUtil.setText(ASCompat.coerce((mPopup : ASAny).crewBonus_label, flash.text.TextField),
				Std.string((((mDBFacade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() : Float)
					- 1) * 5)) + Locale.getString("TEAM_BONUS_BATTLE_POPUP_TEXT"));
		}
		setDungeonDetails();
	}

	override function handleKeyDown(event:KeyboardEvent) {}

	function pushArrowCursor() {
		if (mArrowCursorKey != 0) {
			return;
		}
		mArrowCursorKey = mDBFacade.mouseCursorManager.pushMouseCursor("ARROW");
	}

	function popArrowCursor() {
		if (mArrowCursorKey == 0) {
			return;
		}
		mDBFacade.mouseCursorManager.popMouseCursor(mArrowCursorKey);
		mArrowCursorKey = (0 : UInt);
	}

	function pushNavigationLayer() {
		var depthBeforePush:UInt;
		if (mOwnsNavigationLayer) {
			if (mDBFacade.menuNavigationController.getTopUILayer() == "UI_MAP_BATTLE_POPUP") {
				mDBFacade.menuNavigationController.setFocusedUiObject(mBattleButton);
			}
			return;
		}
		depthBeforePush = mDBFacade.menuNavigationController.layerDepth;
		mDBFacade.menuNavigationController.pushNewLayer("UI_MAP_BATTLE_POPUP", function() {
			removeNavigationLayer();
			animatePopupOut();
		}, mBattleButton, mBattleButton);
		mOwnsNavigationLayer = mDBFacade.menuNavigationController.layerDepth > depthBeforePush;
	}

	function removeNavigationLayer() {
		if (!mOwnsNavigationLayer) {
			return;
		}
		mOwnsNavigationLayer = false;
		mDBFacade.menuNavigationController.removeLayer("UI_MAP_BATTLE_POPUP");
	}

	function cancelNavigationLayerPush() {
		if (mPopupNavigationLinkDelay != null) {
			mPopupNavigationLinkDelay.destroy();
			mPopupNavigationLinkDelay = null;
		}
	}

	override public function destroy() {
		popArrowCursor();
		cancelNavigationLayerPush();
		removeNavigationLayer();
		super.destroy();
		if (mTeamBonusUI != null) {
			mTeamBonusUI.destroy();
		}
		if (mBattleButton != null) {
			mBattleButton.destroy();
			mBattleButton = null;
		}
		if (mChangeHeroButton != null) {
			mChangeHeroButton.destroy();
			mChangeHeroButton = null;
		}
		if (mChangeStatButton != null) {
			mChangeStatButton.destroy();
			mChangeStatButton = null;
		}
		if (mLogicalWorkComponent != null) {
			mLogicalWorkComponent.destroy();
			mLogicalWorkComponent = null;
		}
	}

	@:isVar public var battleButton(get, never):UIButton;

	public function get_battleButton():UIButton {
		return mBattleButton;
	}

	public function setTitle(value:String) {
		if (mPopup != null && ASCompat.toBool((mPopup : ASAny).title_label)) {
			TextUtil.setText(ASCompat.coerce((mPopup : ASAny).title_label, flash.text.TextField), value);
		}
	}

	public function setDifficulty(value:String) {
		if (mPopup != null && ASCompat.toBool((mPopup : ASAny).text_recommendedLevel)) {
			TextUtil.setText(ASCompat.coerce((mPopup : ASAny).text_recommendedLevel, flash.text.TextField), value);
		}
	}

	@:isVar public var mapNodeOpen(never, set):Bool;

	public function set_mapNodeOpen(value:Bool):Bool {
		return mMapNodeOpen = value;
	}

	@:isVar public var currentDungeon(never, set):GMMapNode;

	public function set_currentDungeon(value:GMMapNode):GMMapNode {
		return mCurrentDungeon = value;
	}

	public function setDungeonDetails() {
		var _loc4_:GMColiseumTier = null;
		var _loc2_:String = null;
		if (mCurrentDungeon == null || mPopup == null) {
			return;
		}
		if (mDBFacade != null && mDBFacade.gameMaster != null && mDBFacade.gameMaster.coliseumTierByConstant != null) {
			_loc4_ = ASCompat.coerce(mDBFacade.gameMaster.coliseumTierByConstant.itemFor(mCurrentDungeon.TierRank), gameMasterDictionary.GMColiseumTier);
		}
		if (_loc4_ != null && ASCompat.toBool((mPopup : ASAny).dungeonXp_label)) {
			TextUtil.setText(ASCompat.coerce((mPopup : ASAny).dungeonXp_label, flash.text.TextField),
				Std.string(mCurrentDungeon.CompletionXPBonus) + Locale.getString("WORLD_MAP_BONUS_XP"));
		}
		Locale.setText(ASCompat.coerce((mPopup : ASAny).button_battle.battle_text.battle_text, flash.text.TextField), "WORLD_MAP_UNLOCK");
		setTitle(GameMasterLocale.getGameMasterSubString("DUNGEON_NAME", mCurrentDungeon.Constant).toUpperCase());
		if (_loc4_.TotalFloors > 0 && mCurrentDungeon.NodeType != GMMapNode.BOSS_NODE_TYPE) {
			_loc2_ = _loc4_.TotalFloors > 1 ? Locale.getString("FLOORS").toUpperCase() : Locale.getString("FLOOR").toUpperCase();
			if (_loc4_.TotalFloors >= 50) {
				setDifficulty("INFINITE " + _loc2_);
			} else {
				setDifficulty(Std.string(_loc4_.TotalFloors) + " " + _loc2_);
			}
		} else {
			setDifficulty(GameMasterLocale.getGameMasterSubString("DUNGEON_DIFFICULTY_NAME", mCurrentDungeon.Constant));
		}
		var _loc1_ = mDBFacade.playerActivityCount.getActivityString((mCurrentDungeon.Id : Int));
		TextUtil.setText(ASCompat.coerce((mPopup : ASAny).activity_label, flash.text.TextField), _loc1_);
		var _loc3_ = mDBFacade.playerActivityCount.getPopulationGlow(_loc1_);
		if (_loc3_ != null) {
			ASCompat.setProperty((mPopup : ASAny).activity_label, "filters", [_loc3_]);
		}
	}

	@:isVar public var keyCostClip(get, never):MovieClip;

	public function get_keyCostClip():MovieClip {
		if (mPopup != null) {
			return ASCompat.coerce((mPopup : ASAny).basic_key_icon, flash.display.MovieClip);
		}
		return null;
	}

	public function animatePopupIn() {
		var destX:Float;
		var destY:Float;
		if (mPopup == null) {
			return;
		}
		mPopup.visible = true;
		if (!mCurtainActive) {
			makeCurtain();
		}
		destX = BATTLE_POPUP_POSITION.x;
		destY = BATTLE_POPUP_POSITION.y;
		mPopup.x = 730;
		mPopup.y = destY;
		mDBFacade.mTween.killTweensOf(mPopup);
		mDBFacade.mTween.createTimeline({
			"tweens": [
				mDBFacade.mTween.tweenMaxTo(mPopup, 0.25, {
					"x": destX,
					"y": destY
				})
			],
			"align": "sequence"
		});
		isPopupActive = true;
		pushArrowCursor();
		cancelNavigationLayerPush();
		mPopupNavigationLinkDelay = mLogicalWorkComponent.doLater(0, function(param1:brain.clock.GameClock) {
			mPopupNavigationLinkDelay = null;
			if (isPopupActive) {
				pushNavigationLayer();
			}
		});
		DBGlobal.highlightButton(mBattleButton);
	}

	public function animatePopupOut(keepCurtain:Bool = false) {
		var destX:Float;
		var destY:Float;
		var startX:Float;
		var hidePopup:ASFunction;
		cancelNavigationLayerPush();
		if (mPopup == null) {
			return;
		}
		isPopupActive = false;
		popArrowCursor();
		if (mCurtainActive && !keepCurtain) {
			removeCurtain();
		}
		destX = 1440;
		destY = BATTLE_POPUP_POSITION.y;
		startX = BATTLE_POPUP_POSITION.x;
		mPopup.x = startX;
		mPopup.y = destY;
		hidePopup = function() {
			if (mPopup != null) {
				mPopup.visible = false;
			}
		};
		mDBFacade.mTween.killTweensOf(mPopup);
		mDBFacade.mTween.createTimeline({
			"tweens": [
				mDBFacade.mTween.tweenMaxTo(mPopup, 0.25, {
					"x": destX,
					"y": destY,
					"onComplete": hidePopup
				})
			],
			"align": "sequence"
		});
		removeButtonFilters();
	}

	override function setupMenuNavigation() {
		mPrivateButton.isAbove(mBattleButton);
		mCloseButton.isAbove(mPrivateButton);
		mChangeHeroButton.isToTheLeftOf(mBattleButton);
		setButtonFilters();
	}

	public function setButtonFilters() {
		DBGlobal.highlightButton(mBattleButton);
		mBattleButton.upNavigationAdditionalInteraction = function() {
			DBGlobal.highlightButton(mPrivateButton);
			DBGlobal.unHighlightButton(mBattleButton);
		};
		mPrivateButton.downNavigationAdditionalInteraction = function() {
			DBGlobal.unHighlightButton(mPrivateButton);
			DBGlobal.highlightButton(mBattleButton);
		};
		mPrivateButton.upNavigationAdditionalInteraction = function() {
			DBGlobal.unHighlightButton(mPrivateButton);
		};
		mBattleButton.leftNavigationAdditionalInteraction = function() {
			DBGlobal.unHighlightButton(mBattleButton);
			DBGlobal.highlightButton(mChangeHeroButton);
		};
		mChangeHeroButton.rightNavigationAdditionalInteraction = function() {
			DBGlobal.unHighlightButton(mChangeHeroButton);
			DBGlobal.highlightButton(mBattleButton);
		};
		mCloseButton.downNavigationAdditionalInteraction = function() {
			DBGlobal.highlightButton(mPrivateButton);
		};
	}

	public function removeButtonFilters() {
		mBattleButton.setFocused(false);
		mPrivateButton.setFocused(false);
		mChangeHeroButton.setFocused(false);
		mCloseButton.setFocused(false);
	}
}
