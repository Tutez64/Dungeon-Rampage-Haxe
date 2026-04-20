package uI.dailyRewards
;
   import brain.assetRepository.SwfAsset;
   import brain.clock.GameClock;
   import brain.logger.Logger;
   import brain.render.MovieClipRenderController;
   import brain.sound.SoundAsset;
   import brain.uI.UIButton;
   import brain.jsonRPC.JSONRPCService;
   import facade.DBFacade;
   import facade.Locale;
   import gameMasterDictionary.GMOffer;
   import sound.DBSoundComponent;
   import uI.popup.DBUIPopup;
   import uI.popup.UICashPage;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.filters.GlowFilter;
   import flash.text.TextFormat;
   import flash.utils.Timer;
   
    class UIDailyRewards extends DBUIPopup
   {
      
      public static inline final UI_DAILY_REWARD_SWF_PATH= "Resources/Art2D/UI/db_UI_daily_reward.swf";
      
      public static inline final DAILY_REWARD_GOLD_POPUP_CLASS_NAME= "UI_daily_rewards";
      
      public static inline final DAILY_REWARD_MYSTERY_BOX_POPUP_CLASS_NAME= "UI_daily_rewards_mysterybox";
      
      public static inline final DAILY_REWARD_SLOT_MOVIE_CLASS_NAME= "reveal_storageBox_slotMachine";
      
      public static inline final UI_ICON_SWF_PATH= "Resources/Art2D/Icons/Items/db_icons_items.swf";
      
      public static inline final COIN_SMALL_CLASS_NAME= "db_items_gems_small";
      
      public static inline final COIN_MEDIUM_CLASS_NAME= "db_items_gems_medium_static";
      
      public static inline final COIN_LARGE_CLASS_NAME= "db_items_gems_large_static";
      
      public static inline final COIN_SMALL_ANIM_CLASS_NAME= "db_items_gems_small_anim";
      
      public static inline final COIN_MEDIUM_ANIM_CLASS_NAME= "db_items_gems_medium";
      
      public static inline final COIN_LARGE_ANIM_CLASS_NAME= "db_items_gems_large";
      
      public static inline final MYSTERY_BOX_CLASS_NAME= "db_items_box_mystery";
      
      static inline final DAILY_POPUP_Y_BUFFER= 40;
      
      public static inline final millisecondsPerMinute= 60000;
      
      public static inline final millisecondsPerHour= 3600000;
      
      public static inline final millisecondsPerDay= 86400000;
      
      var mTownRoot:MovieClip;
      
      var mDailyRewardGoldPopup:MovieClip;
      
      var mDailyRewardMysteryBoxPopup:MovieClip;
      
      var mSlotMovie:MovieClip;
      
      var mCrewBonusController:MovieClipRenderController;
      
      var mSlotMovieController:MovieClipRenderController;
      
      var mRedeemRewardsButton:UIButton;
      
      var mAcceptButton:UIButton;
      
      var mExitButton:UIButton;
      
      var mReplayButton:UIButton;
      
      var mCrewButton:UIButton;
      
      var mBoxArray:Array<ASAny>;
      
      var mRewardArray:Array<ASAny>;
      
      var mDisplayOffers:Vector<GMOffer>;
      
      var mBoxPicked:Int = 0;
      
      var mRewardInfo:Array<ASAny>;
      
      var mCountGold:Int = 0;
      
      var mCountCrew:Int = 0;
      
      var mRewardIcon0:MovieClip;
      
      var mRewardIcon1:MovieClip;
      
      var mRewardIcon2:MovieClip;
      
      var mBox0:MovieClip;
      
      var mBox1:MovieClip;
      
      var mBox2:MovieClip;
      
      var mBoxButton0:UIButton;
      
      var mBoxButton1:UIButton;
      
      var mBoxButton2:UIButton;
      
      var mTimerTarget:Float = Math.NaN;
      
      var mCountdownTimer:Timer;
      
      var mTimerTargetDate:Date;
      
      var mRewardName:String;
      
      var mPaytoReplay:Bool = false;
      
      var mNoRoomInStorageForReward:Bool = false;
      
      var mSkipGoldCount:Bool = false;
      
      var mForceOpen:Bool = false;
      
      var mWindowGoldDisplayed:Bool = false;
      
      var mWindowMysteryDisplayed:Bool = false;
      
      var mGoldStartY:Int = 200;
      
      var mGoldEndY:Int = 0;
      
      var mGoldCount:Int = 0;
      
      var mGoldSlideTimer:Timer;
      
      var mGoldCountTimer:Timer;
      
      var mGoldCountTotal:Int = 0;
      
      var mGoldPerCrew:Int = 0;
      
      var mGoldPerCount:Int = 0;
      
      var mGoldDarkTimer:Timer;
      
      var mMysteryStartY:Int = 500;
      
      var mMysteryEndY:Int = 0;
      
      var mMysterySlideTimer:Timer;
      
      var mMysteryFadeTimer:Timer;
      
      var mBoxAlpha:Float = Math.NaN;
      
      var mRewardAlpha:Float = Math.NaN;
      
      var mSoundGoldPlunk:SoundAsset;
      
      var mSoundGoldStart:SoundAsset;
      
      var mSoundBox:SoundAsset;
      
      var mSoundComponent:DBSoundComponent;
      
      var mTimeToNext:Int = 0;
      
      var mCostPlay:Int = 0;
      
      public function new(param1:DBFacade, param2:ASFunction, param3:Bool)
      {
         var dbFacade= param1;
         var closeCallback= param2;
         var forceOpen= param3;
         mForceOpen = forceOpen;
         super(dbFacade,"",null,true,true,function()
         {
            if(closeCallback != null)
            {
               closeCallback();
            }
         },false,ASCompat.stringAsBool("DAILY_LOGIN_POPUP"));
         mDBFacade = dbFacade;
         mCloseCallback = closeCallback;
         mPopup.visible = false;
         mSoundComponent = new DBSoundComponent(mDBFacade);
         mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),"ExpCollectSound",function(param1:SoundAsset)
         {
            mSoundGoldPlunk = param1;
         });
         mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),"TEMP_DooberGoldLarge1",function(param1:SoundAsset)
         {
            mSoundGoldStart = param1;
         });
         mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),"DailyRewardShred",function(param1:SoundAsset)
         {
            mSoundBox = param1;
         });
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_daily_reward.swf"),dailyRewardPopupLoaded);
      }
      
      function displayWindow() 
      {
         if(mWindowGoldDisplayed == false)
         {
            mRoot.addChild(mDailyRewardGoldPopup);
            mGoldEndY = Std.int(mDailyRewardGoldPopup.y + 40);
            mDailyRewardGoldPopup.y = mGoldStartY;
            mWindowGoldDisplayed = true;
            mGoldSlideTimer = new Timer(16);
            mGoldSlideTimer.addEventListener("timer",goldSlideTimerTick);
            mDailyRewardGoldPopup.alpha = 0;
            mGoldSlideTimer.start();
            mDBFacade.mInDailyReward = true;
         }
      }
      
      function goldSlideTimerTick(param1:TimerEvent) 
      {
         mDailyRewardGoldPopup.y -= 5 + 0.1 * Math.abs(mDailyRewardGoldPopup.y - mGoldEndY);
         mDailyRewardGoldPopup.alpha += 0.1;
         if(mDailyRewardGoldPopup.y <= mGoldEndY)
         {
            mDailyRewardGoldPopup.alpha = 1;
            mDailyRewardGoldPopup.y = mGoldEndY;
            mGoldSlideTimer.removeEventListener("timer",goldSlideTimerTick);
            mGoldSlideTimer.stop();
            startGoldCount();
         }
      }
      
      function startGoldCount() 
      {
         mCountGold = 0;
         mCountCrew = 0;
         var _loc1_= Std.int(10 / ASCompat.toNumber(mRewardInfo[1]) + 2);
         mGoldCountTimer = new Timer(50);
         mGoldCountTimer.addEventListener("timer",goldCountTimerTick);
         mGoldCountTotal = ASCompat.toInt(ASCompat.toNumber(ASCompat.dynGetIndex(mRewardInfo[2], ASCompat.toNumber(mRewardInfo[0]) - 1)) * ASCompat.toNumber(mRewardInfo[1]));
         mGoldPerCount = Std.int(5 + 0.5 * (mGoldCountTotal / 30));
         mGoldPerCrew = ASCompat.toInt(ASCompat.dynGetIndex(mRewardInfo[2], ASCompat.toNumber(mRewardInfo[0]) - 1));
         if(mSkipGoldCount)
         {
            startMysterySlide();
         }
         else
         {
            mGoldCountTimer.start();
         }
         if(mSoundGoldStart != null)
         {
            mSoundComponent.playSfxOneShot(mSoundGoldStart);
         }
      }
      
      function goldCountTimerTick(param1:TimerEvent) 
      {
         var _loc2_:GlowFilter = null;
         if(mDBFacade == null)
         {
            mGoldCountTimer.removeEventListener("timer",goldCountTimerTick);
            mGoldCountTimer.stop();
            return;
         }
         mCountGold += mGoldPerCount;
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).label_number, "text", mCountGold);
         if(mCountGold >= mGoldPerCrew * (mCountCrew + 1) && mCountCrew < ASCompat.toNumber(ASCompat.toNumber(mRewardInfo[1]) - 1))
         {
            if(mSoundGoldPlunk != null)
            {
               mSoundComponent.playSfxOneShot(mSoundGoldPlunk);
            }
            if(mSoundGoldStart != null)
            {
               mSoundComponent.playSfxOneShot(mSoundGoldStart);
            }
            mCountCrew += 1;
            ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).crewBonus_anim.crewBonus.header_crew_bonus_number, "text", mCountCrew);
            _loc2_ = new GlowFilter((16777215 : UInt),1,5,5,1,1,false,false);
            _loc2_.quality = 2;
            ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).label_number, "filters", [_loc2_]);
            ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).crewBonus_anim.crewBonus.header_crew_bonus_number, "filters", [_loc2_]);
            mGoldDarkTimer = new Timer(100);
            mGoldDarkTimer.addEventListener("timer",darkenGoldText);
            mGoldDarkTimer.start();
         }
         if(mCountGold >= mGoldCountTotal)
         {
            ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).label_number, "text", mGoldCountTotal);
            ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).crewBonus_anim.crewBonus.header_crew_bonus_number, "text", ASCompat.toNumber(mRewardInfo[1]) - 1);
            mGoldCountTimer.removeEventListener("timer",goldCountTimerTick);
            mGoldCountTimer.stop();
            startMysterySlide();
         }
      }
      
      function darkenGoldText(param1:TimerEvent) 
      {
         if(mDBFacade == null)
         {
            return;
         }
         var _loc2_= new GlowFilter((0 : UInt),1,2,2,4,1,false,false);
         _loc2_.quality = 2;
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).label_number, "filters", [_loc2_]);
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).crewBonus_anim.crewBonus.header_crew_bonus_number, "filters", [_loc2_]);
         mGoldDarkTimer.removeEventListener("timer",goldCountTimerTick);
         mGoldDarkTimer.stop();
      }
      
      function startMysterySlide() 
      {
         if(mWindowMysteryDisplayed == false)
         {
            mRoot.addChild(mDailyRewardMysteryBoxPopup);
            mWindowMysteryDisplayed = true;
         }
         mMysteryEndY = Std.int(mDailyRewardMysteryBoxPopup.y + 40);
         mDailyRewardMysteryBoxPopup.y = mMysteryStartY;
         mMysterySlideTimer = new Timer(16);
         mMysterySlideTimer.addEventListener("timer",mysterySlideTimerTick);
         mDailyRewardMysteryBoxPopup.alpha = 0;
         mMysterySlideTimer.start();
      }
      
      function mysterySlideTimerTick(param1:TimerEvent) 
      {
         mDailyRewardMysteryBoxPopup.alpha += 0.1;
         mDailyRewardMysteryBoxPopup.y -= 5 + 0.1 * Math.abs(mDailyRewardMysteryBoxPopup.y - mMysteryEndY);
         if(mDailyRewardMysteryBoxPopup.y <= mMysteryEndY)
         {
            mDailyRewardMysteryBoxPopup.y = mMysteryEndY;
            mMysterySlideTimer.removeEventListener("timer",mysterySlideTimerTick);
            mMysterySlideTimer.stop();
            mDailyRewardMysteryBoxPopup.alpha = 1;
         }
      }
      
      function startBoxFade() 
      {
         mMysteryFadeTimer = new Timer(16);
         mBoxAlpha = 1;
         mRewardAlpha = 0;
         mMysteryFadeTimer.addEventListener("timer",mysteryFadeTimerTick);
         mMysteryFadeTimer.start();
      }
      
      function mysteryFadeTimerTick(param1:TimerEvent) 
      {
         var _loc2_= 0;
         if(mBoxAlpha > 0)
         {
            mBoxAlpha = Math.max(mBoxAlpha - 0.15,0);
            _loc2_ = 0;
            while(_loc2_ < 3)
            {
               if(mBoxPicked == _loc2_)
               {
                  ASCompat.setProperty(mBoxArray[_loc2_], "alpha", mBoxAlpha);
               }
               else
               {
                  ASCompat.setProperty(mBoxArray[_loc2_], "alpha", mBoxAlpha);
                  ASCompat.setProperty(mRewardArray[_loc2_], "alpha", mRewardAlpha);
               }
               _loc2_++;
            }
         }
         else if(mRewardAlpha < 1)
         {
            mRewardAlpha = Math.min(mRewardAlpha + 0.15,1);
            _loc2_ = 0;
            while(_loc2_ < 3)
            {
               if(mBoxPicked == _loc2_)
               {
                  ASCompat.setProperty(mBoxArray[_loc2_], "alpha", mBoxAlpha);
               }
               else
               {
                  ASCompat.setProperty(mBoxArray[_loc2_], "alpha", mBoxAlpha);
                  ASCompat.setProperty(mRewardArray[_loc2_], "alpha", mRewardAlpha);
               }
               _loc2_++;
            }
         }
         else
         {
            mMysteryFadeTimer.removeEventListener("timer",mysteryFadeTimerTick);
            mMysteryFadeTimer.stop();
            ASCompat.setProperty(mBoxArray[0], "visible", false);
            ASCompat.setProperty(mBoxArray[1], "visible", false);
            ASCompat.setProperty(mBoxArray[2], "visible", false);
            startTimer(mTimeToNext);
         }
      }
      
      function dailyRewardPopupLoaded(param1:SwfAsset) 
      {
         var popupGoldClass:Dynamic;
         var popupMysteryBoxClass:Dynamic;
         var slotMovieClass:Dynamic;
         var swfAsset= param1;
         if(mDBFacade == null)
         {
            return;
         }
         popupGoldClass = swfAsset.getClass("UI_daily_rewards");
         popupMysteryBoxClass = swfAsset.getClass("UI_daily_rewards_mysterybox");
         slotMovieClass = swfAsset.getClass("reveal_storageBox_slotMachine");
         mDailyRewardGoldPopup = ASCompat.dynamicAs(ASCompat.createInstance(popupGoldClass, []), flash.display.MovieClip);
         mDailyRewardMysteryBoxPopup = ASCompat.dynamicAs(ASCompat.createInstance(popupMysteryBoxClass, []), flash.display.MovieClip);
         mSlotMovie = ASCompat.dynamicAs(ASCompat.createInstance(slotMovieClass, []), flash.display.MovieClip);
         mCrewBonusController = new MovieClipRenderController(mDBFacade,ASCompat.dynamicAs((mDailyRewardGoldPopup : ASAny).crewBonus_anim, flash.display.MovieClip));
         mCrewBonusController.loop = false;
         mCrewBonusController.stop();
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).crewBonus_anim, "visible", false);
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).title_label, "text", Locale.getString("DAILY_REWARDS_POPUP_TITLE"));
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).label_message1, "text", Locale.getString("DAILY_REWARDS_WELCOME"));
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).checkbox01.label_day, "text", Locale.getString("DAILY_REWARDS_DAY1"));
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).checkbox02.label_day, "text", Locale.getString("DAILY_REWARDS_DAY2"));
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).checkbox03.label_day, "text", Locale.getString("DAILY_REWARDS_DAY3"));
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).crewBonus_anim.crewBonus.header_crew_bonus_number, "text", "");
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).crewBonus_anim.crewBonus.tooltip.title_label, "text", Locale.getString("TEAM_BONUS_TOOLTIP_TITLE"));
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).crewBonus_anim.crewBonus.tooltip.description_label, "text", Locale.getString("TEAM_BONUS_TOOLTIP_DESCRIPTION"));
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).inv_empty_slot01.coin, "visible", false);
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).inv_empty_slot02.coin, "visible", false);
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).inv_empty_slot03.coin, "visible", false);
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).checkbox01.selected, "visible", false);
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).checkbox02.selected, "visible", false);
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).checkbox03.selected, "visible", false);
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).label_number01, "visible", false);
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).label_number02, "visible", false);
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).label_number03, "visible", false);
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).label_number, "visible", false);
         mDailyRewardGoldPopup.scaleX = mDailyRewardGoldPopup.scaleY = 1.8;
         mDailyRewardGoldPopup.x = 250;
         mDailyRewardMysteryBoxPopup.scaleX = mDailyRewardMysteryBoxPopup.scaleY = 1.8;
         mDailyRewardMysteryBoxPopup.x = 962;
         mDailyRewardMysteryBoxPopup.y = mDailyRewardGoldPopup.height + 26;
         ASCompat.setProperty((mDailyRewardMysteryBoxPopup : ASAny).button_accept.label, "text", Locale.getString("DAILY_REWARDS_ACCEPT"));
         ASCompat.setProperty((mDailyRewardMysteryBoxPopup : ASAny).button_replay.label, "text", Locale.getString("DAILY_REWARDS_REPLAY"));
         ASCompat.setProperty((mDailyRewardMysteryBoxPopup : ASAny).label_message2, "text", Locale.getString("DAILY_REWARDS_SELECT"));
         ASCompat.setProperty((mDailyRewardMysteryBoxPopup : ASAny).label_message3, "text", Locale.getString("DAILY_REWARDS_COMEBACK"));
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).crewBonus_anim.crewBonus.plus, "text", Locale.getString("DAILY_REWARDS_WITH"));
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).label_dailybonus, "text", Locale.getString("DAILY_REWARDS_BONUS"));
         mAcceptButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mDailyRewardMysteryBoxPopup : ASAny).button_accept, flash.display.MovieClip));
         mReplayButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mDailyRewardMysteryBoxPopup : ASAny).button_replay, flash.display.MovieClip));
         ASCompat.setProperty((mDailyRewardMysteryBoxPopup : ASAny).button_replay.l_numberabel, "text", "");
         mExitButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mDailyRewardGoldPopup : ASAny).close, flash.display.MovieClip));
         mExitButton.releaseCallback = function()
         {
            exitButtonPushed();
         };
         mCrewButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mDailyRewardGoldPopup : ASAny).crewBonus_anim.crewBonus, flash.display.MovieClip));
         mReplayButton.isToTheLeftOf(mAcceptButton);
         mReplayButton.upNavigation = mExitButton;
         mAcceptButton.upNavigation = mExitButton;
         mSlotMovieController = new MovieClipRenderController(mDBFacade,mSlotMovie);
         mAcceptButton.visible = false;
         mReplayButton.visible = false;
         mPaytoReplay = false;
         stopTimer();
         askAboutDailyReward();
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).arrow01, "visible", false);
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).arrow02, "visible", false);
      }
      
      function mouseOverCrewListener(param1:Event) 
      {
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).crewBonus_anim.crewBonus.tooltip, "visible", true);
      }
      
      function mouseOutCrewListener(param1:Event) 
      {
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).crewBonus_anim.crewBonus.tooltip, "visible", false);
      }
      
      function stopTimer() 
      {
         if(mDailyRewardMysteryBoxPopup == null)
         {
            return;
         }
         ASCompat.setProperty((mDailyRewardMysteryBoxPopup : ASAny).label_timer, "visible", false);
         ASCompat.setProperty((mDailyRewardMysteryBoxPopup : ASAny).label_remaining, "visible", false);
         ASCompat.setProperty((mDailyRewardMysteryBoxPopup : ASAny).label_message3, "visible", false);
         ASCompat.setProperty((mDailyRewardMysteryBoxPopup : ASAny).timer_clock, "visible", false);
         if(mCountdownTimer != null)
         {
            mCountdownTimer.removeEventListener("timer",timerTick);
            mCountdownTimer.stop();
            mCountdownTimer = null;
         }
      }
      
      function getNextDay() : Date
      {
         var _loc1_= GameClock.getWebServerDate();
         ASCompat.ASDate.setTime(_loc1_, _loc1_.getTime()+ 86400000 - (_loc1_.getSeconds() * 1000 + _loc1_.getMinutes() * 60000 + _loc1_.getHours() * 3600000));
         return _loc1_;
      }
      
      function startTimer(param1:Int) 
      {
         var now:Date;
         var secondsToGo= param1;
         if(mCountdownTimer != null)
         {
            return;
         }
         ASCompat.setProperty((mDailyRewardMysteryBoxPopup : ASAny).label_timer, "visible", true);
         ASCompat.setProperty((mDailyRewardMysteryBoxPopup : ASAny).label_remaining, "visible", true);
         ASCompat.setProperty((mDailyRewardMysteryBoxPopup : ASAny).label_message3, "visible", true);
         ASCompat.setProperty((mDailyRewardMysteryBoxPopup : ASAny).timer_clock, "visible", true);
         now = GameClock.getWebServerDate();
         mTimerTargetDate = GameClock.getWebServerDate();
         ASCompat.ASDate.setTime(mTimerTargetDate, mTimerTargetDate.getTime()+ 1000 * secondsToGo);
         ASCompat.setProperty((mDailyRewardMysteryBoxPopup : ASAny).label_timer, "text", "");
         mCountdownTimer = new Timer(1000);
         mCountdownTimer.addEventListener("timer",timerTick);
         mCountdownTimer.start();
         mAcceptButton.visible = true;
         mReplayButton.visible = true;
         mBoxButton0.enabled = false;
         mBoxButton1.enabled = false;
         mBoxButton2.enabled = false;
         mAcceptButton.releaseCallback = function()
         {
            exitButtonPushed();
         };
         mReplayButton.releaseCallback = function()
         {
            playAgain();
         };
      }
      
      function playAgain() 
      {
         var _loc1_:UICashPage = null;
         if(mDBFacade.dbAccountInfo.premiumCurrency < (mCostPlay : UInt))
         {
            mDBFacade.metrics.log("ShopCashPagePresented");
            _loc1_ = new UICashPage(mDBFacade);
         }
         else
         {
            mDBFacade.metrics.log("DailyRewardsHitReplay");
            resetMysteryBox(true);
            if(mDBFacade.steamAchievementsManager != null)
            {
               mDBFacade.steamAchievementsManager.addToStatInt("REROLL_DAILY_REWARD_STAT",1);
               mDBFacade.steamAchievementsManager.setAchievement("REROLL_DAILY_REWARD");
            }
         }
      }
      
      function timerTick(param1:TimerEvent) 
      {
         var _loc6_= GameClock.getWebServerDate();
         var _loc7_= Date.now();
         var _loc2_= Date.now();
         ASCompat.ASDate.setTime(_loc2_, 3600000 * 8);
         ASCompat.ASDate.setTime(_loc7_, _loc2_.getTime()+ mTimerTargetDate.getTime()- _loc6_.getTime());
         var _loc3_= Std.int(mTimerTargetDate.getSeconds() - _loc6_.getSeconds());
         var _loc5_= Std.int(mTimerTargetDate.getMinutes() - _loc6_.getMinutes());
         var _loc4_= Std.int(mTimerTargetDate.getHours() - _loc6_.getHours());
         ASCompat.setProperty((mDailyRewardMysteryBoxPopup : ASAny).label_timer, "text", Std.string(_loc7_.getHours()) + ":" + zeroPad(Std.int(_loc7_.getMinutes()),2) + ":" + zeroPad(Std.int(_loc7_.getSeconds()),2));
         if(mTimerTargetDate.getTime()<= _loc6_.getTime())
         {
            resetMysteryBox();
            askAboutDailyReward();
         }
      }
      
      public function zeroPad(param1:Int, param2:Int) : String
      {
         var _loc3_= "" + param1;
         while(_loc3_.length < param2)
         {
            _loc3_ = "0" + _loc3_;
         }
         return _loc3_;
      }
      
      public function resetMysteryBox(param1:Bool = false) 
      {
         stopTimer();
         mAcceptButton.visible = false;
         mReplayButton.visible = false;
         mPaytoReplay = param1;
         mBoxButton0.enabled = true;
         mBoxButton1.enabled = true;
         mBoxButton2.enabled = true;
         if(mRewardIcon0 != null)
         {
            (mDailyRewardMysteryBoxPopup : ASAny).inv_empty_slot_storage_box01.removeChild(mRewardIcon0);
            (mDailyRewardMysteryBoxPopup : ASAny).inv_empty_slot_storage_box02.removeChild(mRewardIcon1);
            (mDailyRewardMysteryBoxPopup : ASAny).inv_empty_slot_storage_box03.removeChild(mRewardIcon2);
         }
         mBox0.visible = true;
         mBox0.alpha = 1;
         mBoxButton0.root.filters = null;
         mBox1.visible = true;
         mBox1.alpha = 1;
         mBoxButton1.root.filters = null;
         mBox2.visible = true;
         mBox2.alpha = 1;
         mBoxButton2.root.filters = null;
         ASCompat.setProperty((mDailyRewardMysteryBoxPopup : ASAny).label_message3, "visible", false);
         ASCompat.setProperty((mDailyRewardMysteryBoxPopup : ASAny).timer_clock, "visible", false);
         ASCompat.setProperty((mDailyRewardMysteryBoxPopup : ASAny).label_message2, "text", Locale.getString("DAILY_REWARDS_SELECT"));
         mRewardIcon0 = null;
         mRewardIcon1 = null;
         mRewardIcon2 = null;
         mDBFacade.menuNavigationController.setFocusedUiObject(mBoxButton0);
      }
      
      function exitButtonPushed() 
      {
         mDBFacade.menuNavigationController.popLayer("DAILY_LOGIN_POPUP");
         mDBFacade.metrics.log("DailyRewardCancel");
         if(mCountdownTimer == null)
         {
            mDBFacade.metrics.log("DailyRewardsExitedWithoutRedeeming");
         }
         destroy();
      }
      
      override public function destroy() 
      {
         stopTimer();
         if(mMysterySlideTimer != null)
         {
            mMysterySlideTimer.stop();
         }
         if(mCountdownTimer != null)
         {
            mCountdownTimer.stop();
         }
         if(mGoldSlideTimer != null)
         {
            mGoldSlideTimer.stop();
         }
         if(mGoldCountTimer != null)
         {
            mGoldCountTimer.stop();
         }
         if(mGoldDarkTimer != null)
         {
            mGoldDarkTimer.stop();
         }
         if(mMysteryFadeTimer != null)
         {
            mMysteryFadeTimer.stop();
         }
         if(mWindowGoldDisplayed == true)
         {
            if(mRoot != null && mDailyRewardGoldPopup != null)
            {
               mRoot.removeChild(mDailyRewardGoldPopup);
            }
         }
         if(mWindowMysteryDisplayed == true)
         {
            if(mRoot != null && mDailyRewardMysteryBoxPopup != null)
            {
               mRoot.removeChild(mDailyRewardMysteryBoxPopup);
            }
         }
         mDailyRewardGoldPopup = null;
         mDailyRewardMysteryBoxPopup = null;
         mTownRoot = null;
         if(mCloseButton != null)
         {
            mCloseButton.destroy();
         }
         mCloseButton = null;
         if(mCloseCallback != null)
         {
            mCloseCallback();
         }
         mCloseCallback = null;
         if(mSoundComponent != null)
         {
            mSoundComponent.destroy();
            mSoundComponent = null;
         }
         mDBFacade.mInDailyReward = false;
         super.destroy();
         mDBFacade = null;
      }
      
      public function askAboutDailyReward() 
      {
         var requestFunc= JSONRPCService.getFunction("AskAboutDailyReward",mDBFacade.rpcRoot + "store");
         requestFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,mDBFacade.demographics,function(param1:Array<ASAny>)
         {
            mRewardInfo = param1;
            if(ASCompat.toNumber(mRewardInfo[3]) > 0 && mForceOpen == false)
            {
               Logger.info("UIDailyRewards: Already Redeemed Closings Daily Reward Info: " + param1);
               destroy();
            }
            else
            {
               Logger.info("UIDailyRewards: success - got Daily Reward Info: " + param1);
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Items/db_icons_items.swf"),coinsLoaded);
            }
         },function(param1:Error)
         {
            Logger.info("UIDailyRewards: asking about daily rewards: ERROR:" + Std.string(param1));
         });
      }
      
      function coinsLoaded(param1:SwfAsset) 
      {
         var mysteryBoxClass:Dynamic;
         var smallCoinClass:Dynamic;
         var mediumCoinClass:Dynamic;
         var largeCoinClass:Dynamic;
         var swfAsset= param1;
         if(mDBFacade == null)
         {
            return;
         }
         mysteryBoxClass = swfAsset.getClass("db_items_box_mystery");
         mBox0 = ASCompat.dynamicAs(ASCompat.createInstance(mysteryBoxClass, []), flash.display.MovieClip);
         mBox1 = ASCompat.dynamicAs(ASCompat.createInstance(mysteryBoxClass, []), flash.display.MovieClip);
         mBox2 = ASCompat.dynamicAs(ASCompat.createInstance(mysteryBoxClass, []), flash.display.MovieClip);
         mBoxButton0 = new UIButton(mDBFacade,mBox0);
         mBoxButton1 = new UIButton(mDBFacade,mBox1);
         mBoxButton2 = new UIButton(mDBFacade,mBox2);
         mBoxButton0.releaseCallback = function()
         {
            requestDailyRewards(0);
         };
         mBoxButton1.releaseCallback = function()
         {
            requestDailyRewards(1);
         };
         mBoxButton2.releaseCallback = function()
         {
            requestDailyRewards(2);
         };
         mBoxButton0.rollOverCallback = function()
         {
            hilightButton(mBoxButton0);
         };
         mBoxButton1.rollOverCallback = function()
         {
            hilightButton(mBoxButton1);
         };
         mBoxButton2.rollOverCallback = function()
         {
            hilightButton(mBoxButton2);
         };
         mBoxButton0.rollOutCallback = function()
         {
            unhilightButton(mBoxButton0);
         };
         mBoxButton1.rollOutCallback = function()
         {
            unhilightButton(mBoxButton1);
         };
         mBoxButton2.rollOutCallback = function()
         {
            unhilightButton(mBoxButton2);
         };
         mBoxButton0.enabled = true;
         mBoxButton1.enabled = true;
         mBoxButton2.enabled = true;
         mDBFacade.menuNavigationController.pushNewLayer("DAILY_LOGIN_POPUP",exitButtonPushed,mExitButton,mExitButton);
         mBoxButton0.isToTheLeftOf(mBoxButton1);
         mBoxButton1.isToTheLeftOf(mBoxButton2);
         mBoxButton0.downNavigation = mReplayButton;
         mBoxButton0.upNavigation = mExitButton;
         mBoxButton1.upNavigation = mExitButton;
         mBoxButton2.upNavigation = mExitButton;
         mExitButton.downNavigation = mBoxButton0;
         mDBFacade.menuNavigationController.setFocusedUiObject(mBoxButton0);
         ASCompat.setProperty((mDailyRewardMysteryBoxPopup : ASAny).inv_empty_slot_storage_box01.storage_box, "visible", false);
         ASCompat.setProperty((mDailyRewardMysteryBoxPopup : ASAny).inv_empty_slot_storage_box02.storage_box, "visible", false);
         ASCompat.setProperty((mDailyRewardMysteryBoxPopup : ASAny).inv_empty_slot_storage_box03.storage_box, "visible", false);
         (mDailyRewardMysteryBoxPopup : ASAny).inv_empty_slot_storage_box01.addChild(mBox0);
         (mDailyRewardMysteryBoxPopup : ASAny).inv_empty_slot_storage_box02.addChild(mBox1);
         (mDailyRewardMysteryBoxPopup : ASAny).inv_empty_slot_storage_box03.addChild(mBox2);
         mBoxArray = [mBox0,mBox1,mBox2];
         smallCoinClass = swfAsset.getClass("db_items_gems_small");
         mediumCoinClass = swfAsset.getClass("db_items_gems_medium_static");
         largeCoinClass = swfAsset.getClass("db_items_gems_large_static");
         if(ASCompat.toNumber(mRewardInfo[0]) == 1)
         {
            smallCoinClass = swfAsset.getClass("db_items_gems_small_anim");
         }
         else if(ASCompat.toNumber(mRewardInfo[0]) == 2)
         {
            mediumCoinClass = swfAsset.getClass("db_items_gems_medium");
         }
         else if(ASCompat.toNumber(mRewardInfo[0]) == 3)
         {
            largeCoinClass = swfAsset.getClass("db_items_gems_large");
         }
         setRewardAmounts(ASCompat.toInt(mRewardInfo[0]),ASCompat.toInt(mRewardInfo[1]),ASCompat.dynamicAs(mRewardInfo[2], Array),ASCompat.toInt(mRewardInfo[3]),ASCompat.toInt(mRewardInfo[4]),smallCoinClass,mediumCoinClass,largeCoinClass);
      }
      
      function hilightButton(param1:UIButton) 
      {
         var _loc2_= new GlowFilter((16763972 : UInt),1,7,7,3,1,false,false);
         _loc2_.quality = 2;
         param1.root.filters = cast([_loc2_]);
      }
      
      function unhilightButton(param1:UIButton) 
      {
         var _loc2_= new GlowFilter((0 : UInt),0,5,5,1,1,false,false);
         _loc2_.quality = 2;
         param1.root.filters = null;
      }
      
      function setRewardAmounts(param1:Int, param2:Int, param3:Array<ASAny>, param4:Int, param5:Int, param6:Dynamic, param7:Dynamic, param8:Dynamic) 
      {
         var _loc9_:Array<ASAny> = null;
         displayWindow();
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).label_number01, "visible", true);
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).label_number02, "visible", true);
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).label_number03, "visible", true);
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).label_number, "visible", true);
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).label_number01, "text", param3[0]);
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).label_number02, "text", param3[1]);
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).label_number03, "text", param3[2]);
         mCostPlay = param5;
         ASCompat.setProperty((mDailyRewardMysteryBoxPopup : ASAny).button_replay.l_numberabel, "text", param5);
         if(param4 > 0 && 1 != 0)
         {
            mSkipGoldCount = true;
            ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).label_number, "text", ASCompat.toNumber(param3[param1 - 1]) * param2);
            ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).crewBonus_anim.crewBonus.header_crew_bonus_number, "text", Std.string((param2 - 1)));
         }
         else
         {
            ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).label_number, "text", 0);
            ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).crewBonus_anim.crewBonus.header_crew_bonus_number, "text", 0);
         }
         ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).crewBonus_anim, "visible", true);
         mCrewBonusController.play();
         var _loc14_= ASCompat.dynamicAs(ASCompat.createInstance(param6, []), flash.display.MovieClip);
         var _loc15_= ASCompat.dynamicAs(ASCompat.createInstance(param7, []), flash.display.MovieClip);
         var _loc16_= ASCompat.dynamicAs(ASCompat.createInstance(param8, []), flash.display.MovieClip);
         var _loc12_= new MovieClipRenderController(mDBFacade,_loc14_);
         var _loc10_= new MovieClipRenderController(mDBFacade,_loc15_);
         var _loc11_= new MovieClipRenderController(mDBFacade,_loc16_);
         _loc12_.loop = true;
         _loc10_.loop = true;
         _loc11_.loop = true;
         _loc12_.play((0 : UInt),true);
         _loc10_.play((0 : UInt),true);
         _loc11_.play((0 : UInt),true);
         var _loc13_= new GlowFilter((16777215 : UInt),1,25,25,1,1,false,false);
         _loc13_.quality = 2;
         (mDailyRewardGoldPopup : ASAny).inv_empty_slot01.addChild(_loc14_);
         (mDailyRewardGoldPopup : ASAny).inv_empty_slot02.addChild(_loc15_);
         (mDailyRewardGoldPopup : ASAny).inv_empty_slot03.addChild(_loc16_);
         if(param1 == 1)
         {
            ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).checkbox01.selected, "visible", true);
            ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).inv_empty_slot01, "filters", [_loc13_]);
            _loc15_.scaleX = 0.75;
            _loc15_.scaleY = 0.75;
            _loc16_.scaleX = 0.75;
            _loc16_.scaleY = 0.75;
         }
         else if(param1 == 2)
         {
            ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).checkbox01.selected, "visible", true);
            ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).checkbox02.selected, "visible", true);
            ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).arrow01, "visible", true);
            ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).inv_empty_slot02, "filters", [_loc13_]);
            _loc14_.scaleX = 0.75;
            _loc14_.scaleY = 0.75;
            _loc16_.scaleX = 0.75;
            _loc16_.scaleY = 0.75;
         }
         else if(param1 == 3)
         {
            ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).checkbox01.selected, "visible", true);
            ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).checkbox02.selected, "visible", true);
            ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).checkbox03.selected, "visible", true);
            ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).arrow01, "visible", true);
            ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).arrow02, "visible", true);
            ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).inv_empty_slot03, "filters", [_loc13_]);
            _loc14_.scaleX = 0.75;
            _loc14_.scaleY = 0.75;
            _loc15_.scaleX = 0.75;
            _loc15_.scaleY = 0.75;
         }
         if(param4 > 0)
         {
            _loc9_ = [0,0,0];
            displayRewards(0,_loc9_,param4,false);
         }
      }
      
      function requestDailyRewards(param1:Int) 
      {
         var requestFunc:ASFunction;
         var boxPicked= param1;
         mBoxButton0.enabled = false;
         mBoxButton1.enabled = false;
         mBoxButton2.enabled = false;
         requestFunc = JSONRPCService.getFunction("RequestRedeemDailyRewards",mDBFacade.rpcRoot + "store");
         requestFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,boxPicked,mPaytoReplay,mDBFacade.demographics,function(param1:Array<ASAny>)
         {
            var _loc2_:Array<ASAny> = null;
            Logger.info("UIDailyRewards: success - Redeemed Daily Reward: " + param1 + " Picked:" + boxPicked);
            if(ASCompat.toNumber(param1[0]) == 0 && ASCompat.toNumber(param1[1]) == 0)
            {
               _loc2_ = [0,0,0];
               displayRewards(boxPicked,_loc2_,ASCompat.toInt(param1[2]),false);
            }
            else
            {
               displayRewards(boxPicked,ASCompat.dynamicAs(param1[0], Array),ASCompat.toInt(param1[2]),ASCompat.toBool(param1[3]));
               mDBFacade.dbAccountInfo.parseResponse(param1[1]);
            }
         },function(param1:Error)
         {
            Logger.info("UIDailyRewards: Redeemed daily rewards: ERROR:" + Std.string(param1));
         });
         mPaytoReplay = false;
      }
      
      function displayRewards(param1:Int, param2:Array<ASAny>, param3:Int, param4:Bool) 
      {
         var offer0:GMOffer;
         var offer1:GMOffer;
         var offer2:GMOffer;
         var boxPicked= param1;
         var rewards= param2;
         var timeToNext= param3;
         var gotRefund= param4;
         if(mDBFacade == null)
         {
            return;
         }
         mBoxPicked = boxPicked;
         mNoRoomInStorageForReward = gotRefund;
         mDisplayOffers = new Vector<GMOffer>();
         if(ASCompat.toNumber(rewards[0]) == 0)
         {
            ASCompat.setProperty((mDailyRewardMysteryBoxPopup : ASAny).label_message2, "text", Locale.getString("DAILY_REWARDS_ALREADY"));
            ASCompat.setProperty((mDailyRewardGoldPopup : ASAny).label_message1, "text", Locale.getString("DAILY_REWARDS_ALREADY_GOLD"));
            startTimer(timeToNext);
            return;
         }
         while(rewards.length > 0)
         {
            mDisplayOffers.push(ASCompat.dynamicAs(mDBFacade.gameMaster.offerById.itemFor(rewards.pop()), gameMasterDictionary.GMOffer));
         }
         ASCompat.ASVector.reverse(mDisplayOffers);
         if(mDisplayOffers.length == 3)
         {
            mSlotMovieController.loop = false;
            mSlotMovie.play();
            mSlotMovieController.playRate = 2.65;
            mSlotMovieController.play((0 : UInt));
            mSlotMovie.visible = true;
            if(mSoundBox != null)
            {
               mSoundComponent.playSfxOneShot(mSoundBox);
            }
            offer0 = mDisplayOffers[0];
            offer1 = mDisplayOffers[1];
            offer2 = mDisplayOffers[2];
            if(offer0.BundleSwfFilepath != "" && offer0.BundleIcon != "")
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(offer0.BundleSwfFilepath),function(param1:SwfAsset)
               {
                  var rewardController0:MovieClipRenderController;
                  var swfAsset= param1;
                  var rewardIconClass0= swfAsset.getClass(offer0.BundleIcon);
                  mRewardIcon0 = ASCompat.dynamicAs(ASCompat.createInstance(rewardIconClass0, []), flash.display.MovieClip);
                  (mDailyRewardMysteryBoxPopup : ASAny).inv_empty_slot_storage_box01.addChild(mRewardIcon0);
                  rewardController0 = new MovieClipRenderController(mDBFacade,mRewardIcon0);
                  rewardController0.play((0 : UInt),true);
                  if(boxPicked == 0)
                  {
                     mBox0.visible = false;
                     (mDailyRewardMysteryBoxPopup : ASAny).inv_empty_slot_storage_box01.addChild(mSlotMovie);
                     mSlotMovieController.finishedCallback = function()
                     {
                        finalRewardReveal(0,timeToNext);
                     };
                     mRewardName = offer0.BundleName;
                     mRewardIcon0.visible = false;
                  }
                  else
                  {
                     mRewardIcon0.alpha = 0;
                  }
               });
            }
            if(offer1.BundleSwfFilepath != "" && offer1.BundleIcon != "")
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(offer1.BundleSwfFilepath),function(param1:SwfAsset)
               {
                  var rewardController1:MovieClipRenderController;
                  var swfAsset= param1;
                  var rewardIconClass1= swfAsset.getClass(offer1.BundleIcon);
                  mRewardIcon1 = ASCompat.dynamicAs(ASCompat.createInstance(rewardIconClass1, []), flash.display.MovieClip);
                  (mDailyRewardMysteryBoxPopup : ASAny).inv_empty_slot_storage_box02.addChild(mRewardIcon1);
                  rewardController1 = new MovieClipRenderController(mDBFacade,mRewardIcon1);
                  rewardController1.play((0 : UInt),true);
                  if(boxPicked == 1)
                  {
                     mBox1.visible = false;
                     (mDailyRewardMysteryBoxPopup : ASAny).inv_empty_slot_storage_box02.addChild(mSlotMovie);
                     mSlotMovieController.finishedCallback = function()
                     {
                        finalRewardReveal(1,timeToNext);
                     };
                     mRewardName = offer1.BundleName;
                     mRewardIcon1.visible = false;
                  }
                  else
                  {
                     mRewardIcon1.alpha = 0;
                  }
               });
            }
            if(offer2.BundleSwfFilepath != "" && offer2.BundleIcon != "")
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(offer2.BundleSwfFilepath),function(param1:SwfAsset)
               {
                  var rewardController2:MovieClipRenderController;
                  var swfAsset= param1;
                  var rewardIconClass2= swfAsset.getClass(offer2.BundleIcon);
                  mRewardIcon2 = ASCompat.dynamicAs(ASCompat.createInstance(rewardIconClass2, []), flash.display.MovieClip);
                  (mDailyRewardMysteryBoxPopup : ASAny).inv_empty_slot_storage_box03.addChild(mRewardIcon2);
                  rewardController2 = new MovieClipRenderController(mDBFacade,mRewardIcon2);
                  rewardController2.play((0 : UInt),true);
                  if(boxPicked == 2)
                  {
                     mBox2.visible = false;
                     (mDailyRewardMysteryBoxPopup : ASAny).inv_empty_slot_storage_box03.addChild(mSlotMovie);
                     mSlotMovieController.finishedCallback = function()
                     {
                        finalRewardReveal(2,timeToNext);
                     };
                     mRewardName = offer2.BundleName;
                     mRewardIcon2.visible = false;
                  }
                  else
                  {
                     mRewardIcon2.alpha = 0;
                  }
               });
            }
            mRewardArray = [mRewardIcon0,mRewardIcon1,mRewardIcon2];
         }
         ASCompat.setProperty((mDailyRewardMysteryBoxPopup : ASAny).label_message2, "text", Locale.getString("DAILY_REWARDS_YOU_GOT"));
         if(mDBFacade.steamAchievementsManager != null)
         {
            mDBFacade.steamAchievementsManager.setAchievement("COLLECT_DAILY_REWARD");
         }
      }
      
      public function desaturate(param1:DisplayObject) 
      {
         var _loc2_:Float = 0.212671;
         var _loc5_:Float = 0.71516;
         var _loc3_:Float = 0.072169;
         var _loc6_:Float = 0.7;
         var _loc4_:Float = 0.6;
         var _loc7_:Float = 0.5;
         var _loc8_:Array<ASAny> = [_loc2_ * _loc6_,_loc5_ * _loc6_,_loc3_ * _loc6_,0,0,_loc2_ * _loc4_,_loc5_ * _loc4_,_loc3_ * _loc4_,0,0,_loc2_ * _loc7_,_loc5_ * _loc7_,_loc3_ * _loc7_,0,0,0,0,0,1,0];
         param1.filters = cast([new ColorMatrixFilter(cast(_loc8_))]);
      }
      
      function finalRewardReveal(param1:Int, param2:Int) 
      {
         var _loc4_:TextFormat = null;
         var _loc3_= 0;
         _loc3_ = 0;
         while(_loc3_ < 3)
         {
            if(param1 != _loc3_)
            {
               desaturate(ASCompat.dynamicAs(mRewardArray[_loc3_], flash.display.DisplayObject));
            }
            _loc3_++;
         }
         ASCompat.setProperty(mRewardArray[0], "visible", true);
         ASCompat.setProperty(mRewardArray[1], "visible", true);
         ASCompat.setProperty(mRewardArray[2], "visible", true);
         ASCompat.setProperty(mRewardArray[param1], "visible", true);
         mSlotMovie.visible = false;
         startBoxFade();
         if(mNoRoomInStorageForReward)
         {
            ASCompat.setProperty((mDailyRewardMysteryBoxPopup : ASAny).label_message2, "text", Locale.getString("DAILY_REWARDS_YOU_GOT_REFUND") + mRewardName.toUpperCase() + Locale.getString("DAILY_REWARDS_STORAGE_FULL"));
            _loc4_ = new TextFormat();
            _loc4_.size = 14;
            (mDailyRewardMysteryBoxPopup : ASAny).label_message2.setTextFormat(_loc4_);
         }
         else
         {
            ASCompat.setProperty((mDailyRewardMysteryBoxPopup : ASAny).label_message2, "text", Locale.getString("DAILY_REWARDS_YOU_GOT") + mRewardName.toUpperCase());
         }
         mTimeToNext = param2;
      }
   }


