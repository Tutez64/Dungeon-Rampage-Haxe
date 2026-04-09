package uI.equipPicker
;
   import account.AvatarInfo;
   import account.ItemInfo;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.render.MovieClipRenderController;
   import brain.uI.UIButton;
   import brain.uI.UIObject;
   import brain.utils.ColorMatrix;
   import dBGlobals.DBGlobal;
   import facade.DBFacade;
   import gameMasterDictionary.GMHero;
   import gameMasterDictionary.GMSkin;
   import gameMasterDictionary.GMWeaponItem;
   import uI.inventory.UIHeroTooltip;
   import flash.display.MovieClip;
   import flash.geom.Point;
   
    class HeroElement extends UIButton
   {
      
      var mDBFacade:DBFacade;
      
      var mHeroTooltip:UIHeroTooltip;
      
      var mHeroClicked:ASFunction;
      
      var mGMHero:GMHero;
      
      var mIcon:MovieClip;
      
      var mOverlay:MovieClip;
      
      var mWeaponUnusable:MovieClip;
      
      var mWeaponWeaker:MovieClip;
      
      var mWeaponStronger:MovieClip;
      
      var mAlert:MovieClip;
      
      var mAlertRenderer:MovieClipRenderController;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mContainerHeight:UInt = 0;
      
      var mContainerWidth:UInt = 0;
      
      public function new(param1:DBFacade, param2:MovieClip, param3:Dynamic, param4:ASFunction)
      {
         var dbFacade= param1;
         var root= param2;
         var tooltipClass= param3;
         var heroClicked= param4;
         super(dbFacade,root);
         mDBFacade = dbFacade;
         mHeroClicked = heroClicked;
         this.releaseCallbackThis = function(param1:UIButton)
         {
            mHeroClicked(param1,owned);
         };
         mOverlay = ASCompat.dynamicAs((mRoot : ASAny).overlay, flash.display.MovieClip);
         mOverlay.visible = false;
         mWeaponUnusable = ASCompat.dynamicAs((mRoot : ASAny).unusable, flash.display.MovieClip);
         mWeaponWeaker = ASCompat.dynamicAs((mRoot : ASAny).arrow_down, flash.display.MovieClip);
         mWeaponStronger = ASCompat.dynamicAs((mRoot : ASAny).arrow_up, flash.display.MovieClip);
         hideWeaponComparison();
         mAlert = ASCompat.dynamicAs((mRoot : ASAny).alert_icon, flash.display.MovieClip);
         mAlertRenderer = new MovieClipRenderController(dbFacade,mAlert);
         mAlertRenderer.play((0 : UInt),true);
         mAlert.visible = false;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mContainerHeight = (Std.int(mRoot.height) : UInt);
         mContainerWidth = (Std.int(mRoot.width) : UInt);
         this.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mHeroTooltip = new UIHeroTooltip(mDBFacade,tooltipClass);
         this.tooltip = mHeroTooltip;
         this.tooltipPos = new Point(0,this.root.height * -0.5);
         mHeroTooltip.visible = false;
      }
      
      override public function destroy() 
      {
         mHeroTooltip.destroy();
         mHeroClicked = null;
         if(mAlertRenderer != null)
         {
            mAlertRenderer.destroy();
            mAlertRenderer = null;
         }
         mAssetLoadingComponent.destroy();
         mDBFacade = null;
         super.destroy();
      }
      
      public function showWeaponComparison(param1:GMWeaponItem, param2:UInt) 
      {
         var _loc7_:ItemInfo;
         var _loc4_= false;
         var _loc6_:Vector<ItemInfo> = /*undefined*/null;
         if(mGMHero == null)
         {
            return;
         }
         var _loc3_= mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mGMHero.Id);
         var _loc5_= mGMHero.AllowedWeapons.hasKey(param1.MasterType);
         if(_loc5_)
         {
            mWeaponUnusable.visible = false;
            _loc4_ = true;
            if(_loc3_ != null)
            {
               _loc6_ = mDBFacade.dbAccountInfo.inventoryInfo.getEquipedItemsOnAvatar(_loc3_.id);
               if (checkNullIteratee(_loc6_)) for (_tmp_ in _loc6_)
               {
                  _loc7_ = _tmp_;
                  if(_loc7_.gmWeaponItem.MasterType == param1.MasterType && ASCompat.toNumberField(_loc7_, "power") >= param2)
                  {
                     _loc4_ = false;
                     break;
                  }
               }
            }
            mWeaponWeaker.visible = !_loc4_;
            mWeaponStronger.visible = _loc4_;
         }
         else
         {
            mWeaponUnusable.visible = true;
            mWeaponWeaker.visible = false;
            mWeaponStronger.visible = false;
         }
      }
      
      public function hideWeaponComparison() 
      {
         mWeaponUnusable.visible = false;
         mWeaponWeaker.visible = false;
         mWeaponStronger.visible = false;
      }
      
      @:isVar public var alert(never,set):Bool;
public function  set_alert(param1:Bool) :Bool      {
         return mAlert.visible = param1;
      }
      
            
      @:isVar public var gmHero(get,set):GMHero;
public function  set_gmHero(param1:GMHero) :GMHero      {
         var _loc2_:AvatarInfo = null;
         var _loc3_:ColorMatrix = null;
         mGMHero = param1;
         var _loc4_= this.owned;
         loadHeroIcon();
         if(_loc4_)
         {
            mRoot.filters = cast([]);
            _loc2_ = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mGMHero.Id);
            mHeroTooltip.ownedHero = _loc2_;
         }
         else
         {
            _loc3_ = new ColorMatrix();
            _loc3_.adjustSaturation(0.1);
            _loc3_.adjustBrightness(-64);
            _loc3_.adjustContrast(-0.5);
            mRoot.filters = cast([_loc3_.filter]);
            mHeroTooltip.unownedHero = mGMHero;
         }
         mHeroTooltip.visible = true;
return param1;
      }
function  get_gmHero() : GMHero
      {
         return mGMHero;
      }
      
      @:isVar var owned(get,never):Bool;
function  get_owned() : Bool
      {
         return mGMHero != null ? mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(mGMHero.Id) : false;
      }
      
      function loadHeroIcon() 
      {
         var gmSkin:GMSkin;
         var swfPath:String;
         var iconName:String;
         var avatarInfo= mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mGMHero.Id);
         if(avatarInfo == null)
         {
            gmSkin = mDBFacade.gameMaster.getSkinByConstant(mGMHero.DefaultSkin);
         }
         else
         {
            gmSkin = mDBFacade.gameMaster.getSkinByType(avatarInfo.skinId);
         }
         swfPath = gmSkin.UISwfFilepath;
         iconName = gmSkin.IconName;
         if(mIcon != null && mRoot.contains(mIcon))
         {
            mRoot.removeChild(mIcon);
         }
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath),function(param1:brain.assetRepository.SwfAsset)
         {
            var _loc3_= param1.getClass(iconName);
            mIcon = ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
            var _loc2_= mContainerWidth < mContainerHeight ? mContainerWidth : mContainerHeight;
            UIObject.scaleToFit(mIcon,_loc2_);
            mRoot.addChildAt(mIcon,0);
            mIcon.scaleX *= 0.96;
            mIcon.scaleY *= 0.96;
         });
      }
      
      public function clear() 
      {
         if(mIcon != null && mRoot.contains(mIcon))
         {
            mRoot.removeChild(mIcon);
         }
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
      }
      
      public function select() 
      {
         mRoot.scaleX = 1.25;
         mRoot.scaleY = 1.25;
      }
      
      public function deselect() 
      {
         mRoot.scaleX = 1;
         mRoot.scaleY = 1;
      }
   }


