package effects
;
   import actor.ActorGameObject;
   import brain.gameObject.GameObject;
   import facade.DBFacade;
   
    class CustomSkinVisualsOverrideHandler
   {
      
      static inline final DARK_MAGE_SKIN_ID= (168 : UInt);
      
      var mDBFacade:DBFacade;
      
      public function new(param1:DBFacade)
      {
         
         mDBFacade = param1;
      }
      
      public function customSkinVFXVisualsOverrider(param1:String, param2:UInt) : String
      {
         var _loc4_:GameObject = null;
         var _loc3_:ActorGameObject = null;
         if(param2 != 0)
         {
            _loc4_ = mDBFacade.gameObjectManager.getReferenceFromId(param2);
            _loc3_ = ASCompat.reinterpretAs(_loc4_ , ActorGameObject);
            if(_loc3_ != null && _loc3_.gmSkin != null && _loc3_.gmSkin.Id == 168)
            {
               if(param1 == "db_fx_shockStun")
               {
                  return "db_fx_darkShockStun";
               }
            }
         }
         return param1;
      }
      
      public function customSkinBusterVisualOverrider(param1:String, param2:ActorGameObject) : String
      {
         if(param2.gmSkin != null)
         {
            if(param2.gmSkin.Id == 168)
            {
               if(param1 == "sorcerer_db")
               {
                  return "sorcerer_dark_db";
               }
               if(param1 == "db_fx_knockback_sorcerer")
               {
                  return "db_fx_knockback_sorcerer_dark";
               }
               if(param1 == "Thunderbolt")
               {
                  return "thunderbolt_dark";
               }
               if(param1 == "ShockNova")
               {
                  return "ShockNova_dark";
               }
               if(param1 == "db_fx_charge_release")
               {
                  return "db_fx_charge_release_dark";
               }
               if(param1 == "db_fx_magicCircle")
               {
                  return "db_fx_magicCircle_dark";
               }
            }
         }
         return param1;
      }
      
      public function customSkinProjectileVisualOverrider(param1:String, param2:UInt) : String
      {
         if(param2 == 168)
         {
            return param1 + "_dark";
         }
         return param1;
      }
   }


