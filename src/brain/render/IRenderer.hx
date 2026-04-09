package brain.render
;
   import flash.display.DisplayObject;
   
    interface IRenderer
   {
      
      @:isVar var rendererType(get,never):String;
      
      function play(param1:UInt = (0 : UInt), param2:Bool = true, param3:ASFunction = null) : Void;
      
      function stop() : Void;
      
      @:isVar var currentFrame(get,never):UInt;
      
      @:isVar var loop(get,never):Bool;
      
      function setFrame(param1:UInt) : Void;
      
      @:isVar var displayObject(get,never):DisplayObject;
      
      @:isVar var heading(never,set):Float;
      
      function destroy() : Void;
      
      @:isVar var durationInSeconds(get,never):Float;
      
      @:isVar var frameCount(get,never):Float;
      
            
      @:isVar var playRate(get,set):Float;
      
      @:isVar var isPlaying(get,never):Bool;
   }


