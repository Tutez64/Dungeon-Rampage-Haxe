package brain.mouseScrollPlugin
;
   import flash.display.InteractiveObject;
   import flash.events.MouseEvent;
   
    class CustomMouseWheelEvent extends MouseEvent
   {
      
      public static inline final MOVE= "onMove";
      
      public function new(param1:String, param2:Bool = true, param3:Bool = false, param4:Float = 0, param5:Float = 0, param6:InteractiveObject = null, param7:Bool = false, param8:Bool = false, param9:Bool = false, param10:Bool = false, param11:Int = 0)
      {
         super(param1,param2,param3,param4,param5,param6,param7,param8,param9,param10,param11);
      }
   }


