package brain.mouseScrollPlugin
;
   import flash.display.InteractiveObject;
   import flash.display.Stage;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   
    class MouseWheelEnabler
   {
      
      static var initialised:Bool = false;
      
      static var currentItem:InteractiveObject;
      
      static var browserMouseEvent:MouseEvent;
      
      static var lastEventTime:UInt = (0 : UInt);
      
      public static var useRawValues:Bool = false;
      
      public static var eventTimeout:Float = 50;
      
      public function new()
      {
         
      }
      
      public static function init(param1:Stage, param2:Bool = false) 
      {
         if(!initialised)
         {
            initialised = true;
            registerListenerForMouseMove(param1);
            registerJS();
         }
         useRawValues = param2;
      }
      
      static function registerListenerForMouseMove(param1:Stage) 
      {
         var stage= param1;
         stage.addEventListener("mouseMove",function(param1:MouseEvent)
         {
            currentItem = cast(param1.target, InteractiveObject);
            browserMouseEvent = param1;
         });
      }
      
      static function registerJS() 
      {
         var id:String;
         if(ExternalInterface.available)
         {
            id = "mws_" + Math.ffloor(Math.random() * 1000000);
            ExternalInterface.addCallback(id,function()
            {
            });
            ExternalInterface.call("mws.InitMouseWheelSupport",id);
            ExternalInterface.addCallback("externalMouseEvent",handleExternalMouseEvent);
         }
      }
      
      static function handleExternalMouseEvent(param1:Float, param2:Float) 
      {
         var _loc4_= Math.NaN;
         var _loc3_= (flash.Lib.getTimer() : UInt);
         if(_loc3_ >= eventTimeout + lastEventTime)
         {
            if(useRawValues)
            {
               _loc4_ = param1;
            }
            else
            {
               _loc4_ = param2;
            }
            if(currentItem != null && browserMouseEvent != null)
            {
               currentItem.dispatchEvent(new CustomMouseWheelEvent("onMove",true,false,browserMouseEvent.localX,browserMouseEvent.localY,browserMouseEvent.relatedObject,browserMouseEvent.ctrlKey,browserMouseEvent.altKey,browserMouseEvent.shiftKey,browserMouseEvent.buttonDown,Std.int(_loc4_)));
            }
            lastEventTime = _loc3_;
         }
      }
      
      public static function getBrowserInfo() : BrowserInfo
      {
         var _loc3_:ASObject = null;
         var _loc2_:ASObject = null;
         var _loc1_:String = null;
         if(ExternalInterface.available)
         {
            _loc3_ = ExternalInterface.call("mws.getBrowserInfo");
            _loc2_ = ExternalInterface.call("mws.getPlatformInfo");
            _loc1_ = ExternalInterface.call("mws.getAgentInfo");
            return new BrowserInfo(_loc3_,_loc2_,_loc1_);
         }
         return null;
      }
   }


