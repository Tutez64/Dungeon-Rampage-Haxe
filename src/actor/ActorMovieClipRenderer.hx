package actor
;
   import brain.render.IRenderer;
   import brain.render.MovieClipRenderController;
   import facade.DBFacade;
   import dr_floor.FloorView;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
    class ActorMovieClipRenderer extends MovieClipRenderController implements IRenderer
   {
      
      public static var MOVIE_CLIP_RENDERER_TYPE:String = "MovieClipRenderer";
      
      var mDBFacade:DBFacade;
      
      var mHeading:Float = Math.NaN;
      
      public function new(param1:DBFacade, param2:MovieClip)
      {
         super(param1,param2);
         mDBFacade = param1;
         var _loc3_:ASAny;
         final __ax4_iter_24 = FloorView.findNavCollisions(param2);
         if (checkNullIteratee(__ax4_iter_24)) for (_tmp_ in __ax4_iter_24)
         {
            _loc3_ = _tmp_;
            _loc3_.parent.removeChild(_loc3_);
         }
         var _loc4_:ASAny;
         final __ax4_iter_25 = FloorView.findCombatCollisions(param2);
         if (checkNullIteratee(__ax4_iter_25)) for (_tmp_ in __ax4_iter_25)
         {
            _loc4_ = _tmp_;
            _loc4_.parent.removeChild(_loc4_);
         }
      }
      
      @:isVar public var displayObject(get,never):DisplayObject;
public function  get_displayObject() : DisplayObject
      {
         return mClip;
      }
      
      @:isVar public var rendererType(get,never):String;
public function  get_rendererType() : String
      {
         return MOVIE_CLIP_RENDERER_TYPE;
      }
      
      @:isVar public var heading(never,set):Float;
public function  set_heading(param1:Float) :Float      {
         return mHeading = param1;
      }
      
      override public function destroy() 
      {
         mDBFacade = null;
         super.destroy();
      }
   }


