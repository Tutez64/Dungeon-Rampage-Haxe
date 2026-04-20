package uI.equipPicker
;
   import account.AvatarInfo;
   import account.InventoryBaseInfo;
   import account.ItemInfo;
   import brain.event.EventComponent;
   import brain.logger.Logger;
   import brain.uI.UIButton;
   import brain.uI.UIObject;
   import brain.uI.UIPopup;
   import facade.DBFacade;
   import facade.Locale;
   import gameMasterDictionary.GMHero;
   import gameMasterDictionary.GMWeaponItem;
   import uI.inventory.UIInventoryItem;
   import flash.display.MovieClip;
   
    class HeroWithEquipPicker extends UIObject
   {
      
      var mDBFacade:DBFacade;
      
      var mEventComponent:EventComponent;
      
      var mHeroSlots:Vector<HeroElement>;
      
      var mEquipElements:Vector<AvatarEquipElement>;
      
      var mEquipSlots:Vector<EquipSlot>;
      
      var mShiftLeft:UIButton;
      
      var mShiftRight:UIButton;
      
      var mHeroSelectedCallback:ASFunction;
      
      var mClickedEquippedWeaponCallback:ASFunction;
      
      var mSetSelectedHeroCallback:ASFunction;
      
      var mGetSelectedHeroCallback:ASFunction;
      
      var mCurrentStartIndex:UInt = (0 : UInt);
      
      var mTotalGMHeroes:UInt = 0;
      
      var mEquipResponseCallback:ASFunction;
      
      var mAllowSelectingUnownedHeroes:Bool = true;
      
      var mSelectedHeroIndex:Int = -1;
      
      public function new(param1:DBFacade, param2:MovieClip, param3:Dynamic, param4:Dynamic, param5:ASFunction, param6:ASFunction = null, param7:ASFunction = null, param8:ASFunction = null, param9:ASFunction = null, param10:Bool = false, param11:Bool = true)
      {
         var dbFacade= param1;
         var root= param2;
         var weaponTooltipClass= param3;
         var heroTooltipClass= param4;
         var heroSelectedCallback= param5;
         var clickedEquippedWeaponCallback= param6;
         var getSelectedHeroIndexCallback= param7;
         var setSelectedHeroIndexCallback= param8;
         var equipResponseFinishedCallback= param9;
         var allowEquipmentSwapping= param10;
         var allowSelectingUnownedHeroes= param11;
         super(dbFacade,root);
         mDBFacade = dbFacade;
         mAllowSelectingUnownedHeroes = allowSelectingUnownedHeroes;
         mEventComponent = new EventComponent(mDBFacade);
         mHeroSelectedCallback = heroSelectedCallback;
         mClickedEquippedWeaponCallback = clickedEquippedWeaponCallback;
         mEquipResponseCallback = equipResponseFinishedCallback;
         mSetSelectedHeroCallback = setSelectedHeroIndexCallback;
         mGetSelectedHeroCallback = getSelectedHeroIndexCallback;
         ASCompat.setProperty((mRoot : ASAny).label, "text", Locale.getString("WEAPON_PICKER_LABEL"));
         mEquipElements = new Vector<AvatarEquipElement>();
         mEquipElements.push(new AvatarEquipElement(mDBFacade,"J",ASCompat.dynamicAs((mRoot : ASAny).UI_weapons.equip_slot_0, flash.display.MovieClip),weaponTooltipClass,unequipItem,handleItemDrop,(0 : UInt),equippedWeaponClicked,equipResponseFinishedCallback,allowEquipmentSwapping));
         mEquipElements.push(new AvatarEquipElement(mDBFacade,"K",ASCompat.dynamicAs((mRoot : ASAny).UI_weapons.equip_slot_1, flash.display.MovieClip),weaponTooltipClass,unequipItem,handleItemDrop,(1 : UInt),equippedWeaponClicked,equipResponseFinishedCallback,allowEquipmentSwapping));
         mEquipElements.push(new AvatarEquipElement(mDBFacade,"L",ASCompat.dynamicAs((mRoot : ASAny).UI_weapons.equip_slot_2, flash.display.MovieClip),weaponTooltipClass,unequipItem,handleItemDrop,(2 : UInt),equippedWeaponClicked,equipResponseFinishedCallback,allowEquipmentSwapping));
         mEquipSlots = new Vector<EquipSlot>();
         mEquipSlots.push(new EquipSlot(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).empty_z, flash.display.MovieClip),this.handleItemDrop,(0 : UInt)));
         mEquipSlots.push(new EquipSlot(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).empty_x, flash.display.MovieClip),this.handleItemDrop,(1 : UInt)));
         mEquipSlots.push(new EquipSlot(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).empty_c, flash.display.MovieClip),this.handleItemDrop,(2 : UInt)));
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
      
      function equippedWeaponClicked(param1:AvatarEquipElement) 
      {
         deselectEquipment();
         if(mClickedEquippedWeaponCallback != null && param1.itemInfo != null)
         {
            param1.select();
            mClickedEquippedWeaponCallback(param1.itemInfo);
         }
      }
      
      public function showWeaponComparison(param1:GMWeaponItem, param2:UInt) 
      {
         var _loc3_:HeroElement;
         final __ax4_iter_159 = mHeroSlots;
         if (checkNullIteratee(__ax4_iter_159)) for (_tmp_ in __ax4_iter_159)
         {
            _loc3_ = _tmp_;
            _loc3_.showWeaponComparison(param1,param2);
         }
      }
      
      public function hideWeaponComparison() 
      {
         var _loc1_:HeroElement;
         final __ax4_iter_160 = mHeroSlots;
         if (checkNullIteratee(__ax4_iter_160)) for (_tmp_ in __ax4_iter_160)
         {
            _loc1_ = _tmp_;
            _loc1_.hideWeaponComparison();
         }
      }
      
      public function show() 
      {
         mRoot.visible = true;
      }
      
      public function hide() 
      {
         mRoot.visible = false;
      }
      
      @:isVar public var currentlySelectedHero(get,never):GMHero;
public function  get_currentlySelectedHero() : GMHero
      {
         return ASCompat.dynamicAs(selectedHeroIndex != -1 ? mHeroSlots[selectedHeroIndex].gmHero : null, gameMasterDictionary.GMHero);
      }
      
      @:isVar public var currentlySelectedAvatarInfo(get,never):AvatarInfo;
public function  get_currentlySelectedAvatarInfo() : AvatarInfo
      {
         var _loc1_= this.currentlySelectedHero;
         return ASCompat.dynamicAs(_loc1_ != null ? mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(_loc1_.Id) : null, account.AvatarInfo);
      }
      
      override public function destroy() 
      {
         mEventComponent.destroy();
         mDBFacade = null;
         mShiftLeft.destroy();
         mShiftRight.destroy();
         mHeroSelectedCallback = null;
         super.destroy();
      }
      
      function setActiveAvatarAsCurrentSelection() 
      {
         var _loc2_:Array<ASAny> = null;
         var _loc1_= mDBFacade.dbAccountInfo.activeAvatarInfo;
         if(_loc1_ == null)
         {
            Logger.warn("No active avatar set on account id: " + mDBFacade.accountId);
            if(mDBFacade.dbAccountInfo.inventoryInfo.avatars == null)
            {
               Logger.error("setActiveAvatarAsCurrentSelection() - mDBFacade.dbAccountInfo.inventoryInfo.avatars == null on account id: " + mDBFacade.accountId);
            }
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
      
      public function setAvatarAlert(param1:Bool) 
      {
         var _loc2_:AvatarInfo = null;
         var _loc3_= 0;
         _loc3_ = 0;
         while(_loc3_ < mHeroSlots.length)
         {
            if(param1)
            {
               if(mHeroSlots[_loc3_].gmHero != null)
               {
                  _loc2_ = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mHeroSlots[_loc3_].gmHero.Id) ;
                  if(_loc2_ != null && _loc2_.skillPointsAvailable > 0)
                  {
                     mHeroSlots[_loc3_].alert = param1;
                  }
                  else
                  {
                     mHeroSlots[_loc3_].alert = false;
                  }
               }
            }
            else
            {
               mHeroSlots[_loc3_].alert = param1;
            }
            _loc3_ = ASCompat.toInt(_loc3_) + 1;
         }
      }
      
      public function disableAvatarAlertOnSelectedHero() 
      {
         if(selectedHeroIndex > -1)
         {
            mHeroSlots[selectedHeroIndex].alert = false;
         }
      }
      
      public function refresh(param1:Bool = false) 
      {
         if(selectedHeroIndex == -1 || param1)
         {
            setActiveAvatarAsCurrentSelection();
         }
         hideWeaponComparison();
         setCurrentIndexToShowSelectedHero();
         populateHeroSlots();
         setEquipWeaponSlots();
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
      
      function setCurrentIndexToShowSelectedHero() 
      {
         if(selectedHeroIndex < mHeroSlots.length)
         {
            mCurrentStartIndex = (0 : UInt);
            return;
         }
         mCurrentStartIndex = (selectedHeroIndex - (mHeroSlots.length - 1) : UInt);
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
      
      function heroClicked(param1:HeroElement, param2:Bool) 
      {
         if(!mAllowSelectingUnownedHeroes && !param2)
         {
            return;
         }
         var _loc3_= mHeroSlots.indexOf(param1) + mCurrentStartIndex;
         if((selectedHeroIndex : UInt) == _loc3_)
         {
            return;
         }
         selectedHeroIndex = (_loc3_ : Int);
         determineSelectedElement();
         setEquipWeaponSlots();
         if(mHeroSelectedCallback != null)
         {
            mHeroSelectedCallback(param1.gmHero,param2);
         }
      }
      
      public function setEquipWeaponSlots() 
      {
         var _loc4_= 0;
         var _loc1_= 0;
         if(selectedHeroIndex >= mDBFacade.gameMaster.Heroes.length)
         {
            return;
         }
         var _loc2_= mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mDBFacade.gameMaster.Heroes[selectedHeroIndex].Id);
         if(_loc2_ == null)
         {
            return;
         }
         _loc4_ = 0;
         while(_loc4_ < mEquipElements.length)
         {
            mEquipElements[_loc4_].clear();
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
         }
         var _loc3_= mDBFacade.dbAccountInfo.inventoryInfo.getEquipedItemsOnAvatar(_loc2_.id);
         if(_loc3_.length > 3)
         {
            Logger.warn("Avatar has more than three equipped items.  Equipping first three.");
         }
         _loc4_ = 0;
         while(_loc4_ < mEquipElements.length)
         {
            if(_loc4_ >= _loc3_.length)
            {
               break;
            }
            _loc1_ = _loc3_[_loc4_].avatarSlot;
            if(_loc1_ >= mEquipElements.length)
            {
               Logger.warn("Item instance id: " + _loc3_[_loc4_].databaseId + " is equipped to an invalid slot: " + _loc3_[_loc4_].avatarSlot);
            }
            else if(_loc3_.length > _loc4_)
            {
               if(mEquipElements[_loc1_].itemInfo != null)
               {
                  Logger.warn("Equipped items contains multiple items assigned to the same slot. First itemId: " + mEquipElements[_loc1_].itemInfo.gmId + ". Second itemId: " + _loc3_[_loc4_].gmId + ".  Slot: " + _loc3_[_loc4_].avatarSlot);
               }
               else
               {
                  mEquipElements[_loc1_].itemInfo = _loc3_[_loc4_];
               }
            }
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
         }
      }
      
      public function equipItemOnCurrentAvatar(param1:InventoryBaseInfo, param2:UInt, param3:ASFunction = null, param4:ASFunction = null) 
      {
         var equipServiceResponse:ASFunction;
         var equippingModal:UIPopup = null;
         var avatarId:UInt;
         var info= param1;
         var itemSlot= param2;
         var responseFinishedCallback= param3;
         var errorCallback= param4;
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
            equippingModal = UIPopup.show(mDBFacade,Locale.getString("EQUIPPING_MODAL"));
            avatarId = avatarInfo.id;
            mDBFacade.dbAccountInfo.inventoryInfo.equipItemOnAvatar(avatarId,info.databaseId,itemSlot,equipServiceResponse,errorCallback);
         }
      }
      
      public function unequipItem(param1:InventoryBaseInfo, param2:ASFunction = null, param3:ASFunction = null) 
      {
         var info= param1;
         var responseFinishedCallback= param2;
         var errorCallback= param3;
         var equippingModal= UIPopup.show(mDBFacade,Locale.getString("EQUIPPING_MODAL"));
         var equipServiceResponse:ASFunction = function()
         {
            equippingModal.destroy();
            if(responseFinishedCallback != null)
            {
               responseFinishedCallback();
            }
         };
         mDBFacade.dbAccountInfo.inventoryInfo.unequipItemOffAvatar(info,equipServiceResponse,errorCallback);
      }
      
      public function highlightItem(param1:InventoryBaseInfo) : Bool
      {
         var _loc2_:AvatarEquipElement = null;
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
      
      public function handleItemDrop(param1:UIObject, param2:InventoryBaseInfo, param3:UInt) : Bool
      {
         var equipElement:AvatarEquipElement;
         var dropObject= param1;
         var itemInfo= param2;
         var equipSlot= param3;
         var uiInvItem= ASCompat.reinterpretAs(dropObject , UIInventoryItem);
         if(uiInvItem != null && uiInvItem.info != null && Std.isOfType(uiInvItem.info , ItemInfo))
         {
            this.equipItemOnCurrentAvatar(cast(uiInvItem.info, ItemInfo),equipSlot,mEquipResponseCallback);
            uiInvItem.dragSwapItem(itemInfo);
            return true;
         }
         equipElement = ASCompat.reinterpretAs(dropObject , AvatarEquipElement);
         if(equipElement != null && equipElement.itemInfo != null)
         {
            equipElement.reset();
            if(equipElement.equipSlot == equipSlot)
            {
               return true;
            }
            this.equipItemOnCurrentAvatar(equipElement.itemInfo,equipSlot,function()
            {
               if(itemInfo != null)
               {
                  equipItemOnCurrentAvatar(itemInfo,equipElement.equipSlot,mEquipResponseCallback);
               }
               else
               {
                  mEquipResponseCallback();
               }
            },mEquipResponseCallback);
            return true;
         }
         return false;
      }
      
      public function getFirstHeroSlotUIObject() : UIObject
      {
         return mHeroSlots[0];
      }
      
      public function setupHeroWithEquipPickerMenuNavigation(param1:ASAny) 
      {
         mHeroSlots[0].isToTheLeftOf(mHeroSlots[1]);
         mHeroSlots[1].isToTheLeftOf(mHeroSlots[2]);
         mHeroSlots[2].isToTheLeftOf(mHeroSlots[3]);
         mHeroSlots[3].isToTheLeftOf(mHeroSlots[4]);
         mHeroSlots[4].isToTheLeftOf(mHeroSlots[5]);
         mHeroSlots[5].isToTheLeftOf(mHeroSlots[6]);
         mHeroSlots[6].isToTheLeftOf(mHeroSlots[7]);
         mHeroSlots[0].upNavigation = ASCompat.dynamicAs(param1, brain.uI.UIObject);
         mHeroSlots[1].upNavigation = ASCompat.dynamicAs(param1, brain.uI.UIObject);
         mHeroSlots[2].upNavigation = ASCompat.dynamicAs(param1, brain.uI.UIObject);
         mHeroSlots[3].upNavigation = ASCompat.dynamicAs(param1, brain.uI.UIObject);
         mHeroSlots[4].upNavigation = ASCompat.dynamicAs(param1, brain.uI.UIObject);
         mHeroSlots[5].upNavigation = ASCompat.dynamicAs(param1, brain.uI.UIObject);
         mHeroSlots[6].upNavigation = ASCompat.dynamicAs(param1, brain.uI.UIObject);
         mHeroSlots[7].upNavigation = ASCompat.dynamicAs(param1, brain.uI.UIObject);
         mEquipElements[0].isToTheLeftOf(mEquipElements[1]);
         mEquipElements[1].isToTheLeftOf(mEquipElements[2]);
         mEquipElements[2].isToTheLeftOf(mHeroSlots[0]);
      }
      
      public function resetHeroWithEquipPickerMenuNavigation() 
      {
         mHeroSlots[0].clearNavigationAndInteractions();
         mHeroSlots[1].clearNavigationAndInteractions();
         mHeroSlots[2].clearNavigationAndInteractions();
         mHeroSlots[3].clearNavigationAndInteractions();
         mHeroSlots[4].clearNavigationAndInteractions();
         mHeroSlots[5].clearNavigationAndInteractions();
         mHeroSlots[6].clearNavigationAndInteractions();
         mHeroSlots[7].clearNavigationAndInteractions();
         mEquipElements[0].clearNavigationAndInteractions();
         mEquipElements[1].clearNavigationAndInteractions();
         mEquipElements[2].clearNavigationAndInteractions();
      }
   }


