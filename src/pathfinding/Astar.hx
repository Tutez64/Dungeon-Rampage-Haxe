package pathfinding
;
   import box2D.collision.shapes.B2CircleShape;
   import box2D.collision.B2AABB;
   import box2D.common.math.B2Transform;
   import box2D.common.B2Color;
   import box2D.dynamics.B2Body;
   import box2D.dynamics.B2Fixture;
   import brain.logger.Logger;
   import distributedObjects.DistributedDungeonFloor;
   import dungeon.NavCollider;
   import dungeon.Tile;
   import flash.geom.Vector3D;
   
    class Astar
   {
      
      public var Nodes:Vector<AstarGridNode>;
      
      public var TotalGridCount:UInt = 0;
      
      public var TotalGridCountPerTile:UInt = 0;
      
      var mDistributedDungeonFloor:DistributedDungeonFloor;
      
      var mOpenList:PriorityQueue;
      
      var mUniquePassKey:UInt = 0;
      
      var mConsideredNodeCount:UInt = 0;
      
      var mAnswerPath:Vector<UInt>;
      
      var mClosestGrid:AstarGridNode;
      
      public var pickedClosestGrid:Bool = false;
      
      public var heroCollisionRadius:Float = Math.NaN;
      
      public var goalPoint:Vector3D;
      
      var mCollFixture:B2Fixture = null;
      
      public function new()
      {
         var _loc1_= 0;
         
         TotalGridCount = (216 * 216 : UInt);
         TotalGridCountPerTile = (18 * 18 : UInt);
         Nodes = new Vector<AstarGridNode>();
         mUniquePassKey = (0 : UInt);
         _loc1_ = 0;
         while((_loc1_ : UInt) < TotalGridCount)
         {
            Nodes[_loc1_] = null;
            _loc1_ = ASCompat.toInt(_loc1_) + 1;
         }
         mOpenList = new PriorityQueue();
         mAnswerPath = new Vector<UInt>();
      }
      
      public function Init(param1:DistributedDungeonFloor) 
      {
         var _loc3_= 0;
         var _loc2_= 0;
         var _loc4_:Tile = null;
         mDistributedDungeonFloor = param1;
         _loc3_ = 0;
         while(_loc3_ < 12)
         {
            _loc2_ = 0;
            while(_loc2_ < 12)
            {
               _loc4_ = mDistributedDungeonFloor.tileGrid.getTileAtIndex((_loc2_ : UInt),(_loc3_ : UInt));
               if(_loc4_ != null)
               {
                  InitTileAstarGrids((_loc2_ : UInt),(_loc3_ : UInt));
               }
               _loc2_ = ASCompat.toInt(_loc2_) + 1;
            }
            _loc3_ = ASCompat.toInt(_loc3_) + 1;
         }
      }
      
      public function InitTileAstarGrids(param1:UInt, param2:UInt) 
      {
         var _loc3_= 0;
         var _loc6_= mDistributedDungeonFloor.tileGrid.getTileAtIndex(param1,param2);
         if(_loc6_ == null)
         {
            Logger.error("sent in the wrong tile position: " + param1 + "," + param2);
            return;
         }
         var _loc5_= (0 : UInt);
         var _loc7_= (0 : UInt);
         var _loc4_= param2 * 18;
         while(_loc4_ < (param2 + 1) * 18)
         {
            _loc3_ = (param1 * 18 : Int);
            while((_loc3_ : UInt) < (param1 + 1) * 18)
            {
               _loc5_ = (ASCompat.toInt(_loc3_ + _loc4_ * 216) : UInt);
               Nodes[(_loc5_ : Int)] = new AstarGridNode((_loc5_ : Int));
               _loc7_++;
               _loc3_ = ASCompat.toInt(_loc3_) + 1;
            }
            _loc4_++;
         }
      }
      
      public function destroy() 
      {
         var _loc1_= 0;
         mDistributedDungeonFloor = null;
         _loc1_ = 0;
         while((_loc1_ : UInt) < TotalGridCount)
         {
            if(Nodes[_loc1_] != null)
            {
               Nodes[_loc1_].destroy();
               Nodes[_loc1_] = null;
            }
            _loc1_ = ASCompat.toInt(_loc1_) + 1;
         }
         mOpenList = null;
         mAnswerPath = null;
      }
      
      @:isVar public var HeroCollisionRadius(never,set):Float;
public function  set_HeroCollisionRadius(param1:Float) :Float      {
         return heroCollisionRadius = param1;
      }
      
      @:isVar public var answerPath(get,never):Vector<UInt>;
public function  get_answerPath() : Vector<UInt>
      {
         var _loc2_= new Vector<UInt>();
         var _loc1_:UInt;
         final __ax4_iter_77 = mAnswerPath;
         if (checkNullIteratee(__ax4_iter_77)) for (_tmp_ in __ax4_iter_77)
         {
            _loc1_ = _tmp_;
            _loc2_.push(_loc1_);
         }
         return ASCompat.ASVector.reverse(_loc2_);
      }
      
      public function GetAstarGrid(param1:Vector3D) : UInt
      {
         var _loc2_= (Std.int(param1.x / 50) : UInt);
         var _loc3_= (Std.int(param1.y / 50) : UInt);
         return _loc2_ + _loc3_ * 216;
      }
      
      public function GetAstarGridCenter(param1:Vector3D) : Vector3D
      {
         var _loc3_= (Std.int(param1.x / 50) : UInt);
         var _loc4_= (Std.int(param1.y / 50) : UInt);
         var _loc2_= new Vector3D();
         _loc2_.x = _loc3_ * 50 + 50 / 2;
         _loc2_.y = _loc4_ * 50 + 50 / 2;
         return _loc2_;
      }
      
      public function GetEuclideanDistance(param1:Vector3D, param2:Vector3D) : Float
      {
         return Math.sqrt(Math.pow(param1.x - param2.x,2) + Math.pow(param1.y - param2.y,2));
      }
      
      public function GetManhattanDistance(param1:Vector3D, param2:Vector3D) : Float
      {
         return Math.abs(param1.x - param2.x) + Math.abs(param1.y - param2.y);
      }
      
      public function IsGridLegalAABB(param1:AstarGridNode) : Bool
      {
         var collided:Bool;
         var fixture:B2Fixture;
         var grid= param1;
         var CollisionCallback= function(param1:B2Fixture)
         {
            var _loc2_= param1.GetShape();
            if(param1.GetBody().GetType() == B2Body.b2_staticBody)
            {
               mCollFixture = param1;
               collided = true;
            }
         };
         var gridCenter= NavCollider.convertToB2Vec2(grid.Center);
         var halfDimension:Float = 0.5;
         var aabb= new B2AABB();
         aabb.lowerBound.Set(gridCenter.x - halfDimension,gridCenter.y - halfDimension);
         aabb.upperBound.Set(gridCenter.x + halfDimension,gridCenter.y + halfDimension);
         collided = false;
         mDistributedDungeonFloor.box2DWorld.QueryAABB(CollisionCallback,aabb);
         return !collided;
      }
      
      public function IsGridLegalCircle(param1:AstarGridNode) : Bool
      {
         var collided:Bool;
         var fixture:B2Fixture;
         var grid= param1;
         var CollisionCallback= function(param1:B2Fixture)
         {
            var _loc2_= param1.GetShape();
            if(param1.GetBody().GetType() == B2Body.b2_staticBody)
            {
               collided = true;
               mCollFixture = param1;
            }
         };
         var gridCenter= NavCollider.convertToB2Vec2(grid.Center);
         var circle= new B2CircleShape(heroCollisionRadius);
         var transform= new B2Transform();
         transform.position = gridCenter;
         collided = false;
         mDistributedDungeonFloor.box2DWorld.QueryShape(CollisionCallback,circle,transform);
         return !collided;
      }
      
      public function LineOfSight(param1:Vector3D, param2:Vector3D) : Bool
      {
         var _loc3_= NavCollider.convertToB2Vec2(param1);
         var _loc4_= NavCollider.convertToB2Vec2(param2);
         mCollFixture = mDistributedDungeonFloor.box2DWorld.RayCastOne(_loc3_,_loc4_);
         if(mCollFixture != null)
         {
            Logger.info("no line of sight between " + param1 + " and " + param2);
            return false;
         }
         return true;
      }
      
      public function Search(param1:Vector3D, param2:Vector3D) 
      {
         var _loc9_:UInt;
         var __ax4_iter_78:Vector<UInt>;
         var _loc7_:B2Transform = null;
         mClosestGrid = null;
         mAnswerPath.splice(0,(mAnswerPath.length : UInt));
         mOpenList.splice(0);
         mConsideredNodeCount = (0 : UInt);
         mUniquePassKey = mUniquePassKey + 1;
         pickedClosestGrid = false;
         var _loc4_= GetAstarGridCenter(param1);
         var _loc3_= GetAstarGridCenter(param2);
         var _loc8_= GetAstarGrid(param1);
         var _loc5_= GetAstarGrid(param2);
         goalPoint = param2;
         var _loc6_= AstarWorker(_loc8_,_loc5_);
         if(_loc6_)
         {
            ReconstructPath(_loc5_,_loc8_);
         }
         else if(mClosestGrid != null)
         {
            pickedClosestGrid = true;
            ReconstructPath(mClosestGrid.Id,_loc8_);
         }
         if(mDistributedDungeonFloor.debugVisualizer != null)
         {
            _loc7_ = new B2Transform();
            _loc7_.position = NavCollider.convertToB2Vec2(_loc4_);
            mDistributedDungeonFloor.debugVisualizer.makeAGridCircle(_loc7_,new B2Color(1,0,0));
            _loc7_ = new B2Transform();
            _loc7_.position = NavCollider.convertToB2Vec2(_loc3_);
            mDistributedDungeonFloor.debugVisualizer.makeAGridCircle(_loc7_,new B2Color(1,0,0));
            __ax4_iter_78 = mAnswerPath;
            if (checkNullIteratee(__ax4_iter_78)) for (_tmp_ in __ax4_iter_78)
            {
               _loc9_ = _tmp_;
               if(!(_loc9_ == _loc8_ || _loc9_ == _loc5_))
               {
                  _loc7_ = new B2Transform();
                  _loc7_.position = NavCollider.convertToB2Vec2(Nodes[(_loc9_ : Int)].Center);
                  mDistributedDungeonFloor.debugVisualizer.makeAGridCircle(_loc7_,new B2Color(0,0,1));
               }
            }
         }
      }
      
      public function AstarWorker(param1:UInt, param2:UInt) : Bool
      {
         var _loc8_:ASAny;
         var __ax4_iter_79:Array<ASAny>;
         var _loc9_:AstarGridNode = null;
         var _loc3_:AstarGridNode = null;
         var _loc5_= false;
         var _loc6_= Math.NaN;
         var _loc4_= Nodes[(param1 : Int)];
         var _loc11_= Nodes[(param2 : Int)];
         if(_loc4_ == null)
         {
            Logger.info("startGridIdx: " + param1 + " is invalid");
            return false;
         }
         if(_loc11_ == null)
         {
            Logger.info("goalGridIdx: " + param2 + " is invalid");
            return false;
         }
         param2 = _loc11_.Id;
         var _loc7_= GetManhattanDistance(_loc4_.Center,goalPoint);
         _loc4_.g = 0;
         _loc4_.h = _loc7_;
         _loc4_.f = _loc7_;
         mOpenList.push(_loc4_);
         var _loc10_= _loc7_;
         mClosestGrid = _loc4_;
         while(mOpenList.length > 0)
         {
            _loc9_ = mOpenList.front();
            if(_loc9_.Id == param2)
            {
               return true;
            }
            mOpenList.pop();
            _loc9_.visited = (mUniquePassKey : Int);
            __ax4_iter_79 = _loc9_.Neighbors;
            if (checkNullIteratee(__ax4_iter_79)) for (_tmp_ in __ax4_iter_79)
            {
               _loc8_ = _tmp_;
               _loc3_ = Nodes[ASCompat.toInt(_loc8_)];
               if(_loc3_ != null)
               {
                  if((_loc3_.visited : UInt) != mUniquePassKey)
                  {
                     _loc5_ = false;
                     _loc6_ = _loc9_.g + _loc9_.costToNeighbor(_loc3_.Id);
                     if(!mOpenList.contains(_loc3_))
                     {
                        if(_loc3_.Id == param2)
                        {
                        }
                        if(!IsGridLegalCircle(_loc3_))
                        {
                           _loc3_.visited = (mUniquePassKey : Int);
                           continue;
                        }
                        if(_loc6_ < 850)
                        {
                           _loc5_ = true;
                        }
                     }
                     else if(_loc6_ < _loc3_.g)
                     {
                        _loc5_ = true;
                     }
                     if(_loc5_)
                     {
                        mConsideredNodeCount = mConsideredNodeCount + 1;
                        _loc3_.g = _loc6_;
                        _loc3_.h = GetManhattanDistance(_loc3_.Center,goalPoint);
                        _loc3_.f = _loc3_.g + _loc3_.h;
                        _loc3_.Parent = _loc9_.Id;
                        mOpenList.push(_loc3_);
                        if(_loc3_.h < _loc10_)
                        {
                           _loc10_ = _loc3_.h;
                           mClosestGrid = _loc3_;
                        }
                     }
                  }
               }
            }
         }
         return false;
      }
      
      public function ReconstructPath(param1:UInt, param2:UInt) 
      {
         var _loc3_= param1;
         mAnswerPath.push(_loc3_);
         while(_loc3_ != param2)
         {
            _loc3_ = Nodes[(_loc3_ : Int)].Parent;
            mAnswerPath.push(_loc3_);
         }
      }
      
      public function DrawAstarGridsInTile(param1:UInt) 
      {
         var _loc4_:B2Transform = null;
         var _loc5_= 0;
         var _loc6_= 0;
         var _loc7_:Float = 0;
         var _loc8_:Float = 0;
         var _loc2_:Float = 0;
         var _loc3_:Float = 0;
         var _loc9_:Float = 0;
         if(mDistributedDungeonFloor.debugVisualizer != null)
         {
            _loc4_ = new B2Transform();
            _loc5_ = param1 % 12 * 900;
            _loc6_ = Std.int(param1 / 12) * 900;
            _loc7_ = _loc5_ / 50;
            _loc8_ = _loc6_ / 50;
            _loc2_ = _loc7_;
            while(_loc2_ < ASCompat.toNumber(_loc7_ + 18))
            {
               _loc3_ = _loc8_;
               while(_loc3_ < ASCompat.toNumber(_loc8_ + 18))
               {
                  _loc9_ = _loc2_ + _loc3_ * 216;
                  _loc4_.position = NavCollider.convertToB2Vec2(Nodes[Std.int(_loc9_)].Center);
                  mDistributedDungeonFloor.debugVisualizer.makeAGridRectangle(_loc4_,new B2Color(0.5,0.5,0.5));
                  _loc3_ = ASCompat.toInt(_loc3_) + 1;
               }
               _loc2_ = ASCompat.toInt(_loc2_) + 1;
            }
         }
      }
   }


