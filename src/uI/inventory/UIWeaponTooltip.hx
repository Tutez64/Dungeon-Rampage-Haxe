package uI.inventory
;
   import account.ItemInfo;
   import brain.assetRepository.AssetLoadingComponent;
   import combat.weapon.WeaponGameObject;
   import facade.DBFacade;
   import facade.GameMasterLocale;
   import facade.Locale;
   import gameMasterDictionary.GMModifier;
   import gameMasterDictionary.GMRarity;
   import gameMasterDictionary.GMWeaponAesthetic;
   import uI.modifiers.UIModifier;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
    class UIWeaponTooltip extends MovieClip
   {
      
      public static inline final TAP_HOLD_ICONS_SWF= "Resources/Art2D/Icons/weapon_ability/db_icons_weapon_ability.swf";
      
      var mDBFacade:DBFacade;
      
      var mRoot:MovieClip;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mNameLabel:TextField;
      
      var mPowerLabel:TextField;
      
      var mLevelLabel:TextField;
      
      var mTapIcon:MovieClip;
      
      var mHoldIcon:MovieClip;
      
      var mModifiersList:Vector<UIModifier>;
      
      public function new(param1:DBFacade, param2:Dynamic)
      {
         super();
         mDBFacade = param1;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mRoot = ASCompat.dynamicAs(ASCompat.createInstance(param2, []), flash.display.MovieClip);
         this.addChild(mRoot);
         mNameLabel = ASCompat.dynamicAs((mRoot : ASAny).title_label, flash.text.TextField);
         mPowerLabel = ASCompat.dynamicAs((mRoot : ASAny).power.label, flash.text.TextField);
         ASCompat.setProperty((mRoot : ASAny).power.attack_label, "text", Locale.getString("POWER"));
         mTapIcon = ASCompat.dynamicAs((mRoot : ASAny).tap_icon, flash.display.MovieClip);
         mHoldIcon = ASCompat.dynamicAs((mRoot : ASAny).icon, flash.display.MovieClip);
         mLevelLabel = ASCompat.dynamicAs((mRoot : ASAny).level_label, flash.text.TextField);
         mModifiersList = new Vector<UIModifier>();
      }
      
      public function destroy() 
      {
         mAssetLoadingComponent.destroy();
         mDBFacade = null;
         this.removeChild(mRoot);
         mRoot = null;
      }
      
      public function setWeaponItemFromWeaponGameObject(param1:WeaponGameObject) 
      {
         var _loc3_= 0;
         clearAllIcons();
         mNameLabel.text = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME",param1.weaponAesthetic.Constant).toUpperCase();
         var _loc6_= ASCompat.dynamicAs(mDBFacade.gameMaster.rarityById.itemFor(param1.rarity), gameMasterDictionary.GMRarity);
         var _loc4_= (ASCompat.toInt(_loc6_ != null && _loc6_.TextColor != 0 ? _loc6_.TextColor : 15463921) : UInt);
         mNameLabel.textColor = _loc4_;
         mPowerLabel.text = Std.string(param1.power);
         mLevelLabel.text = Locale.getString("ITEM_CARD_LEVEL_REQUIREMENT") + param1.requiredLevel;
         loadIcon(param1.weaponData.TapIcon,mTapIcon);
         loadIcon(param1.weaponData.HoldIcon,mHoldIcon);
         var _loc2_= "";
         var _loc5_= param1.modifierList;
         _loc3_ = 0;
         while(_loc3_ < _loc5_.length)
         {
            mModifiersList.push(new UIModifier(mDBFacade,ASCompat.reinterpretAs(mRoot.getChildByName("modifier_icon_" + Std.string((_loc3_ + 1))) , MovieClip),_loc5_[_loc3_].Constant));
            _loc2_ += GameMasterLocale.getGameMasterSubString("MODIFIER_NAME",_loc5_[_loc3_].Constant).toUpperCase() + " ";
            _loc3_++;
         }
         mNameLabel.text = _loc2_ + mNameLabel.text;
         if(param1.legendaryModifier != null)
         {
            mModifiersList.push(new UIModifier(mDBFacade,ASCompat.reinterpretAs(mRoot.getChildByName("modifier_icon_3") , MovieClip),"",(0 : UInt),true,param1.legendaryModifier.Id));
            mNameLabel.text = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME",param1.weaponData.getWeaponAesthetic((0 : UInt),true).Constant);
         }
         mNameLabel.text = mNameLabel.text.toUpperCase();
      }
      
      public function setWeaponItemFromItemInfo(param1:ItemInfo) 
      {
         var _loc3_= 0;
         clearAllIcons();
         mNameLabel.text = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME",param1.gmWeaponAesthetic.Constant).toUpperCase();
         mNameLabel.textColor = param1.getTextColor();
         mPowerLabel.text = Std.string(param1.power);
         mLevelLabel.text = Locale.getString("ITEM_CARD_LEVEL_REQUIREMENT") + param1.requiredLevel;
         loadIcon(param1.gmWeaponItem.TapIcon,mTapIcon);
         loadIcon(param1.gmWeaponItem.HoldIcon,mHoldIcon);
         var _loc2_= "";
         var _loc4_= param1.modifiers;
         _loc3_ = 0;
         while(_loc3_ < _loc4_.length)
         {
            mModifiersList.push(new UIModifier(mDBFacade,ASCompat.reinterpretAs(mRoot.getChildByName("modifier_icon_" + Std.string((_loc3_ + 1))) , MovieClip),_loc4_[_loc3_].Constant));
            _loc2_ += GameMasterLocale.getGameMasterSubString("MODIFIER_NAME",_loc4_[_loc3_].Constant).toUpperCase() + " ";
            _loc3_++;
         }
         mNameLabel.text = _loc2_ + mNameLabel.text;
         if(param1.legendaryModifier != 0)
         {
            mModifiersList.push(new UIModifier(mDBFacade,ASCompat.reinterpretAs(mRoot.getChildByName("modifier_icon_3") , MovieClip),"",(0 : UInt),true,param1.legendaryModifier));
            mNameLabel.text = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME",param1.gmWeaponItem.getWeaponAesthetic((0 : UInt),true).Constant);
         }
         mNameLabel.text = mNameLabel.text.toUpperCase();
      }
      
      public function setWeaponItemFromData(param1:String, param2:UInt, param3:String, param4:String, param5:UInt, param6:UInt, param7:UInt, param8:UInt, param9:UInt, param10:GMWeaponAesthetic = null) 
      {
         var _loc11_= 0;
         clearAllIcons();
         mNameLabel.text = param1.toUpperCase();
         if(param10 != null)
         {
            mNameLabel.text = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME",param10.Constant).toUpperCase();
         }
         var _loc15_= ASCompat.dynamicAs(mDBFacade.gameMaster.rarityById.itemFor(param8), gameMasterDictionary.GMRarity);
         var _loc12_= (ASCompat.toInt(_loc15_ != null && _loc15_.TextColor != 0 ? _loc15_.TextColor : 15463921) : UInt);
         mNameLabel.textColor = _loc12_;
         mPowerLabel.text = Std.string(param2);
         mLevelLabel.text = Locale.getString("ITEM_CARD_LEVEL_REQUIREMENT") + param9;
         loadIcon(param3,mTapIcon);
         loadIcon(param4,mHoldIcon);
         var _loc14_= "";
         var _loc13_= new Vector<GMModifier>();
         if(param5 > 0)
         {
            _loc13_.push(ASCompat.dynamicAs(mDBFacade.gameMaster.modifiersById.itemFor(param5), gameMasterDictionary.GMModifier));
         }
         if(param6 > 0)
         {
            _loc13_.push(ASCompat.dynamicAs(mDBFacade.gameMaster.modifiersById.itemFor(param6), gameMasterDictionary.GMModifier));
         }
         _loc11_ = 0;
         while(_loc11_ < _loc13_.length)
         {
            mModifiersList.push(new UIModifier(mDBFacade,ASCompat.reinterpretAs(mRoot.getChildByName("modifier_icon_" + Std.string((_loc11_ + 1))) , MovieClip),_loc13_[_loc11_].Constant));
            _loc14_ += GameMasterLocale.getGameMasterSubString("MODIFIER_NAME",_loc13_[_loc11_].Constant).toUpperCase() + " ";
            _loc11_++;
         }
         if(param7 != 0)
         {
            mModifiersList.push(new UIModifier(mDBFacade,ASCompat.reinterpretAs(mRoot.getChildByName("modifier_icon_3") , MovieClip),"",(0 : UInt),true,param7));
         }
         else
         {
            mNameLabel.text = _loc14_ + mNameLabel.text;
         }
         mNameLabel.text = mNameLabel.text.toUpperCase();
      }
      
      function clearAllIcons() 
      {
         var _loc1_= 0;
         if(mTapIcon.numChildren > 1)
         {
            mTapIcon.removeChildAt(1);
         }
         if(mHoldIcon.numChildren > 1)
         {
            mHoldIcon.removeChildAt(1);
         }
         if(mModifiersList.length > 0)
         {
            _loc1_ = 0;
            while(_loc1_ < mModifiersList.length)
            {
               mModifiersList[_loc1_].destroy();
               _loc1_++;
            }
            mModifiersList.splice(0,(mModifiersList.length : UInt));
         }
      }
      
      function loadIcon(param1:String, param2:MovieClip) 
      {
         var swfPath:String;
         var iconName= param1;
         var parentMC= param2;
         if(iconName == null || iconName == "")
         {
            return;
         }
         swfPath = "Resources/Art2D/Icons/weapon_ability/db_icons_weapon_ability.swf";
         if(ASCompat.stringAsBool(swfPath) && ASCompat.stringAsBool(iconName))
         {
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath),function(param1:brain.assetRepository.SwfAsset)
            {
               var _loc2_:MovieClip = null;
               var _loc3_= param1.getClass(iconName);
               if(_loc3_ != null)
               {
                  _loc2_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
                  _loc2_.scaleX = _loc2_.scaleY = 0.5;
                  parentMC.addChildAt(_loc2_,1);
               }
            });
         }
      }
   }


