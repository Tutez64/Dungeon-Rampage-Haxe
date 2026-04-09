package brain.utils
;
    interface IPoolable
   {
      
      function postCheckout(param1:Bool) : Void;
      
      function postCheckin() : Void;
      
      function destroy() : Void;
      
      function getPoolKey() : String;
   }


