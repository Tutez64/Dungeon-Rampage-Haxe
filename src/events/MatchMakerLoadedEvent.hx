package events
;
   import distributedObjects.MatchMaker;
   import flash.events.Event;
   
    class MatchMakerLoadedEvent extends Event
   {
      
      public static inline final EVENT_NAME= "MATCH_MAKER_LOADED";
      
      var mMatchMaker:MatchMaker;
      
      public function new(param1:MatchMaker, param2:Bool = false, param3:Bool = false)
      {
         super("MATCH_MAKER_LOADED",param2,param3);
         mMatchMaker = param1;
      }
      
      @:isVar public var matchMaker(get,never):MatchMaker;
public function  get_matchMaker() : MatchMaker
      {
         return mMatchMaker;
      }
   }


