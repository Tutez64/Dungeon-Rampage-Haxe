package brain.utils
;

 import flash.errors.ArgumentError;
    class FeatureFlag
   {
      
      static inline final UNSET_ENUM= (0 : UInt);
      
      static inline final FALSE_ENUM= (1 : UInt);
      
      static inline final TRUE_ENUM= (2 : UInt);
      
      public var name:String;
      
      public var defaultValue:Bool = false;
      
      var _currentValue:Bool = false;
      
      var _commandLineFlag:String;
      
      var _configFileAttributeName:String;
      
      var configFileValue:UInt = 0;
      
      var dbValue:UInt = 0;
      
      var cliValue:UInt = 0;
      
      var overrideValue:UInt = 0;
      
      public function new(param1:String, param2:Bool, param3:String, param4:String)
      {
         
         this.name = param1;
         this._currentValue = param2;
         this.defaultValue = param2;
         if(ASCompat.stringAsBool(param3))
         {
            this._commandLineFlag = param3;
         }
         else
         {
            this._commandLineFlag = "--" + param1;
         }
         if(_commandLineFlag.indexOf("--") != 0)
         {
            throw new ArgumentError("FeatureFlag commandLineFlag must start with --");
         }
         if(_commandLineFlag.indexOf(" ") != -1)
         {
            throw new ArgumentError("FeatureFlag commandLineFlag must not contain spaces");
         }
         if(ASCompat.stringAsBool(param4))
         {
            this._configFileAttributeName = param4;
         }
         else
         {
            this._configFileAttributeName = param1;
         }
         if(_configFileAttributeName.indexOf(" ") != -1)
         {
            throw new ArgumentError("ConfigFileAttributeName  must not contain spaces");
         }
         this.configFileValue = (0 : UInt);
         this.dbValue = (0 : UInt);
         this.cliValue = (0 : UInt);
         this.overrideValue = (0 : UInt);
      }
      
      public static function featureFlagFactory(param1:String, param2:Bool, param3:String = null, param4:String = null) : FeatureFlag
      {
         return new FeatureFlag(param1,param2,param3,param4);
      }
      
      public function setConfigFileValue(param1:Bool) 
      {
         this.configFileValue = (param1 ? (2 : UInt) : (1 : UInt) : UInt);
         this.updateCurrentValue();
      }
      
      public function setDbValue(param1:Bool) 
      {
         this.dbValue = (param1 ? (2 : UInt) : (1 : UInt) : UInt);
         this.updateCurrentValue();
      }
      
      public function setCliValue(param1:Bool) 
      {
         this.cliValue = (param1 ? (2 : UInt) : (1 : UInt) : UInt);
         this.updateCurrentValue();
      }
      
      public function setOverrideValue(param1:Bool) 
      {
         this.overrideValue = (param1 ? (2 : UInt) : (1 : UInt) : UInt);
         this.updateCurrentValue();
      }
      
      public function updateCurrentValue() 
      {
         if(this.overrideValue != 0)
         {
            this._currentValue = this.overrideValue == 2;
            return;
         }
         if(this.cliValue != 0)
         {
            this._currentValue = this.cliValue == 2;
            return;
         }
         if(this.dbValue != 0)
         {
            this._currentValue = this.dbValue == 2;
            return;
         }
         if(this.configFileValue != 0)
         {
            this._currentValue = this.configFileValue == 2;
            return;
         }
      }
      
      @:isVar public var currentValue(get,never):Bool;
public function  get_currentValue() : Bool
      {
         return _currentValue;
      }
      
      @:isVar public var commandLineFlag(get,never):String;
public function  get_commandLineFlag() : String
      {
         return _commandLineFlag;
      }
      
      @:isVar public var configFileAttributeName(get,never):String;
public function  get_configFileAttributeName() : String
      {
         return _configFileAttributeName;
      }
   }


