package combat.attack
;
   import actor.ActorGameObject;
   import box2D.collision.shapes.B2CircleShape;
   import box2D.common.math.B2Transform;
   import box2D.dynamics.B2World;
   import facade.DBFacade;
   
    class CircleCombatCollider extends CombatCollider
   {
      
      var mRadius:Float = Math.NaN;
      
      public function new(param1:DBFacade, param2:ActorGameObject, param3:B2World, param4:Float)
      {
         mRadius = param4 / 50;
         super(param1,param2,param3);
      }
      
      override function buildShape() 
      {
         var _loc1_= new B2CircleShape(mRadius);
         mB2Shape = _loc1_;
         mB2Transform = new B2Transform();
         if(mParentGameObject.distributedDungeonFloor.debugVisualizer != null)
         {
            mParentGameObject.distributedDungeonFloor.debugVisualizer.reportCircleAttack(mB2Transform,_loc1_);
         }
      }
   }


