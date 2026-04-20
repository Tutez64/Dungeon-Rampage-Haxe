package distributedObjects
;
   import actor.ActorGameObject;
   import brain.event.EventComponent;
   import brain.logger.Logger;
   import brain.sceneGraph.SceneGraphComponent;
   import events.CacheLoadRequestNpcEvent;
   import facade.DBFacade;
   import gameMasterDictionary.GMAttack;
   import generatedCode.DistributedDungionAreaNetworkComponent;
   import generatedCode.IDistributedDungionArea;
   import generatedCode.InfiniteRewardData;
   import generatedCode.WeaponDetails;
   import generatedCode.Swrapper;
   
    class DistributedDungionArea extends Area implements IDistributedDungionArea
   {
      
      var mNetworkComponent:DistributedDungionAreaNetworkComponent;
      
      var mTileLibrary:Vector<String>;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      var mEventComponent:EventComponent;
      
      public var mCacheNpc:Vector<UInt>;
      
      public var mCacheSfc:Vector<String>;
      
      public function new(param1:DBFacade, param2:UInt = (0 : UInt))
      {
         Logger.debug("New  DistributedDungionArea******************************");
         super(param1,param2);
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"DistributedDungionArea");
         mCacheNpc = new Vector<UInt>();
         mCacheSfc = new Vector<String>();
         mEventComponent = new EventComponent(param1);
      }
      
      @:isVar public var cacheNpc(never,set):Vector<UInt>;
public function  set_cacheNpc(param1:Vector<UInt>) :Vector<UInt>      {
         return mCacheNpc = param1;
      }
      
      @:isVar public var cacheSWC(never,set):Vector<Swrapper>;
public function  set_cacheSWC(param1:Vector<Swrapper>) :Vector<Swrapper>      {
         var _loc2_= 0;
         mCacheSfc = new Vector<String>();
         _loc2_ = 0;
         while(_loc2_ < param1.length)
         {
            mCacheSfc.push(DBFacade.buildFullDownloadPath(param1[_loc2_].fileName));
            _loc2_ = ASCompat.toInt(_loc2_) + 1;
         }
return param1;
      }
      
      public function setNetworkComponentDistributedDungionArea(param1:DistributedDungionAreaNetworkComponent) 
      {
         mNetworkComponent = param1;
      }
      
      public function postGenerate() 
      {
         mEventComponent.dispatchEvent(new CacheLoadRequestNpcEvent(mCacheNpc,mCacheSfc,mTileLibrary));
      }
      
      public function tileLibrary(param1:Vector<Swrapper>) 
      {
         var _loc2_= 0;
         mTileLibrary = new Vector<String>();
         _loc2_ = 0;
         while(_loc2_ < param1.length)
         {
            mTileLibrary.push(param1[_loc2_].fileName);
            _loc2_ = ASCompat.toInt(_loc2_) + 1;
         }
      }
      
      public function calculateNetAttackDamage(param1:ActorGameObject, param2:ActorGameObject, param3:GMAttack, param4:WeaponDetails) : Float
      {
         var _loc6_= Math.NaN;
         var _loc7_= Math.NaN;
         var _loc5_:Float = 0;
         if(param3.StatOffsets != null)
         {
            _loc6_ = ASCompat.toNumber((param4.power * mDBFacade.gameMaster.stat_BonusMultiplier.values[Std.int(param3.StatOffsets.offence)] + param1.stats.values[Std.int(param3.StatOffsets.offence)]) * ASCompat.toNumber((param1.buffHandler.multiplier : ASAny)[param3.StatOffsets.offence]));
            _loc6_ = _loc6_ * param3.DamageMod;
            _loc7_ = ASCompat.toNumber(param2.stats.values[Std.int(param3.StatOffsets.defence)] * ASCompat.toNumber((param2.buffHandler.multiplier : ASAny)[param3.StatOffsets.defence]));
            _loc5_ = _loc6_ + _loc7_;
         }
         else
         {
            _loc5_ = param4.power * param3.DamageMod;
         }
         return _loc5_;
      }
      
      public function floorReward(param1:UInt) 
      {
      }
      
      public function floorEnding(param1:UInt) 
      {
         if(mActiveFloor == null)
         {
            return;
         }
         mActiveFloor.floorEnding(param1);
      }
      
      public function floorfailing(param1:UInt) 
      {
         if(mActiveFloor == null)
         {
            return;
         }
         mActiveFloor.floorFailing(param1);
      }
      
      public function tellClientInfiniteRewardData(param1:UInt, param2:UInt, param3:UInt, param4:Vector<InfiniteRewardData>) 
      {
         if(mDBFacade.dbAccountInfo.activeAvatarId != param1)
         {
            return;
         }
         mInfiniteStartScore = (param2 : Int);
         mInfiniteFloorGold = (param3 : Int);
         mInfiniteRewardData = param4;
         var _loc5_:InfiniteRewardData;
         if (checkNullIteratee(param4)) for (_tmp_ in param4)
         {
         	_loc5_ = _tmp_;
         }
      }
      
      public function dungeonEnding(param1:UInt, param2:UInt) 
      {
         if(mActiveFloor == null)
         {
            return;
         }
         if(param2 != 0)
         {
            mActiveFloor.victory();
         }
         else
         {
            mActiveFloor.defeat();
         }
      }
      
      override public function destroy() 
      {
         mEventComponent.destroy();
         mEventComponent = null;
         mCacheNpc = null;
         super.destroy();
      }
   }


