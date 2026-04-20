package uI.inventory
;
   import facade.DBFacade;
   import facade.GameMasterLocale;
   import gameMasterDictionary.GMWeaponItem;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
    class UIWeaponDescTooltip extends MovieClip
   {
      
      var mDBFacade:DBFacade;
      
      var mRoot:MovieClip;
      
      var mDescription:TextField;
      
      public function new(param1:DBFacade, param2:Dynamic)
      {
         super();
         mDBFacade = param1;
         mRoot = ASCompat.dynamicAs(ASCompat.createInstance(param2, []), flash.display.MovieClip);
         this.addChild(mRoot);
         mDescription = ASCompat.dynamicAs((mRoot : ASAny).description_label, flash.text.TextField);
      }
      
      public function destroy() 
      {
         mDBFacade = null;
         this.removeChild(mRoot);
         mRoot = null;
      }
      
      public function place(param1:Int, param2:Int) 
      {
         mRoot.x = param1;
         mRoot.y = param2;
      }
      
      public function setWeaponItem(param1:GMWeaponItem, param2:UInt, param3:Bool = false) 
      {
         mDescription.text = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_DESCRIPTION",param1.getWeaponAesthetic(param2,param3).WeaponItemConstant);
      }
   }


