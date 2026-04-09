package brain.gameObject
;
   import brain.facade.Facade;
   import brain.utils.MemoryTracker;
   
    class GameObject
   {
      
      var mFacade:Facade;
      
      var mId:UniqueID;
      
      var mIsInitialized:Bool = false;
      
      var mIsDestroyed:Bool = false;
      
      public function new(param1:Facade, param2:UInt = (0 : UInt))
      {
         
         if(param2 == 0)
         {
            mId = new LocalUniqueID(param1,this);
         }
         else
         {
            mId = new UniqueID(param1,param2,this);
         }
         mFacade = param1;
         MemoryTracker.track(this,"GameObject id=" + mId.id + " - created in GameObject()","brain");
      }
      
      @:isVar public var isInitialized(get,never):Bool;
public function  get_isInitialized() : Bool
      {
         return mIsInitialized;
      }
      
      @:isVar public var isDestroyed(get,never):Bool;
public function  get_isDestroyed() : Bool
      {
         return mIsDestroyed;
      }
      
      public function init() 
      {
         mIsInitialized = true;
      }
      
      public function getTrueObject() : GameObject
      {
         return this;
      }
      
      public function destroy() 
      {
         if(!mIsDestroyed)
         {
            mId.destroy(mFacade);
            mId = null;
            mFacade = null;
            mIsDestroyed = true;
         }
      }
      
      @:isVar public var id(get,never):UInt;
public function  get_id() : UInt
      {
         return mId.id;
      }
      
      public function newNetworkChild(param1:GameObject) 
      {
      }
      
      public function InterestClosure() 
      {
      }
   }


