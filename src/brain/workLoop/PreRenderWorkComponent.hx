package brain.workLoop
;
   import brain.facade.Facade;
   
    class PreRenderWorkComponent extends WorkComponent
   {
      
      public function new(param1:Facade, param2:String = null)
      {
         super(param1,param1.preRenderWorkManager,param2);
      }
   }


