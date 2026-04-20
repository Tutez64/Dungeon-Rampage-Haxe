package steamInput
;
   import com.amanitadesign.steam.FRESteamWorks;
   
    class SteamInputActionSet
   {
      
      public var actionSetName:String;
      
      public var actionSetHandle:String;
      
      var mAnalogActions:Vector<SteamInputAction>;
      
      var mDigitalActions:Vector<SteamInputAction>;
      
      public function new(param1:String, param2:String)
      {
         
         actionSetName = param1;
         actionSetHandle = param2;
      }
      
      @:isVar public var analogActionHandles(get,never):Vector<SteamInputAction>;
public function  get_analogActionHandles() : Vector<SteamInputAction>
      {
         return mAnalogActions;
      }
      
      @:isVar public var digitalActionHandles(get,never):Vector<SteamInputAction>;
public function  get_digitalActionHandles() : Vector<SteamInputAction>
      {
         return mDigitalActions;
      }
      
      public function tryLoadAnalogActions(param1:Vector<String>, param2:FRESteamWorks) : Bool
      {
         var _loc4_= tryLoadActionHandles(param1,false,param2);
         var _loc3_= validateSteamInputActions(_loc4_);
         if(!_loc3_)
         {
            return false;
         }
         mAnalogActions = _loc4_;
         return true;
      }
      
      public function tryLoadDigitalActions(param1:Vector<String>, param2:FRESteamWorks) : Bool
      {
         var _loc4_= tryLoadActionHandles(param1,true,param2);
         var _loc3_= validateSteamInputActions(_loc4_);
         if(!_loc3_)
         {
            return false;
         }
         mDigitalActions = _loc4_;
         return true;
      }
      
      function tryLoadActionHandles(param1:Vector<String>, param2:Bool, param3:FRESteamWorks) : Vector<SteamInputAction>
      {
         var _loc6_:String = null;
         var _loc4_:SteamInputAction = null;
         var _loc5_= new Vector<SteamInputAction>();
         var _loc7_:String;
         if (checkNullIteratee(param1)) for (_tmp_ in param1)
         {
            _loc7_ = _tmp_;
            if(param2)
            {
               _loc6_ = param3.getDigitalActionHandle(_loc7_);
            }
            else
            {
               _loc6_ = param3.getAnalogActionHandle(_loc7_);
            }
            _loc4_ = new SteamInputAction(_loc7_,_loc6_);
            _loc5_.push(_loc4_);
         }
         return _loc5_;
      }
      
      function validateSteamInputActions(param1:Vector<SteamInputAction>) : Bool
      {
         var _loc2_:SteamInputAction;
         if (checkNullIteratee(param1)) for (_tmp_ in param1)
         {
            _loc2_ = _tmp_;
            if(_loc2_.actionHandle == "0")
            {
               return false;
            }
         }
         return true;
      }
   }


