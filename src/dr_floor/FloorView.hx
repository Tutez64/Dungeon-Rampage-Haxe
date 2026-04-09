package dr_floor
;
   import brain.gameObject.View;
   import brain.logger.Logger;
   import dungeon.NavCollider;
   import facade.DBFacade;
   import flash.display.DisplayObjectContainer;
   import flash.geom.Vector3D;
   
    class FloorView extends View
   {
      
      var mParentFloorObject:FloorObject;
      
      var mLayer:Int = 0;
      
      var mDBFacade:DBFacade;
      
      public function new(param1:DBFacade, param2:FloorObject)
      {
         mDBFacade = param1;
         super(param1);
         mParentFloorObject = param2;
      }
      
      public static function findNavCollisions(param1:DisplayObjectContainer) : Array<ASAny>
      {
         return View.findChildrenOfClass(param1,["NavCollisionCircle","NavCollisionRectangle"]);
      }
      
      public static function findCombatCollisions(param1:DisplayObjectContainer) : Array<ASAny>
      {
         return View.findChildrenOfClass(param1,["CombatCollisionCircle","CombatCollisionRectangle"]);
      }
      
      override public function  set_position(param1:Vector3D) :Vector3D      {
         super.position = param1;
         var _loc2_:NavCollider;
         final __ax4_iter_189 = mParentFloorObject.navCollisions;
         if (checkNullIteratee(__ax4_iter_189)) for (_tmp_ in __ax4_iter_189)
         {
            _loc2_ = _tmp_;
            ASCompat.setProperty(_loc2_, "position", param1);
         }
return param1;
      }
      
      @:isVar public var worldCenter(get,never):Vector3D;
public function  get_worldCenter() : Vector3D
      {
         return mParentFloorObject.worldCenter;
      }
      
      public function addToStage() 
      {
         if(this.layer == 0)
         {
            Logger.error("Tried to addToStage with layer == 0");
         }
         else
         {
            mSceneGraphComponent.addChild(this.root,(this.layer : UInt));
            checkoutMovieClipRenderers();
         }
      }
      
      public function removeFromStage() 
      {
         if(this.layer != 0 && mSceneGraphComponent.contains(this.root,(this.layer : UInt)))
         {
            mSceneGraphComponent.removeChild(this.root);
         }
         checkinMovieClipRenderers();
      }
      
      function checkoutMovieClipRenderers() 
      {
      }
      
      function checkinMovieClipRenderers() 
      {
      }
      
            
      @:isVar public var layer(get,set):Int;
public function  set_layer(param1:Int) :Int      {
         return mLayer = param1;
      }
      
      override public function destroy() 
      {
         mParentFloorObject = null;
         mDBFacade = null;
         super.destroy();
      }
function  get_layer() : Int
      {
         return mLayer;
      }
   }


