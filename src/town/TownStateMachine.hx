package town
;
   import brain.assetRepository.SwfAsset;
   import brain.stateMachine.StateMachine;
   import brain.utils.MemoryTracker;
   import facade.DBFacade;
   import uI.leaderboard.UILeaderboard;
   import flash.display.MovieClip;
   
    class TownStateMachine extends StateMachine
   {
      
      static inline final TOWN_HOME_CLASS_NAME= "UI_town_home";
      
      public static inline final INVENTORY_CLASS_NAME= "DR_UI_town_inventory";
      
      static inline final TAVERN_CLASS_NAME= "UI_town_tavern";
      
      public static inline final SHOP_CLASS_NAME= "DR_UI_town_shop";
      
      static inline final FRIEND_MANAGEMENT_CLASS_NAME= "UI_friend_management";
      
      static inline final SKILLS_CLASS_NAME= "UI_town_skills";
      
      static inline final TRAIN_CLASS_NAME= "UI_town_train";
      
      static inline final MAP_2_1_NAME= "Map_2_1";
      
      static inline final CREDITS_CLASS_NAME= "UI_town_credits";
      
      var mTownSwfAsset:SwfAsset;
      
      var mMapSwfAsset:SwfAsset;
      
      var mHomeState:HomeState;
      
      var mInventoryState:InventoryTownSubState;
      
      var mTavernState:TavernTownSubState;
      
      var mTrainState:TrainTownSubState;
      
      var mSkillsState:SkillsTownSubState;
      
      var mShopState:ShopTownSubState;
      
      var mFriendManagementState:SocialSubState;
      
      var mMapState:MapTownSubState;
      
      var mTownHeader:TownHeader;
      
      var mUILeaderboard:UILeaderboard;
      
      var mCreditsState:CreditsTownSubState;
      
      var mDBFacade:DBFacade;
      
      public function new(param1:DBFacade)
      {
         super();
         mDBFacade = param1;
         buildStates();
         mTownHeader = new TownHeader(mDBFacade,this.enterHomeState,this.enterMapState);
      }
      
      override public function destroy() 
      {
         mHomeState.destroy();
         mInventoryState.destroy();
         mTavernState.destroy();
         mShopState.destroy();
         mFriendManagementState.destroy();
         mSkillsState.destroy();
         mTrainState.destroy();
         mMapState.destroy();
         mTownHeader.destroy();
         mUILeaderboard.destroy();
         mCreditsState.destroy();
         mHomeState = null;
         mInventoryState = null;
         mTavernState = null;
         mShopState = null;
         mFriendManagementState = null;
         mSkillsState = null;
         mTrainState = null;
         mMapState = null;
         mTownHeader = null;
         mUILeaderboard = null;
         mMapSwfAsset = null;
         mTownSwfAsset = null;
         mCreditsState = null;
         mDBFacade = null;
         super.destroy();
      }
      
      public function setSwfs(param1:SwfAsset, param2:SwfAsset) 
      {
         mTownSwfAsset = param1;
         mMapSwfAsset = param2;
         setMovieClipsOnStates();
      }
      
      @:isVar public var townSwf(get,never):SwfAsset;
public function  get_townSwf() : SwfAsset
      {
         return mTownSwfAsset;
      }
      
      @:isVar public var townHeader(get,never):TownHeader;
public function  get_townHeader() : TownHeader
      {
         return mTownHeader;
      }
      
      function setMovieClipsOnStates() 
      {
         var _loc3_:Dynamic = null;
         var _loc7_= mTownSwfAsset.getClass("UI_town_home");
         mHomeState.rootMovieClip = ASCompat.dynamicAs(ASCompat.createInstance(_loc7_, []) , MovieClip);
         var _loc4_= mTownSwfAsset.getClass("UI_town_tavern");
         mTavernState.rootMovieClip = ASCompat.dynamicAs(ASCompat.createInstance(_loc4_, []) , MovieClip);
         var _loc1_= mTownSwfAsset.getClass("DR_UI_town_inventory");
         mInventoryState.rootMovieClip = ASCompat.dynamicAs(ASCompat.createInstance(_loc1_, []) , MovieClip);
         var _loc9_= mTownSwfAsset.getClass("DR_UI_town_shop");
         mShopState.rootMovieClip = ASCompat.dynamicAs(ASCompat.createInstance(_loc9_, []) , MovieClip);
         var _loc8_= mTownSwfAsset.getClass("UI_friend_management");
         mFriendManagementState.rootMovieClip = ASCompat.dynamicAs(ASCompat.createInstance(_loc8_, []) , MovieClip);
         var _loc5_= mTownSwfAsset.getClass("UI_town_skills");
         mSkillsState.rootMovieClip = ASCompat.dynamicAs(ASCompat.createInstance(_loc5_, []) , MovieClip);
         var _loc6_= mTownSwfAsset.getClass("UI_town_train");
         mTrainState.rootMovieClip = ASCompat.dynamicAs(ASCompat.createInstance(_loc6_, []) , MovieClip);
         var _loc2_= mTownSwfAsset.getClass("UI_town_credits");
         mCreditsState.rootMovieClip = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []) , MovieClip);
         _loc3_ = mMapSwfAsset.getClass("Map_2_1");
         mMapState.rootMovieClip = ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []) , MovieClip);
         mUILeaderboard = new UILeaderboard(mDBFacade,mTownSwfAsset,callbackToFriendManager,getGifts,this);
      }
      
      function buildStates() 
      {
         mHomeState = new HomeState(mDBFacade,this);
         MemoryTracker.track(mHomeState,"HomeState - created in TownStateMachine.buildStates()");
         mInventoryState = new InventoryTownSubState(mDBFacade,this);
         MemoryTracker.track(mInventoryState,"InventoryTownSubState - created in TownStateMachine.buildStates()");
         mTavernState = new TavernTownSubState(mDBFacade,this);
         MemoryTracker.track(mTavernState,"TavernTownSubState - created in TownStateMachine.buildStates()");
         mShopState = new ShopTownSubState(mDBFacade,this);
         MemoryTracker.track(mShopState,"ShopTownSubState - created in TownStateMachine.buildStates()");
         mFriendManagementState = new SocialSubState(mDBFacade,this);
         MemoryTracker.track(mFriendManagementState,"SocialSubState - created in TownStateMachine.buildStates()");
         mSkillsState = new SkillsTownSubState(mDBFacade,this);
         MemoryTracker.track(mSkillsState,"SkillsTownSubState - created in TownStateMachine.buildStates()");
         mTrainState = new TrainTownSubState(mDBFacade,this);
         MemoryTracker.track(mTrainState,"TrainTownSubState - created in TownStateMachine.buildStates()");
         mMapState = new MapTownSubState(mDBFacade,this);
         MemoryTracker.track(mMapState,"MapTownSubState - created in TownStateMachine.buildStates()");
         mCreditsState = new CreditsTownSubState(mDBFacade,this);
         MemoryTracker.track(mCreditsState,"CreditsTownSubState - created in TownStateMachine.buildStates()");
      }
      
      public function enterHomeState() 
      {
         mTownHeader.show();
         mTownHeader.showCloseButton(false);
         this.transitionToState(mHomeState);
      }
      
      public function enterInventoryState(param1:Bool = false, param2:String = "", param3:UInt = (0 : UInt), param4:UInt = (0 : UInt), param5:Bool = false) 
      {
         mInventoryState.startAtCategoryTab = param2;
         mTownHeader.jumpToMapState = param1;
         mInventoryState.setRevlealedState(param3,param4,param5);
         this.transitionToState(mInventoryState);
      }
      
      public function enterTavernState(param1:Bool = false) 
      {
         mTownHeader.jumpToMapState = param1;
         this.transitionToState(mTavernState);
      }
      
      public function enterTrainState() 
      {
         this.transitionToState(mTrainState);
      }
      
      public function enterShopState(param1:Bool = false, param2:String = "") 
      {
         mShopState.startAtCategoryTab = param2;
         mTownHeader.jumpToMapState = param1;
         this.transitionToState(mShopState);
      }
      
      public function enterFriendManagementState() 
      {
         this.transitionToState(mFriendManagementState);
      }
      
      public function setFriendManagementTabCategory(param1:UInt) 
      {
         mFriendManagementState.setTabCategory(param1);
      }
      
      public function enterSkillsState() 
      {
         this.transitionToState(mSkillsState);
      }
      
      public function enterMapState() 
      {
         this.transitionToState(mMapState);
      }
      
      public function enterCreditState() 
      {
         this.transitionToState(mCreditsState);
      }
      
      public function getGifts() 
      {
         mHomeState.getGifts();
      }
      
      @:isVar public var leaderboard(get,never):UILeaderboard;
public function  get_leaderboard() : UILeaderboard
      {
         return mUILeaderboard;
      }
      
      public function getTownAsset(param1:String) : Dynamic
      {
         return mTownSwfAsset.getClass(param1);
      }
      
      public function callbackToFriendManager() 
      {
         setFriendManagementTabCategory((1 : UInt));
         enterFriendManagementState();
      }
      
      public function exit() 
      {
         mTownHeader.hide();
         this.currentState.exitState();
         this.currentState = null;
      }
   }


