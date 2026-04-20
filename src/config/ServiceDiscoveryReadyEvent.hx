package config
;
   import flash.events.Event;
   
    class ServiceDiscoveryReadyEvent extends Event
   {
      
      public static inline final EVENT_NAME= "ServiceDiscoveryReadyEvent";
      
      public var serviceDiscoveryResult:ASObject;
      
      public var serviceDiscoveryErrorCode:Int = 0;
      
      public var serviceDiscoveryErrorText:String;
      
      public function new(param1:ASObject, param2:Int, param3:String = "")
      {
         super("ServiceDiscoveryReadyEvent",true);
         serviceDiscoveryResult = param1;
         serviceDiscoveryErrorCode = param2;
         serviceDiscoveryErrorText = param3;
      }
   }


