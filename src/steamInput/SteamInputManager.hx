package steamInput
;
   import brain.event.EventComponent;
   import brain.logger.Logger;
   import facade.DBFacade;
   import com.amanitadesign.steam.FRESteamWorks;
   import flash.display.Stage;
   import flash.geom.Vector3D;
   
    class SteamInputManager
   {
      
      var mSteamworks:FRESteamWorks;
      
      var mEventComponent:EventComponent;
      
      var mKeyboardEventSpoofer:KeyboardEventSpoofer;
      
      var mIsInitialized:Bool = false;
      
      var mIsSteamInputManagerEnabled:Bool = false;
      
      var mControllerWasConnectedLastUpdate:Bool = false;
      
      var mHandlesToSteamControllers:ASDictionary<ASAny,ASAny> = new ASDictionary();
      
      var mConnectedSteamControllers:Vector<SteamController> = new Vector();
      
      var mInGameControlsActionSet:SteamInputActionSet;
      
      var mMenuControlsActionSet:SteamInputActionSet;
      
      var mUseMenuControlsInsteadOfInGameControls:Bool = true;
      
      var mInputActionNameToControllerGlyphFilePath:ASDictionary<ASAny,ASAny> = new ASDictionary();
      
      final ZERO_VECTOR:Vector3D = new Vector3D(0,0,0);
      
      public function new(param1:DBFacade, param2:FRESteamWorks, param3:Stage, param4:Bool = true)
      {
         
         mSteamworks = param2;
         mIsSteamInputManagerEnabled = param4;
         mEventComponent = new EventComponent(param1);
         mKeyboardEventSpoofer = new KeyboardEventSpoofer(param3);
      }
      
      public function destroy() 
      {
         mConnectedSteamControllers.length = 0;
         var _loc1_:ASAny;
         final __ax4_iter_92 = mHandlesToSteamControllers;
         if (checkNullIteratee(__ax4_iter_92)) for(_tmp_ in __ax4_iter_92.keys())
         {
            _loc1_ = _tmp_;
            mHandlesToSteamControllers.remove(_loc1_);
         }
         mHandlesToSteamControllers = null;
         if(mEventComponent != null)
         {
            mEventComponent.destroy();
            mEventComponent = null;
         }
         mSteamworks.steamInputShutdown();
      }
      
      public function runFrame() 
      {
         if(!mIsSteamInputManagerEnabled)
         {
            return;
         }
         if(!mIsInitialized)
         {
            initSteamInput();
            return;
         }
         mSteamworks.runFrame();
         checkForHardwareChanges();
         updateControllers();
         updateActionOrigins();
         mKeyboardEventSpoofer.update(this);
         fireButtonEvents();
      }
      
      function updateActionOrigins() 
      {
         var _loc3_:String = null;
         if(mConnectedSteamControllers.length <= 0)
         {
            return;
         }
         var _loc1_= new ASDictionary<ASAny,ASAny>();
         var _loc2_:SteamInputAction;
         final __ax4_iter_93 = mMenuControlsActionSet.digitalActionHandles;
         if (checkNullIteratee(__ax4_iter_93)) for (_tmp_ in __ax4_iter_93)
         {
            _loc2_ = _tmp_;
            _loc3_ = getFilePathsOfControllerGlyphsAssignedToMenuControlsDigitalAction(_loc2_.actionName)[0];
            _loc1_[_loc2_.actionName] = _loc3_;
         }
         if(!dictionariesHaveSameContents(mInputActionNameToControllerGlyphFilePath,_loc1_))
         {
            mInputActionNameToControllerGlyphFilePath = _loc1_;
            mEventComponent.dispatchEvent(new SteamInputGlyphsChangedEvent());
         }
      }
      
      public function getFilePathsOfControllerGlyphsAssignedToMenuControlsDigitalAction(param1:String, param2:UInt = (0 : UInt), param3:UInt = (2 : UInt)) : Vector<String>
      {
         var _loc6_:Vector<String> = /*undefined*/null;
         var _loc5_= new Vector<String>();
         _loc6_ = getDigitalActionOriginsAssignedToMenuControlsAction(param1);
         if(_loc6_ == null)
         {
            Logger.warn("menuActionOrigins is null please ensure it\'s loaded properly.");
            return _loc5_;
         }
         var _loc4_:String;
         if (checkNullIteratee(_loc6_)) for (_tmp_ in _loc6_)
         {
            _loc4_ = _tmp_;
            if(_loc4_ == null)
            {
               Logger.warn("origin is null please ensure menuActionOrigins is loaded properly.");
               return _loc5_;
            }
            _loc5_.push(mSteamworks.getGlyphPNGForActionOrigin(_loc4_,(param2 : Int),(param3 : Int)));
         }
         return _loc5_;
      }
      
      public function getGlyphFilePathForAction(param1:String) : String
      {
         return mInputActionNameToControllerGlyphFilePath[param1];
      }
      
      public function flushInputs() 
      {
         var _loc1_:SteamController;
         final __ax4_iter_94 = mConnectedSteamControllers;
         if (checkNullIteratee(__ax4_iter_94)) for (_tmp_ in __ax4_iter_94)
         {
            _loc1_ = _tmp_;
            _loc1_.flushInput();
         }
      }
      
      public function getAnalogAction(param1:String) : Vector3D
      {
         var _loc2_:Vector3D = null;
         var _loc3_:SteamController;
         final __ax4_iter_95 = mConnectedSteamControllers;
         if (checkNullIteratee(__ax4_iter_95)) for (_tmp_ in __ax4_iter_95)
         {
            _loc3_ = _tmp_;
            _loc2_ = ASCompat.dynamicAs(_loc3_.analogInputs[param1], flash.geom.Vector3D);
            if(_loc2_ != null)
            {
               if(_loc2_.lengthSquared > 0)
               {
                  return _loc2_;
               }
            }
         }
         ZERO_VECTOR.setTo(0,0,0);
         return ZERO_VECTOR;
      }
      
      public function fireButtonEvents() 
      {
         var _loc1_:ASAny;
         var __ax4_iter_97:ASAny;
         var _loc2_:ASAny;
         var __ax4_iter_98:ASAny;
         var _loc3_:SteamController;
         final __ax4_iter_96 = mConnectedSteamControllers;
         if (checkNullIteratee(__ax4_iter_96)) for (_tmp_ in __ax4_iter_96)
         {
            _loc3_ = _tmp_;
            __ax4_iter_97 = _loc3_.pressedDigitalButtons;
            if (checkNullIteratee(__ax4_iter_97)) for(_tmp_ in __ax4_iter_97.___keys())
            {
               _loc1_ = _tmp_;
               mEventComponent.dispatchEvent(new OnSteamInputButtonPressedEvent(ASCompat.toString(_loc1_)));
            }
            __ax4_iter_98 = _loc3_.releasedDigitalButtons;
            if (checkNullIteratee(__ax4_iter_98)) for(_tmp_ in __ax4_iter_98.___keys())
            {
               _loc2_ = _tmp_;
               mEventComponent.dispatchEvent(new OnSteamInputButtonReleasedEvent(ASCompat.toString(_loc2_)));
            }
         }
      }
      
      public function pressedAction(param1:String) : Bool
      {
         var _loc2_:SteamController;
         final __ax4_iter_99 = mConnectedSteamControllers;
         if (checkNullIteratee(__ax4_iter_99)) for (_tmp_ in __ax4_iter_99)
         {
            _loc2_ = _tmp_;
            if(_loc2_.pressedDigitalButtons.hasOwnProperty(param1 ))
            {
               return true;
            }
         }
         return false;
      }
      
      public function releasedAction(param1:String) : Bool
      {
         var _loc2_:SteamController;
         final __ax4_iter_100 = mConnectedSteamControllers;
         if (checkNullIteratee(__ax4_iter_100)) for (_tmp_ in __ax4_iter_100)
         {
            _loc2_ = _tmp_;
            if(_loc2_.releasedDigitalButtons.hasOwnProperty(param1 ))
            {
               return true;
            }
         }
         return false;
      }
      
      public function heldAction(param1:String) : Bool
      {
         var _loc2_:SteamController;
         final __ax4_iter_101 = mConnectedSteamControllers;
         if (checkNullIteratee(__ax4_iter_101)) for (_tmp_ in __ax4_iter_101)
         {
            _loc2_ = _tmp_;
            if(_loc2_.heldDigitalButtons.hasOwnProperty(param1 ))
            {
               return true;
            }
         }
         return false;
      }
      
      public function activateInGameActionLayer() 
      {
         mUseMenuControlsInsteadOfInGameControls = false;
      }
      
      public function activateMenuControlsActionLayer() 
      {
         mUseMenuControlsInsteadOfInGameControls = true;
      }
      
      public function getDigitalActionOriginsAssignedToMenuControlsAction(param1:String) : Vector<String>
      {
         var _loc2_:SteamController;
         var __ax4_iter_103:Vector<SteamController>;
         var _loc4_= new Vector<String>();
         if(mMenuControlsActionSet.digitalActionHandles == null || mConnectedSteamControllers == null)
         {
            Logger.warn("SteamInputManager: digitalActionHandles or connectedSteamControllers is null. Unable to getDigitalActionOriginsAssignedToMenuControlsAction.");
            return _loc4_;
         }
         var _loc3_:SteamInputAction;
         final __ax4_iter_102 = mMenuControlsActionSet.digitalActionHandles;
         if (checkNullIteratee(__ax4_iter_102)) for (_tmp_ in __ax4_iter_102)
         {
            _loc3_ = _tmp_;
            if(_loc3_.actionName == param1)
            {
               __ax4_iter_103 = mConnectedSteamControllers;
               if (checkNullIteratee(__ax4_iter_103)) for (_tmp_ in __ax4_iter_103)
               {
                  _loc2_ = _tmp_;
                  _loc4_.push(ASCompat.toString(mSteamworks.getDigitalActionOrigins(_loc2_.controllerHandle,mMenuControlsActionSet.actionSetHandle,_loc3_.actionHandle)));
               }
            }
         }
         return _loc4_;
      }
      
      @:isVar public var isUsingMenuControlsInsteadOfInGameControls(get,never):Bool;
public function  get_isUsingMenuControlsInsteadOfInGameControls() : Bool
      {
         return mUseMenuControlsInsteadOfInGameControls;
      }
      
      @:isVar public var isSteamControllerConnected(get,never):Bool;
public function  get_isSteamControllerConnected() : Bool
      {
         return mSteamworks.isReady && mSteamworks.getConnectedControllers().length > 0;
      }
      
      function initSteamInput() 
      {
         if(!mSteamworks.isReady)
         {
            return;
         }
         var _loc1_= mSteamworks.inputInit();
         if(!_loc1_)
         {
            Logger.info("SteamInputManager: Steamworks inputInit failed");
            return;
         }
         mIsInitialized = true;
         Logger.info("SteamInputManager: Steam Input initialized.");
      }
      
      function checkForHardwareChanges() 
      {
         resetControllerConnectedStates();
         updateOrCreateConnectedControllers();
         removeDisconnectedControllers();
         if(mControllerWasConnectedLastUpdate != isSteamControllerConnected)
         {
            mEventComponent.dispatchEvent(new ControllerConnectionChangedEvent(isSteamControllerConnected));
            mControllerWasConnectedLastUpdate = isSteamControllerConnected;
         }
      }
      
      function dictionariesHaveSameContents(param1:ASDictionary<ASAny,ASAny>, param2:ASDictionary<ASAny,ASAny>) : Bool
      {
         if(param1["length"] != param2["length"])
         {
            return false;
         }
         var _loc3_:ASAny;
         if (checkNullIteratee(param1)) for(_tmp_ in param1.keys())
         {
            _loc3_ = _tmp_;
            if(param1[_loc3_] != param2[_loc3_])
            {
               return false;
            }
         }
         return true;
      }
      
      function resetControllerConnectedStates() 
      {
         var _loc1_:SteamController;
         final __ax4_iter_104 = mConnectedSteamControllers;
         if (checkNullIteratee(__ax4_iter_104)) for (_tmp_ in __ax4_iter_104)
         {
            _loc1_ = _tmp_;
            ASCompat.setProperty(_loc1_, "isConnected", false);
         }
      }
      
      function updateOrCreateConnectedControllers() 
      {
         var _loc2_:SteamController = null;
         var _loc1_= mSteamworks.getConnectedControllers();
         if(!tryLazyLoadInGameActionSet(_loc1_))
         {
            return;
         }
         if(!tryLazyLoadMenuControlsActionSet(_loc1_))
         {
            return;
         }
         var _loc3_:ASAny;
         if (checkNullIteratee(_loc1_)) for (_tmp_ in _loc1_)
         {
            _loc3_ = _tmp_;
            _loc2_ = ASCompat.dynamicAs(mHandlesToSteamControllers[_loc3_], steamInput.SteamController);
            if(_loc2_ == null)
            {
               _loc2_ = new SteamController(_loc3_,mInGameControlsActionSet,mMenuControlsActionSet);
               mHandlesToSteamControllers[_loc3_] = _loc2_;
            }
            if(mConnectedSteamControllers.indexOf(_loc2_) == -1)
            {
               mConnectedSteamControllers.push(_loc2_);
            }
            _loc2_.isConnected = true;
            if(mUseMenuControlsInsteadOfInGameControls)
            {
               mSteamworks.activateActionSet(_loc2_.controllerHandle,mMenuControlsActionSet.actionSetHandle);
            }
            else
            {
               mSteamworks.activateActionSet(_loc2_.controllerHandle,mInGameControlsActionSet.actionSetHandle);
            }
         }
      }
      
      function tryLazyLoadMenuControlsActionSet(param1:Array<ASAny>) : Bool
      {
         if(mMenuControlsActionSet != null)
         {
            return true;
         }
         var _loc2_= tryLoadActionSet("MenuControls",param1);
         if(_loc2_ == null)
         {
            return false;
         }
         mMenuControlsActionSet = _loc2_;
         return true;
      }
      
      function tryLazyLoadInGameActionSet(param1:Array<ASAny>) : Bool
      {
         if(mInGameControlsActionSet != null)
         {
            return true;
         }
         var _loc2_= tryLoadActionSet("InGameControls",param1);
         if(_loc2_ == null)
         {
            return false;
         }
         mInGameControlsActionSet = _loc2_;
         return true;
      }
      
      function tryLoadActionSet(param1:String, param2:Array<ASAny>) : SteamInputActionSet
      {
         if(param2.length == 0)
         {
            return null;
         }
         var _loc4_= mSteamworks.getActionSetHandle(param1);
         if(_loc4_ == "0")
         {
            Logger.warn("SteamInputManager: Couldn\'t load actionSet \'" + param1 + "\'");
            return null;
         }
         var _loc6_= new SteamInputActionSet(param1,_loc4_);
         var _loc3_= false;
         var _loc5_= false;
         if(param1 == "InGameControls")
         {
            _loc3_ = _loc6_.tryLoadAnalogActions(InGameControlsActionSetData.gatherAnalogActionNames(),mSteamworks);
            _loc5_ = _loc6_.tryLoadDigitalActions(InGameControlsActionSetData.gatherDigitalActionNames(),mSteamworks);
         }
         if(param1 == "MenuControls")
         {
            _loc3_ = _loc6_.tryLoadAnalogActions(MenuControlsActionSetData.gatherAnalogActionNames(),mSteamworks);
            _loc5_ = _loc6_.tryLoadDigitalActions(MenuControlsActionSetData.gatherDigitalActionNames(),mSteamworks);
         }
         if(!_loc3_ || !_loc5_)
         {
            Logger.warn("SteamInputManager: Couldn\'t load actionSet actions for \'" + param1 + "\'");
            return null;
         }
         return _loc6_;
      }
      
      function removeDisconnectedControllers() 
      {
         var _loc1_= 0;
         var _loc2_:SteamController = null;
         _loc1_ = mConnectedSteamControllers.length - 1;
         while(_loc1_ >= 0)
         {
            _loc2_ = mConnectedSteamControllers[_loc1_];
            if(!_loc2_.isConnected)
            {
               _loc2_.handleDisconnect();
               mConnectedSteamControllers.removeAt(_loc1_);
            }
            _loc1_--;
         }
      }
      
      function updateControllers() 
      {
         var _loc1_:SteamController;
         final __ax4_iter_105 = mConnectedSteamControllers;
         if (checkNullIteratee(__ax4_iter_105)) for (_tmp_ in __ax4_iter_105)
         {
            _loc1_ = _tmp_;
            _loc1_.readInput(mSteamworks);
         }
      }
   }


