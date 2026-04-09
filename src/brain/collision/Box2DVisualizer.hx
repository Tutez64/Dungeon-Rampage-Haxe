package brain.collision
;
   import box2D.dynamics.B2DebugDraw;
   import box2D.dynamics.B2World;
   import brain.clock.GameClock;
   import flash.display.Sprite;
   
    class Box2DVisualizer
   {
      
      var mB2World:B2World;
      
      var mRootSprite:Sprite;
      
      var mDebugDraw:B2DebugDraw;
      
      var mWantAllCollisions:Bool = false;
      
      var mWantNavigationCollisions:Bool = false;
      
      var mWantCombatCollisions:Bool = false;
      
      var mWantAStarVisuals:Bool = false;
      
      public function new(param1:B2World, param2:Bool = false, param3:Bool = false, param4:Bool = false, param5:Bool = false)
      {
         
         mB2World = param1;
         mRootSprite = new Sprite();
         mWantAllCollisions = param2;
         mWantNavigationCollisions = param4;
         mWantCombatCollisions = param3;
         mWantAStarVisuals = param5;
         setupDebugDraw();
      }
      
      function setupDebugDraw() 
      {
         mRootSprite = new Sprite();
         mDebugDraw = new B2DebugDraw();
         var _loc1_= new Sprite();
         mRootSprite.addChild(_loc1_);
         mDebugDraw.SetSprite(mRootSprite);
         mDebugDraw.SetDrawScale(1);
         mDebugDraw.SetAlpha(1);
         mDebugDraw.SetFillAlpha(0.5);
         mDebugDraw.SetLineThickness(1);
         if(mWantAllCollisions || mWantNavigationCollisions)
         {
            mDebugDraw.SetFlags(((B2DebugDraw.e_shapeBit : Int) | (B2DebugDraw.e_jointBit : Int) | (B2DebugDraw.e_controllerBit : Int) | (B2DebugDraw.e_aabbBit : Int) | (B2DebugDraw.e_pairBit : Int) | (B2DebugDraw.e_centerOfMassBit : Int) : UInt));
         }
         mB2World.SetDebugDraw(mDebugDraw);
         mRootSprite.x = 0;
         mRootSprite.y = 0;
      }
      
      @:isVar public var rootSprite(get,never):Sprite;
public function  get_rootSprite() : Sprite
      {
         return mRootSprite;
      }
      
      public function update(param1:GameClock) 
      {
         mB2World.DrawDebugData();
      }
   }


