package account
;
    class PlayerSpecialStatus
   {
      
      public function new()
      {
         
      }
      
      public static function getSpecialTextColor(param1:String, param2:UInt) : UInt
      {
         if(param1.charAt(0) == "★")
         {
            return (380536 : UInt);
         }
         if(param1.charAt(0) == "⚡")
         {
            return (16738339 : UInt);
         }
         if(param1.charAt(0) == "⚠")
         {
            return param2;
         }
         return param2;
      }
   }


