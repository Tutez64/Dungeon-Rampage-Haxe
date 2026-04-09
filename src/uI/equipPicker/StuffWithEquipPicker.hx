package uI.equipPicker
;
   import account.AvatarInfo;
   import brain.event.EventComponent;
   import brain.logger.Logger;
   import brain.uI.UIButton;
   import brain.uI.UIObject;
   import facade.DBFacade;
   import facade.Locale;
   import flash.display.MovieClip;
   
    class StuffWithEquipPicker extends UIObject
   {
      
      var mDBFacade:DBFacade;
      
      var mEventComponent:EventComponent;
      
      var mHeroSlots:Vector<HeroElement>;
      
      var mTotalGMHeroes:UInt = 0;
      
      var mShiftLeft:UIButton;
      
      var mShiftRight:UIButton;
      
      var mSetSelectedHeroCallback:ASFunction;
      
      var mGetSelectedHeroCallback:ASFunction;
      
      var mSelectedHeroIndex:Int = -1;
      
      var mCurrentStartIndex:UInt = (0 : UInt);
      
      public function new(param1:DBFacade, param2:MovieClip, param3:Dynamic, param4:ASFunction = null, param5:ASFunction = null)
      {
         var dbFacade= param1;
         var root= param2;
         var heroTooltipClass= param3;
         var getSelectedHeroIndexCallback= param4;
         var setSelectedHeroIndexCallback= param5;
         super(dbFacade,root);
         mDBFacade = dbFacade;
         mEventComponent = new EventComponent(mDBFacade);
         mSetSelectedHeroCallback = setSelectedHeroIndexCallback;
         mGetSelectedHeroCallback = getSelectedHeroIndexCallback;
         mHeroSlots = new Vector<HeroElement>();
         mHeroSlots.push(new HeroElement(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).hero_slot_0, flash.display.MovieClip),heroTooltipClass,function()
         {
         }));
         mHeroSlots.push(new HeroElement(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).hero_slot_1, flash.display.MovieClip),heroTooltipClass,function()
         {
         }));
         mHeroSlots.push(new HeroElement(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).hero_slot_2, flash.display.MovieClip),heroTooltipClass,function()
         {
         }));
         mHeroSlots.push(new HeroElement(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).hero_slot_3, flash.display.MovieClip),heroTooltipClass,function()
         {
         }));
         mHeroSlots.push(new HeroElement(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).hero_slot_4, flash.display.MovieClip),heroTooltipClass,function()
         {
         }));
         mHeroSlots.push(new HeroElement(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).hero_slot_5, flash.display.MovieClip),heroTooltipClass,function()
         {
         }));
         mHeroSlots.push(new HeroElement(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).hero_slot_6, flash.display.MovieClip),heroTooltipClass,function()
         {
         }));
         mHeroSlots.push(new HeroElement(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).hero_slot_7, flash.display.MovieClip),heroTooltipClass,function()
         {
         }));
         mShiftLeft = new UIButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).shift_left, flash.display.MovieClip));
         mShiftLeft.releaseCallback = shiftLeft;
         mShiftRight = new UIButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).shift_right, flash.display.MovieClip));
         mShiftRight.releaseCallback = shiftRight;
         mShiftLeft.visible = false;
         mShiftRight.visible = false;
         mTotalGMHeroes = (mDBFacade.gameMaster.Heroes.length : UInt);
         ASCompat.setProperty((mRoot : ASAny).label, "text", Locale.getString("INVENTORY_STUFF_DESCRIPTION"));
         mEventComponent.addListener("DB_ACCOUNT_INFO_RESPONSE",function(param1:events.DBAccountResponseEvent)
         {
            refresh();
         });
      }
      
      function populateHeroSlots() 
      {
         var _loc2_= 0;
         var _loc3_= mDBFacade.gameMaster.Heroes;
         var _loc1_= mCurrentStartIndex;
         _loc2_ = 0;
         while(_loc2_ < mHeroSlots.length)
         {
            mHeroSlots[_loc2_].clear();
            if(_loc1_ < (_loc3_.length : UInt) && (!_loc3_[(_loc1_ : Int)].Hidden || mDBFacade.dbConfigManager.getConfigBoolean("want_hidden_heroes",false)))
            {
               mHeroSlots[_loc2_].gmHero = _loc3_[(_loc1_ : Int)];
            }
            else
            {
               mHeroSlots[_loc2_].enabled = false;
            }
            _loc1_++;
            _loc2_ = ASCompat.toInt(_loc2_) + 1;
         }
         updateShiftButtons();
      }
      
      function updateShiftButtons() 
      {
         if(mCurrentStartIndex == 0)
         {
            mShiftLeft.enabled = false;
         }
         else
         {
            mShiftLeft.enabled = true;
         }
         var _loc1_= mCurrentStartIndex + mHeroSlots.length;
         if(_loc1_ < mTotalGMHeroes)
         {
            mShiftRight.enabled = true;
         }
         else
         {
            mShiftRight.enabled = false;
         }
      }
      
      function shiftLeft() 
      {
         mCurrentStartIndex = mCurrentStartIndex - 1;
         populateHeroSlots();
      }
      
      function shiftRight() 
      {
         mCurrentStartIndex = mCurrentStartIndex + 1;
         populateHeroSlots();
      }
      
      override public function destroy() 
      {
         mEventComponent.destroy();
         mDBFacade = null;
         super.destroy();
      }
      
      public function show() 
      {
         mRoot.visible = true;
      }
      
      public function hide() 
      {
         mRoot.visible = false;
      }
      
      public function refresh(param1:Bool = false) 
      {
         if(selectedHeroIndex == -1 || param1)
         {
            setActiveAvatarAsCurrentSelection();
         }
         populateHeroSlots();
      }
      
      function setActiveAvatarAsCurrentSelection() 
      {
         var _loc2_:Array<ASAny> = null;
         var _loc1_= mDBFacade.dbAccountInfo.activeAvatarInfo;
         if(_loc1_ == null)
         {
            Logger.warn("No active avatar set on account id: " + mDBFacade.accountId);
            _loc2_ = mDBFacade.dbAccountInfo.inventoryInfo.avatars.keysToArray();
            if(_loc2_ == null)
            {
               Logger.error("No avatars found on account id: " + mDBFacade.accountId);
               return;
            }
            _loc1_ = ASCompat.dynamicAs(mDBFacade.dbAccountInfo.inventoryInfo.avatars.itemFor(_loc2_[0]) , AvatarInfo);
            if(_loc1_ == null)
            {
               Logger.fatal("Could not get avatar info for key: " + Std.string(_loc2_[0]) + " Unable to get active avatar.");
               return;
            }
         }
         selectedHeroIndex = (findHeroIndex(_loc1_.avatarType) : Int);
      }
      
            
      @:isVar var selectedHeroIndex(get,set):Int;
function  get_selectedHeroIndex() : Int
      {
         if(mGetSelectedHeroCallback != null)
         {
            mSelectedHeroIndex = ASCompat.toInt(mGetSelectedHeroCallback());
         }
         return mSelectedHeroIndex;
      }
function  set_selectedHeroIndex(param1:Int) :Int      {
         mSelectedHeroIndex = param1;
         if(mSetSelectedHeroCallback != null)
         {
            mSetSelectedHeroCallback(mSelectedHeroIndex);
         }
return param1;
      }
      
      function heroClicked(param1:HeroElement, param2:Bool) 
      {
         var _loc3_= mHeroSlots.indexOf(param1) + mCurrentStartIndex;
         if((selectedHeroIndex : UInt) == _loc3_)
         {
            return;
         }
         selectedHeroIndex = (_loc3_ : Int);
         determineSelectedElement();
         refresh();
      }
      
      function determineSelectedElement() 
      {
         var _loc1_= 0;
         _loc1_ = 0;
         while(_loc1_ < mHeroSlots.length)
         {
            if(ASCompat.toNumber(_loc1_ + mCurrentStartIndex) == selectedHeroIndex)
            {
               mHeroSlots[_loc1_].select();
            }
            else
            {
               mHeroSlots[_loc1_].deselect();
            }
            _loc1_ = ASCompat.toInt(_loc1_) + 1;
         }
      }
      
      function setCurrentIndexToShowSelectedHero() 
      {
         if(selectedHeroIndex < mHeroSlots.length)
         {
            mCurrentStartIndex = (0 : UInt);
            return;
         }
         mCurrentStartIndex = (selectedHeroIndex - (mHeroSlots.length - 1) : UInt);
      }
      
      function findHeroIndex(param1:UInt) : UInt
      {
         var _loc2_= 0;
         var _loc3_= mDBFacade.gameMaster.Heroes;
         _loc2_ = 0;
         while(_loc2_ < _loc3_.length)
         {
            if(param1 == _loc3_[_loc2_].Id)
            {
               return (_loc2_ : UInt);
            }
            _loc2_ = ASCompat.toInt(_loc2_) + 1;
         }
         Logger.error("Unable to find gmHero for active avatar Id: " + param1);
         return (0 : UInt);
      }
   }


