package dungeon
;
   import brain.logger.Logger;
   import brain.utils.MemoryTracker;
   import distributedObjects.DistributedDungeonFloor;
   import events.LEClientEvent;
   import facade.DBFacade;
   import generatedCode.DungeonTileUsage;
   import flash.geom.Vector3D;
   import org.as3commons.collections.Map;
   
    class TileFactory
   {
      
      var mDBFacade:DBFacade;
      
      var mFactoriesReady:ASFunction;
      
      var mPropFactoryReady:Bool = false;
      
      var mTileFactoryReady:Bool = false;
      
      var mPropFactory:PropFactory;
      
      var mTileMap:Map = new Map();
      
      public var mFillerTiles:Array<ASAny> = [];
      
      var mLocalProximityTriggers:Array<ASAny>;
      
      var mTileLibraryJson:ASObject;
      
      public function new(param1:DBFacade, param2:Array<ASAny>, param3:ASObject)
      {
         
         mDBFacade = param1;
         mTileLibraryJson = param3;
         loadTileLibrary();
         loadTileTriggersAndTriggerables();
         mPropFactory = new PropFactory(mDBFacade,param2);
         MemoryTracker.track(mPropFactory,"PropFactory - created in TileFactory.constructor()");
      }
      
      public function destroy() 
      {
         mDBFacade = null;
         mPropFactory.destroy();
         mPropFactory = null;
         mFactoriesReady = null;
      }
      
      @:isVar public var propFactory(get,never):PropFactory;
public function  get_propFactory() : PropFactory
      {
         return mPropFactory;
      }
      
      function propFactoryReady() 
      {
         mPropFactoryReady = true;
         checkIfReady();
      }
      
      function checkIfReady() 
      {
         if(mPropFactoryReady && mTileFactoryReady)
         {
            mFactoriesReady();
         }
      }
      
      function loadTileLibrary() 
      {
         var _loc2_= 0;
         var _loc3_:Array<ASAny> = ASCompat.dynamicAs(mTileLibraryJson.LETiles , Array);
         var _loc1_= (_loc3_.length : UInt);
         while((_loc2_ : UInt) < _loc1_)
         {
            mTileMap.add(_loc3_[_loc2_].id,_loc3_[_loc2_]);
            if(_loc3_[_loc2_].category == "FILLER_TILE")
            {
               mFillerTiles.push(_loc3_[_loc2_]);
            }
            _loc2_++;
         }
         mTileFactoryReady = true;
         checkIfReady();
      }
      
      function loadTileTriggersAndTriggerables() 
      {
         var _loc2_= 0;
         var _loc3_:Array<ASAny> = ASCompat.dynamicAs(mTileLibraryJson.LETriggers , Array);
         var _loc1_= (_loc3_.length : UInt);
         while((_loc2_ : UInt) < _loc1_)
         {
            mDBFacade.gameMaster.triggerToTriggerable.add(_loc3_[_loc2_].triggerId,_loc3_[_loc2_].triggerableId);
            _loc2_++;
         }
      }
      
      public function buildTile(param1:DungeonTileUsage, param2:ASFunction, param3:ASFunction, param4:DistributedDungeonFloor) 
      {
         var _loc5_:ASAny = null;
         mLocalProximityTriggers = [];
         var _loc6_:ASObject = mTileMap.itemFor(param1.tileId);
         if(_loc6_ == null)
         {
            Logger.warn("Could not find tileId: " + param1.tileId + " in mTileMap");
            return;
         }
         var _loc7_= new Tile(mDBFacade,(ASCompat.toInt(_loc6_.LEObjects.length) : UInt),_loc6_.category == "FILLER_TILE");
         MemoryTracker.track(_loc7_,"Tile - created in TileFactory.buildTile()");
         _loc7_.position = new Vector3D(param1.x,param1.y);
         param2(_loc7_);
         param3(_loc7_);
         buildBackground(_loc6_.LEBackground,_loc7_,param4);
         final __ax4_iter_148:Array<ASAny> = _loc6_.LEObjects;
         if (checkNullIteratee(__ax4_iter_148)) for (_tmp_ in __ax4_iter_148)
         {
            _loc5_  = _tmp_;
            buildingProp(_loc5_,_loc7_,param4);
         }
         final __ax4_iter_149:Array<ASAny> = _loc6_.LETriggers;
         if (checkNullIteratee(__ax4_iter_149)) for (_tmp_ in __ax4_iter_149)
         {
            _loc5_  = _tmp_;
            buildingProp(_loc5_,_loc7_,param4);
         }
         final __ax4_iter_150 = mLocalProximityTriggers;
         if (checkNullIteratee(__ax4_iter_150)) for (_tmp_ in __ax4_iter_150)
         {
            _loc5_  = _tmp_;
            analyzeLocalProximityTrigger(_loc5_,_loc7_,param4);
         }
      }
      
      function buildingProp(param1:ASObject, param2:Tile, param3:DistributedDungeonFloor) 
      {
         switch(param1.type)
         {
            case "LEProp":
               buildProp(param1,param2,param3);
               
            case "LEHeroSpawnProp"
               | "LENPC"
               | "LENPCGenerator"
               | "LECollectable"
               | "LETriggerGate"
               | "LETriggerableCamera"
               | "LENPCGeneratorWithAllSpawnsDeadTrigger":
               param2.ignoredAProp();
               
            case "LETriggerable":
               if(param1.constant == "SEND_LOCAL_CLIENT_EVENT")
               {
                  mDBFacade.gameMaster.TriggerableIdToTriggerableEvent.add(ASCompat.toInt(param1.id),new TriggerableEvent((ASCompat.toInt(param1.id) : UInt),param1.textKey));
               }
               
            case "LETrigger":
               if(param1.constant == "PROXIMITY_LOCAL_HERO")
               {
                  mLocalProximityTriggers.push(param1);
               }
               
            default:
               Logger.debug("Do not know how to handle type: " + Std.string(param1.type) + " Ignoring.");
               param2.ignoredAProp();
         }
      }
      
      function buildProp(param1:ASObject, param2:Tile, param3:DistributedDungeonFloor) 
      {
         var _loc4_= Prop.validatePropConstant(param1,mDBFacade);
         if(!_loc4_)
         {
            Logger.warn("invalid prop constant: " + Std.string(param1.constant));
            return;
         }
         var _loc5_= Prop.parseFromTileJson(param1,param2,mDBFacade);
         _loc5_.distributedDungeonFloor = param3;
      }
      
      function analyzeLocalProximityTrigger(param1:ASObject, param2:Tile, param3:DistributedDungeonFloor) 
      {
         var triggerableEvent:TriggerableEvent;
         var propJsonObj:ASObject = param1;
         var tile= param2;
         var distributedDungeonFloor= param3;
         var triggerableId= (ASCompat.toInt(mDBFacade.gameMaster.triggerToTriggerable.itemFor(propJsonObj.id)) : UInt);
         if(triggerableId != 0)
         {
            triggerableEvent = ASCompat.dynamicAs(mDBFacade.gameMaster.TriggerableIdToTriggerableEvent.itemFor(triggerableId), dungeon.TriggerableEvent);
            if(triggerableEvent != null)
            {
               tile.createLocalEventCollision(distributedDungeonFloor,(ASCompat.toInt(propJsonObj.x) : UInt),(ASCompat.toInt(propJsonObj.y) : UInt),(ASCompat.toInt(propJsonObj.radius) : UInt),ASCompat.toBool(propJsonObj.triggerOnce),function()
               {
                  mDBFacade.eventManager.dispatchEvent(new LEClientEvent(triggerableEvent.eventName));
               });
            }
         }
      }
      
      function buildBackground(param1:ASObject, param2:Tile, param3:DistributedDungeonFloor) 
      {
         var _loc4_= Prop.validatePropConstant(param1,mDBFacade);
         if(!_loc4_)
         {
            Logger.warn("invalid background constant: " + Std.string(param1.constant));
            return;
         }
         var _loc5_= Prop.parseFromTileJson(param1,param2,mDBFacade);
         _loc5_.view.root.scaleX = _loc5_.view.root.scaleY = 1.0022222222222221;
         _loc5_.layer = 5;
         _loc5_.distributedDungeonFloor = param3;
         param2.background = _loc5_;
      }
   }


