package actor.player.input
;
   import flash.geom.Vector3D;
   
    interface IMouseController
   {
      
      function init() : Void;
      
      function stop() : Void;
      
      function clearMovement() : Void;
      
      function perFrameUpCall() : Void;
      
      @:isVar var combatDisabled(never,set):Bool;
      
      @:isVar var potentialAttacksThisFrame(get,never):Array<ASAny>;
      
      @:isVar var inputVelocity(get,never):Vector3D;
      
      @:isVar var inputHeading(get,never):Vector3D;
      
      function destroy() : Void;
   }


