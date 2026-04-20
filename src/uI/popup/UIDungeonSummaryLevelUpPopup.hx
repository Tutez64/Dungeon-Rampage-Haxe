package uI.popup
;
   import brain.assetRepository.SwfAsset;
   import brain.render.MovieClipRenderController;
   import brain.uI.UIButton;
   import facade.DBFacade;
   import facade.Locale;
   import gameMasterDictionary.GMFeedPosts;
   import gameMasterDictionary.GMSkin;
   import flash.display.MovieClip;
   
    class UIDungeonSummaryLevelUpPopup extends DBUIOneButtonPopup
   {
      
      static inline final SWF_PATH= "Resources/Art2D/UI/db_UI_town.swf";
      
      static inline final POPUP_CLASS_NAME= "UI_prompt_levelup";
      
      static inline final AVATAR_PIC_SCALE:Float = 0.45;
      
      var mGMSkin:GMSkin;
      
      var mLevelUpPost:GMFeedPosts;
      
      var mPicClass:Dynamic;
      
      public function new(param1:DBFacade, param2:ASFunction, param3:GMSkin, param4:GMFeedPosts, param5:Dynamic)
      {
         mGMSkin = param3;
         mLevelUpPost = param4;
         mPicClass = param5;
         super(param1,Locale.getString("INVITE_POPUP_TITLE"),Locale.getString("INVITE_POPUP_MESSAGE"),null,param2,true,null,null,null,true,"DUNGEON_SUMMARY_LEVEL_UP_POPUP");
         mDBFacade.metrics.log("InvitePopupPresented");
      }
      
      override function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_town.swf";
      }
      
      override function getClassName() : String
      {
         return "UI_prompt_levelup";
      }
      
      override function centerButtonCallback() 
      {
         mDBFacade.metrics.log("InvitePopupContinue");
         super.centerButtonCallback();
      }
      
      override function setupUI(param1:SwfAsset, param2:String, param3:ASAny, param4:Bool, param5:ASFunction) 
      {
         var avatarPic:MovieClip;
         var movieClipRenderer:MovieClipRenderController;
         var levelUpButton:UIButton;
         var swfAsset= param1;
         var titleText= param2;
         var content:ASAny = param3;
         var allowClose= param4;
         var closeCallback= param5;
         super.setupUI(swfAsset,titleText,null,allowClose,closeCallback);
         mPopup.x += 40;
         avatarPic = ASCompat.dynamicAs(ASCompat.createInstance(mPicClass, []), flash.display.MovieClip);
         movieClipRenderer = new MovieClipRenderController(mDBFacade,avatarPic);
         movieClipRenderer.play();
         avatarPic.scaleX = avatarPic.scaleY = 0.45;
         (mPopup : ASAny).avatar.addChildAt(avatarPic,0);
         ASCompat.setProperty((mPopup : ASAny).level_text, "text", mLevelUpPost.LevelTrigger);
         ASCompat.setProperty((mPopup : ASAny).congrats_label, "text", Locale.getString("LEVEL_UP_SHARE_TITLE"));
         ASCompat.setProperty((mPopup : ASAny).label, "text", Locale.getString("LEVEL_UP_SHARE_TEXT") + mLevelUpPost.LevelTrigger);
         levelUpButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).share, flash.display.MovieClip));
         if(mDBFacade.isDRPlayer)
         {
            levelUpButton.label.text = Locale.getString("SWEET");
         }
         else
         {
            levelUpButton.label.text = Locale.getString("LEVEL_UP_SHARE_BUTTON_TEXT");
         }
         levelUpButton.releaseCallback = function()
         {
            close(null);
         };
         mPopup.x = mDBFacade.viewWidth / 2;
         mPopup.y = mDBFacade.viewHeight / 2;
         mCloseButton.clearNavigationAndInteractions();
         mCloseButton.isAbove(levelUpButton);
      }
   }


