package brain.uI
;
   import brain.facade.Facade;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
    class UIToggleButton extends UIButton
   {
      
      var m_id:UInt = 0;
      
      var selectionChangeCallback:ASFunction;
      
      public function new(param1:Facade, param2:UInt, param3:MovieClip, param4:Bool, param5:ASFunction, param6:Int = 0)
      {
         super(param1,param3,param6);
         m_id = param2;
         selectionChangeCallback = param5;
         this.selected = param4;
      }
      
      override function onRelease(param1:MouseEvent) 
      {
         this.selected = !this.selected;
         selectionChangeCallback(m_id,this.selected);
         super.onRelease(param1);
      }
   }


