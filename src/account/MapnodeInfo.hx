package account
;
    class MapnodeInfo
   {
      
      public static inline final NODE_STATE_DEFEATED= (1 : UInt);
      
      public static inline final NODE_STATE_OPEN= (2 : UInt);
      
      public static inline final NODE_STATE_OPEN_NOT_DEFEATED= (3 : UInt);
      
      var mMapnodeJson:ASObject;
      
      var mMapnodeId:UInt = 0;
      
      var mAccountId:UInt = 0;
      
      var mId:UInt = 0;
      
      var mMapnodeState:UInt = 0;
      
      var mResponseCallback:ASFunction;
      
      var mCallbackSuccess:ASFunction;
      
      var mCallbackFailure:ASFunction;
      
      public function new()
      {
         
      }
      
      @:isVar public var id(get,never):UInt;
public function  get_id() : UInt
      {
         return mId;
      }
      
      @:isVar public var nodeId(get,never):UInt;
public function  get_nodeId() : UInt
      {
         return mMapnodeId;
      }
      
            
      @:isVar public var MapnodeState(get,set):UInt;
public function  get_MapnodeState() : UInt
      {
         return mMapnodeState;
      }
function  set_MapnodeState(param1:UInt) :UInt      {
         return mMapnodeState = param1;
      }
      
      public function init(param1:UInt, param2:UInt) 
      {
         mMapnodeId = param1;
         mMapnodeState = param2;
      }
      
      function parseMapnodeJson(param1:ASObject) 
      {
         if(param1 == null)
         {
            return;
         }
         mMapnodeId = ASCompat.asUint(param1.node_id );
         mAccountId = ASCompat.asUint(param1.account_id );
         mId = ASCompat.asUint(param1.id );
         mMapnodeState = ASCompat.asUint(param1.node_state );
      }
      
      public function parseResponse(param1:ASObject) 
      {
         if(param1 == null)
         {
            return;
         }
         mMapnodeId = ASCompat.asUint(param1.node_id );
         mAccountId = ASCompat.asUint(param1.account_id );
         mId = ASCompat.asUint(param1.id );
         mMapnodeState = ASCompat.asUint(param1.node_state );
         if(mCallbackSuccess != null)
         {
            mCallbackSuccess(this);
         }
      }
   }


