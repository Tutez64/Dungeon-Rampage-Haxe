package generatedCode
;
   import brain.gameObject.GameObject;
   import flash.geom.Vector3D;
   
    interface IHeroGameObject
   {
      
      function setNetworkComponentHeroGameObject(param1:HeroGameObjectNetworkComponent) : Void;
      
      function postGenerate() : Void;
      
      function getTrueObject() : GameObject;
      
      function destroy() : Void;
      
      @:isVar var type(never,set):UInt;
      
      @:isVar var position(never,set):Vector3D;
      
      @:isVar var heading(never,set):Float;
      
      @:isVar var scale(never,set):Float;
      
      @:isVar var flip(never,set):UInt;
      
      @:isVar var hitPoints(never,set):UInt;
      
      @:isVar var weaponDetails(never,set):Vector<WeaponDetails>;
      
      @:isVar var consumableDetails(never,set):Vector<ConsumableDetails>;
      
      @:isVar var healthBombsUsed(never,set):UInt;
      
      @:isVar var partyBombsUsed(never,set):UInt;
      
      @:isVar var playerID(never,set):UInt;
      
      @:isVar var state(never,set):String;
      
      @:isVar var team(never,set):Int;
      
      function ReceiveAttackChoreography(param1:AttackChoreography) : Void;
      
      function ReceiveCombatResult(param1:CombatResult) : Void;
      
      @:isVar var skinType(never,set):UInt;
      
      @:isVar var screenName(never,set):String;
      
      @:isVar var manaPoints(never,set):UInt;
      
      @:isVar var experiencePoints(never,set):UInt;
      
      @:isVar var slotPoints(never,set):Vector<UInt>;
      
      @:isVar var dungeonBusterPoints(never,set):UInt;
      
      @:isVar var setAFK(never,set):UInt;
      
      function PartyBomb(param1:UInt) : Void;
      
      function setStateAndAttackChoreography(param1:String, param2:AttackChoreography) : Void;
      
      function StopChoreography() : Void;
   }


