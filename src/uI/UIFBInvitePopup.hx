package uI
;
   import brain.assetRepository.SwfAsset;
   import brain.logger.Logger;
   import facade.DBFacade;
   import facade.Locale;
   import flash.display.Sprite;
   
    class UIFBInvitePopup extends DBUIOneButtonPopup
   {
      
      static inline final SWF_PATH= "Resources/Art2D/UI/db_UI_screens.swf";
      
      static inline final POPUP_CLASS_NAME= "invite_popup";
      
      public function new(param1:DBFacade, param2:ASFunction)
      {
         super(param1,Locale.getString("INVITE_POPUP_TITLE"),Locale.getString("INVITE_POPUP_MESSAGE"),Locale.getString("INVITE_POPUP_BUTTON"),param2,true,null);
         mDBFacade.metrics.log("InvitePopupPresented");
      }
      
      override function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_screens.swf";
      }
      
      override function getClassName() : String
      {
         return "invite_popup";
      }
      
      override function centerButtonCallback() 
      {
         mDBFacade.metrics.log("InvitePopupContinue");
         super.centerButtonCallback();
      }
      
      override function setupUI(param1:SwfAsset, param2:String, param3:ASAny, param4:Bool, param5:ASFunction) 
      {
         super.setupUI(param1,param2,param3,param4,param5);
         ASCompat.setProperty((mPopup : ASAny).player_name_label, "text", mDBFacade.dbAccountInfo.name);
         ASCompat.setProperty((mPopup : ASAny).chatBalloon.chatMessage, "text", Locale.getString("INVITE_POPUP_CHAT"));
         ASCompat.setProperty((mPopup : ASAny).nametag_1, "visible", false);
         ASCompat.setProperty((mPopup : ASAny).nametag_2, "visible", false);
         ASCompat.setProperty((mPopup : ASAny).nametag_3, "visible", false);
         mDBFacade.facebookAccountInfo.loadFriends(this.loadedFriends);
      }
      
      function loadedFriends(param1:Array<ASAny>) 
      {
         var _loc2_:Float = 0;
         var _loc4_:Float = 0;
         var _loc3_:Float = 0;
         if(param1.length >= 3)
         {
            Logger.debug("UIInvitePopup showing friends");
            ASCompat.setProperty((mPopup : ASAny).nametag_1, "visible", true);
            ASCompat.setProperty((mPopup : ASAny).nametag_2, "visible", true);
            ASCompat.setProperty((mPopup : ASAny).nametag_3, "visible", true);
            _loc2_ = Math.ffloor(Math.random() * param1.length);
            _loc4_ = Math.ffloor(Math.random() * param1.length);
            while(_loc4_ == _loc2_)
            {
               _loc4_ = Math.ffloor(Math.random() * param1.length);
            }
            _loc3_ = Math.ffloor(Math.random() * param1.length);
            while(_loc3_ == _loc4_ || _loc3_ == _loc2_)
            {
               _loc3_ = Math.ffloor(Math.random() * param1.length);
            }
            ASCompat.setProperty((mPopup : ASAny).nametag_1.name_label, "text", param1[Std.int(_loc2_)].name);
            ASCompat.setProperty((mPopup : ASAny).nametag_2.name_label, "text", param1[Std.int(_loc4_)].name);
            ASCompat.setProperty((mPopup : ASAny).nametag_3.name_label, "text", param1[Std.int(_loc3_)].name);
            cast((mPopup : ASAny).nametag_1.pic_bg, Sprite).addChild(mDBFacade.facebookAccountInfo.loadFriendProfilePic(param1[Std.int(_loc2_)].id));
            cast((mPopup : ASAny).nametag_2.pic_bg, Sprite).addChild(mDBFacade.facebookAccountInfo.loadFriendProfilePic(param1[Std.int(_loc4_)].id));
            cast((mPopup : ASAny).nametag_3.pic_bg, Sprite).addChild(mDBFacade.facebookAccountInfo.loadFriendProfilePic(param1[Std.int(_loc3_)].id));
         }
         else
         {
            Logger.debug("UIInvitePopup: not enough friends to show");
         }
      }
   }


