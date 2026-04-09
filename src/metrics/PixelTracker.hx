package metrics
;
   import brain.logger.Logger;
   import facade.DBFacade;
   import flash.events.Event;
   
    class PixelTracker
   {
      
      public function new()
      {
         
      }
      
      public static function tutorialComplete(param1:DBFacade) 
      {
      }
      
      public static function purchaseEvent(param1:DBFacade, param2:UInt) 
      {
      }
      
      public static function nodeCompleted(param1:DBFacade) 
      {
      }
      
      public static function nodeIndexCompleted(param1:DBFacade, param2:UInt) 
      {
      }
      
      public static function logMapNodeUnlocked(param1:DBFacade, param2:UInt) 
      {
      }
      
      public static function wallPost(param1:DBFacade) 
      {
      }
      
      public static function invitedFriend(param1:DBFacade) 
      {
      }
      
      public static function returnDAU(param1:DBFacade) 
      {
      }
      
      public static function visitedStore(param1:DBFacade) 
      {
      }
      
      public static function completeHandler(param1:Event) 
      {
         Logger.debug("Tracker completeHandler" + param1.toString());
      }
      
      public static function securityErrorHandler(param1:Event) 
      {
         Logger.warn("Tracker securityErrorHandler: " + param1.toString());
      }
      
      public static function ioErrorHandler(param1:Event) 
      {
         Logger.warn("Tracker ioErrorHandler: " + param1.toString());
      }
   }


