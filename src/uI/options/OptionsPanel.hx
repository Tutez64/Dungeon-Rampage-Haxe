package uI.options
;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.event.EventComponent;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.uI.UIButton;
   import brain.uI.UIRadioButton;
   import brain.uI.UISlider;
   import events.UIHudChangeEvent;
   import facade.DBFacade;
   import facade.Locale;
   import sound.DBSoundManager;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
    class OptionsPanel
   {
      
      static inline final GRAPHICS_QUALITY_RADIO_BUTTON_GROUP= "GRAPHICS_QUALITY_RADIO_BUTTON_GROUP";
      
      static inline final HUD_CHOICE_RADIO_BUTTON_GROUP= "HUD_CHOICE_RADIO_BUTTON_GROUP";
      
      static var GRAPHICS_DIRTY:Bool = false;
      
      static var MUSIC_VOLUME_DIRTY:Bool = false;
      
      static var SFX_VOLUME_DIRTY:Bool = false;
      
      static var HUD_STYLE_DIRTY:Bool = false;
      
      public static inline final HIGH_GRAPHICS_QUALITY= "high";
      
      public static inline final LOW_GRAPHICS_QUALITY= "low";
      
      var mDBFacade:DBFacade;
      
      var mDBSoundManager:DBSoundManager;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      var mEventComponent:EventComponent;
      
      var mCurtainActive:Bool = false;
      
      var mCloseButton:UIButton;
      
      var mTitleLabel:TextField;
      
      var mSfxLabel:TextField;
      
      var mMusicLabel:TextField;
      
      var mMusicButton:UIButton;
      
      var mGraphicsLabel:TextField;
      
      var mGraphicsLowLabel:TextField;
      
      var mGraphicsHighLabel:TextField;
      
      var mGraphicsLowRadioButton:UIRadioButton;
      
      var mGraphicsHighRadioButton:UIRadioButton;
      
      var mSfxSlider:UISlider;
      
      var mMusicSlider:UISlider;
      
      var mHudLabel:TextField;
      
      var mHudDefaultLabel:TextField;
      
      var mHudCondensedLabel:TextField;
      
      var mHudCondensedBlurbLabel:TextField;
      
      var mHudDefaultBlurbLabel:TextField;
      
      var mHudDefaultRadioButton:UIRadioButton;
      
      var mHudCondensedRadioButton:UIRadioButton;
      
      var mHudStyle:UInt = (0 : UInt);
      
      var mGraphicsQuality:String;
      
      var mRoot:MovieClip;
      
      public function new(param1:DBFacade)
      {
         
         mDBFacade = param1;
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"OptionsPanel");
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mEventComponent = new EventComponent(mDBFacade);
         mDBSoundManager = ASCompat.reinterpretAs(mDBFacade.soundManager , DBSoundManager);
         readAccountDeetsToSetInitialValues();
         loadSwf();
      }
      
      function readAccountDeetsToSetInitialValues() 
      {
         var _loc5_= Math.NaN;
         var _loc4_= Math.NaN;
         var _loc1_= mDBFacade.dbAccountInfo.getAttribute("optionsSFXVolume");
         if(_loc1_ != null)
         {
            _loc5_ = ASCompat.toNumber(_loc1_);
            mDBSoundManager.sfxVolumeScale = _loc5_;
         }
         var _loc3_= mDBFacade.dbAccountInfo.getAttribute("optionsMusicVolume");
         if(_loc3_ != null)
         {
            _loc4_ = ASCompat.toNumber(_loc3_);
            mDBSoundManager.musicVolumeScale = _loc4_;
         }
         mGraphicsQuality = mDBFacade.dbAccountInfo.getAttribute("optionsGraphicsQuality");
         if(mGraphicsQuality == "high")
         {
            mDBFacade.featureFlags.setFlagDatabaseValueOnFirstLoad("want-zoom",true);
            mDBFacade.featureFlags.setFlagDatabaseValueOnFirstLoad("want-dynamic-rarity-backgrounds",true);
            mDBFacade.featureFlags.setFlagDatabaseValueOnFirstLoad("want-damage-floaters",true);
            mDBFacade.featureFlags.setFlagDatabaseValueOnFirstLoad("want-town-animations",true);
            mDBFacade.featureFlags.setFlagDatabaseValueOnFirstLoad("want-buster-background-fade",true);
         }
         else if(mGraphicsQuality == "low")
         {
            mDBFacade.featureFlags.setFlagDatabaseValueOnFirstLoad("want-zoom",false);
            mDBFacade.featureFlags.setFlagDatabaseValueOnFirstLoad("want-dynamic-rarity-backgrounds",false);
            mDBFacade.featureFlags.setFlagDatabaseValueOnFirstLoad("want-damage-floaters",false);
            mDBFacade.featureFlags.setFlagDatabaseValueOnFirstLoad("want-town-animations",false);
            mDBFacade.featureFlags.setFlagDatabaseValueOnFirstLoad("want-buster-background-fade",false);
         }
         var _loc2_= mDBFacade.dbAccountInfo.getAttribute("optionsHudStyle");
         if(_loc2_ != null)
         {
            mHudStyle = (ASCompat.toInt(_loc2_) : UInt);
         }
         else
         {
            mHudStyle = (0 : UInt);
         }
      }
      
      function loadSwf() 
      {
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),swfLoaded);
      }
      
      function swfLoaded(param1:SwfAsset) 
      {
         var optionsPanelX:Float;
         var optionsPanelY:Float;
         var swfAsset= param1;
         var optionsClass= swfAsset.getClass("popup_options_02");
         mRoot = ASCompat.dynamicAs(ASCompat.createInstance(optionsClass, []), flash.display.MovieClip);
         mRoot.scaleY = mRoot.scaleX = 1.8;
         mCloseButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).close, flash.display.MovieClip));
         mCloseButton.releaseCallback = hide;
         mTitleLabel = ASCompat.dynamicAs((mRoot : ASAny).title_label , TextField);
         mTitleLabel.text = Locale.getString("OPTIONS_PANEL_TITLE");
         mMusicLabel = ASCompat.dynamicAs((mRoot : ASAny).music_label , TextField);
         mMusicLabel.text = Locale.getString("OPTIONS_PANEL_MUSIC");
         mMusicSlider = new UISlider(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).music_slider, flash.display.MovieClip),(1 : UInt));
         mMusicSlider.minimum = 0;
         mMusicSlider.maximum = 1.1;
         mMusicSlider.tick = 0.1;
         mMusicSlider.value = mDBSoundManager.musicVolumeScale;
         ASCompat.setProperty((mRoot : ASAny).music_slider_value, "text", Std.int(mMusicSlider.value * 10));
         mMusicSlider.updateCallback = musicSliderCallback;
         mSfxLabel = ASCompat.dynamicAs((mRoot : ASAny).sfx_label , TextField);
         mSfxLabel.text = Locale.getString("OPTIONS_PANEL_SOUND_EFFECTS_LABEL");
         mSfxSlider = new UISlider(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).sfx_slider, flash.display.MovieClip),(1 : UInt));
         mSfxSlider.minimum = 0;
         mSfxSlider.maximum = 1.1;
         mSfxSlider.tick = 0.1;
         mSfxSlider.value = mDBSoundManager.sfxVolumeScale;
         ASCompat.setProperty((mRoot : ASAny).sfx_slider_value, "text", Std.int(mSfxSlider.value * 10));
         mSfxSlider.updateCallback = sfxSliderCallback;
         mGraphicsLabel = ASCompat.dynamicAs((mRoot : ASAny).graphics_label , TextField);
         mGraphicsLabel.text = Locale.getString("OPTIONS_PANEL_GRAPHICS_QUALITY_LABEL");
         mGraphicsLowLabel = ASCompat.dynamicAs((mRoot : ASAny).gfx_low_label , TextField);
         mGraphicsLowLabel.text = Locale.getString("OPTIONS_PANEL_GRAPHICS_QUALITY_LOW_LABEL");
         mGraphicsHighLabel = ASCompat.dynamicAs((mRoot : ASAny).gfx_high_label , TextField);
         mGraphicsHighLabel.text = Locale.getString("OPTIONS_PANEL_GRAPHICS_QUALITY_HIGH_LABEL");
         mGraphicsLowRadioButton = new UIRadioButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).gfx_low_radio_button, flash.display.MovieClip),"GRAPHICS_QUALITY_RADIO_BUTTON_GROUP");
         mGraphicsHighRadioButton = new UIRadioButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).gfx_high_radio_button, flash.display.MovieClip),"GRAPHICS_QUALITY_RADIO_BUTTON_GROUP");
         if(mDBFacade.featureFlags.getFlagValue("quality-control-button"))
         {
            mGraphicsLowRadioButton.releaseCallback = function()
            {
               setQuality("low");
            };
            mGraphicsHighRadioButton.releaseCallback = function()
            {
               setQuality("high");
            };
         }
         mHudLabel = ASCompat.dynamicAs((mRoot : ASAny).hud_label , TextField);
         mHudLabel.text = Locale.getString("OPTIONS_PANEL_HUD_LABEL");
         mHudDefaultLabel = ASCompat.dynamicAs((mRoot : ASAny).legacy_label , TextField);
         mHudDefaultLabel.text = Locale.getString("OPTIONS_PANEL_DEFAULT_HUD_LABEL");
         mHudCondensedLabel = ASCompat.dynamicAs((mRoot : ASAny).new_label , TextField);
         mHudCondensedLabel.text = Locale.getString("OPTIONS_PANEL_CONDENSED_HUD_LABEL");
         mHudDefaultRadioButton = new UIRadioButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).legacy_radio_button, flash.display.MovieClip),"HUD_CHOICE_RADIO_BUTTON_GROUP");
         mHudDefaultRadioButton.releaseCallback = function()
         {
            setHud((0 : UInt));
         };
         mHudCondensedRadioButton = new UIRadioButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).new_radio_button, flash.display.MovieClip),"HUD_CHOICE_RADIO_BUTTON_GROUP");
         mHudCondensedRadioButton.releaseCallback = function()
         {
            setHud((1 : UInt));
         };
         optionsPanelX = mDBFacade.dbConfigManager.getConfigNumber("options_panel_x",1500);
         optionsPanelY = mDBFacade.dbConfigManager.getConfigNumber("options_panel_y",200);
         mRoot.x = optionsPanelX;
         mRoot.y = optionsPanelY;
      }
      
      function musicSliderCallback(param1:Float) 
      {
         var _loc2_= Std.int(mMusicSlider.value * 10);
         ASCompat.setProperty((mRoot : ASAny).music_slider_value, "text", _loc2_);
         if(_loc2_ == 11 && mDBFacade.steamAchievementsManager != null)
         {
            mDBFacade.steamAchievementsManager.setAchievement("MUSIC_VOLUME_SET_TO_11");
         }
         setMusicVolume(param1);
      }
      
      function sfxSliderCallback(param1:Float) 
      {
         ASCompat.setProperty((mRoot : ASAny).sfx_slider_value, "text", Std.int(mSfxSlider.value * 10));
         setSfxVolume(param1);
      }
      
      function setQuality(param1:String) 
      {
         mGraphicsQuality = param1;
         GRAPHICS_DIRTY = true;
         if(mGraphicsQuality == "high")
         {
            mDBFacade.featureFlags.setFlagOverrideValue("want-zoom",true);
            mDBFacade.featureFlags.setFlagOverrideValue("want-dynamic-rarity-backgrounds",true);
            mDBFacade.featureFlags.setFlagOverrideValue("want-damage-floaters",true);
            mDBFacade.featureFlags.setFlagOverrideValue("want-town-animations",true);
            mDBFacade.featureFlags.setFlagOverrideValue("want-buster-background-fade",true);
         }
         else if(mGraphicsQuality == "low")
         {
            mDBFacade.featureFlags.setFlagOverrideValue("want-zoom",false);
            mDBFacade.featureFlags.setFlagOverrideValue("want-dynamic-rarity-backgrounds",false);
            mDBFacade.featureFlags.setFlagOverrideValue("want-damage-floaters",false);
            mDBFacade.featureFlags.setFlagOverrideValue("want-town-animations",false);
            mDBFacade.featureFlags.setFlagOverrideValue("want-buster-background-fade",false);
         }
      }
      
      function setHud(param1:UInt) 
      {
         mHudStyle = param1;
         HUD_STYLE_DIRTY = true;
         mEventComponent.dispatchEvent(new UIHudChangeEvent(mHudStyle));
      }
      
      function setSfxVolume(param1:Float) 
      {
         mDBSoundManager.sfxVolumeScale = param1;
         SFX_VOLUME_DIRTY = true;
      }
      
      function setMusicVolume(param1:Float) 
      {
         mDBSoundManager.musicVolumeScale = param1;
         MUSIC_VOLUME_DIRTY = true;
      }
      
      public function hide() 
      {
         if(mRoot != null)
         {
            mSceneGraphComponent.removeChild(mRoot);
         }
         removeCurtain();
         saveValuesToDB();
      }
      
      function saveValuesToDB() 
      {
         if(GRAPHICS_DIRTY)
         {
            if(mDBFacade.dbAccountInfo.getAttribute("optionsGraphicsQuality") != mGraphicsQuality)
            {
               mDBFacade.dbAccountInfo.alterAttribute("optionsGraphicsQuality",mGraphicsQuality);
            }
         }
         if(SFX_VOLUME_DIRTY)
         {
            if(mDBFacade.dbAccountInfo.getAttribute("optionsSFXVolume") != Std.string(mDBSoundManager.sfxVolumeScale))
            {
               mDBFacade.dbAccountInfo.alterAttribute("optionsSFXVolume",Std.string(mDBSoundManager.sfxVolumeScale));
            }
         }
         if(MUSIC_VOLUME_DIRTY)
         {
            if(mDBFacade.dbAccountInfo.getAttribute("optionsMusicVolume") != Std.string(mDBSoundManager.musicVolumeScale))
            {
               mDBFacade.dbAccountInfo.alterAttribute("optionsMusicVolume",Std.string(mDBSoundManager.musicVolumeScale));
            }
         }
         if(HUD_STYLE_DIRTY)
         {
            if(ASCompat.asUint(mDBFacade.dbAccountInfo.getAttribute("optionsHudStyle") ) != mHudStyle)
            {
               mDBFacade.dbAccountInfo.alterAttribute("optionsHudStyle",Std.string(mHudStyle));
            }
         }
         GRAPHICS_DIRTY = false;
         SFX_VOLUME_DIRTY = false;
         MUSIC_VOLUME_DIRTY = false;
         HUD_STYLE_DIRTY = false;
      }
      
      public function show() 
      {
         if(mRoot != null)
         {
            if(mGraphicsQuality == "high")
            {
               mGraphicsHighRadioButton.selected = true;
            }
            else
            {
               mGraphicsLowRadioButton.selected = true;
            }
            switch(mHudStyle)
            {
               case 0:
                  mHudDefaultRadioButton.selected = true;
                  
               case 1:
                  mHudCondensedRadioButton.selected = true;
            }
            mSceneGraphComponent.addChild(mRoot,(105 : UInt));
            showCurtain();
         }
      }
      
      function showCurtain() 
      {
         if(!mCurtainActive)
         {
            mCurtainActive = true;
            mSceneGraphComponent.showPopupCurtain();
         }
      }
      
      function removeCurtain() 
      {
         if(mCurtainActive)
         {
            mCurtainActive = false;
            mSceneGraphComponent.removePopupCurtain();
         }
      }
      
      public function toggleVisible() : Bool
      {
         if(mRoot != null)
         {
            if(mSceneGraphComponent.contains(mRoot,(50 : UInt)))
            {
               this.hide();
               return false;
            }
            this.show();
            return true;
         }
         return false;
      }
      
      public function destroy() 
      {
         hide();
         mCloseButton.destroy();
         mSfxSlider.destroy();
         mMusicSlider.destroy();
         mGraphicsLowRadioButton.destroy();
         mGraphicsHighRadioButton.destroy();
         mRoot = null;
         mCloseButton = null;
         mSfxSlider = null;
         mMusicSlider = null;
         mSceneGraphComponent.destroy();
         mSceneGraphComponent = null;
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mEventComponent.destroy();
         mEventComponent = null;
         if(mHudDefaultRadioButton != null)
         {
            mHudDefaultRadioButton.destroy();
            mHudDefaultRadioButton = null;
         }
         if(mHudCondensedRadioButton != null)
         {
            mHudCondensedRadioButton.destroy();
            mHudCondensedRadioButton = null;
         }
         mDBFacade = null;
      }
   }


