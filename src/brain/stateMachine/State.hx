package brain.stateMachine
;
    class State
   {
      
      var mName:String = "";
      
      var mFinishedCallback:ASFunction;
      
      var mRunning:Bool = false;
      
      public function new(param1:String, param2:ASFunction = null)
      {
         
         mName = param1;
         mFinishedCallback = param2;
      }
      
      @:isVar public var running(get,never):Bool;
public function  get_running() : Bool
      {
         return mRunning;
      }
      
      @:isVar public var finishedCallback(never,set):ASFunction;
public function  set_finishedCallback(param1:ASFunction) :ASFunction      {
         return mFinishedCallback = param1;
      }
      
      @:isVar public var name(get,never):String;
public function  get_name() : String
      {
         return mName;
      }
      
      public function enterState() 
      {
         mRunning = true;
      }
      
      public function exitState() 
      {
         mRunning = false;
      }
      
      public function destroy() 
      {
         mFinishedCallback = null;
         mRunning = false;
      }
   }


