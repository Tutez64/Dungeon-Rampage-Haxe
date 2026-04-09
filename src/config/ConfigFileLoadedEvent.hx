package config
;
   import flash.events.Event;
   
    class ConfigFileLoadedEvent extends Event
   {
      
      public static inline final EVENT_NAME= "ConfigFileLoadedEvent";
      
      var mDBConfigManager:DBConfigManager;
      
      public function new(param1:DBConfigManager, param2:Bool = false, param3:Bool = false)
      {
         super("ConfigFileLoadedEvent",param2,param3);
         mDBConfigManager = param1;
      }
      
      @:isVar public var dbConfigManager(get,never):DBConfigManager;
public function  get_dbConfigManager() : DBConfigManager
      {
         return mDBConfigManager;
      }
   }


