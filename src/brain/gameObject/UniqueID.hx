package brain.gameObject
;
   import brain.facade.Facade;
   
    class UniqueID
   {
      
      var mId:UInt = (0 : UInt);
      
      public function new(param1:Facade, param2:UInt, param3:GameObject)
      {
         
         mId = param2;
         param1.gameObjectManager.addIdReference(param2,param3);
      }
      
      @:isVar public var id(get,never):UInt;
public function  get_id() : UInt
      {
         return mId;
      }
      
      public function destroy(param1:Facade) 
      {
         param1.gameObjectManager.removeIdReference(this);
         mId = (0 : UInt);
      }
   }


