package combat.attack
;
   import actor.ActorGameObject;
   import box2D.collision.shapes.B2Shape;
   import box2D.common.math.B2Transform;
   import box2D.dynamics.B2World;
   import brain.logger.Logger;
   import dungeon.NavCollider;
   import facade.DBFacade;
   import flash.geom.Vector3D;
   
    class CombatCollider
   {
      
      var mDBFacade:DBFacade;
      
      var mParentGameObject:ActorGameObject;
      
      var mBox2DWorld:B2World;
      
      var mB2Shape:B2Shape;
      
      var mB2Transform:B2Transform;
      
      public function new(param1:DBFacade, param2:ActorGameObject, param3:B2World)
      {
         
         mDBFacade = param1;
         mParentGameObject = param2;
         mBox2DWorld = param3;
         buildShape();
      }
      
      @:isVar public var shape(get,never):B2Shape;
public function  get_shape() : B2Shape
      {
         return mB2Shape;
      }
      
      @:isVar public var transform(get,never):B2Transform;
public function  get_transform() : B2Transform
      {
         return mB2Transform;
      }
      
      function buildShape() 
      {
         Logger.error("buildShape needs to be overridden by the subclasses.");
      }
      
      @:isVar public var position(never,set):Vector3D;
public function  set_position(param1:Vector3D) :Vector3D      {
         mB2Transform.position = NavCollider.convertToB2Vec2(param1);
return param1;
      }
      
      @:isVar public var worldPosition(get,never):Vector3D;
public function  get_worldPosition() : Vector3D
      {
         return NavCollider.convertToVector3D(mB2Transform.position);
      }
      
      public function destroy() 
      {
         mDBFacade = null;
         mParentGameObject = null;
         mBox2DWorld = null;
         mB2Shape = null;
         mB2Transform = null;
      }
   }


