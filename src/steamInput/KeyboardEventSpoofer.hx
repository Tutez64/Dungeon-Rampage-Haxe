package steamInput
;
   import flash.display.Stage;
   import flash.events.KeyboardEvent;
   
    class KeyboardEventSpoofer
   {
      
      var mStageRef:Stage;
      
      var mKeyboardEventsSpoofMap:KeyboardEventsSpoofMap = new KeyboardEventsSpoofMap();
      
      var mPressedActions:ASDictionary<ASAny,ASAny> = new ASDictionary();
      
      public function new(param1:Stage)
      {
         
         mStageRef = param1;
      }
      
      public function update(param1:SteamInputManager) 
      {
         var _loc2_:String;
         final __ax4_iter_89 = mKeyboardEventsSpoofMap.actionNames;
         if (checkNullIteratee(__ax4_iter_89)) for (_tmp_ in __ax4_iter_89)
         {
            _loc2_ = _tmp_;
            if(param1.releasedAction(_loc2_))
            {
               handleReleasedAction(_loc2_);
            }
            if(param1.pressedAction(_loc2_))
            {
               handlePressedAction(_loc2_);
            }
         }
      }
      
      function handleReleasedAction(param1:String) 
      {
         if(mPressedActions.exists(param1 ))
         {
            fireReleasedEvent(param1);
            mPressedActions.remove(param1);
         }
      }
      
      function handlePressedAction(param1:String) 
      {
         if(mPressedActions.exists(param1 ))
         {
            return;
         }
         mPressedActions[param1] = true;
         firePressedEvent(param1);
      }
      
      function fireReleasedEvent(param1:String) 
      {
         fireKeyboardEvent("keyUp",param1);
      }
      
      function firePressedEvent(param1:String) 
      {
         fireKeyboardEvent("keyDown",param1);
      }
      
      function fireKeyboardEvent(param1:String, param2:String) 
      {
         var _loc3_= mKeyboardEventsSpoofMap.getKeyCode(param2);
         var _loc4_= new KeyboardEvent(param1,true,false,(0 : UInt),(_loc3_ : UInt));
         mStageRef.dispatchEvent(_loc4_);
      }
   }


