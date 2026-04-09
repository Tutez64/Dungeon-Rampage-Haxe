package gameMasterDictionary
;
    class GMWeaponMastertype
   {
      
      public var Id:UInt = 0;
      
      public var Constant:String;
      
      public var Name:String;
      
      public var Icon:String;
      
      public var UISwfFilepath:String;
      
      public var Description:String;
      
      public var DontShowInTavern:Bool = false;
      
      public function new(param1:ASObject)
      {
         
         Id = (ASCompat.toInt(param1.Id) : UInt);
         Constant = param1.Constant;
         Name = param1.Name;
         Icon = param1.Icon;
         UISwfFilepath = param1.UISwfFilepath;
         Description = param1.Description;
         DontShowInTavern = ASCompat.toBool(param1.DontShowInTavern != null ? ASCompat.toBool(param1.DontShowInTavern) : false);
      }
   }


