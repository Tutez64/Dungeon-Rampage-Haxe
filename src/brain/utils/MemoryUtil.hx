package brain.utils
;
   
    class MemoryUtil
   {
      
      public function new()
      {
         
      }
      
      public static function pauseForGCWithLogging(param1:String = "", param2:Float = 0.25) 
      {
         ASCompat.pauseForGCIfCollectionImminent(param2);
      }
   }


