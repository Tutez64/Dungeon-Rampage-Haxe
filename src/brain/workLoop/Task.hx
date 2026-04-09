package brain.workLoop
;
    class Task
   {
      
      public var callback:ASFunction = null;
      
      var mDestroyed:Bool = false;
      
      public function new()
      {
         
      }
      
      public function destroy() 
      {
         mDestroyed = true;
         callback = null;
      }
      
      public function isDestroyed() : Bool
      {
         return mDestroyed;
      }
   }


