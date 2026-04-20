package uI.infiniteIsland
;
   import account.FriendInfo;
   import brain.assetRepository.SwfAsset;
   import brain.render.MovieClipRenderController;
   import brain.uI.UIButton;
   import brain.uI.UIObject;
   import brain.uI.UIScrollPane;
   import brain.uI.UISlider;
   import brain.jsonRPC.JSONRPCService;
   import facade.DBFacade;
   import facade.GameMasterLocale;
   import facade.Locale;
   import gameMasterDictionary.GMChest;
   import gameMasterDictionary.GMDoober;
   import gameMasterDictionary.GMDungeonModifier;
   import gameMasterDictionary.GMInfiniteDungeon;
   import uI.map.UIMapBattlePopup;
   import flash.display.MovieClip;
   import org.as3commons.collections.Map;
   
    class II_UIMapBattlePopup extends UIMapBattlePopup
   {
      
      static inline final SWF_PATH= "Resources/Art2D/UI/db_UI_screens.swf";
      
      static inline final II_POPUP_CLASS_NAME= "battle_popup_infinite_island";
      
      static inline final SWF_ITEM_PATH= "Resources/Art2D/Icons/Items/db_icons_items.swf";
      
      static inline final TOTAL_TOP_LEADERBOARD_SLOTS= (20 : UInt);
      
      var mFloorModifierLabels:Vector<UIObject>;
      
      var mScrollPane:UIScrollPane;
      
      var mSlider:UISlider;
      
      var mSliderUpButton:UIButton;
      
      var mSliderDownButton:UIButton;
      
      var mChampionsboardFriendSlots:Vector<II_UIChampionsboardSlot>;
      
      var mChampionsboardTopSlots:Vector<II_UIChampionsboardSlot>;
      
      var mFriends:Vector<FriendInfo>;
      
      var mTopScoresBtn:UIButton;
      
      var mIsChampionsBoardFriends:Bool = false;
      
      var mTopTwentyScores:Map;
      
      var mItemAsset:SwfAsset;
      
      var mReadyForChests:Bool = false;
      
      var mRewardSlots:Vector<MovieClip>;
      
      var mRewardChests:Vector<MovieClip>;
      
      public function new(param1:DBFacade, param2:ASFunction, param3:ASFunction, param4:ASFunction, param5:ASFunction, param6:String)
      {
         super(param1,param2,param3,param4,param5,param6);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Items/db_icons_items.swf"),itemsLoaded);
         mTopTwentyScores = new Map();
      }
      
      override function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_screens.swf";
      }
      
      override function getClassName() : String
      {
         return "battle_popup_infinite_island";
      }
      
      override function setupUI(param1:SwfAsset, param2:String, param3:ASAny, param4:Bool, param5:ASFunction) 
      {
         var i:Int;
         var friends:Map;
         var friendsKeyArray:Array<ASAny>;
         var key:UInt;
         var swfAsset= param1;
         var titleText= param2;
         var content:ASAny = param3;
         var allowClose= param4;
         var closeCallback= param5;
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
         ASCompat.setProperty((mPopup : ASAny).label_killSwitch, "text", Locale.getString("KILL_SWITCH"));
         ASCompat.setProperty((mPopup : ASAny).label_weeklyTopScores, "text", Locale.getString("II_WEEKLY_FRIENDS_SCORES"));
         mFloorModifierLabels = new Vector<UIObject>();
         i = 0;
         while(i < 4)
         {
            mFloorModifierLabels.push(new UIObject(mDBFacade,ASCompat.reinterpretAs(mPopup.getChildByName("floor_modifier_" + Std.string((i + 1))) , MovieClip)));
            i = i + 1;
         }
         mScrollPane = new UIScrollPane(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).leaderboard_scroll_panel, flash.display.MovieClip));
         mSlider = new UISlider(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).slider, flash.display.MovieClip),(1 : UInt));
         mSlider.minimum = 500;
         mSlider.maximum = 0;
         mSlider.value = 0;
         mSlider.updateCallback = mScrollPane.scrollToY;
         mSliderUpButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).uparrow, flash.display.MovieClip));
         mSliderUpButton.releaseCallback = function()
         {
            mSlider.valueWithCallback = mSlider.value - 20;
         };
         mSliderDownButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).downarrow, flash.display.MovieClip));
         mSliderDownButton.releaseCallback = function()
         {
            mSlider.valueWithCallback = mSlider.value + 20;
         };
         mScrollPane.addMouseWheelFunctionality(mSlider,20,mPopup);
         mTopScoresBtn = new UIButton(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).button_topScores, flash.display.MovieClip));
         mTopScoresBtn.visible = false;
         mTopScoresBtn.enabled = false;
         mTopScoresBtn.releaseCallback = switchChampionsBoardType;
         friends = mDBFacade.dbAccountInfo.friendInfos;
         friendsKeyArray = friends.keysToArray();
         mChampionsboardFriendSlots = new Vector<II_UIChampionsboardSlot>();
         mFriends = new Vector<FriendInfo>();
         i = 0;
         if (checkNullIteratee(friendsKeyArray)) for (_tmp_ in friendsKeyArray)
         {
            key  = (ASCompat.toInt(_tmp_) : UInt);
            mFriends.push(ASCompat.dynamicAs(friends.itemFor(key), account.FriendInfo));
            mChampionsboardFriendSlots.push(new II_UIChampionsboardSlot(mDBFacade,i++));
         }
         mChampionsboardTopSlots = new Vector<II_UIChampionsboardSlot>();
         i = 0;
         while(i < 20)
         {
            mChampionsboardTopSlots.push(new II_UIChampionsboardSlot(mDBFacade,i));
            i = i + 1;
         }
         mScrollPane.scrollByY(mSlider.value);
      }
      
      override public function setDungeonDetails() 
      {
         var _loc3_= 0;
         var _loc4_:GMDungeonModifier = null;
         var _loc1_:ASFunction = null;
         super.setDungeonDetails();
         if(mCurrentDungeon == null || mPopup == null)
         {
            return;
         }
         var _loc2_= mDBFacade.getInfiniteDungeonDetailForNodeId(mCurrentDungeon.Id);
         var _loc5_= ASCompat.dynamicAs(mDBFacade.gameMaster.infiniteDungeonsByConstant.itemFor(mCurrentDungeon.InfiniteDungeon), gameMasterDictionary.GMInfiniteDungeon);
         _loc3_ = 0;
         while(_loc3_ < _loc2_.modifiers.length)
         {
            ASCompat.setProperty((mFloorModifierLabels[_loc3_].root : ASAny).label_floor_modifier, "text", Locale.getString("BATTLE_POP_UP_II_FLOOR:") + Std.string(_loc5_.DModFloorStart[_loc3_]));
            _loc3_++;
         }
         _loc3_ = 0;
         while(_loc3_ < _loc2_.modifiers.length)
         {
            _loc4_ = ASCompat.dynamicAs(mDBFacade.gameMaster.dungeonModifierById.itemFor(_loc2_.modifiers[_loc3_]), gameMasterDictionary.GMDungeonModifier);
            if(_loc4_ != null)
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(_loc4_.IconFilepath),lateLoadForModifier((_loc3_ : UInt),_loc4_));
            }
            _loc3_++;
         }
         mIsChampionsBoardFriends = true;
         switchChampionsBoardType();
         mScrollPane.scrollByY(mSlider.value);
         if(!ASCompat.toBool(mTopTwentyScores.itemFor(mCurrentDungeon.Id)))
         {
            _loc1_ = JSONRPCService.getFunction("getTopTwenty",mDBFacade.rpcRoot + "championsboard");
            _loc1_(mDBFacade.dbAccountInfo.id,mCurrentDungeon.Id,mDBFacade.validationToken,onReceivedTopScores);
         }
         mReadyForChests = true;
         if(mItemAsset != null)
         {
            populateChests();
         }
      }
      
      function itemsLoaded(param1:SwfAsset) 
      {
         mItemAsset = param1;
         if(mReadyForChests)
         {
            populateChests();
         }
      }
      
      function populateChests() 
      {
         var _loc7_= 0;
         var _loc1_= 0;
         var _loc3_:GMDoober = null;
         var _loc9_:GMChest = null;
         var _loc10_:Dynamic = null;
         var _loc4_:MovieClip = null;
         var _loc8_:MovieClipRenderController = null;
         if(mCurrentDungeon == null || mPopup == null)
         {
            return;
         }
         mRewardChests = new Vector<MovieClip>();
         mRewardSlots = new Vector<MovieClip>();
         mRewardSlots.push(ASCompat.dynamicAs((mPopup : ASAny).loot_01, flash.display.MovieClip));
         mRewardSlots.push(ASCompat.dynamicAs((mPopup : ASAny).loot_02, flash.display.MovieClip));
         mRewardSlots.push(ASCompat.dynamicAs((mPopup : ASAny).loot_03, flash.display.MovieClip));
         mRewardSlots.push(ASCompat.dynamicAs((mPopup : ASAny).loot_04, flash.display.MovieClip));
         var _loc11_= ASCompat.dynamicAs(mDBFacade.gameMaster.infiniteDungeonsByConstant.itemFor(mCurrentDungeon.InfiniteDungeon), gameMasterDictionary.GMInfiniteDungeon);
         var _loc2_= mDBFacade.dbAccountInfo.localFriendInfo.getIIAvatarScoreForNode((mDBFacade.dbAccountInfo.activeAvatarId : Int),(mCurrentDungeon.Id : Int));
         _loc7_ = 0;
         while(_loc7_ < 4)
         {
            while(mRewardSlots[_loc7_].numChildren > 1)
            {
               mRewardSlots[_loc7_].removeChildAt(1);
            }
            ASCompat.setProperty((mRewardSlots[_loc7_] : ASAny).loot, "visible", true);
            _loc7_++;
         }
         var _loc5_= 0;
         var _loc6_:UInt;
         final __ax4_iter_34 = _loc11_.RewardFloors;
         if (checkNullIteratee(__ax4_iter_34)) for (_tmp_ in __ax4_iter_34)
         {
            _loc6_ = _tmp_;
            _loc1_ = 0;
            if((_loc2_ : UInt) > _loc6_)
            {
               _loc1_ = ASCompat.toInt(_loc11_.FloorRewardsMap.itemFor(_loc6_));
            }
            if(_loc1_ != 0)
            {
               _loc3_ = ASCompat.dynamicAs(mDBFacade.gameMaster.dooberById.itemFor(_loc1_), gameMasterDictionary.GMDoober);
               _loc9_ = ASCompat.dynamicAs(mDBFacade.gameMaster.chestsById.itemFor(_loc3_.ChestId), gameMasterDictionary.GMChest);
               _loc10_ = mItemAsset.getClass(_loc9_.IconName);
               _loc4_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc10_, []), flash.display.MovieClip);
               _loc8_ = new MovieClipRenderController(mDBFacade,_loc4_);
               _loc8_.loop = false;
               _loc8_.stop();
               if(_loc1_ == 30104)
               {
                  _loc4_.scaleY = 0.6;
                  _loc4_.scaleX = 0.6;
                  _loc4_.y += 6;
                  _loc4_.x -= 0;
               }
               else
               {
                  _loc4_.scaleY = 0.82;
                  _loc4_.scaleX = 0.82;
                  _loc4_.y += 6;
                  _loc4_.x -= 0;
               }
               mRewardSlots[_loc5_].addChild(_loc4_);
               ASCompat.setProperty((mRewardSlots[_loc5_] : ASAny).loot, "visible", false);
               mRewardChests.push(_loc4_);
               _loc5_++;
            }
         }
      }
      
      function onReceivedTopScores(param1:ASAny) 
      {
         if(param1 == false)
         {
            return;
         }
         mTopTwentyScores.add(mCurrentDungeon.Id,new II_ChampionsboardListPerNode(param1));
      }
      
      function switchChampionsBoardType() 
      {
         var _loc1_:II_ChampionsboardListPerNode = null;
         var _loc2_:II_ChampionsboardTopScore = null;
         mSlider.valueWithCallback = 0;
         var _loc3_= 0;
         if(mIsChampionsBoardFriends)
         {
            _loc3_ = 0;
            while(_loc3_ < mChampionsboardTopSlots.length)
            {
               if(mScrollPane.root.contains(mChampionsboardTopSlots[_loc3_].root))
               {
                  mScrollPane.root.removeChild(mChampionsboardTopSlots[_loc3_].root);
               }
               _loc3_++;
            }
            ASCompat.ASVector.sort(mFriends, sortFriends);
            _loc3_ = 0;
            while(_loc3_ < mChampionsboardFriendSlots.length)
            {
               mChampionsboardFriendSlots[_loc3_].setDungeonDetails((mCurrentDungeon.Id : Int),mFriends[_loc3_],mFriends[_loc3_].id == mDBFacade.dbAccountInfo.id);
               mScrollPane.root.addChild(mChampionsboardFriendSlots[_loc3_].root);
               if(mFriends[_loc3_].id == mDBFacade.dbAccountInfo.id)
               {
                  mSlider.valueWithCallback = _loc3_ * 15.3;
               }
               _loc3_++;
            }
         }
         else
         {
            _loc3_ = 0;
            while(_loc3_ < mChampionsboardFriendSlots.length)
            {
               if(mScrollPane.root.contains(mChampionsboardFriendSlots[_loc3_].root))
               {
                  mScrollPane.root.removeChild(mChampionsboardFriendSlots[_loc3_].root);
               }
               _loc3_++;
            }
            if(mTopTwentyScores.hasKey(mCurrentDungeon.Id))
            {
               _loc1_ = ASCompat.dynamicAs(mTopTwentyScores.itemFor(mCurrentDungeon.Id), uI.infiniteIsland.II_ChampionsboardListPerNode);
               _loc1_.sort();
               _loc3_ = 0;
               while(_loc3_ < _loc1_.getTotalScores())
               {
                  _loc2_ = _loc1_.getTopScoreForNum(_loc3_);
                  mChampionsboardTopSlots[_loc3_].setDungeonDetailsForTopTwenty(_loc2_.name,_loc2_.score,_loc2_.skinId,_loc2_.weaponsJson);
                  mScrollPane.root.addChild(mChampionsboardTopSlots[_loc3_].root);
                  _loc3_++;
               }
            }
         }
         ASCompat.setProperty((mPopup : ASAny).label_weeklyTopScores, "text", Locale.getString("II_WEEKLY_FRIENDS_SCORES"));
         mTopScoresBtn.label.text = Locale.getString("II_FRIENDS_SCORES");
      }
      
      function sortFriends(param1:FriendInfo, param2:FriendInfo) : Int
      {
         return param2.getIILeaderboardScoreForNode((mCurrentDungeon.Id : Int)) - param1.getIILeaderboardScoreForNode((mCurrentDungeon.Id : Int));
      }
      
      function lateLoadForModifier(param1:UInt, param2:GMDungeonModifier) : ASFunction
      {
         var index= param1;
         var gmDungeonModifer= param2;
         return function(param1:SwfAsset)
         {
            var _loc2_:MovieClip = null;
            var __tmpAssignObj0:ASAny = (mFloorModifierLabels[(index : Int)].root : ASAny).label_floor_modifier;
            ASCompat.setProperty(__tmpAssignObj0, "text", Std.string(__tmpAssignObj0.text) + "\n" + GameMasterLocale.getGameMasterSubString("DUNGEON_MODIFIER_NAME",gmDungeonModifer.Constant));
            var _loc3_= param1.getClass(gmDungeonModifer.IconName);
            if(_loc3_ != null)
            {
               _loc2_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []) , MovieClip);
               _loc2_.scaleX = _loc2_.scaleY = 0.5;
               while(ASCompat.toNumberField((mFloorModifierLabels[(index : Int)].root : ASAny).floor_modifier_icon, "numChildren") > 0)
               {
                  (mFloorModifierLabels[(index : Int)].root : ASAny).floor_modifier_icon.removeChildAt(0);
               }
               (mFloorModifierLabels[(index : Int)].root : ASAny).floor_modifier_icon.addChild(_loc2_);
            }
            ASCompat.setProperty((mFloorModifierLabels[(index : Int)].tooltip : ASAny).title_label, "text", GameMasterLocale.getGameMasterSubString("DUNGEON_MODIFIER_NAME",gmDungeonModifer.Constant));
            ASCompat.setProperty((mFloorModifierLabels[(index : Int)].tooltip : ASAny).description_label, "text", GameMasterLocale.getGameMasterSubString("DUNGEON_MODIFIER_DESCRIPTION",gmDungeonModifer.Constant));
         };
      }
      
      override public function destroy() 
      {
         var __ax4_iter_35:Vector<II_UIChampionsboardSlot>;
         var _loc1_:II_UIChampionsboardSlot = null;
         mScrollPane.destroy();
         mSlider.destroy();
         mSliderUpButton.destroy();
         mSliderDownButton.destroy();
         mScrollPane = null;
         mSlider = null;
         mSliderUpButton = null;
         mSliderDownButton = null;
         if(mChampionsboardFriendSlots != null)
         {
            __ax4_iter_35 = mChampionsboardFriendSlots;
            if (checkNullIteratee(__ax4_iter_35)) for (_tmp_ in __ax4_iter_35)
            {
               _loc1_  = _tmp_;
               _loc1_.destroy();
            }
            mChampionsboardFriendSlots = null;
         }
         mFloorModifierLabels = null;
         super.destroy();
      }
   }


