package uI
;
   import account.AvatarInfo;
   import account.StoreServicesController;
   import brain.assetRepository.SwfAsset;
   import brain.render.MovieClipRenderController;
   import brain.uI.UIObject;
   import facade.DBFacade;
   import facade.Locale;
   import gameMasterDictionary.GMOffer;
   import gameMasterDictionary.GMWeaponAesthetic;
   import gameMasterDictionary.GMWeaponItem;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   
    class UILevelUpShopPopup extends DBUIOneButtonPopup
   {
      
      static inline final SWF_PATH= "Resources/Art2D/UI/db_UI_screens.swf";
      
      static inline final POPUP_CLASS_NAME= "levelup_shop_popup";
      
      var mAvatarInfo:AvatarInfo;
      
      var mGMOffers:Vector<GMOffer>;
      
      public function new(param1:DBFacade, param2:ASFunction, param3:AvatarInfo, param4:Vector<GMOffer>)
      {
         mAvatarInfo = param3;
         mGMOffers = param4;
         super(param1,Locale.getString("LEVELUPSHOP_POPUP_TITLE"),Locale.getString("LEVELUPSHOP_POPUP_MESSAGE"),Locale.getString("LEVELUPSHOP_POPUP_BUTTON"),param2,true,null);
         mDBFacade.metrics.log("LevelUpShopPopupPresented");
      }
      
      public static function getLevelUpWeaponUnlocks(param1:DBFacade, param2:AvatarInfo) : Vector<GMOffer>
      {
         var _loc10_:GMOffer = null;
         var _loc7_:ASAny = null;
         var _loc11_= 0;
         var _loc8_= 0;
         var _loc6_:String = null;
         var _loc9_= 0;
         var _loc4_= new Vector<GMOffer>();
         var _loc3_= param2.level;
         var _loc5_= param1.gameMaster.Offers;
         _loc9_ = 0;
         while(_loc9_ < _loc5_.length)
         {
            _loc10_ = _loc5_[_loc9_];
            if(_loc10_.Location == "STORE")
            {
               if(!_loc10_.Gift)
               {
                  if(!_loc10_.IsBundle)
                  {
                     if(_loc10_.Details[0].WeaponId != 0)
                     {
                        _loc11_ = (StoreServicesController.requiredHeroForWeapon(param1,_loc10_) : Int);
                        if(!(_loc11_ != 0 && (_loc11_ : UInt) != param2.avatarType))
                        {
                           _loc8_ = (StoreServicesController.getOfferLevelReq(param1,_loc10_) : Int);
                           if(!(_loc8_ != 0 && (_loc8_ : UInt) != _loc3_))
                           {
                              _loc6_ = StoreServicesController.getWeaponMastertype(param1,_loc10_);
                              if(!(ASCompat.stringAsBool(_loc6_) && !param2.gmHero.AllowedWeapons.hasKey(_loc6_)))
                              {
                                 _loc4_.push(_loc10_);
                              }
                           }
                        }
                     }
                  }
               }
            }
            _loc9_ = ASCompat.toInt(_loc9_) + 1;
         }
         return _loc4_;
      }
      
      override public function destroy() 
      {
         mGMOffers = null;
         mAvatarInfo = null;
         super.destroy();
      }
      
      override function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_screens.swf";
      }
      
      override function getClassName() : String
      {
         return "levelup_shop_popup";
      }
      
      override function centerButtonCallback() 
      {
         mDBFacade.metrics.log("LevelUpShopPopupContinue");
         super.centerButtonCallback();
      }
      
      override function setupUI(param1:SwfAsset, param2:String, param3:ASAny, param4:Bool, param5:ASFunction) 
      {
         var offerUIs:Vector<MovieClip>;
         var gmOffer:GMOffer;
         var offerUI:MovieClip;
         var gmWeaponItem:GMWeaponItem;
         var gmAesthetic:GMWeaponAesthetic;
         var i:UInt;
         var swfAsset= param1;
         var titleText= param2;
         var content:ASAny = param3;
         var allowClose= param4;
         var closeCallback= param5;
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
         mAvatarInfo.loadHeroIcon(function(param1:MovieClip)
         {
            if(mPopup != null)
            {
               UIObject.scaleToFit(param1,60);
               (mPopup : ASAny).avatar.addChild(param1);
            }
         });
         ASCompat.setProperty((mPopup : ASAny).hero_level_star_label, "text", Std.string(mAvatarInfo.level));
         offerUIs = new Vector<MovieClip>();
         offerUIs.push(ASCompat.dynamicAs((mPopup : ASAny).weapon_0, flash.display.MovieClip));
         offerUIs.push(ASCompat.dynamicAs((mPopup : ASAny).weapon_1, flash.display.MovieClip));
         offerUIs.push(ASCompat.dynamicAs((mPopup : ASAny).weapon_2, flash.display.MovieClip));
         if (checkNullIteratee(offerUIs)) for (_tmp_ in offerUIs)
         {
            offerUI  = _tmp_;
            offerUI.visible = false;
         }
         i = (0 : UInt);
         while(i < (mGMOffers.length : UInt) && i < (offerUIs.length : UInt))
         {
            offerUI = offerUIs[(i : Int)];
            offerUI.visible = true;
            gmOffer = mGMOffers[(i : Int)];
            gmWeaponItem = ASCompat.dynamicAs(mDBFacade.gameMaster.weaponItemById.itemFor(gmOffer.Details[0].WeaponId), gameMasterDictionary.GMWeaponItem);
            gmAesthetic = gmWeaponItem.getWeaponAesthetic(gmOffer.Details[0].Level);
            ASCompat.setProperty((offerUI : ASAny).weapon_label, "text", gmAesthetic.Name.toUpperCase());
            this.loadWeaponIcon(ASCompat.dynamicAs((offerUI : ASAny).empty_slot, flash.display.DisplayObjectContainer),gmWeaponItem);
            ASCompat.setProperty((offerUI : ASAny).level_star_label, "text", Std.string(gmOffer.Details[0].Level));
            i = i + 1;
         }
      }
      
      function loadWeaponIcon(param1:DisplayObjectContainer, param2:GMWeaponItem) 
      {
         var parent= param1;
         var gmWeaponItem= param2;
         var swfPath= gmWeaponItem.UISwfFilepath;
         var iconName= gmWeaponItem.IconName;
         if(ASCompat.stringAsBool(swfPath) && ASCompat.stringAsBool(iconName))
         {
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath),function(param1:SwfAsset)
            {
               var _loc2_:MovieClip = null;
               var _loc3_:MovieClipRenderController = null;
               var _loc4_= param1.getClass(iconName);
               if(_loc4_ != null)
               {
                  _loc2_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc4_, []), flash.display.MovieClip);
                  _loc3_ = new MovieClipRenderController(mDBFacade,_loc2_);
                  _loc3_.play((0 : UInt),true);
                  _loc2_.scaleX = _loc2_.scaleY = 72 / 100;
                  parent.addChild(_loc2_);
               }
            });
         }
      }
   }


