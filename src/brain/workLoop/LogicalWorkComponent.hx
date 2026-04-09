package brain.workLoop
;
   import brain.facade.Facade;
   
    class LogicalWorkComponent extends WorkComponent
   {
      
      public function new(param1:Facade)
      {
         super(param1,param1.logicalWorkManager);
      }
   }


