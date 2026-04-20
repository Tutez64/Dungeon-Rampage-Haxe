package uI.training
;
   import account.AvatarInfo;
   import account.StoreServicesController;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.event.EventComponent;
   import brain.logger.Logger;
   import brain.render.MovieClipRenderController;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.sceneGraph.SceneGraphManager;
   import brain.uI.UIButton;
   import brain.utils.MemoryTracker;
   import brain.workLoop.LogicalWorkComponent;
   import dBGlobals.DBGlobal;
   import events.DBAccountResponseEvent;
   import facade.DBFacade;
   import facade.GameMasterLocale;
   import facade.Locale;
   import gameMasterDictionary.GMHero;
   import gameMasterDictionary.GMOffer;
   import gameMasterDictionary.GMSkin;
   import town.TownHeader;
   import uI.equipPicker.HeroWithEquipPicker;
   import uI.popup.UIRetrainPopup;
   import uI.UITownTweens;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
    class UIHeroTraining
   {
      
      static var RESPEC_OFFER_ID:UInt = (51303 : UInt);
      
      var mDBFacade:DBFacade;
      
      var mLastHeroId:UInt = 0;
      
      var mFakeHeroInfo:AvatarInfo;
      
      var mHeroInfo:AvatarInfo;
      
      var mSelectedHero:GMHero;
      
      var mHeroWithEquipPicker:HeroWithEquipPicker;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mAssetsLoaded:Bool = false;
      
      var mIconSwfAsset:SwfAsset;
      
      var mUIRoot:MovieClip;
      
      var mTownHeader:TownHeader;
      
      var mHeroPortrait:MovieClip;
      
      var mHeroPortraitText:TextField;
      
      var mStatHelpers:Vector<UIStatHelper>;
      
      var mStatLevelPlusButtons:Vector<UIButton>;
      
      var mHeroLevel:UInt = 0;
      
      var mBasicCurrencyText:TextField;
      
      var mPremiumCurrencyText:TextField;
      
      var mSpendButton:UIButton;
      
      var mSpendAmount:Int = 0;
      
      var mPendingDBWrite:Bool = false;
      
      var mResetButton:UIButton;
      
      var mGMOffer:GMOffer;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mEventComponent:EventComponent;
      
      public function new(param1:DBFacade, param2:SwfAsset, param3:MovieClip, param4:TownHeader)
      {
         
         mDBFacade = param1;
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"UIHeroTraining");
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"UIHeroTraining");
         mEventComponent = new EventComponent(mDBFacade);
         mTownHeader = param4;
         var _loc6_= param2.getClass("DR_weapon_tooltip");
         var _loc7_= param2.getClass("avatar_tooltip");
         mHeroWithEquipPicker = new HeroWithEquipPicker(mDBFacade,ASCompat.dynamicAs((param3 : ASAny).hero_picker, flash.display.MovieClip),_loc6_,_loc7_,heroSelected);
         var _loc5_:ASObject = {"avatar_id":103};
         mFakeHeroInfo = new AvatarInfo(mDBFacade,_loc5_,null);
         this.setupUI(param3,param2.getClass("stat_tooltip"));
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Stats/db_icon_stats.swf"),setupIcons);
         mGMOffer = ASCompat.dynamicAs(mDBFacade.gameMaster.offerById.itemFor(RESPEC_OFFER_ID), gameMasterDictionary.GMOffer);
      }
      
      function setupUI(param1:MovieClip, param2:Dynamic) 
      {
         var i = 0;
         var rootClip= param1;
         var tooltipClass= param2;
         mUIRoot = ASCompat.dynamicAs((rootClip : ASAny).training_main, flash.display.MovieClip);
         mHeroPortrait = ASCompat.dynamicAs((rootClip : ASAny).training_avatar, flash.display.MovieClip);
         mHeroPortraitText = ASCompat.dynamicAs((mUIRoot : ASAny).hero_text, flash.text.TextField);
         mStatHelpers = new Vector<UIStatHelper>();
         mStatLevelPlusButtons = new Vector<UIButton>();
         var createFunc:ASFunction = function(param1:Int):ASFunction
         {
            var i= param1;
            return function()
            {
               statPlusReleased(i);
            };
         };
         var listOfStatUpgrades:Array<ASAny> = [(mUIRoot : ASAny).UI_statupgrade1,(mUIRoot : ASAny).UI_statupgrade2,(mUIRoot : ASAny).UI_statupgrade3,(mUIRoot : ASAny).UI_statupgrade4];
         var listOfStatPlusButtons:Array<ASAny> = [(mUIRoot : ASAny).statupgrade1_plus_button,(mUIRoot : ASAny).statupgrade2_plus_button,(mUIRoot : ASAny).statupgrade3_plus_button,(mUIRoot : ASAny).statupgrade4_plus_button];
         i = 0;
         while(i < 4)
         {
            mStatHelpers.push(new UIStatHelper(mDBFacade,tooltipClass,ASCompat.dynamicAs(listOfStatUpgrades[i], flash.display.MovieClip)));
            mStatLevelPlusButtons.push(new UIButton(mDBFacade,ASCompat.dynamicAs(listOfStatPlusButtons[i], flash.display.MovieClip)));
            mStatLevelPlusButtons[i].releaseCallback = ASCompat.asFunction(createFunc(i));
            i = i + 1;
         }
         mSpendButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).spend_button, flash.display.MovieClip));
         mSpendButton.enabled = false;
         ASCompat.setProperty((mSpendButton.root : ASAny).button_text, "text", Locale.getString("TRAINING_POINTS"));
         mResetButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).reset_button, flash.display.MovieClip));
         mResetButton.label.text = Locale.getString("RETRAIN");
         mResetButton.releaseCallback = function()
         {
            resetReleased();
         };
         disableHud();
      }
      
      public function animateEntry() 
      {
         if(mDBFacade.featureFlags.getFlagValue("want-town-animations"))
         {
            UITownTweens.avatarFadeInTweenSequence(mHeroPortrait);
            mTownHeader.rootMovieClip.visible = false;
            mLogicalWorkComponent.doLater(0.20833333333333334,function(param1:brain.clock.GameClock)
            {
               mTownHeader.animateHeader();
            });
            mUIRoot.visible = false;
            mLogicalWorkComponent.doLater(0.16666666666666666,function(param1:brain.clock.GameClock)
            {
               UITownTweens.rightPanelTweenSequence(mUIRoot,mDBFacade);
            });
            mHeroWithEquipPicker.visible = false;
            mLogicalWorkComponent.doLater(0.5,function(param1:brain.clock.GameClock)
            {
               UITownTweens.footerTweenSequence(mHeroWithEquipPicker.root,mDBFacade);
            });
         }
         setupMenuNavigation();
         setButtonNavigationFilters();
      }
      
      public function setupIcons(param1:SwfAsset) 
      {
         mAssetsLoaded = true;
         mIconSwfAsset = param1;
      }
      
      public function destroy() 
      {
         var _loc1_= 0;
         mDBFacade = null;
         mFakeHeroInfo.destroy();
         _loc1_ = 0;
         while(_loc1_ < 4)
         {
            mStatHelpers[_loc1_].destroy();
            mStatLevelPlusButtons[_loc1_].destroy();
            _loc1_++;
         }
         mSpendButton.destroy();
         mResetButton.destroy();
         mHeroWithEquipPicker.destroy();
         mLogicalWorkComponent.destroy();
         mSceneGraphComponent.destroy();
         mAssetLoadingComponent.destroy();
         mEventComponent.destroy();
      }
      
      public function enableHud() 
      {
         mTownHeader.title = Locale.getString("TRAINING_HEADER");
         mPendingDBWrite = false;
         mEventComponent.removeAllListeners();
         mEventComponent.addListener("DB_ACCOUNT_INFO_RESPONSE",dbAccountInfoUpdate);
         mHeroWithEquipPicker.refresh(true);
         mHeroInfo = mDBFacade.dbAccountInfo.activeAvatarInfo;
         mSelectedHero = ASCompat.dynamicAs(mDBFacade.gameMaster.heroById.itemFor(mHeroInfo.avatarType), gameMasterDictionary.GMHero);
         var _loc1_= mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(mSelectedHero.Id);
         this.heroSelected(mSelectedHero,_loc1_);
         mUIRoot.visible = true;
         mHeroPortrait.visible = true;
      }
      
      public function disableHud() 
      {
         mEventComponent.removeAllListeners();
         mUIRoot.visible = false;
         mHeroPortrait.visible = false;
         mHeroWithEquipPicker.setAvatarAlert(false);
         resetMenuNavigation();
      }
      
      function greyHero(param1:Bool) 
      {
         var _loc4_= Vector.ofArray(([mUIRoot] : Array<DisplayObject>));
         var _loc2_= SceneGraphManager.getGrayScaleSaturationFilter(5);
         var _loc3_:DisplayObject;
         if (checkNullIteratee(_loc4_)) for (_tmp_ in _loc4_)
         {
            _loc3_ = _tmp_;
            ASCompat.setProperty(_loc3_, "filters", param1 ? [_loc2_] : []);
         }
      }
      
      function shouldGreyHero(param1:GMHero) : Bool
      {
         return false;
      }
      
      function writeStatsToDatabase() 
      {
         mHeroInfo.RPC_updateAvatarSlots(mStatHelpers[0].amount,mStatHelpers[1].amount,mStatHelpers[2].amount,mStatHelpers[3].amount,null,null);
         mPendingDBWrite = false;
      }
      
      function heroSelected(param1:GMHero, param2:Bool) 
      {
         var gmSkin:GMSkin;
         var avatarJson:ASObject;
         var gmHero= param1;
         var owned= param2;
         if(gmHero == null)
         {
            return;
         }
         if(mPendingDBWrite)
         {
            writeStatsToDatabase();
         }
         greyHero(!owned);
         mSelectedHero = gmHero;
         mHeroInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mSelectedHero.Id);
         if(mHeroInfo == null)
         {
            avatarJson = {"avatar_id":mSelectedHero.Id};
            mFakeHeroInfo.init(avatarJson);
            mHeroInfo = mFakeHeroInfo;
            gmSkin = mDBFacade.gameMaster.getSkinByConstant(mSelectedHero.DefaultSkin);
         }
         else
         {
            gmSkin = mDBFacade.gameMaster.getSkinByType(mHeroInfo.skinId);
         }
         mHeroLevel = mSelectedHero.getLevelFromExp(mHeroInfo.experience);
         if(gmSkin == null)
         {
            Logger.error("Unable to find gmSkin for ID: " + mHeroInfo.skinId);
         }
         else
         {
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmSkin.PortraitName),function(param1:SwfAsset)
            {
               var _loc3_= param1.getClass(gmSkin.CardName);
               if(_loc3_ == null)
               {
                  return;
               }
               var _loc4_= ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
               _loc4_.scaleX = _loc4_.scaleY = 0.7;
               _loc4_.x = 15;
               var _loc2_= new MovieClipRenderController(mDBFacade,_loc4_);
               _loc2_.play();
               if(mHeroPortrait.numChildren > 0)
               {
                  mHeroPortrait.removeChildAt(0);
               }
               mHeroPortrait.addChildAt(_loc4_,0);
            });
         }
         readSelectedHeroInfo();
         mHeroWithEquipPicker.setAvatarAlert(true);
         updateUIFromDB();
      }
      
      function dbAccountInfoUpdate(param1:DBAccountResponseEvent) 
      {
         mHeroInfo = param1.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mSelectedHero.Id);
         mHeroWithEquipPicker.setAvatarAlert(true);
         updateUIFromDB();
      }
      
      @:isVar var spendAmount(get,never):Int;
function  get_spendAmount() : Int
      {
         if(mHeroInfo == mFakeHeroInfo)
         {
            return 0;
         }
         return mHeroInfo.skillPointsAvailable;
      }
      
      @:isVar var spendAmountClient(get,never):Int;
function  get_spendAmountClient() : Int
      {
         if(mHeroInfo == mFakeHeroInfo)
         {
            return 0;
         }
         return Std.int(Math.max(mHeroInfo.skillPointsEarned - (mStatHelpers[0].amount + mStatHelpers[1].amount + mStatHelpers[2].amount + mStatHelpers[3].amount),0));
      }
      
      function updateResetButton() 
      {
         var _loc1_= mSelectedHero.getTotalStatFromExp(mHeroInfo.experience);
         var _loc2_= (spendAmountClient : UInt);
         mResetButton.enabled = false;
         if(mHeroInfo != mFakeHeroInfo && _loc2_ != _loc1_)
         {
            mResetButton.enabled = true;
         }
      }
      
      public function readSelectedHeroInfo() 
      {
         var _loc2_= 0;
         mHeroPortraitText.text = GameMasterLocale.getGameMasterSubString("SKIN_NAME",mSelectedHero.Constant).toUpperCase();
         var _loc1_:Array<ASAny> = [mSelectedHero.StatUpgrade1,mSelectedHero.StatUpgrade2,mSelectedHero.StatUpgrade3,mSelectedHero.StatUpgrade4];
         _loc2_ = 0;
         while(_loc2_ < 4)
         {
            mStatHelpers[_loc2_].statName = _loc1_[_loc2_];
            mStatHelpers[_loc2_].refresh(mIconSwfAsset);
            _loc2_++;
         }
         ASCompat.setProperty((mUIRoot : ASAny).training_db_label, "text", Locale.getString("DUNGEON_BUSTER"));
         ASCompat.setProperty((mUIRoot : ASAny).training_db_name, "text", GameMasterLocale.getGameMasterSubString("ATTACK_BUSTER_NAME",mDBFacade.gameMaster.attackByConstant.itemFor(mSelectedHero.DBuster1).Constant).toUpperCase());
         ASCompat.setProperty((mUIRoot : ASAny).training_db_description, "text", GameMasterLocale.getGameMasterSubString("ATTACK_BUSTER_DESCRIPTION",mDBFacade.gameMaster.attackByConstant.itemFor(mSelectedHero.DBuster1).Constant));
         ASCompat.setProperty((mUIRoot : ASAny).xp_label.level_label, "text", mHeroLevel);
      }
      
      function updateUIClient() 
      {
         var _loc4_= 0;
         var _loc3_= (25 : UInt);
         var _loc2_= (50 : UInt);
         var _loc1_= (75 : UInt);
         mPendingDBWrite = true;
         mSpendAmount = spendAmountClient;
         _loc4_ = 0;
         while(_loc4_ < 4)
         {
            mStatHelpers[_loc4_].updateUI();
            mStatLevelPlusButtons[_loc4_].enabled = false;
            _loc4_++;
         }
         ASCompat.setProperty((mSpendButton.root : ASAny).spend_amount_text, "text", mSpendAmount);
         if(mSpendAmount <= 0)
         {
            mSpendAmount = 0;
            mHeroWithEquipPicker.disableAvatarAlertOnSelectedHero();
         }
         else
         {
            _loc4_ = 0;
            while(_loc4_ < 4)
            {
               if(mStatHelpers[_loc4_].statAmount < _loc1_)
               {
                  mStatLevelPlusButtons[_loc4_].enabled = true;
               }
               _loc4_++;
            }
         }
         updateResetButton();
      }
      
      function updateUIFromDB() 
      {
         var _loc4_= 0;
         var _loc3_= (25 : UInt);
         var _loc2_= (50 : UInt);
         var _loc1_= (75 : UInt);
         var _loc5_:Array<ASAny> = [mHeroInfo.statUpgrade1,mHeroInfo.statUpgrade2,mHeroInfo.statUpgrade3,mHeroInfo.statUpgrade4];
         _loc4_ = 0;
         while(_loc4_ < 4)
         {
            mStatHelpers[_loc4_].statAmount = (ASCompat.toInt(_loc5_[_loc4_]) : UInt);
            _loc4_++;
         }
         mHeroLevel = mSelectedHero.getLevelFromExp(mHeroInfo.experience);
         mSpendAmount = spendAmount;
         _loc4_ = 0;
         while(_loc4_ < 4)
         {
            mStatHelpers[_loc4_].updateUI();
            mStatLevelPlusButtons[_loc4_].enabled = false;
            _loc4_++;
         }
         ASCompat.setProperty((mSpendButton.root : ASAny).spend_amount_text, "text", mSpendAmount);
         if(mSpendAmount <= 0)
         {
            mSpendAmount = 0;
         }
         else
         {
            _loc4_ = 0;
            while(_loc4_ < 4)
            {
               if(mStatHelpers[_loc4_].statAmount < _loc1_)
               {
                  mStatLevelPlusButtons[_loc4_].enabled = true;
               }
               _loc4_++;
            }
         }
         updateResetButton();
      }
      
      public function setCurrency(param1:Int, param2:Int) 
      {
         if(!mAssetsLoaded)
         {
            return;
         }
         mBasicCurrencyText.text = Std.string(param1);
         mPremiumCurrencyText.text = Std.string(param2);
      }
      
      public function setBasicCurrency(param1:Int) 
      {
         if(!mAssetsLoaded)
         {
            return;
         }
         mBasicCurrencyText.text = Std.string(param1);
      }
      
      public function setPremiumCurrency(param1:Int) 
      {
         if(!mAssetsLoaded)
         {
            return;
         }
         mPremiumCurrencyText.text = Std.string(param1);
      }
      
      function statPlusReleased(param1:Int) 
      {
         mStatHelpers[param1].statAmount = mStatHelpers[param1].amount + 1;
         updateUIClient();
      }
      
      function resetReleased() 
      {
         var popup:UIRetrainPopup;
         if(mGMOffer != null)
         {
            popup = new UIRetrainPopup(mDBFacade,function()
            {
               StoreServicesController.tryBuyOffer(mDBFacade,mGMOffer,function(param1:ASAny)
               {
                  var _loc2_= 0;
                  _loc2_ = 0;
                  while(_loc2_ < 4)
                  {
                     mStatHelpers[_loc2_].statAmount = (0 : UInt);
                     _loc2_++;
                  }
                  if(mDBFacade.steamAchievementsManager != null)
                  {
                     mDBFacade.steamAchievementsManager.addToStatInt("RETRAIN_STAT",1);
                     mDBFacade.steamAchievementsManager.setAchievement("RETRAIN_CHARACTER");
                  }
                  updateUIClient();
               });
            },(Std.int(mGMOffer.Price) : UInt));
            MemoryTracker.track(popup,"UIRetrainPopup - created in UIHeroTraining.resetReleased()");
         }
      }
      
      public function processChosenAvatar() 
      {
         if(mHeroWithEquipPicker.currentlySelectedHero == null)
         {
            return;
         }
         if(mPendingDBWrite)
         {
            writeStatsToDatabase();
         }
         var _loc1_= mHeroWithEquipPicker.currentlySelectedHero.Id;
         if(mDBFacade.dbAccountInfo.activeAvatarInfo.gmHero.Id != _loc1_)
         {
            mDBFacade.dbAccountInfo.changeActiveAvatarRPC(_loc1_);
         }
      }
      
      function setupMenuNavigation() 
      {
         mTownHeader.closeButton.isAbove(mStatLevelPlusButtons[0]);
         mStatLevelPlusButtons[0].isAbove(mStatLevelPlusButtons[1]);
         mStatLevelPlusButtons[1].isAbove(mStatLevelPlusButtons[2]);
         mStatLevelPlusButtons[2].isAbove(mStatLevelPlusButtons[3]);
         mStatLevelPlusButtons[3].isAbove(mResetButton);
         mResetButton.downNavigation = mHeroWithEquipPicker.getFirstHeroSlotUIObject();
         mHeroWithEquipPicker.setupHeroWithEquipPickerMenuNavigation(mResetButton);
      }
      
      function resetMenuNavigation() 
      {
         mStatLevelPlusButtons[0].clearNavigationAndInteractions();
         mStatLevelPlusButtons[1].clearNavigationAndInteractions();
         mStatLevelPlusButtons[2].clearNavigationAndInteractions();
         mStatLevelPlusButtons[3].clearNavigationAndInteractions();
         mStatLevelPlusButtons[0].setFocused(false);
         mStatLevelPlusButtons[1].setFocused(false);
         mStatLevelPlusButtons[2].setFocused(false);
         mStatLevelPlusButtons[3].setFocused(false);
         mResetButton.clearNavigationAndInteractions();
         mHeroWithEquipPicker.resetHeroWithEquipPickerMenuNavigation();
      }
      
      function setButtonNavigationFilters() 
      {
         mStatLevelPlusButtons[0].navigationSelectedInteraction = function()
         {
            DBGlobal.highlightButton(mStatLevelPlusButtons[0]);
         };
         mStatLevelPlusButtons[1].navigationSelectedInteraction = function()
         {
            DBGlobal.highlightButton(mStatLevelPlusButtons[1]);
         };
         mStatLevelPlusButtons[2].navigationSelectedInteraction = function()
         {
            DBGlobal.highlightButton(mStatLevelPlusButtons[2]);
         };
         mStatLevelPlusButtons[3].navigationSelectedInteraction = function()
         {
            DBGlobal.highlightButton(mStatLevelPlusButtons[3]);
         };
         mStatLevelPlusButtons[0].navigationSetToUnselectedInteraction = function()
         {
            DBGlobal.unHighlightButton(mStatLevelPlusButtons[0]);
         };
         mStatLevelPlusButtons[1].navigationSetToUnselectedInteraction = function()
         {
            DBGlobal.unHighlightButton(mStatLevelPlusButtons[1]);
         };
         mStatLevelPlusButtons[2].navigationSetToUnselectedInteraction = function()
         {
            DBGlobal.unHighlightButton(mStatLevelPlusButtons[2]);
         };
         mStatLevelPlusButtons[3].navigationSetToUnselectedInteraction = function()
         {
            DBGlobal.unHighlightButton(mStatLevelPlusButtons[3]);
         };
      }
   }


