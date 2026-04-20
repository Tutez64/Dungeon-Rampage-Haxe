package uI.tavern
;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.uI.UIObject;
   import brain.uI.UIRadioButton;
   import facade.DBFacade;
   import facade.Locale;
   import gameMasterDictionary.GMHero;
   import gameMasterDictionary.GMSkin;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
    class UITavernSkinButton extends UIRadioButton
   {
      
      var mDBFacade:DBFacade;
      
      var mGMSkin:GMSkin;
      
      var mHeroRequired:MovieClip;
      
      var mIcon:MovieClip;
      
      var mClassicLabel:TextField;
      
      var mShowSkinInTavernCallback:ASFunction;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mAvatarIconSlot:MovieClip;
      
      var mChosenClip:MovieClip;
      
      var mHighlight:MovieClip;
      
      public function new(param1:DBFacade, param2:MovieClip, param3:ASFunction)
      {
         mDBFacade = param1;
         super(param1,param2,"skin_selector_buttons");
         this.releaseCallback = clicked;
         mHeroRequired = ASCompat.dynamicAs((mRoot : ASAny).hero_required, flash.display.MovieClip);
         mHeroRequired.visible = false;
         ASCompat.setProperty((mHeroRequired : ASAny).required_text, "text", Locale.getString("TAVERN_SKIN_BUTTON_HERO_REQUIRED"));
         mShowSkinInTavernCallback = param3;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mAvatarIconSlot = ASCompat.dynamicAs((mRoot : ASAny).slot, flash.display.MovieClip);
         mHighlight = ASCompat.dynamicAs((mRoot : ASAny).selected, flash.display.MovieClip);
         mHighlight.visible = false;
         mChosenClip = ASCompat.dynamicAs((mRoot : ASAny).chosen, flash.display.MovieClip);
         mChosenClip.visible = false;
         mClassicLabel = ASCompat.dynamicAs((mRoot : ASAny).classic_text, flash.text.TextField);
         mClassicLabel.text = Locale.getString("TAVERN_SKIN_SLOT_HERO_LABEL");
      }
      
      @:isVar public var chosen(never,set):Bool;
public function  set_chosen(param1:Bool) :Bool      {
         return mChosenClip.visible = param1;
      }
      
      @:isVar public var gmSkin(never,set):GMSkin;
public function  set_gmSkin(param1:GMSkin) :GMSkin      {
         mGMSkin = param1;
         refresh();
return param1;
      }
      
      function refresh() 
      {
         var hero= ASCompat.dynamicAs(mDBFacade.gameMaster.heroByConstant.itemFor(mGMSkin.ForHero), gameMasterDictionary.GMHero);
         var swfPath= mGMSkin.UISwfFilepath;
         var iconName= mGMSkin.IconName;
         if(mIcon != null && mAvatarIconSlot.contains(mIcon))
         {
            mAvatarIconSlot.removeChild(mIcon);
         }
         while(mAvatarIconSlot.numChildren > 1)
         {
            mAvatarIconSlot.removeChildAt(mAvatarIconSlot.numChildren - 1);
         }
         mClassicLabel.visible = mGMSkin.Constant == hero.DefaultSkin;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath),function(param1:brain.assetRepository.SwfAsset)
         {
            var _loc3_= param1.getClass(iconName);
            mIcon = ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
            var _loc2_= (Std.int(mAvatarIconSlot.width < mAvatarIconSlot.height ? (Std.int(mAvatarIconSlot.width) : UInt) : (Std.int(mAvatarIconSlot.height) : UInt)) : UInt);
            UIObject.scaleToFit(mIcon,_loc2_);
            mAvatarIconSlot.addChildAt(mIcon,1);
         });
      }
      
      function clicked() 
      {
         mShowSkinInTavernCallback(mGMSkin);
         var _loc1_= ASCompat.dynamicAs(mDBFacade.gameMaster.heroByConstant.itemFor(mGMSkin.ForHero), gameMasterDictionary.GMHero);
         mDBFacade.metrics.log("StyleView",{
            "heroType":_loc1_.Id,
            "styleType":mGMSkin.Id
         });
         this.selected = true;
      }
      
      override public function destroy() 
      {
         if(mAssetLoadingComponent != null)
         {
            mAssetLoadingComponent.destroy();
            mAssetLoadingComponent = null;
         }
         super.destroy();
      }
      
      public function getUITavernSkinButtonHighlight() : MovieClip
      {
         return mHighlight;
      }
   }


