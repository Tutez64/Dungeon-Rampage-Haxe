package uI.training
;
   import brain.uI.UIProgressBar;
   import facade.DBFacade;
   import flash.display.MovieClip;
   
    class UIStatProgressBar
   {
      
      var mDBFacade:DBFacade;
      
      var mProgressBar:UIProgressBar;
      
      var mCompletedClip:MovieClip;
      
      public function new(param1:DBFacade, param2:MovieClip, param3:MovieClip)
      {
         
         mDBFacade = param1;
         mProgressBar = new UIProgressBar(mDBFacade,ASCompat.dynamicAs((param2 : ASAny).training_bar, flash.display.MovieClip));
         mProgressBar.enabled = false;
         mCompletedClip = param3;
         completed = false;
      }
      
      @:isVar public var progressBar(get,never):UIProgressBar;
public function  get_progressBar() : UIProgressBar
      {
         return mProgressBar;
      }
      
      @:isVar public var value(never,set):Float;
public function  set_value(param1:Float) :Float      {
         return mProgressBar.value = param1;
      }
      
      @:isVar public var completed(never,set):Bool;
public function  set_completed(param1:Bool) :Bool      {
         return mCompletedClip.visible = param1;
      }
      
      public function destroy() 
      {
         mProgressBar.destroy();
      }
   }


