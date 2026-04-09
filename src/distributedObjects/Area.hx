package distributedObjects
;
   import brain.gameObject.GameObject;
   import brain.logger.Logger;
   import facade.DBFacade;
   import generatedCode.InfiniteRewardData;
   
    class Area extends GameObject
   {
      
      var mActiveFloor:Floor;
      
      public var mDBFacade:DBFacade;
      
      var mExpCollected:UInt = 0;
      
      var mTreasureCollected:Vector<UInt>;
      
      var mAvScore:Int = 0;
      
      var mInfiniteStartScore:Int = 0;
      
      var mInfiniteTotalGold:Int = 0;
      
      var mInfiniteFloorGold:Int = 0;
      
      var mInfiniteRewardData:Vector<InfiniteRewardData>;
      
      public function new(param1:DBFacade, param2:UInt = (0 : UInt))
      {
         super(param1,param2);
         mDBFacade = param1;
         mTreasureCollected = new Vector<UInt>();
      }
      
      override public function newNetworkChild(param1:GameObject) 
      {
         if(ASCompat.reinterpretAs(param1 , Floor) != null)
         {
            settingActiveFloor(ASCompat.reinterpretAs(param1 , Floor));
         }
      }
      
      public function settingActiveFloor(param1:Floor) 
      {
         mActiveFloor = param1;
         mActiveFloor.SetParentArea(this);
      }
      
      @:isVar public var infiniteStartScore(get,never):Int;
public function  get_infiniteStartScore() : Int
      {
         return mInfiniteStartScore;
      }
      
      @:isVar public var infiniteTotalGold(get,never):Int;
public function  get_infiniteTotalGold() : Int
      {
         return mInfiniteTotalGold;
      }
      
      @:isVar public var infiniteFloorGold(get,never):Int;
public function  get_infiniteFloorGold() : Int
      {
         return mInfiniteFloorGold;
      }
      
      public function addInfiniteFloorGoldToTotal() 
      {
         mInfiniteTotalGold += mInfiniteFloorGold;
      }
      
      @:isVar public var infiniteRewardData(get,never):Vector<InfiniteRewardData>;
public function  get_infiniteRewardData() : Vector<InfiniteRewardData>
      {
         return mInfiniteRewardData;
      }
      
      @:isVar public var avScore(get,never):Int;
public function  get_avScore() : Int
      {
         return mAvScore;
      }
      
      override public function destroy() 
      {
         if(mActiveFloor != null)
         {
            Logger.debug("destroy Area " + Std.string(id) + " Before Active Floor is Cleared" + Std.string(mActiveFloor.id));
         }
         super.destroy();
         mActiveFloor = null;
         mTreasureCollected = null;
      }
      
      public function FloorIsLeaving(param1:Floor) 
      {
         mActiveFloor = null;
      }
      
      public function addCollectedTreasure(param1:UInt) 
      {
         mTreasureCollected.push(param1);
      }
      
      @:isVar public var treasureCollected(get,never):Vector<UInt>;
public function  get_treasureCollected() : Vector<UInt>
      {
         return mTreasureCollected;
      }
      
      public function addCollectedExp(param1:UInt) 
      {
         mExpCollected += param1;
      }
      
      @:isVar public var expCollected(get,never):UInt;
public function  get_expCollected() : UInt
      {
         return mExpCollected;
      }
   }


