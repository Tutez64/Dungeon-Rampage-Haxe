package brain.utils
;
    class Receipt
   {
      
      var mUnregisterFunction:ASFunction;
      
      public function new(param1:ASFunction)
      {
         
         mUnregisterFunction = param1;
      }
      
      public function exit() 
      {
         mUnregisterFunction();
      }
   }


