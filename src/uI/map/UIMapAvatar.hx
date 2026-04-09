package uI.map
;
   import facade.DBFacade;
   import com.maccherone.json.JSON;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.net.URLLoader;
   
    class UIMapAvatar
   {
      
      var mAvatar:MovieClip;
      
      var mAvatarDropShadow:MovieClip;
      
      var mAvatarMover:UIMapAvatarMover;
      
      var mDBFacade:DBFacade;
      
      public function new(param1:DBFacade, param2:MovieClip, param3:MovieClip, param4:Dynamic)
      {
         
         mDBFacade = param1;
         mAvatar = param2;
         mAvatarDropShadow = param3;
         mAvatarMover = ASCompat.dynamicAs(ASCompat.createInstance(param4, [updatePosition]) , UIMapAvatarMover);
         updatePlayerName();
      }
      
      public function moveTo(param1:Float, param2:Float) 
      {
         mAvatarMover.moveTo(param1,param2);
      }
      
      public function destroy(param1:MovieClip) 
      {
         if(mAvatar != null)
         {
            param1.removeChild(mAvatar);
         }
         if(mAvatarDropShadow != null)
         {
            param1.removeChild(mAvatarDropShadow);
         }
         if(mAvatarMover != null)
         {
            mAvatarMover.destroy();
            mAvatarMover = null;
         }
      }
      
      function updatePosition(param1:Float, param2:Float) 
      {
         mAvatar.x = param1;
         mAvatar.y = param2;
         mAvatarDropShadow.x = param1;
         mAvatarDropShadow.y = param2;
      }
      
      function loadedPlayerName(param1:Event) 
      {
         var _loc3_= cast(param1.target, URLLoader);
         var _loc2_:ASObject = com.maccherone.json.JSON.decode(_loc3_.data);
         ASCompat.setProperty((mAvatar : ASAny).label, "text", _loc2_["name"]);
      }
      
      function updatePlayerName() 
      {
         ASCompat.setProperty((mAvatar : ASAny).label, "text", ASCompat.stringAsBool(mDBFacade.facebookAccountInfo.name) ? mDBFacade.facebookAccountInfo.name : mDBFacade.dbAccountInfo.name);
      }
   }


