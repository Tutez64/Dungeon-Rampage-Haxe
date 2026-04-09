package actor.player
;
   import brain.logger.Logger;
   import facade.DBFacade;
   import gameMasterDictionary.GMSkin;
   
    class SkinInfo
   {
      
      var mGMSkin:GMSkin;
      
      var mSkinType:UInt = 0;
      
      var mDBFacade:DBFacade;
      
      public function new(param1:DBFacade, param2:ASObject)
      {
         
         mDBFacade = param1;
         mSkinType = ASCompat.asUint(param2.skin_type );
         mGMSkin = mDBFacade.gameMaster.getSkinByType(mSkinType);
         if(mGMSkin == null)
         {
            Logger.error("Unable to find GMSkin for skin with id: " + mSkinType);
         }
      }
      
      @:isVar public var skinType(get,never):UInt;
public function  get_skinType() : UInt
      {
         return mSkinType;
      }
   }


