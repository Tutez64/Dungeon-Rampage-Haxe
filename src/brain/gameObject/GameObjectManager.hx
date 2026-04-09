package brain.gameObject
;
   import brain.facade.Facade;
   import brain.logger.Logger;
   import org.as3commons.collections.Map;
   
    class GameObjectManager
   {
      
      var mGameObjects:Map = new Map();
      
      var mFacade:Facade;
      
      public function new(param1:Facade)
      {
         
         mFacade = param1;
      }
      
      public function isIdActive(param1:UInt) : Bool
      {
         return mGameObjects.hasKey(param1);
      }
      
      public function removeIdReference(param1:UniqueID) 
      {
         if(mGameObjects.hasKey(param1.id))
         {
            mGameObjects.removeKey(param1.id);
         }
         else
         {
            Logger.error("GameObjectManager:removeIdReference Removing id not existing " + param1);
         }
      }
      
      public function addIdReference(param1:UInt, param2:GameObject) 
      {
         if(mGameObjects.hasKey(param1))
         {
            Logger.error("GameObjectManager:addIdReference Adding Id That Already Exists " + param1);
         }
         mGameObjects.add(param1,param2);
      }
      
      public function getReferenceFromId(param1:UInt) : GameObject
      {
         return ASCompat.dynamicAs(mGameObjects.itemFor(param1), brain.gameObject.GameObject);
      }
   }


