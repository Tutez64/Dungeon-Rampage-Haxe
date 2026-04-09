package uI.equipPicker
;
   import account.ItemInfo;
   import account.StackableInfo;
   import facade.DBFacade;
   import gameMasterDictionary.GMStackable;
   import flash.display.MovieClip;
   
    class ConsumableEquipElement extends AvatarEquipElement
   {
      
      var mStackableInfo:StackableInfo;
      
      public function new(param1:DBFacade, param2:String, param3:MovieClip, param4:Dynamic, param5:ASFunction, param6:ASFunction, param7:UInt, param8:ASFunction = null, param9:ASFunction = null, param10:Bool = false)
      {
         super(param1,param2,param3,param4,param5,param6,param7,param8,param9,param10);
         ASCompat.setProperty((mRoot : ASAny).textx, "visible", false);
         ASCompat.setProperty((mRoot : ASAny).quantity, "visible", false);
      }
      
      override public function clear() 
      {
         super.clear();
         ASCompat.setProperty((mRoot : ASAny).textx, "visible", false);
         ASCompat.setProperty((mRoot : ASAny).quantity, "visible", false);
      }
      
      public function init(param1:GMStackable, param2:UInt, param3:UInt) 
      {
         var _loc4_:ItemInfo = null;
         clear();
         mStackableInfo = new StackableInfo(mDBFacade,null,param1);
         stackableInfo.setPropertiesAsConsumable(param1.Id,param2,param3);
         mItemInfo = stackableInfo;
         if(mItemInfo != null)
         {
            ASCompat.setProperty((mRoot : ASAny).frame, "alpha", 1);
            loadItemIcon();
            _loc4_ = ASCompat.reinterpretAs(mItemInfo , ItemInfo);
            if(_loc4_ == null)
            {
            }
            draggable = true;
         }
         else
         {
            ASCompat.setProperty((mRoot : ASAny).frame, "alpha", 0);
            draggable = false;
         }
         ASCompat.setProperty((mRoot : ASAny).textx, "visible", true);
         ASCompat.setProperty((mRoot : ASAny).quantity, "visible", true);
         ASCompat.setProperty((mRoot : ASAny).quantity, "text", Std.string(param3));
      }
      
      @:isVar public var stackableInfo(get,never):StackableInfo;
public function  get_stackableInfo() : StackableInfo
      {
         return mStackableInfo;
      }
      
      override function resetDragUnequipFunc() 
      {
         mUnequipCallback(mItemInfo,mEquipSlot,mEquipResponseCallback);
      }
   }


