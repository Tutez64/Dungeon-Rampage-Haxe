package distributedObjects
;
   import account.AvatarInfo;
   import account.BoosterInfo;
   import account.ChestInfo;
   import account.CurrencyUpdatedAccountEvent;
   import account.DBInventoryInfo;
   import account.KeyInfo;
   import account.PlayerSpecialStatus;
   import account.StoreServices;
   import account.StoreServicesController;
   import actor.ChatBalloon;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.clock.GameClock;
   import brain.event.EventComponent;
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
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import brain.jsonRPC.JSONRPCService;
   import dBGlobals.DBGlobal;
   import events.ChatEvent;
   import events.FacebookLevelUpPostEvent;
   import events.FriendSummaryNewsFeedEvent;
   import events.GameObjectEvent;
   import events.PlayerExitEvent;
   import facade.DBFacade;
   import facade.Locale;
   import facebookAPI.DBFacebookBragFeedPost;
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
   import metrics.LifestreetTracker;
   import metrics.PixelTracker;
   import sound.DBSoundComponent;
   import town.TownHeader;
   import uI.CountdownTextTimer;
   import uI.DBUIPopup;
   import uI.DBUITwoButtonPopup;
   import uI.friendManager.UIFriendManager;
   import uI.inventory.chests.ChestBuyKeysPopUp;
   import uI.inventory.chests.ChestKeySlot;
   import uI.inventory.chests.ChestRevealPopUp;
   import uI.inventory.UIInventory;
   import uI.inventory.UIWeaponTooltip;
   import uI.UIChatLog;
   import uI.UIHud;
   import uI.UIReportPopup;
   import uI.UIVictoryBoosterPopup;
   import com.greensock.TweenMax;
   import com.maccherone.json.JSONParseError;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.filters.ColorMatrixFilter;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import org.as3commons.collections.Map;

import flash.display.DisplayObject;
import flash.display.MovieClip;
   
    class DistributedDungeonSummary extends GameObject implements IDistributedDungeonSummary
   {
      
      static inline final SCORE_REPORT_PATH= "Resources/Art2D/UI/db_UI_score_report.swf";
      
      static inline final TOWN_PATH= "Resources/Art2D/UI/db_UI_town.swf";
      
      static inline final DOOBER_SWF_PATH= "Resources/Art2D/Doobers/db_items_doobers.swf";
      
      static inline final ITEM_CARD_LEVEL_REQUIREMENT= "ITEM_CARD_LEVEL_REQUIREMENT";
      
      static inline final TAKE_ALL_ID= (1000 : UInt);
      
      static inline final DUNGEONS_COMPLETED= "DUNGEONS_COMPLETED";
      
      static inline final REVEAL_STATE_BEGIN= (1 : UInt);
      
      static inline final REVEAL_TROPHY_AWARD_STATE= (20 : UInt);
      
      static inline final HIDE_TROPHY_AWARD_STATE= (25 : UInt);
      
      static inline final MAP_NODE_DEFEATED_FEED_POST= (30 : UInt);
      
      static inline final REVEAL_STATE_BONUS_XP= (2 : UInt);
      
      static inline final REVEAL_STATE_BONUS_XP_TICK= (3 : UInt);
      
      static inline final REVEAL_STATE_TEAM_BONUS_XP= (4 : UInt);
      
      static inline final REVEAL_STATE_TEAM_BONUS_XP_TICK= (5 : UInt);
      
      static inline final REVEAL_STATE_BOOSTER_TICK= (6 : UInt);
      
      static inline final REVEAL_STATE_BOOSTER_BONUS_TICK= (7 : UInt);
      
      static inline final REVEAL_STATE_KILLS= (8 : UInt);
      
      static inline final REVEAL_STATE_KILLS_TICK= (9 : UInt);
      
      static inline final REVEAL_STATE_TREASURE= (10 : UInt);
      
      static inline final REVEAL_STATE_TREASURE_TICK= (11 : UInt);
      
      static inline final REVEAL_STATE_DONE= (12 : UInt);
      
      static inline final REVEAL_STATE_GOLD_BOOSTER_TICK= (13 : UInt);
      
      static inline final REVEAL_STATE_GOLD_BOOSTER_BONUS_TICK= (14 : UInt);
      
      static inline final REVEAL_TRANSITION_SPEED:Float = 0.45;
      
      static inline final BONUS_TRANSITION_SPEED:Float = 0.45;
      
      static inline final PRE_PLAYTEST= false;
      
      var mRarityMap:Map;
      
      var mDBFacade:DBFacade;
      
      var mDungeonReport:Vector<DungeonReport>;
      
      var mDungeonName:String;
      
      var mSortedLootData:Array<ASAny>;
      
      var mScoreReportRoot:MovieClip;
      
      var mTownRoot:MovieClip;
      
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
      
      var mAddFriendButtons:Array<ASAny>;
      
      var mBlockFriendButtons:Array<ASAny>;
      
      var mReportPlayerButtons:Array<ASAny>;
      
      var mSelectedItemSlot:UInt = 0;
      
      var mSelectedGMChest:GMChest;
      
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
      
      var mFacebookPicHolder:MovieClip;
      
      var mFacebookPicMap:Map;
      
      var mDungeonSuccess:Bool = false;
      
      var mDungeonCompleteBonusXP:UInt = (0 : UInt);
      
      var mInDungeonXPEarned:UInt = (0 : UInt);
      
      var mDRFriendBlockPopup:DBUITwoButtonPopup;
      
      var mBgRenderer:MovieClipRenderController;
      
      var mOpenKeyChestMC:MovieClip;
      
      var mAbandonButton:UIButton;
      
      var mKeepButton:UIButton;
      
      var mOpenButton:UIButton;
      
      var mChestRevealPopUp:ChestRevealPopUp;
      
      var mChestRenderers:Vector<MovieClipRenderer>;
      
      var mChestKeySlots:Vector<ChestKeySlot>;
      
      var mOpenKeyChestRenderer:MovieClipRenderer;
      
      var mKeyThatCanOpenChest:KeyInfo;
      
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
      
      public function new(param1:DBFacade, param2:UInt)
      {
         var dungeonsCompletedCount:UInt;
         var k:Int;
         var i:Int;
         var j:Int;
         var dbFacade= param1;
         var doid= param2;
         mXpBar = [];
         Logger.warn("Start construction of DDS");
         super(dbFacade,doid);
         try
         {
            mDBFacade = dbFacade;
            mRarityMap = new Map();
            mRarityMap.add("COMMON",1);
            mRarityMap.add("UNCOMMON",4);
            mRarityMap.add("RARE",5);
            mRarityMap.add("LEGENDARY",6);
            mRarityMap.add("CONSUMABLE_SMALL",2);
            mRarityMap.add("CONSUMABLE_ROYAL",3);
            mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade);
            mRevealedItemType = (0 : UInt);
            mRevealedItemOfferId = (0 : UInt);
            mAddFriendButtons = [];
            mBlockFriendButtons = [];
            mReportPlayerButtons = [];
            mBoosterInfos = [];
            mDBFacade.dbAccountInfo.incrementCompletedDungeons();
            dungeonsCompletedCount = mDBFacade.dbAccountInfo.getDungeonsCompleted();
            if(dungeonsCompletedCount == 1)
            {
               PixelTracker.tutorialComplete(mDBFacade);
            }
            if(mDBFacade.facebookController != null && dungeonsCompletedCount >= 1 && !mDBFacade.dbConfigManager.getConfigBoolean("FUFB",false))
            {
               mDBFacade.facebookController.updateGuestAchievement((1 : UInt));
            }
            mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
            mSceneGraphComponent = new SceneGraphComponent(mDBFacade);
            mSoundComponent = new DBSoundComponent(mDBFacade);
            mWorkComponent = new LogicalWorkComponent(mDBFacade);
            mEventComponent = new EventComponent(mDBFacade);
            mChatBalloon = new Vector<ChatBalloon>((4 : UInt));
            mChatCloseTask = new Vector<Task>((4 : UInt));
            mChatEventComponent = new EventComponent(dbFacade);
            mFacebookPicMap = new Map();
            isSingleChestList = new Vector<Bool>();
            isSingleChestList = new Vector<Bool>();
            k = 0;
            while(k < 4)
            {
               isSingleChestList.push(false);
               k = k + 1;
            }
            mChestRenderers = new Vector<MovieClipRenderer>();
            mChestMovieClips = [];
            i = 0;
            while(i < 4)
            {
               mChestMovieClips.push([]);
               j = 0;
               while(j < 4)
               {
                  ASCompat.dynPush(mChestMovieClips[i], new MovieClip());
                  j = j + 1;
               }
               i = i + 1;
            }
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_nametag.swf"),nametagSwfLoaded);
            mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),"HealthBomb1",function(param1:SoundAsset)
            {
               mSmashSfx = param1;
            });
            mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),"LevelUp2",function(param1:SoundAsset)
            {
               mLevelSfx = param1;
            });
            mTeamBonusUI = new Map();
         }
         catch(e:Dynamic)
         {
            Logger.error("An error occurred while attempting to construct distributed dungeon summary.  Error: " + Std.string(e.message));
         }
         Logger.warn("Finished construction of DDS");
      }
      
      function nametagSwfLoaded(param1:SwfAsset) 
      {
         var _loc2_= param1.getClass("fb_avatar_holder");
         mFacebookPicHolder = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
         mSceneGraphComponent.addChild(mFacebookPicHolder,(105 : UInt));
         mFacebookPicHolder.visible = false;
      }
      
      public function setNetworkComponentDistributedDungeonSummary(param1:DistributedDungeonSummaryNetworkComponent) 
      {
         mNetworkComponent = param1;
      }
      
      public function postGenerate() 
      {
         mCurrentMapNode = ASCompat.dynamicAs(mDBFacade.gameMaster.mapNodeById.itemFor(mMapNodeId), gameMasterDictionary.GMMapNode);
         if(mCurrentMapNode == null)
         {
            Logger.error("Couldn\'t find GMMapNode for node id : " + mMapNodeId);
            return;
         }
         if(LifestreetTracker.IS_FUNCTIONAL && mCurrentMapNode.Id == LifestreetTracker.LIFESTREET_NODE_ID && !mDBFacade.dbAccountInfo.dbAccountParams.hasLifestreetParam())
         {
            PixelTracker.nodeCompleted(mDBFacade);
         }
         PixelTracker.nodeIndexCompleted(mDBFacade,mCurrentMapNode.BitIndex);
         mDungeonName = mCurrentMapNode.Name.toUpperCase();
         if(this.dungeonSuccess != 0)
         {
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_score_report.swf"),successScoreReportSwfLoaded);
         }
         else
         {
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_score_report.swf"),failureScoreReportSwfLoaded);
         }
         mDBFacade.dbAccountInfo.dbAccountParams.flushParams();
      }
      
      function setRevealState(param1:UInt, param2:Float) 
      {
         mRevealState = param1;
         mWorkComponent.doLater(param2,updateRevealState);
      }
      
      function setUILootSlotsTwoTreasuresVisible(param1:Bool) 
      {
         var _loc3_= 0;
         var _loc2_:ASAny;
         final __ax4_iter_199 = mUILootSlotsTwoTreasures;
         if (checkNullIteratee(__ax4_iter_199)) for (_tmp_ in __ax4_iter_199)
         {
            _loc2_ = _tmp_;
            _loc3_ = 0;
            while(_loc3_ < ASCompat.toNumberField(_loc2_, "length"))
            {
               ASCompat.setProperty(_loc2_[_loc3_], "visible", param1);
               _loc3_++;
            }
         }
      }
      
      function setUILootSlotsFourTreasuresVisible(param1:Bool) 
      {
         var _loc3_= 0;
         var _loc2_:ASAny;
         final __ax4_iter_200 = mUILootSlotsFourTreasures;
         if (checkNullIteratee(__ax4_iter_200)) for (_tmp_ in __ax4_iter_200)
         {
            _loc2_ = _tmp_;
            _loc3_ = 0;
            while(_loc3_ < ASCompat.toNumberField(_loc2_, "length"))
            {
               ASCompat.setProperty(_loc2_[_loc3_], "visible", param1);
               _loc3_++;
            }
         }
      }
      
      function updateRevealState(param1:GameClock) 
      {
         var __tmpIncObj1:Vector<UInt>;
         var __tmpIncIdx2:Int;
         var __tmpIncObj3:Vector<UInt>;
         var __tmpIncIdx4:Int;
         var i:UInt = 0;
         var allFinished:Bool;
         var loot:Array<ASAny>;
         var trophies:Int;
         var trophyGetClipLength:UInt;
         var bossFeedPosts:Bool;
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
         var totalXP:Int;
         var local_i:UInt;
         var tickingFilter:Array<ASAny>;
         var headerTitle:String;
         var go:GameObject;
         var player:PlayerGameObject;
         var treasureClips:Array<ASAny>;
         var j:Int;
         var clock= param1;
         var stats:Array<ASAny> = [(mScoreReportRoot : ASAny).stats_a,(mScoreReportRoot : ASAny).stats_b,(mScoreReportRoot : ASAny).stats_c,(mScoreReportRoot : ASAny).stats_d];
         do {
                  switch(mRevealState)
         {
            case 1:
               i = (0 : UInt);
               while(i < (stats.length : UInt))
               {
                  if(mDungeonReport[(i : Int)].valid != 0)
                  {
                     ASCompat.setProperty(stats[(i : Int)].stats.xp_bar.bonus_xp_reveal, "visible", false);
                     ASCompat.setProperty(stats[(i : Int)].stats.xp_bar.bonus_xp, "visible", false);
                     ASCompat.setProperty(stats[(i : Int)].stats.kills.enemies_killed, "visible", false);
                     ASCompat.setProperty(stats[(i : Int)].stats.kills.enemies_killed_reveal, "visible", false);
                     ASCompat.setProperty(stats[(i : Int)].stats.treasure, "visible", false);
                  }
                  i = i + 1;
               }
               if(mDBFacade.accountBonus.isXPBonusActive)
               {
                  mXPBonusStarEffect.visible = true;
                  mXPBonusBarEffect.visible = true;
                  mXPBonusTextFlash.visible = true;
                  mXPBonusText.text = mDBFacade.accountBonus.xpBonusText;
               }
               setRevealState((20 : UInt),0.45);
               
            case 20:
               if(mDungeonReport[0].receivedTrophy == 0)
               {
                  setRevealState((2 : UInt),0.45);
                  break;
               }
               mDungeonAchievementPanelMovieClipRenderer.clip.visible = true;
               ASCompat.setProperty((mScoreReportRoot : ASAny).stats_a.stats.trophies, "filters", [new GlowFilter((16633879 : UInt),1,8,8,10)]);
               trophies = ASCompat.toInt((mScoreReportRoot : ASAny).stats_a.stats.trophies.trophies.text);
               trophies = trophies + 1;
               ASCompat.setProperty((mScoreReportRoot : ASAny).stats_a.stats.trophies.trophies, "text", Std.string(trophies));
               trophyGetClipLength = (4 : UInt);
               mDungeonAchievementPanelMovieClipRenderer.play();
               if(mSmashSfx != null)
               {
                  mSoundComponent.playSfxOneShot(mSmashSfx);
               }
               mLogicalWorkComponent.doLater(1.5833333333333333,function(param1:GameClock)
               {
                  if(mSmashSfx != null)
                  {
                     mSoundComponent.playSfxOneShot(mSmashSfx);
                  }
               });
               setRevealState((25 : UInt),trophyGetClipLength);
               
            case 25:
               mDungeonAchievementPanelMovieClipRenderer.stop();
               mDungeonAchievementPanelMovieClipRenderer.clip.visible = false;
               setRevealState((30 : UInt),0.45);
               
            case 30:
               bossFeedPosts = mDBFacade.dbConfigManager.getConfigBoolean("boss_feed_posts",true);
               if(bossFeedPosts && mDungeonReport[0].receivedTrophy != 0 && mCurrentMapNode.Constant != "TUTORIAL")
               {
                  DBFacebookBragFeedPost.defeatMapNodeBrag(mDBFacade,mCurrentMapNode,mAssetLoadingComponent);
               }
               setRevealState((2 : UInt),0.45);
               
            case 2:
               if(mTrophyGetMovieClipRenderer != null)
               {
                  mTrophyGetMovieClipRenderer.clip.visible = false;
               }
               i = (0 : UInt);
               while(i < (stats.length : UInt))
               {
                  if(mDungeonReport[(i : Int)].valid != 0)
                  {
                     ASCompat.setProperty(stats[(i : Int)].stats.xp_bar.bonus_xp_reveal, "visible", false);
                     ASCompat.setProperty(stats[(i : Int)].stats.xp_bar.bonus_xp, "visible", false);
                  }
                  i = i + 1;
               }
               setRevealState((3 : UInt),0.45);
               
            case 3:
               allFinished = true;
               maxBonus = (0 : UInt);
               xp_bars = [(mScoreReportRoot : ASAny).stats_a.stats.xp_bar.UI_XP,(mScoreReportRoot : ASAny).stats_b.stats.xp_bar.UI_XP,(mScoreReportRoot : ASAny).stats_c.stats.xp_bar.UI_XP,(mScoreReportRoot : ASAny).stats_d.stats.xp_bar.UI_XP];
               i = (0 : UInt);
               while(i < (stats.length : UInt))
               {
                  if(mDungeonReport[(i : Int)].valid != 0)
                  {
                     ASCompat.setProperty(stats[(i : Int)].stats.xp_bar.bonus_xp_reveal, "visible", false);
                     ASCompat.setProperty(stats[(i : Int)].stats.xp_bar.bonus_xp, "visible", true);
                     maxBonus = (Std.int(Math.max(maxBonus,mDungeonReport[(i : Int)].xp_bonus)) : UInt);
                     speed = (maxBonus - mBonusXPTick[(i : Int)]) / 10;
                     if(speed < 1 && maxBonus > mBonusXPTick[(i : Int)])
                     {
                        speed = 1;
                     }
                     if(mBonusXPTick[(i : Int)] < mDungeonReport[(i : Int)].xp_bonus)
                     {
                        gmHero = ASCompat.dynamicAs(mDBFacade.gameMaster.heroById.itemFor(mDungeonReport[(i : Int)].type), gameMasterDictionary.GMHero);
                        oldLevel = gmHero.getLevelFromExp(mDungeonReport[(i : Int)].xp + mBonusXPTick[(i : Int)]);
                        allFinished = false;
                        mBonusXPTick[(i : Int)] += (Std.int(speed) : UInt);
                        currentExp = mDungeonReport[(i : Int)].xp + mBonusXPTick[(i : Int)];
                        level = gmHero.getLevelFromExp(currentExp);
                        levelIndex = (gmHero.getLevelIndex(currentExp) : UInt);
                        lastLevelExp = (ASCompat.toInt(levelIndex > 0 ? gmHero.getExpFromIndex(levelIndex - 1) : 0) : UInt);
                        max = gmHero.getExpFromIndex(levelIndex);
                        ASCompat.setProperty(mXpBar[(i : Int)], "value", (currentExp - lastLevelExp) / (max - lastLevelExp));
                        ASCompat.setProperty(xp_bars[(i : Int)].xp_level, "text", Std.string(level));
                        ASCompat.setProperty(stats[(i : Int)].stats.xp_bar.bonus_xp.xp, "text", Std.string(mBonusXPTick[(i : Int)]));
                        ASCompat.setProperty(stats[(i : Int)].stats.xp_bar.UI_XP.xp_points, "text", Std.string(currentExp));
                        ASCompat.setProperty(stats[(i : Int)].stats.xp_bar.UI_XP.xp_level, "text", Std.string(level));
                        if(oldLevel != level)
                        {
                           ASCompat.setProperty(stats[(i : Int)].stats.fx_level_up_text, "visible", true);
                           ASCompat.setProperty(stats[(i : Int)].stats.fx_level_up_anim, "visible", true);
                           animMcr = new MovieClipRenderController(mDBFacade,ASCompat.dynamicAs(stats[(i : Int)].stats.fx_level_up_anim, flash.display.MovieClip));
                           animMcr.play((0 : UInt),false,function()
                           {
                              animMcr.destroy();
                           });
                           textMcr = new MovieClipRenderController(mDBFacade,ASCompat.dynamicAs(stats[(i : Int)].stats.fx_level_up_text, flash.display.MovieClip));
                           textMcr.play((0 : UInt),false,function()
                           {
                              textMcr.destroy();
                           });
                           if(mLevelSfx != null)
                           {
                              mSoundComponent.playSfxOneShot(mLevelSfx);
                           }
                           if(i == 0)
                           {
                              mEventComponent.dispatchEvent(new FacebookLevelUpPostEvent("FacebookLevelUpPostEvent",level));
                           }
                        }
                     }
                  }
                  i = i + 1;
               }
               if(allFinished)
               {
                  mDungeonCompleteBonusXP = mDungeonReport[0].xp_bonus;
                  mInDungeonXPEarned = mDungeonReport[0].xp_earned;
                  setRevealState((4 : UInt),0.45);
                  break;
               }
               setRevealState((3 : UInt),0.45 / maxBonus);
               
            case 4:
               i = (0 : UInt);
               while(i < (stats.length : UInt))
               {
                  if(mDungeonReport[(i : Int)].valid != 0)
                  {
                     teamBonusUI = ASCompat.dynamicAs(mTeamBonusUI.itemFor(i), brain.uI.UIObject);
                     teamBonusUI.visible = true;
                  }
                  i = i + 1;
               }
               setRevealState((5 : UInt),0.45);
               
            case 5:
               allFinished = true;
               maxBonusTeam = (0 : UInt);
               xp_barsTeam = [(mScoreReportRoot : ASAny).stats_a.stats.xp_bar.UI_XP,(mScoreReportRoot : ASAny).stats_b.stats.xp_bar.UI_XP,(mScoreReportRoot : ASAny).stats_c.stats.xp_bar.UI_XP,(mScoreReportRoot : ASAny).stats_d.stats.xp_bar.UI_XP];
               i = (0 : UInt);
               while(i < (stats.length : UInt))
               {
                  if(mDungeonReport[(i : Int)].valid != 0)
                  {
                     maxBonusTeam = (Std.int(Math.max(maxBonusTeam,mDungeonReport[(i : Int)].team_xp_bonus)) : UInt);
                     speedTeam = (maxBonusTeam - mTeamBonusXPTick[(i : Int)]) / 10;
                     if(speedTeam < 1 && maxBonusTeam > mTeamBonusXPTick[(i : Int)])
                     {
                        speedTeam = 1;
                     }
                     if(mTeamBonusXPTick[(i : Int)] < mDungeonReport[(i : Int)].team_xp_bonus)
                     {
                        gmHeroTeam = ASCompat.dynamicAs(mDBFacade.gameMaster.heroById.itemFor(mDungeonReport[(i : Int)].type), gameMasterDictionary.GMHero);
                        oldLevelTeam = gmHeroTeam.getLevelFromExp(mDungeonReport[(i : Int)].xp + mBonusXPTick[(i : Int)]);
                        allFinished = false;
                        mTeamBonusXPTick[(i : Int)] += (Std.int(speedTeam) : UInt);
                        currentExpTeam = mDungeonReport[(i : Int)].xp + mBonusXPTick[(i : Int)] + mTeamBonusXPTick[(i : Int)];
                        levelTeam = gmHeroTeam.getLevelFromExp(currentExpTeam);
                        levelIndexTeam = (gmHeroTeam.getLevelIndex(currentExpTeam) : UInt);
                        lastLevelExpTeam = (ASCompat.toInt(levelIndexTeam > 0 ? gmHeroTeam.getExpFromIndex(levelIndexTeam - 1) : 0) : UInt);
                        maxTeam = gmHeroTeam.getExpFromIndex(levelIndexTeam);
                        ASCompat.setProperty(mXpBar[(i : Int)], "value", (currentExpTeam - lastLevelExpTeam) / (maxTeam - lastLevelExpTeam));
                        ASCompat.setProperty(xp_barsTeam[(i : Int)].xp_level, "text", Std.string(levelTeam));
                        teamBonusUITeam = ASCompat.dynamicAs(mTeamBonusUI.itemFor(i), brain.uI.UIObject);
                        ASCompat.setProperty((teamBonusUITeam.root : ASAny).xp, "text", Std.string(mTeamBonusXPTick[(i : Int)]));
                        ASCompat.setProperty(stats[(i : Int)].stats.xp_bar.UI_XP.xp_points, "text", Std.string(currentExpTeam));
                        ASCompat.setProperty(stats[(i : Int)].stats.xp_bar.UI_XP.xp_level, "text", Std.string(levelTeam));
                        if(oldLevelTeam != levelTeam)
                        {
                           ASCompat.setProperty(stats[(i : Int)].stats.fx_level_up_text, "visible", true);
                           ASCompat.setProperty(stats[(i : Int)].stats.fx_level_up_anim, "visible", true);
                           animMcrTeam = new MovieClipRenderController(mDBFacade,ASCompat.dynamicAs(stats[(i : Int)].stats.fx_level_up_anim, flash.display.MovieClip));
                           animMcrTeam.play((0 : UInt),false,function()
                           {
                              animMcrTeam.destroy();
                           });
                           textMcrTeam = new MovieClipRenderController(mDBFacade,ASCompat.dynamicAs(stats[(i : Int)].stats.fx_level_up_text, flash.display.MovieClip));
                           textMcrTeam.play((0 : UInt),false,function()
                           {
                              textMcrTeam.destroy();
                           });
                           if(mLevelSfx != null)
                           {
                              mSoundComponent.playSfxOneShot(mLevelSfx);
                           }
                           if(i == 0)
                           {
                              mEventComponent.dispatchEvent(new FacebookLevelUpPostEvent("FacebookLevelUpPostEvent",levelTeam));
                           }
                        }
                     }
                  }
                  i = i + 1;
               }
               if(allFinished)
               {
                  mDungeonCompleteBonusXP = mDungeonReport[0].xp_bonus + mDungeonReport[0].team_xp_bonus;
                  setRevealState((8 : UInt),0.45);
                  break;
               }
               setRevealState((5 : UInt),0.45 / maxBonusTeam);
               
            case 8:
               i = (0 : UInt);
               while(i < (stats.length : UInt))
               {
                  if(mDungeonReport[(i : Int)].valid != 0)
                  {
                     ASCompat.setProperty(stats[(i : Int)].stats.kills.enemies_killed_reveal, "visible", false);
                  }
                  i = i + 1;
               }
               setRevealState((9 : UInt),0);
               
            case 9:
               allFinished = true;
               maxKills = (0 : UInt);
               i = (0 : UInt);
               while(i < (stats.length : UInt))
               {
                  if(mDungeonReport[(i : Int)].valid != 0)
                  {
                     maxKills = (Std.int(Math.max(maxKills,mDungeonReport[(i : Int)].kills)) : UInt);
                     ASCompat.setProperty(stats[(i : Int)].stats.kills.enemies_killed_reveal, "visible", false);
                     ASCompat.setProperty(stats[(i : Int)].stats.kills.enemies_killed, "visible", true);
                     if(mKillsTick[(i : Int)] < mDungeonReport[(i : Int)].kills)
                     {
                        allFinished = false;
                        __tmpIncObj1 = mKillsTick;
                        __tmpIncIdx2 = (i : Int);
__tmpIncObj1[__tmpIncIdx2]= (__tmpIncObj1[__tmpIncIdx2] + 1 : UInt);
                        ASCompat.setProperty(stats[(i : Int)].stats.kills.enemies_killed.kills, "text", mKillsTick[(i : Int)]);
                     }
                  }
                  i = i + 1;
               }
               if(allFinished)
               {
                  setRevealState((10 : UInt),0.45);
                  break;
               }
               setRevealState((9 : UInt),0.45 / maxKills);
               
            case 10:
               i = (0 : UInt);
               while(i < (stats.length : UInt))
               {
                  if(mDungeonReport[(i : Int)].valid != 0)
                  {
                     ASCompat.setProperty(stats[(i : Int)].stats.treasure, "visible", true);
                  }
                  i = i + 1;
               }
               setRevealState((11 : UInt),0.45);
               
            case 11:
               slot = mTreasureTick++;
               i = (0 : UInt);
               while(i < (stats.length : UInt))
               {
                  if(mDungeonReport[(i : Int)].valid != 0)
                  {
                     if(mItemCount > 2)
                     {
                        loot = ASCompat.dynamicAs(mUILootSlotsFourTreasures[(i : Int)], Array);
                        setUILootSlotsTwoTreasuresVisible(false);
                     }
                     else
                     {
                        loot = ASCompat.dynamicAs(mUILootSlotsTwoTreasures[(i : Int)], Array);
                        setUILootSlotsFourTreasuresVisible(false);
                     }
                     if(i == 0)
                     {
                        localLoot = loot;
                     }
                     if(ASCompat.toNumberField(loot[(slot : Int)], "numChildren") > 2)
                     {
                        weapon_clip = ASCompat.dynamicAs(loot[(slot : Int)].getChildAt(2), flash.display.MovieClip);
                        if(weapon_clip != null)
                        {
                           weapon_clip.visible = true;
                           global_position = weapon_clip.localToGlobal(new Point(0,0));
                           position = new Vector3D(global_position.x,global_position.y + 16);
                        }
                     }
                  }
                  i = i + 1;
               }
               if(mTreasureTick >= 2 || ASCompat.toNumberField(localLoot[(slot + 1 : Int)], "numChildren") < 2)
               {
                  openBoosterPopup();
                  if((mBoosterPopup.expStack != null || mBoosterPopup.goldStack != null) && this.dungeonSuccess != 0)
                  {
                     setRevealState((6 : UInt),0.45);
                     break;
                  }
                  closeBoosterPopup();
                  setRevealState((12 : UInt),0.1);
                  break;
               }
               setRevealState((11 : UInt),0.45);
               
            case 6:
               if(mBoosterPopup == null)
               {
                  setRevealState((12 : UInt),0.1);
                  break;
               }
               if(mBoosterPopup.expStack != null)
               {
                  maxBonus = (Std.int(Math.max(mDungeonReport[0].xp_bonus + mDungeonReport[0].team_xp_bonus,mDungeonReport[0].xp_earned)) : UInt);
                  totalXP = mDungeonReport[0].xp_bonus + mDungeonReport[0].team_xp_bonus + mDungeonReport[0].xp_earned;
                  mBoosterExpTick = (Std.int(totalXP * mBoosterPopup.expStack.ExpMult - totalXP) : UInt);
                  if(mBoosterPopup != null)
                  {
                     mBoosterPopup.setExp((mBoosterExpTick : Int));
                  }
                  mDungeonReport[0].xp_bonus += mBoosterExpTick;
               }
               if(mBoosterPopup.goldStack != null)
               {
                  mBoosterPopup.setGold(Std.int(mDungeonReport[0].gold_earned * mBoosterPopup.goldStack.GoldMult - mDungeonReport[0].gold_earned));
               }
               setRevealState((7 : UInt),0.45);
               
            case 7:
               if(mBoosterPopup == null)
               {
                  setRevealState((12 : UInt),0.1);
                  break;
               }
               allFinished = true;
               maxBonus = (0 : UInt);
               xp_bars = [(mScoreReportRoot : ASAny).stats_a.stats.xp_bar.UI_XP,(mScoreReportRoot : ASAny).stats_b.stats.xp_bar.UI_XP,(mScoreReportRoot : ASAny).stats_c.stats.xp_bar.UI_XP,(mScoreReportRoot : ASAny).stats_d.stats.xp_bar.UI_XP];
               local_i = (0 : UInt);
               ASCompat.setProperty(stats[(local_i : Int)].stats.xp_bar.bonus_xp_reveal, "visible", false);
               ASCompat.setProperty(stats[(local_i : Int)].stats.xp_bar.bonus_xp, "visible", true);
               maxBonus = (Std.int(Math.max(maxBonus,mDungeonReport[(local_i : Int)].xp_bonus + mDungeonReport[(local_i : Int)].team_xp_bonus)) : UInt);
               if(mBonusXPTick[(local_i : Int)] < mDungeonReport[(local_i : Int)].xp_bonus + mDungeonReport[(local_i : Int)].team_xp_bonus)
               {
                  gmHero = ASCompat.dynamicAs(mDBFacade.gameMaster.heroById.itemFor(mDungeonReport[(local_i : Int)].type), gameMasterDictionary.GMHero);
                  oldLevel = gmHero.getLevelFromExp(mDungeonReport[(local_i : Int)].xp + mBonusXPTick[(local_i : Int)]);
                  allFinished = false;
                  __tmpIncObj3 = mBonusXPTick;
                  __tmpIncIdx4 = (local_i : Int);
__tmpIncObj3[__tmpIncIdx4]= (__tmpIncObj3[__tmpIncIdx4] + 1 : UInt);
                  currentExp = mDungeonReport[(local_i : Int)].xp + mBonusXPTick[(local_i : Int)];
                  level = gmHero.getLevelFromExp(currentExp);
                  levelIndex = (gmHero.getLevelIndex(currentExp) : UInt);
                  lastLevelExp = (ASCompat.toInt(levelIndex > 0 ? gmHero.getExpFromIndex(levelIndex - 1) : 0) : UInt);
                  max = gmHero.getExpFromIndex(levelIndex);
                  ASCompat.setProperty(mXpBar[(local_i : Int)], "value", (currentExp - lastLevelExp) / (max - lastLevelExp));
                  ASCompat.setProperty(xp_bars[(local_i : Int)].xp_level, "text", Std.string(level));
                  ASCompat.setProperty(stats[(local_i : Int)].stats.xp_bar.bonus_xp.xp, "text", Std.string(mBonusXPTick[(local_i : Int)]));
                  ASCompat.setProperty(stats[(local_i : Int)].stats.xp_bar.UI_XP.xp_points, "text", Std.string(currentExp));
                  ASCompat.setProperty(stats[(local_i : Int)].stats.xp_bar.UI_XP.xp_level, "text", Std.string(level));
                  if(oldLevel != level)
                  {
                     ASCompat.setProperty(stats[(local_i : Int)].stats.fx_level_up_text, "visible", true);
                     ASCompat.setProperty(stats[(local_i : Int)].stats.fx_level_up_anim, "visible", true);
                     animMcr = new MovieClipRenderController(mDBFacade,ASCompat.dynamicAs(stats[(local_i : Int)].stats.fx_level_up_anim, flash.display.MovieClip));
                     animMcr.play((0 : UInt),false,function()
                     {
                        animMcr.destroy();
                     });
                     textMcr = new MovieClipRenderController(mDBFacade,ASCompat.dynamicAs(stats[(local_i : Int)].stats.fx_level_up_text, flash.display.MovieClip));
                     textMcr.play((0 : UInt),false,function()
                     {
                        textMcr.destroy();
                     });
                     if(i == 0)
                     {
                        mEventComponent.dispatchEvent(new FacebookLevelUpPostEvent("FacebookLevelUpPostEvent",level));
                     }
                  }
               }
               if(allFinished)
               {
                  setRevealState((12 : UInt),0.1);
                  applyGlowFilter(ASCompat.dynamicAs(stats[0].stats.xp_bar.bonus_xp, flash.display.MovieClip));
                  break;
               }
               tickingFilter = [];
               tickingFilter.push(new GlowFilter((16777215 : UInt),1,12,12,6));
               ASCompat.setProperty(stats[0].stats.xp_bar.bonus_xp, "filters", tickingFilter);
               ASCompat.setProperty(stats[0].stats.xp_bar.bonus_xp, "scaleX", 1.1);
               ASCompat.setProperty(stats[0].stats.xp_bar.bonus_xp, "scaleY", 1.1);
               setRevealState((7 : UInt),0.45 / maxBonus);
               
            case 12:
               fadeAwayTitle();
               mEventComponent.dispatchEvent(new Event("TIME_TO_SHARE_LEVEL_UP_EVENT"));
               mTownHeader = new TownHeader(mDBFacade,closeHeader);
               mTownHeader.animateHeader();
               if(mCurrentMapNode.InfiniteDungeon != null)
               {
                  headerTitle = Locale.getString("INFINITE_SUMMARY_HEADER_TITLE");
               }
               else
               {
                  headerTitle = this.dungeonSuccess != 0 ? Locale.getString("VICTORY") : Locale.getString("DUNGEON_FAILED");
               }
               mTownHeader.title = headerTitle;
               mTownHeader.showCloseButton(true);
               go = mFacade.gameObjectManager.getReferenceFromId(mDungeonReport[0].id);
               player = ASCompat.reinterpretAs(go , PlayerGameObject);
               mEventComponent.dispatchEvent(new CurrencyUpdatedAccountEvent(player.basicCurrency,mDBFacade.dbAccountInfo.premiumCurrency));
               if(mItemCount > 0 && mDungeonSuccess)
               {
                  loot = mUILootSlots;
                  treasureClips = [(mScoreReportRoot : ASAny).stats_a.stats.treasure,(mScoreReportRoot : ASAny).stats_b.stats.treasure,(mScoreReportRoot : ASAny).stats_c.stats.treasure,(mScoreReportRoot : ASAny).stats_d.stats.treasure];
                  i = (0 : UInt);
                  while(i < 4)
                  {
                     if(isSingleChestList[(i : Int)])
                     {
                        if(ASCompat.dynGetIndex(mChestMovieClips[(i : Int)], 2) != null && ASCompat.dynGetIndex(loot[(i : Int)], 2) != null)
                        {
                           treasureClips[(i : Int)].addChild(ASCompat.dynGetIndex(mChestMovieClips[(i : Int)], 2));
                           if(mDungeonReport[(i : Int)].chest_type_1 != 0)
                           {
                              ASCompat.setProperty(ASCompat.dynGetIndex(loot[(i : Int)], 2), "visible", false);
                           }
                        }
                     }
                     else
                     {
                        j = 0;
                        while(j < 4)
                        {
                           if(ASCompat.dynGetIndex(mChestMovieClips[(i : Int)], j) != null && ASCompat.dynGetIndex(loot[(i : Int)], j) != null)
                           {
                              treasureClips[(i : Int)].addChild(ASCompat.dynGetIndex(mChestMovieClips[(i : Int)], j));
                              if(j == 0 && mDungeonReport[(i : Int)].chest_type_1 != 0 || j == 1 && mDungeonReport[(i : Int)].chest_type_2 != 0)
                              {
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
      
      function applyGlowFilter(param1:MovieClip) 
      {
         var _loc2_:Array<ASAny> = [];
         _loc2_.push(new GlowFilter((16777215 : UInt),1,9,9,4));
         param1.filters = cast(_loc2_);
         param1.scaleX = 1;
         param1.scaleY = 1;
      }
      
      function setUpTownScreen(param1:SwfAsset) 
      {
         mTownRoot = param1.root;
         var _loc2_= new MovieClipRenderController(mDBFacade,mTownRoot);
         _loc2_.play((0 : UInt),true);
         mSceneGraphComponent.addChild(mTownRoot,(50 : UInt));
      }
      
      function setupPortraits() 
      {
         var _loc2_:GMSkin = null;
         var _loc3_= 0;
         var _loc1_:TextField = null;
         ASCompat.setProperty((mScoreReportRoot : ASAny).stats_a.stats.player_name, "text", mDungeonReport[0].name);
         ASCompat.setProperty((mScoreReportRoot : ASAny).stats_b.stats.player_name, "text", mDungeonReport[1].name);
         ASCompat.setProperty((mScoreReportRoot : ASAny).stats_c.stats.player_name, "text", mDungeonReport[2].name);
         ASCompat.setProperty((mScoreReportRoot : ASAny).stats_d.stats.player_name, "text", mDungeonReport[3].name);
         ASCompat.setProperty((mScoreReportRoot : ASAny).stats_a.stats.player_name, "textColor", PlayerSpecialStatus.getSpecialTextColor(mDungeonReport[0].name,(ASCompat.toInt((mScoreReportRoot : ASAny).stats_a.stats.player_name.textColor) : UInt)));
         ASCompat.setProperty((mScoreReportRoot : ASAny).stats_b.stats.player_name, "textColor", PlayerSpecialStatus.getSpecialTextColor(mDungeonReport[1].name,(ASCompat.toInt((mScoreReportRoot : ASAny).stats_b.stats.player_name.textColor) : UInt)));
         ASCompat.setProperty((mScoreReportRoot : ASAny).stats_c.stats.player_name, "textColor", PlayerSpecialStatus.getSpecialTextColor(mDungeonReport[2].name,(ASCompat.toInt((mScoreReportRoot : ASAny).stats_c.stats.player_name.textColor) : UInt)));
         ASCompat.setProperty((mScoreReportRoot : ASAny).stats_d.stats.player_name, "textColor", PlayerSpecialStatus.getSpecialTextColor(mDungeonReport[3].name,(ASCompat.toInt((mScoreReportRoot : ASAny).stats_d.stats.player_name.textColor) : UInt)));
         var _loc5_:Array<ASAny> = [(mScoreReportRoot : ASAny).stats_a.stats.avatar,(mScoreReportRoot : ASAny).stats_b.stats.avatar,(mScoreReportRoot : ASAny).stats_c.stats.avatar,(mScoreReportRoot : ASAny).stats_d.stats.avatar];
         var _loc4_:Array<ASAny> = [(mScoreReportRoot : ASAny).stats_a,(mScoreReportRoot : ASAny).stats_b,(mScoreReportRoot : ASAny).stats_c,(mScoreReportRoot : ASAny).stats_d];
         _loc3_ = 0;
         while(_loc3_ < 4)
         {
            if(mDungeonReport[_loc3_].valid == ASCompat.toNumber(true))
            {
               _loc1_ = ASCompat.dynamicAs(_loc4_[_loc3_].stats.trophies.trophies, flash.text.TextField);
               _loc1_.text = Std.string(mDungeonReport[_loc3_].trophyCount);
               _loc2_ = mDBFacade.gameMaster.getSkinByType(mDungeonReport[_loc3_].skin_type);
               if(_loc2_ == null)
               {
                  Logger.error("Could not find skin for skin_type: " + mDungeonReport[_loc3_].skin_type);
               }
               else
               {
                  loadPortraitForReport(mDungeonReport[_loc3_],_loc2_,ASCompat.dynamicAs(_loc5_[_loc3_], flash.display.MovieClip));
               }
            }
            else
            {
               ASCompat.setProperty(_loc5_[_loc3_], "visible", false);
            }
            _loc3_ = ASCompat.toInt(_loc3_) + 1;
         }
      }
      
      function loadPortraitForReport(param1:DungeonReport, param2:GMSkin, param3:MovieClip) 
      {
         var dungeonReport= param1;
         var skin= param2;
         var iconContainer= param3;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(skin.UISwfFilepath),function(param1:SwfAsset)
         {
            var _loc3_= param1.getClass(skin.IconName);
            var _loc2_= ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
            UIObject.scaleToFit(_loc2_,65);
            iconContainer.addChild(_loc2_);
            saveFacebookPicAndAchievement(dungeonReport.id,iconContainer);
         });
      }
      
      function showFacebookPic(param1:UInt) 
      {
         if(mFacebookPicHolder == null)
         {
            return;
         }
         var _loc2_= ASCompat.dynamicAs(mFacebookPicMap.itemFor(param1), FacebookPicHelper);
         if(_loc2_ == null)
         {
            return;
         }
         mFacebookPicHolder.addChild(_loc2_.pic);
         mFacebookPicHolder.visible = true;
         var _loc3_= _loc2_.root.localToGlobal(new Point(0,0));
         mFacebookPicHolder.x = _loc3_.x;
         mFacebookPicHolder.y = _loc3_.y - _loc2_.root.height / 2 - mFacebookPicHolder.height / 2;
      }
      
      function hideFacebookPic(param1:UInt) 
      {
         if(mFacebookPicHolder == null)
         {
            return;
         }
         mFacebookPicHolder.visible = false;
         var _loc2_= ASCompat.dynamicAs(mFacebookPicMap.itemFor(param1), FacebookPicHelper);
         if(_loc2_ == null)
         {
            return;
         }
         if(mFacebookPicHolder.contains(_loc2_.pic))
         {
            mFacebookPicHolder.removeChild(_loc2_.pic);
         }
      }
      
      function saveFacebookPicAndAchievement(param1:UInt, param2:MovieClip) 
      {
         var facebookId:String;
         var loader:Loader;
         var picUrl:String;
         var url:URLRequest;
         var lc:LoaderContext;
         var playerId= param1;
         var root= param2;
         var go= mFacade.gameObjectManager.getReferenceFromId(playerId);
         var player= ASCompat.reinterpretAs(go , PlayerGameObject);
         if(player == null || !ASCompat.stringAsBool(player.facebookId) || player.facebookId == "" || mDBFacade.isDRPlayer)
         {
            return;
         }
         if(mDBFacade.facebookController != null && player.isFriend && playerId != mDBFacade.accountId)
         {
            mDBFacade.facebookController.updateGuestAchievement((4 : UInt));
         }
         facebookId = player.facebookId;
         loader = new Loader();
         picUrl = "https://graph.facebook.com/" + facebookId + "/picture";
         url = new URLRequest(picUrl);
         loader.contentLoaderInfo.addEventListener("ioError",(cast function()
         {
         }));
         loader.contentLoaderInfo.addEventListener("securityError",(cast function()
         {
         }));
         loader.contentLoaderInfo.addEventListener("complete",function(param1:Event)
         {
            var facebookPic:DisplayObject;
            var helper:FacebookPicHelper;
            var e= param1;
            if(root == null)
            {
               return;
            }
            facebookPic = loader;
            facebookPic.x -= 25;
            facebookPic.y -= 25;
            helper = new FacebookPicHelper();
            helper.pic = facebookPic;
            helper.root = root;
            mFacebookPicMap.add(playerId,helper);
            root.addEventListener("rollOver",function(param1:flash.events.MouseEvent)
            {
               showFacebookPic(playerId);
            });
            root.addEventListener("rollOut",function(param1:flash.events.MouseEvent)
            {
               hideFacebookPic(playerId);
            });
         });
         lc = new LoaderContext(true);
         lc.checkPolicyFile = true;
         loader.load(url,lc);
      }
      
      function setupXPBars() 
      {
         var _loc7_= 0;
         var _loc4_:GMHero = null;
         var _loc5_= 0;
         var _loc2_= 0;
         var _loc1_= 0;
         var _loc8_= 0;
         var _loc6_= 0;
         ASCompat.setProperty((mScoreReportRoot : ASAny).stats_a.stats.fx_level_up_text, "visible", false);
         ASCompat.setProperty((mScoreReportRoot : ASAny).stats_b.stats.fx_level_up_text, "visible", false);
         ASCompat.setProperty((mScoreReportRoot : ASAny).stats_c.stats.fx_level_up_text, "visible", false);
         ASCompat.setProperty((mScoreReportRoot : ASAny).stats_d.stats.fx_level_up_text, "visible", false);
         ASCompat.setProperty((mScoreReportRoot : ASAny).stats_a.stats.fx_level_up_anim, "visible", false);
         ASCompat.setProperty((mScoreReportRoot : ASAny).stats_b.stats.fx_level_up_anim, "visible", false);
         ASCompat.setProperty((mScoreReportRoot : ASAny).stats_c.stats.fx_level_up_anim, "visible", false);
         ASCompat.setProperty((mScoreReportRoot : ASAny).stats_d.stats.fx_level_up_anim, "visible", false);
         var _loc3_:Array<ASAny> = [(mScoreReportRoot : ASAny).stats_a.stats.xp_bar.UI_XP,(mScoreReportRoot : ASAny).stats_b.stats.xp_bar.UI_XP,(mScoreReportRoot : ASAny).stats_c.stats.xp_bar.UI_XP,(mScoreReportRoot : ASAny).stats_d.stats.xp_bar.UI_XP];
         _loc7_ = 0;
         while(_loc7_ < 4)
         {
            if(mDungeonReport[_loc7_].valid != 0)
            {
               _loc4_ = ASCompat.dynamicAs(mDBFacade.gameMaster.heroById.itemFor(mDungeonReport[_loc7_].type), gameMasterDictionary.GMHero);
               _loc5_ = (_loc4_.getLevelFromExp(mDungeonReport[_loc7_].xp) : Int);
               _loc2_ = (mDungeonReport[_loc7_].xp : Int);
               _loc1_ = _loc4_.getLevelIndex(_loc2_);
               _loc8_ = ASCompat.toInt(_loc1_ > 0 ? _loc4_.getExpFromIndex((ASCompat.toInt(_loc1_ - 1) : UInt)) : 0);
               _loc6_ = (_loc4_.getExpFromIndex((_loc1_ : UInt)) : Int);
               mXpBar[_loc7_] = new UIProgressBar(mFacade,ASCompat.dynamicAs(_loc3_[_loc7_].xp_bar, flash.display.MovieClip));
               ASCompat.setProperty(mXpBar[_loc7_], "value", ASCompat.toNumber(_loc2_ - _loc8_) / ASCompat.toNumber(_loc6_ - _loc8_));
               ASCompat.setProperty(_loc3_[_loc7_].xp_level, "text", Std.string(_loc5_));
               ASCompat.setProperty(_loc3_[_loc7_].xp_points, "visible", true);
               ASCompat.setProperty(_loc3_[_loc7_].xp_points, "text", Std.string(mDungeonReport[_loc7_].xp));
            }
            else
            {
               ASCompat.setProperty(_loc3_[_loc7_], "visible", false);
            }
            _loc7_ = ASCompat.toInt(_loc7_) + 1;
         }
         mBoosterExpTick = (0 : UInt);
         mBoosterGoldTick = (0 : UInt);
      }
      
      public function TransactionResponse(param1:UInt, param2:UInt, param3:UInt, param4:UInt) 
      {
         var updateRevealPopupCallback:ASFunction;
         var details:ASObject;
         var callbackHelper:ASFunction;
         var account_id= param1;
         var succeeded= param2;
         var offer_id= param3;
         var weapon_id= param4;
         if(mDBFacade.accountId != account_id)
         {
            return;
         }
         closeBoosterPopup();
         updateRevealPopupCallback = function()
         {
         };
         if(succeeded != 0)
         {
            details = {};
            ASCompat.setProperty(details, "OfferId", offer_id);
            ASCompat.setProperty(details, "WeaponId", weapon_id);
            ASCompat.setProperty(details, "NewWeaponDetails", {});
            ASCompat.setProperty(details.NewWeaponDetails, "id", weapon_id);
            if(!mTookLastItem)
            {
               callbackHelper = function(param1:ASAny):ASFunction
               {
                  var details:ASObject = param1;
                  return function()
                  {
                     mChestRevealPopUp.updateRevealLoot(details);
                  };
               };
               updateRevealPopupCallback = ASCompat.asFunction(callbackHelper(details));
            }
            if(mInfoPopup != null)
            {
               if(mSelectedItemSlot == 1000 && mItemCount > 0)
               {
                  mDBFacade.metrics.log("DungeonLootTakeAll",{"itemCount":mItemCount});
               }
               removeItemFromSlot(mSelectedItemSlot);
            }
            if(mTookLastItem)
            {
               removeItemFromSlot(mSelectedItemSlot);
               if(!mFromInventory)
               {
                  if(mOpenKeyChestMC != null)
                  {
                     closeKeyChestPopup();
                  }
                  loadNextChestPopUp();
               }
            }
         }
         else
         {
            if(mInfoPopup != null)
            {
               mInfoPopup.destroy();
               mInfoPopup = null;
            }
            mChestTransactionFailedPopup = new DBUIPopup(mDBFacade,Locale.getString("TRANSACTION_FAILED"));
            MemoryTracker.track(mChestTransactionFailedPopup,"DBUIPopup - created in DistributedDungeonSummary.TransactionResponse()");
            mLogicalWorkComponent.doLater(1.5,function()
            {
               if(mChestTransactionFailedPopup != null)
               {
                  mChestTransactionFailedPopup.destroy();
                  mChestTransactionFailedPopup = null;
               }
            });
            if(!mTookLastItem)
            {
               if(mOpenKeyChestMC != null)
               {
                  closeKeyChestPopup();
               }
               mChestRevealPopUp.destroy();
               mChestRevealPopUp = null;
            }
            loadNextChestPopUp();
         }
         mEventComponent.addListener("DB_ACCOUNT_INFO_LOADED",function(param1:Event)
         {
            mEventComponent.removeListener("DB_ACCOUNT_INFO_LOADED");
            if(mInfoPopup != null)
            {
               mInfoPopup.destroy();
               mInfoPopup = null;
            }
            updateRevealPopupCallback();
            if(mTransactionSuccessCallback != null)
            {
               mTransactionSuccessCallback();
            }
         });
         mDBFacade.dbAccountInfo.getUsersFullAccountInfo();
      }
      
      public function openBoosterPopup() 
      {
         mBoosterPopup = new UIVictoryBoosterPopup(mDBFacade,Locale.getString("BOOSTER_POPUP"));
         MemoryTracker.track(mBoosterPopup,"UIVictoryBoosterPopup - created in DistributedDungeonSummary.openBoosterPopup()");
      }
      
      public function closeBoosterPopup() 
      {
         if(mBoosterPopup != null)
         {
            mBoosterPopup.destroy();
            mBoosterPopup = null;
         }
      }
      
      function loadChestIconCallback(param1:GMChest, param2:MovieClip, param3:UInt, param4:UInt, param5:UInt, param6:DistributedDungeonSummary) : ASFunction
      {
         var gmChest= param1;
         var loot= param2;
         var loot_type= param3;
         var player= param4;
         var slot= param5;
         var summary= param6;
         return function(param1:SwfAsset)
         {
            var _loc2_= param1.getClass(gmChest.IconName);
            if(_loc2_ != null)
            {
               mItemButtons[(player : Int)][slot] = new UIButton(mDBFacade,loot);
               ASCompat.setProperty(ASCompat.dynGetIndex(mItemButtons[(player : Int)], slot), "rolloverFilter", DBGlobal.UI_ROLLOVER_FILTER);
               ASCompat.setProperty(ASCompat.dynGetIndex(mItemButtons[(player : Int)], slot), "enabled", player == 0);
               ASCompat.setProperty(ASCompat.dynGetIndex(mItemButtons[(player : Int)], slot), "releaseCallback", chestPopupCallback(gmChest,slot));
            }
            else
            {
               Logger.error("Could not find asset class for loot item: " + Std.string(loot_type));
            }
         };
      }
      
      function getPlayerSlotItemCount(param1:Int) : Int
      {
         var _loc3_= 0;
         var _loc5_= 0;
         var _loc4_= mDungeonReport[param1];
         var _loc2_:Array<ASAny> = [_loc4_.chest_type_1,_loc4_.chest_type_2,_loc4_.chest_type_3,_loc4_.chest_type_4];
         if(_loc4_.valid == ASCompat.toNumber(true))
         {
            _loc3_ = 0;
            while(_loc3_ < _loc2_.length)
            {
               if(ASCompat.toNumber(_loc2_[_loc3_]) != 0)
               {
                  _loc5_++;
               }
               _loc3_ = ASCompat.toInt(_loc3_) + 1;
            }
         }
         return _loc5_;
      }
      
      function setupItemButtons() 
      {
         var _loc2_= 0;
         var _loc7_:DungeonReport = null;
         var _loc1_:Array<ASAny> = null;
         var _loc6_= 0;
         var _loc4_:GMChest = null;
         var _loc5_:Array<ASAny> = [(mScoreReportRoot : ASAny).stats_a,(mScoreReportRoot : ASAny).stats_b,(mScoreReportRoot : ASAny).stats_c,(mScoreReportRoot : ASAny).stats_d];
         var _loc3_= mUILootSlots;
         if(mUILootSlots == mUILootSlotsFourTreasures)
         {
            setUILootSlotsTwoTreasuresVisible(false);
         }
         if(mUILootSlots == mUILootSlotsTwoTreasures)
         {
            setUILootSlotsFourTreasuresVisible(false);
         }
         _loc2_ = 0;
         while(_loc2_ < 4)
         {
            _loc7_ = mDungeonReport[_loc2_];
            _loc1_ = [_loc7_.loot_type_1,_loc7_.loot_type_2,_loc7_.loot_type_3,_loc7_.loot_type_4];
            if(_loc7_.valid == ASCompat.toNumber(true))
            {
               _loc6_ = 0;
               while(_loc6_ < _loc1_.length)
               {
                  if(ASCompat.toNumber(_loc1_[_loc6_]) != 0)
                  {
                     _loc4_ = ASCompat.dynamicAs(mDBFacade.gameMaster.chestsById.itemFor(_loc1_[_loc6_]), gameMasterDictionary.GMChest);
                     if(_loc4_ != null && ASCompat.stringAsBool(_loc4_.IconName))
                     {
                        if(isSingleChestList[_loc2_])
                        {
                           if(_loc3_[_loc2_] == null || ASCompat.dynGetIndex(_loc3_[_loc2_], 2) == null)
                           {
                              Logger.warn("Could not load loot for singleChestList player slot: " + _loc2_);
                           }
                           else
                           {
                              ASCompat.setProperty(ASCompat.dynGetIndex(_loc3_[_loc2_], 2), "visible", false);
                              mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(_loc4_.IconSwf),loadChestIconCallback(_loc4_,ASCompat.dynamicAs(ASCompat.dynGetIndex(mChestMovieClips[_loc2_], 2), flash.display.MovieClip),(ASCompat.toInt(_loc1_[_loc6_]) : UInt),(_loc2_ : UInt),(_loc6_ : UInt),this));
                           }
                        }
                        else if(_loc3_[_loc2_] == null || ASCompat.dynGetIndex(_loc3_[_loc2_], _loc6_) == null)
                        {
                           Logger.warn("Could not load loot for player slot: " + _loc2_ + " chest slot: " + _loc6_);
                        }
                        else
                        {
                           ASCompat.setProperty(ASCompat.dynGetIndex(_loc3_[_loc2_], _loc6_), "visible", false);
                           mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(_loc4_.IconSwf),loadChestIconCallback(_loc4_,ASCompat.dynamicAs(ASCompat.dynGetIndex(mChestMovieClips[_loc2_], _loc6_), flash.display.MovieClip),(ASCompat.toInt(_loc1_[_loc6_]) : UInt),(_loc2_ : UInt),(_loc6_ : UInt),this));
                        }
                     }
                     else
                     {
                        Logger.error("Could not find GMChestItem for loot item: " + Std.string(_loc1_[_loc6_]));
                     }
                  }
                  _loc6_ = ASCompat.toInt(_loc6_) + 1;
               }
            }
            else
            {
               ASCompat.setProperty(_loc5_[_loc2_], "visible", false);
            }
            _loc2_ = ASCompat.toInt(_loc2_) + 1;
         }
      }
      
      function setupLoot() 
      {
         var mcr:MovieClipRenderer;
         var loot:Array<ASAny>;
         var yScale:Float;
         final __ax4_iter_201 = mChestRenderers;
         if (checkNullIteratee(__ax4_iter_201)) for (_tmp_ in __ax4_iter_201)
         {
            mcr  = _tmp_;
            mcr.destroy();
         }
         mChestRenderers.splice(0,(mChestRenderers.length : UInt));
         mItemCount = 0;
         mBonusXPTick = new Vector<UInt>((4 : UInt));
         mTeamBonusXPTick = new Vector<UInt>((4 : UInt));
         mKillsTick = new Vector<UInt>((4 : UInt));
         mItemCount = getPlayerSlotItemCount(0);
         yScale = 0.5;
         if(mItemCount > 2)
         {
            mUILootSlots = mUILootSlotsFourTreasures;
            yScale = 0.4;
         }
         else
         {
            mUILootSlots = mUILootSlotsTwoTreasures;
         }
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Doobers/db_items_doobers.swf"),function(param1:SwfAsset)
         {
            var _loc9_= 0;
            var _loc2_:Array<ASAny> = null;
            var _loc12_= 0;
            var _loc5_= 0;
            var _loc10_= 0;
            var _loc7_:GMDoober = null;
            var _loc8_:GMChest = null;
            var _loc6_:String = null;
            var _loc4_:String = null;
            var _loc11_:Point = null;
            var _loc3_:Array<ASAny> = null;
            loot = mUILootSlots;
            _loc9_ = 0;
            while(_loc9_ < 4)
            {
               _loc2_ = [mDungeonReport[_loc9_].chest_type_1,mDungeonReport[_loc9_].chest_type_2,mDungeonReport[_loc9_].chest_type_3,mDungeonReport[_loc9_].chest_type_4];
               _loc12_ = 0;
               _loc5_ = 0;
               while(_loc5_ < _loc2_.length)
               {
                  if(ASCompat.toBool(_loc2_[_loc5_]))
                  {
                     _loc12_++;
                  }
                  _loc5_ = ASCompat.toInt(_loc5_) + 1;
               }
               if(_loc12_ > 2)
               {
                  ASCompat.ASArray.sort(_loc2_, reverseChestTypeComparison);
               }
               else
               {
                  ASCompat.ASArray.sort(_loc2_, compareChestTypes);
               }
               if(mDungeonReport[_loc9_].valid == ASCompat.toNumber(true))
               {
                  _loc10_ = 0;
                  while(_loc10_ < 4)
                  {
                     if(!(ASCompat.toNumber(_loc2_[_loc10_]) == 0 || ASCompat.dynGetIndex(loot[_loc9_], _loc10_) == null))
                     {
                        _loc7_ = ASCompat.dynamicAs(mDBFacade.gameMaster.dooberById.itemFor(_loc2_[_loc10_]), gameMasterDictionary.GMDoober);
                        if(_loc7_ != null)
                        {
                           _loc8_ = ASCompat.dynamicAs(mDBFacade.gameMaster.chestsById.itemFor(_loc7_.ChestId), gameMasterDictionary.GMChest);
                           _loc6_ = _loc8_.IconSwf;
                           _loc4_ = _loc8_.IconName;
                           if(isSingleChestList[_loc9_])
                           {
                              _loc10_ = 2;
                           }
                           _loc11_ = new Point(ASCompat.toNumberField(ASCompat.dynGetIndex(loot[_loc9_], _loc10_), "x"),ASCompat.toNumberField(ASCompat.dynGetIndex(loot[_loc9_], _loc10_), "y"));
                           _loc3_ = mChestMovieClips;
                           ChestInfo.loadItemIcon(_loc6_,_loc4_,ASCompat.dynamicAs(ASCompat.dynGetIndex(mChestMovieClips[_loc9_], _loc10_), flash.display.DisplayObjectContainer),mDBFacade,(150 : UInt),(150 : UInt),mAssetLoadingComponent);
                           ASCompat.setProperty(ASCompat.dynGetIndex(mChestMovieClips[_loc9_], _loc10_), "scaleX", ASCompat.setProperty(ASCompat.dynGetIndex(mChestMovieClips[_loc9_], _loc10_), "scaleY", yScale));
                           ASCompat.setProperty(ASCompat.dynGetIndex(mChestMovieClips[_loc9_], _loc10_), "x", _loc11_.x);
                           ASCompat.setProperty(ASCompat.dynGetIndex(mChestMovieClips[_loc9_], _loc10_), "y", _loc11_.y);
                        }
                     }
                     _loc10_ = ASCompat.toInt(_loc10_) + 1;
                  }
               }
               _loc9_ = ASCompat.toInt(_loc9_) + 1;
            }
         });
         setupItemButtons();
      }
      
      public function compareChestTypes(param1:UInt, param2:UInt) : Int
      {
         if(param1 == 0)
         {
            return 1;
         }
         if(param2 == 0)
         {
            return -1;
         }
         var _loc3_= ASCompat.dynamicAs(mDBFacade.gameMaster.dooberById.itemFor(param1), gameMasterDictionary.GMDoober);
         var _loc4_= ASCompat.dynamicAs(mDBFacade.gameMaster.dooberById.itemFor(param2), gameMasterDictionary.GMDoober);
         if(mRarityMap.itemFor(_loc3_.Rarity) > mRarityMap.itemFor(_loc4_.Rarity))
         {
            return -1;
         }
         if(mRarityMap.itemFor(_loc4_.Rarity) > mRarityMap.itemFor(_loc3_.Rarity))
         {
            return 1;
         }
         return 0;
      }
      
      public function reverseChestTypeComparison(param1:UInt, param2:UInt) : Int
      {
         if(param1 == 0 || param2 == 0)
         {
            return 1;
         }
         var _loc3_= ASCompat.dynamicAs(mDBFacade.gameMaster.dooberById.itemFor(param1), gameMasterDictionary.GMDoober);
         var _loc4_= ASCompat.dynamicAs(mDBFacade.gameMaster.dooberById.itemFor(param2), gameMasterDictionary.GMDoober);
         if(mRarityMap.itemFor(_loc3_.Rarity) > mRarityMap.itemFor(_loc4_.Rarity))
         {
            return 1;
         }
         if(mRarityMap.itemFor(_loc4_.Rarity) > mRarityMap.itemFor(_loc3_.Rarity))
         {
            return -1;
         }
         return 0;
      }
      
      function setupWeapons() 
      {
         mWeapons = [];
         mWeaponTooltips = [];
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:SwfAsset)
         {
            var _loc2_= 0;
            var _loc3_= 0;
            _loc2_ = 0;
            while(_loc2_ < 4)
            {
               if(mDungeonReport[_loc2_].valid == ASCompat.toNumber(true))
               {
                  mWeapons.push([]);
                  mWeaponTooltips.push([]);
                  _loc3_ = 0;
                  while(_loc3_ < 3)
                  {
                     if(!(_loc3_ == 0 && mDungeonReport[_loc2_].weapon_type_1 == 0))
                     {
                        if(!(_loc3_ == 1 && mDungeonReport[_loc2_].weapon_type_2 == 0))
                        {
                           if(!(_loc3_ == 2 && mDungeonReport[_loc2_].weapon_type_3 == 0))
                           {
                              setupWeaponUIForStat(param1,(_loc2_ : UInt),(_loc3_ : UInt));
                           }
                        }
                     }
                     _loc3_ = ASCompat.toInt(_loc3_) + 1;
                  }
               }
               _loc2_ = ASCompat.toInt(_loc2_) + 1;
            }
         });
      }
      
      function setupWeaponUIForStat(param1:SwfAsset, param2:UInt, param3:UInt) 
      {
         var tooltipClass:Dynamic;
         var weaponTooltip:UIWeaponTooltip;
         var gmWeaponItem:GMWeaponItem = null;
         var gmWeaponAesthetic:GMWeaponAesthetic = null;
         var swfAsset= param1;
         var statNum= param2;
         var weaponSlotNum= param3;
         var weaponButtons:Array<ASAny> = [[(mScoreReportRoot : ASAny).stats_a.stats.loot_slot_A1,(mScoreReportRoot : ASAny).stats_a.stats.loot_slot_A2,(mScoreReportRoot : ASAny).stats_a.stats.loot_slot_A3],[(mScoreReportRoot : ASAny).stats_b.stats.loot_slot_A1,(mScoreReportRoot : ASAny).stats_b.stats.loot_slot_A2,(mScoreReportRoot : ASAny).stats_b.stats.loot_slot_A3],[(mScoreReportRoot : ASAny).stats_c.stats.loot_slot_A1,(mScoreReportRoot : ASAny).stats_c.stats.loot_slot_A2,(mScoreReportRoot : ASAny).stats_c.stats.loot_slot_A3],[(mScoreReportRoot : ASAny).stats_d.stats.loot_slot_A1,(mScoreReportRoot : ASAny).stats_d.stats.loot_slot_A2,(mScoreReportRoot : ASAny).stats_d.stats.loot_slot_A3]];
         var weapon= new UIObject(mDBFacade,ASCompat.dynamicAs(ASCompat.dynGetIndex(weaponButtons[(statNum : Int)], weaponSlotNum), flash.display.MovieClip));
         mWeapons.push(weapon);
         tooltipClass = swfAsset.getClass("DR_weapon_tooltip");
         weaponTooltip = new UIWeaponTooltip(mDBFacade,tooltipClass);
         ASCompat.dynPush(mWeaponTooltips[(statNum : Int)], weaponTooltip);
         switch(weaponSlotNum)
         {
            case 0:
               gmWeaponItem = ASCompat.dynamicAs(mDBFacade.gameMaster.weaponItemById.itemFor(mDungeonReport[(statNum : Int)].weapon_type_1), gameMasterDictionary.GMWeaponItem);
               gmWeaponAesthetic = gmWeaponItem.getWeaponAesthetic(mDungeonReport[(statNum : Int)].weapon_level_1,mDungeonReport[(statNum : Int)].legendary_modifier_type_1 > 0);
               
            case 1:
               gmWeaponItem = ASCompat.dynamicAs(mDBFacade.gameMaster.weaponItemById.itemFor(mDungeonReport[(statNum : Int)].weapon_type_2), gameMasterDictionary.GMWeaponItem);
               gmWeaponAesthetic = gmWeaponItem.getWeaponAesthetic(mDungeonReport[(statNum : Int)].weapon_level_2,mDungeonReport[(statNum : Int)].legendary_modifier_type_2 > 0);
               
            case 2:
               gmWeaponItem = ASCompat.dynamicAs(mDBFacade.gameMaster.weaponItemById.itemFor(mDungeonReport[(statNum : Int)].weapon_type_3), gameMasterDictionary.GMWeaponItem);
               gmWeaponAesthetic = gmWeaponItem.getWeaponAesthetic(mDungeonReport[(statNum : Int)].weapon_level_3,mDungeonReport[(statNum : Int)].legendary_modifier_type_3 > 0);
         }
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmWeaponAesthetic.IconSwf),function(param1:SwfAsset)
         {
            var rarity:GMRarity = null;
            var bgColoredExists:Bool;
            var bgSwfPath:String;
            var bgIconName:String;
            var swfAsset= param1;
            var weaponClass= swfAsset.getClass(gmWeaponAesthetic.IconName);
            var weaponMC= ASCompat.dynamicAs(ASCompat.createInstance(weaponClass, []) , MovieClip);
            weaponMC.scaleX = weaponMC.scaleY = 0.5;
            weapon.root.addChild(weaponMC);
            weapon.tooltip = weaponTooltip;
            switch(weaponSlotNum)
            {
               case 0:
                  rarity = ASCompat.dynamicAs(mDBFacade.gameMaster.rarityById.itemFor(mDungeonReport[(statNum : Int)].weapon_rarity_1), gameMasterDictionary.GMRarity);
                  
               case 1:
                  rarity = ASCompat.dynamicAs(mDBFacade.gameMaster.rarityById.itemFor(mDungeonReport[(statNum : Int)].weapon_rarity_2), gameMasterDictionary.GMRarity);
                  
               case 2:
                  rarity = ASCompat.dynamicAs(mDBFacade.gameMaster.rarityById.itemFor(mDungeonReport[(statNum : Int)].weapon_rarity_3), gameMasterDictionary.GMRarity);
            }
            bgColoredExists = rarity.HasColoredBackground;
            bgSwfPath = rarity.BackgroundSwf;
            bgIconName = rarity.BackgroundIcon;
            if(bgColoredExists)
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(bgSwfPath),function(param1:SwfAsset)
               {
                  var _loc3_:MovieClip = null;
                  var _loc2_= param1.getClass(bgIconName);
                  if(_loc2_ != null)
                  {
                     _loc3_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []) , MovieClip);
                     _loc3_.scaleX = _loc3_.scaleY = 0.65;
                     weapon.root.addChildAt(_loc3_,1);
                  }
               });
            }
            switch(weaponSlotNum)
            {
               case 0:
                  weaponTooltip.setWeaponItemFromData(gmWeaponAesthetic.Name,mDungeonReport[(statNum : Int)].weapon_power_1,gmWeaponItem.TapIcon,gmWeaponItem.HoldIcon,mDungeonReport[(statNum : Int)].modifier_type_1a,mDungeonReport[(statNum : Int)].modifier_type_1b,mDungeonReport[(statNum : Int)].legendary_modifier_type_1,mDungeonReport[(statNum : Int)].weapon_rarity_1,mDungeonReport[(statNum : Int)].weapon_level_1);
                  
               case 1:
                  weaponTooltip.setWeaponItemFromData(gmWeaponAesthetic.Name,mDungeonReport[(statNum : Int)].weapon_power_2,gmWeaponItem.TapIcon,gmWeaponItem.HoldIcon,mDungeonReport[(statNum : Int)].modifier_type_2a,mDungeonReport[(statNum : Int)].modifier_type_2b,mDungeonReport[(statNum : Int)].legendary_modifier_type_2,mDungeonReport[(statNum : Int)].weapon_rarity_2,mDungeonReport[(statNum : Int)].weapon_level_2);
                  
               case 2:
                  weaponTooltip.setWeaponItemFromData(gmWeaponAesthetic.Name,mDungeonReport[(statNum : Int)].weapon_power_3,gmWeaponItem.TapIcon,gmWeaponItem.HoldIcon,mDungeonReport[(statNum : Int)].modifier_type_3a,mDungeonReport[(statNum : Int)].modifier_type_3b,mDungeonReport[(statNum : Int)].legendary_modifier_type_3,mDungeonReport[(statNum : Int)].weapon_rarity_3,mDungeonReport[(statNum : Int)].weapon_level_3);
            }
         });
      }
      
      public function compareOnChestValues(param1:Array<ASAny>, param2:Array<ASAny>) : Int
      {
         return compareChestTypes((ASCompat.toInt(param1[1]) : UInt),(ASCompat.toInt(param2[1]) : UInt));
      }
      
      public function loadNextChestPopUp() 
      {
         var _loc1_= 0;
         var _loc8_:Array<ASAny> = null;
         var _loc4_:GMChest = null;
         var _loc6_= 0;
         var _loc2_= 0;
         mDBFacade.dbAccountInfo.getUsersFullAccountInfo();
         var _loc7_= mDungeonReport[0];
         var _loc5_:Array<ASAny> = [_loc7_.chest_type_1,_loc7_.chest_type_2,_loc7_.chest_type_3,_loc7_.chest_type_4];
         var _loc3_:Array<ASAny> = [];
         _loc1_ = 0;
         while(_loc1_ < 4)
         {
            _loc8_ = [_loc1_,_loc5_[_loc1_]];
            _loc3_.push(_loc8_);
            _loc1_++;
         }
         ASCompat.ASArray.sort(_loc3_, compareOnChestValues);
         if(_loc7_.valid != 0)
         {
            if(ASCompat.toNumber(ASCompat.dynGetIndex(_loc3_[0], 1)) != 0)
            {
               _loc6_ = ASCompat.toInt(ASCompat.dynGetIndex(_loc3_[0], 0));
               _loc2_ = ASCompat.toInt(ASCompat.dynGetIndex(_loc3_[0], 1));
               _loc4_ = ASCompat.dynamicAs(mDBFacade.gameMaster.chestsById.itemFor(mDBFacade.gameMaster.dooberById.itemFor(_loc2_).ChestId), gameMasterDictionary.GMChest);
               chestOpenPopUp(_loc4_,(_loc6_ : UInt));
               return;
            }
         }
      }
      
      function chestOpenPopUp(param1:GMChest, param2:UInt) 
      {
         mSelectedItemSlot = param2;
         mSelectedGMChest = param1;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_score_report.swf"),setupOpenKeyChest);
      }
      
            
      @:isVar public var dungeonSuccess(get,set):UInt;
public function  set_dungeonSuccess(param1:UInt) :UInt      {
         if(param1 == 0)
         {
            mDungeonSuccess = false;
         }
         else if(param1 == 1)
         {
            mDungeonSuccess = true;
         }
         else
         {
            Logger.error("Unable to parse value to a bool.  Value: " + param1);
         }
return param1;
      }
function  get_dungeonSuccess() : UInt
      {
         return (ASCompat.toInt(mDungeonSuccess) : UInt);
      }
      
      function chestPopupCallback(param1:GMChest, param2:UInt) : ASFunction
      {
         var gmChest= param1;
         var slot= param2;
         return function()
         {
            chestOpenPopUp(gmChest,slot);
         };
      }
      
      function setupOpenKeyChest(param1:SwfAsset) 
      {
         var openKeyChestClass:Dynamic;
         var bounds:Rectangle;
         var swfPath:String;
         var iconName:String;
         var rarity:GMRarity;
         var bgColoredExists:Bool;
         var bgSwfPath:String;
         var bgIconName:String;
         var keys:Vector<KeyInfo>;
         var i:Int;
         var swfAsset= param1;
         mSceneGraphComponent.showPopupCurtain();
         openKeyChestClass = UIHud.isThisAConsumbleChestId((mSelectedGMChest.Id : Int)) ? swfAsset.getClass("popup_itemBox") : swfAsset.getClass("popup_chest");
         mOpenKeyChestMC = ASCompat.dynamicAs(ASCompat.createInstance(openKeyChestClass, []), flash.display.MovieClip);
         mOpenKeyChestMC.scaleX = mOpenKeyChestMC.scaleY = 1.8;
         bounds = mOpenKeyChestMC.getBounds(mDBFacade.stageRef);
         mOpenKeyChestMC.x = mDBFacade.stageRef.stageWidth / 2 - bounds.width / 2 - bounds.x;
         mOpenKeyChestMC.y = mDBFacade.stageRef.stageHeight / 2 - bounds.height / 2 - bounds.y;
         ASCompat.setProperty((mOpenKeyChestMC : ASAny).title_label, "text", Locale.getString("TREASURE_FOUND"));
         swfPath = mSelectedGMChest.IconSwf;
         iconName = mSelectedGMChest.IconName;
         ChestInfo.loadItemIcon(swfPath,iconName,ASCompat.dynamicAs((mOpenKeyChestMC : ASAny).content, flash.display.DisplayObjectContainer),mDBFacade,(150 : UInt),(150 : UInt),mAssetLoadingComponent);
         rarity = ASCompat.dynamicAs(mDBFacade.gameMaster.rarityByConstant.itemFor(mSelectedGMChest.Rarity), gameMasterDictionary.GMRarity);
         bgColoredExists = rarity.HasColoredBackground;
         bgSwfPath = rarity.BackgroundSwf;
         bgIconName = rarity.BackgroundIcon;
         if(bgColoredExists)
         {
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(bgSwfPath),function(param1:SwfAsset)
            {
               var _loc3_:MovieClip = null;
               var _loc2_= param1.getClass(bgIconName);
               if(_loc2_ != null)
               {
                  _loc3_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []) , MovieClip);
                  (mOpenKeyChestMC : ASAny).content.addChildAt(_loc3_,0);
                  _loc3_.scaleX = _loc3_.scaleY = 1.5;
               }
            });
         }
         mOpenKeyChestRenderer = new MovieClipRenderer(mDBFacade,ASCompat.dynamicAs((mOpenKeyChestMC : ASAny).content, flash.display.MovieClip));
         mOpenKeyChestRenderer.play((0 : UInt),true);
         mAbandonButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mOpenKeyChestMC : ASAny).abandon_button, flash.display.MovieClip));
         mAbandonButton.releaseCallback = abandonChestCallback;
         mAbandonButton.label.text = Locale.getString("ABANDON");
         mKeepButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mOpenKeyChestMC : ASAny).keep_button, flash.display.MovieClip));
         mKeepButton.releaseCallback = keepChestCallback;
         mKeepButton.label.text = Locale.getString("KEEP");
         mOpenButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mOpenKeyChestMC : ASAny).open_button, flash.display.MovieClip));
         mOpenButton.releaseCallback = openChestCallback;
         mOpenButton.label.text = Locale.getString("UNLOCK");
         ASCompat.setProperty((mOpenKeyChestMC : ASAny).close, "visible", false);
         keys = mDBFacade.dbAccountInfo.inventoryInfo.keys;
         i = 0;
         while(i < keys.length)
         {
            if(mSelectedGMChest.Id == keys[i].gmKey.ChestId)
            {
               mKeyThatCanOpenChest = keys[i];
            }
            i = i + 1;
         }
         if(!UIHud.isThisAConsumbleChestId((mSelectedGMChest.Id : Int)))
         {
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(mKeyThatCanOpenChest.gmKeyOffer.BundleSwfFilepath),loadKeyIconOnButton);
            refreshHeroInfoUI(mOpenKeyChestMC);
         }
         mSceneGraphComponent.addChild(mOpenKeyChestMC,(105 : UInt));
      }
      
      public function refreshHeroInfoUI(param1:MovieClip) 
      {
         var mHeroInfo:AvatarInfo;
         var gmSkin:GMSkin;
         var chestMC= param1;
         ASCompat.setProperty((chestMC : ASAny).hero_label, "text", Locale.getString("OPENING_WITH"));
         mHeroInfo = mDBFacade.dbAccountInfo.activeAvatarInfo;
         gmSkin = mDBFacade.gameMaster.getSkinByType(mHeroInfo.skinId);
         if(gmSkin == null)
         {
            Logger.error("Unable to find gmSkin for ID: " + mHeroInfo.skinId);
         }
         else
         {
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmSkin.IconSwfFilepath),function(param1:SwfAsset)
            {
               var _loc3_= param1.getClass(gmSkin.IconName);
               if(_loc3_ == null)
               {
                  return;
               }
               var _loc4_= ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
               var _loc2_= new MovieClipRenderController(mDBFacade,_loc4_);
               _loc2_.play();
               if(ASCompat.toNumberField((chestMC : ASAny).avatar, "numChildren") > 0)
               {
                  (chestMC : ASAny).avatar.removeChildAt(0);
               }
               (chestMC : ASAny).avatar.addChildAt(_loc4_,0);
               _loc4_.scaleX = _loc4_.scaleY = 1;
            });
         }
      }
      
      function loadKeyIconOnButton(param1:SwfAsset) 
      {
         var _loc3_= param1.getClass(mKeyThatCanOpenChest.gmKeyOffer.BundleIcon);
         var _loc2_= ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []) , MovieClip);
         _loc2_.scaleX = _loc2_.scaleY = 0.5;
         if(ASCompat.toNumberField((mOpenButton.root : ASAny).pick, "numChildren") > 1)
         {
            (mOpenButton.root : ASAny).pick.removeChildAt(1);
         }
         (mOpenButton.root : ASAny).pick.addChild(_loc2_);
      }
      
      function setupOpenKeylessChest(param1:SwfAsset) 
      {
         mChestBuyKeysPopUp = new ChestBuyKeysPopUp(mDBFacade,mAssetLoadingComponent,mSceneGraphComponent,param1,mSelectedGMChest,chestBuyCoinCallback,chestBuyGemCallback,closeKeylessChestPopup,refreshHeroInfoUI,true);
      }
      
      function createKeySlots(param1:MovieClip) 
      {
         var _loc3_= 0;
         var _loc2_:MovieClip = null;
         mChestKeySlots = new Vector<ChestKeySlot>();
         _loc3_ = 0;
         while(_loc3_ < 4)
         {
            _loc2_ = ASCompat.reinterpretAs(param1.getChildByName("slot_" + Std.string(_loc3_)) , MovieClip);
            mChestKeySlots.push(new ChestKeySlot(mDBFacade,_loc2_,mDBFacade.dbAccountInfo.inventoryInfo.keys[_loc3_],mAssetLoadingComponent));
            if(mSelectedGMChest.Id == mChestKeySlots[_loc3_].keyInfo.gmKey.ChestId)
            {
               mChestKeySlots[_loc3_].setSelected(true);
            }
            else
            {
               mChestKeySlots[_loc3_].setSelected(false);
            }
            _loc3_++;
         }
      }
      
      function chestBuyCoinCallback(param1:Float) : ASFunction
      {
         var val= param1;
         return function()
         {
            var _loc1_= 0;
            var _loc2_= 0;
            mDBFacade.metrics.log("ChestUnlockCoinTry",{
               "chestId":mSelectedGMChest.Id,
               "rarity":mSelectedGMChest.Rarity,
               "category":"dungeonSummary"
            });
            if(mDBFacade.dbAccountInfo.basicCurrency >= val)
            {
               mDBFacade.metrics.log("ChestUnlockCoin",{
                  "chestId":mSelectedGMChest.Id,
                  "rarity":mSelectedGMChest.Rarity,
                  "category":"dungeonSummary"
               });
               closeKeylessChestPopup();
               closeKeyChestPopup();
               mInfoPopup = new DBUIPopup(mDBFacade,Locale.getString("PURCHASING..."));
               MemoryTracker.track(mInfoPopup,"DBUIPopup - created in DistributedDungeonSummary.chestBuyCoinCallback()");
               mSceneGraphComponent.addChild(mInfoPopup.root,(105 : UInt));
               _loc1_ = 0;
               while(_loc1_ < 6)
               {
                  if(mDBFacade.dbAccountInfo.inventoryInfo.keys[_loc1_].gmKey.ChestId == mSelectedGMChest.Id)
                  {
                     _loc2_ = (mDBFacade.dbAccountInfo.inventoryInfo.keys[_loc1_].gmKeyOffer.Id : Int);
                     StoreServices.purchaseOffer(mDBFacade,(_loc2_ : UInt),boughtKey,boughtKeyError,(0 : UInt),false);
                     break;
                  }
                  _loc1_++;
               }
            }
            else
            {
               StoreServicesController.showCoinPage(mDBFacade);
            }
         };
      }
      
      function chestBuyGemCallback(param1:Float) : ASFunction
      {
         var val= param1;
         return function()
         {
            var _loc1_= 0;
            var _loc2_= 0;
            mDBFacade.metrics.log("ChestUnlockGemTry",{
               "chestId":mSelectedGMChest.Id,
               "rarity":mSelectedGMChest.Rarity,
               "category":"dungeonSummary"
            });
            if(mDBFacade.dbAccountInfo.premiumCurrency >= val)
            {
               mDBFacade.metrics.log("ChestUnlockGem",{
                  "chestId":mSelectedGMChest.Id,
                  "rarity":mSelectedGMChest.Rarity,
                  "category":"dungeonSummary"
               });
               closeKeylessChestPopup();
               closeKeyChestPopup();
               mInfoPopup = new DBUIPopup(mDBFacade,Locale.getString("PURCHASING..."));
               MemoryTracker.track(mInfoPopup,"DBUIPopup - created in DistributedDungeonSummary.chestBuyGemCallback()");
               mSceneGraphComponent.addChild(mInfoPopup.root,(105 : UInt));
               _loc1_ = 0;
               while(_loc1_ < 6)
               {
                  if(mDBFacade.dbAccountInfo.inventoryInfo.keys[_loc1_].gmKey.ChestId == mSelectedGMChest.Id)
                  {
                     _loc2_ = (mDBFacade.dbAccountInfo.inventoryInfo.keys[_loc1_].gmKeyOffer.Id : Int);
                     StoreServices.purchaseOffer(mDBFacade,(_loc2_ : UInt),boughtKey,boughtKeyError,(0 : UInt),false);
                     break;
                  }
                  _loc1_++;
               }
            }
            else
            {
               StoreServicesController.showCashPage(mDBFacade,"chestOpenWithGemsAttemptDungeonSummary");
            }
         };
      }
      
      function abandonChestCallback(param1:String = "dungeonSummaryChestPopUp") 
      {
         var category= param1;
         mAbandonChestPopUp = new DBUITwoButtonPopup(mDBFacade,Locale.getString("ABANDON_CHEST_POPUP_TITLE"),Locale.getString("ABANDON_CHEST_POPUP_DESC"),Locale.getString("ABANDON_CHEST_POPUP_CANCEL"),closeAbandonChestPopUp,Locale.getString("ABANDON_CHEST_POPUP_CONFIRM"),function()
         {
            mNetworkComponent.send_DropChest(mDBFacade.dbAccountInfo.id,mSelectedItemSlot);
            mDBFacade.metrics.log("ChestAbandoned",{
               "chestId":mSelectedGMChest.Id,
               "rarity":mSelectedGMChest.Rarity,
               "category":category
            });
            removeItemFromSlot(mSelectedItemSlot);
            closeKeyChestPopup();
            loadNextChestPopUp();
            closeAbandonChestPopUp();
         },false,null);
         MemoryTracker.track(mAbandonChestPopUp,"DBUITwoButtonPopup - created in DistributedDungeonSummary.abandonChestCallback()");
         mAbandonChestPopUp.root.y += 180;
      }
      
      function closeAbandonChestPopUp() 
      {
         if(mAbandonChestPopUp != null)
         {
            mAbandonChestPopUp.destroy();
            mAbandonChestPopUp = null;
         }
      }
      
      public function abandonChestFromInventory(param1:UInt) 
      {
         mNetworkComponent.send_DropChest(mDBFacade.dbAccountInfo.id,mSelectedItemSlot);
         removeItemFromSlot(param1);
         mUIInventory.refresh(true);
      }
      
      function keepChestCallback() 
      {
         if(mDBFacade.dbAccountInfo.inventoryInfo.isThereEmptySpaceInWeaponStorage())
         {
            closeKeyChestPopup();
            keepChestFromInventory(mSelectedItemSlot,false);
         }
         else
         {
            mStorageFullPopUp = new DBUITwoButtonPopup(mDBFacade,Locale.getString("GO_TO_INVENTORY_TITLE"),Locale.getString("GO_TO_INVENTORY_BODY"),Locale.getString("INVENTORY"),function()
            {
               closeKeyChestPopup();
               openInventory();
            },Locale.getString("ABANDON"),function()
            {
               abandonChestCallback("dungeonSummaryInventoryFullOnKeep");
            },true,null);
            MemoryTracker.track(mStorageFullPopUp,"DBUITwoButtonPopup - created in DistributedDungeonSummary.keepChestCallback()");
            mStorageFullPopUp.root.y += 180;
         }
      }
      
      public function keepChestFromInventory(param1:UInt, param2:Bool) 
      {
         if(param2)
         {
            mDBFacade.metrics.log("ChestKept",{
               "chestId":mSelectedGMChest.Id,
               "rarity":mSelectedGMChest.Id,
               "category":"storageFromDungeonSummary"
            });
         }
         else
         {
            mDBFacade.metrics.log("ChestKept",{
               "chestId":mSelectedGMChest.Id,
               "rarity":mSelectedGMChest.Id,
               "category":"dungeonSummary"
            });
         }
         mSelectedItemSlot = param1;
         mFromInventory = param2;
         mTookLastItem = true;
         mNetworkComponent.send_TakeChest(mDBFacade.dbAccountInfo.id,mSelectedItemSlot);
         mInfoPopup = new DBUIPopup(mDBFacade,Locale.getString("TAKING_ITEM"));
         MemoryTracker.track(mInfoPopup,"DBUIPopup - created in DistributedDungeonSummary.keepChestFromInventory()");
      }
      
      function openChestCallback() 
      {
         var doesKeyExist:Bool;
         var i:Int;
         if(mDBFacade.dbAccountInfo.inventoryInfo.isThereEmptySpaceInWeaponStorage())
         {
            doesKeyExist = false;
            i = 0;
            while(i < 4)
            {
               if(mDBFacade.dbAccountInfo.inventoryInfo.keys[i].gmKey.ChestId == mSelectedGMChest.Id && mDBFacade.dbAccountInfo.inventoryInfo.keys[i].count > 0)
               {
                  doesKeyExist = true;
               }
               i = i + 1;
            }
            if(doesKeyExist)
            {
               boughtKey(null);
            }
            else
            {
               mOpenKeyChestMC.visible = false;
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_score_report.swf"),setupOpenKeylessChest);
            }
         }
         else
         {
            mStorageFullPopUp = new DBUITwoButtonPopup(mDBFacade,Locale.getString("GO_TO_INVENTORY_TITLE"),Locale.getString("GO_TO_INVENTORY_BODY_OPEN"),Locale.getString("INVENTORY"),function()
            {
               closeKeyChestPopup();
               openInventory();
            },Locale.getString("ABANDON"),function()
            {
               abandonChestCallback("abandonFromUnlockOnChestWithFullInventory");
            },true,null);
            MemoryTracker.track(mStorageFullPopUp,"DBUITwoButtonPopup - created in DistributedDungeonSummary.openChestCallback()");
            mStorageFullPopUp.root.y += 180;
         }
      }
      
      function boughtKey(param1:ASAny) 
      {
         mDBFacade.metrics.log("ChestUnlockKey",{
            "chestId":mSelectedGMChest.Id,
            "rarity":mSelectedGMChest.Rarity,
            "category":"dungeonSummary"
         });
         if(mInfoPopup != null)
         {
            mSceneGraphComponent.removeChild(mInfoPopup.root);
            mInfoPopup.destroy();
            mInfoPopup = null;
         }
         openChestFromInventory(mSelectedGMChest,false);
      }
      
      public function findSlotForChest(param1:GMChest) : UInt
      {
         var _loc4_= 0;
         var _loc3_:GMDoober = null;
         var _loc2_:Array<ASAny> = [mDungeonReport[0].chest_type_1,mDungeonReport[0].chest_type_2,mDungeonReport[0].chest_type_3,mDungeonReport[0].chest_type_4];
         if(mDungeonReport[0].valid == ASCompat.toNumber(true))
         {
            _loc4_ = 0;
            while(_loc4_ < 4)
            {
               if(ASCompat.toNumber(_loc2_[_loc4_]) != 0)
               {
                  _loc3_ = ASCompat.dynamicAs(mDBFacade.gameMaster.dooberById.itemFor(_loc2_[_loc4_]), gameMasterDictionary.GMDoober);
                  if(_loc3_.ChestId == param1.Id)
                  {
                     return (_loc4_ : UInt);
                  }
               }
               _loc4_ = ASCompat.toInt(_loc4_) + 1;
            }
         }
         return (0 : UInt);
      }
      
      public function openChestFromInventory(param1:GMChest, param2:Bool) 
      {
         var _loc3_= findSlotForChest(param1);
         mFromInventory = param2;
         mTookLastItem = false;
         mNetworkComponent.send_OpenChest(mDBFacade.dbAccountInfo.id,_loc3_);
         mSceneGraphComponent.fadeOut(0.5,0.75);
         if(param2)
         {
            mChestRevealPopUp = new ChestRevealPopUp(mDBFacade,param1,closeChestRevealPopUp,equipItemFromInventory);
         }
         else
         {
            mChestRevealPopUp = new ChestRevealPopUp(mDBFacade,param1,closeChestRevealPopUp,goToStorageChestRevealPopUp);
         }
         removeItemFromSlot(_loc3_);
         if(mOpenKeyChestMC != null)
         {
            closeKeyChestPopup();
         }
      }
      
      function equipItemFromInventory(param1:UInt, param2:UInt, param3:Bool) 
      {
         mSceneGraphComponent.fadeIn(0.5);
         if(mChestRevealPopUp != null)
         {
            mChestRevealPopUp.destroy();
            mChestRevealPopUp = null;
         }
         if(mTownHeader != null)
         {
            mTownHeader.refreshKeyPanel();
         }
         mUIInventory.setRevealedState(param1,param2,param3);
         mUIInventory.refresh();
      }
      
      function goToStorageChestRevealPopUp(param1:UInt, param2:UInt, param3:Bool) 
      {
         mRevealedItemType = param1;
         mRevealedItemOfferId = param2;
         mRevealedItemCallEquip = param3;
         mSceneGraphComponent.fadeIn(0.5);
         if(mChestRevealPopUp != null)
         {
            mChestRevealPopUp.destroy();
            mChestRevealPopUp = null;
         }
         if(mTownHeader != null)
         {
            mTownHeader.refreshKeyPanel();
         }
         openInventory();
      }
      
      function boughtKeyError(param1:JSONParseError) 
      {
         Logger.warn("Error buying keys from Reward Screen");
      }
      
      function closeChestRevealPopUp(param1:UInt, param2:UInt, param3:Bool) 
      {
         mRevealedItemType = param1;
         mRevealedItemOfferId = param2;
         mSceneGraphComponent.fadeIn(0.5);
         if(mChestRevealPopUp != null)
         {
            mChestRevealPopUp.destroy();
            mChestRevealPopUp = null;
         }
         if(!mFromInventory)
         {
            loadNextChestPopUp();
         }
         else if(param3)
         {
            mUIInventory.setRevealedState(mRevealedItemType,mRevealedItemOfferId);
            mUIInventory.refresh();
         }
         if(mTownHeader != null)
         {
            mTownHeader.refreshKeyPanel();
         }
      }
      
      function closeKeyChestPopup() 
      {
         if(mOpenKeyChestMC != null)
         {
            mAbandonButton.destroy();
            mAbandonButton = null;
            mKeepButton.destroy();
            mKeepButton = null;
            mOpenButton.destroy();
            mOpenButton = null;
            mOpenKeyChestRenderer.destroy();
            mOpenKeyChestRenderer = null;
            mSceneGraphComponent.removeChild(mOpenKeyChestMC);
            mOpenKeyChestMC = null;
            mSceneGraphComponent.removePopupCurtain();
         }
      }
      
      function closeKeylessChestPopup() 
      {
         if(mChestBuyKeysPopUp != null)
         {
            mChestBuyKeysPopUp.destroy();
            mChestBuyKeysPopUp = null;
         }
         mOpenKeyChestMC.visible = true;
      }
      
      function chatCallback(param1:UInt) : ASFunction
      {
         var playerIndex= param1;
         return function(param1:ChatEvent)
         {
            var event= param1;
            mChatBalloon[(playerIndex : Int)].showBalloon();
            mChatBalloon[(playerIndex : Int)].text = event.message;
            if(mChatCloseTask[(playerIndex : Int)] != null)
            {
               mChatCloseTask[(playerIndex : Int)].destroy();
            }
            mChatCloseTask[(playerIndex : Int)] = mWorkComponent.doLater(5,function()
            {
               mChatBalloon[(playerIndex : Int)].hideBalloon();
            });
         };
      }
      
      function typingCallback(param1:UInt) : ASFunction
      {
         var playerIndex= param1;
         return function(param1:events.PlayerIsTypingEvent)
         {
            if(param1.subtype == "CHAT_BOX_FOCUS_IN")
            {
               mChatBalloon[(playerIndex : Int)].showPlayerTyping();
            }
            else
            {
               mChatBalloon[(playerIndex : Int)].hidePlayerTyping();
            }
         };
      }
      
      function setupChat() 
      {
         var i= (0 : UInt);
         while(i < 4)
         {
            if(mDungeonReport[(i : Int)].valid != 0)
            {
               mChatBalloon[(i : Int)] = new ChatBalloon();
               mChatBalloon[(i : Int)].hideBalloon();
               mChatEventComponent.addListener(GameObjectEvent.uniqueEvent("ChatEvent_INCOMING_CHAT_UPDATE",mDungeonReport[(i : Int)].id),chatCallback(i));
               mChatEventComponent.addListener(GameObjectEvent.uniqueEvent("PLAYER_IS_TYPING",mDungeonReport[(i : Int)].id),typingCallback(i));
            }
            i = i + 1;
         }
         mUIChatLog = new UIChatLog(mDBFacade,ASCompat.dynamicAs((mScoreReportRoot : ASAny).chatLogContainer, flash.display.MovieClip),ASCompat.dynamicAs((mScoreReportRoot : ASAny).UI_chat, flash.display.MovieClip),ASCompat.dynamicAs((mScoreReportRoot : ASAny).UI_chat.log_btn, flash.display.MovieClip),ASCompat.dynamicAs((mScoreReportRoot : ASAny).UI_chat.chat_btn, flash.display.MovieClip));
         mUIChatLog.hideChatLog();
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_nametag.swf"),function(param1:SwfAsset)
         {
            var _loc3_:Dynamic = null;
            var _loc2_:MovieClip = null;
            var _loc6_:Dynamic = null;
            var _loc5_:Point = null;
            var _loc4_:Array<ASAny> = [(mScoreReportRoot : ASAny).stats_a,(mScoreReportRoot : ASAny).stats_b,(mScoreReportRoot : ASAny).stats_c,(mScoreReportRoot : ASAny).stats_d];
            i = (0 : UInt);
            while(i < 4)
            {
               if(mDungeonReport[(i : Int)].valid != 0)
               {
                  _loc3_ = param1.getClass("UI_speechbubble");
                  _loc2_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
                  _loc2_.visible = false;
                  _loc6_ = param1.getClass("UI_speechbubble_typing");
                  mPlayerIsTypingNotification = ASCompat.dynamicAs(ASCompat.createInstance(_loc6_, []), flash.display.MovieClip);
                  mPlayerIsTypingNotification.visible = false;
                  mChatBalloon[(i : Int)].initializeChatBalloon(param1,mPlayerIsTypingNotification);
                  mSceneGraphComponent.addChild(mChatBalloon[(i : Int)],(50 : UInt));
                  mChatBalloon[(i : Int)].text = "";
                  _loc5_ = ASCompat.dynamicAs(_loc4_[(i : Int)].stats.player_name.localToGlobal(new Point(0,0)), flash.geom.Point);
                  mChatBalloon[(i : Int)].scaleY = mChatBalloon[(i : Int)].scaleX = 1.8;
                  mChatBalloon[(i : Int)].x = _loc5_.x + 69 + 55;
                  mChatBalloon[(i : Int)].y = _loc5_.y + 32 - 32;
                  mChatBalloon[(i : Int)].hideBalloon();
               }
               i = i + 1;
            }
         });
      }
      
      function sendChat(param1:String) 
      {
         var value= param1;
         mDBFacade.regainFocus();
         if(ASCompat.stringAsBool(value))
         {
            mChatBalloon[0].showBalloon();
            mChatBalloon[0].text = value;
            if(mChatCloseTask[0] != null)
            {
               mChatCloseTask[0].destroy();
            }
            mChatCloseTask[0] = mWorkComponent.doLater(5,function()
            {
               mChatBalloon[0].hideBalloon();
            });
            mEventComponent.dispatchEvent(new ChatEvent("ChatEvent_OUTGOING_CHAT_UPDATE",(0 : UInt),value));
         }
      }
      
      function removeItemFromSlot(param1:UInt) 
      {
         var _loc3_= 0;
         var _loc5_:Int = param1;
         _loc3_ = 0;
         while(_loc3_ < mSortedLootData.length)
         {
            if(ASCompat.toNumber(ASCompat.dynGetIndex(mSortedLootData[_loc3_], 0)) == param1)
            {
               _loc5_ = _loc3_;
            }
            _loc3_ = ASCompat.toInt(_loc3_) + 1;
         }
         var _loc4_= (0 : UInt);
         switch(param1)
         {
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
         if(_loc4_ == 0)
         {
            return;
         }
         mItemCount = mItemCount - 1;
         if(mTookLastItem)
         {
            mDBFacade.metrics.log("DungeonLootTookItem",{"itemId":_loc4_});
         }
         else
         {
            mDBFacade.metrics.log("DungeonLootSoldItem",{"itemId":_loc4_});
         }
         var _loc2_:Array<ASAny> = ASCompat.dynamicAs(mUILootSlots[0], Array);
         if(isSingleChestList[0])
         {
            param1 = (2 : UInt);
         }
         ASCompat.setProperty(_loc2_[_loc5_], "visible", true);
         ASCompat.setProperty(ASCompat.dynGetIndex(mChestMovieClips[0], _loc5_), "visible", false);
         if(isSingleChestList[0])
         {
            if(ASCompat.toBool(ASCompat.dynGetIndex(mItemButtons[0], 0)))
            {
               ASCompat.setProperty(ASCompat.dynGetIndex(mItemButtons[0], 0), "enabled", false);
            }
         }
         else if(ASCompat.toBool(ASCompat.dynGetIndex(mItemButtons[0], param1)))
         {
            ASCompat.setProperty(ASCompat.dynGetIndex(mItemButtons[0], param1), "enabled", false);
         }
      }
      
      function hideBanners() 
      {
         ASCompat.setProperty((mScoreReportRoot : ASAny).stats_a, "visible", false);
         ASCompat.setProperty((mScoreReportRoot : ASAny).stats_b, "visible", false);
         ASCompat.setProperty((mScoreReportRoot : ASAny).stats_c, "visible", false);
         ASCompat.setProperty((mScoreReportRoot : ASAny).stats_d, "visible", false);
         ASCompat.setProperty((mScoreReportRoot : ASAny).empty_banner_b, "visible", false);
         ASCompat.setProperty((mScoreReportRoot : ASAny).empty_banner_c, "visible", false);
         ASCompat.setProperty((mScoreReportRoot : ASAny).empty_banner_d, "visible", false);
         if(mCurrentMapNode.InfiniteDungeon != null)
         {
            ASCompat.setProperty((mScoreReportRoot : ASAny).banner_deco01, "visible", false);
            ASCompat.setProperty((mScoreReportRoot : ASAny).banner_deco02, "visible", false);
         }
      }
      
      function updateBannerAlpha(param1:GameClock) 
      {
         var _loc2_= ASCompat.toNumber(1 - ASCompat.toNumberField((mScoreReportRoot : ASAny).stats_a, "alpha"));
         _loc2_ = 1 - _loc2_ * _loc2_;
         ASCompat.setProperty((mScoreReportRoot : ASAny).stats_a, "alpha", _loc2_);
         ASCompat.setProperty((mScoreReportRoot : ASAny).stats_b, "alpha", _loc2_);
         ASCompat.setProperty((mScoreReportRoot : ASAny).stats_c, "alpha", _loc2_);
         ASCompat.setProperty((mScoreReportRoot : ASAny).stats_d, "alpha", _loc2_);
         ASCompat.setProperty((mScoreReportRoot : ASAny).empty_banner_b, "alpha", _loc2_);
         ASCompat.setProperty((mScoreReportRoot : ASAny).empty_banner_c, "alpha", _loc2_);
         ASCompat.setProperty((mScoreReportRoot : ASAny).empty_banner_d, "alpha", _loc2_);
         if(mCurrentMapNode.InfiniteDungeon != null)
         {
            ASCompat.setProperty((mScoreReportRoot : ASAny).banner_deco02, "alpha", _loc2_);
            ASCompat.setProperty((mScoreReportRoot : ASAny).banner_deco01, "alpha", _loc2_);
         }
         if(ASCompat.toNumberField((mScoreReportRoot : ASAny).stats_a, "alpha") >= 0.95)
         {
            ASCompat.setProperty((mScoreReportRoot : ASAny).stats_a, "alpha", 1);
            ASCompat.setProperty((mScoreReportRoot : ASAny).stats_b, "alpha", 1);
            ASCompat.setProperty((mScoreReportRoot : ASAny).stats_c, "alpha", 1);
            ASCompat.setProperty((mScoreReportRoot : ASAny).stats_d, "alpha", 1);
            ASCompat.setProperty((mScoreReportRoot : ASAny).empty_banner_b, "alpha", 1);
            ASCompat.setProperty((mScoreReportRoot : ASAny).empty_banner_c, "alpha", 1);
            ASCompat.setProperty((mScoreReportRoot : ASAny).empty_banner_d, "alpha", 1);
            if(mCurrentMapNode.InfiniteDungeon != null)
            {
               ASCompat.setProperty((mScoreReportRoot : ASAny).banner_deco02, "alpha", 1);
               ASCompat.setProperty((mScoreReportRoot : ASAny).banner_deco01, "alpha", 1);
            }
            mBannerFadeTask.destroy();
            mBannerFadeTask = null;
         }
      }
      
      function revealBanners(param1:GameClock) 
      {
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
         if(mCurrentMapNode.InfiniteDungeon != null)
         {
            ASCompat.setProperty((mScoreReportRoot : ASAny).banner_deco01, "visible", true);
            ASCompat.setProperty((mScoreReportRoot : ASAny).banner_deco02, "visible", true);
            ASCompat.setProperty((mScoreReportRoot : ASAny).banner_deco01, "alpha", 0.05);
            ASCompat.setProperty((mScoreReportRoot : ASAny).banner_deco02, "alpha", 0.05);
         }
         if(mBannerFadeTask != null)
         {
            mBannerFadeTask.destroy();
            mBannerFadeTask = null;
         }
         mBannerFadeTask = mWorkComponent.doEveryFrame(updateBannerAlpha);
      }
      
      function onPlayerExit(param1:PlayerExitEvent) 
      {
         var _loc6_= 0;
         var _loc3_= Math.NaN;
         var _loc5_= Math.NaN;
         var _loc4_= Math.NaN;
         var _loc8_:Array<ASAny> = null;
         var _loc7_:Array<ASAny> = [(mScoreReportRoot : ASAny).stats_a,(mScoreReportRoot : ASAny).stats_b,(mScoreReportRoot : ASAny).stats_c,(mScoreReportRoot : ASAny).stats_d];
         var _loc2_:Array<ASAny> = [(mScoreReportRoot : ASAny).empty_banner_b,(mScoreReportRoot : ASAny).empty_banner_b,(mScoreReportRoot : ASAny).empty_banner_c,(mScoreReportRoot : ASAny).empty_banner_d];
         _loc6_ = 0;
         while(_loc6_ < 4)
         {
            if(mDungeonReport[_loc6_].valid != 0 && mDungeonReport[_loc6_].id == param1.id)
            {
               _loc3_ = 0.212671;
               _loc5_ = 0.71516;
               _loc4_ = 0.072169;
               _loc8_ = [];
               _loc8_ = _loc8_.concat([_loc3_,_loc5_,_loc4_,0,0]);
               _loc8_ = _loc8_.concat([_loc3_,_loc5_,_loc4_,0,0]);
               _loc8_ = _loc8_.concat([_loc3_,_loc5_,_loc4_,0,0]);
               _loc8_ = _loc8_.concat([0,0,0,1,0]);
               ASCompat.setProperty(_loc7_[_loc6_], "filters", [new ColorMatrixFilter(cast(_loc8_))]);
            }
            _loc6_ = ASCompat.toInt(_loc6_) + 1;
         }
      }
      
      function failureScoreReportSwfLoaded(param1:SwfAsset) 
      {
         var _loc2_= param1.getClass("DRfriends_UI_score_report_defeat");
         mScoreReportRoot = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []) , MovieClip);
         mUILootSlotsTwoTreasures = [[(mScoreReportRoot : ASAny).stats_a.stats.treasure.loot_slot_A1,(mScoreReportRoot : ASAny).stats_a.stats.treasure.loot_slot_A2,(mScoreReportRoot : ASAny).stats_a.stats.treasure.loot_slot_A3],[(mScoreReportRoot : ASAny).stats_b.stats.treasure.loot_slot_A1,(mScoreReportRoot : ASAny).stats_b.stats.treasure.loot_slot_A2,(mScoreReportRoot : ASAny).stats_b.stats.treasure.loot_slot_A3],[(mScoreReportRoot : ASAny).stats_c.stats.treasure.loot_slot_A1,(mScoreReportRoot : ASAny).stats_c.stats.treasure.loot_slot_A2,(mScoreReportRoot : ASAny).stats_c.stats.treasure.loot_slot_A3],[(mScoreReportRoot : ASAny).stats_d.stats.treasure.loot_slot_A1,(mScoreReportRoot : ASAny).stats_d.stats.treasure.loot_slot_A2,(mScoreReportRoot : ASAny).stats_d.stats.treasure.loot_slot_A3]];
         mUILootSlotsFourTreasures = [[(mScoreReportRoot : ASAny).stats_a.stats.treasure.loot_slot_B1,(mScoreReportRoot : ASAny).stats_a.stats.treasure.loot_slot_B2,(mScoreReportRoot : ASAny).stats_a.stats.treasure.loot_slot_B3,(mScoreReportRoot : ASAny).stats_a.stats.treasure.loot_slot_B4],[(mScoreReportRoot : ASAny).stats_b.stats.treasure.loot_slot_B1,(mScoreReportRoot : ASAny).stats_b.stats.treasure.loot_slot_B2,(mScoreReportRoot : ASAny).stats_b.stats.treasure.loot_slot_B3,(mScoreReportRoot : ASAny).stats_b.stats.treasure.loot_slot_B4],[(mScoreReportRoot : ASAny).stats_c.stats.treasure.loot_slot_B1,(mScoreReportRoot : ASAny).stats_c.stats.treasure.loot_slot_B2,(mScoreReportRoot : ASAny).stats_c.stats.treasure.loot_slot_B3,(mScoreReportRoot : ASAny).stats_c.stats.treasure.loot_slot_B4],[(mScoreReportRoot : ASAny).stats_d.stats.treasure.loot_slot_B1,(mScoreReportRoot : ASAny).stats_d.stats.treasure.loot_slot_B2,(mScoreReportRoot : ASAny).stats_d.stats.treasure.loot_slot_B3,(mScoreReportRoot : ASAny).stats_d.stats.treasure.loot_slot_B4]];
         setupUI();
      }
      
      function successScoreReportSwfLoaded(param1:SwfAsset) 
      {
         var _loc2_:Dynamic = null;
         mDBFacade.metrics.log("DungeonLootSummary");
         if(mCurrentMapNode.InfiniteDungeon != null)
         {
            _loc2_ = param1.getClass("UI_score_report_infinite_island");
         }
         else
         {
            _loc2_ = param1.getClass("DRfriends_UI_score_report");
         }
         mScoreReportRoot = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []) , MovieClip);
         mUILootSlotsTwoTreasures = [[(mScoreReportRoot : ASAny).stats_a.stats.treasure.loot_slot_A1,(mScoreReportRoot : ASAny).stats_a.stats.treasure.loot_slot_A2,(mScoreReportRoot : ASAny).stats_a.stats.treasure.loot_slot_A3],[(mScoreReportRoot : ASAny).stats_b.stats.treasure.loot_slot_A1,(mScoreReportRoot : ASAny).stats_b.stats.treasure.loot_slot_A2,(mScoreReportRoot : ASAny).stats_b.stats.treasure.loot_slot_A3],[(mScoreReportRoot : ASAny).stats_c.stats.treasure.loot_slot_A1,(mScoreReportRoot : ASAny).stats_c.stats.treasure.loot_slot_A2,(mScoreReportRoot : ASAny).stats_c.stats.treasure.loot_slot_A3],[(mScoreReportRoot : ASAny).stats_d.stats.treasure.loot_slot_A1,(mScoreReportRoot : ASAny).stats_d.stats.treasure.loot_slot_A2,(mScoreReportRoot : ASAny).stats_d.stats.treasure.loot_slot_A3]];
         mUILootSlotsFourTreasures = [[(mScoreReportRoot : ASAny).stats_a.stats.treasure.loot_slot_B1,(mScoreReportRoot : ASAny).stats_a.stats.treasure.loot_slot_B2,(mScoreReportRoot : ASAny).stats_a.stats.treasure.loot_slot_B3,(mScoreReportRoot : ASAny).stats_a.stats.treasure.loot_slot_B4],[(mScoreReportRoot : ASAny).stats_b.stats.treasure.loot_slot_B1,(mScoreReportRoot : ASAny).stats_b.stats.treasure.loot_slot_B2,(mScoreReportRoot : ASAny).stats_b.stats.treasure.loot_slot_B3,(mScoreReportRoot : ASAny).stats_b.stats.treasure.loot_slot_B4],[(mScoreReportRoot : ASAny).stats_c.stats.treasure.loot_slot_B1,(mScoreReportRoot : ASAny).stats_c.stats.treasure.loot_slot_B2,(mScoreReportRoot : ASAny).stats_c.stats.treasure.loot_slot_B3,(mScoreReportRoot : ASAny).stats_c.stats.treasure.loot_slot_B4],[(mScoreReportRoot : ASAny).stats_d.stats.treasure.loot_slot_B1,(mScoreReportRoot : ASAny).stats_d.stats.treasure.loot_slot_B2,(mScoreReportRoot : ASAny).stats_d.stats.treasure.loot_slot_B3,(mScoreReportRoot : ASAny).stats_d.stats.treasure.loot_slot_B4]];
         setupUI();
      }
      
      function addFriendCallback(param1:UIButton, param2:UInt) : ASFunction
      {
         var button= param1;
         var idx= param2;
         return function()
         {
            if(mDBFacade.dbConfigManager.getConfigBoolean("FUFB",false))
            {
               mDBFacade.errorPopup("INVITE CURRENTLY DISABLED","Sorry for the inconvenience, we are looking into resolving the issue.");
               return;
            }
            findCorrectIcon(mDungeonReport[(idx : Int)],addFriend,button);
         };
      }
      
      function blockFriendCallback(param1:UIButton, param2:UInt) : ASFunction
      {
         var button= param1;
         var idx= param2;
         return function()
         {
            findCorrectIcon(mDungeonReport[(idx : Int)],blockFriend,button);
         };
      }
      
      function reportPlayerCallback(param1:UIButton, param2:UInt) : ASFunction
      {
         var button= param1;
         var idx= param2;
         return function()
         {
            findCorrectIcon(mDungeonReport[(idx : Int)],createReportPlayerPopup,button);
         };
      }
      
      function findCorrectIcon(param1:DungeonReport, param2:ASFunction, param3:UIButton) 
      {
         var DR= param1;
         var callBackFunc= param2;
         var button= param3;
         var iconContainer= new MovieClip();
         var skin= mDBFacade.gameMaster.getSkinByType(DR.skin_type);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(skin.UISwfFilepath),function(param1:SwfAsset)
         {
            var _loc3_= param1.getClass(skin.IconName);
            var _loc2_= ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
            UIObject.scaleToFit(_loc2_,65);
            iconContainer.addChild(_loc2_);
            saveFacebookPicAndAchievement(DR.id,iconContainer);
            callBackFunc(DR.name,iconContainer,DR.id,button);
         });
      }
      
      function fadeAwayTitle() 
      {
         TweenMax.to(mBgRenderer.clip,1,{
            "alpha":0,
            "onComplete":killFadeAwayTitle
         });
      }
      
      function killFadeAwayTitle() 
      {
         ASCompat.setProperty((mScoreReportRoot : ASAny).bg, "visible", false);
         mBgRenderer.destroy();
         mBgRenderer = null;
      }
      
      function setupUI() 
      {
         var movieClipRenderer:MovieClipRenderController;
         var panel_idx:Array<ASAny>;
         var stats_panels:Array<ASAny>;
         var invInfo:DBInventoryInfo;
         var i:UInt;
         var teamBonusUI:UIObject;
         var titleText:String;
         if(mDBFacade.hud != null)
         {
            mDBFacade.hud.hideStacks();
         }
         mBgRenderer = new MovieClipRenderController(mDBFacade,ASCompat.dynamicAs((mScoreReportRoot : ASAny).bg, flash.display.MovieClip));
         mBgRenderer.play();
         movieClipRenderer = new MovieClipRenderController(mDBFacade,ASCompat.dynamicAs((mScoreReportRoot : ASAny).rays, flash.display.MovieClip));
         movieClipRenderer.play();
         mSceneGraphComponent.addChild(mScoreReportRoot,(50 : UInt));
         setupPortraits();
         panel_idx = [0,1,2,3];
         stats_panels = [(mScoreReportRoot : ASAny).stats_a,(mScoreReportRoot : ASAny).stats_b,(mScoreReportRoot : ASAny).stats_c,(mScoreReportRoot : ASAny).stats_d];
         mAddFriendButtons = [];
         mBlockFriendButtons = [];
         mReportPlayerButtons = [];
         mItemButtons = [];
         invInfo = mDBFacade.dbAccountInfo.inventoryInfo;
         mBoosterXP = invInfo.findHighestBoosterXP();
         mBoosterGold = invInfo.findHighestBoosterGold();
         i = (0 : UInt);
         while(i < 4)
         {
            isSingleChestList[(i : Int)] = mCurrentMapNode.MinTreasure == 1 && mDungeonReport[(i : Int)].receivedTrophy == 0;
            isSingleChestList[(i : Int)] = false;
            if(((mDungeonReport[(i : Int)].account_flags : Int) & 1) != 0)
            {
               ASCompat.setProperty(stats_panels[(i : Int)].pennant, "visible", false);
            }
            if(isSingleChestList[(i : Int)])
            {
               ASCompat.setProperty(stats_panels[(i : Int)].stats.treasure.loot_slot_A1, "visible", false);
               ASCompat.setProperty(stats_panels[(i : Int)].stats.treasure.loot_slot_A2, "visible", false);
               ASCompat.setProperty(stats_panels[(i : Int)].stats.treasure.loot_slot_A3, "visible", true);
            }
            else
            {
               ASCompat.setProperty(stats_panels[(i : Int)].stats.treasure.loot_slot_A1, "visible", true);
               ASCompat.setProperty(stats_panels[(i : Int)].stats.treasure.loot_slot_A2, "visible", true);
               ASCompat.setProperty(stats_panels[(i : Int)].stats.treasure.loot_slot_A3, "visible", false);
            }
            ASCompat.setProperty(stats_panels[(i : Int)].stats.xp_bar.bonus_xp_reveal.Bonus_XP, "text", Locale.getString("SUMMARY_BONUS_XP"));
            ASCompat.setProperty(stats_panels[(i : Int)].stats.kills.enemies_killed_reveal.Enemies_Killed, "text", Locale.getString("SUMMARY_ENEMIES_KILLED"));
            ASCompat.setProperty(stats_panels[(i : Int)].stats.treasure.treasure_text, "text", Locale.getString("SUMMARY_TREASURE"));
            if(i == 0)
            {
               ASCompat.setProperty(stats_panels[(i : Int)].stats.text_booster, "text", Locale.getString("ACTIVE_BOOSTERS"));
               ASCompat.setProperty(stats_panels[(i : Int)].stats.text_booster, "visible", false);
               if(mBoosterXP != null)
               {
                  mXPBoosterUI = new UIObject(mDBFacade,ASCompat.dynamicAs(stats_panels[(i : Int)].stats.boosterXP, flash.display.MovieClip));
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.boosterXP.label, "text", mBoosterXP.BuffInfo.Exp + "X");
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.boosterXP.tooltip.title_label, "text", mBoosterXP.StackInfo.Name);
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.boosterXP, "visible", true);
                  mCountDownTextXP = new CountdownTextTimer(ASCompat.dynamicAs((mXPBoosterUI.tooltip : ASAny).time_label, flash.text.TextField),mBoosterXP.getEndDate(),GameClock.getWebServerDate,null,Locale.getString("BOOSTER_REMAINING"),"",Locale.getString("EXPIRED"));
                  mCountDownTextXP.start();
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.text_booster, "visible", true);
               }
               else
               {
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.boosterXP, "visible", false);
               }
               if(mBoosterGold != null)
               {
                  mCoinBoosterUI = new UIObject(mDBFacade,ASCompat.dynamicAs(stats_panels[(i : Int)].stats.boosterCoin, flash.display.MovieClip));
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.boosterCoin.label, "text", mBoosterGold.BuffInfo.Gold + "X");
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.boosterCoin.tooltip.title_label, "text", mBoosterGold.StackInfo.Name);
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.boosterCoin, "visible", true);
                  mCountDownTextGold = new CountdownTextTimer(ASCompat.dynamicAs((mCoinBoosterUI.tooltip : ASAny).time_label, flash.text.TextField),mBoosterGold.getEndDate(),GameClock.getWebServerDate,null,Locale.getString("BOOSTER_REMAINING"),"",Locale.getString("EXPIRED"));
                  mCountDownTextGold.start();
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.text_booster, "visible", true);
               }
               else
               {
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.boosterCoin, "visible", false);
               }
            }
            mTeamBonusUI.add(i,new UIObject(mDBFacade,ASCompat.dynamicAs(stats_panels[(i : Int)].stats.crewbonus, flash.display.MovieClip)));
            teamBonusUI = ASCompat.dynamicAs(mTeamBonusUI.itemFor(i), brain.uI.UIObject);
            ASCompat.setProperty((teamBonusUI.tooltip : ASAny).title_label, "text", Locale.getString("TEAM_BONUS_TOOLTIP_TITLE"));
            ASCompat.setProperty((teamBonusUI.tooltip : ASAny).description_label, "text", Locale.getString("TEAM_BONUS_TOOLTIP_DESCRIPTION"));
            ASCompat.setProperty((teamBonusUI.root : ASAny).header_crew_bonus_number, "text", mDungeonReport[(i : Int)].totalAvatarsOwned - 1);
            ASCompat.setProperty((teamBonusUI.root : ASAny).xp, "text", "0");
            teamBonusUI.visible = false;
            ASCompat.setProperty(stats_panels[(i : Int)].stats.doublexp_effect, "visible", false);
            ASCompat.setProperty(stats_panels[(i : Int)].stats.doublexp_effect_star, "visible", false);
            ASCompat.setProperty(stats_panels[(i : Int)].stats.doublxp_effect_flash_text, "visible", false);
            if(i > 0)
            {
               ASCompat.setProperty(stats_panels[(i : Int)].stats.add_button, "visible", false);
               ASCompat.setProperty(stats_panels[(i : Int)].stats.report_button, "visible", false);
               ASCompat.setProperty(stats_panels[(i : Int)].stats.block_button, "visible", false);
               ASCompat.setProperty(stats_panels[(i : Int)].stats.friend_indicator_icon, "visible", false);
               ASCompat.setProperty(stats_panels[(i : Int)].stats.boosterXP, "visible", false);
               ASCompat.setProperty(stats_panels[(i : Int)].stats.boosterCoin, "visible", false);
               if(mDungeonReport[(i : Int)].boost_xp > 1)
               {
                  mBoosterInfos.push(new UIObject(mDBFacade,ASCompat.dynamicAs(stats_panels[(i : Int)].stats.boosterXP, flash.display.MovieClip)));
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.boosterXP, "visible", true);
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.boosterXP.label, "text", mDungeonReport[(i : Int)].boost_xp + "X");
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.boosterXP.tooltip.title_label, "text", Locale.getString("BOOST_XP_SUMMARY_TITLE"));
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.boosterXP.tooltip.time_label, "text", Locale.getString("BOOST_XP_SUMMARY_DESCRIPTION") + mDungeonReport[(i : Int)].boost_xp + "X");
               }
               if(mDungeonReport[(i : Int)].boost_gold > 1)
               {
                  mBoosterInfos.push(new UIObject(mDBFacade,ASCompat.dynamicAs(stats_panels[(i : Int)].stats.boosterCoin, flash.display.MovieClip)));
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.boosterCoin, "visible", true);
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.boosterCoin.label, "text", mDungeonReport[(i : Int)].boost_gold + "X");
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.boosterCoin.tooltip.title_label, "text", Locale.getString("BOOST_GOLD_SUMMARY_TITLE"));
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.boosterCoin.tooltip.time_label, "text", Locale.getString("BOOST_GOLD_SUMMARY_DESCRIPTION") + mDungeonReport[(i : Int)].boost_gold + "X");
               }
            }
            ASCompat.setProperty(stats_panels[(i : Int)].stats.friend_name, "visible", false);
            if(i > 0)
            {
               if(mDBFacade.dbAccountInfo.isFriend(mDungeonReport[(i : Int)].id))
               {
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.friend_indicator_icon, "visible", true);
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.friend_name, "visible", true);
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.friend_name, "text", mDungeonReport[(i : Int)].name);
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.player_name, "visible", false);
               }
               else
               {
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.friend_indicator_icon, "visible", false);
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.friend_name, "visible", false);
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.player_name, "visible", true);
               }
               if(!ASCompat.toBool(stats_panels[(i : Int)].stats.friend_indicator_icon.visible))
               {
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.add_button, "visible", true);
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.add_button.label, "text", Locale.getString("ADD_FRIEND"));
                  mAddFriendButtons.push(new UIButton(mDBFacade,ASCompat.dynamicAs(stats_panels[(i : Int)].stats.add_button, flash.display.MovieClip)));
                  ASCompat.setProperty(mAddFriendButtons[mAddFriendButtons.length - 1], "releaseCallback", addFriendCallback(ASCompat.dynamicAs(mAddFriendButtons[mAddFriendButtons.length - 1], brain.uI.UIButton),i));
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.block_button, "visible", true);
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.block_button.label, "text", Locale.getString("BLOCK"));
                  mBlockFriendButtons.push(new UIButton(mDBFacade,ASCompat.dynamicAs(stats_panels[(i : Int)].stats.block_button, flash.display.MovieClip)));
                  ASCompat.setProperty(mBlockFriendButtons[mBlockFriendButtons.length - 1], "releaseCallback", blockFriendCallback(ASCompat.dynamicAs(mBlockFriendButtons[mBlockFriendButtons.length - 1], brain.uI.UIButton),i));
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.report_button, "visible", true);
                  ASCompat.setProperty(stats_panels[(i : Int)].stats.report_button.label, "text", Locale.getString("REPORT"));
                  mReportPlayerButtons.push(new UIButton(mDBFacade,ASCompat.dynamicAs(stats_panels[(i : Int)].stats.report_button, flash.display.MovieClip)));
                  ASCompat.setProperty(mReportPlayerButtons[mReportPlayerButtons.length - 1], "releaseCallback", reportPlayerCallback(ASCompat.dynamicAs(mReportPlayerButtons[mReportPlayerButtons.length - 1], brain.uI.UIButton),i));
               }
            }
            if(i == 0)
            {
               mXPBonusStarEffect = ASCompat.dynamicAs(stats_panels[(i : Int)].stats.doublexp_effect_star, flash.display.MovieClip);
               mXPBonusBarEffect = ASCompat.dynamicAs(stats_panels[(i : Int)].stats.doublexp_effect, flash.display.MovieClip);
               mXPBonusTextFlash = ASCompat.dynamicAs(stats_panels[(i : Int)].stats.doublxp_effect_flash_text, flash.display.MovieClip);
               mXPBonusText = ASCompat.dynamicAs((mXPBonusTextFlash : ASAny).doublexp_text, flash.text.TextField);
            }
            ASCompat.setProperty(stats_panels[(i : Int)], "visible", mDungeonReport[(i : Int)].valid);
            ASCompat.setProperty(stats_panels[(i : Int)].stats.kills.enemies_killed.kills, "text", Std.string(mDungeonReport[(i : Int)].kills));
            ASCompat.setProperty(stats_panels[(i : Int)].stats.xp_bar.bonus_xp.xp, "text", "0");
            ASCompat.setProperty(stats_panels[(i : Int)].stats.xp_bar.tooltip, "visible", false);
            mItemButtons[(i : Int)] = [];
            i = i + 1;
         }
         ASCompat.setProperty((mScoreReportRoot : ASAny).bg.banner_text.dungeon_title, "text", mDungeonName != null ? mDungeonName.toUpperCase() : "DUNGEON NAME");
         titleText = this.dungeonSuccess != 0 ? Locale.getString("VICTORY") : Locale.getString("DUNGEON_FAILED");
         if(mCurrentMapNode.InfiniteDungeon != null)
         {
            titleText = Locale.getString("CASHED_OUT");
         }
         ASCompat.setProperty((mScoreReportRoot : ASAny).bg.banner_text.title, "text", titleText);
         setupXPBars();
         setupLoot();
         setupChat();
         setupWeapons();
         mEventComponent.addListener("PlayerExitEvent_str",onPlayerExit);
         hideBanners();
         mWorkComponent.doLater(0.625,revealBanners);
         mTreasureTick = (0 : UInt);
         mRevealState = (1 : UInt);
         updateRevealState(null);
         mDungeonAchievementPanelMovieClipRenderer = new MovieClipRenderer(mDBFacade,ASCompat.dynamicAs((mScoreReportRoot : ASAny).achievement, flash.display.MovieClip),destroyAchievementBossPanel);
         mDungeonAchievementPanelMovieClipRenderer.clip.visible = false;
         ASCompat.setProperty((mScoreReportRoot : ASAny).achievement.label.label, "text", Locale.getString("DUNGEON_SUMMARY_REWARD_PANEL_LABEL"));
         if(mCurrentMapNode.InfiniteDungeon != null)
         {
            ASCompat.setProperty((mScoreReportRoot : ASAny).achievement.label_boss.label, "text", Locale.getString("DUNGEON_SUMMARY_REWARD_PANEL_LABEL_INFINITE"));
         }
         else
         {
            ASCompat.setProperty((mScoreReportRoot : ASAny).achievement.label_boss.label, "text", Locale.getString("DUNGEON_SUMMARY_REWARD_PANEL_LABEL_BOSS"));
         }
         if(mDungeonReport[0].receivedTrophy != 0)
         {
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Doobers/db_items_doobers.swf"),function(param1:SwfAsset)
            {
               var _loc4_:GMChest = null;
               var _loc3_:String = null;
               var _loc2_:String = null;
               var _loc5_= mDungeonReport[0].loot_type_2 > 0 ? mDungeonReport[0].loot_type_2 : mDungeonReport[0].loot_type_1;
               if(_loc5_ != 0 && !ASCompat.stringAsBool(mCurrentMapNode.InfiniteDungeon))
               {
                  _loc4_ = ASCompat.dynamicAs(mDBFacade.gameMaster.chestsById.itemFor(_loc5_), gameMasterDictionary.GMChest);
                  _loc3_ = _loc4_.IconSwf;
                  _loc2_ = _loc4_.IconName;
                  ChestInfo.loadItemIcon(_loc3_,_loc2_,ASCompat.dynamicAs((mScoreReportRoot : ASAny).achievement.chest, flash.display.DisplayObjectContainer),mDBFacade,(400 : UInt),(150 : UInt),mAssetLoadingComponent);
               }
            });
         }
         if(ASCompat.toBool((mScoreReportRoot : ASAny).achievement.chest))
         {
            ASCompat.setProperty((mScoreReportRoot : ASAny).achievement.chest.defaultPic, "visible", false);
         }
      }
      
      function destroyAchievementBossPanel() 
      {
         mDungeonAchievementPanelMovieClipRenderer.destroy();
         ASCompat.setProperty((mScoreReportRoot : ASAny).achievement, "visible", false);
      }
      
      function parseJson(param1:ASAny) : ASObject
      {
         var _loc2_:Array<ASAny> = null;
         var _loc4_:ASObject = null;
         var _loc3_:Vector<UInt> = /*undefined*/null;
         if(ASCompat.getQualifiedClassName(param1) == "Array")
         {
            _loc2_ = ASCompat.dynamicAs(param1[0], Array);
            _loc4_ = param1[1];
            _loc3_ = new Vector<UInt>();
            _loc3_.push(_loc4_.account_id);
            PresenceManager.instance().addFriends(_loc3_);
            mDBFacade.dbAccountInfo.addFriendCallback(_loc2_);
         }
         else
         {
            _loc4_ = (param1 : ASObject) ;
         }
         Logger.debug("friendRequest: id:" + Std.string(_loc4_.id) + " from:" + Std.string(_loc4_.account_id) + " to:" + Std.string(_loc4_.to_account_id) + " state:" + Std.string(_loc4_.curr_state));
         return _loc4_;
      }
      
      function addFriend(param1:String, param2:MovieClip, param3:UInt, param4:UIButton) 
      {
         var personName= param1;
         var iconMC= param2;
         var personId= param3;
         var button= param4;
         var rpcFunc= JSONRPCService.getFunction("DRFriendRequest",mDBFacade.rpcRoot + "friendrequests");
         var rpcSuccessCallback:ASFunction = function(param1:ASAny)
         {
            var _loc2_:ASObject = null;
            if(param1 == null || ASCompat.toNumberField(param1, "length") <= 0)
            {
               Logger.warn("Komo?");
            }
            else
            {
               _loc2_ = parseJson(param1);
               Logger.debug("Successful add friend.");
               mEventComponent.dispatchEvent(new FriendSummaryNewsFeedEvent("FRIEND_SUMMARY_NEWS_FEED_MESSAGE_EVENT",Locale.getString("Friend_Request_Sent_to_"),iconMC,personName));
               mDBFacade.metrics.log("DRFriendRequest",{"friendId":_loc2_.to_account_id});
            }
            button.enabled = false;
         };
         rpcFunc(mDBFacade.dbAccountInfo.name,mDBFacade.dbAccountInfo.trophies,mDBFacade.dbAccountInfo.activeAvatarSkinId,mDBFacade.dbAccountInfo.facebookId,mDBFacade.dbAccountInfo.id,personId,mDBFacade.demographics,mDBFacade.validationToken,rpcSuccessCallback,UIFriendManager.createFriendRPCErrorCallback(mDBFacade,"addFriend"));
      }
      
      function blockFriend(param1:String, param2:MovieClip, param3:UInt, param4:UIButton) 
      {
         var tf:TextFormat;
         var personName= param1;
         var iconMC= param2;
         var personId= param3;
         var button= param4;
         var rpcSuccessCallback:ASFunction = function(param1:ASAny)
         {
            var _loc2_:String = null;
            if(param1 == null || ASCompat.toNumberField(param1, "length") <= 0)
            {
               Logger.warn("Komo?");
            }
            else
            {
               Logger.debug("Successful block friend");
               mEventComponent.dispatchEvent(new FriendSummaryNewsFeedEvent("FRIEND_SUMMARY_NEWS_FEED_MESSAGE_EVENT",Locale.getString("_has_been_blocked"),iconMC,personName,true));
               _loc2_ = param1;
               mDBFacade.metrics.log("DRFriendIgnore",{"friendId":_loc2_.substr(1,_loc2_.length - 2)});
            }
         };
         mDRFriendBlockPopup = new DBUITwoButtonPopup(mDBFacade,Locale.getString("BLOCK") + " " + personName + "?",personName + Locale.getString("VICTORY_SCREEN_BLOCK_POPUP_MESSAGE"),Locale.getString("BLOCK"),function()
         {
            var _loc1_= JSONRPCService.getFunction("IgnoreFriend",mDBFacade.rpcRoot + "friendrequests");
            _loc1_(mDBFacade.dbAccountInfo.id,personId,mDBFacade.validationToken,rpcSuccessCallback);
            button.enabled = false;
         },Locale.getString("CANCEL"),null);
         MemoryTracker.track(mDRFriendBlockPopup,"DBUITwoButtonPopup - created in DistributedDungeonSummary.blockFriend()");
         tf = new TextFormat();
         tf.color = FriendSummaryNewsFeedEvent.FRIEND_NAME_HIGHLIGHT_COLOR;
         mDRFriendBlockPopup.colorizeMessage(tf,0,personName.length);
      }
      
      function buildMatchPlayers() : Array<ASAny>
      {
         var _loc1_= 0;
         var _loc2_:Array<ASAny> = [];
         _loc1_ = 0;
         while(_loc1_ < mDungeonReport.length)
         {
            if(mDungeonReport[_loc1_].id != 0)
            {
               _loc2_.push({
                  "accountId":mDungeonReport[_loc1_].id,
                  "heroType":mDungeonReport[_loc1_].type,
                  "xp":mDungeonReport[_loc1_].xp
               });
            }
            _loc1_++;
         }
         return _loc2_;
      }
      
      function createReportPlayerPopup(param1:String, param2:MovieClip, param3:UInt, param4:UIButton) 
      {
         var personName= param1;
         var iconMC= param2;
         var personId= param3;
         var button= param4;
         var matchPlayers= buildMatchPlayers();
         mDRReportPlayerPopup = new UIReportPopup(mDBFacade,personName,personId,matchPlayers,function()
         {
            if(button != null)
            {
               button.enabled = false;
            }
         },function(param1:ASAny)
         {
            if(param1 != null && ASCompat.toNumberField(param1, "length") > 0)
            {
               mEventComponent.dispatchEvent(new FriendSummaryNewsFeedEvent("FRIEND_SUMMARY_NEWS_FEED_MESSAGE_EVENT",Locale.getString("_has_been_reported"),iconMC,personName,true));
            }
         });
         MemoryTracker.track(mDRReportPlayerPopup,"UIReportPopup - created in DistributedDungeonSummary.createReportPlayerPopup()");
      }
      
      override public function destroy() 
      {
         var _loc5_= 0;
         var _loc6_= 0;
         var _loc2_:FacebookPicHelper = null;
         var _loc4_= 0;
         var _loc7_= 0;
         if(mCountDownTextXP != null)
         {
            mCountDownTextXP.destroy();
         }
         if(mCountDownTextGold != null)
         {
            mCountDownTextGold.destroy();
         }
         var _loc3_:ASAny;
         final __ax4_iter_202 = mTeamBonusUI;
         if (checkNullIteratee(__ax4_iter_202)) for (_tmp_ in __ax4_iter_202.iterator())
         {
            _loc3_ = _tmp_;
            _loc3_.destroy();
         }
         mTeamBonusUI = null;
         mSmashSfx = null;
         mLevelSfx = null;
         if(mChestRevealPopUp != null)
         {
            mChestRevealPopUp.destroy();
            mChestRevealPopUp = null;
         }
         if(mChestKeySlots != null)
         {
            _loc5_ = 0;
            while(_loc5_ < mChestKeySlots.length)
            {
               mChestKeySlots[_loc5_].destroy();
               _loc5_++;
            }
         }
         mChestKeySlots = null;
         mLogicalWorkComponent.destroy();
         mLogicalWorkComponent = null;
         mSoundComponent.destroy();
         mSoundComponent = null;
         if(mStorageFullPopUp != null)
         {
            mStorageFullPopUp.destroy();
            mStorageFullPopUp = null;
         }
         if(mUIInventory != null)
         {
            mUIInventory.destroy();
            mUIInventory = null;
         }
         _loc4_ = 0;
         while(_loc4_ < 4)
         {
            _loc6_ = 0;
            while(_loc6_ < 2)
            {
               mSceneGraphComponent.removeChild(ASCompat.dynamicAs(ASCompat.dynGetIndex(mChestMovieClips[_loc4_], _loc6_), flash.display.DisplayObject));
               _loc6_++;
            }
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
         }
         mChestMovieClips = null;
         mDBFacade.regainFocus();
         if(mSceneGraphComponent.contains(mFacebookPicHolder,(105 : UInt)))
         {
            mSceneGraphComponent.removeChild(mFacebookPicHolder);
         }
         mFacebookPicHolder = null;
         var _loc1_= mFacebookPicMap.keysToArray();
         var _loc8_:ASAny;
         if (checkNullIteratee(_loc1_)) for (_tmp_ in _loc1_)
         {
            _loc8_ = _tmp_;
            _loc2_ = ASCompat.dynamicAs(mFacebookPicMap.itemFor(_loc8_), FacebookPicHelper);
            if(_loc2_ != null)
            {
               _loc2_.destroy();
            }
            _loc2_ = null;
         }
         mFacebookPicMap.clear();
         closeBoosterPopup();
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
         _loc4_ = 0;
         while(_loc4_ < mAddFriendButtons.length)
         {
            mAddFriendButtons[_loc4_].destroy();
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
         }
         mAddFriendButtons = null;
         _loc4_ = 0;
         while(_loc4_ < mBlockFriendButtons.length)
         {
            mBlockFriendButtons[_loc4_].destroy();
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
         }
         mBlockFriendButtons = null;
         _loc4_ = 0;
         while(_loc4_ < mReportPlayerButtons.length)
         {
            mReportPlayerButtons[_loc4_].destroy();
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
         }
         mReportPlayerButtons = null;
         _loc4_ = 0;
         while(_loc4_ < mBoosterInfos.length)
         {
            mBoosterInfos[_loc4_].destroy();
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
         }
         mBoosterInfos = null;
         _loc4_ = 0;
         while(_loc4_ < 4)
         {
            _loc7_ = 0;
            while(_loc7_ < 2)
            {
               if(ASCompat.toBool(ASCompat.dynGetIndex(mItemButtons[_loc4_], _loc7_)))
               {
                  ASCompat.dynGetIndex(mItemButtons[_loc4_], _loc7_).destroy();
                  mItemButtons[_loc4_][_loc7_] = null;
               }
               _loc7_ = ASCompat.toInt(_loc7_) + 1;
            }
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
         }
         mItemButtons = null;
         if(mTownHeader != null)
         {
            mTownHeader.destroy();
            mTownHeader = null;
         }
         if(mAssetLoadingComponent != null)
         {
            mAssetLoadingComponent.destroy();
            mAssetLoadingComponent = null;
         }
         if(mScoreReportRoot != null)
         {
            mSceneGraphComponent.removeChild(mScoreReportRoot);
         }
         mScoreReportRoot = null;
         if(mSceneGraphComponent != null)
         {
            mSceneGraphComponent.destroy();
            mSceneGraphComponent = null;
         }
         mUIChatLog.destroy();
         _loc4_ = 0;
         while(_loc4_ < mChestRenderers.length)
         {
            mChestRenderers[_loc4_].destroy();
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
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
         mFacebookPicMap.clear();
         mFacebookPicMap = null;
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
         mWeapons.resize(0);
         mWeapons = null;
         mWeaponTooltips.resize(0);
         mWeaponTooltips = null;
         mXpBar.resize(0);
         mXpBar = null;
         mDBFacade = null;
      }
      
      @:isVar public var dungeon_name(never,set):String;
public function  set_dungeon_name(param1:String) :String      {
         return mDungeonName = param1;
      }
      
            
      @:isVar public var report(get,set):Vector<DungeonReport>;
public function  set_report(param1:Vector<DungeonReport>) :Vector<DungeonReport>      {
         var _loc4_= 0;
         var _loc2_:DungeonReport = null;
         var _loc3_= 0;
         var _loc6_:Array<ASAny> = null;
         mDungeonReport = param1;
         _loc4_ = 0;
         while(_loc4_ < 4)
         {
            if(mDungeonReport[_loc4_].id == mDBFacade.accountId)
            {
               _loc2_ = mDungeonReport[_loc4_];
               mDungeonReport[_loc4_] = mDungeonReport[0];
               mDungeonReport[0] = _loc2_;
               break;
            }
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
         }
         var _loc5_:Array<ASAny> = [mDungeonReport[0].chest_type_1,mDungeonReport[0].chest_type_2,mDungeonReport[0].chest_type_3,mDungeonReport[0].chest_type_4];
         mSortedLootData = [];
         _loc3_ = 0;
         while(_loc3_ < 4)
         {
            _loc6_ = [_loc3_,_loc5_[_loc3_]];
            mSortedLootData.push(_loc6_);
            _loc3_++;
         }
         ASCompat.ASArray.sort(mSortedLootData, compareOnChestValues);
return param1;
      }
      
      @:isVar public var map_node_id(never,set):UInt;
public function  set_map_node_id(param1:UInt) :UInt      {
         return mMapNodeId = param1;
      }
      
      @:isVar public var dungeonMod1(never,set):UInt;
public function  set_dungeonMod1(param1:UInt) :UInt      {
         return mDungeonMod1 = param1;
      }
      
      @:isVar public var dungeonMod2(never,set):UInt;
public function  set_dungeonMod2(param1:UInt) :UInt      {
         return mDungeonMod2 = param1;
      }
      
      @:isVar public var dungeonMod3(never,set):UInt;
public function  set_dungeonMod3(param1:UInt) :UInt      {
         return mDungeonMod3 = param1;
      }
      
      @:isVar public var dungeonMod4(never,set):UInt;
public function  set_dungeonMod4(param1:UInt) :UInt      {
         return mDungeonMod4 = param1;
      }
function  get_report() : Vector<DungeonReport>
      {
         return mDungeonReport;
      }
      
      function trySurveyLink() 
      {
         var popup:DBUITwoButtonPopup;
         var surveyName= "SURVEY_" + mDBFacade.dbConfigManager.getConfigString("survey_name","XHBQPFS");
         var surveyURL= mDBFacade.dbConfigManager.getConfigString("survey_url","");
         var alreadyCompleted= mDBFacade.dbAccountInfo.getAttribute(surveyName) == "1";
         if(ASCompat.stringAsBool(surveyURL) && !alreadyCompleted)
         {
            surveyURL += "?c=" + mDBFacade.accountId;
            popup = new DBUITwoButtonPopup(mDBFacade,Locale.getString("SURVEY_POPUP_TITLE"),Locale.getString("SURVEY_POPUP_MESSAGE"),Locale.getString("SURVEY_CANCEL"),function()
            {
               Logger.info("trySurveyLink cancel: " + surveyURL);
               returnToSplashScreen();
            },Locale.getString("SURVEY_GO"),function()
            {
               var _loc1_= new URLRequest(surveyURL);
               flash.Lib.getURL(_loc1_,"_blank");
               Logger.info("trySurveyLink opened: " + surveyURL);
            });
            MemoryTracker.track(popup,"DBUITwoButtonPopup - created in DistributedDungeonSummary.trySurveyLink()");
            mDBFacade.dbAccountInfo.alterAttribute(surveyName,"1");
         }
         else
         {
            returnToSplashScreen();
         }
      }
      
      function tryReturnToSplashScreen() 
      {
         var _loc1_:DBUITwoButtonPopup = null;
         if(mItemCount > 0)
         {
            _loc1_ = new DBUITwoButtonPopup(mDBFacade,Locale.getString("ABANDON_ITEMS_TITLE"),Locale.getString("ABANDON_ITEMS_MESSAGE"),Locale.getString("ABANDON_YES"),trySurveyLink,Locale.getString("CANCEL"),null);
            MemoryTracker.track(_loc1_,"DBUITwoButtonPopup - created in DistributedDungeonSummary.tryReturnToSplashScreen()");
         }
         else
         {
            trySurveyLink();
         }
      }
      
      function openInventory() 
      {
         var _loc1_= 0;
         var _loc2_= 0;
         mUIInventory = new UIInventory(mDBFacade,mTownHeader,this);
         mUIInventory.setRevealedState(mRevealedItemType,mRevealedItemOfferId,mRevealedItemCallEquip);
         mUIInventory.show(mSelectedGMChest);
         mTownHeader.showCloseButton(true);
         mScoreReportRoot.addChild(mUIInventory.root);
         _loc1_ = 0;
         while(_loc1_ < 4)
         {
            _loc2_ = 0;
            while(_loc2_ < 2)
            {
               if(ASCompat.dynGetIndex(mChestMovieClips[_loc1_], _loc2_) != null)
               {
                  ASCompat.setProperty(ASCompat.dynGetIndex(mChestMovieClips[_loc1_], _loc2_), "visible", false);
               }
               _loc2_++;
            }
            _loc1_ = ASCompat.toInt(_loc1_) + 1;
         }
      }
      
      function closeHeader() 
      {
         if(mUIInventory != null)
         {
            closeInventory();
         }
         else
         {
            tryReturnToSplashScreen();
         }
      }
      
      function closeInventory() 
      {
         var _loc2_= 0;
         mScoreReportRoot.removeChild(mUIInventory.root);
         mUIInventory.destroy();
         mUIInventory = null;
         mTownHeader.showCloseButton(true);
         mTownHeader.title = this.dungeonSuccess != 0 ? Locale.getString("VICTORY") : Locale.getString("DUNGEON_FAILED");
         var _loc1_:Array<ASAny> = [mDungeonReport[0].chest_type_1,mDungeonReport[0].chest_type_2,mDungeonReport[0].chest_type_3,mDungeonReport[0].chest_type_4];
         _loc2_ = 0;
         while(_loc2_ < 2)
         {
            if(ASCompat.toBool(ASCompat.dynGetIndex(mChestMovieClips[0], _loc2_)))
            {
               if(ASCompat.toNumber(_loc1_[_loc2_]) == 0)
               {
                  ASCompat.setProperty(ASCompat.dynGetIndex(mChestMovieClips[0], _loc2_), "visible", false);
               }
               else
               {
                  ASCompat.setProperty(ASCompat.dynGetIndex(mChestMovieClips[0], _loc2_), "visible", true);
               }
            }
            _loc2_++;
         }
      }
      
      function returnToSplashScreen() 
      {
         mDBFacade.mDistributedObjectManager.mMatchMaker.RequestExit();
      }
   }


private class FacebookPicHelper
{
   
   public var pic:DisplayObject;
   
   public var root:MovieClip;
   
   public function new()
   {
      
   }
   
   public function destroy() 
   {
      pic = null;
      root = null;
   }
}
