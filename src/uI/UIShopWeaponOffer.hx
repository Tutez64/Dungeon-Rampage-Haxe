package uI
;
   import account.AvatarInfo;
   import brain.uI.UIObject;
   import facade.DBFacade;
   import facade.Locale;
   import gameMasterDictionary.GMHero;
   import gameMasterDictionary.GMOffer;
   import gameMasterDictionary.GMOfferDetail;
   import gameMasterDictionary.GMRarity;
   import gameMasterDictionary.GMWeaponItem;
   import uI.inventory.UITapHoldTooltip;
   import uI.inventory.UIWeaponDescTooltip;
   import uI.modifiers.UIModifier;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
    class UIShopWeaponOffer extends UIShopOffer
   {
      
      public static inline final WEAPON_CARD_ROLL_OVER_SCALE:Float = 1.845;
      
      var mTapIcon:UIObject;
      
      var mTapTooltip:UITapHoldTooltip;
      
      var mHoldIcon:UIObject;
      
      var mHoldTooltip:UITapHoldTooltip;
      
      var mPower:MovieClip;
      
      var mPowerLabel:TextField;
      
      var mGMOfferDetail:GMOfferDetail;
      
      var mGMWeaponItem:GMWeaponItem;
      
      var mRollOverCallback:ASFunction;
      
      var mRollOutCallback:ASFunction;
      
      var mWeaponDescTooltip:UIWeaponDescTooltip;
      
      var mUIModifierList:Vector<UIModifier>;
      
      var mRibbonA:MovieClip;
      
      var mRibbonB:MovieClip;
      
      public function new(param1:DBFacade, param2:Dynamic, param3:Dynamic, param4:Dynamic, param5:ASFunction = null)
      {
         super(param1,param2,param5);
         mRibbonA = ASCompat.dynamicAs((mRoot : ASAny).ribbon_A, flash.display.MovieClip);
         mRibbonB = ASCompat.dynamicAs((mRoot : ASAny).ribbon_B, flash.display.MovieClip);
         mRibbonA.visible = false;
         mRibbonB.visible = false;
         mPower = ASCompat.dynamicAs((mRoot : ASAny).power, flash.display.MovieClip);
         if(mPower != null)
         {
            mPowerLabel = ASCompat.dynamicAs((mPower : ASAny).label, flash.text.TextField);
         }
         mTapIcon = new UIObject(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).tap_icon, flash.display.MovieClip));
         mTapTooltip = new UITapHoldTooltip(mDBFacade,param4);
         mTapIcon.tooltip = mTapTooltip;
         mTapTooltip.visible = false;
         mHoldIcon = new UIObject(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).hit_icon, flash.display.MovieClip));
         mHoldTooltip = new UITapHoldTooltip(mDBFacade,param4);
         mHoldIcon.tooltip = mHoldTooltip;
         mHoldTooltip.visible = false;
         mWeaponDescTooltip = new UIWeaponDescTooltip(mDBFacade,param3);
         mIconParent.tooltip = mWeaponDescTooltip;
         mWeaponDescTooltip.visible = false;
         ASCompat.setProperty((mRoot : ASAny).label_tap, "text", Locale.getString("TAP"));
         ASCompat.setProperty((mRoot : ASAny).label_charge, "text", Locale.getString("HOLD"));
         ASCompat.setProperty((mRoot : ASAny).label_modifier, "text", Locale.getString("MODIFIERS"));
         mUIModifierList = new Vector<UIModifier>();
      }
      
      override public function destroy() 
      {
         var _loc1_:UIModifier;
         var __ax4_iter_117:Vector<UIModifier>;
         mTapTooltip.destroy();
         mTapIcon.destroy();
         mTapIcon = null;
         mHoldTooltip.destroy();
         mHoldIcon.destroy();
         mHoldIcon = null;
         mRollOverCallback = null;
         mRollOutCallback = null;
         mWeaponDescTooltip.destroy();
         if(mUIModifierList != null)
         {
            __ax4_iter_117 = mUIModifierList;
            if (checkNullIteratee(__ax4_iter_117)) for (_tmp_ in __ax4_iter_117)
            {
               _loc1_ = _tmp_;
               _loc1_.destroy();
            }
         }
         mUIModifierList = null;
         super.destroy();
      }
      
      override function  get_nativeIconSize() : Float
      {
         return 100;
      }
      
      public function setRolloverCallbacks(param1:ASFunction, param2:ASFunction) 
      {
         mRollOverCallback = param1;
         mRollOutCallback = param2;
      }
      
      override function onRollOver(param1:MouseEvent) 
      {
         super.onRollOver(param1);
         if(mRollOverCallback != null)
         {
            mRollOverCallback(mGMWeaponItem,mGMOfferDetail.WeaponPower);
         }
         mRoot.scaleX = mRoot.scaleY = 1.845;
      }
      
      override function onRollOut(param1:MouseEvent) 
      {
         super.onRollOut(param1);
         if(mRollOutCallback != null)
         {
            mRollOutCallback(mGMWeaponItem,mGMOfferDetail.WeaponPower);
         }
      }
      
      override function shouldGreyOffer(param1:GMHero) : Bool
      {
         return false;
      }
      
      override public function showOffer(param1:GMOffer, param2:GMHero) 
      {
         var stagePos:Point;
         var weaponName:String;
         var swfPath:String;
         var iconName:String;
         var swfPath1:String;
         var iconName1:String;
         var preNameModifiers:String;
         var i:Int;
         var avatarInfo:AvatarInfo;
         var format:TextFormat;
         var sizeMult:Float;
         var rarity:GMRarity;
         var gmOffer= param1;
         var gmHero= param2;
         this.offer = gmOffer;
         mGMOfferDetail = this.offer.Details[0];
         mGMWeaponItem = ASCompat.dynamicAs(mDBFacade.gameMaster.weaponItemById.itemFor(mGMOfferDetail.WeaponId), gameMasterDictionary.GMWeaponItem);
         super.showOffer(gmOffer,gmHero);
         weaponName = "";
         weaponName = gmOffer.getDisplayName(mDBFacade.gameMaster);
         mWeaponDescTooltip.setWeaponItem(mGMWeaponItem,mGMOfferDetail.Level);
         if(mGMOfferDetail.Rarity == "LEGENDARY")
         {
            mWeaponDescTooltip.setWeaponItem(mGMWeaponItem,mGMOfferDetail.Level,true);
         }
         mWeaponDescTooltip.visible = true;
         stagePos = new Point();
         stagePos.y = mPower.height * 1.93;
         mIconParent.tooltipPos = stagePos;
         if(ASCompat.stringAsBool(mGMWeaponItem.TapIcon) && mGMWeaponItem.TapIcon != "")
         {
            mTapIcon.visible = true;
            swfPath = "Resources/Art2D/Icons/weapon_ability/db_icons_weapon_ability.swf";
            iconName = mGMWeaponItem.TapIcon;
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
                     mTapIcon.root.addChild(_loc2_);
                     mTapTooltip.setValues(mGMWeaponItem.TapTitle,mGMWeaponItem.TapDescription);
                     mTapTooltip.visible = true;
                     stagePos = new Point();
                     stagePos.y += mTapIcon.root.height * 0.5;
                     mTapIcon.tooltipPos = stagePos;
                  }
               });
            }
         }
         if(ASCompat.stringAsBool(mGMWeaponItem.HoldIcon) && mGMWeaponItem.HoldIcon != "")
         {
            mHoldIcon.visible = true;
            swfPath1 = "Resources/Art2D/Icons/weapon_ability/db_icons_weapon_ability.swf";
            iconName1 = mGMWeaponItem.HoldIcon;
            if(ASCompat.stringAsBool(swfPath1) && ASCompat.stringAsBool(iconName1))
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath1),function(param1:brain.assetRepository.SwfAsset)
               {
                  var _loc2_:MovieClip = null;
                  var _loc4_:String = null;
                  var _loc3_= param1.getClass(iconName1);
                  if(_loc3_ != null)
                  {
                     _loc2_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
                     _loc2_.scaleX = _loc2_.scaleY = 0.5;
                     mHoldIcon.root.addChild(_loc2_);
                     _loc4_ = mGMWeaponItem.WeaponController != null ? Locale.getString(mGMWeaponItem.WeaponController) : mGMWeaponItem.HoldTitle;
                     mHoldTooltip.setValues(_loc4_,mGMWeaponItem.HoldDescription);
                     mHoldTooltip.visible = true;
                     stagePos = new Point();
                     stagePos.y += mHoldIcon.root.height * 0.5;
                     mHoldIcon.tooltipPos = stagePos;
                  }
               });
            }
         }
         mPower.visible = true;
         mPowerLabel.text = Std.string(mGMOfferDetail.WeaponPower);
         if(mGMOfferDetail.Modifier1 != null)
         {
            mUIModifierList.push(new UIModifier(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).modifier_icon_1, flash.display.MovieClip),mGMOfferDetail.Modifier1));
         }
         if(mGMOfferDetail.Modifier2 != null)
         {
            mUIModifierList.push(new UIModifier(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).modifier_icon_2, flash.display.MovieClip),mGMOfferDetail.Modifier2));
         }
         if(mGMOfferDetail.Modifier3 != null)
         {
            mUIModifierList.push(new UIModifier(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).modifier_icon_3, flash.display.MovieClip),mGMOfferDetail.Modifier3,(0 : UInt),true));
         }
         preNameModifiers = "";
         i = 0;
         while(i < mUIModifierList.length)
         {
            if(mGMOfferDetail.Rarity == "LEGENDARY")
            {
               break;
            }
            preNameModifiers += mUIModifierList[i].gmModifier.Name.toUpperCase() + " ";
            i = i + 1;
         }
         weaponName = preNameModifiers + mTitle.text;
         if(mGMOfferDetail.Rarity == "LEGENDARY")
         {
            weaponName = mTitle.text;
         }
         if(this.offer.EndDate != null || this.offer.StartDate != null)
         {
            if(this.offer.LimitedQuantity > 0)
            {
               mRibbonA.visible = false;
               mRibbonB.visible = true;
               ASCompat.setProperty((mRibbonB : ASAny).timer, "text", getDateString());
               ASCompat.setProperty((mRibbonB : ASAny).limit_label, "text", getQuantityString());
            }
            else
            {
               mRibbonA.visible = true;
               mRibbonB.visible = false;
               ASCompat.setProperty((mRibbonA : ASAny).timer, "text", getDateString());
            }
         }
         avatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(gmHero.Id);
         if(avatarInfo == null || avatarInfo.level < mGMOfferDetail.Level)
         {
            mLevelStarLabel.textColor = mRequiresLabel.textColor = (15535124 : UInt);
         }
         format = new TextFormat();
         sizeMult = 0.1;
         if(weaponName.length <= 32)
         {
            format.size = 13;
            sizeMult = weaponName.length < 16 ? 0.2 : 0.1;
            mTitle.y = mTitleY + mTitle.height * sizeMult;
         }
         else
         {
            format.size = 11;
            mTitle.y = mTitleY;
         }
         if(mGMOfferDetail.Rarity == "LEGENDARY")
         {
            weaponName = gmOffer.getDisplayName(mDBFacade.gameMaster,"LEGENDARY",true);
         }
         mTitle.defaultTextFormat = format;
         mTitle.text = weaponName;
         rarity = ASCompat.dynamicAs(mDBFacade.gameMaster.rarityByConstant.itemFor(mGMOfferDetail.Rarity), gameMasterDictionary.GMRarity);
         if(rarity != null && rarity.TextColor != 0)
         {
            mTitle.textColor = rarity.TextColor;
         }
      }
      
      override function  get_offerDescription() : String
      {
         return mGMWeaponItem != null ? mGMWeaponItem.getWeaponAesthetic(mGMOfferDetail.Level).Description : "";
      }
      
      override function  get_offerIconName() : String
      {
         if(mGMOfferDetail.Rarity == "LEGENDARY")
         {
            return mGMWeaponItem != null ? mGMWeaponItem.getWeaponAesthetic(mGMOfferDetail.Level,true).IconName : "";
         }
         return mGMWeaponItem != null ? mGMWeaponItem.getWeaponAesthetic(mGMOfferDetail.Level).IconName : "";
      }
      
      override function  get_offerSwfPath() : String
      {
         return mGMWeaponItem != null ? mGMWeaponItem.getWeaponAesthetic(mGMOfferDetail.Level).IconSwf : "";
      }
      
      override function hasRequirements() : Bool
      {
         if(mGMOfferDetail != null)
         {
            if(mGMOfferDetail.Level > 0)
            {
               mRequiresLabel.appendText(Std.string(mGMOfferDetail.Level));
               return true;
            }
         }
         return false;
      }
      
      override function requirementsMetForPurchase() : Bool
      {
         return true;
      }
   }


