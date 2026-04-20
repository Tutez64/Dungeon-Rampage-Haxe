package steamInput
;
   import com.amanitadesign.steam.FRESteamWorks;
   import com.amanitadesign.steam.InputAnalogActionData;
   import com.amanitadesign.steam.InputDigitalActionData;
   import flash.geom.Vector3D;
   
    class SteamController
   {
      
      public var controllerHandle:String;
      
      var mIsConnected:Bool = false;
      
      var mInGameControlsActionSet:SteamInputActionSet;
      
      var mMenuControlsActionSet:SteamInputActionSet;
      
      var mAnalogActionsNamesToVector3D:ASDictionary<ASAny,ASAny> = new ASDictionary();
      
      var mPressedDigitalButtons:ASDictionary<ASAny,ASAny> = new ASDictionary();
      
      var mReleasedDigitalButtons:ASDictionary<ASAny,ASAny> = new ASDictionary();
      
      var mHeldDigitalButtons:ASDictionary<ASAny,ASAny> = new ASDictionary();
      
      public function new(param1:String, param2:SteamInputActionSet, param3:SteamInputActionSet)
      {
         
         controllerHandle = param1;
         mInGameControlsActionSet = param2;
         mMenuControlsActionSet = param3;
         mIsConnected = false;
      }
      
      @:isVar public var analogInputs(get,never):ASDictionary<ASAny,ASAny>;
public function  get_analogInputs() : ASDictionary<ASAny,ASAny>
      {
         return mAnalogActionsNamesToVector3D;
      }
      
      @:isVar public var pressedDigitalButtons(get,never):ASDictionary<ASAny,ASAny>;
public function  get_pressedDigitalButtons() : ASDictionary<ASAny,ASAny>
      {
         return mPressedDigitalButtons;
      }
      
      @:isVar public var releasedDigitalButtons(get,never):ASDictionary<ASAny,ASAny>;
public function  get_releasedDigitalButtons() : ASDictionary<ASAny,ASAny>
      {
         return mReleasedDigitalButtons;
      }
      
      @:isVar public var heldDigitalButtons(get,never):ASDictionary<ASAny,ASAny>;
public function  get_heldDigitalButtons() : ASDictionary<ASAny,ASAny>
      {
         return mHeldDigitalButtons;
      }
      
            
      @:isVar public var isConnected(get,set):Bool;
public function  set_isConnected(param1:Bool) :Bool      {
         return mIsConnected = param1;
      }
function  get_isConnected() : Bool
      {
         return mIsConnected;
      }
      
      public function flushInput() 
      {
         clearInputDictionary(mAnalogActionsNamesToVector3D);
         clearInputDictionary(mPressedDigitalButtons);
         clearInputDictionary(mReleasedDigitalButtons);
      }
      
      public function handleDisconnect() 
      {
         flushInput();
      }
      
      public function readInput(param1:FRESteamWorks) 
      {
         readAnalogActions(param1);
         readDigitalActions(param1);
      }
      
      function clearInputDictionary(param1:ASDictionary<ASAny,ASAny>) 
      {
         var _loc2_:ASAny;
         if (checkNullIteratee(param1)) for(_tmp_ in param1.keys())
         {
            _loc2_ = _tmp_;
            param1.remove(_loc2_);
         }
      }
      
      function readAnalogActions(param1:FRESteamWorks) 
      {
         var _loc4_:InputAnalogActionData = null;
         var _loc2_= mInGameControlsActionSet.analogActionHandles;
         var _loc3_:SteamInputAction;
         if (checkNullIteratee(_loc2_)) for (_tmp_ in _loc2_)
         {
            _loc3_ = _tmp_;
            _loc4_ = param1.getAnalogActionData(controllerHandle,_loc3_.actionHandle);
            mAnalogActionsNamesToVector3D[_loc3_.actionName] = new Vector3D(_loc4_.x,_loc4_.y,0);
         }
      }
      
      function readDigitalActions(param1:FRESteamWorks) 
      {
         var _loc5_:InputDigitalActionData = null;
         var _loc3_= new Vector<SteamInputAction>();
         var _loc6_:SteamInputAction;
         final __ax4_iter_90 = mInGameControlsActionSet.digitalActionHandles;
         if (checkNullIteratee(__ax4_iter_90)) for (_tmp_ in __ax4_iter_90)
         {
            _loc6_ = _tmp_;
            _loc3_.push(_loc6_);
         }
         var _loc2_:SteamInputAction;
         final __ax4_iter_91 = mMenuControlsActionSet.digitalActionHandles;
         if (checkNullIteratee(__ax4_iter_91)) for (_tmp_ in __ax4_iter_91)
         {
            _loc2_ = _tmp_;
            _loc3_.push(_loc2_);
         }
         var _loc4_:SteamInputAction;
         if (checkNullIteratee(_loc3_)) for (_tmp_ in _loc3_)
         {
            _loc4_ = _tmp_;
            _loc5_ = param1.getDigitalActionData(controllerHandle,_loc4_.actionHandle);
            writeDigitalActionState(_loc4_.actionName,_loc5_.bState);
         }
      }
      
      function writeDigitalActionState(param1:String, param2:Bool) 
      {
         if(param2)
         {
            if(!mHeldDigitalButtons.exists(param1 ))
            {
               mPressedDigitalButtons[param1] = true;
               mHeldDigitalButtons[param1] = true;
            }
         }
         else if(mHeldDigitalButtons.exists(param1 ))
         {
            mReleasedDigitalButtons[param1] = true;
            mHeldDigitalButtons.remove(param1);
         }
      }
   }


