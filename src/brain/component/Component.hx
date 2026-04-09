package brain.component
;
   import brain.facade.Facade;
   
    class Component
   {
      
      var mFacade:Facade;
      
      public function new(param1:Facade)
      {
         
         mFacade = param1;
      }
      
      public function destroy() 
      {
         mFacade = null;
      }
   }


