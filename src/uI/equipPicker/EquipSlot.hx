package uI.equipPicker
;
   import brain.uI.UIObject;
   import facade.DBFacade;
   import flash.display.MovieClip;
   
    class EquipSlot extends UIObject
   {
      
      var mEquipPicker_handleItemDrop:ASFunction;
      
      var mEquipSlot:UInt = 0;
      
      public function new(param1:DBFacade, param2:MovieClip, param3:ASFunction, param4:UInt)
      {
         super(param1,param2);
         mEquipPicker_handleItemDrop = param3;
         mEquipSlot = param4;
      }
      
      override public function handleDrop(param1:UIObject) : Bool
      {
         return ASCompat.toBool(mEquipPicker_handleItemDrop(param1,null,mEquipSlot));
      }
   }


