package uI.infiniteIsland
;
   import brain.assetRepository.SwfAsset;
   import brain.render.MovieClipRenderController;
   import facade.DBFacade;
   import facade.Locale;
   import gameMasterDictionary.GMChest;
   import gameMasterDictionary.GMDoober;
   import generatedCode.InfiniteRewardData;
   import uI.DBUIPopup;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.TimerEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.text.TextField;
   import flash.utils.Timer;
   
    class II_UIRewardReportPopup extends DBUIPopup
   {
      
      static inline final SWF_SCREEN_PATH= "Resources/Art2D/UI/db_UI_screens.swf";
      
      static inline final REPORT_POPUP_CLASS_NAME= "infinite_bonusRewards_popup";
      
      static inline final NEWREWARD_POPUP_CLASS_NAME= "nextfloor_infinite_popup";
      
      static inline final SWF_DOOBER_PATH= "Resources/Art2D/Doobers/db_items_doobers.swf";
      
      static inline final SWF_ITEM_PATH= "Resources/Art2D/Icons/Items/db_icons_items.swf";
      
      var mNewDooberId:Int = 0;
      
      var mFloorGold:Int = 0;
      
      var mTotalGold:Int = 0;
      
      var mRewardData:Vector<InfiniteRewardData>;
      
      var mNextGoldFloor:Int = 0;
      
      var mNextChestFloor:Int = 0;
      
      var mAvStartScore:Int = 0;
      
      var mCurrentFloorNum:Int = 0;
      
      var mRewardChests:Vector<MovieClip>;
      
      var mRewardSlots:Vector<MovieClip>;
      
      var mRewardSlotLabels:Vector<TextField>;
      
      var mDooberAsset:SwfAsset;
      
      var mItemAsset:SwfAsset;
      
      var mTimeRemaining:Float = Math.NaN;
      
      var mCountDownTimer:Timer;
      
      public function new(param1:DBFacade, param2:Vector<InfiniteRewardData>, param3:Int, param4:Int, param5:Int, param6:Int, param7:Float = 3, param8:String = "", param9:ASAny = null, param10:Bool = true, param11:Bool = true, param12:ASFunction = null, param13:Bool = false)
      {
         mFloorGold = param5;
         mTotalGold = param4;
         mCurrentFloorNum = param6;
         mAvStartScore = param3;
         mTimeRemaining = param7;
         if(param5 == 0 && mCurrentFloorNum != 0)
         {
            mNextGoldFloor = param3 + 1;
         }
         mRewardData = param2;
         var _loc14_:InfiniteRewardData;
         final __ax4_iter_31 = mRewardData;
         if (checkNullIteratee(__ax4_iter_31)) for (_tmp_ in __ax4_iter_31)
         {
            _loc14_ = _tmp_;
            if(ASCompat.toNumberField(_loc14_, "status") == 3)
            {
               mNewDooberId = ASCompat.toInt(_loc14_.dooberId);
            }
            if(ASCompat.toNumberField(_loc14_, "status") == 0)
            {
               mNextChestFloor = ASCompat.toInt(_loc14_.floorNumber);
               break;
            }
         }
         super(param1,param8,param9,param10,param11,param12,param13);
         mRewardSlots = new Vector<MovieClip>();
         mRewardSlots.push(ASCompat.dynamicAs((mPopup : ASAny).loot_01, flash.display.MovieClip));
         mRewardSlots.push(ASCompat.dynamicAs((mPopup : ASAny).loot_02, flash.display.MovieClip));
         mRewardSlots.push(ASCompat.dynamicAs((mPopup : ASAny).loot_03, flash.display.MovieClip));
         mRewardSlots.push(ASCompat.dynamicAs((mPopup : ASAny).loot_04, flash.display.MovieClip));
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Doobers/db_items_doobers.swf"),doobersLoaded);
      }
      
      function doobersLoaded(param1:SwfAsset) 
      {
         mDooberAsset = param1;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Items/db_icons_items.swf"),itemsLoaded);
      }
      
      function itemsLoaded(param1:SwfAsset) 
      {
         mItemAsset = param1;
         init();
      }
      
      function init() 
      {
         var __ax4_iter_33:Vector<InfiniteRewardData>;
         var _loc5_:InfiniteRewardData = null;
         var _loc1_= false;
         var _loc11_:GMDoober = null;
         var _loc7_:GMChest = null;
         var _loc13_:Dynamic = null;
         var _loc3_:MovieClip = null;
         var _loc6_:MovieClipRenderController = null;
         var _loc9_:GMDoober = null;
         var _loc2_:Dynamic = null;
         var _loc10_:MovieClip = null;
         var _loc8_:MovieClipRenderController = null;
         var _loc12_= 0;
         mRewardChests = new Vector<MovieClip>();
         var _loc14_= 0;
         _loc14_ = mTotalGold;
         var _loc4_= 0;
         final __ax4_iter_32 = mRewardData;
         if (checkNullIteratee(__ax4_iter_32)) for (_tmp_ in __ax4_iter_32)
         {
            _loc5_  = _tmp_;
            if(_loc4_ < mRewardSlots.length)
            {
               _loc1_ = false;
               if(ASCompat.toNumberField(_loc5_, "status") == 0)
               {
                  continue;
               }
               if(ASCompat.toNumberField(_loc5_, "status") == 1)
               {
                  _loc1_ = true;
               }
               _loc11_ = ASCompat.dynamicAs(mDBFacade.gameMaster.dooberById.itemFor(_loc5_.dooberId), gameMasterDictionary.GMDoober);
               _loc7_ = ASCompat.dynamicAs(mDBFacade.gameMaster.chestsById.itemFor(_loc11_.ChestId), gameMasterDictionary.GMChest);
               _loc13_ = mItemAsset.getClass(_loc7_.IconName);
               _loc3_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc13_, []), flash.display.MovieClip);
               _loc6_ = new MovieClipRenderController(mDBFacade,_loc3_);
               _loc6_.loop = false;
               _loc6_.stop();
               if(_loc4_ == 0)
               {
                  _loc3_.scaleY = 0.55;
                  _loc3_.scaleX = 0.55;
                  _loc3_.y += 0;
                  _loc3_.x -= 0;
               }
               else
               {
                  _loc3_.scaleY = 0.65;
                  _loc3_.scaleX = 0.65;
                  _loc3_.y += 0;
                  _loc3_.x -= 0;
               }
               if(_loc1_)
               {
                  desaturate(_loc3_);
               }
               mRewardSlots[_loc4_].addChild(_loc3_);
               ASCompat.setProperty((mRewardSlots[_loc4_] : ASAny).loot, "visible", false);
               mRewardChests.push(_loc3_);
            }
            _loc4_++;
         }
         ASCompat.setProperty((mPopup : ASAny).label_next_bonus_chest, "text", "");
         if(mFloorGold != 0 || mNewDooberId != 0)
         {
            if(mNewDooberId != 0)
            {
               _loc9_ = ASCompat.dynamicAs(mDBFacade.gameMaster.dooberById.itemFor(mNewDooberId), gameMasterDictionary.GMDoober);
               _loc2_ = mDooberAsset.getClass(_loc9_.AssetClassName);
               _loc10_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
               _loc8_ = new MovieClipRenderController(mDBFacade,_loc10_);
               _loc10_.scaleY = 0.38;
               _loc10_.scaleX = 0.38;
               _loc10_.y += 12;
               _loc8_.play((0 : UInt),true);
               (mPopup : ASAny).loot_00.addChild(_loc10_);
               ASCompat.setProperty((mPopup : ASAny).coin_center, "visible", false);
               ASCompat.setProperty((mPopup : ASAny).label_coin_count_center, "visible", false);
            }
            else
            {
               ASCompat.setProperty((mPopup : ASAny).coin, "visible", false);
               ASCompat.setProperty((mPopup : ASAny).label_coin_count, "visible", false);
               ASCompat.setProperty((mPopup : ASAny).label_next_bonus_chest, "text", Locale.getString("INFINITE_TILL_REWARD") + Std.string(mNextChestFloor));
            }
            ASCompat.setProperty((mPopup : ASAny).loot_00_center, "visible", false);
            ASCompat.setProperty((mPopup : ASAny).loot_00.loot, "visible", false);
            ASCompat.setProperty((mPopup : ASAny).label_coin_count_total, "text", "x" + Std.string(mTotalGold));
            ASCompat.setProperty((mPopup : ASAny).label_coin_count, "text", "x" + Std.string(mFloorGold));
            ASCompat.setProperty((mPopup : ASAny).label_coin_count_center, "text", "x" + Std.string(mFloorGold));
         }
         else
         {
            ASCompat.setProperty((mPopup : ASAny).label, "text", Locale.getString("INFINITE_BEAT"));
            ASCompat.setProperty((mPopup : ASAny).label_loot_01, "text", "");
            ASCompat.setProperty((mPopup : ASAny).label_loot_02, "text", "");
            ASCompat.setProperty((mPopup : ASAny).label_loot_03, "text", "");
            ASCompat.setProperty((mPopup : ASAny).label_loot_04, "text", "");
            mRewardSlotLabels = new Vector<TextField>();
            mRewardSlotLabels.push(ASCompat.dynamicAs((mPopup : ASAny).label_loot_01, flash.text.TextField));
            mRewardSlotLabels.push(ASCompat.dynamicAs((mPopup : ASAny).label_loot_02, flash.text.TextField));
            mRewardSlotLabels.push(ASCompat.dynamicAs((mPopup : ASAny).label_loot_03, flash.text.TextField));
            mRewardSlotLabels.push(ASCompat.dynamicAs((mPopup : ASAny).label_loot_04, flash.text.TextField));
            _loc4_ = 0;
            __ax4_iter_33 = mRewardData;
            if (checkNullIteratee(__ax4_iter_33)) for (_tmp_ in __ax4_iter_33)
            {
               _loc5_  = _tmp_;
               if(ASCompat.toNumberField(_loc5_, "status") == 1 && ASCompat.toNumberField(_loc5_, "floorNumber") == mCurrentFloorNum)
               {
                  mRewardSlotLabels[_loc4_].text = Locale.getString("INFINITE_ALREADY_REWARD");
               }
               _loc4_++;
            }
            ASCompat.setProperty((mPopup : ASAny).label_next_bonus_coins, "text", "");
            if(mNextChestFloor != 0)
            {
               ASCompat.setProperty((mPopup : ASAny).label_next_bonus_chest, "text", Locale.getString("INFINITE_TILL_REWARD") + Std.string(mNextChestFloor));
            }
            _loc12_ = mAvStartScore + 1;
            ASCompat.setProperty((mPopup : ASAny).label_next_bonus_coins, "text", Locale.getString("INFINITE_TILL_GOLD") + Std.string(_loc12_));
            ASCompat.setProperty((mPopup : ASAny).label_coin_count, "text", "x" + Std.string(mFloorGold));
         }
         startCountdown();
      }
      
      function startCountdown() 
      {
         if(mCountDownTimer != null)
         {
            endCountdown();
         }
         mTimeRemaining -= 1;
         ASCompat.setProperty((mPopup : ASAny).countdown_bounce.countdown.countdown_text, "text", "" + Std.int(mTimeRemaining));
         mCountDownTimer = new Timer(1000);
         mCountDownTimer.addEventListener("timer",tickCountdown);
         mCountDownTimer.start();
      }
      
      function endCountdown() 
      {
         if(mCountDownTimer != null)
         {
            mCountDownTimer.removeEventListener("timer",tickCountdown);
            mCountDownTimer.stop();
         }
      }
      
      function tickCountdown(param1:TimerEvent) 
      {
         ASCompat.setProperty((mPopup : ASAny).countdown_bounce.countdown.countdown_text, "text", "" + Std.int(mTimeRemaining));
         if(mTimeRemaining <= 0)
         {
            endCountdown();
            destroy();
         }
         mTimeRemaining -= 1;
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
      
      override function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_screens.swf";
      }
      
      override function getClassName() : String
      {
         if(mFloorGold != 0 || mNewDooberId != 0)
         {
            return "nextfloor_infinite_popup";
         }
         return "infinite_bonusRewards_popup";
      }
      
      override public function destroy() 
      {
         endCountdown();
         super.destroy();
      }
   }


