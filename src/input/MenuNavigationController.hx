package input
;
   import brain.event.EventComponent;
   import brain.input.*;
   import brain.logger.Logger;
   import brain.uI.UIObject;
   import facade.DBFacade;
   import steamInput.OnSteamInputButtonPressedEvent;
   import steamInput.SteamInputManager;
   
    class MenuNavigationController
   {
      
      static inline final MAX_NAVIGATION_ITERATIONS= (100 : UInt);
      
      var mTopLayer:UInt = (0 : UInt);
      
      var mUILayerConstants:Array<ASAny> = [];
      
      var mSelectedUIObjs:ASDictionary<ASAny,ASAny> = new ASDictionary();
      
      var mDefaultUIObjs:ASDictionary<ASAny,ASAny> = new ASDictionary();
      
      var mLayerExitCallbacks:ASDictionary<ASAny,ASAny> = new ASDictionary();
      
      var mSteamInputActionsToKeyCodes:ASDictionary<ASAny,ASAny> = new ASDictionary();
      
      var mDBFacade:DBFacade;
      
      var mSteamInputManager:SteamInputManager;
      
      var mEventComponent:EventComponent;
      
      public function new(param1:DBFacade)
      {
         
         mDBFacade = param1;
         mDBFacade.inputManager.registerMenuNavigationCallback(onKeyPressed);
         mSteamInputManager = mDBFacade.steamInputManager;
         mEventComponent = new EventComponent(mDBFacade);
         mEventComponent.addListener("OnSteamInputButtonPressedEvent",onSteamInputButtonPressed);
         mSteamInputActionsToKeyCodes["menu_left"] = 37;
         mSteamInputActionsToKeyCodes["menu_right"] = 39;
         mSteamInputActionsToKeyCodes["menu_up"] = 38;
         mSteamInputActionsToKeyCodes["menu_down"] = 40;
         mSteamInputActionsToKeyCodes["menu_select"] = 13;
         mSteamInputActionsToKeyCodes["menu_cancel"] = 27;
      }
      
      public function getTopUILayer() : String
      {
         return mUILayerConstants[(mTopLayer : Int)];
      }
      
      public function pushNewLayer(param1:String, param2:ASFunction, param3:UIObject, param4:UIObject = null) 
      {
         if(ASCompat.toBool(mDefaultUIObjs[param1]) || ASCompat.toBool(mSelectedUIObjs[param1]) || mUILayerConstants.indexOf(param1) != -1)
         {
            Logger.warn("Layer constant " + param1 + " already exists in the UI Manager");
            return;
         }
         Logger.debugch("UI","Pushing layer: " + param1 + " (Current Layers: " + getAllCurrentLayers() + ")");
         if(mFocusedUiObject != null)
         {
            mFocusedUiObject.setFocused(false);
         }
         mTopLayer = mTopLayer + 1;
         mUILayerConstants[(mTopLayer : Int)] = param1;
         mLayerExitCallbacks[param1] = param2;
         mDefaultUIObjs[param1] = param3;
         if(param4 != null)
         {
            setFocusedUiObject(param4);
         }
         else
         {
            setFocusedUiObject(param3);
         }
         mDBFacade.steamInputManager.activateMenuControlsActionLayer();
      }
      
      public function popLayer(param1:String) 
      {
         if(param1 == null)
         {
            param1 = mUILayerConstants[(mTopLayer : Int)];
         }
         Logger.debugch("UI","Popping layer: " + param1 + "(Current Layers: " + getAllCurrentLayers() + ")");
         if(mTopLayer == 0)
         {
            Logger.warn("No layers to pop");
            return;
         }
         if(mUILayerConstants[(mTopLayer : Int)] != param1)
         {
            Logger.warn("You tried to pop a layer that wasn\'t currently the top one. Layer attempted to be popped (Layerconstant): " + param1 + " Actual Current Top Layer: " + Std.string(mUILayerConstants[(mTopLayer : Int)]));
            return;
         }
         mDefaultUIObjs.remove(param1);
         mSelectedUIObjs.remove(param1);
         mLayerExitCallbacks.remove(param1);
         mUILayerConstants.pop();
         mTopLayer = mTopLayer - 1;
         if(mTopLayer == 0)
         {
            mFocusedUiObject = null;
            mDBFacade.steamInputManager.activateInGameActionLayer();
            return;
         }
         if(ASCompat.dictionaryLookupNeNull(mSelectedUIObjs, mUILayerConstants[(mTopLayer : Int)]))
         {
            setFocusedUiObject(ASCompat.dynamicAs(mSelectedUIObjs[mUILayerConstants[(mTopLayer : Int)]], brain.uI.UIObject));
         }
         else
         {
            setFocusedUiObject(ASCompat.dynamicAs(mDefaultUIObjs[mUILayerConstants[(mTopLayer : Int)]], brain.uI.UIObject));
         }
      }
      
      public function getAllCurrentLayers() : String
      {
         var _loc2_= 0;
         var _loc1_= "";
         _loc2_ = 1;
         while(_loc2_ < mUILayerConstants.length)
         {
            _loc1_ += Std.string(mUILayerConstants[_loc2_]) + ", ";
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function setFocusedUiObject(param1:UIObject) 
      {
         if(mTopLayer == 0)
         {
            Logger.warn("There\'s no UI Layer for you to set a Focused UIObject on because top layer is 0!");
            return;
         }
         if(param1 == null)
         {
            Logger.warn("Cannot focus on a null UIObject");
            return;
         }
         if(mFocusedUiObject != param1)
         {
            if(mFocusedUiObject != null)
            {
               mFocusedUiObject.setFocused(false);
            }
            param1.setFocused(true);
            mFocusedUiObject = param1;
         }
         else if(!mFocusedUiObject.isFocused())
         {
            mFocusedUiObject.setFocused(true);
         }
      }

      public function replaceLayerUIObjects(param1:String, param2:UIObject, param3:UIObject = null) 
      {
         var layerConstant= param1;
         var defaultUiObject= param2;
         var selectedUiObject= param3;
         if(layerConstant == null || mUILayerConstants.indexOf(layerConstant) == -1)
         {
            Logger.warn("Cannot replace UI objects for a layer that does not exist: " + Std.string(layerConstant));
            return;
         }
         mDefaultUIObjs[layerConstant] = defaultUiObject;
         mSelectedUIObjs[layerConstant] = selectedUiObject != null ? selectedUiObject : defaultUiObject;
      }
      
            
      @:isVar var mFocusedUiObject(get,set):UIObject;
function  get_mFocusedUiObject() : UIObject
      {
         return ASCompat.dynamicAs(mSelectedUIObjs[mUILayerConstants[(mTopLayer : Int)]], brain.uI.UIObject);
      }
function  set_mFocusedUiObject(param1:UIObject) :UIObject      {
         mSelectedUIObjs[mUILayerConstants[(mTopLayer : Int)]] = param1;
return param1;
      }
      
      public function getNextAvailableNavLeftObject() : UIObject
      {
         var _loc1_= mFocusedUiObject.leftNavigation;
         var _loc2_= (0 : UInt);
         while(_loc1_ != null && !_loc1_.canBeFocused())
         {
            if(++_loc2_ >= 100)
            {
               Logger.warn("Menu navigation infinite loop detected traversing LEFT from layer: " + getTopUILayer() + " (Current Layers: " + getAllCurrentLayers() + ")");
               return mFocusedUiObject;
            }
            _loc1_ = _loc1_.leftNavigation;
         }
         if(_loc1_ != null)
         {
            return _loc1_;
         }
         return mFocusedUiObject;
      }
      
      public function getNextAvailableNavRightObject() : UIObject
      {
         var _loc1_= mFocusedUiObject.rightNavigation;
         var _loc2_= (0 : UInt);
         while(_loc1_ != null && !_loc1_.canBeFocused())
         {
            if(++_loc2_ >= 100)
            {
               Logger.warn("Menu navigation infinite loop detected traversing RIGHT from layer: " + getTopUILayer() + " (Current Layers: " + getAllCurrentLayers() + ")");
               return mFocusedUiObject;
            }
            _loc1_ = _loc1_.rightNavigation;
         }
         if(_loc1_ != null)
         {
            return _loc1_;
         }
         return mFocusedUiObject;
      }
      
      public function getNextAvailableNavUpObject() : UIObject
      {
         var _loc1_= mFocusedUiObject.upNavigation;
         var _loc2_= (0 : UInt);
         while(_loc1_ != null && !_loc1_.canBeFocused())
         {
            if(++_loc2_ >= 100)
            {
               Logger.warn("Menu navigation infinite loop detected traversing UP from layer: " + getTopUILayer() + " (Current Layers: " + getAllCurrentLayers() + ")");
               return mFocusedUiObject;
            }
            _loc1_ = _loc1_.upNavigation;
         }
         if(_loc1_ != null)
         {
            return _loc1_;
         }
         return mFocusedUiObject;
      }
      
      public function getNextAvailableNavDownObject() : UIObject
      {
         var _loc1_= mFocusedUiObject.downNavigation;
         var _loc2_= (0 : UInt);
         while(_loc1_ != null && !_loc1_.canBeFocused())
         {
            if(++_loc2_ >= 100)
            {
               Logger.warn("Menu navigation infinite loop detected traversing DOWN from layer: " + getTopUILayer() + " (Current Layers: " + getAllCurrentLayers() + ")");
               return mFocusedUiObject;
            }
            _loc1_ = _loc1_.downNavigation;
         }
         if(_loc1_ != null)
         {
            return _loc1_;
         }
         return mFocusedUiObject;
      }
      
      function onSteamInputButtonPressed(param1:OnSteamInputButtonPressedEvent) 
      {
         var _loc2_:ASAny;
         final __ax4_iter_131 = mSteamInputActionsToKeyCodes;
         if (checkNullIteratee(__ax4_iter_131)) for(_tmp_ in __ax4_iter_131.keys())
         {
            _loc2_ = _tmp_;
            if(mSteamInputManager.pressedAction(_loc2_))
            {
               onKeyPressed(ASCompat.toInt(mSteamInputActionsToKeyCodes[_loc2_]));
            }
         }
      }
      
      public function onKeyPressed(param1:Int) 
      {
         var _loc2_:UIObject = null;
         if(mFocusedUiObject != null)
         {
            _loc2_ = null;
            if(param1 == 37)
            {
               _loc2_ = getNextAvailableNavLeftObject();
               if(_loc2_ != null)
               {
                  if(ASCompat.toBool(mFocusedUiObject.leftNavigationAdditionalInteraction))
                  {
                     mFocusedUiObject.leftNavigationAdditionalInteraction();
                  }
                  if(ASCompat.toBool(mFocusedUiObject.navigationSetToUnselectedInteraction))
                  {
                     mFocusedUiObject.navigationSetToUnselectedInteraction();
                  }
                  setFocusedUiObject(_loc2_);
                  if(ASCompat.toBool(mFocusedUiObject.navigationSelectedInteraction))
                  {
                     mFocusedUiObject.navigationSelectedInteraction();
                  }
               }
            }
            else if(param1 == 39)
            {
               _loc2_ = getNextAvailableNavRightObject();
               if(_loc2_ != null)
               {
                  if(ASCompat.toBool(mFocusedUiObject.rightNavigationAdditionalInteraction))
                  {
                     mFocusedUiObject.rightNavigationAdditionalInteraction();
                  }
                  if(ASCompat.toBool(mFocusedUiObject.navigationSetToUnselectedInteraction))
                  {
                     mFocusedUiObject.navigationSetToUnselectedInteraction();
                  }
                  setFocusedUiObject(_loc2_);
                  if(ASCompat.toBool(mFocusedUiObject.navigationSelectedInteraction))
                  {
                     mFocusedUiObject.navigationSelectedInteraction();
                  }
               }
            }
            else if(param1 == 38)
            {
               _loc2_ = getNextAvailableNavUpObject();
               if(_loc2_ != null)
               {
                  if(ASCompat.toBool(mFocusedUiObject.upNavigationAdditionalInteraction))
                  {
                     mFocusedUiObject.upNavigationAdditionalInteraction();
                  }
                  if(ASCompat.toBool(mFocusedUiObject.navigationSetToUnselectedInteraction))
                  {
                     mFocusedUiObject.navigationSetToUnselectedInteraction();
                  }
                  setFocusedUiObject(_loc2_);
                  if(ASCompat.toBool(mFocusedUiObject.navigationSelectedInteraction))
                  {
                     mFocusedUiObject.navigationSelectedInteraction();
                  }
               }
            }
            else if(param1 == 40)
            {
               _loc2_ = getNextAvailableNavDownObject();
               if(_loc2_ != null)
               {
                  if(ASCompat.toBool(mFocusedUiObject.downNavigationAdditionalInteraction))
                  {
                     mFocusedUiObject.downNavigationAdditionalInteraction();
                  }
                  if(ASCompat.toBool(mFocusedUiObject.navigationSetToUnselectedInteraction))
                  {
                     mFocusedUiObject.navigationSetToUnselectedInteraction();
                  }
                  setFocusedUiObject(_loc2_);
                  if(ASCompat.toBool(mFocusedUiObject.navigationSelectedInteraction))
                  {
                     mFocusedUiObject.navigationSelectedInteraction();
                  }
               }
            }
            else if(param1 == 13)
            {
               if(mFocusedUiObject.enabled && mFocusedUiObject.visible)
               {
                  mFocusedUiObject.onSelected();
               }
               else
               {
                  Logger.debugch("UI","Attempted to press UIObject when it was not enabled or visible (Enabled: " + Std.string(mFocusedUiObject.enabled) + " Visible: " + Std.string(mFocusedUiObject.visible) + ")");
               }
            }
            else if(param1 == 27)
            {
               if(ASCompat.toBool(mLayerExitCallbacks[mUILayerConstants[(mTopLayer : Int)]]))
               {
                  mLayerExitCallbacks[mUILayerConstants[(mTopLayer : Int)]]();
               }
            }
         }
      }
   }


