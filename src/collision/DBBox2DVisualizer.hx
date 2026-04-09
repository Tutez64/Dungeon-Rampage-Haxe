package collision
;
   import box2D.collision.shapes.B2CircleShape;
   import box2D.collision.shapes.B2PolygonShape;
   import box2D.collision.shapes.B2Shape;
   import box2D.common.math.B2Math;
   import box2D.common.math.B2Transform;
   import box2D.common.math.B2Vec2;
   import box2D.common.B2Color;
   import box2D.dynamics.B2World;
   import brain.clock.GameClock;
   import brain.collision.Box2DVisualizer;
   import brain.logger.Logger;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.workLoop.PreRenderWorkComponent;
   import distributedObjects.Floor;
   import facade.DBFacade;

import box2D.collision.shapes.B2CircleShape;
import box2D.collision.shapes.B2PolygonShape;
import box2D.collision.shapes.B2Shape;
import box2D.common.math.B2Transform;
import box2D.common.math.B2Vec2;
import box2D.common.B2Color;
   
    class DBBox2DVisualizer extends Box2DVisualizer
   {
      
      static inline final DEFAULT_LIFETIME= (24 : UInt);
      
      var mDBFacade:DBFacade;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      var mPreRenderWorkComponent:PreRenderWorkComponent;
      
      var mFloor:Floor;
      
      var mHeroCircleAttacks:Vector<CircleAttackRecord>;
      
      var mHeroPolyAttacks:Vector<PolygonShapeRecord>;
      
      var mRayCasts:Vector<RayCastDraw>;
      
      var mPolysToShow:Vector<PolygonShapeRecord> = new Vector();
      
      var mCirclesToShow:Vector<ShapeRecord> = new Vector();
      
      var mAstarGridRects:Vector<AstarGridRectangleDraw> = new Vector();
      
      var mAstarGridCircs:Vector<AstarGridCircleDraw> = new Vector();
      
      public function new(param1:DBFacade, param2:B2World, param3:Bool = false, param4:Bool = false, param5:Bool = false, param6:Bool = false)
      {
         super(param2,param3,param4,param5,param6);
         mDBFacade = param1;
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade);
         mPreRenderWorkComponent = new PreRenderWorkComponent(mDBFacade);
         mSceneGraphComponent.addChild(rootSprite,(30 : UInt));
         mPreRenderWorkComponent.doEveryFrame(update);
         mDebugDraw.SetDrawScale(50);
         mHeroCircleAttacks = new Vector<CircleAttackRecord>();
         mHeroPolyAttacks = new Vector<PolygonShapeRecord>();
         mAstarGridCircs = new Vector<AstarGridCircleDraw>();
         mAstarGridRects = new Vector<AstarGridRectangleDraw>();
         mRayCasts = new Vector<RayCastDraw>();
      }
      
      override public function update(param1:GameClock) 
      {
         var _loc5_:B2PolygonShape = null;
         var _loc4_:PolygonShapeRecord = null;
         var _loc7_= 0;
         var _loc8_= 0;
         var _loc9_:B2CircleShape = null;
         var _loc2_= Math.NaN;
         super.update(param1);
         if(mWantAllCollisions || mWantCombatCollisions)
         {
            drawCombatCollisions();
         }
         if(mWantAllCollisions || mWantAStarVisuals)
         {
            drawAStarVisuals();
         }
         var _loc3_= new Vector<PolygonShapeRecord>();
         var _loc6_= new B2Color(0,0,1);
         _loc7_ = 0;
         while(_loc7_ < mPolysToShow.length)
         {
            _loc4_ = mPolysToShow[_loc7_];
            _loc5_ = _loc4_.mShape ;
            mDebugDraw.DrawPolygon(_loc4_.mVerticies,_loc5_.GetVertexCount(),_loc6_);
            _loc4_.mLife--;
            if(_loc4_.mLife > 0)
            {
               _loc3_.push(_loc4_);
            }
            _loc7_ = ASCompat.toInt(_loc7_) + 1;
         }
         mPolysToShow = _loc3_;
         _loc8_ = 0;
         while(_loc8_ < mCirclesToShow.length)
         {
            _loc9_ = ASCompat.reinterpretAs(mCirclesToShow[_loc8_].mShape , B2CircleShape);
            _loc2_ = _loc9_.GetRadius();
            mDebugDraw.DrawCircle(mCirclesToShow[_loc8_].mTransform.position,_loc2_,_loc6_);
            _loc8_ = ASCompat.toInt(_loc8_) + 1;
         }
      }
      
      function drawCombatCollisions() 
      {
         var _loc10_= 0;
         var _loc9_:CircleAttackRecord = null;
         var _loc14_:B2CircleShape = null;
         var _loc7_:B2Vec2 = null;
         var _loc15_= Math.NaN;
         var _loc8_:B2Vec2 = null;
         var _loc4_:B2Color = null;
         var _loc5_:PolygonShapeRecord = null;
         var _loc6_:B2PolygonShape = null;
         var _loc2_:B2Color = null;
         var _loc3_:RayCastDraw = null;
         var _loc1_= new Vector<CircleAttackRecord>();
         _loc10_ = 0;
         while(_loc10_ < mHeroCircleAttacks.length)
         {
            _loc9_ = mHeroCircleAttacks[_loc10_];
            _loc14_ = _loc9_.mCircle;
            _loc14_.GetLocalPosition();
            _loc7_ = B2Math.MulX(_loc9_.mTransform,_loc14_.GetLocalPosition());
            _loc15_ = _loc14_.GetRadius();
            _loc8_ = _loc9_.mTransform.R.col1;
            _loc4_ = new B2Color(1,1,1);
            _loc9_.mlife--;
            if(_loc9_.mlife > 0)
            {
               _loc1_.push(_loc9_);
            }
            mDebugDraw.DrawSolidCircle(_loc7_,_loc15_,_loc8_,_loc4_);
            _loc10_ = ASCompat.toInt(_loc10_) + 1;
         }
         mHeroCircleAttacks = _loc1_;
         var _loc12_= new Vector<PolygonShapeRecord>();
         _loc10_ = 0;
         while(_loc10_ < mHeroPolyAttacks.length)
         {
            _loc5_ = mHeroPolyAttacks[_loc10_];
            _loc5_.buildVerticies();
            _loc6_ = _loc5_.mShape ;
            _loc2_ = new B2Color(1,1,1);
            mDebugDraw.DrawSolidPolygon(_loc5_.mVerticiesAsVector,_loc6_.GetVertexCount(),_loc2_);
            _loc5_.mLife--;
            if(_loc5_.mLife > 0)
            {
               _loc12_.push(_loc5_);
            }
            _loc10_ = ASCompat.toInt(_loc10_) + 1;
         }
         mHeroPolyAttacks = _loc12_;
         var _loc11_= new B2Color(1,0,0);
         var _loc13_= new Vector<RayCastDraw>();
         _loc10_ = 0;
         while(_loc10_ < mRayCasts.length)
         {
            _loc3_ = mRayCasts[_loc10_];
            _loc3_.life--;
            mDebugDraw.DrawSegment(_loc3_.point1,_loc3_.point2,_loc11_);
            if(_loc3_.life > 0)
            {
               _loc13_.push(_loc3_);
            }
            _loc10_ = ASCompat.toInt(_loc10_) + 1;
         }
         mRayCasts = _loc13_;
      }
      
      function drawAStarVisuals() 
      {
         var _loc4_= 0;
         var _loc6_:AstarGridCircleDraw = null;
         var _loc7_:B2CircleShape = null;
         var _loc3_:B2Vec2 = null;
         var _loc8_= Math.NaN;
         var _loc9_:B2Vec2 = null;
         var _loc10_:AstarGridRectangleDraw = null;
         var _loc5_:B2PolygonShape = null;
         var _loc2_= new Vector<AstarGridCircleDraw>();
         _loc4_ = 0;
         while(_loc4_ < mAstarGridCircs.length)
         {
            _loc6_ = mAstarGridCircs[_loc4_];
            _loc7_ = _loc6_.mCircle;
            _loc7_.GetLocalPosition();
            _loc3_ = B2Math.MulX(_loc6_.mTransform,_loc7_.GetLocalPosition());
            _loc8_ = _loc7_.GetRadius();
            _loc9_ = _loc6_.mTransform.R.col1;
            _loc6_.mlife--;
            if(_loc6_.mlife > 0)
            {
               _loc2_.push(_loc6_);
            }
            mDebugDraw.DrawSolidCircle(_loc3_,_loc8_,_loc9_,_loc6_.mColor);
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
         }
         mAstarGridCircs = _loc2_;
         var _loc1_= new Vector<AstarGridRectangleDraw>();
         _loc4_ = 0;
         while(_loc4_ < mAstarGridRects.length)
         {
            _loc10_ = mAstarGridRects[_loc4_];
            _loc5_ = _loc10_.mRectangle;
            _loc10_.mlife--;
            if(_loc10_.mlife > 0)
            {
               _loc1_.push(_loc10_);
            }
            mDebugDraw.DrawSolidPolygon(_loc5_.GetVertices(),_loc5_.GetVertexCount(),_loc10_.mColor);
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
         }
         mAstarGridRects = _loc1_;
      }
      
      public function reportCircleAttack(param1:B2Transform, param2:B2CircleShape, param3:UInt = (24 : UInt)) 
      {
         var _loc4_= new CircleAttackRecord();
         _loc4_.mCircle = param2;
         _loc4_.mTransform = param1;
         _loc4_.mlife = param3;
         mHeroCircleAttacks.push(_loc4_);
      }
      
      public function reportPolyAttack(param1:B2Transform, param2:B2PolygonShape, param3:UInt = (24 : UInt)) 
      {
         var _loc4_= new PolygonShapeRecord();
         _loc4_.mShape = param2;
         _loc4_.mTransform = param1;
         _loc4_.mLife = param3;
         _loc4_.buildVerticies();
         mHeroPolyAttacks.push(_loc4_);
      }
      
      public function makeAGridCircle(param1:B2Transform, param2:B2Color, param3:UInt = (24 : UInt)) 
      {
         var _loc4_= new AstarGridCircleDraw();
         _loc4_.mCircle = new B2CircleShape(0.6);
         _loc4_.mTransform = param1;
         _loc4_.mColor = param2;
         _loc4_.mlife = param3;
         mAstarGridCircs.push(_loc4_);
      }
      
      public function makeAGridRectangle(param1:B2Transform, param2:B2Color, param3:UInt = (24 : UInt)) 
      {
         var _loc5_= new AstarGridRectangleDraw();
         _loc5_.mRectangle = new B2PolygonShape();
         var _loc4_:Array<ASAny> = [];
         _loc4_[0] = new B2Vec2(param1.position.x + 0.5,param1.position.y + 0.5);
         _loc4_[1] = new B2Vec2(param1.position.x + 0.5,param1.position.y - 0.5);
         _loc4_[2] = new B2Vec2(param1.position.x - 0.5,param1.position.y - 0.5);
         _loc4_[3] = new B2Vec2(param1.position.x - 0.5,param1.position.y + 0.5);
         _loc5_.mRectangle.SetAsArray(_loc4_,_loc4_.length);
         _loc5_.mTransform = param1;
         _loc5_.mColor = param2;
         _loc5_.mlife = param3;
         mAstarGridRects.push(_loc5_);
      }
      
      public function reportShape(param1:B2Shape, param2:B2Transform, param3:UInt = (24 : UInt)) 
      {
         var _loc4_:PolygonShapeRecord = null;
         var _loc5_:ShapeRecord = null;
         if(Std.isOfType(param1 , B2PolygonShape))
         {
            _loc4_ = new PolygonShapeRecord();
            _loc4_.mLife = param3;
            _loc4_.mShape = ASCompat.reinterpretAs(param1 , B2PolygonShape);
            _loc4_.mTransform = param2;
            _loc4_.buildVerticies();
            mPolysToShow.push(_loc4_);
         }
         else if(Std.isOfType(param1 , B2CircleShape))
         {
            _loc5_ = new ShapeRecord();
            _loc5_.mLife = param3;
            _loc5_.mShape = param1;
            _loc5_.mTransform = param2;
            mCirclesToShow.push(_loc5_);
         }
         else
         {
            Logger.warn("Shape is neither a b2Polygon nor a b2circle.  Unable to visualize.");
         }
      }
      
      public function reportRayCast(param1:B2Vec2, param2:B2Vec2, param3:UInt = (24 : UInt)) 
      {
         var _loc4_= new RayCastDraw();
         _loc4_.point1 = param1.Copy();
         _loc4_.point2 = param2.Copy();
         _loc4_.life = param3;
         mRayCasts.push(_loc4_);
      }
      
      public function destroy() 
      {
         mSceneGraphComponent.destroy();
         mSceneGraphComponent = null;
         mPreRenderWorkComponent.destroy();
         mPreRenderWorkComponent = null;
         mHeroCircleAttacks = null;
         mHeroPolyAttacks = null;
         mRayCasts = null;
         mPolysToShow = null;
         mCirclesToShow = null;
         mAstarGridRects = null;
         mAstarGridCircs = null;
      }
   }


private class CircleAttackRecord
{
   
   public var mTransform:B2Transform;
   
   public var mCircle:B2CircleShape;
   
   public var mlife:UInt = 0;
   
   public function new()
   {
      
   }
}

private class AstarGridCircleDraw
{
   
   public static inline final GRID_RADIUS:Float = 0.6;
   
   public var mTransform:B2Transform;
   
   public var mCircle:B2CircleShape;
   
   public var mColor:B2Color;
   
   public var mlife:UInt = 0;
   
   public function new()
   {
      
   }
}

private class AstarGridRectangleDraw
{
   
   public var mTransform:B2Transform;
   
   public var mRectangle:B2PolygonShape;
   
   public var mColor:B2Color;
   
   public var mlife:UInt = 0;
   
   public function new()
   {
      
   }
}

private class PolygonShapeRecord
{
   
   public var mVerticies:Array<ASAny>;
   
   public var mVerticiesAsVector:Vector<B2Vec2>;
   
   public var mShape:B2PolygonShape;
   
   public var mTransform:B2Transform;
   
   public var mLife:UInt = 0;
   
   public function new()
   {
      
   }
   
   public function buildVerticies() 
   {
      var _loc3_= 0;
      var _loc2_:B2Vec2 = null;
      var _loc1_= mShape ;
      mVerticies = [];
      mVerticiesAsVector = new Vector<B2Vec2>();
      _loc3_ = 0;
      while(_loc3_ < _loc1_.GetVertexCount())
      {
         _loc2_ = new B2Vec2(_loc1_.GetVertices()[_loc3_].x,_loc1_.GetVertices()[_loc3_].y);
         _loc2_.Add(mTransform.position);
         mVerticiesAsVector.push(_loc2_);
         mVerticies.push(_loc2_);
         _loc3_ = ASCompat.toInt(_loc3_) + 1;
      }
   }
}

private class ShapeRecord
{
   
   public var mShape:B2Shape;
   
   public var mTransform:B2Transform;
   
   public var mLife:UInt = 0;
   
   public function new()
   {
      
   }
}

private class RayCastDraw
{
   
   public var point1:B2Vec2;
   
   public var point2:B2Vec2;
   
   public var life:UInt = 0;
   
   public function new()
   {
      
   }
}
