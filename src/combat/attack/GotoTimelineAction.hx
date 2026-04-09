package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import facade.DBFacade;
   
    class GotoTimelineAction extends AttackTimelineAction
   {
      
      public static inline final TYPE= "goto";
      
      var mGotoFrame:Int = 0;
      
      var mGotoFunction:ASFunction;
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:ASObject, param5:ASFunction)
      {
         super(param1,param2,param3);
         mGotoFrame = ASCompat.toInt(param4.gotoFrame);
         mGotoFunction = param5;
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:ASObject, param5:ASFunction) : GotoTimelineAction
      {
         return new GotoTimelineAction(param1,param2,param3,param4,param5);
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         super.execute(param1);
         mGotoFunction(mGotoFrame);
      }
   }


