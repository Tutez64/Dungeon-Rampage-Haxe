package steamInput
;
    class InGameControlsActionSetData
   {
      
      public static inline final actionSetName= "InGameControls";
      
      public static inline final movementAction= "game_movement";
      
      public static inline final holdInPlaceAction= "hold_in_place";
      
      public static inline final attackWeapon1Action= "attack_weapon_1";
      
      public static inline final attackWeapon2Action= "attack_weapon_2";
      
      public static inline final attackWeapon3Action= "attack_weapon_3";
      
      public static inline final useConsumable1Action= "use_consumable_one";
      
      public static inline final useConsumable2Action= "use_consumable_two";
      
      public static inline final useDungeonBusterAction= "use_dungeon_buster";
      
      public static inline final reviveAllyAction= "revive_ally";
      
      public static inline final toggleMenuAction= "toggle_menu";
      
      public function new()
      {
         
      }
      
      public static function gatherAnalogActionNames() : Vector<String>
      {
         var _loc1_= new Vector<String>();
         _loc1_.push("game_movement");
         return _loc1_;
      }
      
      public static function gatherDigitalActionNames() : Vector<String>
      {
         var _loc1_= new Vector<String>();
         _loc1_.push("hold_in_place");
         _loc1_.push("attack_weapon_1");
         _loc1_.push("attack_weapon_2");
         _loc1_.push("attack_weapon_3");
         _loc1_.push("use_dungeon_buster");
         _loc1_.push("use_consumable_one");
         _loc1_.push("use_consumable_two");
         _loc1_.push("revive_ally");
         _loc1_.push("toggle_menu");
         return _loc1_;
      }
   }


