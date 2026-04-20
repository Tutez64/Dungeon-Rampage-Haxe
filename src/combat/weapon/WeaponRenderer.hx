package combat.weapon
;
   import actor.ActorRenderer;
   import brain.render.IRenderer;
   import dBGlobals.DBGlobal;
   import facade.DBFacade;
   
    class WeaponRenderer extends ActorRenderer
   {
      
      var mWeaponGameObject:WeaponGameObject;
      
      public function new(param1:DBFacade, param2:WeaponGameObject, param3:Bool)
      {
         super(param1,param2.actorGameObject,param3);
         mWeaponGameObject = param2;
      }
      
      override public function destroy() 
      {
         super.destroy();
         mWeaponGameObject = null;
      }
      
      override function loadErrorCallback() 
      {
      }
      
      override function getSpriteSheetClassName(param1:String) : String
      {
         return mActorGameObject.actorData.assetClassName + "_" + param1 + "_" + mWeaponGameObject.weaponAesthetic.ModelName + ".png";
      }
      
      override function  get_movieClipClassName() : String
      {
         return super.movieClipClassName + "_" + mWeaponGameObject.weaponAesthetic.ModelName;
      }
      
      override function setAnimInDictionary(param1:String, param2:IRenderer) 
      {
         super.setAnimInDictionary(param1,param2);
         stop();
      }
      
      override function  get_swfFilePath() : String
      {
         if(DBGlobal.endsWith(super.swfFilePath,".HD.swf"))
         {
            return super.swfFilePath.substring(0,super.swfFilePath.length - 7) + "_" + mWeaponGameObject.weaponAesthetic.ModelName + ".HD.swf";
         }
         return super.swfFilePath.substring(0,super.swfFilePath.length - 4) + "_" + mWeaponGameObject.weaponAesthetic.ModelName + ".swf";
      }
   }


