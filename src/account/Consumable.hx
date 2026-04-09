package account
;
    class Consumable
   {
      
      public var stackId:UInt = 0;
      
      public var stackCount:UInt = 0;
      
      public var stackSlot:UInt = 0;
      
      public function new(param1:UInt, param2:UInt, param3:UInt)
      {
         
         stackId = param2;
         stackCount = param3;
         stackSlot = param1;
      }
   }


