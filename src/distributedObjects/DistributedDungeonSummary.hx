package distributedObjects;

import account.AvatarInfo;
import account.BoosterInfo;
import account.ChestInfo;
import account.CurrencyUpdatedAccountEvent;
import account.DBInventoryInfo;
import account.PlayerSpecialStatus;
import account.StoreServices;
import account.StoreServicesController;
import actor.ChatBalloon;
import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.SwfAsset;
import brain.clock.GameClock;
import brain.event.EventComponent;
import brain.event.EventListeners;
import brain.gameObject.GameObject;
import brain.logger.Logger;
import brain.render.MovieClipRenderController;
import brain.render.MovieClipRenderer;
import brain.sceneGraph.SceneGraphComponent;
import brain.sound.SoundAsset;
import brain.uI.UIButton;
import brain.uI.UIObject;
import brain.uI.UIProgressBar;
import brain.utils.MemoryTracker;
import brain.utils.TextUtil;
import brain.workLoop.LogicalWorkComponent;
import brain.workLoop.Task;
import brain.jsonRPC.JSONRPCService;
import collections.Map;
import dBGlobals.DBGlobal;
import events.ChatEvent;
import events.FriendSummaryNewsFeedEvent;
import events.GameObjectEvent;
import events.LevelUpPostEvent;
import events.PlayerExitEvent;
import facade.DBFacade;
import facade.GameMasterLocale;
import facade.Locale;
import gameMasterDictionary.GMChest;
import gameMasterDictionary.GMDoober;
import gameMasterDictionary.GMHero;
import gameMasterDictionary.GMMapNode;
import gameMasterDictionary.GMRarity;
import gameMasterDictionary.GMSkin;
import gameMasterDictionary.GMWeaponAesthetic;
import gameMasterDictionary.GMWeaponItem;
import generatedCode.DistributedDungeonSummaryNetworkComponent;
import generatedCode.DungeonReport;
import generatedCode.IDistributedDungeonSummary;
import sound.DBSoundComponent;
import town.TownHeader;
import uI.CountdownTextTimer;
import uI.friendManager.UIFriendManager;
import uI.inventory.chests.ChestBuyKeysPopUp;
import uI.inventory.chests.ChestKeySlot;
import uI.inventory.chests.ChestRevealPopUp;
import uI.inventory.UIInventory;
import uI.inventory.UIWeaponTooltip;
import uI.popup.DBUIPopup;
import uI.popup.DBUITwoButtonPopup;
import uI.popup.UIDistributedDungeonNextFloorSection;
import uI.popup.UIReportPopup;
import uI.popup.UITreasureFoundPopup;
import uI.popup.UIVictoryBoosterPopup;
import uI.UIChatLog;
import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.events.Event;
import flash.filters.ColorMatrixFilter;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.geom.Vector3D;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.display.DisplayObject;
import flash.display.MovieClip;

class DistributedDungeonSummary extends GameObject implements IDistributedDungeonSummary {
	static inline final SCORE_REPORT_PATH = "Resources/Art2D/UI/db_UI_score_report.swf";

	static inline final TOWN_PATH = "Resources/Art2D/UI/db_UI_town.swf";

	static inline final DOOBER_SWF_PATH = "Resources/Art2D/Doobers/db_items_doobers.swf";

	static inline final ITEM_CARD_LEVEL_REQUIREMENT = "ITEM_CARD_LEVEL_REQUIREMENT";

	static inline final TAKE_ALL_ID = (1000 : UInt);

	static inline final CHAT_LOG_HEIGHT_SCALE:Float = 1.5;

	static inline final CHAT_BUTTON_HEIGHT_SCALE:Float = 1.25;

	static inline final DUNGEONS_COMPLETED = "DUNGEONS_COMPLETED";

	static inline final REVEAL_STATE_BEGIN = (1 : UInt);

	static inline final REVEAL_TROPHY_AWARD_STATE = (20 : UInt);

	static inline final HIDE_TROPHY_AWARD_STATE = (25 : UInt);

	static inline final REVEAL_STATE_BONUS_XP = (2 : UInt);

	static inline final REVEAL_STATE_BONUS_XP_TICK = (3 : UInt);

	static inline final REVEAL_STATE_TEAM_BONUS_XP = (4 : UInt);

	static inline final REVEAL_STATE_TEAM_BONUS_XP_TICK = (5 : UInt);

	static inline final REVEAL_STATE_BOOSTER_TICK = (6 : UInt);

	static inline final REVEAL_STATE_BOOSTER_BONUS_TICK = (7 : UInt);

	static inline final REVEAL_STATE_KILLS = (8 : UInt);

	static inline final REVEAL_STATE_KILLS_TICK = (9 : UInt);

	static inline final REVEAL_STATE_TREASURE = (10 : UInt);

	static inline final REVEAL_STATE_TREASURE_TICK = (11 : UInt);

	static inline final REVEAL_STATE_DONE = (12 : UInt);

	static inline final REVEAL_STATE_GOLD_BOOSTER_TICK = (13 : UInt);

	static inline final REVEAL_STATE_GOLD_BOOSTER_BONUS_TICK = (14 : UInt);

	static inline final REVEAL_TRANSITION_SPEED:Float = 0.45;

	static inline final BONUS_TRANSITION_SPEED:Float = 0.45;

	static inline final PRE_PLAYTEST = false;

	var mRarityMap:Map;

	var mDBFacade:DBFacade;

	var mDungeonReport:Vector<DungeonReport>;

	var mDungeonName:String;

	var mSortedLootData:Array<ASAny>;

	var mScoreReportRoot:MovieClip;

	var mTownRoot:MovieClip;

	var mNextFloorSection:UIDistributedDungeonNextFloorSection;

	var mUIInventory:UIInventory;

	var mTownHeader:TownHeader;

	var mItemCardX:Float = Math.NaN;

	var mItemCardY:Float = Math.NaN;

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mSceneGraphComponent:SceneGraphComponent;

	var mSoundComponent:DBSoundComponent;

	var mEventComponent:EventComponent;

	var mWorkComponent:LogicalWorkComponent;

	var mBannerFadeTask:Task;

	var mSurveyButton:UIButton;

	var mXpBar:Array<ASAny>;

	var mUIChatLog:UIChatLog;

	var mChatEventComponent:EventComponent;

	var mChatBalloon:Vector<ChatBalloon>;

	var mChatCloseTask:Vector<Task>;

	var mPlayerIsTypingNotification:MovieClip;

	var mItemButtons:Array<ASAny>;

	var mAvatarButtons:Array<ASAny>;

	var mPlayerBoosterUIs:Array<ASAny>;

	var mAddFriendButtons:Array<ASAny>;

	var mBlockFriendButtons:Array<ASAny>;

	var mReportPlayerButtons:Array<ASAny>;

	var mSelectedItemSlot:UInt = 0;

	var mSelectedGMChest:GMChest;

	var mLeaving:Bool = false;

	var mTookLastItem:Bool = false;

	var mItemCount:Int = 0;

	var mBoosterPopup:UIVictoryBoosterPopup;

	var mInfoPopup:DBUIPopup;

	var mNetworkComponent:DistributedDungeonSummaryNetworkComponent;

	var mXPBonusStarEffect:MovieClip;

	var mXPBonusBarEffect:MovieClip;

	var mXPBonusTextFlash:MovieClip;

	var mXPBonusText:TextField;

	var mRevealState:UInt = 0;

	var mBoosterExpTick:UInt = 0;

	var mBoosterGoldTick:UInt = 0;

	var mBonusXPTick:Vector<UInt>;

	var mTeamBonusXPTick:Vector<UInt>;

	var mKillsTick:Vector<UInt>;

	var mTreasureTick:UInt = 0;

	var mTrophyGetMovieClipRenderer:MovieClipRenderer;

	var mDungeonAchievementPanelMovieClipRenderer:MovieClipRenderer;

	var mTransactionSuccessCallback:ASFunction;

	var mSteamAvatarHolder:MovieClip;

	var mSteamAvatarMap:Map;

	var mDungeonSuccess:Bool = false;

	var mDungeonCompleteBonusXP:UInt = (0 : UInt);

	var mInDungeonXPEarned:UInt = (0 : UInt);

	var mDRFriendBlockPopup:DBUITwoButtonPopup;

	var mBgRenderer:MovieClipRenderController;

	var mTreasureFoundPopup:UITreasureFoundPopup;

	var mChestRevealPopUp:ChestRevealPopUp;

	var mChestRenderers:Vector<MovieClipRenderer>;

	var mChestKeySlots:Vector<ChestKeySlot>;

	var mChestBuyKeysPopUp:ChestBuyKeysPopUp;

	var mChestMovieClips:Array<ASAny>;

	var mStorageFullPopUp:DBUITwoButtonPopup;

	var mFromInventory:Bool = false;

	var mRevealedItemType:UInt = 0;

	var mRevealedItemOfferId:UInt = 0;

	var mRevealedItemCallEquip:Bool = false;

	public var isSingleChestList:Vector<Bool>;

	var mLogicalWorkComponent:LogicalWorkComponent;

	var mChestTransactionFailedPopup:DBUIPopup;

	var mAbandonChestPopUp:DBUITwoButtonPopup;

	var mCurrentMapNode:GMMapNode;

	var mUILootSlotsTwoTreasures:Array<ASAny>;

	var mUILootSlotsFourTreasures:Array<ASAny>;

	var mUILootSlots:Array<ASAny>;

	var mMapNodeId:UInt = 0;

	var mWeapons:Array<ASAny>;

	var mWeaponTooltips:Array<ASAny>;

	var mSmashSfx:SoundAsset;

	var mLevelSfx:SoundAsset;

	var mBoosterXP:BoosterInfo;

	var mBoosterGold:BoosterInfo;

	var mCoinBoosterUI:UIObject;

	var mXPBoosterUI:UIObject;

	var mCountDownTextXP:CountdownTextTimer;

	var mCountDownTextGold:CountdownTextTimer;

	var mBoosterInfos:Array<ASAny>;

	var mTeamBonusUI:Map;

	var mDungeonMod1:UInt = 0;

	var mDungeonMod2:UInt = 0;

	var mDungeonMod3:UInt = 0;

	var mDungeonMod4:UInt = 0;

	var mDRReportPlayerPopup:UIReportPopup;

	public function new(dbFacade:DBFacade, doid:UInt) {
		var k:Int;
		var i:Int;
		var j:Int;
		mXpBar = [];
		Logger.info("Start construction of DDS");
		super(dbFacade, doid);
		try {
			mDBFacade = dbFacade;
			mRarityMap = new Map();
			mRarityMap.add("COMMON", 1);
			mRarityMap.add("UNCOMMON", 4);
			mRarityMap.add("RARE", 5);
			mRarityMap.add("LEGENDARY", 6);
			mRarityMap.add("CONSUMABLE_SMALL", 2);
			mRarityMap.add("CONSUMABLE_ROYAL", 3);
			mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade, "DistributedDungeonSummary");
			mRevealedItemType = (0 : UInt);
			mRevealedItemOfferId = (0 : UInt);
			mAddFriendButtons = [];
			mBlockFriendButtons = [];
			mReportPlayerButtons = [];
			mBoosterInfos = [];
			mAvatarButtons = ASCompat.allocArray(4);
			mPlayerBoosterUIs = [[], [], [], []];
			mDBFacade.dbAccountInfo.incrementCompletedDungeons();
			mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
			mSceneGraphComponent = new SceneGraphComponent(mDBFacade, "DistributedDungeonSummary");
			mSoundComponent = new DBSoundComponent(mDBFacade);
			mWorkComponent = new LogicalWorkComponent(mDBFacade, "DistributedDungeonSummary");
			mEventComponent = new EventComponent(mDBFacade);
			mChatBalloon = new Vector<ChatBalloon>((4 : UInt));
			mChatCloseTask = new Vector<Task>((4 : UInt));
			mChatEventComponent = new EventComponent(dbFacade);
			mSteamAvatarMap = new Map();
			isSingleChestList = new Vector<Bool>();
			isSingleChestList = new Vector<Bool>();
			k = 0;
			while (k < 4) {
				isSingleChestList.push(false);
				k = k + 1;
			}
			mChestRenderers = new Vector<MovieClipRenderer>();
			mChestMovieClips = [];
			i = 0;
			while (i < 4) {
				mChestMovieClips.push([]);
				j = 0;
				while (j < 4) {
					ASCompat.dynPush(mChestMovieClips[i], new MovieClip());
					j = j + 1;
				}
				i = i + 1;
			}
			mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_nametag.swf"), nametagSwfLoaded);
			mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath(DBGlobal.SFX_PATH), "HealthBomb1", function(param1:SoundAsset) {
				mSmashSfx = param1;
			});
			mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath(DBGlobal.SFX_PATH), "LevelUp2", function(param1:SoundAsset) {
				mLevelSfx = param1;
			});
			mTeamBonusUI = new Map();
		} catch (e:Dynamic) {
			Logger.error("An error occurred while attempting to construct distributed dungeon summary.  Error: " + Std.string(e.message));
		}
		Logger.info("Finished construction of DDS");
	}

	function nametagSwfLoaded(swfAsset:SwfAsset) {
		var _loc2_ = swfAsset.getClass("fb_avatar_holder");
		mSteamAvatarHolder = ASCompat.coerce(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
		mSceneGraphComponent.addChild(mSteamAvatarHolder, (105 : UInt));
		mSteamAvatarHolder.visible = false;
	}

	public function setNetworkComponentDistributedDungeonSummary(iface:DistributedDungeonSummaryNetworkComponent) {
		mNetworkComponent = iface;
	}

	public function postGenerate() {
		mDBFacade.uiHideToggle.reveal();
		mCurrentMapNode = ASCompat.coerce(mDBFacade.gameMaster.mapNodeById.itemFor(mMapNodeId), gameMasterDictionary.GMMapNode);
		if (mCurrentMapNode == null) {
			Logger.error("Couldn\'t find GMMapNode for node id : " + mMapNodeId);
			return;
		}
		mDungeonName = GameMasterLocale.getGameMasterSubString("DUNGEON_NAME", mCurrentMapNode.Constant).toUpperCase();
		if (this.dungeonSuccess != 0) {
			mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_score_report.swf"), successScoreReportSwfLoaded);
		} else {
			mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_score_report.swf"), failureScoreReportSwfLoaded);
		}
		if (this.dungeonSuccess != 0 && mMapNodeId == DBGlobal.TUTORIAL_MAP_NODE_ID) {
			mDBFacade.dbAccountInfo.dbAccountParams.setMovementTutorialParam();
		}
		mDBFacade.dbAccountInfo.dbAccountParams.flushParams();
	}

	function setRevealState(reveal_state:UInt, delay:Float) {
		mRevealState = reveal_state;
		mWorkComponent.doLater(delay, updateRevealState);
	}

	function setUILootSlotsTwoTreasuresVisible(isVisible:Bool) {
		var _loc3_ = 0;
		var _loc2_:Array<ASAny>;
		final __ax4_iter_308 = mUILootSlotsTwoTreasures;
		if (checkNullIteratee(__ax4_iter_308))
			for (_tmp_ in __ax4_iter_308) {
				_loc2_ = ASCompat.coerce(_tmp_, Array);
				_loc3_ = 0;
				while (_loc3_ < _loc2_.length) {
					ASCompat.setProperty(_loc2_[_loc3_], "visible", isVisible);
					_loc3_++;
				}
			}
	}

	function setUILootSlotsFourTreasuresVisible(isVisible:Bool) {
		var _loc3_ = 0;
		var _loc2_:Array<ASAny>;
		final __ax4_iter_309 = mUILootSlotsFourTreasures;
		if (checkNullIteratee(__ax4_iter_309))
			for (_tmp_ in __ax4_iter_309) {
				_loc2_ = ASCompat.coerce(_tmp_, Array);
				_loc3_ = 0;
				while (_loc3_ < _loc2_.length) {
					ASCompat.setProperty(_loc2_[_loc3_], "visible", isVisible);
					_loc3_++;
				}
			}
	}

	function noCoinsCollectedByParty():Bool {
		if (!mDungeonSuccess || mCurrentMapNode.InfiniteDungeon != null) {
			return false;
		}
		var _loc1_:DungeonReport;
		final __ax4_iter_310 = mDungeonReport;
		if (checkNullIteratee(__ax4_iter_310))
			for (_tmp_ in __ax4_iter_310) {
				_loc1_ = _tmp_;
				if (_loc1_.valid != 0 && _loc1_.gold_earned != 0) {
					return false;
				}
			}
		return true;
	}

	function updateRevealState(clock:GameClock) {
		var __tmpIncObj1:Vector<UInt>;
		var __tmpIncIdx2:Int;
		var __tmpIncObj3:Vector<UInt>;
		var __tmpIncIdx4:Int;
		var i:UInt = 0;
		var allFinished:Bool;
		var loot:Array<ASAny>;
		var popupType:String;
		var trophies:Int;
		var trophyGetClipLength:UInt;
		var maxBonus:UInt;
		var xp_bars:Array<ASAny>;
		var speed:Float;
		var gmHero:GMHero;
		var oldLevel:UInt;
		var currentExp:UInt;
		var level:UInt;
		var levelIndex:UInt;
		var lastLevelExp:UInt;
		var max:UInt;
		var animMcr:MovieClipRenderController;
		var textMcr:MovieClipRenderController;
		var teamBonusUI:UIObject;
		var maxBonusTeam:UInt;
		var xp_barsTeam:Array<ASAny>;
		var speedTeam:Float;
		var gmHeroTeam:GMHero;
		var oldLevelTeam:UInt;
		var currentExpTeam:UInt;
		var levelTeam:UInt;
		var levelIndexTeam:UInt;
		var lastLevelExpTeam:UInt;
		var maxTeam:UInt;
		var teamBonusUITeam:UIObject;
		var animMcrTeam:MovieClipRenderController;
		var textMcrTeam:MovieClipRenderController;
		var maxKills:UInt;
		var slot:UInt;
		var localLoot:Array<ASAny> = null;
		var weapon_clip:MovieClip;
		var global_position:Point;
		var position:Vector3D;
		var totalXP:UInt;
		var local_i:UInt;
		var tickingFilter:Array<ASAny>;
		var headerTitle:String;
		var go:GameObject;
		var player:PlayerGameObject;
		var treasureClips:Array<ASAny>;
		var j:Int;
		var stats:Array<ASAny> = [
			(mScoreReportRoot : ASAny)
			.stats_a,
			(mScoreReportRoot : ASAny)
			.stats_b,
			(mScoreReportRoot : ASAny)
			.stats_c,
			(mScoreReportRoot : ASAny)
			.stats_d
		];
		do {
			switch (mRevealState) {
				case 1:
					i = (0 : UInt);
					while (i < (stats.length:UInt)) {
						if (mDungeonReport[(i : Int)].valid != 0) {
							ASCompat.setProperty(stats[(i : Int)].stats.xp_bar.bonus_xp_reveal, "visible", false);
							ASCompat.setProperty(stats[(i : Int)].stats.xp_bar.bonus_xp, "visible", false);
							ASCompat.setProperty(stats[(i : Int)].stats.kills.enemies_killed, "visible", false);
							ASCompat.setProperty(stats[(i : Int)].stats.kills.enemies_killed_reveal, "visible", false);
							ASCompat.setProperty(stats[(i : Int)].stats.treasure, "visible", false);
							if (mDungeonReport[(i : Int)].id == mDBFacade.accountId) {
								if (noCoinsCollectedByParty()) {
									mDBFacade.steamAchievementsHelper.unlockAchievement("CHALLENGE_COLLECT_NO_COINS_IN_DUNGEON");
								}
								mDBFacade.steamAchievementsHelper.addValueToStatInt(mDungeonReport[(i : Int)].kills, "ENEMIES_KILLED");
								mDBFacade.steamAchievementsHelper.addValueToStatInt(mDungeonReport[(i : Int)].receivedTrophy, "TROPHIES_EARNED");
							}
						}
						i = i + 1;
					}
					if (mDBFacade.accountBonus.isXPBonusActive) {
						mXPBonusStarEffect.visible = true;
						mXPBonusBarEffect.visible = true;
						mXPBonusTextFlash.visible = true;
						TextUtil.setText(mXPBonusText, mDBFacade.accountBonus.xpBonusText);
					}
					if (mCurrentMapNode.InfiniteDungeon != null) {
						popupType = "ULTIMATE_RAMPAGE";
					} else if (this.dungeonSuccess != 0) {
						popupType = "VICTORY";
					} else {
						popupType = "DEFEAT";
					}
					mNextFloorSection = new UIDistributedDungeonNextFloorSection(mDBFacade,
						ASCompat.coerce((mScoreReportRoot : ASAny).dungeon_popup, flash.display.MovieClip), mCurrentMapNode, popupType, returnToSplashScreen);
					setRevealState((20 : UInt), 0.45);

				case 20:
					if (mDungeonReport[0].receivedTrophy == 0) {
						setRevealState((2 : UInt), 0.45);
					} else {
						mDungeonAchievementPanelMovieClipRenderer.clip.visible = true;
						ASCompat.setProperty((mScoreReportRoot : ASAny).stats_a.stats.trophies, "filters", [new GlowFilter((16633879 : UInt), 1, 8, 8, 10)]);
						trophies = ASCompat.toInt((mScoreReportRoot : ASAny).stats_a.stats.trophies.trophies.text);
						trophies = trophies + 1;
						TextUtil.setText(ASCompat.coerce((mScoreReportRoot : ASAny).stats_a.stats.trophies.trophies, flash.text.TextField),
							Std.string(trophies));
						trophyGetClipLength = (4 : UInt);
						mDungeonAchievementPanelMovieClipRenderer.play();
						if (mSmashSfx != null) {
							mSoundComponent.playSfxOneShot(mSmashSfx);
						}
						mLogicalWorkComponent.doLater(1.5833333333333333, function(param1:GameClock) {
							if (mSmashSfx != null) {
								mSoundComponent.playSfxOneShot(mSmashSfx);
							}
						});
						setRevealState((25 : UInt), trophyGetClipLength);
					}

				case 25:
					if (mDungeonAchievementPanelMovieClipRenderer != null && mDungeonAchievementPanelMovieClipRenderer.clip != null) {
						mDungeonAchievementPanelMovieClipRenderer.stop();
						mDungeonAchievementPanelMovieClipRenderer.clip.visible = false;
					}
					setRevealState((2 : UInt), 0.45);

				case 2:
					if (mTrophyGetMovieClipRenderer != null) {
						mTrophyGetMovieClipRenderer.clip.visible = false;
					}
					i = (0 : UInt);
					while (i < (stats.length:UInt)) {
						if (mDungeonReport[(i : Int)].valid != 0) {
							ASCompat.setProperty(stats[(i : Int)].stats.xp_bar.bonus_xp_reveal, "visible", false);
							ASCompat.setProperty(stats[(i : Int)].stats.xp_bar.bonus_xp, "visible", false);
						}
						i = i + 1;
					}
					setRevealState((3 : UInt), 0.45);

				case 3:
					allFinished = true;
					maxBonus = (0 : UInt);
					xp_bars = [
						(mScoreReportRoot : ASAny)
						.stats_a.stats.xp_bar.UI_XP,
						(mScoreReportRoot : ASAny)
						.stats_b.stats.xp_bar.UI_XP,
						(mScoreReportRoot : ASAny)
						.stats_c.stats.xp_bar.UI_XP,
						(mScoreReportRoot : ASAny)
						.stats_d.stats.xp_bar.UI_XP
					];
					i = (0 : UInt);
					while (i < (stats.length:UInt)) {
						if (mDungeonReport[(i : Int)].valid != 0) {
							ASCompat.setProperty(stats[(i : Int)].stats.xp_bar.bonus_xp_reveal, "visible", false);
							ASCompat.setProperty(stats[(i : Int)].stats.xp_bar.bonus_xp, "visible", true);
							maxBonus = (ASCompat.floatToInt(Math.max(maxBonus, mDungeonReport[(i : Int)].xp_bonus)) : UInt);
							speed = ((maxBonus : Float) - (mBonusXPTick[(i : Int)] : Float)) / 10;
							if (speed < 1 && maxBonus > mBonusXPTick[(i : Int)]) {
								speed = 1;
							}
							if (mBonusXPTick[(i : Int)] < mDungeonReport[(i : Int)].xp_bonus) {
								gmHero = ASCompat.coerce(mDBFacade.gameMaster.heroById.itemFor(mDungeonReport[(i : Int)].type), gameMasterDictionary.GMHero);
								oldLevel = gmHero.getLevelFromExp(mDungeonReport[(i : Int)].xp + mBonusXPTick[(i : Int)],
									mDungeonReport[(i : Int)].ascension_level);
								allFinished = false;
								mBonusXPTick[(i : Int)] += (ASCompat.floatToInt(speed) : UInt);
								currentExp = mDungeonReport[(i : Int)].xp + mBonusXPTick[(i : Int)];
								level = gmHero.getLevelFromExp(currentExp, mDungeonReport[(i : Int)].ascension_level);
								levelIndex = (gmHero.getLevelIndex(currentExp, (mDungeonReport[(i : Int)].ascension_level : Int)) : UInt);
								lastLevelExp = (ASCompat.toInt(levelIndex > 0 ? gmHero.getExpFromIndex(levelIndex - 1) : 0) : UInt);
								max = gmHero.getExpFromIndex(levelIndex);
								ASCompat.setProperty(mXpBar[(i : Int)], "value",
									((currentExp : Float) - (lastLevelExp : Float)) / ((max : Float) - (lastLevelExp : Float)));
								TextUtil.setText(ASCompat.coerce(xp_bars[(i : Int)].xp_level, flash.text.TextField), Std.string(level));
								TextUtil.setText(ASCompat.coerce(stats[(i : Int)].stats.xp_bar.bonus_xp.xp, flash.text.TextField),
									Std.string(mBonusXPTick[(i : Int)]));
								TextUtil.setText(ASCompat.coerce(stats[(i : Int)].stats.xp_bar.UI_XP.xp_points, flash.text.TextField), Std.string(currentExp));
								TextUtil.setText(ASCompat.coerce(stats[(i : Int)].stats.xp_bar.UI_XP.xp_level, flash.text.TextField), Std.string(level));
								if (oldLevel != level) {
									ASCompat.setProperty(stats[(i : Int)].stats.fx_level_up_text, "visible", true);
									ASCompat.setProperty(stats[(i : Int)].stats.fx_level_up_anim, "visible", true);
									animMcr = new MovieClipRenderController(mDBFacade,
										ASCompat.coerce(stats[(i : Int)].stats.fx_level_up_anim, flash.display.MovieClip));
									animMcr.play((0 : UInt), false, function() {
										animMcr.destroy();
									});
									textMcr = new MovieClipRenderController(mDBFacade,
										ASCompat.coerce(stats[(i : Int)].stats.fx_level_up_text, flash.display.MovieClip));
									textMcr.play((0 : UInt), false, function() {
										textMcr.destroy();
									});
									if (mLevelSfx != null) {
										mSoundComponent.playSfxOneShot(mLevelSfx);
									}
									if (i == 0) {
										mEventComponent.dispatchEvent(new LevelUpPostEvent("LevelUpPostEvent", level));
									}
								}
							}
						}
						i = i + 1;
					}
					if (allFinished) {
						mDungeonCompleteBonusXP = mDungeonReport[0].xp_bonus;
						mInDungeonXPEarned = mDungeonReport[0].xp_earned;
						setRevealState((4 : UInt), 0.45);
					} else {
						setRevealState((3 : UInt), 0.45 / maxBonus);
					}

				case 4:
					i = (0 : UInt);
					while (i < (stats.length:UInt)) {
						if (mDungeonReport[(i : Int)].valid != 0) {
							teamBonusUI = ASCompat.coerce(mTeamBonusUI.itemFor(i), brain.uI.UIObject);
							teamBonusUI.visible = true;
						}
						i = i + 1;
					}
					setRevealState((5 : UInt), 0.45);

				case 5:
					allFinished = true;
					maxBonusTeam = (0 : UInt);
					xp_barsTeam = [
						(mScoreReportRoot : ASAny)
						.stats_a.stats.xp_bar.UI_XP,
						(mScoreReportRoot : ASAny)
						.stats_b.stats.xp_bar.UI_XP,
						(mScoreReportRoot : ASAny)
						.stats_c.stats.xp_bar.UI_XP,
						(mScoreReportRoot : ASAny)
						.stats_d.stats.xp_bar.UI_XP
					];
					i = (0 : UInt);
					while (i < (stats.length:UInt)) {
						if (mDungeonReport[(i : Int)].valid != 0) {
							maxBonusTeam = (ASCompat.floatToInt(Math.max(maxBonusTeam, mDungeonReport[(i : Int)].team_xp_bonus)) : UInt);
							speedTeam = ((maxBonusTeam : Float) - (mTeamBonusXPTick[(i : Int)] : Float)) / 10;
							if (speedTeam < 1 && maxBonusTeam > mTeamBonusXPTick[(i : Int)]) {
								speedTeam = 1;
							}
							if (mTeamBonusXPTick[(i : Int)] < mDungeonReport[(i : Int)].team_xp_bonus) {
								gmHeroTeam = ASCompat.coerce(mDBFacade.gameMaster.heroById.itemFor(mDungeonReport[(i : Int)].type),
									gameMasterDictionary.GMHero);
								oldLevelTeam = gmHeroTeam.getLevelFromExp(mDungeonReport[(i : Int)].xp + mBonusXPTick[(i : Int)],
									mDungeonReport[(i : Int)].ascension_level);
								allFinished = false;
								mTeamBonusXPTick[(i : Int)] += (ASCompat.floatToInt(speedTeam) : UInt);
								currentExpTeam = mDungeonReport[(i : Int)].xp + mBonusXPTick[(i : Int)] + mTeamBonusXPTick[(i : Int)];
								levelTeam = gmHeroTeam.getLevelFromExp(currentExpTeam, mDungeonReport[(i : Int)].ascension_level);
								levelIndexTeam = (gmHeroTeam.getLevelIndex(currentExpTeam, (mDungeonReport[(i : Int)].ascension_level : Int)) : UInt);
								lastLevelExpTeam = (ASCompat.toInt(levelIndexTeam > 0 ? gmHeroTeam.getExpFromIndex(levelIndexTeam - 1) : 0) : UInt);
								maxTeam = gmHeroTeam.getExpFromIndex(levelIndexTeam);
								ASCompat.setProperty(mXpBar[(i : Int)], "value",
									((currentExpTeam : Float) - (lastLevelExpTeam : Float)) / ((maxTeam : Float) - (lastLevelExpTeam : Float)));
								TextUtil.setText(ASCompat.coerce(xp_barsTeam[(i : Int)].xp_level, flash.text.TextField), Std.string(levelTeam));
								teamBonusUITeam = ASCompat.coerce(mTeamBonusUI.itemFor(i), brain.uI.UIObject);
								TextUtil.setText(ASCompat.coerce((teamBonusUITeam.root : ASAny).xp, flash.text.TextField),
									Std.string(mTeamBonusXPTick[(i : Int)]));
								TextUtil.setText(ASCompat.coerce(stats[(i : Int)].stats.xp_bar.UI_XP.xp_points, flash.text.TextField),
									Std.string(currentExpTeam));
								TextUtil.setText(ASCompat.coerce(stats[(i : Int)].stats.xp_bar.UI_XP.xp_level, flash.text.TextField), Std.string(levelTeam));
								if (oldLevelTeam != levelTeam) {
									ASCompat.setProperty(stats[(i : Int)].stats.fx_level_up_text, "visible", true);
									ASCompat.setProperty(stats[(i : Int)].stats.fx_level_up_anim, "visible", true);
									animMcrTeam = new MovieClipRenderController(mDBFacade,
										ASCompat.coerce(stats[(i : Int)].stats.fx_level_up_anim, flash.display.MovieClip));
									animMcrTeam.play((0 : UInt), false, function() {
										animMcrTeam.destroy();
									});
									textMcrTeam = new MovieClipRenderController(mDBFacade,
										ASCompat.coerce(stats[(i : Int)].stats.fx_level_up_text, flash.display.MovieClip));
									textMcrTeam.play((0 : UInt), false, function() {
										textMcrTeam.destroy();
									});
									if (mLevelSfx != null) {
										mSoundComponent.playSfxOneShot(mLevelSfx);
									}
									if (i == 0) {
										mEventComponent.dispatchEvent(new LevelUpPostEvent("LevelUpPostEvent", levelTeam));
									}
								}
							}
						}
						i = i + 1;
					}
					if (allFinished) {
						mDungeonCompleteBonusXP = mDungeonReport[0].xp_bonus + mDungeonReport[0].team_xp_bonus;
						setRevealState((8 : UInt), 0.45);
					} else {
						setRevealState((5 : UInt), 0.45 / maxBonusTeam);
					}

				case 8:
					i = (0 : UInt);
					while (i < (stats.length:UInt)) {
						if (mDungeonReport[(i : Int)].valid != 0) {
							ASCompat.setProperty(stats[(i : Int)].stats.kills.enemies_killed_reveal, "visible", false);
						}
						i = i + 1;
					}
					setRevealState((9 : UInt), 0);

				case 9:
					allFinished = true;
					maxKills = (0 : UInt);
					i = (0 : UInt);
					while (i < (stats.length:UInt)) {
						if (mDungeonReport[(i : Int)].valid != 0) {
							maxKills = (ASCompat.floatToInt(Math.max(maxKills, mDungeonReport[(i : Int)].kills)) : UInt);
							ASCompat.setProperty(stats[(i : Int)].stats.kills.enemies_killed_reveal, "visible", false);
							ASCompat.setProperty(stats[(i : Int)].stats.kills.enemies_killed, "visible", true);
							if (mKillsTick[(i : Int)] < mDungeonReport[(i : Int)].kills) {
								allFinished = false;
								__tmpIncObj1 = mKillsTick;
								__tmpIncIdx2 = (i : Int);
								__tmpIncObj1[__tmpIncIdx2] = (__tmpIncObj1[__tmpIncIdx2] + 1 : UInt);
								TextUtil.setText(ASCompat.coerce(stats[(i : Int)].stats.kills.enemies_killed.kills, flash.text.TextField),
									Std.string(mKillsTick[(i : Int)]));
							}
						}
						i = i + 1;
					}
					if (allFinished) {
						setRevealState((10 : UInt), 0.45);
					} else {
						setRevealState((9 : UInt), 0.45 / maxKills);
					}

				case 10:
					i = (0 : UInt);
					while (i < (stats.length:UInt)) {
						if (mDungeonReport[(i : Int)].valid != 0) {
							ASCompat.setProperty(stats[(i : Int)].stats.treasure, "visible", true);
						}
						i = i + 1;
					}
					setRevealState((11 : UInt), 0.45);

				case 11:
					slot = mTreasureTick++;
					i = (0 : UInt);
					while (i < (stats.length:UInt)) {
						if (mDungeonReport[(i : Int)].valid != 0) {
							if (mItemCount > 2) {
								loot = ASCompat.coerce(mUILootSlotsFourTreasures[(i : Int)], Array);
								setUILootSlotsTwoTreasuresVisible(false);
							} else {
								loot = ASCompat.coerce(mUILootSlotsTwoTreasures[(i : Int)], Array);
								setUILootSlotsFourTreasuresVisible(false);
							}
							if (i == 0) {
								localLoot = loot;
							}
							if (ASCompat.toNumberField(loot[(slot : Int)], "numChildren") > 2) {
								weapon_clip = ASCompat.coerce(loot[(slot : Int)].getChildAt(2), flash.display.MovieClip);
								if (weapon_clip != null) {
									weapon_clip.visible = true;
									global_position = mFacade.designLocalToGlobal(weapon_clip, new Point(0, 0));
									position = new Vector3D(global_position.x, global_position.y + 16);
								}
							}
						}
						i = i + 1;
					}
					if (mTreasureTick >= 2 || ASCompat.toNumberField(localLoot[(slot + 1 : Int)], "numChildren") < 2) {
						openBoosterPopup();
						if ((mBoosterPopup.expStack != null || mBoosterPopup.goldStack != null) && this.dungeonSuccess != 0) {
							setRevealState((6 : UInt), 0.45);
						} else {
							closeBoosterPopup();
							setRevealState((12 : UInt), 0.1);
						}
					} else {
						setRevealState((11 : UInt), 0.45);
					}

				case 6:
					if (mBoosterPopup == null) {
						setRevealState((12 : UInt), 0.1);
						break;
					}
					if (mBoosterPopup.expStack != null) {
						maxBonus = (ASCompat.floatToInt(Math.max(mDungeonReport[0].xp_bonus + mDungeonReport[0].team_xp_bonus,
							mDungeonReport[0].xp_earned)) : UInt);
						totalXP = mDungeonReport[0].xp_bonus + mDungeonReport[0].team_xp_bonus + mDungeonReport[0].xp_earned;
						mBoosterExpTick = (ASCompat.floatToInt(totalXP * mBoosterPopup.expStack.ExpMult - totalXP) : UInt);
						if (mBoosterPopup != null) {
							mBoosterPopup.setExp((mBoosterExpTick : Int));
						}
						mDungeonReport[0].xp_bonus += mBoosterExpTick;
					}
					if (mBoosterPopup.goldStack != null) {
						mBoosterPopup.setGold(ASCompat.floatToInt(mDungeonReport[0].gold_earned * mBoosterPopup.goldStack.GoldMult
							- mDungeonReport[0].gold_earned));
					}
					setRevealState((7 : UInt), 0.45);

				case 7:
					if (mBoosterPopup == null) {
						setRevealState((12 : UInt), 0.1);
						break;
					}
					allFinished = true;
					maxBonus = (0 : UInt);
					xp_bars = [
						(mScoreReportRoot : ASAny)
						.stats_a.stats.xp_bar.UI_XP,
						(mScoreReportRoot : ASAny)
						.stats_b.stats.xp_bar.UI_XP,
						(mScoreReportRoot : ASAny)
						.stats_c.stats.xp_bar.UI_XP,
						(mScoreReportRoot : ASAny)
						.stats_d.stats.xp_bar.UI_XP
					];
					local_i = (0 : UInt);
					ASCompat.setProperty(stats[(local_i : Int)].stats.xp_bar.bonus_xp_reveal, "visible", false);
					ASCompat.setProperty(stats[(local_i : Int)].stats.xp_bar.bonus_xp, "visible", true);
					maxBonus = (ASCompat.floatToInt(Math.max(maxBonus,
						mDungeonReport[(local_i : Int)].xp_bonus + mDungeonReport[(local_i : Int)].team_xp_bonus)) : UInt);
					if (mBonusXPTick[(local_i : Int)] < mDungeonReport[(local_i : Int)].xp_bonus + mDungeonReport[(local_i : Int)].team_xp_bonus) {
						gmHero = ASCompat.coerce(mDBFacade.gameMaster.heroById.itemFor(mDungeonReport[(local_i : Int)].type), gameMasterDictionary.GMHero);
						oldLevel = gmHero.getLevelFromExp(mDungeonReport[(local_i : Int)].xp + mBonusXPTick[(local_i : Int)],
							mDungeonReport[(local_i : Int)].ascension_level);
						allFinished = false;
						__tmpIncObj3 = mBonusXPTick;
						__tmpIncIdx4 = (local_i : Int);
						__tmpIncObj3[__tmpIncIdx4] = (__tmpIncObj3[__tmpIncIdx4] + 1 : UInt);
						currentExp = mDungeonReport[(local_i : Int)].xp + mBonusXPTick[(local_i : Int)];
						level = gmHero.getLevelFromExp(currentExp, mDungeonReport[(local_i : Int)].ascension_level);
						levelIndex = (gmHero.getLevelIndex(currentExp, (mDungeonReport[(local_i : Int)].ascension_level : Int)) : UInt);
						lastLevelExp = (ASCompat.toInt(levelIndex > 0 ? gmHero.getExpFromIndex(levelIndex - 1) : 0) : UInt);
						max = gmHero.getExpFromIndex(levelIndex);
						ASCompat.setProperty(mXpBar[(local_i : Int)], "value",
							((currentExp : Float) - (lastLevelExp : Float)) / ((max : Float) - (lastLevelExp : Float)));
						TextUtil.setText(ASCompat.coerce(xp_bars[(local_i : Int)].xp_level, flash.text.TextField), Std.string(level));
						TextUtil.setText(ASCompat.coerce(stats[(local_i : Int)].stats.xp_bar.bonus_xp.xp, flash.text.TextField),
							Std.string(mBonusXPTick[(local_i : Int)]));
						TextUtil.setText(ASCompat.coerce(stats[(local_i : Int)].stats.xp_bar.UI_XP.xp_points, flash.text.TextField), Std.string(currentExp));
						TextUtil.setText(ASCompat.coerce(stats[(local_i : Int)].stats.xp_bar.UI_XP.xp_level, flash.text.TextField), Std.string(level));
						if (oldLevel != level) {
							ASCompat.setProperty(stats[(local_i : Int)].stats.fx_level_up_text, "visible", true);
							ASCompat.setProperty(stats[(local_i : Int)].stats.fx_level_up_anim, "visible", true);
							animMcr = new MovieClipRenderController(mDBFacade,
								ASCompat.coerce(stats[(local_i : Int)].stats.fx_level_up_anim, flash.display.MovieClip));
							animMcr.play((0 : UInt), false, function() {
								animMcr.destroy();
							});
							textMcr = new MovieClipRenderController(mDBFacade,
								ASCompat.coerce(stats[(local_i : Int)].stats.fx_level_up_text, flash.display.MovieClip));
							textMcr.play((0 : UInt), false, function() {
								textMcr.destroy();
							});
							if (i == 0) {
								mEventComponent.dispatchEvent(new LevelUpPostEvent("LevelUpPostEvent", level));
							}
						}
					}
					if (allFinished) {
						setRevealState((12 : UInt), 0.1);
						applyGlowFilter(ASCompat.coerce(stats[0].stats.xp_bar.bonus_xp, flash.display.MovieClip));
					} else {
						tickingFilter = [];
						tickingFilter.push(new GlowFilter((16777215 : UInt), 1, 12, 12, 6));
						ASCompat.setProperty(stats[0].stats.xp_bar.bonus_xp, "filters", tickingFilter);
						ASCompat.setProperty(stats[0].stats.xp_bar.bonus_xp, "scaleX", 1.1);
						ASCompat.setProperty(stats[0].stats.xp_bar.bonus_xp, "scaleY", 1.1);
						setRevealState((7 : UInt), 0.45 / maxBonus);
					}

				case 12:
					fadeAwayTitle();
					if (mTownHeader != null) {
						mTownHeader.destroy();
					}
					mTownHeader = new TownHeader(mDBFacade, closeHeader);
					mTownHeader.animateHeader();
					if (mCurrentMapNode.InfiniteDungeon != null) {
						headerTitle = Locale.getString("INFINITE_SUMMARY_HEADER_TITLE");
					} else {
						headerTitle = this.dungeonSuccess != 0 ? Locale.getString("VICTORY") : Locale.getString("DUNGEON_FAILED");
					}
					mTownHeader.title = headerTitle;
					mTownHeader.showCloseButton(true);
					mUIChatLog.enabledChatEnterEvent = false;
					mNextFloorSection.setButtonEnabled();
					mDBFacade.menuNavigationController.pushNewLayer("DISTRIBUTED_DUNGEON_SUMMARY", closeHeader, mTownHeader.closeButton,
						mNextFloorSection.battleButton, focusPreviousPlayerAvatar, focusNextPlayerAvatar);
					mTownHeader.setupButtonLinks();
					setupMenuNavigation();
					mEventComponent.dispatchEvent(new Event("TIME_TO_SHARE_LEVEL_UP_EVENT"));
					go = mFacade.gameObjectManager.getReferenceFromId(mDungeonReport[0].id);
					player = ASCompat.reinterpretAs(go, PlayerGameObject);
					mEventComponent.dispatchEvent(new CurrencyUpdatedAccountEvent(player.basicCurrency, mDBFacade.dbAccountInfo.premiumCurrency));
					if (mItemCount > 0 && mDungeonSuccess) {
						loot = mUILootSlots;
						treasureClips = [
							(mScoreReportRoot : ASAny)
							.stats_a.stats.treasure,
							(mScoreReportRoot : ASAny)
							.stats_b.stats.treasure,
							(mScoreReportRoot : ASAny)
							.stats_c.stats.treasure,
							(mScoreReportRoot : ASAny)
							.stats_d.stats.treasure
						];
						i = (0 : UInt);
						while (i < 4) {
							if (isSingleChestList[(i : Int)]) {
								if (ASCompat.dynGetIndex(mChestMovieClips[(i : Int)], 2) != null
									&& ASCompat.dynGetIndex(loot[(i : Int)], 2) != null) {
									treasureClips[(i : Int)].addChild(ASCompat.dynGetIndex(mChestMovieClips[(i : Int)], 2));
									if (mDungeonReport[(i : Int)].chest_type_1 != 0) {
										ASCompat.setProperty(ASCompat.dynGetIndex(loot[(i : Int)], 2), "visible", false);
									}
								}
							} else {
								j = 0;
								while (j < 4) {
									if (ASCompat.dynGetIndex(mChestMovieClips[(i : Int)], j) != null
										&& ASCompat.dynGetIndex(loot[(i : Int)], j) != null) {
										treasureClips[(i : Int)].addChild(ASCompat.dynGetIndex(mChestMovieClips[(i : Int)], j));
										if (j == 0
											&& mDungeonReport[(i : Int)].chest_type_1 != 0
											|| j == 1
											&& mDungeonReport[(i : Int)].chest_type_2 != 0) {
											ASCompat.setProperty(ASCompat.dynGetIndex(loot[(i : Int)], j), "visible", false);
										}
									}
									j = j + 1;
								}
							}
							i = i + 1;
						}
					}
					loadNextChestPopUp();
			}
		} while (false);
	}

	function applyGlowFilter(clipToGlow:MovieClip) {
		var _loc2_:Array<ASAny> = [];
		_loc2_.push(new GlowFilter((16777215 : UInt), 1, 9, 9, 4));
		clipToGlow.filters = cast(_loc2_);
		clipToGlow.scaleX = 1;
		clipToGlow.scaleY = 1;
	}

	function setUpTownScreen(swfAsset:SwfAsset) {
		mTownRoot = swfAsset.root;
		var _loc2_ = new MovieClipRenderController(mDBFacade, mTownRoot);
		_loc2_.play((0 : UInt), true);
		mSceneGraphComponent.addChild(mTownRoot, (50 : UInt));
	}

	function setupPortraits() {
		var _loc2_:GMSkin = null;
		var _loc3_ = (0 : UInt);
		var _loc1_:TextField = null;
		TextUtil.setText(ASCompat.coerce((mScoreReportRoot : ASAny).stats_a.stats.player_name, flash.text.TextField), mDungeonReport[0].name,
			Locale.summaryNameSizeModifier);
		TextUtil.setText(ASCompat.coerce((mScoreReportRoot : ASAny).stats_b.stats.player_name, flash.text.TextField), mDungeonReport[1].name,
			Locale.summaryNameSizeModifier);
		TextUtil.setText(ASCompat.coerce((mScoreReportRoot : ASAny).stats_c.stats.player_name, flash.text.TextField), mDungeonReport[2].name,
			Locale.summaryNameSizeModifier);
		TextUtil.setText(ASCompat.coerce((mScoreReportRoot : ASAny).stats_d.stats.player_name, flash.text.TextField), mDungeonReport[3].name,
			Locale.summaryNameSizeModifier);
		ASCompat.setProperty((mScoreReportRoot : ASAny).stats_a.stats.player_name, "textColor",
			PlayerSpecialStatus.getSpecialTextColor(mDungeonReport[0].name,
				(ASCompat.toInt((mScoreReportRoot : ASAny).stats_a.stats.player_name.textColor) : UInt)));
		ASCompat.setProperty((mScoreReportRoot : ASAny).stats_b.stats.player_name, "textColor",
			PlayerSpecialStatus.getSpecialTextColor(mDungeonReport[1].name,
				(ASCompat.toInt((mScoreReportRoot : ASAny).stats_b.stats.player_name.textColor) : UInt)));
		ASCompat.setProperty((mScoreReportRoot : ASAny).stats_c.stats.player_name, "textColor",
			PlayerSpecialStatus.getSpecialTextColor(mDungeonReport[2].name,
				(ASCompat.toInt((mScoreReportRoot : ASAny).stats_c.stats.player_name.textColor) : UInt)));
		ASCompat.setProperty((mScoreReportRoot : ASAny).stats_d.stats.player_name, "textColor",
			PlayerSpecialStatus.getSpecialTextColor(mDungeonReport[3].name,
				(ASCompat.toInt((mScoreReportRoot : ASAny).stats_d.stats.player_name.textColor) : UInt)));
		var _loc5_:Array<ASAny> = [
			(mScoreReportRoot : ASAny)
			.stats_a.stats.avatar,
			(mScoreReportRoot : ASAny)
			.stats_b.stats.avatar,
			(mScoreReportRoot : ASAny)
			.stats_c.stats.avatar,
			(mScoreReportRoot : ASAny)
			.stats_d.stats.avatar
		];
		var _loc4_:Array<ASAny> = [
			(mScoreReportRoot : ASAny)
			.stats_a,
			(mScoreReportRoot : ASAny)
			.stats_b,
			(mScoreReportRoot : ASAny)
			.stats_c,
			(mScoreReportRoot : ASAny)
			.stats_d
		];
		_loc3_ = (0 : UInt);
		while (_loc3_ < 4) {
			if (mDungeonReport[(_loc3_ : Int)].valid == ASCompat.toNumber(true)) {
				_loc1_ = ASCompat.coerce(_loc4_[(_loc3_ : Int)].stats.trophies.trophies, flash.text.TextField);
				TextUtil.setText(_loc1_, Std.string(mDungeonReport[(_loc3_ : Int)].trophyCount));
				_loc2_ = mDBFacade.gameMaster.getSkinByType(mDungeonReport[(_loc3_ : Int)].skin_type);
				if (_loc2_ == null) {
					Logger.error("Could not find skin for skin_type: " + mDungeonReport[(_loc3_ : Int)].skin_type);
				} else {
					loadPortraitForReport(mDungeonReport[(_loc3_ : Int)], _loc2_, ASCompat.coerce(_loc5_[(_loc3_ : Int)], flash.display.MovieClip), _loc3_);
				}
			} else {
				ASCompat.setProperty(_loc5_[(_loc3_ : Int)], "visible", false);
			}
			_loc3_++;
		}
	}

	function loadPortraitForReport(dungeonReport:DungeonReport, skin:GMSkin, iconContainer:MovieClip, playerIndex:UInt) {
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(skin.UISwfFilepath), function(param1:SwfAsset) {
			var _loc3_ = param1.getClass(skin.IconName);
			var _loc2_ = ASCompat.coerce(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
			UIObject.scaleToFit(_loc2_, 65);
			iconContainer.addChild(_loc2_);
			var _loc4_ = new UIButton(mDBFacade, iconContainer);
			_loc4_.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
			mAvatarButtons[(playerIndex : Int)] = _loc4_;
			loadSteamAvatar(dungeonReport.id, iconContainer);
			if (mTownHeader != null) {
				setupMenuNavigation();
			}
		});
	}

	function showSteamAvatar(playerId:UInt) {
		if (mSteamAvatarHolder == null) {
			return;
		}
		var _loc2_ = ASCompat.coerce(mSteamAvatarMap.itemFor(playerId), SteamAvatarHelper);
		if (_loc2_ == null) {
			return;
		}
		mSteamAvatarHolder.addChild(_loc2_.pic);
		mSteamAvatarHolder.visible = true;
		var _loc3_ = mDBFacade.designLocalToGlobal(_loc2_.root, new Point(0, 0));
		mSteamAvatarHolder.x = _loc3_.x;
		mSteamAvatarHolder.y = _loc3_.y - _loc2_.root.height / 2 - mSteamAvatarHolder.height / 2;
	}

	function hideSteamAvatar(playerId:UInt) {
		if (mSteamAvatarHolder == null) {
			return;
		}
		mSteamAvatarHolder.visible = false;
		var _loc2_ = ASCompat.coerce(mSteamAvatarMap.itemFor(playerId), SteamAvatarHelper);
		if (_loc2_ == null) {
			return;
		}
		if (mSteamAvatarHolder.contains(_loc2_.pic)) {
			mSteamAvatarHolder.removeChild(_loc2_.pic);
		}
	}

	function loadSteamAvatar(playerId:UInt, root:MovieClip) {
		var loader:Loader;
		var picUrl:String;
		var url:URLRequest;
		var lc:LoaderContext;
		var go = mFacade.gameObjectManager.getReferenceFromId(playerId);
		var player = ASCompat.reinterpretAs(go, PlayerGameObject);
		if (player == null || !ASCompat.stringAsBool(player.steamAvatarUrl) || player.steamAvatarUrl == "") {
			return;
		}
		loader = new Loader();
		picUrl = player.steamAvatarUrl;
		url = new URLRequest(picUrl);
		EventListeners.add(loader.contentLoaderInfo, "ioError", function() {});
		EventListeners.add(loader.contentLoaderInfo, "securityError", function() {});
		EventListeners.add(loader.contentLoaderInfo, "complete", function(param1:Event) {
			var steamAvatarPic:DisplayObject;
			var helper:SteamAvatarHelper;
			var e = param1;
			if (root == null || mDBFacade == null || mSteamAvatarMap == null) {
				return;
			}
			steamAvatarPic = loader;
			steamAvatarPic.x -= 25;
			steamAvatarPic.y -= 25;
			steamAvatarPic.width = steamAvatarPic.height = 50;
			helper = new SteamAvatarHelper();
			helper.pic = steamAvatarPic;
			helper.root = root;
			mSteamAvatarMap.add(playerId, helper);
			EventListeners.add(root, "rollOver", function(param1:flash.events.MouseEvent) {
				showSteamAvatar(playerId);
			});
			EventListeners.add(root, "rollOut", function(param1:flash.events.MouseEvent) {
				hideSteamAvatar(playerId);
			});
		});
		lc = new LoaderContext(true);
		lc.checkPolicyFile = true;
		loader.load(url, lc);
	}

	function setupXPBars() {
		var _loc7_ = (0 : UInt);
		var _loc4_:GMHero = null;
		var _loc5_ = (0 : UInt);
		var _loc2_ = (0 : UInt);
		var _loc1_ = (0 : UInt);
		var _loc8_ = (0 : UInt);
		var _loc6_ = (0 : UInt);
		ASCompat.setProperty((mScoreReportRoot : ASAny).stats_a.stats.fx_level_up_text, "visible", false);
		ASCompat.setProperty((mScoreReportRoot : ASAny).stats_b.stats.fx_level_up_text, "visible", false);
		ASCompat.setProperty((mScoreReportRoot : ASAny).stats_c.stats.fx_level_up_text, "visible", false);
		ASCompat.setProperty((mScoreReportRoot : ASAny).stats_d.stats.fx_level_up_text, "visible", false);
		ASCompat.setProperty((mScoreReportRoot : ASAny).stats_a.stats.fx_level_up_anim, "visible", false);
		ASCompat.setProperty((mScoreReportRoot : ASAny).stats_b.stats.fx_level_up_anim, "visible", false);
		ASCompat.setProperty((mScoreReportRoot : ASAny).stats_c.stats.fx_level_up_anim, "visible", false);
		ASCompat.setProperty((mScoreReportRoot : ASAny).stats_d.stats.fx_level_up_anim, "visible", false);
		var _loc3_:Array<ASAny> = [
			(mScoreReportRoot : ASAny)
			.stats_a.stats.xp_bar.UI_XP,
			(mScoreReportRoot : ASAny)
			.stats_b.stats.xp_bar.UI_XP,
			(mScoreReportRoot : ASAny)
			.stats_c.stats.xp_bar.UI_XP,
			(mScoreReportRoot : ASAny)
			.stats_d.stats.xp_bar.UI_XP
		];
		_loc7_ = (0 : UInt);
		while (_loc7_ < 4) {
			if (mDungeonReport[(_loc7_ : Int)].valid != 0) {
				_loc4_ = ASCompat.coerce(mDBFacade.gameMaster.heroById.itemFor(mDungeonReport[(_loc7_ : Int)].type), gameMasterDictionary.GMHero);
				_loc5_ = _loc4_.getLevelFromExp(mDungeonReport[(_loc7_ : Int)].xp, mDungeonReport[(_loc7_ : Int)].ascension_level);
				_loc2_ = mDungeonReport[(_loc7_ : Int)].xp;
				_loc1_ = (_loc4_.getLevelIndex(_loc2_, (mDungeonReport[(_loc7_ : Int)].ascension_level : Int)) : UInt);
				_loc8_ = (ASCompat.toInt(_loc1_ > 0 ? _loc4_.getExpFromIndex(_loc1_ - 1) : 0) : UInt);
				_loc6_ = _loc4_.getExpFromIndex(_loc1_);
				mXpBar[(_loc7_ : Int)] = new UIProgressBar(mFacade, ASCompat.coerce(_loc3_[(_loc7_ : Int)].xp_bar, flash.display.MovieClip));
				if (ASCompat.toBool(_loc3_[(_loc7_ : Int)].xp_bar_delta)) {
					ASCompat.setProperty(_loc3_[(_loc7_ : Int)].xp_bar_delta, "visible", false);
				}
				ASCompat.setProperty(mXpBar[(_loc7_ : Int)], "value", ((_loc2_ : Float) - (_loc8_ : Float)) / ((_loc6_ : Float) - (_loc8_ : Float)));
				TextUtil.setText(ASCompat.coerce(_loc3_[(_loc7_ : Int)].xp_level, flash.text.TextField), Std.string(_loc5_));
				ASCompat.setProperty(_loc3_[(_loc7_ : Int)].xp_points, "visible", true);
				TextUtil.setText(ASCompat.coerce(_loc3_[(_loc7_ : Int)].xp_points, flash.text.TextField), Std.string(mDungeonReport[(_loc7_ : Int)].xp));
			} else {
				ASCompat.setProperty(_loc3_[(_loc7_ : Int)], "visible", false);
			}
			_loc7_++;
		}
		mBoosterExpTick = (0 : UInt);
		mBoosterGoldTick = (0 : UInt);
	}

	public function TransactionResponse(account_id:UInt, succeeded:UInt, offer_id:UInt, weapon_id:UInt) {
		var updateRevealPopupCallback:ASFunction;
		var details:ASObject;
		var callbackHelper:ASFunction;
		if (mDBFacade.accountId != account_id) {
			return;
		}
		closeBoosterPopup();
		updateRevealPopupCallback = function() {};
		if (succeeded != 0) {
			details = {};
			ASCompat.setProperty(details, "OfferId", offer_id);
			ASCompat.setProperty(details, "WeaponId", weapon_id);
			ASCompat.setProperty(details, "NewWeaponDetails", {});
			ASCompat.setProperty(details.NewWeaponDetails, "id", weapon_id);
			if (!mTookLastItem) {
				callbackHelper = function(param1:ASAny):ASFunction {
					var details:ASAny = param1;
					return function() {
						mChestRevealPopUp.updateRevealLoot(details);
					};
				};
				updateRevealPopupCallback = ASCompat.coerceFunction(callbackHelper(details));
			}
			if (mInfoPopup != null) {
				if (mSelectedItemSlot == 1000 && mItemCount > 0) {
					mDBFacade.metrics.log("DungeonLootTakeAll", {"itemCount": mItemCount});
				}
				removeItemFromSlot(mSelectedItemSlot);
			}
			if (mTookLastItem) {
				removeItemFromSlot(mSelectedItemSlot);
				if (!mFromInventory) {
					if (mTreasureFoundPopup != null) {
						closeKeyChestPopup();
					}
					loadNextChestPopUp();
				}
			}
		} else {
			closeInfoPopup();
			mChestTransactionFailedPopup = new DBUIPopup(mDBFacade, "", Locale.getString("TRANSACTION_FAILED"));
			MemoryTracker.track(mChestTransactionFailedPopup, "DBUIPopup - created in DistributedDungeonSummary.TransactionResponse()");
			mLogicalWorkComponent.doLater(1.5, function() {
				if (mChestTransactionFailedPopup != null) {
					mChestTransactionFailedPopup.destroy();
					mChestTransactionFailedPopup = null;
				}
			});
			if (!mTookLastItem) {
				if (mTreasureFoundPopup != null) {
					closeKeyChestPopup();
				}
				mChestRevealPopUp.destroy();
				mChestRevealPopUp = null;
			}
			loadNextChestPopUp();
		}
		mEventComponent.addListener("DB_ACCOUNT_INFO_LOADED", function(param1:Event) {
			mEventComponent.removeListener("DB_ACCOUNT_INFO_LOADED");
			closeInfoPopup();
			updateRevealPopupCallback();
			if (mTransactionSuccessCallback != null) {
				mTransactionSuccessCallback();
			}
		});
		mDBFacade.dbAccountInfo.getUsersFullAccountInfo();
	}

	public function openBoosterPopup() {
		mBoosterPopup = new UIVictoryBoosterPopup(mDBFacade, Locale.getString("BOOSTER_POPUP"));
		MemoryTracker.track(mBoosterPopup, "UIVictoryBoosterPopup - created in DistributedDungeonSummary.openBoosterPopup()");
	}

	public function closeBoosterPopup() {
		if (mBoosterPopup != null) {
			mBoosterPopup.destroy();
			mBoosterPopup = null;
		}
	}

	function loadChestIconCallback(gmChest:GMChest, loot:MovieClip, loot_type:UInt, player:UInt, slot:UInt, summary:DistributedDungeonSummary):ASFunction {
		return function(param1:SwfAsset) {
			var _loc2_ = param1.getClass(gmChest.IconName);
			if (_loc2_ != null) {
				mItemButtons[(player : Int)][slot] = new UIButton(mDBFacade, loot);
				ASCompat.setProperty(ASCompat.dynGetIndex(mItemButtons[(player : Int)], slot), "rolloverFilter", DBGlobal.UI_ROLLOVER_FILTER);
				ASCompat.setProperty(ASCompat.dynGetIndex(mItemButtons[(player : Int)], slot), "enabled", player == 0);
				ASCompat.setProperty(ASCompat.dynGetIndex(mItemButtons[(player : Int)], slot), "releaseCallback", chestPopupCallback(gmChest, slot));
			} else {
				Logger.error("Could not find asset class for loot item: " + Std.string(loot_type));
			}
		};
	}

	function getPlayerSlotItemCount(playerSlot:Int):Int {
		var _loc3_ = (0 : UInt);
		var _loc5_ = 0;
		var _loc4_ = mDungeonReport[playerSlot];
		var _loc2_:Array<ASAny> = [
			_loc4_.chest_type_1,
			_loc4_.chest_type_2,
			_loc4_.chest_type_3,
			_loc4_.chest_type_4
		];
		if (_loc4_.valid == ASCompat.toNumber(true)) {
			_loc3_ = (0 : UInt);
			while (_loc3_ < (_loc2_.length:UInt)) {
				if (ASCompat.toNumber(_loc2_[(_loc3_ : Int)]) != 0) {
					_loc5_++;
				}
				_loc3_++;
			}
		}
		return _loc5_;
	}

	function setupItemButtons() {
		var _loc2_ = (0 : UInt);
		var _loc7_:DungeonReport = null;
		var _loc1_:Array<ASAny> = null;
		var _loc6_ = (0 : UInt);
		var _loc4_:GMChest = null;
		var _loc5_:Array<ASAny> = [
			(mScoreReportRoot : ASAny)
			.stats_a,
			(mScoreReportRoot : ASAny)
			.stats_b,
			(mScoreReportRoot : ASAny)
			.stats_c,
			(mScoreReportRoot : ASAny)
			.stats_d
		];
		var _loc3_ = mUILootSlots;
		if (mUILootSlots == mUILootSlotsFourTreasures) {
			setUILootSlotsTwoTreasuresVisible(false);
		}
		if (mUILootSlots == mUILootSlotsTwoTreasures) {
			setUILootSlotsFourTreasuresVisible(false);
		}
		_loc2_ = (0 : UInt);
		while (_loc2_ < 4) {
			_loc7_ = mDungeonReport[(_loc2_ : Int)];
			_loc1_ = [_loc7_.loot_type_1, _loc7_.loot_type_2, _loc7_.loot_type_3, _loc7_.loot_type_4];
			if (_loc7_.valid == ASCompat.toNumber(true)) {
				_loc6_ = (0 : UInt);
				while (_loc6_ < (_loc1_.length:UInt)) {
					if (ASCompat.toNumber(_loc1_[(_loc6_ : Int)]) != 0) {
						_loc4_ = ASCompat.coerce(mDBFacade.gameMaster.chestsById.itemFor(_loc1_[(_loc6_ : Int)]), gameMasterDictionary.GMChest);
						if (_loc4_ != null && ASCompat.stringAsBool(_loc4_.IconName)) {
							if (isSingleChestList[(_loc2_ : Int)]) {
								if (_loc3_[(_loc2_ : Int)] == null || ASCompat.dynGetIndex(_loc3_[(_loc2_ : Int)], 2) == null) {
									Logger.warn("Could not load loot for singleChestList player slot: " + _loc2_);
									_loc6_++;
									continue;
								}
								ASCompat.setProperty(ASCompat.dynGetIndex(_loc3_[(_loc2_ : Int)], 2), "visible", false);
								mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(_loc4_.IconSwf),
									loadChestIconCallback(_loc4_,
										ASCompat.coerce(ASCompat.dynGetIndex(mChestMovieClips[(_loc2_ : Int)], 2), flash.display.MovieClip),
										(ASCompat.toInt(_loc1_[(_loc6_ : Int)]) : UInt), _loc2_, _loc6_, this));
							} else {
								if (_loc3_[(_loc2_ : Int)] == null || ASCompat.dynGetIndex(_loc3_[(_loc2_ : Int)], _loc6_) == null) {
									Logger.warn("Could not load loot for player slot: " + _loc2_ + " chest slot: " + _loc6_);
									_loc6_++;
									continue;
								}
								ASCompat.setProperty(ASCompat.dynGetIndex(_loc3_[(_loc2_ : Int)], _loc6_), "visible", false);
								mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(_loc4_.IconSwf),
									loadChestIconCallback(_loc4_,
										ASCompat.coerce(ASCompat.dynGetIndex(mChestMovieClips[(_loc2_ : Int)], _loc6_), flash.display.MovieClip),
										(ASCompat.toInt(_loc1_[(_loc6_ : Int)]) : UInt), _loc2_, _loc6_, this));
							}
						} else {
							Logger.error("Could not find GMChestItem for loot item: " + Std.string(_loc1_[(_loc6_ : Int)]));
						}
					}
					_loc6_++;
				}
			} else {
				ASCompat.setProperty(_loc5_[(_loc2_ : Int)], "visible", false);
			}
			_loc2_++;
		}
	}

	function setupLoot() {
		var mcr:MovieClipRenderer;
		var loot:Array<ASAny>;
		var yScale:Float;
		final __ax4_iter_311 = mChestRenderers;
		if (checkNullIteratee(__ax4_iter_311))
			for (_tmp_ in __ax4_iter_311) {
				mcr = _tmp_;
				mcr.destroy();
			}
		mChestRenderers.splice(0, (mChestRenderers.length : UInt));
		mItemCount = 0;
		mBonusXPTick = new Vector<UInt>((4 : UInt));
		mTeamBonusXPTick = new Vector<UInt>((4 : UInt));
		mKillsTick = new Vector<UInt>((4 : UInt));
		mItemCount = getPlayerSlotItemCount(0);
		yScale = 0.5;
		if (mItemCount > 2) {
			mUILootSlots = mUILootSlotsFourTreasures;
			yScale = 0.4;
		} else {
			mUILootSlots = mUILootSlotsTwoTreasures;
		}
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Doobers/db_items_doobers.swf"), function(param1:SwfAsset) {
			var _loc9_ = (0 : UInt);
			var _loc2_:Array<ASAny> = null;
			var _loc12_ = 0;
			var _loc5_ = (0 : UInt);
			var _loc10_ = (0 : UInt);
			var _loc7_:GMDoober = null;
			var _loc8_:GMChest = null;
			var _loc6_:String = null;
			var _loc4_:String = null;
			var _loc11_:Point = null;
			var _loc3_:Array<ASAny> = null;
			loot = mUILootSlots;
			_loc9_ = (0 : UInt);
			while (_loc9_ < 4) {
				_loc2_ = [
					mDungeonReport[(_loc9_ : Int)].chest_type_1,
					mDungeonReport[(_loc9_ : Int)].chest_type_2,
					mDungeonReport[(_loc9_ : Int)].chest_type_3,
					mDungeonReport[(_loc9_ : Int)].chest_type_4
				];
				_loc12_ = 0;
				_loc5_ = (0 : UInt);
				while (_loc5_ < (_loc2_.length:UInt)) {
					if (ASCompat.toBool(_loc2_[(_loc5_ : Int)])) {
						_loc12_++;
					}
					_loc5_++;
				}
				if (_loc12_ > 2) {
					ASCompat.ASArray.sort(_loc2_, reverseChestTypeComparison);
				} else {
					ASCompat.ASArray.sort(_loc2_, compareChestTypes);
				}
				if (mDungeonReport[(_loc9_ : Int)].valid == ASCompat.toNumber(true)) {
					_loc10_ = (0 : UInt);
					while (_loc10_ < 4) {
						if (!(ASCompat.toNumber(_loc2_[(_loc10_ : Int)]) == 0
							|| ASCompat.dynGetIndex(loot[(_loc9_ : Int)], _loc10_) == null)) {
							_loc7_ = ASCompat.coerce(mDBFacade.gameMaster.dooberById.itemFor(_loc2_[(_loc10_ : Int)]), gameMasterDictionary.GMDoober);
							if (_loc7_ != null) {
								_loc8_ = ASCompat.coerce(mDBFacade.gameMaster.chestsById.itemFor(_loc7_.ChestId), gameMasterDictionary.GMChest);
								_loc6_ = _loc8_.IconSwf;
								_loc4_ = _loc8_.IconName;
								if (isSingleChestList[(_loc9_ : Int)]) {
									_loc10_ = (2 : UInt);
								}
								_loc11_ = new Point(ASCompat.toNumberField(ASCompat.dynGetIndex(loot[(_loc9_ : Int)], _loc10_), "x"),
									ASCompat.toNumberField(ASCompat.dynGetIndex(loot[(_loc9_ : Int)], _loc10_), "y"));
								_loc3_ = mChestMovieClips;
								ChestInfo.loadItemIcon(_loc6_, _loc4_,
									ASCompat.coerce(ASCompat.dynGetIndex(mChestMovieClips[(_loc9_ : Int)], _loc10_), flash.display.DisplayObjectContainer),
									mDBFacade, (150 : UInt), (150 : UInt), mAssetLoadingComponent);
								ASCompat.setProperty(ASCompat.dynGetIndex(mChestMovieClips[(_loc9_ : Int)], _loc10_), "scaleX",
									ASCompat.setProperty(ASCompat.dynGetIndex(mChestMovieClips[(_loc9_ : Int)], _loc10_), "scaleY", yScale));
								ASCompat.setProperty(ASCompat.dynGetIndex(mChestMovieClips[(_loc9_ : Int)], _loc10_), "x", _loc11_.x);
								ASCompat.setProperty(ASCompat.dynGetIndex(mChestMovieClips[(_loc9_ : Int)], _loc10_), "y", _loc11_.y);
							}
						}
						_loc10_++;
					}
				}
				_loc9_++;
			}
		});
		setupItemButtons();
	}

	public function compareChestTypes(a:UInt, b:UInt):Int {
		if (a == 0) {
			return 1;
		}
		if (b == 0) {
			return -1;
		}
		var _loc3_ = ASCompat.coerce(mDBFacade.gameMaster.dooberById.itemFor(a), gameMasterDictionary.GMDoober);
		var _loc4_ = ASCompat.coerce(mDBFacade.gameMaster.dooberById.itemFor(b), gameMasterDictionary.GMDoober);
		if (mRarityMap.itemFor(_loc3_.Rarity) > mRarityMap.itemFor(_loc4_.Rarity)) {
			return -1;
		}
		if (mRarityMap.itemFor(_loc4_.Rarity) > mRarityMap.itemFor(_loc3_.Rarity)) {
			return 1;
		}
		return 0;
	}

	public function reverseChestTypeComparison(a:UInt, b:UInt):Int {
		if (a == 0 || b == 0) {
			return 1;
		}
		var _loc3_ = ASCompat.coerce(mDBFacade.gameMaster.dooberById.itemFor(a), gameMasterDictionary.GMDoober);
		var _loc4_ = ASCompat.coerce(mDBFacade.gameMaster.dooberById.itemFor(b), gameMasterDictionary.GMDoober);
		if (mRarityMap.itemFor(_loc3_.Rarity) > mRarityMap.itemFor(_loc4_.Rarity)) {
			return 1;
		}
		if (mRarityMap.itemFor(_loc4_.Rarity) > mRarityMap.itemFor(_loc3_.Rarity)) {
			return -1;
		}
		return 0;
	}

	function setupWeapons() {
		mWeapons = [[], [], [], []];
		mWeaponTooltips = [[], [], [], []];
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"), function(param1:SwfAsset) {
			var _loc2_ = (0 : UInt);
			var _loc3_ = (0 : UInt);
			_loc2_ = (0 : UInt);
			while (_loc2_ < 4) {
				if (mDungeonReport[(_loc2_ : Int)].valid == ASCompat.toNumber(true)) {
					_loc3_ = (0 : UInt);
					while (_loc3_ < 3) {
						if (!(_loc3_ == 0 && mDungeonReport[(_loc2_ : Int)].weapon_type_1 == 0)) {
							if (!(_loc3_ == 1 && mDungeonReport[(_loc2_ : Int)].weapon_type_2 == 0)) {
								if (!(_loc3_ == 2 && mDungeonReport[(_loc2_ : Int)].weapon_type_3 == 0)) {
									setupWeaponUIForStat(param1, _loc2_, _loc3_);
								}
							}
						}
						_loc3_++;
					}
				}
				_loc2_++;
			}
			if (mTownHeader != null) {
				setupMenuNavigation();
			}
		});
	}

	function setupWeaponUIForStat(swfAsset:SwfAsset, statNum:UInt, weaponSlotNum:UInt) {
		var tooltipClass:Dynamic;
		var weaponTooltip:UIWeaponTooltip;
		var gmWeaponItem:GMWeaponItem = null;
		var gmWeaponAesthetic:GMWeaponAesthetic = null;
		var weaponButtons:Array<ASAny> = [
			[
				(mScoreReportRoot : ASAny)
				.stats_a.stats.loot_slot_A1,
				(mScoreReportRoot : ASAny)
				.stats_a.stats.loot_slot_A2,
				(mScoreReportRoot : ASAny)
				.stats_a.stats.loot_slot_A3
			],
			[
				(mScoreReportRoot : ASAny)
				.stats_b.stats.loot_slot_A1,
				(mScoreReportRoot : ASAny)
				.stats_b.stats.loot_slot_A2,
				(mScoreReportRoot : ASAny)
				.stats_b.stats.loot_slot_A3
			],
			[
				(mScoreReportRoot : ASAny)
				.stats_c.stats.loot_slot_A1,
				(mScoreReportRoot : ASAny)
				.stats_c.stats.loot_slot_A2,
				(mScoreReportRoot : ASAny)
				.stats_c.stats.loot_slot_A3
			],
			[
				(mScoreReportRoot : ASAny)
				.stats_d.stats.loot_slot_A1,
				(mScoreReportRoot : ASAny)
				.stats_d.stats.loot_slot_A2,
				(mScoreReportRoot : ASAny)
				.stats_d.stats.loot_slot_A3
			]
		];
		var weapon = new UIObject(mDBFacade, ASCompat.coerce(ASCompat.dynGetIndex(weaponButtons[(statNum : Int)], weaponSlotNum), flash.display.MovieClip));
		mWeapons[(statNum : Int)][weaponSlotNum] = weapon;
		tooltipClass = swfAsset.getClass("DR_weapon_tooltip");
		weaponTooltip = new UIWeaponTooltip(mDBFacade, tooltipClass);
		ASCompat.dynPush(mWeaponTooltips[(statNum : Int)], weaponTooltip);
		switch (weaponSlotNum) {
			case 0:
				gmWeaponItem = ASCompat.coerce(mDBFacade.gameMaster.weaponItemById.itemFor(mDungeonReport[(statNum : Int)].weapon_type_1),
					gameMasterDictionary.GMWeaponItem);
				gmWeaponAesthetic = gmWeaponItem.getWeaponAesthetic(mDungeonReport[(statNum : Int)].weapon_level_1,
					mDungeonReport[(statNum : Int)].legendary_modifier_type_1 > 0);

			case 1:
				gmWeaponItem = ASCompat.coerce(mDBFacade.gameMaster.weaponItemById.itemFor(mDungeonReport[(statNum : Int)].weapon_type_2),
					gameMasterDictionary.GMWeaponItem);
				gmWeaponAesthetic = gmWeaponItem.getWeaponAesthetic(mDungeonReport[(statNum : Int)].weapon_level_2,
					mDungeonReport[(statNum : Int)].legendary_modifier_type_2 > 0);

			case 2:
				gmWeaponItem = ASCompat.coerce(mDBFacade.gameMaster.weaponItemById.itemFor(mDungeonReport[(statNum : Int)].weapon_type_3),
					gameMasterDictionary.GMWeaponItem);
				gmWeaponAesthetic = gmWeaponItem.getWeaponAesthetic(mDungeonReport[(statNum : Int)].weapon_level_3,
					mDungeonReport[(statNum : Int)].legendary_modifier_type_3 > 0);
		}
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmWeaponAesthetic.IconSwf), function(param1:SwfAsset) {
			var rarity:GMRarity = null;
			var bgColoredExists:Bool;
			var bgSwfPath:String;
			var bgIconName:String;
			var swfAsset = param1;
			var weaponClass = swfAsset.getClass(gmWeaponAesthetic.IconName);
			var weaponMC = ASCompat.dynamicAs(ASCompat.createInstance(weaponClass, []), MovieClip);
			weaponMC.scaleX = weaponMC.scaleY = 0.5;
			weapon.root.addChild(weaponMC);
			weapon.tooltip = weaponTooltip;
			switch (weaponSlotNum) {
				case 0:
					rarity = ASCompat.coerce(mDBFacade.gameMaster.rarityById.itemFor(mDungeonReport[(statNum : Int)].weapon_rarity_1),
						gameMasterDictionary.GMRarity);

				case 1:
					rarity = ASCompat.coerce(mDBFacade.gameMaster.rarityById.itemFor(mDungeonReport[(statNum : Int)].weapon_rarity_2),
						gameMasterDictionary.GMRarity);

				case 2:
					rarity = ASCompat.coerce(mDBFacade.gameMaster.rarityById.itemFor(mDungeonReport[(statNum : Int)].weapon_rarity_3),
						gameMasterDictionary.GMRarity);
			}
			bgColoredExists = rarity.HasColoredBackground;
			bgSwfPath = rarity.BackgroundSwf;
			bgIconName = rarity.BackgroundIcon;
			if (bgColoredExists) {
				mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(bgSwfPath), function(param1:SwfAsset) {
					var _loc3_:MovieClip = null;
					var _loc2_ = param1.getClass(bgIconName);
					if (_loc2_ != null) {
						_loc3_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), MovieClip);
						_loc3_.scaleX = _loc3_.scaleY = 0.65;
						weapon.root.addChildAt(_loc3_, 1);
					}
				});
			}
			switch (weaponSlotNum) {
				case 0:
					weaponTooltip.setWeaponItemFromData(gmWeaponAesthetic.Name, mDungeonReport[(statNum : Int)].weapon_power_1, gmWeaponItem.TapIcon,
						gmWeaponItem.HoldIcon, mDungeonReport[(statNum : Int)].modifier_type_1a, mDungeonReport[(statNum : Int)].modifier_type_1b,
						mDungeonReport[(statNum : Int)].legendary_modifier_type_1, mDungeonReport[(statNum : Int)].weapon_rarity_1,
						mDungeonReport[(statNum : Int)].weapon_level_1, gmWeaponAesthetic);

				case 1:
					weaponTooltip.setWeaponItemFromData(gmWeaponAesthetic.Name, mDungeonReport[(statNum : Int)].weapon_power_2, gmWeaponItem.TapIcon,
						gmWeaponItem.HoldIcon, mDungeonReport[(statNum : Int)].modifier_type_2a, mDungeonReport[(statNum : Int)].modifier_type_2b,
						mDungeonReport[(statNum : Int)].legendary_modifier_type_2, mDungeonReport[(statNum : Int)].weapon_rarity_2,
						mDungeonReport[(statNum : Int)].weapon_level_2, gmWeaponAesthetic);

				case 2:
					weaponTooltip.setWeaponItemFromData(gmWeaponAesthetic.Name, mDungeonReport[(statNum : Int)].weapon_power_3, gmWeaponItem.TapIcon,
						gmWeaponItem.HoldIcon, mDungeonReport[(statNum : Int)].modifier_type_3a, mDungeonReport[(statNum : Int)].modifier_type_3b,
						mDungeonReport[(statNum : Int)].legendary_modifier_type_3, mDungeonReport[(statNum : Int)].weapon_rarity_3,
						mDungeonReport[(statNum : Int)].weapon_level_3, gmWeaponAesthetic);
			}
		});
	}

	public function compareOnChestValues(a:Array<ASAny>, b:Array<ASAny>):Int {
		return compareChestTypes((ASCompat.toInt(a[1]) : UInt), (ASCompat.toInt(b[1]) : UInt));
	}

	public function loadNextChestPopUp() {
		var _loc1_ = 0;
		var _loc8_:Array<ASAny> = null;
		var _loc4_:GMChest = null;
		var _loc6_ = 0;
		var _loc2_ = 0;
		mDBFacade.dbAccountInfo.getUsersFullAccountInfo();
		var _loc7_ = mDungeonReport[0];
		var _loc5_:Array<ASAny> = [
			_loc7_.chest_type_1,
			_loc7_.chest_type_2,
			_loc7_.chest_type_3,
			_loc7_.chest_type_4
		];
		var _loc3_:Array<ASAny> = [];
		_loc1_ = 0;
		while (_loc1_ < 4) {
			_loc8_ = [_loc1_, _loc5_[_loc1_]];
			_loc3_.push(_loc8_);
			_loc1_++;
		}
		ASCompat.ASArray.sort(_loc3_, compareOnChestValues);
		if (_loc7_.valid != 0) {
			if (ASCompat.toNumber(ASCompat.dynGetIndex(_loc3_[0], 1)) != 0) {
				_loc6_ = ASCompat.toInt(ASCompat.dynGetIndex(_loc3_[0], 0));
				_loc2_ = ASCompat.toInt(ASCompat.dynGetIndex(_loc3_[0], 1));
				_loc4_ = ASCompat.coerce(mDBFacade.gameMaster.chestsById.itemFor(mDBFacade.gameMaster.dooberById.itemFor(_loc2_).ChestId),
					gameMasterDictionary.GMChest);
				chestOpenPopUp(_loc4_, (_loc6_ : UInt));
				return;
			}
		}
	}

	function chestOpenPopUp(gmChest:GMChest, slot:UInt) {
		mSelectedItemSlot = slot;
		mSelectedGMChest = gmChest;
		mTreasureFoundPopup = new UITreasureFoundPopup(mDBFacade, mSelectedGMChest, abandonChestCallback, keepChestCallback, openChestCallback,
			refreshHeroInfoUI);
	}

	@:isVar public var dungeonSuccess(get, set):UInt;

	public function set_dungeonSuccess(val:UInt):UInt {
		if (val == 0) {
			mDungeonSuccess = false;
		} else if (val == 1) {
			mDungeonSuccess = true;
		} else {
			Logger.error("Unable to parse value to a bool.  Value: " + val);
		}
		return val;
	}

	function get_dungeonSuccess():UInt {
		return (ASCompat.toInt(mDungeonSuccess) : UInt);
	}

	function chestPopupCallback(gmChest:GMChest, slot:UInt):ASFunction {
		return function() {
			chestOpenPopUp(gmChest, slot);
		};
	}

	public function refreshHeroInfoUI(chestMC:MovieClip) {
		var mHeroInfo:AvatarInfo;
		var gmSkin:GMSkin;
		Locale.setText(ASCompat.coerce((chestMC : ASAny).hero_label, flash.text.TextField), "OPENING_WITH");
		mHeroInfo = mDBFacade.dbAccountInfo.activeAvatarInfo;
		gmSkin = mDBFacade.gameMaster.getSkinByType(mHeroInfo.skinId);
		if (gmSkin == null) {
			Logger.error("Unable to find gmSkin for ID: " + mHeroInfo.skinId);
		} else {
			mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmSkin.IconSwfFilepath), function(param1:SwfAsset) {
				var _loc3_ = param1.getClass(gmSkin.IconName);
				if (_loc3_ == null) {
					return;
				}
				var _loc4_ = ASCompat.coerce(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
				var _loc2_ = new MovieClipRenderController(mDBFacade, _loc4_);
				_loc2_.play();
				if (ASCompat.toNumberField((chestMC : ASAny).avatar, "numChildren") > 0) {
					(chestMC : ASAny).avatar.removeChildAt(0);
				}
				(chestMC : ASAny).avatar.addChildAt(_loc4_, 0);
				_loc4_.scaleX = _loc4_.scaleY = 1;
			});
		}
	}

	function setupOpenKeylessChest() {
		mChestBuyKeysPopUp = new ChestBuyKeysPopUp(mDBFacade, mSelectedGMChest, chestBuyCoinCallback, chestBuyGemCallback, closeKeylessChestPopup,
			refreshHeroInfoUI, true);
	}

	function createKeySlots(mc:MovieClip) {
		var _loc3_ = 0;
		var _loc2_:MovieClip = null;
		mChestKeySlots = new Vector<ChestKeySlot>();
		_loc3_ = 0;
		while (_loc3_ < 4) {
			_loc2_ = ASCompat.reinterpretAs(mc.getChildByName("slot_" + Std.string(_loc3_)), MovieClip);
			mChestKeySlots.push(new ChestKeySlot(mDBFacade, _loc2_, mDBFacade.dbAccountInfo.inventoryInfo.keys[_loc3_], mAssetLoadingComponent));
			if (mSelectedGMChest.Id == mChestKeySlots[_loc3_].keyInfo.gmKey.ChestId) {
				mChestKeySlots[_loc3_].setSelected(true);
			} else {
				mChestKeySlots[_loc3_].setSelected(false);
			}
			_loc3_++;
		}
	}

	function chestBuyCoinCallback(val:Float):ASFunction {
		return function() {
			var _loc1_ = 0;
			var _loc2_ = (0 : UInt);
			mDBFacade.metrics.log("ChestUnlockCoinTry", {
				"chestId": mSelectedGMChest.Id,
				"rarity": mSelectedGMChest.Rarity,
				"category": "dungeonSummary"
			});
			if (mDBFacade.dbAccountInfo.basicCurrency >= val) {
				mDBFacade.metrics.log("ChestUnlockCoin", {
					"chestId": mSelectedGMChest.Id,
					"rarity": mSelectedGMChest.Rarity,
					"category": "dungeonSummary"
				});
				closeKeylessChestPopup();
				closeKeyChestPopup();
				closeInfoPopup();
				mInfoPopup = new DBUIPopup(mDBFacade, "", Locale.getString("PURCHASING..."));
				MemoryTracker.track(mInfoPopup, "DBUIPopup - created in DistributedDungeonSummary.chestBuyCoinCallback()");
				mSceneGraphComponent.addChild(mInfoPopup.root, (105 : UInt));
				_loc1_ = 0;
				while (_loc1_ < 6) {
					if (mDBFacade.dbAccountInfo.inventoryInfo.keys[_loc1_].gmKey.ChestId == mSelectedGMChest.Id) {
						_loc2_ = mDBFacade.dbAccountInfo.inventoryInfo.keys[_loc1_].gmKeyOffer.Id;
						StoreServices.purchaseOffer(mDBFacade, _loc2_, boughtKey, boughtKeyError, (0 : UInt), false);
						break;
					}
					_loc1_++;
				}
			} else {
				StoreServicesController.showCoinPage(mDBFacade);
			}
		};
	}

	function chestBuyGemCallback(val:Float):ASFunction {
		return function() {
			var _loc1_ = 0;
			var _loc2_ = (0 : UInt);
			mDBFacade.metrics.log("ChestUnlockGemTry", {
				"chestId": mSelectedGMChest.Id,
				"rarity": mSelectedGMChest.Rarity,
				"category": "dungeonSummary"
			});
			if (mDBFacade.dbAccountInfo.premiumCurrency >= val) {
				mDBFacade.metrics.log("ChestUnlockGem", {
					"chestId": mSelectedGMChest.Id,
					"rarity": mSelectedGMChest.Rarity,
					"category": "dungeonSummary"
				});
				closeKeylessChestPopup();
				closeKeyChestPopup();
				closeInfoPopup();
				mInfoPopup = new DBUIPopup(mDBFacade, "", Locale.getString("PURCHASING..."));
				MemoryTracker.track(mInfoPopup, "DBUIPopup - created in DistributedDungeonSummary.chestBuyGemCallback()");
				mSceneGraphComponent.addChild(mInfoPopup.root, (105 : UInt));
				_loc1_ = 0;
				while (_loc1_ < 6) {
					if (mDBFacade.dbAccountInfo.inventoryInfo.keys[_loc1_].gmKey.ChestId == mSelectedGMChest.Id) {
						_loc2_ = mDBFacade.dbAccountInfo.inventoryInfo.keys[_loc1_].gmKeyOffer.Id;
						StoreServices.purchaseOffer(mDBFacade, _loc2_, boughtKey, boughtKeyError, (0 : UInt), false);
						break;
					}
					_loc1_++;
				}
			} else {
				StoreServicesController.showCashPage(mDBFacade, "chestOpenWithGemsAttemptDungeonSummary");
			}
		};
	}

	function abandonChestCallback(category:String = "dungeonSummaryChestPopUp") {
		mAbandonChestPopUp = new DBUITwoButtonPopup(mDBFacade, "ABANDON_CHEST_CONFIRMATION", Locale.getString("ABANDON_CHEST_POPUP_TITLE"),
			Locale.getString("ABANDON_CHEST_POPUP_DESC"), Locale.getString("ABANDON_CHEST_POPUP_CANCEL"), closeAbandonChestPopUp,
			Locale.getString("ABANDON_CHEST_POPUP_CONFIRM"), function() {
				mNetworkComponent.send_DropChest(mDBFacade.dbAccountInfo.id, mSelectedItemSlot);
				mDBFacade.metrics.log("ChestAbandoned", {
					"chestId": mSelectedGMChest.Id,
					"rarity": mSelectedGMChest.Rarity,
					"category": category
				});
				removeItemFromSlot(mSelectedItemSlot);
				closeAbandonChestPopUp();
				closeKeyChestPopup();
				loadNextChestPopUp();
		}, false);
		MemoryTracker.track(mAbandonChestPopUp, "DBUITwoButtonPopup - created in DistributedDungeonSummary.abandonChestCallback()");
		mAbandonChestPopUp.root.y += 180;
	}

	function closeAbandonChestPopUp() {
		if (mAbandonChestPopUp != null) {
			mAbandonChestPopUp.destroy();
			mAbandonChestPopUp = null;
		}
	}

	public function abandonChestFromInventory(slot:UInt) {
		mNetworkComponent.send_DropChest(mDBFacade.dbAccountInfo.id, slot);
		removeItemFromSlot(slot);
		mUIInventory.refresh(true);
	}

	function keepChestCallback() {
		if (mDBFacade.dbAccountInfo.inventoryInfo.isThereEmptySpaceInWeaponStorage()) {
			closeKeyChestPopup();
			keepChestFromInventory(mSelectedItemSlot, false);
		} else {
			mStorageFullPopUp = new DBUITwoButtonPopup(mDBFacade, "DUNGEON_SUMMARY_STORAGE_FULL_ON_KEEP", Locale.getString("GO_TO_INVENTORY_TITLE"),
				Locale.getString("GO_TO_INVENTORY_BODY"), Locale.getString("INVENTORY"), function() {
					closeStorageFullPopUp();
					closeKeyChestPopup();
					openInventory();
			}, Locale.getString("ABANDON"), function() {
					closeStorageFullPopUp();
					abandonChestCallback("dungeonSummaryInventoryFullOnKeep");
			}, true, closeStorageFullPopUp);
			MemoryTracker.track(mStorageFullPopUp, "DBUITwoButtonPopup - created in DistributedDungeonSummary.keepChestCallback()");
			mStorageFullPopUp.root.y += 180;
		}
	}

	public function keepChestFromInventory(slot:UInt, fromInventory:Bool) {
		if (fromInventory) {
			mDBFacade.metrics.log("ChestKept", {
				"chestId": mSelectedGMChest.Id,
				"rarity": mSelectedGMChest.Id,
				"category": "storageFromDungeonSummary"
			});
		} else {
			mDBFacade.metrics.log("ChestKept", {
				"chestId": mSelectedGMChest.Id,
				"rarity": mSelectedGMChest.Id,
				"category": "dungeonSummary"
			});
		}
		mSelectedItemSlot = slot;
		mFromInventory = fromInventory;
		mTookLastItem = true;
		mNetworkComponent.send_TakeChest(mDBFacade.dbAccountInfo.id, mSelectedItemSlot);
		closeInfoPopup();
		mInfoPopup = new DBUIPopup(mDBFacade, "", Locale.getString("TAKING_ITEM"));
		MemoryTracker.track(mInfoPopup, "DBUIPopup - created in DistributedDungeonSummary.keepChestFromInventory()");
	}

	function openChestCallback() {
		var doesKeyExist:Bool;
		var i:Int;
		if (mDBFacade.dbAccountInfo.inventoryInfo.isThereEmptySpaceInWeaponStorage()) {
			doesKeyExist = false;
			i = 0;
			while (i < 4) {
				if (mDBFacade.dbAccountInfo.inventoryInfo.keys[i].gmKey.ChestId == mSelectedGMChest.Id
					&& mDBFacade.dbAccountInfo.inventoryInfo.keys[i].count > 0) {
					doesKeyExist = true;
				}
				i = i + 1;
			}
			if (doesKeyExist) {
				boughtKey(null);
			} else {
				mTreasureFoundPopup.visible = false;
				setupOpenKeylessChest();
			}
		} else {
			mStorageFullPopUp = new DBUITwoButtonPopup(mDBFacade, "DUNGEON_SUMMARY_STORAGE_FULL_ON_UNLOCK", Locale.getString("GO_TO_INVENTORY_TITLE"),
				Locale.getString("GO_TO_INVENTORY_BODY_OPEN"), Locale.getString("INVENTORY"), function() {
					closeStorageFullPopUp();
					closeKeyChestPopup();
					openInventory();
			}, Locale.getString("ABANDON"), function() {
					closeStorageFullPopUp();
					abandonChestCallback("abandonFromUnlockOnChestWithFullInventory");
			}, true, closeStorageFullPopUp);
			MemoryTracker.track(mStorageFullPopUp, "DBUITwoButtonPopup - created in DistributedDungeonSummary.openChestCallback()");
			mStorageFullPopUp.root.y += 180;
		}
	}

	function closeStorageFullPopUp() {
		if (mStorageFullPopUp != null) {
			mStorageFullPopUp.destroy();
			mStorageFullPopUp = null;
		}
	}

	function boughtKey(details:ASAny) {
		if (mLeaving || mWorkComponent == null || mSelectedGMChest == null) {
			return;
		}
		mDBFacade.metrics.log("ChestUnlockKey", {
			"chestId": mSelectedGMChest.Id,
			"rarity": mSelectedGMChest.Rarity,
			"category": "dungeonSummary"
		});
		closeInfoPopup();
		openChestFromInventory(mSelectedGMChest, false);
	}

	public function findSlotForChest(gmChest:GMChest):UInt {
		var _loc4_ = (0 : UInt);
		var _loc3_:GMDoober = null;
		var _loc2_:Array<ASAny> = [
			mDungeonReport[0].chest_type_1,
			mDungeonReport[0].chest_type_2,
			mDungeonReport[0].chest_type_3,
			mDungeonReport[0].chest_type_4
		];
		if (mDungeonReport[0].valid == ASCompat.toNumber(true)) {
			_loc4_ = (0 : UInt);
			while (_loc4_ < 4) {
				if (ASCompat.toNumber(_loc2_[(_loc4_ : Int)]) != 0) {
					_loc3_ = ASCompat.coerce(mDBFacade.gameMaster.dooberById.itemFor(_loc2_[(_loc4_ : Int)]), gameMasterDictionary.GMDoober);
					if (_loc3_.ChestId == gmChest.Id) {
						return _loc4_;
					}
				}
				_loc4_++;
			}
		}
		return (0 : UInt);
	}

	public function openChestFromInventory(gmChest:GMChest, fromInventory:Bool) {
		var _loc3_ = findSlotForChest(gmChest);
		mFromInventory = fromInventory;
		mTookLastItem = false;
		mNetworkComponent.send_OpenChest(mDBFacade.dbAccountInfo.id, _loc3_);
		mSceneGraphComponent.fadeOut(0.5, 0.75);
		if (fromInventory) {
			mChestRevealPopUp = new ChestRevealPopUp(mDBFacade, gmChest, closeChestRevealPopUp, equipItemFromInventory);
		} else {
			mChestRevealPopUp = new ChestRevealPopUp(mDBFacade, gmChest, closeChestRevealPopUp, goToStorageChestRevealPopUp);
		}
		removeItemFromSlot(_loc3_);
		if (mTreasureFoundPopup != null) {
			closeKeyChestPopup();
		}
	}

	function equipItemFromInventory(itemType:UInt, itemOfferId:UInt, callEquip:Bool) {
		mSceneGraphComponent.fadeIn(0.5);
		if (mChestRevealPopUp != null) {
			mChestRevealPopUp.destroy();
			mChestRevealPopUp = null;
		}
		mUIInventory.setRevealedState(itemType, itemOfferId, callEquip);
		mUIInventory.refresh();
	}

	function goToStorageChestRevealPopUp(itemType:UInt, itemOfferId:UInt, callEquip:Bool) {
		mRevealedItemType = itemType;
		mRevealedItemOfferId = itemOfferId;
		mRevealedItemCallEquip = callEquip;
		mSceneGraphComponent.fadeIn(0.5);
		if (mChestRevealPopUp != null) {
			mChestRevealPopUp.destroy();
			mChestRevealPopUp = null;
		}
		openInventory();
	}

	function boughtKeyError(err:ASAny) {
		Logger.warn("Error buying keys from Reward Screen");
	}

	function closeChestRevealPopUp(itemType:UInt, itemOfferId:UInt, updateInventory:Bool) {
		mRevealedItemType = itemType;
		mRevealedItemOfferId = itemOfferId;
		mSceneGraphComponent.fadeIn(0.5);
		if (mChestRevealPopUp != null) {
			mChestRevealPopUp.destroy();
			mChestRevealPopUp = null;
		}
		if (!mFromInventory) {
			loadNextChestPopUp();
		} else if (updateInventory) {
			mUIInventory.setRevealedState(mRevealedItemType, mRevealedItemOfferId);
			mUIInventory.refresh();
		}
	}

	function closeInfoPopup() {
		if (mInfoPopup == null) {
			return;
		}
		if (mSceneGraphComponent != null) {
			mSceneGraphComponent.removeChild(mInfoPopup.root);
		}
		mInfoPopup.destroy();
		mInfoPopup = null;
	}

	function closeKeyChestPopup() {
		if (mTreasureFoundPopup != null) {
			mTreasureFoundPopup.destroy();
			mTreasureFoundPopup = null;
		}
	}

	function closeKeylessChestPopup() {
		if (mChestBuyKeysPopUp != null) {
			mChestBuyKeysPopUp.destroy();
			mChestBuyKeysPopUp = null;
		}
		if (mTreasureFoundPopup != null) {
			mTreasureFoundPopup.visible = true;
		}
	}

	function chatCallback(playerIndex:UInt):ASFunction {
		return function(param1:ChatEvent) {
			var event = param1;
			mChatBalloon[(playerIndex : Int)].showBalloon();
			mChatBalloon[(playerIndex : Int)].text = event.message;
			if (mChatCloseTask[(playerIndex : Int)] != null) {
				mChatCloseTask[(playerIndex : Int)].destroy();
			}
			mChatCloseTask[(playerIndex : Int)] = mWorkComponent.doLater(5, function() {
				mChatBalloon[(playerIndex : Int)].hideBalloon();
			});
		};
	}

	function typingCallback(playerIndex:UInt):ASFunction {
		return function(param1:events.PlayerIsTypingEvent) {
			if (param1.subtype == "CHAT_BOX_FOCUS_IN") {
				mChatBalloon[(playerIndex : Int)].showPlayerTyping();
			} else {
				mChatBalloon[(playerIndex : Int)].hidePlayerTyping();
			}
		};
	}

	function setupChat() {
		var button:MovieClip;
		var c:Int;
		var i = (0 : UInt);
		while (i < 4) {
			if (mDungeonReport[(i : Int)].valid != 0) {
				mChatBalloon[(i : Int)] = new ChatBalloon();
				mChatBalloon[(i : Int)].hideBalloon();
				mChatEventComponent.addListener(GameObjectEvent.uniqueEvent("ChatEvent_INCOMING_CHAT_UPDATE", mDungeonReport[(i : Int)].id), chatCallback(i));
				mChatEventComponent.addListener(GameObjectEvent.uniqueEvent("PLAYER_IS_TYPING", mDungeonReport[(i : Int)].id), typingCallback(i));
			}
			i = i + 1;
		}
		UIChatLog.growLogUp(ASCompat.coerce((mScoreReportRoot : ASAny).chatLogContainer, flash.display.MovieClip), 1.5);
		final __ax4_iter_312:Array<ASAny> = [
			(mScoreReportRoot : ASAny)
			.UI_chat.chat_btn,
			(mScoreReportRoot : ASAny)
			.UI_chat.log_btn
		];
		if (checkNullIteratee(__ax4_iter_312))
			for (_tmp_ in __ax4_iter_312) {
				button = ASCompat.coerce(_tmp_, flash.display.MovieClip);
				c = 0;
				while (c < button.numChildren) {
					if (!Std.isOfType(button.getChildAt(c), TextField)) {
						button.getChildAt(c).scaleY = button.getChildAt(c).scaleY * 1.25;
					}
					c = c + 1;
				}
			}
		mUIChatLog = new UIChatLog(mDBFacade, ASCompat.coerce((mScoreReportRoot : ASAny).chatLogContainer, flash.display.MovieClip),
			ASCompat.coerce((mScoreReportRoot : ASAny).UI_chat, flash.display.MovieClip),
			ASCompat.coerce((mScoreReportRoot : ASAny).UI_chat.log_btn, flash.display.MovieClip),
			ASCompat.coerce((mScoreReportRoot : ASAny).UI_chat.chat_btn, flash.display.MovieClip));
		mUIChatLog.textSizeModifier = 1.55;
		mUIChatLog.hideChatLog();
		mUIChatLog.setChatPromptVisible(!mDBFacade.steamInputManager.wantsControllerPrompts);
		mChatEventComponent.addListener("ControllerConnectionChangedEvent", function(param1:Event) {
			if (mUIChatLog != null) {
				mUIChatLog.setChatPromptVisible(!mDBFacade.steamInputManager.wantsControllerPrompts);
			}
		});
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_nametag.swf"), function(param1:SwfAsset) {
			var _loc3_:Dynamic = null;
			var _loc2_:MovieClip = null;
			var _loc6_:Dynamic = null;
			var _loc5_:Point = null;
			var _loc4_:Array<ASAny> = [
				(mScoreReportRoot : ASAny)
				.stats_a,
				(mScoreReportRoot : ASAny)
				.stats_b,
				(mScoreReportRoot : ASAny)
				.stats_c,
				(mScoreReportRoot : ASAny)
				.stats_d
			];
			i = (0 : UInt);
			while (i < 4) {
				if (mDungeonReport[(i : Int)].valid != 0) {
					_loc3_ = param1.getClass("UI_speechbubble");
					_loc2_ = ASCompat.coerce(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
					_loc2_.visible = false;
					_loc6_ = param1.getClass("UI_speechbubble_typing");
					mPlayerIsTypingNotification = ASCompat.coerce(ASCompat.createInstance(_loc6_, []), flash.display.MovieClip);
					mPlayerIsTypingNotification.visible = false;
					mChatBalloon[(i : Int)].initializeChatBalloon(param1, mPlayerIsTypingNotification, 1.47);
					mChatBalloon[(i : Int)].growsDown = true;
					mSceneGraphComponent.addChild(mChatBalloon[(i : Int)], (50 : UInt));
					mChatBalloon[(i : Int)].text = "";
					_loc5_ = mDBFacade.designLocalToGlobal(ASCompat.coerce(_loc4_[(i : Int)].stats.player_name, flash.display.DisplayObject), new Point(0, 0));
					mChatBalloon[(i : Int)].scaleY = mChatBalloon[(i : Int)].scaleX = 1.8;
					mChatBalloon[(i : Int)].x = _loc5_.x + 69 + 55;
					mChatBalloon[(i : Int)].y = _loc5_.y + 32 - 32;
					mChatBalloon[(i : Int)].hideBalloon();
				}
				i = i + 1;
			}
		});
	}

	function sendChat(value:String) {
		mDBFacade.regainFocus();
		if (ASCompat.stringAsBool(value)) {
			mChatBalloon[0].showBalloon();
			mChatBalloon[0].text = value;
			if (mChatCloseTask[0] != null) {
				mChatCloseTask[0].destroy();
			}
			mChatCloseTask[0] = mWorkComponent.doLater(5, function() {
				mChatBalloon[0].hideBalloon();
			});
			mEventComponent.dispatchEvent(new ChatEvent("ChatEvent_OUTGOING_CHAT_UPDATE", (0 : UInt), value));
		}
	}

	function removeItemFromSlot(slot:UInt) {
		var _loc3_ = (0 : UInt);
		var _loc5_ = slot;
		_loc3_ = (0 : UInt);
		while (_loc3_ < (mSortedLootData.length:UInt)) {
			if (ASCompat.toNumber(ASCompat.dynGetIndex(mSortedLootData[(_loc3_ : Int)], 0)) == slot) {
				_loc5_ = _loc3_;
			}
			_loc3_++;
		}
		var _loc4_ = (0 : UInt);
		switch (slot) {
			case 0:
				_loc4_ = mDungeonReport[0].chest_type_1;
				mDungeonReport[0].chest_type_1 = (0 : UInt);

			case 1:
				_loc4_ = mDungeonReport[0].chest_type_2;
				mDungeonReport[0].chest_type_2 = (0 : UInt);

			case 2:
				_loc4_ = mDungeonReport[0].chest_type_3;
				mDungeonReport[0].chest_type_3 = (0 : UInt);

			case 3:
				_loc4_ = mDungeonReport[0].chest_type_4;
				mDungeonReport[0].chest_type_4 = (0 : UInt);
		}
		if (_loc4_ == 0) {
			return;
		}
		mItemCount = mItemCount - 1;
		if (mTookLastItem) {
			mDBFacade.metrics.log("DungeonLootTookItem", {"itemId": _loc4_});
		} else {
			mDBFacade.metrics.log("DungeonLootSoldItem", {"itemId": _loc4_});
		}
		var _loc2_:Array<ASAny> = ASCompat.coerce(mUILootSlots[0], Array);
		if (isSingleChestList[0]) {
			slot = (2 : UInt);
		}
		ASCompat.setProperty(_loc2_[(_loc5_ : Int)], "visible", true);
		ASCompat.setProperty(ASCompat.dynGetIndex(mChestMovieClips[0], _loc5_), "visible", false);
		if (isSingleChestList[0]) {
			if (ASCompat.toBool(ASCompat.dynGetIndex(mItemButtons[0], 0))) {
				ASCompat.setProperty(ASCompat.dynGetIndex(mItemButtons[0], 0), "enabled", false);
			}
		} else if (ASCompat.toBool(ASCompat.dynGetIndex(mItemButtons[0], slot))) {
			ASCompat.setProperty(ASCompat.dynGetIndex(mItemButtons[0], slot), "enabled", false);
		}
	}

	function hideBanners() {
		ASCompat.setProperty((mScoreReportRoot : ASAny).stats_a, "visible", false);
		ASCompat.setProperty((mScoreReportRoot : ASAny).stats_b, "visible", false);
		ASCompat.setProperty((mScoreReportRoot : ASAny).stats_c, "visible", false);
		ASCompat.setProperty((mScoreReportRoot : ASAny).stats_d, "visible", false);
		ASCompat.setProperty((mScoreReportRoot : ASAny).empty_banner_b, "visible", false);
		ASCompat.setProperty((mScoreReportRoot : ASAny).empty_banner_c, "visible", false);
		ASCompat.setProperty((mScoreReportRoot : ASAny).empty_banner_d, "visible", false);
		if (mCurrentMapNode.InfiniteDungeon != null) {
			ASCompat.setProperty((mScoreReportRoot : ASAny).banner_deco01, "visible", false);
			ASCompat.setProperty((mScoreReportRoot : ASAny).banner_deco02, "visible", false);
		}
	}

	function updateBannerAlpha(clock:GameClock) {
		var _loc2_ = 1 - ASCompat.toNumberField((mScoreReportRoot : ASAny).stats_a, "alpha");
		_loc2_ = 1 - _loc2_ * _loc2_;
		ASCompat.setProperty((mScoreReportRoot : ASAny).stats_a, "alpha", _loc2_);
		ASCompat.setProperty((mScoreReportRoot : ASAny).stats_b, "alpha", _loc2_);
		ASCompat.setProperty((mScoreReportRoot : ASAny).stats_c, "alpha", _loc2_);
		ASCompat.setProperty((mScoreReportRoot : ASAny).stats_d, "alpha", _loc2_);
		ASCompat.setProperty((mScoreReportRoot : ASAny).empty_banner_b, "alpha", _loc2_);
		ASCompat.setProperty((mScoreReportRoot : ASAny).empty_banner_c, "alpha", _loc2_);
		ASCompat.setProperty((mScoreReportRoot : ASAny).empty_banner_d, "alpha", _loc2_);
		if (mCurrentMapNode.InfiniteDungeon != null) {
			ASCompat.setProperty((mScoreReportRoot : ASAny).banner_deco02, "alpha", _loc2_);
			ASCompat.setProperty((mScoreReportRoot : ASAny).banner_deco01, "alpha", _loc2_);
		}
		if (ASCompat.toNumberField((mScoreReportRoot : ASAny).stats_a, "alpha") >= 0.95) {
			ASCompat.setProperty((mScoreReportRoot : ASAny).stats_a, "alpha", 1);
			ASCompat.setProperty((mScoreReportRoot : ASAny).stats_b, "alpha", 1);
			ASCompat.setProperty((mScoreReportRoot : ASAny).stats_c, "alpha", 1);
			ASCompat.setProperty((mScoreReportRoot : ASAny).stats_d, "alpha", 1);
			ASCompat.setProperty((mScoreReportRoot : ASAny).empty_banner_b, "alpha", 1);
			ASCompat.setProperty((mScoreReportRoot : ASAny).empty_banner_c, "alpha", 1);
			ASCompat.setProperty((mScoreReportRoot : ASAny).empty_banner_d, "alpha", 1);
			if (mCurrentMapNode.InfiniteDungeon != null) {
				ASCompat.setProperty((mScoreReportRoot : ASAny).banner_deco02, "alpha", 1);
				ASCompat.setProperty((mScoreReportRoot : ASAny).banner_deco01, "alpha", 1);
			}
			mBannerFadeTask.destroy();
			mBannerFadeTask = null;
		}
	}

	function revealBanners(clock:GameClock) {
		ASCompat.setProperty((mScoreReportRoot : ASAny).stats_a, "visible", mDungeonReport[0].valid);
		ASCompat.setProperty((mScoreReportRoot : ASAny).stats_b, "visible", mDungeonReport[1].valid);
		ASCompat.setProperty((mScoreReportRoot : ASAny).stats_c, "visible", mDungeonReport[2].valid);
		ASCompat.setProperty((mScoreReportRoot : ASAny).stats_d, "visible", mDungeonReport[3].valid);
		ASCompat.setProperty((mScoreReportRoot : ASAny).empty_banner_b, "visible", mDungeonReport[1].valid == 0);
		ASCompat.setProperty((mScoreReportRoot : ASAny).empty_banner_c, "visible", mDungeonReport[2].valid == 0);
		ASCompat.setProperty((mScoreReportRoot : ASAny).empty_banner_d, "visible", mDungeonReport[3].valid == 0);
		ASCompat.setProperty((mScoreReportRoot : ASAny).stats_a, "alpha", 0.05);
		ASCompat.setProperty((mScoreReportRoot : ASAny).stats_b, "alpha", 0.05);
		ASCompat.setProperty((mScoreReportRoot : ASAny).stats_c, "alpha", 0.05);
		ASCompat.setProperty((mScoreReportRoot : ASAny).stats_d, "alpha", 0.05);
		ASCompat.setProperty((mScoreReportRoot : ASAny).empty_banner_b, "alpha", 0.05);
		ASCompat.setProperty((mScoreReportRoot : ASAny).empty_banner_c, "alpha", 0.05);
		ASCompat.setProperty((mScoreReportRoot : ASAny).empty_banner_d, "alpha", 0.05);
		if (mCurrentMapNode.InfiniteDungeon != null) {
			ASCompat.setProperty((mScoreReportRoot : ASAny).banner_deco01, "visible", true);
			ASCompat.setProperty((mScoreReportRoot : ASAny).banner_deco02, "visible", true);
			ASCompat.setProperty((mScoreReportRoot : ASAny).banner_deco01, "alpha", 0.05);
			ASCompat.setProperty((mScoreReportRoot : ASAny).banner_deco02, "alpha", 0.05);
		}
		if (mBannerFadeTask != null) {
			mBannerFadeTask.destroy();
			mBannerFadeTask = null;
		}
		mBannerFadeTask = mWorkComponent.doEveryFrame(updateBannerAlpha);
	}

	function onPlayerExit(event:PlayerExitEvent) {
		var _loc6_ = (0 : UInt);
		var _loc3_ = Math.NaN;
		var _loc5_ = Math.NaN;
		var _loc4_ = Math.NaN;
		var _loc8_:Array<ASAny> = null;
		var _loc7_:Array<ASAny> = [
			(mScoreReportRoot : ASAny)
			.stats_a,
			(mScoreReportRoot : ASAny)
			.stats_b,
			(mScoreReportRoot : ASAny)
			.stats_c,
			(mScoreReportRoot : ASAny)
			.stats_d
		];
		var _loc2_:Array<ASAny> = [
			(mScoreReportRoot : ASAny)
			.empty_banner_b,
			(mScoreReportRoot : ASAny)
			.empty_banner_b,
			(mScoreReportRoot : ASAny)
			.empty_banner_c,
			(mScoreReportRoot : ASAny)
			.empty_banner_d
		];
		_loc6_ = (0 : UInt);
		while (_loc6_ < 4) {
			if (mDungeonReport[(_loc6_ : Int)].valid != 0 && mDungeonReport[(_loc6_ : Int)].id == event.id) {
				_loc3_ = 0.212671;
				_loc5_ = 0.71516;
				_loc4_ = 0.072169;
				_loc8_ = [];
				_loc8_ = _loc8_.concat([_loc3_, _loc5_, _loc4_, 0, 0]);
				_loc8_ = _loc8_.concat([_loc3_, _loc5_, _loc4_, 0, 0]);
				_loc8_ = _loc8_.concat([_loc3_, _loc5_, _loc4_, 0, 0]);
				_loc8_ = _loc8_.concat([0, 0, 0, 1, 0]);
				ASCompat.setProperty(_loc7_[(_loc6_ : Int)], "filters", [new ColorMatrixFilter(cast(_loc8_))]);
			}
			_loc6_++;
		}
	}

	function failureScoreReportSwfLoaded(swfAsset:SwfAsset) {
		var _loc2_ = swfAsset.getClass("DRfriends_UI_score_report_defeat");
		mScoreReportRoot = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), MovieClip);
		mUILootSlotsTwoTreasures = [
			[
				(mScoreReportRoot : ASAny)
				.stats_a.stats.treasure.loot_slot_A1,
				(mScoreReportRoot : ASAny)
				.stats_a.stats.treasure.loot_slot_A2,
				(mScoreReportRoot : ASAny)
				.stats_a.stats.treasure.loot_slot_A3
			],
			[
				(mScoreReportRoot : ASAny)
				.stats_b.stats.treasure.loot_slot_A1,
				(mScoreReportRoot : ASAny)
				.stats_b.stats.treasure.loot_slot_A2,
				(mScoreReportRoot : ASAny)
				.stats_b.stats.treasure.loot_slot_A3
			],
			[
				(mScoreReportRoot : ASAny)
				.stats_c.stats.treasure.loot_slot_A1,
				(mScoreReportRoot : ASAny)
				.stats_c.stats.treasure.loot_slot_A2,
				(mScoreReportRoot : ASAny)
				.stats_c.stats.treasure.loot_slot_A3
			],
			[
				(mScoreReportRoot : ASAny)
				.stats_d.stats.treasure.loot_slot_A1,
				(mScoreReportRoot : ASAny)
				.stats_d.stats.treasure.loot_slot_A2,
				(mScoreReportRoot : ASAny)
				.stats_d.stats.treasure.loot_slot_A3
			]
		];
		mUILootSlotsFourTreasures = [
			[
				(mScoreReportRoot : ASAny)
				.stats_a.stats.treasure.loot_slot_B1,
				(mScoreReportRoot : ASAny)
				.stats_a.stats.treasure.loot_slot_B2,
				(mScoreReportRoot : ASAny)
				.stats_a.stats.treasure.loot_slot_B3,
				(mScoreReportRoot : ASAny)
				.stats_a.stats.treasure.loot_slot_B4
			],
			[
				(mScoreReportRoot : ASAny)
				.stats_b.stats.treasure.loot_slot_B1,
				(mScoreReportRoot : ASAny)
				.stats_b.stats.treasure.loot_slot_B2,
				(mScoreReportRoot : ASAny)
				.stats_b.stats.treasure.loot_slot_B3,
				(mScoreReportRoot : ASAny)
				.stats_b.stats.treasure.loot_slot_B4
			],
			[
				(mScoreReportRoot : ASAny)
				.stats_c.stats.treasure.loot_slot_B1,
				(mScoreReportRoot : ASAny)
				.stats_c.stats.treasure.loot_slot_B2,
				(mScoreReportRoot : ASAny)
				.stats_c.stats.treasure.loot_slot_B3,
				(mScoreReportRoot : ASAny)
				.stats_c.stats.treasure.loot_slot_B4
			],
			[
				(mScoreReportRoot : ASAny)
				.stats_d.stats.treasure.loot_slot_B1,
				(mScoreReportRoot : ASAny)
				.stats_d.stats.treasure.loot_slot_B2,
				(mScoreReportRoot : ASAny)
				.stats_d.stats.treasure.loot_slot_B3,
				(mScoreReportRoot : ASAny)
				.stats_d.stats.treasure.loot_slot_B4
			]
		];
		setupUI();
	}

	function successScoreReportSwfLoaded(swfAsset:SwfAsset) {
		var _loc2_:Dynamic = null;
		mDBFacade.metrics.log("DungeonLootSummary");
		if (mCurrentMapNode.InfiniteDungeon != null) {
			_loc2_ = swfAsset.getClass("UI_score_report_infinite_island");
		} else {
			_loc2_ = swfAsset.getClass("DRfriends_UI_score_report");
		}
		mScoreReportRoot = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), MovieClip);
		mUILootSlotsTwoTreasures = [
			[
				(mScoreReportRoot : ASAny)
				.stats_a.stats.treasure.loot_slot_A1,
				(mScoreReportRoot : ASAny)
				.stats_a.stats.treasure.loot_slot_A2,
				(mScoreReportRoot : ASAny)
				.stats_a.stats.treasure.loot_slot_A3
			],
			[
				(mScoreReportRoot : ASAny)
				.stats_b.stats.treasure.loot_slot_A1,
				(mScoreReportRoot : ASAny)
				.stats_b.stats.treasure.loot_slot_A2,
				(mScoreReportRoot : ASAny)
				.stats_b.stats.treasure.loot_slot_A3
			],
			[
				(mScoreReportRoot : ASAny)
				.stats_c.stats.treasure.loot_slot_A1,
				(mScoreReportRoot : ASAny)
				.stats_c.stats.treasure.loot_slot_A2,
				(mScoreReportRoot : ASAny)
				.stats_c.stats.treasure.loot_slot_A3
			],
			[
				(mScoreReportRoot : ASAny)
				.stats_d.stats.treasure.loot_slot_A1,
				(mScoreReportRoot : ASAny)
				.stats_d.stats.treasure.loot_slot_A2,
				(mScoreReportRoot : ASAny)
				.stats_d.stats.treasure.loot_slot_A3
			]
		];
		mUILootSlotsFourTreasures = [
			[
				(mScoreReportRoot : ASAny)
				.stats_a.stats.treasure.loot_slot_B1,
				(mScoreReportRoot : ASAny)
				.stats_a.stats.treasure.loot_slot_B2,
				(mScoreReportRoot : ASAny)
				.stats_a.stats.treasure.loot_slot_B3,
				(mScoreReportRoot : ASAny)
				.stats_a.stats.treasure.loot_slot_B4
			],
			[
				(mScoreReportRoot : ASAny)
				.stats_b.stats.treasure.loot_slot_B1,
				(mScoreReportRoot : ASAny)
				.stats_b.stats.treasure.loot_slot_B2,
				(mScoreReportRoot : ASAny)
				.stats_b.stats.treasure.loot_slot_B3,
				(mScoreReportRoot : ASAny)
				.stats_b.stats.treasure.loot_slot_B4
			],
			[
				(mScoreReportRoot : ASAny)
				.stats_c.stats.treasure.loot_slot_B1,
				(mScoreReportRoot : ASAny)
				.stats_c.stats.treasure.loot_slot_B2,
				(mScoreReportRoot : ASAny)
				.stats_c.stats.treasure.loot_slot_B3,
				(mScoreReportRoot : ASAny)
				.stats_c.stats.treasure.loot_slot_B4
			],
			[
				(mScoreReportRoot : ASAny)
				.stats_d.stats.treasure.loot_slot_B1,
				(mScoreReportRoot : ASAny)
				.stats_d.stats.treasure.loot_slot_B2,
				(mScoreReportRoot : ASAny)
				.stats_d.stats.treasure.loot_slot_B3,
				(mScoreReportRoot : ASAny)
				.stats_d.stats.treasure.loot_slot_B4
			]
		];
		setupUI();
	}

	function addFriendCallback(button:UIButton, idx:UInt):ASFunction {
		return function() {
			findCorrectIcon(mDungeonReport[(idx : Int)], addFriend, button, idx);
		};
	}

	function blockFriendCallback(button:UIButton, idx:UInt):ASFunction {
		return function() {
			findCorrectIcon(mDungeonReport[(idx : Int)], blockFriend, button, idx);
		};
	}

	function reportPlayerCallback(button:UIButton, idx:UInt):ASFunction {
		return function() {
			findCorrectIcon(mDungeonReport[(idx : Int)], createReportPlayerPopup, button, idx);
		};
	}

	function findCorrectIcon(DR:DungeonReport, callBackFunc:ASFunction, button:UIButton, playerIndex:UInt) {
		var iconContainer = new MovieClip();
		var skin = mDBFacade.gameMaster.getSkinByType(DR.skin_type);
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(skin.UISwfFilepath), function(param1:SwfAsset) {
			var _loc3_ = param1.getClass(skin.IconName);
			var _loc2_ = ASCompat.coerce(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
			UIObject.scaleToFit(_loc2_, 65);
			iconContainer.addChild(_loc2_);
			loadSteamAvatar(DR.id, iconContainer);
			callBackFunc(DR.name, iconContainer, DR.id, button, playerIndex);
		});
	}

	function fadeAwayTitle() {
		mDBFacade.mTween.tweenMaxTo(mBgRenderer.clip, 1, {
			"alpha": 0,
			"onComplete": killFadeAwayTitle
		});
	}

	function killFadeAwayTitle() {
		if (mScoreReportRoot == null || mBgRenderer == null) {
			return;
		}
		ASCompat.setProperty((mScoreReportRoot : ASAny).bg, "visible", false);
		mBgRenderer.destroy();
		mBgRenderer = null;
	}

	function setupUI() {
		var movieClipRenderer:MovieClipRenderController;
		var panel_idx:Array<ASAny>;
		var stats_panels:Array<ASAny>;
		var invInfo:DBInventoryInfo;
		var i:UInt;
		var teamBonusUI:UIObject;
		var xpBoosterUI:UIObject;
		var goldBoosterUI:UIObject;
		var titleText:String;
		if (mDBFacade.hud != null) {
			mDBFacade.hud.hideStacks();
		}
		mBgRenderer = new MovieClipRenderController(mDBFacade, ASCompat.coerce((mScoreReportRoot : ASAny).bg, flash.display.MovieClip));
		mBgRenderer.play();
		movieClipRenderer = new MovieClipRenderController(mDBFacade, ASCompat.coerce((mScoreReportRoot : ASAny).rays, flash.display.MovieClip));
		movieClipRenderer.play();
		mSceneGraphComponent.addChild(mScoreReportRoot, (50 : UInt));
		setupPortraits();
		panel_idx = [0, 1, 2, 3];
		stats_panels = [
			(mScoreReportRoot : ASAny)
			.stats_a,
			(mScoreReportRoot : ASAny)
			.stats_b,
			(mScoreReportRoot : ASAny)
			.stats_c,
			(mScoreReportRoot : ASAny)
			.stats_d
		];
		mAddFriendButtons = [];
		mBlockFriendButtons = [];
		mReportPlayerButtons = [];
		mItemButtons = [];
		invInfo = mDBFacade.dbAccountInfo.inventoryInfo;
		mBoosterXP = invInfo.findHighestBoosterXP();
		mBoosterGold = invInfo.findHighestBoosterGold();
		i = (0 : UInt);
		while (i < 4) {
			isSingleChestList[(i : Int)] = mCurrentMapNode.MinTreasure == 1 && mDungeonReport[(i : Int)].receivedTrophy == 0;
			isSingleChestList[(i : Int)] = false;
			if (((mDungeonReport[(i : Int)].account_flags : Int) & 1) != 0) {
				ASCompat.setProperty(stats_panels[(i : Int)].pennant, "visible", false);
			}
			if (isSingleChestList[(i : Int)]) {
				ASCompat.setProperty(stats_panels[(i : Int)].stats.treasure.loot_slot_A1, "visible", false);
				ASCompat.setProperty(stats_panels[(i : Int)].stats.treasure.loot_slot_A2, "visible", false);
				ASCompat.setProperty(stats_panels[(i : Int)].stats.treasure.loot_slot_A3, "visible", true);
			} else {
				ASCompat.setProperty(stats_panels[(i : Int)].stats.treasure.loot_slot_A1, "visible", true);
				ASCompat.setProperty(stats_panels[(i : Int)].stats.treasure.loot_slot_A2, "visible", true);
				ASCompat.setProperty(stats_panels[(i : Int)].stats.treasure.loot_slot_A3, "visible", false);
			}
			Locale.setText(ASCompat.coerce(stats_panels[(i : Int)].stats.xp_bar.bonus_xp_reveal.Bonus_XP, flash.text.TextField), "SUMMARY_BONUS_XP");
			Locale.setText(ASCompat.coerce(stats_panels[(i : Int)].stats.kills.enemies_killed_reveal.Enemies_Killed, flash.text.TextField),
				"SUMMARY_ENEMIES_KILLED");
			Locale.setText(ASCompat.coerce(stats_panels[(i : Int)].stats.treasure.treasure_text, flash.text.TextField), "SUMMARY_TREASURE");
			if (i == 0) {
				Locale.setText(ASCompat.coerce(stats_panels[(i : Int)].stats.text_booster, flash.text.TextField), "ACTIVE_BOOSTERS");
				ASCompat.setProperty(stats_panels[(i : Int)].stats.text_booster, "visible", false);
				if (mBoosterXP != null) {
					mXPBoosterUI = new UIObject(mDBFacade, ASCompat.coerce(stats_panels[(i : Int)].stats.boosterXP, flash.display.MovieClip));
					ASCompat.dynPush(mPlayerBoosterUIs[(i : Int)], mXPBoosterUI);
					TextUtil.setText(ASCompat.coerce(stats_panels[(i : Int)].stats.boosterXP.label, flash.text.TextField), mBoosterXP.BuffInfo.Exp + "X");
					TextUtil.setText(ASCompat.coerce(stats_panels[(i : Int)].stats.boosterXP.tooltip.title_label, flash.text.TextField),
						mBoosterXP.StackInfo.Name);
					ASCompat.setProperty(stats_panels[(i : Int)].stats.boosterXP, "visible", true);
					mCountDownTextXP = new CountdownTextTimer(ASCompat.coerce((mXPBoosterUI.tooltip : ASAny).time_label, flash.text.TextField),
						mBoosterXP.getEndDate(), GameClock.getWebServerDate, null, Locale.getString("BOOSTER_REMAINING"), "", Locale.getString("EXPIRED"));
					mCountDownTextXP.start();
					ASCompat.setProperty(stats_panels[(i : Int)].stats.text_booster, "visible", true);
				} else {
					ASCompat.setProperty(stats_panels[(i : Int)].stats.boosterXP, "visible", false);
				}
				if (mBoosterGold != null) {
					mCoinBoosterUI = new UIObject(mDBFacade, ASCompat.coerce(stats_panels[(i : Int)].stats.boosterCoin, flash.display.MovieClip));
					ASCompat.dynPush(mPlayerBoosterUIs[(i : Int)], mCoinBoosterUI);
					TextUtil.setText(ASCompat.coerce(stats_panels[(i : Int)].stats.boosterCoin.label, flash.text.TextField), mBoosterGold.BuffInfo.Gold + "X");
					TextUtil.setText(ASCompat.coerce(stats_panels[(i : Int)].stats.boosterCoin.tooltip.title_label, flash.text.TextField),
						mBoosterGold.StackInfo.Name);
					ASCompat.setProperty(stats_panels[(i : Int)].stats.boosterCoin, "visible", true);
					mCountDownTextGold = new CountdownTextTimer(ASCompat.coerce((mCoinBoosterUI.tooltip : ASAny).time_label, flash.text.TextField),
						mBoosterGold.getEndDate(), GameClock.getWebServerDate, null, Locale.getString("BOOSTER_REMAINING"), "", Locale.getString("EXPIRED"));
					mCountDownTextGold.start();
					ASCompat.setProperty(stats_panels[(i : Int)].stats.text_booster, "visible", true);
				} else {
					ASCompat.setProperty(stats_panels[(i : Int)].stats.boosterCoin, "visible", false);
				}
			}
			mTeamBonusUI.add(i, new UIObject(mDBFacade, ASCompat.coerce(stats_panels[(i : Int)].stats.crewbonus, flash.display.MovieClip)));
			teamBonusUI = ASCompat.coerce(mTeamBonusUI.itemFor(i), brain.uI.UIObject);
			Locale.setText(ASCompat.coerce((teamBonusUI.root : ASAny).header_crew_bonus_txt1, flash.text.TextField), "TEAM_BONUS_TITLE_CREW", null, 0.82);
			Locale.setText(ASCompat.coerce((teamBonusUI.root : ASAny).header_crew_bonus_txt2, flash.text.TextField), "TEAM_BONUS_TITLE_BONUS", null, 0.82);
			Locale.setText(ASCompat.coerce((teamBonusUI.tooltip : ASAny).title_label, flash.text.TextField), "TEAM_BONUS_TOOLTIP_TITLE");
			Locale.setText(ASCompat.coerce((teamBonusUI.tooltip : ASAny).description_label, flash.text.TextField), "TEAM_BONUS_TOOLTIP_DESCRIPTION");
			TextUtil.setText(ASCompat.coerce((teamBonusUI.root : ASAny).header_crew_bonus_number, flash.text.TextField),
				Std.string((mDungeonReport[(i : Int)].totalAvatarsOwned : Float) - 1), 0.73);
			TextUtil.setText(ASCompat.coerce((teamBonusUI.root : ASAny).xp, flash.text.TextField), "0");
			teamBonusUI.visible = false;
			ASCompat.setProperty(stats_panels[(i : Int)].stats.doublexp_effect, "visible", false);
			ASCompat.setProperty(stats_panels[(i : Int)].stats.doublexp_effect_star, "visible", false);
			ASCompat.setProperty(stats_panels[(i : Int)].stats.doublxp_effect_flash_text, "visible", false);
			if (i > 0) {
				ASCompat.setProperty(stats_panels[(i : Int)].stats.add_button, "visible", false);
				ASCompat.setProperty(stats_panels[(i : Int)].stats.report_button, "visible", false);
				ASCompat.setProperty(stats_panels[(i : Int)].stats.block_button, "visible", false);
				ASCompat.setProperty(stats_panels[(i : Int)].stats.friend_indicator_icon, "visible", false);
				ASCompat.setProperty(stats_panels[(i : Int)].stats.boosterXP, "visible", false);
				ASCompat.setProperty(stats_panels[(i : Int)].stats.boosterCoin, "visible", false);
				if (mDungeonReport[(i : Int)].boost_xp > 1) {
					xpBoosterUI = new UIObject(mDBFacade, ASCompat.coerce(stats_panels[(i : Int)].stats.boosterXP, flash.display.MovieClip));
					mBoosterInfos.push(xpBoosterUI);
					ASCompat.dynPush(mPlayerBoosterUIs[(i : Int)], xpBoosterUI);
					ASCompat.setProperty(stats_panels[(i : Int)].stats.boosterXP, "visible", true);
					TextUtil.setText(ASCompat.coerce(stats_panels[(i : Int)].stats.boosterXP.label, flash.text.TextField),
						mDungeonReport[(i : Int)].boost_xp + "X");
					Locale.setText(ASCompat.coerce(stats_panels[(i : Int)].stats.boosterXP.tooltip.title_label, flash.text.TextField),
						"BOOST_XP_SUMMARY_TITLE");
					TextUtil.setText(ASCompat.coerce(stats_panels[(i : Int)].stats.boosterXP.tooltip.time_label, flash.text.TextField),
						Locale.getString("BOOST_XP_SUMMARY_DESCRIPTION") + mDungeonReport[(i : Int)].boost_xp + "X");
				}
				if (mDungeonReport[(i : Int)].boost_gold > 1) {
					goldBoosterUI = new UIObject(mDBFacade, ASCompat.coerce(stats_panels[(i : Int)].stats.boosterCoin, flash.display.MovieClip));
					mBoosterInfos.push(goldBoosterUI);
					ASCompat.dynPush(mPlayerBoosterUIs[(i : Int)], goldBoosterUI);
					ASCompat.setProperty(stats_panels[(i : Int)].stats.boosterCoin, "visible", true);
					TextUtil.setText(ASCompat.coerce(stats_panels[(i : Int)].stats.boosterCoin.label, flash.text.TextField),
						mDungeonReport[(i : Int)].boost_gold + "X");
					Locale.setText(ASCompat.coerce(stats_panels[(i : Int)].stats.boosterCoin.tooltip.title_label, flash.text.TextField),
						"BOOST_GOLD_SUMMARY_TITLE");
					TextUtil.setText(ASCompat.coerce(stats_panels[(i : Int)].stats.boosterCoin.tooltip.time_label, flash.text.TextField),
						Locale.getString("BOOST_GOLD_SUMMARY_DESCRIPTION") + mDungeonReport[(i : Int)].boost_gold + "X");
				}
			}
			ASCompat.setProperty(stats_panels[(i : Int)].stats.friend_name, "visible", false);
			if (i > 0) {
				if (mDBFacade.dbAccountInfo.isFriend(mDungeonReport[(i : Int)].id)) {
					ASCompat.setProperty(stats_panels[(i : Int)].stats.friend_indicator_icon, "visible", true);
					ASCompat.setProperty(stats_panels[(i : Int)].stats.friend_name, "visible", true);
					TextUtil.setText(ASCompat.coerce(stats_panels[(i : Int)].stats.friend_name, flash.text.TextField), mDungeonReport[(i : Int)].name,
						Locale.summaryNameSizeModifier);
					ASCompat.setProperty(stats_panels[(i : Int)].stats.player_name, "visible", false);
				} else {
					ASCompat.setProperty(stats_panels[(i : Int)].stats.friend_indicator_icon, "visible", false);
					ASCompat.setProperty(stats_panels[(i : Int)].stats.friend_name, "visible", false);
					ASCompat.setProperty(stats_panels[(i : Int)].stats.player_name, "visible", true);
				}
				if (!ASCompat.toBool(stats_panels[(i : Int)].stats.friend_indicator_icon.visible)) {
					ASCompat.setProperty(stats_panels[(i : Int)].stats.add_button, "visible", true);
					Locale.setText(ASCompat.coerce(stats_panels[(i : Int)].stats.add_button.label, flash.text.TextField), "ADD_FRIEND");
					mAddFriendButtons[(i : Int)] = new UIButton(mDBFacade, ASCompat.coerce(stats_panels[(i : Int)].stats.add_button, flash.display.MovieClip));
					ASCompat.setProperty(mAddFriendButtons[(i : Int)], "releaseCallback",
						addFriendCallback(ASCompat.coerce(mAddFriendButtons[(i : Int)], brain.uI.UIButton), i));
					ASCompat.setProperty(stats_panels[(i : Int)].stats.block_button, "visible", true);
					Locale.setText(ASCompat.coerce(stats_panels[(i : Int)].stats.block_button.label, flash.text.TextField), "BLOCK");
					mBlockFriendButtons[(i : Int)] = new UIButton(mDBFacade,
						ASCompat.coerce(stats_panels[(i : Int)].stats.block_button, flash.display.MovieClip));
					ASCompat.setProperty(mBlockFriendButtons[(i : Int)], "releaseCallback",
						blockFriendCallback(ASCompat.coerce(mBlockFriendButtons[(i : Int)], brain.uI.UIButton), i));
					ASCompat.setProperty(stats_panels[(i : Int)].stats.report_button, "visible", true);
					Locale.setText(ASCompat.coerce(stats_panels[(i : Int)].stats.report_button.label, flash.text.TextField), "REPORT");
					mReportPlayerButtons[(i : Int)] = new UIButton(mDBFacade,
						ASCompat.coerce(stats_panels[(i : Int)].stats.report_button, flash.display.MovieClip));
					ASCompat.setProperty(mReportPlayerButtons[(i : Int)], "releaseCallback",
						reportPlayerCallback(ASCompat.coerce(mReportPlayerButtons[(i : Int)], brain.uI.UIButton), i));
				}
			}
			if (i == 0) {
				mXPBonusStarEffect = ASCompat.coerce(stats_panels[(i : Int)].stats.doublexp_effect_star, flash.display.MovieClip);
				mXPBonusBarEffect = ASCompat.coerce(stats_panels[(i : Int)].stats.doublexp_effect, flash.display.MovieClip);
				mXPBonusTextFlash = ASCompat.coerce(stats_panels[(i : Int)].stats.doublxp_effect_flash_text, flash.display.MovieClip);
				mXPBonusText = ASCompat.coerce((mXPBonusTextFlash : ASAny).doublexp_text, flash.text.TextField);
			}
			ASCompat.setProperty(stats_panels[(i : Int)], "visible", mDungeonReport[(i : Int)].valid);
			TextUtil.setText(ASCompat.coerce(stats_panels[(i : Int)].stats.kills.enemies_killed.kills, flash.text.TextField),
				Std.string(mDungeonReport[(i : Int)].kills));
			TextUtil.setText(ASCompat.coerce(stats_panels[(i : Int)].stats.xp_bar.bonus_xp.xp, flash.text.TextField), "0");
			ASCompat.setProperty(stats_panels[(i : Int)].stats.xp_bar.tooltip, "visible", false);
			mItemButtons[(i : Int)] = [];
			i = i + 1;
		}
		TextUtil.setText(ASCompat.coerce((mScoreReportRoot : ASAny).bg.banner_text.dungeon_title, flash.text.TextField),
			mDungeonName != null ? mDungeonName.toUpperCase() : "DUNGEON NAME");
		titleText = this.dungeonSuccess != 0 ? Locale.getString("VICTORY") : Locale.getString("DUNGEON_FAILED");
		if (mCurrentMapNode.InfiniteDungeon != null) {
			titleText = Locale.getString("CASHED_OUT");
		}
		TextUtil.setText(ASCompat.coerce((mScoreReportRoot : ASAny).bg.banner_text.title, flash.text.TextField), titleText);
		setupXPBars();
		setupLoot();
		setupChat();
		setupWeapons();
		mEventComponent.addListener("PlayerExitEvent_str", onPlayerExit);
		hideBanners();
		mWorkComponent.doLater(0.625, revealBanners);
		mTreasureTick = (0 : UInt);
		mRevealState = (1 : UInt);
		updateRevealState(null);
		mDungeonAchievementPanelMovieClipRenderer = new MovieClipRenderer(mDBFacade,
			ASCompat.coerce((mScoreReportRoot : ASAny).achievement, flash.display.MovieClip), destroyAchievementBossPanel);
		mDungeonAchievementPanelMovieClipRenderer.clip.visible = false;
		Locale.setText(ASCompat.coerce((mScoreReportRoot : ASAny).achievement.label.label, flash.text.TextField), "DUNGEON_SUMMARY_REWARD_PANEL_LABEL");
		if (mCurrentMapNode.InfiniteDungeon != null) {
			Locale.setText(ASCompat.coerce((mScoreReportRoot : ASAny).achievement.label_boss.label, flash.text.TextField),
				"DUNGEON_SUMMARY_REWARD_PANEL_LABEL_INFINITE");
		} else {
			Locale.setText(ASCompat.coerce((mScoreReportRoot : ASAny).achievement.label_boss.label, flash.text.TextField),
				"DUNGEON_SUMMARY_REWARD_PANEL_LABEL_BOSS");
		}
		if (mDungeonReport[0].receivedTrophy != 0) {
			mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Doobers/db_items_doobers.swf"), function(param1:SwfAsset) {
				var _loc4_:GMChest = null;
				var _loc3_:String = null;
				var _loc2_:String = null;
				var _loc5_ = mDungeonReport[0].loot_type_2 > 0 ? mDungeonReport[0].loot_type_2 : mDungeonReport[0].loot_type_1;
				if (_loc5_ != 0 && !ASCompat.stringAsBool(mCurrentMapNode.InfiniteDungeon)) {
					_loc4_ = ASCompat.coerce(mDBFacade.gameMaster.chestsById.itemFor(_loc5_), gameMasterDictionary.GMChest);
					_loc3_ = _loc4_.IconSwf;
					_loc2_ = _loc4_.IconName;
					ChestInfo.loadItemIcon(_loc3_, _loc2_,
						ASCompat.coerce((mScoreReportRoot : ASAny).achievement.chest, flash.display.DisplayObjectContainer), mDBFacade, (400 : UInt),
						(150 : UInt), mAssetLoadingComponent);
				}
			});
		}
		if (ASCompat.toBool((mScoreReportRoot : ASAny).achievement.chest)) {
			ASCompat.setProperty((mScoreReportRoot : ASAny).achievement.chest.defaultPic, "visible", false);
		}
	}

	function destroyAchievementBossPanel() {
		mDungeonAchievementPanelMovieClipRenderer.destroy();
		ASCompat.setProperty((mScoreReportRoot : ASAny).achievement, "visible", false);
	}

	function parseJson(details:ASAny):ASObject {
		var _loc2_:Array<ASAny> = null;
		var _loc4_:ASObject = null;
		var _loc3_:Vector<UInt> = /*undefined*/ null;
		if (ASCompat.getQualifiedClassName(details) == "Array") {
			_loc2_ = ASCompat.coerce(details[0], Array);
			_loc4_ = details[1];
			_loc3_ = new Vector<UInt>();
			_loc3_.push((ASCompat.toInt(_loc4_.account_id) : UInt));
			PresenceManager.instance().addFriends(_loc3_);
			mDBFacade.dbAccountInfo.addFriendCallback(_loc2_);
		} else {
			_loc4_ = (details : ASObject);
		}
		Logger.debug("friendRequest: id:" + Std.string(_loc4_.id) + " from:" + Std.string(_loc4_.account_id) + " to:" + Std.string(_loc4_.to_account_id)
			+ " state:" + Std.string(_loc4_.curr_state));
		return _loc4_;
	}

	function addFriend(personName:String, iconMC:MovieClip, personId:UInt, button:UIButton, playerIndex:UInt) {
		var rpcFunc = JSONRPCService.getFunction("DRFriendRequest", mDBFacade.rpcRoot + "friendrequests");
		var rpcSuccessCallback:ASFunction = function(param1:ASAny) {
			var _loc2_:ASObject = null;
			if (param1 == null || ASCompat.toNumberField(param1, "length") <= 0) {
				Logger.warn("Komo?");
			} else {
				_loc2_ = parseJson(param1);
				Logger.debug("Successful add friend.");
				mEventComponent.dispatchEvent(new FriendSummaryNewsFeedEvent("FRIEND_SUMMARY_NEWS_FEED_MESSAGE_EVENT",
					Locale.getString("Friend_Request_Sent_to_"), iconMC, personName));
				mDBFacade.metrics.log("DRFriendRequest", {"friendId": _loc2_.to_account_id});
				mDBFacade.steamAchievementsHelper.unlockAchievement("ADD_FRIEND");
			}
			button.enabled = false;
			if (mDBFacade.menuNavigationController.getTopUILayer() == "DISTRIBUTED_DUNGEON_SUMMARY") {
				restoreFocusAfterSocialAction(playerIndex, button);
			}
		};
		var deadFacebookIdParameter = "";
		rpcFunc(mDBFacade.dbAccountInfo.name, mDBFacade.dbAccountInfo.trophies, mDBFacade.dbAccountInfo.activeAvatarSkinId, deadFacebookIdParameter,
			mDBFacade.dbAccountInfo.id, personId, mDBFacade.demographics, mDBFacade.validationToken, rpcSuccessCallback,
			UIFriendManager.createFriendRPCErrorCallback(mDBFacade, "addFriend"));
	}

	function blockFriend(personName:String, iconMC:MovieClip, personId:UInt, button:UIButton, playerIndex:UInt) {
		var tf:TextFormat;
		var rpcSuccessCallback:ASFunction = function(param1:ASAny) {
			var _loc2_:String = null;
			if (param1 == null || ASCompat.toNumberField(param1, "length") <= 0) {
				Logger.warn("Komo?");
			} else {
				Logger.debug("Successful block friend");
				mEventComponent.dispatchEvent(new FriendSummaryNewsFeedEvent("FRIEND_SUMMARY_NEWS_FEED_MESSAGE_EVENT", Locale.getString("_has_been_blocked"),
					iconMC, personName, true));
				_loc2_ = param1;
				mDBFacade.metrics.log("DRFriendIgnore", {"friendId": _loc2_.substr(1, _loc2_.length - 2)});
			}
		};
		mDRFriendBlockPopup = new DBUITwoButtonPopup(mDBFacade, "DUNGEON_SUMMARY_BLOCK_PLAYER", Locale.getString("BLOCK")
			+ " "
			+ personName
			+ "?",
			personName
			+ Locale.getString("VICTORY_SCREEN_BLOCK_POPUP_MESSAGE"), Locale.getString("BLOCK"), function() {
				var _loc1_ = JSONRPCService.getFunction("IgnoreFriend", mDBFacade.rpcRoot + "friendrequests");
				_loc1_(mDBFacade.dbAccountInfo.id, personId, mDBFacade.validationToken, rpcSuccessCallback);
				button.enabled = false;
				closeDRFriendBlockPopup();
				restoreFocusAfterSocialAction(playerIndex, button);
		}, Locale.getString("CANCEL"), null, true, closeDRFriendBlockPopup);
		MemoryTracker.track(mDRFriendBlockPopup, "DBUITwoButtonPopup - created in DistributedDungeonSummary.blockFriend()");
		tf = new TextFormat();
		tf.color = FriendSummaryNewsFeedEvent.FRIEND_NAME_HIGHLIGHT_COLOR;
		mDRFriendBlockPopup.colorizeMessage(tf, 0, personName.length);
	}

	function closeDRFriendBlockPopup() {
		if (mDRFriendBlockPopup != null) {
			mDRFriendBlockPopup.destroy();
			mDRFriendBlockPopup = null;
		}
	}

	function buildMatchPlayers():Array<ASAny> {
		var _loc1_ = 0;
		var _loc2_:Array<ASAny> = [];
		_loc1_ = 0;
		while (_loc1_ < mDungeonReport.length) {
			if (mDungeonReport[_loc1_].id != 0) {
				_loc2_.push({
					"accountId": mDungeonReport[_loc1_].id,
					"heroType": mDungeonReport[_loc1_].type,
					"xp": mDungeonReport[_loc1_].xp
				});
			}
			_loc1_++;
		}
		return _loc2_;
	}

	function createReportPlayerPopup(personName:String, iconMC:MovieClip, personId:UInt, button:UIButton, playerIndex:UInt) {
		var matchPlayers = buildMatchPlayers();
		mDRReportPlayerPopup = new UIReportPopup(mDBFacade, personName, personId, matchPlayers, function() {
			if (button != null) {
				button.enabled = false;
			}
		}, function(param1:ASAny) {
			if (param1 != null && ASCompat.toNumberField(param1, "length") > 0) {
				mEventComponent.dispatchEvent(new FriendSummaryNewsFeedEvent("FRIEND_SUMMARY_NEWS_FEED_MESSAGE_EVENT", Locale.getString("_has_been_reported"),
					iconMC, personName, true));
			}
		}, function() {
			mDRReportPlayerPopup = null;
			restoreFocusAfterSocialAction(playerIndex, button);
		});
		MemoryTracker.track(mDRReportPlayerPopup, "UIReportPopup - created in DistributedDungeonSummary.createReportPlayerPopup()");
	}

	function closeDRReportPlayerPopup() {
		if (mDRReportPlayerPopup != null) {
			mDRReportPlayerPopup.destroy();
			mDRReportPlayerPopup = null;
		}
	}

	function restoreFocusAfterSocialAction(playerIndex:UInt, usedButton:UIButton) {
		if (mAvatarButtons == null || mAddFriendButtons == null || mBlockFriendButtons == null || mReportPlayerButtons == null) {
			return;
		}
		if (usedButton == null || usedButton.canBeFocused()) {
			return;
		}
		setupMenuNavigation();
		var _loc3_ = getPlayerSocialButtons((playerIndex : Int));
		var _loc4_ = firstUIObject(_loc3_);
		if (_loc4_ == null) {
			_loc4_ = ASCompat.coerce(mAvatarButtons[(playerIndex : Int)], brain.uI.UIObject);
		}
		if (_loc4_ != null) {
			mDBFacade.menuNavigationController.setFocusedUiObject(_loc4_);
		}
	}

	override public function destroy() {
		var _loc2_:UIObject;
		var _loc6_ = 0;
		var _loc7_ = 0;
		var _loc3_:SteamAvatarHelper = null;
		var _loc5_ = (0 : UInt);
		var _loc8_ = (0 : UInt);
		if (mCountDownTextXP != null) {
			mCountDownTextXP.destroy();
		}
		if (mCountDownTextGold != null) {
			mCountDownTextGold.destroy();
		}
		var _loc4_:UIObject;
		final __ax4_iter_313 = mTeamBonusUI;
		if (checkNullIteratee(__ax4_iter_313))
			for (_tmp_ in __ax4_iter_313.iterator()) {
				_loc4_ = ASCompat.coerce(_tmp_, brain.uI.UIObject);
				_loc4_.destroy();
			}
		mTeamBonusUI = null;
		mSmashSfx = null;
		mLevelSfx = null;
		if (mChestRevealPopUp != null) {
			mChestRevealPopUp.destroy();
			mChestRevealPopUp = null;
		}
		if (mChestKeySlots != null) {
			_loc6_ = 0;
			while (_loc6_ < mChestKeySlots.length) {
				mChestKeySlots[_loc6_].destroy();
				_loc6_++;
			}
		}
		mChestKeySlots = null;
		mLogicalWorkComponent.destroy();
		mLogicalWorkComponent = null;
		mSoundComponent.destroy();
		mSoundComponent = null;
		if (mStorageFullPopUp != null) {
			mStorageFullPopUp.destroy();
			mStorageFullPopUp = null;
		}
		if (mUIInventory != null) {
			mUIInventory.destroy();
			mUIInventory = null;
		}
		_loc5_ = (0 : UInt);
		while (_loc5_ < 4) {
			_loc7_ = 0;
			while (_loc7_ < 2) {
				mSceneGraphComponent.removeChild(ASCompat.coerce(ASCompat.dynGetIndex(mChestMovieClips[(_loc5_ : Int)], _loc7_), flash.display.DisplayObject));
				_loc7_++;
			}
			_loc5_++;
		}
		mChestMovieClips = null;
		mDBFacade.regainFocus();
		if (mSceneGraphComponent.contains(mSteamAvatarHolder, (105 : UInt))) {
			mSceneGraphComponent.removeChild(mSteamAvatarHolder);
		}
		mSteamAvatarHolder = null;
		var _loc1_ = mSteamAvatarMap.keysToArray();
		var _loc10_:UInt;
		if (checkNullIteratee(_loc1_))
			for (_tmp_ in _loc1_) {
				_loc10_ = (ASCompat.toInt(_tmp_) : UInt);
				_loc3_ = ASCompat.coerce(mSteamAvatarMap.itemFor(_loc10_), SteamAvatarHelper);
				if (_loc3_ != null) {
					_loc3_.destroy();
				}
				_loc3_ = null;
			}
		mSteamAvatarMap.clear();
		closeBoosterPopup();
		closeDRFriendBlockPopup();
		closeDRReportPlayerPopup();
		closeAbandonChestPopUp();
		closeKeylessChestPopup();
		closeKeyChestPopup();
		closeInfoPopup();
		if (mChestTransactionFailedPopup != null) {
			mChestTransactionFailedPopup.destroy();
			mChestTransactionFailedPopup = null;
		}
		mDBFacade.menuNavigationController.removeLayer("DISTRIBUTED_DUNGEON_SUMMARY");
		mEventComponent.destroy();
		mWorkComponent.destroy();
		mChatEventComponent.destroy();
		mWorkComponent = null;
		mChatEventComponent = null;
		mBonusXPTick = null;
		mTeamBonusXPTick = null;
		mKillsTick = null;
		mXPBonusStarEffect = null;
		mXPBonusBarEffect = null;
		mXPBonusTextFlash = null;
		mXPBonusText = null;
		_loc5_ = (0 : UInt);
		while (_loc5_ < (mAddFriendButtons.length:UInt)) {
			if (ASCompat.toBool(mAddFriendButtons[(_loc5_ : Int)])) {
				mAddFriendButtons[(_loc5_ : Int)].destroy();
			}
			_loc5_++;
		}
		mAddFriendButtons = null;
		_loc5_ = (0 : UInt);
		while (_loc5_ < (mBlockFriendButtons.length:UInt)) {
			if (ASCompat.toBool(mBlockFriendButtons[(_loc5_ : Int)])) {
				mBlockFriendButtons[(_loc5_ : Int)].destroy();
			}
			_loc5_++;
		}
		mBlockFriendButtons = null;
		_loc5_ = (0 : UInt);
		while (_loc5_ < (mReportPlayerButtons.length:UInt)) {
			if (ASCompat.toBool(mReportPlayerButtons[(_loc5_ : Int)])) {
				mReportPlayerButtons[(_loc5_ : Int)].destroy();
			}
			_loc5_++;
		}
		mReportPlayerButtons = null;
		_loc5_ = (0 : UInt);
		while (_loc5_ < (mBoosterInfos.length:UInt)) {
			mBoosterInfos[(_loc5_ : Int)].destroy();
			_loc5_++;
		}
		mBoosterInfos = null;
		_loc5_ = (0 : UInt);
		while (_loc5_ < (mAvatarButtons.length:UInt)) {
			if (ASCompat.toBool(mAvatarButtons[(_loc5_ : Int)])) {
				mAvatarButtons[(_loc5_ : Int)].destroy();
			}
			_loc5_++;
		}
		mAvatarButtons = null;
		if (mXPBoosterUI != null) {
			mXPBoosterUI.destroy();
		}
		mXPBoosterUI = null;
		if (mCoinBoosterUI != null) {
			mCoinBoosterUI.destroy();
		}
		mCoinBoosterUI = null;
		mPlayerBoosterUIs = null;
		_loc5_ = (0 : UInt);
		while (_loc5_ < 4) {
			_loc8_ = (0 : UInt);
			while (_loc8_ < 2) {
				if (ASCompat.toBool(ASCompat.dynGetIndex(mItemButtons[(_loc5_ : Int)], _loc8_))) {
					ASCompat.dynGetIndex(mItemButtons[(_loc5_ : Int)], _loc8_).destroy();
					mItemButtons[(_loc5_ : Int)][_loc8_] = null;
				}
				_loc8_++;
			}
			_loc5_++;
		}
		mItemButtons = null;
		if (mTownHeader != null) {
			mTownHeader.destroy();
			mTownHeader = null;
		}
		if (mAssetLoadingComponent != null) {
			mAssetLoadingComponent.destroy();
			mAssetLoadingComponent = null;
		}
		if (mBgRenderer != null) {
			mDBFacade.mTween.killTweensOf(mBgRenderer.clip);
			mBgRenderer.destroy();
			mBgRenderer = null;
		}
		if (mNextFloorSection != null) {
			mNextFloorSection.destroy();
			mNextFloorSection = null;
		}
		if (mScoreReportRoot != null) {
			mSceneGraphComponent.removeChild(mScoreReportRoot);
		}
		mScoreReportRoot = null;
		if (mSceneGraphComponent != null) {
			mSceneGraphComponent.destroy();
			mSceneGraphComponent = null;
		}
		mUIChatLog.enabledChatEnterEvent = true;
		mUIChatLog.destroy();
		_loc5_ = (0 : UInt);
		while (_loc5_ < (mChestRenderers.length:UInt)) {
			mChestRenderers[(_loc5_ : Int)].destroy();
			_loc5_++;
		}
		mChestRenderers = null;
		isSingleChestList.length = 0;
		isSingleChestList = null;
		mChatBalloon.length = 0;
		mChatBalloon = null;
		mChatCloseTask.length = 0;
		mChatCloseTask = null;
		mCurrentMapNode = null;
		mDungeonAchievementPanelMovieClipRenderer = null;
		mDungeonReport.length = 0;
		mDungeonReport = null;
		mEventComponent = null;
		mSteamAvatarMap.clear();
		mSteamAvatarMap = null;
		mNetworkComponent = null;
		mPlayerIsTypingNotification = null;
		mRarityMap.clear();
		mRarityMap = null;
		mSortedLootData.resize(0);
		mSortedLootData = null;
		mUIChatLog = null;
		mUILootSlots.resize(0);
		mUILootSlots = null;
		mUILootSlotsFourTreasures.resize(0);
		mUILootSlotsFourTreasures = null;
		mUILootSlotsTwoTreasures.resize(0);
		mUILootSlotsTwoTreasures = null;
		var _loc9_:Array<ASAny>;
		final __ax4_iter_314 = mWeapons;
		if (checkNullIteratee(__ax4_iter_314))
			for (_tmp_ in __ax4_iter_314) {
				_loc9_ = ASCompat.coerce(_tmp_, Array);
				if (checkNullIteratee(_loc9_))
					for (_tmp_ in _loc9_) {
						_loc2_ = ASCompat.coerce(_tmp_, brain.uI.UIObject);
						if (_loc2_ != null) {
							_loc2_.destroy();
						}
					}
			}
		mWeapons.resize(0);
		mWeapons = null;
		mWeaponTooltips.resize(0);
		mWeaponTooltips = null;
		mXpBar.resize(0);
		mXpBar = null;
		mDBFacade = null;
		super.destroy();
	}

	@:isVar public var dungeon_name(never, set):String;

	public function set_dungeon_name(dungeonName:String):String {
		return mDungeonName = dungeonName;
	}

	@:isVar public var report(get, set):Vector<DungeonReport>;

	public function set_report(val:Vector<DungeonReport>):Vector<DungeonReport> {
		var _loc4_ = (0 : UInt);
		var _loc2_:DungeonReport = null;
		var _loc3_ = 0;
		var _loc6_:Array<ASAny> = null;
		mDungeonReport = val;
		_loc4_ = (0 : UInt);
		while (_loc4_ < 4) {
			if (mDungeonReport[(_loc4_ : Int)].id == mDBFacade.accountId) {
				_loc2_ = mDungeonReport[(_loc4_ : Int)];
				mDungeonReport[(_loc4_ : Int)] = mDungeonReport[0];
				mDungeonReport[0] = _loc2_;
				break;
			}
			_loc4_++;
		}
		var _loc5_:Array<ASAny> = [
			mDungeonReport[0].chest_type_1,
			mDungeonReport[0].chest_type_2,
			mDungeonReport[0].chest_type_3,
			mDungeonReport[0].chest_type_4
		];
		mSortedLootData = [];
		_loc3_ = 0;
		while (_loc3_ < 4) {
			_loc6_ = [_loc3_, _loc5_[_loc3_]];
			mSortedLootData.push(_loc6_);
			_loc3_++;
		}
		ASCompat.ASArray.sort(mSortedLootData, compareOnChestValues);
		return val;
	}

	@:isVar public var map_node_id(never, set):UInt;

	public function set_map_node_id(val:UInt):UInt {
		return mMapNodeId = val;
	}

	@:isVar public var dungeonMod1(never, set):UInt;

	public function set_dungeonMod1(val:UInt):UInt {
		return mDungeonMod1 = val;
	}

	@:isVar public var dungeonMod2(never, set):UInt;

	public function set_dungeonMod2(val:UInt):UInt {
		return mDungeonMod2 = val;
	}

	@:isVar public var dungeonMod3(never, set):UInt;

	public function set_dungeonMod3(val:UInt):UInt {
		return mDungeonMod3 = val;
	}

	@:isVar public var dungeonMod4(never, set):UInt;

	public function set_dungeonMod4(val:UInt):UInt {
		return mDungeonMod4 = val;
	}

	function get_report():Vector<DungeonReport> {
		return mDungeonReport;
	}

	function trySurveyLink() {
		var popup:DBUITwoButtonPopup;
		var surveyName = "SURVEY_" + mDBFacade.dbConfigManager.getConfigString("survey_name", "XHBQPFS");
		var surveyURL = mDBFacade.dbConfigManager.getConfigString("survey_url", "");
		var alreadyCompleted = mDBFacade.dbAccountInfo.getAttribute(surveyName) == "1";
		if (ASCompat.stringAsBool(surveyURL) && !alreadyCompleted) {
			surveyURL += "?c=" + mDBFacade.accountId;
			popup = new DBUITwoButtonPopup(mDBFacade, "SUMMARY_SURVEY_POPUP", Locale.getString("SURVEY_POPUP_TITLE"),
				Locale.getString("SURVEY_POPUP_MESSAGE"), Locale.getString("SURVEY_CANCEL"), function() {
					Logger.info("trySurveyLink cancel: " + surveyURL);
					returnToSplashScreen();
			}, Locale.getString("SURVEY_GO"), function() {
					var _loc1_ = new URLRequest(surveyURL);
					flash.Lib.getURL(_loc1_, "_blank");
					Logger.info("trySurveyLink opened: " + surveyURL);
			});
			MemoryTracker.track(popup, "DBUITwoButtonPopup - created in DistributedDungeonSummary.trySurveyLink()");
			mDBFacade.dbAccountInfo.alterAttribute(surveyName, "1");
		} else {
			returnToSplashScreen();
		}
	}

	function tryReturnToSplashScreen() {
		var _loc1_:DBUITwoButtonPopup = null;
		if (mItemCount > 0) {
			_loc1_ = new DBUITwoButtonPopup(mDBFacade, "ARE_YOU_SURE_YOU_WANT_TO_ABANDON_CHESTS", Locale.getString("ABANDON_ITEMS_TITLE"),
				Locale.getString("ABANDON_ITEMS_MESSAGE"), Locale.getString("ABANDON_YES"), trySurveyLink, Locale.getString("CANCEL"), null);
			MemoryTracker.track(_loc1_, "DBUITwoButtonPopup - created in DistributedDungeonSummary.tryReturnToSplashScreen()");
		} else {
			trySurveyLink();
		}
	}

	function openInventory() {
		var _loc1_ = (0 : UInt);
		var _loc2_ = 0;
		mUIInventory = new UIInventory(mDBFacade, mTownHeader, this);
		mUIInventory.setRevealedState(mRevealedItemType, mRevealedItemOfferId, mRevealedItemCallEquip);
		mUIInventory.show(mSelectedGMChest);
		mTownHeader.showCloseButton(true);
		mScoreReportRoot.addChild(mUIInventory.root);
		mUIInventory.setupCategoryNavigation("DISTRIBUTED_DUNGEON_SUMMARY");
		mTownHeader.closeButton.clearRightNavigation();
		_loc1_ = (0 : UInt);
		while (_loc1_ < 4) {
			_loc2_ = 0;
			while (_loc2_ < 2) {
				if (ASCompat.dynGetIndex(mChestMovieClips[(_loc1_ : Int)], _loc2_) != null) {
					ASCompat.setProperty(ASCompat.dynGetIndex(mChestMovieClips[(_loc1_ : Int)], _loc2_), "visible", false);
				}
				_loc2_++;
			}
			_loc1_++;
		}
	}

	function closeHeader() {
		if (mUIInventory != null) {
			closeInventory();
		} else {
			tryReturnToSplashScreen();
		}
	}

	function closeInventory() {
		var _loc2_ = 0;
		mDBFacade.menuNavigationController.setLayerCategoryCallbacks(null, null, "DISTRIBUTED_DUNGEON_SUMMARY");
		mScoreReportRoot.removeChild(mUIInventory.root);
		mUIInventory.destroy();
		mUIInventory = null;
		setupMenuNavigation();
		mTownHeader.showCloseButton(true);
		mTownHeader.title = this.dungeonSuccess != 0 ? Locale.getString("VICTORY") : Locale.getString("DUNGEON_FAILED");
		var _loc1_:Array<ASAny> = [
			mDungeonReport[0].chest_type_1,
			mDungeonReport[0].chest_type_2,
			mDungeonReport[0].chest_type_3,
			mDungeonReport[0].chest_type_4
		];
		_loc2_ = 0;
		while (_loc2_ < 2) {
			if (ASCompat.toBool(ASCompat.dynGetIndex(mChestMovieClips[0], _loc2_))) {
				if (ASCompat.toNumber(_loc1_[_loc2_]) == 0) {
					ASCompat.setProperty(ASCompat.dynGetIndex(mChestMovieClips[0], _loc2_), "visible", false);
				} else {
					ASCompat.setProperty(ASCompat.dynGetIndex(mChestMovieClips[0], _loc2_), "visible", true);
				}
			}
			_loc2_++;
		}
	}

	function returnToSplashScreen() {
		mLeaving = true;
		closeDRFriendBlockPopup();
		closeDRReportPlayerPopup();
		mDBFacade.menuNavigationController.removeLayer("DISTRIBUTED_DUNGEON_SUMMARY");
		mDBFacade.mDistributedObjectManager.mMatchMaker.RequestExit();
	}

	function setupMenuNavigation() {
		var __ax4_iter_315:Array<ASAny>;
		var __ax4_iter_316:Array<ASAny>;
		var _loc12_ = 0;
		var _loc13_:UIObject = null;
		var _loc16_ = 0;
		var _loc9_:UIObject = null;
		var _loc19_:Array<ASAny> = null;
		var _loc14_:Array<ASAny> = null;
		var _loc22_:Array<ASAny> = null;
		var _loc17_:UIObject = null;
		var _loc11_:UIObject = null;
		var _loc7_:UIObject = null;
		var _loc6_:UIObject = null;
		var _loc18_:UIObject = null;
		var _loc2_:UIObject = null;
		var _loc4_ = 0;
		var _loc21_:UIObject = null;
		var _loc15_:UIObject = null;
		var _loc24_:UIObject = null;
		var _loc3_:UIObject = null;
		var _loc5_:Array<ASAny> = null;
		var _loc20_:Array<ASAny> = null;
		if (mTownHeader == null || mNextFloorSection == null || mUIChatLog == null || mWeapons == null) {
			return;
		}
		var _loc23_:Array<ASAny> = [
			mNextFloorSection.battleButton,
			mUIChatLog.chatSendButton,
			mUIChatLog.chatLogButton
		];
		_loc12_ = 0;
		while (_loc12_ < 4) {
			if (ASCompat.toBool(mAvatarButtons[_loc12_])) {
				_loc23_.push(mAvatarButtons[_loc12_]);
			}
			__ax4_iter_315 = mPlayerBoosterUIs[_loc12_];
			if (checkNullIteratee(__ax4_iter_315))
				for (_tmp_ in __ax4_iter_315) {
					_loc13_ = ASCompat.coerce(_tmp_, brain.uI.UIObject);
					_loc23_.push(_loc13_);
				}
			if (ASCompat.toBool(mAddFriendButtons[_loc12_])) {
				_loc23_.push(mAddFriendButtons[_loc12_]);
			}
			if (ASCompat.toBool(mBlockFriendButtons[_loc12_])) {
				_loc23_.push(mBlockFriendButtons[_loc12_]);
			}
			if (ASCompat.toBool(mReportPlayerButtons[_loc12_])) {
				_loc23_.push(mReportPlayerButtons[_loc12_]);
			}
			__ax4_iter_316 = mWeapons[_loc12_];
			if (checkNullIteratee(__ax4_iter_316))
				for (_tmp_ in __ax4_iter_316) {
					_loc13_ = ASCompat.coerce(_tmp_, brain.uI.UIObject);
					_loc23_.push(_loc13_);
				}
			_loc12_++;
		}
		if (checkNullIteratee(_loc23_))
			for (_tmp_ in _loc23_) {
				_loc13_ = ASCompat.coerce(_tmp_, brain.uI.UIObject);
				_loc13_.clearNavigationAndInteractions();
			}
		var _loc10_ = getValidSummaryPlayerIndices();
		linkHeaderToSummary(ASCompat.coerce(_loc10_.length > 0 ? ASCompat.coerce(mAvatarButtons[ASCompat.toInt(_loc10_[0])], brain.uI.UIObject) : null,
			brain.uI.UIObject));
		if (_loc10_.length == 0) {
			return;
		}
		_loc16_ = 0;
		while (_loc16_ < _loc10_.length) {
			_loc12_ = ASCompat.toInt(_loc10_[_loc16_]);
			_loc9_ = ASCompat.coerce(mAvatarButtons[_loc12_], brain.uI.UIObject);
			_loc9_.upNavigation = mTownHeader.addCoinButton;
			if (_loc16_ > 0) {
				mAvatarButtons[ASCompat.toInt(_loc10_[_loc16_ - 1])].isToTheLeftOf(_loc9_);
			}
			_loc19_ = getAvailableUIObjects(ASCompat.coerce(mPlayerBoosterUIs[_loc12_], Array));
			_loc14_ = getPlayerSocialButtons(_loc12_);
			_loc22_ = getAvailableUIObjects(ASCompat.coerce(mWeapons[_loc12_], Array));
			_loc17_ = firstUIObject(_loc19_);
			if (_loc17_ == null) {
				_loc17_ = firstUIObject(_loc14_);
			}
			if (_loc17_ == null) {
				_loc17_ = firstUIObject(_loc22_);
			}
			if (_loc17_ == null) {
				_loc17_ = mUIChatLog.chatSendButton;
			}
			_loc9_.downNavigation = _loc17_;
			linkHorizontalRow(_loc19_);
			_loc11_ = firstUIObject(_loc14_);
			if (_loc11_ == null) {
				_loc11_ = firstUIObject(_loc22_);
			}
			if (_loc11_ == null) {
				_loc11_ = mUIChatLog.chatSendButton;
			}
			if (checkNullIteratee(_loc19_))
				for (_tmp_ in _loc19_) {
					_loc13_ = ASCompat.coerce(_tmp_, brain.uI.UIObject);
					_loc13_.upNavigation = _loc9_;
					_loc13_.downNavigation = _loc11_;
				}
			linkHorizontalRow(_loc14_);
			_loc7_ = firstUIObject(_loc22_);
			_loc6_ = ASCompat.coerce(_loc7_ != null ? _loc7_ : mUIChatLog.chatSendButton, brain.uI.UIObject);
			_loc18_ = ASCompat.coerce(_loc19_.length > 0 ? ASCompat.coerce(_loc19_[_loc19_.length - 1], brain.uI.UIObject) : _loc9_, brain.uI.UIObject);
			if (checkNullIteratee(_loc14_))
				for (_tmp_ in _loc14_) {
					_loc13_ = ASCompat.coerce(_tmp_, brain.uI.UIObject);
					_loc13_.upNavigation = _loc18_;
					_loc13_.downNavigation = _loc6_;
				}
			linkHorizontalRow(_loc22_);
			_loc2_ = ASCompat.coerce(_loc14_.length > 0 ? ASCompat.coerce(_loc14_[0],
				brain.uI.UIObject) : ASCompat.coerce(_loc19_.length > 0 ? ASCompat.coerce(_loc19_[_loc19_.length - 1], brain.uI.UIObject) : _loc9_,
					brain.uI.UIObject),
				brain.uI.UIObject);
			if (checkNullIteratee(_loc22_))
				for (_tmp_ in _loc22_) {
					_loc13_ = ASCompat.coerce(_tmp_, brain.uI.UIObject);
					_loc13_.upNavigation = _loc2_;
					_loc13_.downNavigation = mUIChatLog.chatSendButton;
				}
			_loc4_ = ASCompat.toInt(_loc16_ + 1 < _loc10_.length ? _loc10_[_loc16_ + 1] : -1);
			_loc21_ = ASCompat.coerce(_loc4_ >= 0 ? firstUIObject(getPlayerSocialButtons(_loc4_)) : null, brain.uI.UIObject);
			_loc15_ = ASCompat.coerce(_loc4_ >= 0 ? firstUIObject(getAvailableUIObjects(ASCompat.coerce(mWeapons[_loc4_], Array))) : null, brain.uI.UIObject);
			_loc24_ = mNextFloorSection.battleButton;
			if (_loc14_.length > 0) {
				cast(_loc14_[_loc14_.length - 1], UIObject).rightNavigation = _loc21_ != null ? _loc21_ : (_loc15_ != null ? _loc15_ : _loc24_);
				if (_loc21_ != null) {
					_loc21_.leftNavigation = ASCompat.coerce(_loc14_[_loc14_.length - 1], brain.uI.UIObject);
				}
			}
			if (_loc22_.length > 0) {
				cast(_loc22_[_loc22_.length - 1], UIObject).rightNavigation = _loc15_ != null ? _loc15_ : (_loc21_ != null ? _loc21_ : _loc24_);
				if (_loc15_ != null) {
					_loc15_.leftNavigation = ASCompat.coerce(_loc22_[_loc22_.length - 1], brain.uI.UIObject);
				}
			}
			_loc16_++;
		}
		var _loc1_ = ASCompat.toInt(_loc10_[_loc10_.length - 1]);
		ASCompat.setProperty(mAvatarButtons[_loc1_], "rightNavigation", mNextFloorSection.battleButton);
		var _loc8_ = getAvailableUIObjects(ASCompat.coerce(mWeapons[_loc1_], Array));
		if (_loc8_.length > 0) {
			_loc3_ = ASCompat.coerce(_loc8_[_loc8_.length - 1], brain.uI.UIObject);
		} else {
			_loc5_ = getPlayerSocialButtons(_loc1_);
			_loc20_ = getAvailableUIObjects(ASCompat.coerce(mPlayerBoosterUIs[_loc1_], Array));
			_loc3_ = ASCompat.coerce(_loc5_.length > 0 ? ASCompat.coerce(_loc5_[0],
				brain.uI.UIObject) : ASCompat.coerce(_loc20_.length > 0 ? ASCompat.coerce(_loc20_[_loc20_.length - 1],
					brain.uI.UIObject) : ASCompat.coerce(mAvatarButtons[_loc1_], brain.uI.UIObject),
					brain.uI.UIObject),
				brain.uI.UIObject);
		}
		mUIChatLog.chatSendButton.upNavigation = _loc3_;
		mUIChatLog.chatSendButton.isToTheLeftOf(mUIChatLog.chatLogButton);
		mUIChatLog.chatLogButton.rightNavigation = mNextFloorSection.battleButton;
		mUIChatLog.chatSendButton.isToTheLeftOf(mUIChatLog.chatLogButton);
		mUIChatLog.chatLogButton.rightNavigation = mNextFloorSection.battleButton;
		if (_loc8_.length > 0) {
			mNextFloorSection.battleButton.leftNavigation = ASCompat.coerce(_loc8_[_loc8_.length - 1], brain.uI.UIObject);
		}
	}

	function linkHeaderToSummary(firstAvatar:UIObject) {
		var _loc3_:UIObject = mNextFloorSection.battleButton;
		var _loc2_:UIObject = mTownHeader.closeButton;
		_loc3_.upNavigation = _loc2_;
		if (mUIInventory != null) {
			return;
		}
		_loc2_.clearRightNavigation();
		_loc2_.clearDownNavigation();
		_loc2_.rightNavigation = _loc3_;
		_loc2_.downNavigation = _loc3_;
		mTownHeader.addCoinButton.clearDownNavigation();
		mTownHeader.addGemButton.clearDownNavigation();
		if (firstAvatar != null) {
			mTownHeader.addCoinButton.downNavigation = firstAvatar;
			mTownHeader.addGemButton.downNavigation = firstAvatar;
		}
	}

	function getValidSummaryPlayerIndices():Array<ASAny> {
		var _loc2_ = 0;
		var _loc1_:Array<ASAny> = [];
		_loc2_ = 0;
		while (_loc2_ < 4) {
			if (mDungeonReport[_loc2_].valid != 0
				&& ASCompat.toBool(mAvatarButtons[_loc2_])
				&& ASCompat.toBool(mAvatarButtons[_loc2_].canBeFocused())
				&& isEffectivelyVisible(ASCompat.coerce(mAvatarButtons[_loc2_].root, flash.display.DisplayObject))) {
				_loc1_.push(_loc2_);
			}
			_loc2_++;
		}
		return _loc1_;
	}

	function getAvailableUIObjects(objects:Array<ASAny>):Array<ASAny> {
		var _loc2_:Array<ASAny> = [];
		if (objects == null) {
			return _loc2_;
		}
		var _loc3_:UIObject;
		if (checkNullIteratee(objects))
			for (_tmp_ in objects) {
				_loc3_ = ASCompat.coerce(_tmp_, brain.uI.UIObject);
				if (_loc3_ != null && _loc3_.canBeFocused() && isEffectivelyVisible(_loc3_.root)) {
					_loc2_.push(_loc3_);
				}
			}
		return _loc2_;
	}

	function isEffectivelyVisible(displayObject:DisplayObject):Bool {
		var _loc2_:DisplayObject = null;
		_loc2_ = displayObject;
		while (_loc2_ != null) {
			if (!_loc2_.visible) {
				return false;
			}
			_loc2_ = _loc2_.parent;
		}
		return true;
	}

	function getPlayerSocialButtons(playerIndex:Int):Array<ASAny> {
		return getAvailableUIObjects([
			mAddFriendButtons[playerIndex],
			mBlockFriendButtons[playerIndex],
			mReportPlayerButtons[playerIndex]
		]);
	}

	function firstUIObject(objects:Array<ASAny>):UIObject {
		return ASCompat.coerce(objects != null && objects.length > 0 ? ASCompat.dynamicAs(objects[0], UIObject) : null, brain.uI.UIObject);
	}

	function linkHorizontalRow(objects:Array<ASAny>) {
		var _loc2_ = 0;
		_loc2_ = 1;
		while (_loc2_ < objects.length) {
			cast(objects[_loc2_ - 1], UIObject).isToTheLeftOf(cast(objects[_loc2_], UIObject));
			_loc2_++;
		}
	}

	function focusPreviousPlayerAvatar() {
		focusAdjacentPlayerAvatar(-1);
	}

	function focusNextPlayerAvatar() {
		focusAdjacentPlayerAvatar(1);
	}

	function focusAdjacentPlayerAvatar(direction:Int) {
		var _loc4_ = 0;
		var _loc5_ = getValidSummaryPlayerIndices();
		if (_loc5_.length == 0) {
			return;
		}
		var _loc2_ = -1;
		_loc4_ = 0;
		while (_loc4_ < _loc5_.length) {
			if (isSummaryPlayerObjectFocused(ASCompat.toInt(_loc5_[_loc4_]))) {
				_loc2_ = _loc4_;
				break;
			}
			_loc4_++;
		}
		var _loc3_ = _loc2_ < 0 ? (direction < 0 ? _loc5_.length - 1 : 0) : (_loc2_ + direction + _loc5_.length) % _loc5_.length;
		mDBFacade.menuNavigationController.setFocusedUiObject(ASCompat.coerce(mAvatarButtons[ASCompat.toInt(_loc5_[_loc3_])], brain.uI.UIObject));
	}

	function isSummaryPlayerObjectFocused(playerIndex:Int):Bool {
		var _loc2_:Array<ASAny> = [
			mAvatarButtons[playerIndex],
			mAddFriendButtons[playerIndex],
			mBlockFriendButtons[playerIndex],
			mReportPlayerButtons[playerIndex]
		];
		_loc2_ = _loc2_.concat(ASCompat.coerce(mPlayerBoosterUIs[playerIndex], Array), mWeapons[playerIndex]);
		var _loc3_:UIObject;
		if (checkNullIteratee(_loc2_))
			for (_tmp_ in _loc2_) {
				_loc3_ = ASCompat.coerce(_tmp_, brain.uI.UIObject);
				if (_loc3_ != null && _loc3_.isFocused()) {
					return true;
				}
			}
		return false;
	}
}

private class SteamAvatarHelper {
	public var pic:DisplayObject;

	public var root:MovieClip;

	public function new() {}

	public function destroy() {
		pic = null;
		root = null;
	}
}
