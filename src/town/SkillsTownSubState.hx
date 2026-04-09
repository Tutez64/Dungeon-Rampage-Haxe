package town
;
   import facade.DBFacade;
   
    class SkillsTownSubState extends TownSubState
   {
      
      public static inline final NAME= "SkillsTownSubState";
      
      public function new(param1:DBFacade, param2:TownStateMachine)
      {
         super(param1,param2,"SkillsTownSubState");
      }
      
      override function setupState() 
      {
         super.setupState();
      }
      
      override public function enterState() 
      {
         super.enterState();
         mTownStateMachine.townHeader.showCloseButton(true);
      }
   }


