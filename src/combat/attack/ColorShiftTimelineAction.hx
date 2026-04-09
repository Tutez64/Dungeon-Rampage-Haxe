package combat.attack
;
   import actor.ActorGameObject;
   import actor.ActorView;
   import brain.clock.GameClock;
   import brain.workLoop.Task;
   import facade.DBFacade;
   import flash.geom.ColorTransform;
   import flash.geom.Vector3D;
   
    class ColorShiftTimelineAction extends AttackTimelineAction
   {
      
      public static inline final TYPE= "color";
      
      var mDuration:UInt = 0;
      
      var mColorMul:Vector3D;
      
      var mColorAdd:Vector3D;
      
      var mAlphaMul:Float = Math.NaN;
      
      var mAlphaAdd:Float = Math.NaN;
      
      var mOldColorTransform:ColorTransform;
      
      var mColorTransformTask:Task;
      
      var mFramesElapsed:UInt = (0 : UInt);
      
      var mOffsets:ColorTransform;
      
      var mTransitionDuration:Float = Math.NaN;
      
      public function new(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:UInt, param5:Vector3D, param6:Vector3D, param7:Float, param8:Float, param9:Float)
      {
         mDuration = param4;
         mColorMul = new Vector3D(param5.x,param5.y,param5.z);
         mColorAdd = new Vector3D(param6.x,param6.y,param6.z);
         mAlphaMul = param7;
         mAlphaAdd = param8;
         mTransitionDuration = param9;
         super(param1,param2,param3);
         mOldColorTransform = new ColorTransform();
         mOffsets = new ColorTransform();
      }
      
      public static function buildFromJson(param1:ActorGameObject, param2:ActorView, param3:DBFacade, param4:ASObject) : ColorShiftTimelineAction
      {
         var _loc5_= ASCompat.toNumber(param4.duration);
         var _loc10_= new Vector3D(ASCompat.toNumberField(param4, "filter_r"),ASCompat.toNumberField(param4, "filter_g"),ASCompat.toNumberField(param4, "filter_b"));
         var _loc7_= new Vector3D(ASCompat.toNumberField(param4, "add_r"),ASCompat.toNumberField(param4, "add_g"),ASCompat.toNumberField(param4, "add_b"));
         var _loc6_= ASCompat.toNumber(param4.filter_alpha);
         var _loc9_= ASCompat.toNumber(param4.add_alpha);
         var _loc8_= ASCompat.toNumber(param4.transitionDur);
         return new ColorShiftTimelineAction(param1,param2,param3,(Std.int(_loc5_) : UInt),_loc10_,_loc7_,_loc6_,_loc9_,_loc8_);
      }
      
      function CopyColorTransform(param1:ColorTransform) : ColorTransform
      {
         var _loc2_= new ColorTransform();
         _loc2_.alphaMultiplier = param1.alphaMultiplier;
         _loc2_.alphaOffset = param1.alphaOffset;
         _loc2_.blueMultiplier = param1.blueMultiplier;
         _loc2_.blueOffset = param1.blueOffset;
         _loc2_.redMultiplier = param1.redMultiplier;
         _loc2_.redOffset = param1.redOffset;
         _loc2_.greenMultiplier = param1.greenMultiplier;
         _loc2_.greenOffset = param1.greenOffset;
         return _loc2_;
      }
      
      function CalculateColorTransformOffsets(param1:ColorTransform, param2:ColorTransform, param3:Float) 
      {
         mOffsets.alphaMultiplier = (param2.alphaMultiplier - param1.alphaMultiplier) / param3;
         mOffsets.alphaOffset = (param2.alphaOffset - param1.alphaOffset) / param3;
         mOffsets.blueMultiplier = (param2.blueMultiplier - param1.blueMultiplier) / param3;
         mOffsets.blueOffset = (param2.blueOffset - param1.blueOffset) / param3;
         mOffsets.redMultiplier = (param2.redMultiplier - param1.redMultiplier) / param3;
         mOffsets.redOffset = (param2.redOffset - param1.redOffset) / param3;
         mOffsets.greenMultiplier = (param2.greenMultiplier - param1.greenMultiplier) / param3;
         mOffsets.greenOffset = (param2.greenOffset - param1.greenOffset) / param3;
      }
      
      function AddColorTransformOffsets() : ColorTransform
      {
         var _loc1_= new ColorTransform();
         var _loc2_= mActorView.body.transform.colorTransform;
         _loc1_.alphaMultiplier = _loc2_.alphaMultiplier + mOffsets.alphaMultiplier;
         _loc1_.alphaOffset = _loc2_.alphaOffset + mOffsets.alphaOffset;
         _loc1_.blueMultiplier = _loc2_.blueMultiplier + mOffsets.blueMultiplier;
         _loc1_.blueOffset = _loc2_.blueOffset + mOffsets.blueOffset;
         _loc1_.redMultiplier = _loc2_.redMultiplier + mOffsets.redMultiplier;
         _loc1_.redOffset = _loc2_.redOffset + mOffsets.redOffset;
         _loc1_.greenMultiplier = _loc2_.greenMultiplier + mOffsets.greenMultiplier;
         _loc1_.greenOffset = _loc2_.greenOffset + mOffsets.greenOffset;
         return _loc1_;
      }
      
      function SubtractColorTransformOffsets() : ColorTransform
      {
         var _loc1_= new ColorTransform();
         var _loc2_= mActorView.body.transform.colorTransform;
         _loc1_.alphaMultiplier = _loc2_.alphaMultiplier - mOffsets.alphaMultiplier;
         _loc1_.alphaOffset = _loc2_.alphaOffset - mOffsets.alphaOffset;
         _loc1_.blueMultiplier = _loc2_.blueMultiplier - mOffsets.blueMultiplier;
         _loc1_.blueOffset = _loc2_.blueOffset - mOffsets.blueOffset;
         _loc1_.redMultiplier = _loc2_.redMultiplier - mOffsets.redMultiplier;
         _loc1_.redOffset = _loc2_.redOffset - mOffsets.redOffset;
         _loc1_.greenMultiplier = _loc2_.greenMultiplier - mOffsets.greenMultiplier;
         _loc1_.greenOffset = _loc2_.greenOffset - mOffsets.greenOffset;
         return _loc1_;
      }
      
      override public function execute(param1:ScriptTimeline) 
      {
         super.execute(param1);
         if(mFramesElapsed != 0)
         {
            ResetColorTransform();
         }
         mFramesElapsed = (0 : UInt);
         mOldColorTransform = CopyColorTransform(new ColorTransform());
         var _loc2_= new ColorTransform(mColorMul.x,mColorMul.y,mColorMul.z,mAlphaMul,mColorAdd.x,mColorAdd.y,mColorAdd.z,mAlphaAdd);
         CalculateColorTransformOffsets(mOldColorTransform,_loc2_,mTransitionDuration);
         if(mColorTransformTask != null)
         {
            mColorTransformTask.destroy();
            mColorTransformTask = null;
         }
         if(mWorkComponent != null)
         {
            mColorTransformTask = mWorkComponent.doEveryFrame(UpdateColorShift);
         }
      }
      
      public function UpdateColorShift(param1:GameClock) 
      {
         if(mActorView != null && mActorView.body != null)
         {
            mFramesElapsed = mFramesElapsed + 1;
            if(mFramesElapsed <= mTransitionDuration)
            {
               mActorView.body.transform.colorTransform = AddColorTransformOffsets();
            }
            else if(mFramesElapsed >= mDuration - mTransitionDuration)
            {
               mActorView.body.transform.colorTransform = SubtractColorTransformOffsets();
            }
            if(mFramesElapsed > mDuration)
            {
               ResetColorTransform();
               return;
            }
            return;
         }
         ResetColorTransform();
      }
      
      function ResetColorTransform() 
      {
         mFramesElapsed = (0 : UInt);
         if(mActorView != null && mActorView.body != null)
         {
            mActorView.body.transform.colorTransform = CopyColorTransform(mOldColorTransform);
         }
         if(mColorTransformTask != null)
         {
            mColorTransformTask.destroy();
            mColorTransformTask = null;
         }
      }
      
      override public function destroy() 
      {
         if(mColorTransformTask != null)
         {
            mColorTransformTask.destroy();
            mColorTransformTask = null;
         }
         super.destroy();
      }
   }


