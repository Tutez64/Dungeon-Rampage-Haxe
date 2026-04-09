package dungeon
;
   import brain.render.MovieClipRenderController;
   import facade.DBFacade;
   import dr_floor.FloorView;
   import flash.display.MovieClip;
   
    class PropView extends FloorView
   {
      
      var mBody:MovieClip;
      
      public function new(param1:DBFacade, param2:Prop)
      {
         super(param1,param2);
         mRoot.name = "PropView_" + param2.id;
         mRoot.mouseEnabled = false;
         mRoot.mouseChildren = false;
      }
      
      @:isVar public var body(never,set):MovieClip;
public function  set_body(param1:MovieClip) :MovieClip      {
         mBody = param1;
         mRoot.addChild(mBody);
         var _loc2_:ASAny;
         final __ax4_iter_124 = FloorView.findNavCollisions(mBody);
         if (checkNullIteratee(__ax4_iter_124)) for (_tmp_ in __ax4_iter_124)
         {
            _loc2_ = _tmp_;
            _loc2_.parent.removeChild(_loc2_);
         }
         var _loc3_:ASAny;
         final __ax4_iter_125 = FloorView.findCombatCollisions(mBody);
         if (checkNullIteratee(__ax4_iter_125)) for (_tmp_ in __ax4_iter_125)
         {
            _loc3_ = _tmp_;
            _loc3_.parent.removeChild(_loc3_);
         }
         mMovieClipRenderer = new MovieClipRenderController(mFacade,mBody);
         if(mBody.totalFrames == 1 && !mDBFacade.featureFlags.getFlagValue("want-zoom"))
         {
            mRoot.cacheAsBitmap = true;
            mMovieClipRenderer.play((0 : UInt),false);
         }
         else
         {
            mMovieClipRenderer.play((0 : UInt),true);
         }
return param1;
      }
      
      override public function destroy() 
      {
         mBody = null;
         super.destroy();
      }
   }


