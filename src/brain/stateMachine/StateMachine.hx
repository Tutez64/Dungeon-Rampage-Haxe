package brain.stateMachine
;
   import brain.logger.Logger;
   
    class StateMachine
   {
      
      var mCurrentState:State;
      
      public function new()
      {
         
      }
      
            
      @:isVar public var currentState(get,set):State;
public function  get_currentState() : State
      {
         return mCurrentState;
      }
function  set_currentState(param1:State) :State      {
         return mCurrentState = param1;
      }
      
      @:isVar public var currentStateName(get,never):String;
public function  get_currentStateName() : String
      {
         if(mCurrentState != null)
         {
            return mCurrentState.name;
         }
         return "";
      }
      
      public function transitionToState(param1:State) : Bool
      {
         if(mCurrentState != null)
         {
            if(!mCurrentState.running)
            {
               Logger.warn("transitionToState (" + param1.name + ") but old state (" + mCurrentState.name + ") was not running.");
            }
            mCurrentState.exitState();
         }
         mCurrentState = param1;
         mCurrentState.enterState();
         return true;
      }
      
      public function destroy() 
      {
         if(mCurrentState != null && mCurrentState.running)
         {
            mCurrentState.exitState();
         }
         mCurrentState = null;
      }
   }


