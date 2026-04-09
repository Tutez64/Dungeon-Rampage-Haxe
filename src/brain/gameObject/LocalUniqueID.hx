package brain.gameObject
;
   import brain.facade.Facade;
   import brain.logger.Logger;
   
    class LocalUniqueID extends UniqueID
   {
      
      static var minId:UInt = (1000000 : UInt);
      
      static var maxId:UInt = (1099999 : UInt);
      
      static var cache:UInt = (1000000 : UInt);
      
      public function new(param1:Facade, param2:GameObject)
      {
         var _loc3_= 0;
         var _loc4_= nextCandidate();
         while(_loc3_ == 0)
         {
            if(param1.gameObjectManager.isIdActive(_loc4_))
            {
               _loc4_ = nextCandidate();
            }
            else
            {
               _loc3_ = (_loc4_ : Int);
            }
         }
         super(param1,(_loc3_ : UInt),param2);
      }
      
      function nextCandidate() : UInt
      {
         cache += (1 : UInt);
         if(cache > maxId)
         {
            Logger.debug("--------------------------->Wrap **************************************");
            cache = minId;
         }
         return cache;
      }
   }


