package uI.equipPicker
;
   import account.AvatarInfo;
   import account.Consumable;
   import account.InventoryBaseInfo;
   import account.StackableInfo;
   import brain.event.EventComponent;
   import brain.logger.Logger;
   import brain.uI.UIButton;
   import brain.uI.UIObject;
   import brain.uI.UIPopup;
   import brain.utils.MemoryTracker;
   import facade.DBFacade;
   import facade.Locale;
   import gameMasterDictionary.GMStackable;
   import uI.DBUIOneButtonPopup;
   import uI.inventory.UIInventoryItem;
   import flash.display.MovieClip;
   
    class StacksWithEquipPicker extends UIObject
   {
      
      var mDBFacade:DBFacade;
      
      var mEventComponent:EventComponent;
      
      var mHeroSlots:Vector<HeroElement>;
      
      var mEquipElements:Vector<ConsumableEquipElement>;
      
      var mEquipSlots:Vector<EquipSlot>;
      
      var mClickedEquippedWeaponCallback:ASFunction;
      
      var mCurrentStartIndex:UInt = (0 : UInt);
      
      var mEquipResponseCallback:ASFunction;
      
      var mSetSelectedHeroCallback:ASFunction;
      
      var mGetSelectedHeroCallback:ASFunction;
      
      var mSelectedHeroIndex:Int = -1;
      
      var mTotalGMHeroes:UInt = 0;
      
      var mShiftLeft:UIButton;
      
      var mShiftRight:UIButton;
      
      public function new(param1:DBFacade, param2:MovieClip, param3:Dynamic, param4:Dynamic, param5:ASFunction = null, param6:ASFunction = null, param7:Bool = false, param8:ASFunction = null, param9:ASFunction = null)
      {
         var dbFacade= param1;
         var root= param2;
         var weaponTooltipClass= param3;
         var heroTooltipClass= param4;
         var clickedEquippedWeaponCallback= param5;
         var equipResponseFinishedCallback= param6;
         var allowEquipmentSwapping= param7;
         var getSelectedHeroIndexCallback= param8;
         var setSelectedHeroIndexCallback= param9;
         super(dbFacade,root);
         mSetSelectedHeroCallback = setSelectedHeroIndexCallback;
         mGetSelectedHeroCallback = getSelectedHeroIndexCallback;
         ASCompat.setProperty((mRoot : ASAny).label, "text", Locale.getString("STACK_PICKER_LABEL"));
         mDBFacade = dbFacade;
         mEventComponent = new EventComponent(mDBFacade);
         mClickedEquippedWeaponCallback = clickedEquippedWeaponCallback;
         mEquipResponseCallback = equipResponseFinishedCallback;
         mEquipElements = new Vector<ConsumableEquipElement>();
         mEquipElements.push(new ConsumableEquipElement(mDBFacade,"1",ASCompat.dynamicAs((mRoot : ASAny).UI_potion.equip_slot_0, flash.display.MovieClip),weaponTooltipClass,unequipPotion,handleItemDrop,(0 : UInt),equippedPotionClicked,equipResponseFinishedCallback,allowEquipmentSwapping));
         mEquipElements.push(new ConsumableEquipElement(mDBFacade,"2",ASCompat.dynamicAs((mRoot : ASAny).UI_potion.equip_slot_1, flash.display.MovieClip),weaponTooltipClass,unequipPotion,handleItemDrop,(1 : UInt),equippedPotionClicked,equipResponseFinishedCallback,allowEquipmentSwapping));
         mEquipSlots = new Vector<EquipSlot>();
         mEquipSlots.push(new EquipSlot(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).empty_z, flash.display.MovieClip),this.handleItemDrop,(0 : UInt)));
         mEquipSlots.push(new EquipSlot(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).empty_x, flash.display.MovieClip),this.handleItemDrop,(1 : UInt)));
         mHeroSlots = new Vector<HeroElement>();
         mHeroSlots.push(new HeroElement(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).hero_slot_0, flash.display.MovieClip),heroTooltipClass,heroClicked));
         mHeroSlots.push(new HeroElement(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).hero_slot_1, flash.display.MovieClip),heroTooltipClass,heroClicked));
         mHeroSlots.push(new HeroElement(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).hero_slot_2, flash.display.MovieClip),heroTooltipClass,heroClicked));
         mHeroSlots.push(new HeroElement(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).hero_slot_3, flash.display.MovieClip),heroTooltipClass,heroClicked));
         mHeroSlots.push(new HeroElement(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).hero_slot_4, flash.display.MovieClip),heroTooltipClass,heroClicked));
         mHeroSlots.push(new HeroElement(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).hero_slot_5, flash.display.MovieClip),heroTooltipClass,heroClicked));
         mHeroSlots.push(new HeroElement(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).hero_slot_6, flash.display.MovieClip),heroTooltipClass,heroClicked));
         mHeroSlots.push(new HeroElement(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).hero_slot_7, flash.display.MovieClip),heroTooltipClass,heroClicked));
         mShiftLeft = new UIButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).shift_left, flash.display.MovieClip));
         mShiftLeft.releaseCallback = shiftLeft;
         mShiftRight = new UIButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).shift_right, flash.display.MovieClip));
         mShiftRight.releaseCallback = shiftRight;
         mShiftLeft.visible = false;
         mShiftRight.visible = false;
         mTotalGMHeroes = (mDBFacade.gameMaster.Heroes.length : UInt);
         mEventComponent.addListener("DB_ACCOUNT_INFO_RESPONSE",function(param1:events.DBAccountResponseEvent)
         {
            refresh();
         });
      }
      
      public function unequipPotion(param1:StackableInfo, param2:UInt, param3:ASFunction = null, param4:ASFunction = null) 
      {
         var equippingModal:UIPopup;
         var equipServiceResponse:ASFunction;
         var info= param1;
         var itemSlot= param2;
         var responseFinishedCallback= param3;
         var errorCallback= param4;
         var avatarInfo= mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mHeroSlots[selectedHeroIndex].gmHero.Id);
         if(avatarInfo != null)
         {
            equippingModal = UIPopup.show(mDBFacade,Locale.getString("EQUIPPING_MODAL"));
            equipServiceResponse = function()
            {
               equippingModal.destroy();
               if(responseFinishedCallback != null)
               {
                  responseFinishedCallback();
               }
            };
            mDBFacade.dbAccountInfo.inventoryInfo.unequipConsumableOffAvatar(avatarInfo.id,info.gmStackable.Id,itemSlot,equipServiceResponse,errorCallback);
         }
      }
      
      public function equipPotionOnCurrentAvatar(param1:StackableInfo, param2:UInt, param3:Bool = false, param4:ASFunction = null, param5:ASFunction = null) : Bool
      {
         var equipServiceResponse:ASFunction;
         var equippingModal:UIPopup = null;
         var avatarId:UInt;
         var popup:DBUIOneButtonPopup;
         var info= param1;
         var itemSlot= param2;
         var swapping= param3;
         var responseFinishedCallback= param4;
         var errorCallback= param5;
         var avatarInfo= mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mHeroSlots[selectedHeroIndex].gmHero.Id);
         if(avatarInfo != null)
         {
            equipServiceResponse = function()
            {
               equippingModal.destroy();
               if(responseFinishedCallback != null)
               {
                  responseFinishedCallback();
               }
            };
            if(swapping || mDBFacade.dbAccountInfo.inventoryInfo.canEquipThisConsumable(avatarInfo,itemSlot,info.gmId))
            {
               equippingModal = UIPopup.show(mDBFacade,Locale.getString("EQUIPPING_MODAL"));
               avatarId = avatarInfo.id;
               mDBFacade.dbAccountInfo.inventoryInfo.equipConsumableOnAvatar(avatarId,info.gmStackable.Id,itemSlot,swapping,equipServiceResponse,errorCallback);
               return true;
            }
            popup = new DBUIOneButtonPopup(mDBFacade,Locale.getString("STACK_NOT_ALLOWED_TITLE"),Locale.getString("STACK_NOT_ALLOWED_MESSAGE"),Locale.getString("CANCEL"),null);
            MemoryTracker.track(popup,"DBUIOneButtonPopup - created in StacksWithEquipPicker.tryEquip()");
         }
         return false;
      }
      
      function equippedPotionClicked(param1:ConsumableEquipElement) 
      {
         deselectEquipment();
         if(mClickedEquippedWeaponCallback != null && param1.itemInfo != null)
         {
            param1.select();
            mClickedEquippedWeaponCallback(param1.itemInfo);
         }
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
         determineSelectedElement();
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
      
      public function refresh(param1:Bool = false) 
      {
         if(selectedHeroIndex == -1 || param1)
         {
            setActiveAvatarAsCurrentSelection();
         }
         populateHeroSlots();
         setEquipSlots();
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
      
      function setEquipSlots() 
      {
         var _loc5_= 0;
         var _loc3_:GMStackable = null;
         var _loc1_:Vector<Consumable> = /*undefined*/null;
         var _loc2_= 0;
         if(mHeroSlots[selectedHeroIndex].gmHero == null)
         {
            return;
         }
         _loc5_ = 0;
         while(_loc5_ < mEquipElements.length)
         {
            mEquipElements[_loc5_].clear();
            _loc5_ = ASCompat.toInt(_loc5_) + 1;
         }
         var _loc4_= mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mHeroSlots[selectedHeroIndex].gmHero.Id);
         if(_loc4_ != null)
         {
            _loc1_ = _loc4_.equippedConsumables;
            _loc5_ = 0;
            while(_loc5_ < mEquipElements.length)
            {
               if(_loc5_ >= ASCompat.toNumberField(_loc1_, "length"))
               {
                  break;
               }
               if(ASCompat.toNumberField(_loc1_[_loc5_], "stackId") != 0)
               {
                  _loc2_ = ASCompat.toInt(_loc1_[_loc5_].stackSlot);
                  _loc3_ = ASCompat.dynamicAs(mDBFacade.gameMaster.stackableById.itemFor(_loc1_[_loc5_].stackId), gameMasterDictionary.GMStackable);
                  if(_loc2_ >= mEquipElements.length || _loc2_ < 0)
                  {
                     Logger.warn("Stackable id: " + _loc3_.Id + " is equipped to an invalid slot: " + Std.string(_loc1_[_loc5_].stackSlot));
                  }
                  else
                  {
                     mEquipElements[_loc2_].init(_loc3_,(ASCompat.toInt(_loc1_[_loc5_].stackSlot) : UInt),(ASCompat.toInt(_loc1_[_loc5_].stackCount) : UInt));
                  }
               }
               _loc5_ = ASCompat.toInt(_loc5_) + 1;
            }
         }
      }
      
      public function highlightItem(param1:InventoryBaseInfo) : Bool
      {
         var _loc2_:ConsumableEquipElement = null;
         var _loc3_= 0;
         _loc3_ = 0;
         while(_loc3_ < mEquipElements.length)
         {
            _loc2_ = mEquipElements[_loc3_];
            if(param1 != null && _loc2_.itemInfo == param1)
            {
               mEquipElements[_loc3_].select();
            }
            else
            {
               mEquipElements[_loc3_].deselect();
            }
            _loc3_ = ASCompat.toInt(_loc3_) + 1;
         }
         return true;
      }
      
      public function deselectEquipment() 
      {
         var _loc1_= 0;
         _loc1_ = 0;
         while(_loc1_ < mEquipElements.length)
         {
            mEquipElements[_loc1_].deselect();
            _loc1_ = ASCompat.toInt(_loc1_) + 1;
         }
      }
      
      public function handleItemDrop(param1:UIObject, param2:StackableInfo, param3:UInt) : Bool
      {
         var equipElement:ConsumableEquipElement;
         var dropObject= param1;
         var stackInfo= param2;
         var equipSlot= param3;
         var uiInvItem= ASCompat.reinterpretAs(dropObject , UIInventoryItem);
         if(uiInvItem != null && uiInvItem.info != null && ASCompat.reinterpretAs(uiInvItem.info , StackableInfo) != null)
         {
            if(uiInvItem.info.gmId == 60001 || uiInvItem.info.gmId == 60018)
            {
               return false;
            }
            if(!this.equipPotionOnCurrentAvatar(cast(uiInvItem.info, StackableInfo),equipSlot,false,mEquipResponseCallback))
            {
               return false;
            }
            uiInvItem.dragSwapItem(stackInfo);
            return true;
         }
         equipElement = ASCompat.reinterpretAs(dropObject , ConsumableEquipElement);
         if(equipElement != null && equipElement.itemInfo != null)
         {
            equipElement.reset();
            if(equipElement.equipSlot == equipSlot)
            {
               return true;
            }
            this.equipPotionOnCurrentAvatar(equipElement.stackableInfo,equipSlot,true,function()
            {
            },mEquipResponseCallback);
            return true;
         }
         return false;
      }
   }


