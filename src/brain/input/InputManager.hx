package brain.input
;
   import brain.facade.Facade;
   import brain.logger.Logger;
   import brain.mouseScrollPlugin.CustomMouseWheelEvent;
   import brain.utils.MemoryTracker;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   
    class InputManager
   {
      
      var mEnabled:Bool = false;
      
      var mKeysDown:Vector<Bool> = new Vector((256 : UInt));
      
      var mNumberOfKeysDown:Int = 0;
      
      var mKeysPressed:Vector<Int> = new Vector((256 : UInt));
      
      var mKeysReleased:Vector<Int> = new Vector((256 : UInt));
      
      var mNumberOfKeysPressed:Int = 0;
      
      var mNumberOfKeysReleased:Int = 0;
      
      var mMouseWheelDelta:Int = 0;
      
      public var lastKey:Int = 0;
      
      public var mouseDown:Bool = false;
      
      public var mouseUp:Bool = true;
      
      public var mousePressed:Bool = false;
      
      public var mouseReleased:Bool = false;
      
      public var mouseWheel:Bool = false;
      
      var mFacade:Facade;
      
      public var disableInputs:Bool = false;
      
      var menuNavigationCallback:ASFunction;
      
      public function new(param1:Facade)
      {
         
         mFacade = param1;
         MemoryTracker.track(mKeysDown,"Vector.<Boolean> - keys down state in InputManager()","brain");
         MemoryTracker.track(mKeysPressed,"Vector.<int> - keys pressed in InputManager()","brain");
         MemoryTracker.track(mKeysReleased,"Vector.<int> - keys released in InputManager()","brain");
         enable();
      }
      
      public function registerMenuNavigationCallback(param1:ASFunction) 
      {
         menuNavigationCallback = param1;
      }
      
      public function unregisterKeyPressedCallback(param1:ASAny) 
      {
         if(ASCompat.toBool(menuNavigationCallback))
         {
            menuNavigationCallback = null;
            return;
         }
         Logger.warn("Unregistering MenuNavigation shouldn\'t have an empty callback");
      }
      
      @:isVar public var mouseWheelDelta(get,never):Int;
public function  get_mouseWheelDelta() : Int
      {
         if(mouseWheel)
         {
            mouseWheel = false;
            return mMouseWheelDelta;
         }
         return 0;
      }
      
      @:isVar public var mouseX(get,never):Int;
public function  get_mouseX() : Int
      {
         return Std.int(mFacade.stageRef.mouseX);
      }
      
      @:isVar public var mouseY(get,never):Int;
public function  get_mouseY() : Int
      {
         return Std.int(mFacade.stageRef.mouseY);
      }
      
      @:isVar public var mouseFlashX(get,never):Int;
public function  get_mouseFlashX() : Int
      {
         return Std.int(mFacade.stageRef.mouseX);
      }
      
      @:isVar public var mouseFlashY(get,never):Int;
public function  get_mouseFlashY() : Int
      {
         return Std.int(mFacade.stageRef.mouseY);
      }
      
      public function check(param1:ASAny) : Bool
      {
         return ASCompat.toNumber(param1) < 0 ? mNumberOfKeysDown > 0 : mKeysDown[ASCompat.toInt(param1)];
      }
      
      public function pressed(param1:ASAny) : Bool
      {
         return ASCompat.toBool(ASCompat.toNumber(param1) < 0 ? mNumberOfKeysPressed != 0 : mKeysPressed.indexOf(ASCompat.toInt(param1)) >= 0);
      }
      
      public function released(param1:ASAny) : Bool
      {
         return ASCompat.toBool(ASCompat.toNumber(param1) < 0 ? mNumberOfKeysReleased != 0 : mKeysReleased.indexOf(ASCompat.toInt(param1)) >= 0);
      }
      
      function enable() 
      {
         mFacade.stageRef.addEventListener("keyDown",onKeyDown);
         mFacade.stageRef.addEventListener("keyUp",onKeyUp);
         mFacade.stageRef.addEventListener("mouseDown",onMouseDown);
         mFacade.stageRef.addEventListener("mouseUp",onMouseUp);
         mFacade.stageRef.addEventListener("onMove",onMouseWheel);
         mFacade.stageRef.addEventListener("mouseLeave",onMouseLeave);
         mFacade.stageRef.addEventListener("deactivate",onDeactivate);
      }
      
      public function flush() 
      {
         while(mNumberOfKeysPressed-- != 0)
         {
            mKeysPressed[mNumberOfKeysPressed] = -1;
         }
         mNumberOfKeysPressed = 0;
         while(mNumberOfKeysReleased-- != 0)
         {
            mKeysReleased[mNumberOfKeysReleased] = -1;
         }
         mNumberOfKeysReleased = 0;
         mousePressed = false;
         mouseReleased = false;
      }
      
      public function clear() 
      {
         flush();
         var _loc1_= mKeysDown.length;
         while(_loc1_-- != 0)
         {
            mKeysDown[_loc1_] = false;
         }
         mNumberOfKeysDown = 0;
      }
      
      function onKeyDown(param1:KeyboardEvent = null) 
      {
         var _loc2_= 0;
         if(!disableInputs)
         {
            _loc2_ = lastKey = (param1.keyCode : Int);
            if(!mKeysDown[_loc2_])
            {
               mKeysDown[_loc2_] = true;
               mNumberOfKeysDown = mNumberOfKeysDown + 1;
               mKeysPressed[mNumberOfKeysPressed++] = _loc2_;
            }
            if(ASCompat.toBool(menuNavigationCallback))
            {
               menuNavigationCallback(_loc2_);
            }
         }
      }
      
      function onKeyUp(param1:KeyboardEvent) 
      {
         var _loc2_= 0;
         if(!disableInputs)
         {
            _loc2_ = param1.keyCode;
            if(mKeysDown[_loc2_])
            {
               mKeysDown[_loc2_] = false;
               mNumberOfKeysDown = mNumberOfKeysDown - 1;
               mKeysReleased[mNumberOfKeysReleased++] = _loc2_;
            }
         }
      }
      
      function onDeactivate(param1:Event) 
      {
         clear();
      }
      
      function onMouseLeave(param1:Event) 
      {
         clear();
      }
      
      public function onMouseDown(param1:MouseEvent) 
      {
         if(!disableInputs)
         {
            mouseDown = true;
            mouseUp = false;
            mousePressed = true;
         }
      }
      
      public function onMouseUp(param1:MouseEvent) 
      {
         if(!disableInputs)
         {
            mouseUp = true;
            mouseDown = false;
            mouseReleased = true;
         }
      }
      
      function onMouseWheel(param1:CustomMouseWheelEvent) 
      {
         if(!disableInputs)
         {
            mouseWheel = true;
            mMouseWheelDelta = param1.delta;
         }
      }
      
      public function enableControls() 
      {
         clear();
         disableInputs = false;
      }
      
      public function disableControls() 
      {
         clear();
         disableInputs = true;
      }
   }


