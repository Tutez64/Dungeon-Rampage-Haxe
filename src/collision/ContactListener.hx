package collision
;
   import box2D.dynamics.contacts.B2Contact;
   import box2D.dynamics.B2ContactListener;
   import facade.DBFacade;
   
    class ContactListener extends B2ContactListener
   {
      
      var mDBFacade:DBFacade;
      
      var mContactList:Vector<CollisionHelper> = new Vector();
      
      public function new(param1:DBFacade)
      {
         mDBFacade = param1;
         super();
      }
      
      override public function BeginContact(param1:B2Contact) 
      {
         var _loc4_= 0;
         var _loc3_= 0;
         var _loc2_:IContactResolver = null;
         var _loc7_:IContactResolver = null;
         var _loc6_= param1.GetFixtureA();
         var _loc5_= param1.GetFixtureB();
         if(_loc6_.IsSensor() && _loc5_.IsSensor())
         {
            return;
         }
         if(_loc6_.IsSensor())
         {
            if(Std.isOfType(_loc6_.GetUserData() , IContactResolver))
            {
               _loc2_ = ASCompat.dynamicAs(_loc6_.GetUserData() , IContactResolver);
            }
            else
            {
               _loc4_ = (ASCompat.asUint(_loc6_.GetUserData() ) : Int);
               _loc2_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId((_loc4_ : UInt)) , IContactResolver);
            }
            _loc3_ = (ASCompat.asUint(_loc5_.GetBody().GetUserData() ) : Int);
            mContactList.push(new CollisionHelper(_loc2_,(_loc3_ : UInt),_loc2_.enterContact));
         }
         if(_loc5_.IsSensor())
         {
            if(Std.isOfType(_loc5_.GetUserData() , IContactResolver))
            {
               _loc7_ = ASCompat.dynamicAs(_loc5_.GetUserData() , IContactResolver);
            }
            else
            {
               _loc3_ = (ASCompat.asUint(_loc5_.GetUserData() ) : Int);
               _loc7_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId((_loc3_ : UInt)) , IContactResolver);
            }
            _loc4_ = (ASCompat.asUint(_loc6_.GetBody().GetUserData() ) : Int);
            mContactList.push(new CollisionHelper(_loc7_,(_loc4_ : UInt),_loc7_.enterContact));
         }
      }
      
      override public function EndContact(param1:B2Contact) 
      {
         var _loc4_= 0;
         var _loc3_= 0;
         var _loc2_:IContactResolver = null;
         var _loc7_:IContactResolver = null;
         var _loc6_= param1.GetFixtureA();
         var _loc5_= param1.GetFixtureB();
         if(_loc6_.IsSensor() && _loc5_.IsSensor())
         {
            return;
         }
         if(_loc6_.IsSensor())
         {
            if(Std.isOfType(_loc6_.GetUserData() , IContactResolver))
            {
               _loc2_ = ASCompat.dynamicAs(_loc6_.GetUserData() , IContactResolver);
            }
            else
            {
               _loc4_ = (ASCompat.asUint(_loc6_.GetUserData() ) : Int);
               _loc2_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId((_loc4_ : UInt)) , IContactResolver);
            }
            _loc3_ = (ASCompat.asUint(_loc5_.GetBody().GetUserData() ) : Int);
            mContactList.push(new CollisionHelper(_loc2_,(_loc3_ : UInt),_loc2_.exitContact));
         }
         if(_loc5_.IsSensor())
         {
            if(Std.isOfType(_loc5_.GetUserData() , IContactResolver))
            {
               _loc7_ = ASCompat.dynamicAs(_loc5_.GetUserData() , IContactResolver);
            }
            else
            {
               _loc3_ = (ASCompat.asUint(_loc5_.GetUserData() ) : Int);
               _loc7_ = ASCompat.reinterpretAs(mDBFacade.gameObjectManager.getReferenceFromId((_loc3_ : UInt)) , IContactResolver);
            }
            _loc4_ = (ASCompat.asUint(_loc6_.GetBody().GetUserData() ) : Int);
            mContactList.push(new CollisionHelper(_loc7_,(_loc4_ : UInt),_loc7_.exitContact));
         }
      }
      
      public function processCollisions() 
      {
         var _loc1_:CollisionHelper;
         final __ax4_iter_230 = mContactList;
         if (checkNullIteratee(__ax4_iter_230)) for (_tmp_ in __ax4_iter_230)
         {
            _loc1_ = _tmp_;
            _loc1_.functionToExecute(_loc1_.actorId);
         }
         mContactList.length = 0;
      }
   }


private class CollisionHelper
{
   
   public var contactResolver:IContactResolver;
   
   public var actorId:UInt = 0;
   
   public var functionToExecute:ASFunction;
   
   public function new(param1:IContactResolver, param2:UInt, param3:ASFunction)
   {
      
      contactResolver = param1;
      actorId = param2;
      functionToExecute = param3;
   }
}
