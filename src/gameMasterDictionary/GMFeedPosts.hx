package gameMasterDictionary
;
    class GMFeedPosts
   {
      
      public var Id:UInt = 0;
      
      public var Constant:String;
      
      public var FeedName:String;
      
      public var IdTrigger:UInt = 0;
      
      public var LevelTrigger:UInt = 0;
      
      public var Category:String;
      
      public var FeedCaption:String;
      
      public var FeedDescriptions:String;
      
      public var FeedActionsName:String;
      
      public var FeedActionsLink:String;
      
      public var FeedActionsReward:String;
      
      public var FeedImageLink:String;
      
      public function new(param1:ASObject)
      {
         
         Id = (ASCompat.toInt(param1.Id) : UInt);
         Constant = param1.Constant;
         FeedName = param1.FeedName;
         IdTrigger = (ASCompat.toInt(param1.IdTrigger) : UInt);
         Category = param1.Category;
         FeedCaption = param1.FeedCaption;
         FeedDescriptions = param1.FeedDescriptions;
         FeedActionsName = param1.FeedActionsName;
         FeedActionsLink = param1.FeedActionsLink;
         FeedActionsReward = param1.FeedActionsReward;
         FeedImageLink = param1.FeedImageLink;
         LevelTrigger = (ASCompat.toInt(param1.LevelTrigger) : UInt);
      }
   }


