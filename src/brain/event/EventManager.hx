package brain.event
;
   import brain.facade.Facade;
   import flash.display.Sprite;
   
    class EventManager extends Sprite
   {
      
      public function new(param1:Facade)
      {
         super();
         param1.addRootDisplayObject(this);
      }
   }


