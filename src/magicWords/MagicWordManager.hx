package magicWords
;
   import brain.clock.GameClock;
   import brain.logger.Logger;
   import brain.jsonRPC.JSONRPCService;
   import facade.DBFacade;
   import com.junkbyte.console.KeyBind;
   
    class MagicWordManager
   {
      
      var mDBFacade:DBFacade;
      
      var mCheckedAdmin:Bool = false;
      
      var mIsAdmin:Bool = false;
      
      public function new(param1:DBFacade)
      {
         
         mDBFacade = param1;
         setupClientWords();
         setupPhpServerWords();
         Logger.bindKey(new KeyBind("`"),askForAdmin);
      }
      
      public function askForAdmin() 
      {
         var askForAdminFunc:ASFunction;
         if(!mCheckedAdmin)
         {
            askForAdminFunc = JSONRPCService.getFunction("AskIfAdmin",mDBFacade.rpcRoot + "webMagicWord");
            askForAdminFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,mDBFacade.demographics,function(param1:Int)
            {
               if(param1 != 0)
               {
                  mIsAdmin = true;
                  Logger.enableCommandLine();
                  Logger.displayConsole();
                  Logger.log("Setting Console Commands for admin. Push the CL button on top of this frame for the commandline.");
               }
               else
               {
                  Logger.log("You are not an admin.");
               }
               mCheckedAdmin = true;
            },function(param1:Error)
            {
               Logger.log("PhpTime: ERROR:" + Std.string(param1));
            });
         }
         else if(mIsAdmin)
         {
            if(Logger.isConsoleVisible())
            {
               Logger.hideConsole();
            }
            else
            {
               Logger.displayConsole();
            }
         }
      }
      
      public function setupClientWords() 
      {
         Logger.addSlashCommand("listAccountId",function()
         {
            var _loc1_:Int = mDBFacade.accountId;
            Logger.log("" + _loc1_);
         });
         Logger.addSlashCommand("helpCommands",function()
         {
            Logger.log("These are the magic words:");
            Logger.listSlashCommands();
         });
         Logger.addSlashCommand("test3",function(param1:String = "")
         {
            var _loc2_:Array<ASAny> = (cast new compat.RegExp("\\s+").split(param1));
            Logger.log("" + _loc2_);
         });
         Logger.addSlashCommand("showCollisions",function(param1:String = "")
         {
            Logger.log("showing Collisions");
            mDBFacade.showCollisions = true;
         });
         Logger.addSlashCommand("setClockOffset",function(param1:String = "")
         {
            var _loc5_= Math.NaN;
            var _loc3_= Math.NaN;
            var _loc4_= Math.NaN;
            var _loc2_:Array<ASAny> = (cast new compat.RegExp("\\s+").split(param1));
            if(!ASCompat.toBool(_loc2_[0]))
            {
               showHelp();
               Logger.log("/setClockOffset days [hours] [minutes]");
               Logger.log("\tsets the offset for the webserver time.");
            }
            else
            {
               _loc5_ = ASCompat.toNumber(_loc2_[0]);
               _loc3_ = 0;
               _loc4_ = 0;
               if(_loc2_.length >= 2)
               {
                  _loc3_ = ASCompat.toNumber(_loc2_[1]);
               }
               if(_loc2_.length >= 3)
               {
                  _loc4_ = ASCompat.toNumber(_loc2_[2]);
               }
               GameClock.setUserWebOffset(Std.int(_loc5_),Std.int(_loc3_),Std.int(_loc4_));
            }
         });
      }
      
      public function setupPhpServerWords() 
      {
         Logger.addSlashCommand("PhpTime",function()
         {
            PhpTime();
         });
         Logger.addSlashCommand("PhpTest",function()
         {
            PhpTest();
         });
         Logger.addSlashCommand("PhpUnlockAllMapNodes",function()
         {
            PhpUnlockAllMapNodes();
         });
         Logger.addSlashCommand("PhpLockAllMapNodes",function()
         {
            PhpLockAllMapNodes();
         });
         Logger.addSlashCommand("PhpUnlockMapNodes",function(param1:String = "")
         {
            var _loc3_= 0;
            var _loc4_= 0;
            var _loc2_:Array<ASAny> = (cast new compat.RegExp("\\s+").split(param1));
            if(!ASCompat.toBool(_loc2_[0]))
            {
               showHelp();
               Logger.log("/PhpUnlockMapNodes startNode [endNode]");
               Logger.log("\tunlocks map nodes from the start node to the end node");
            }
            else
            {
               _loc3_ = ASCompat.toInt(_loc2_[0]);
               _loc4_ = 0;
               if(_loc2_.length >= 2)
               {
                  _loc4_ = ASCompat.toInt(_loc2_[1]);
               }
               PhpUnlockMapNodes(_loc3_,_loc4_);
            }
         });
         Logger.addSlashCommand("PhpGiveGems",function(param1:String = "")
         {
            var _loc3_= 0;
            var _loc2_:Array<ASAny> = (cast new compat.RegExp("\\s+").split(param1));
            if(!ASCompat.toBool(_loc2_[0]))
            {
               showHelp();
               Logger.log("/PhpGiveGems numberGems");
               Logger.log("\tgives you gems.");
            }
            else
            {
               _loc3_ = ASCompat.toInt(_loc2_[0]);
               PhpGiveGems(_loc3_);
            }
         });
         Logger.addSlashCommand("PhpGiveCoins",function(param1:String = "")
         {
            var _loc3_= 0;
            var _loc2_:Array<ASAny> = (cast new compat.RegExp("\\s+").split(param1));
            if(!ASCompat.toBool(_loc2_[0]))
            {
               showHelp();
               Logger.log("/PhpGiveCoins numberCoins");
               Logger.log("\tgives you coins.");
            }
            else
            {
               _loc3_ = ASCompat.toInt(_loc2_[0]);
               PhpGiveCoins(_loc3_);
            }
         });
         Logger.addSlashCommand("PhpGiveXp",function(param1:String = "")
         {
            var _loc3_= 0;
            var _loc2_:Array<ASAny> = (cast new compat.RegExp("\\s+").split(param1));
            if(!ASCompat.toBool(_loc2_[0]))
            {
               showHelp();
               Logger.log("/PhpGiveXp xp");
               Logger.log("\tgives the current avatar xp");
            }
            else
            {
               _loc3_ = ASCompat.toInt(_loc2_[0]);
               PhpGiveXp(_loc3_);
            }
         });
      }
      
      public function AskForAccountDetailsRefresh() 
      {
         var useAccountBoosterFunc= JSONRPCService.getFunction("AskForAccountDetails",mDBFacade.rpcRoot + "webMagicWord");
         useAccountBoosterFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,mDBFacade.demographics,function(param1:ASAny)
         {
            Logger.log("Got new account details");
            mDBFacade.dbAccountInfo.parseResponse(param1);
         },function(param1:Error)
         {
            Logger.log("PhpTime: ERROR:" + Std.string(param1));
         });
      }
      
      public function PhpTime() 
      {
         var requestFunc= JSONRPCService.getFunction("getWebServerTimestamp",mDBFacade.rpcRoot + "webMagicWord");
         requestFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,mDBFacade.demographics,function(param1:Array<ASAny>)
         {
            Logger.log("PhpTime:" + param1);
         },function(param1:Error)
         {
            Logger.log("PhpTime: ERROR:" + Std.string(param1));
         });
      }
      
      public function PhpTest() 
      {
         var argsArray:Array<ASAny> = ["Test"];
         var requestFunc= JSONRPCService.getFunction("doMagicWord",mDBFacade.rpcRoot + "webMagicWord");
         requestFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,argsArray,mDBFacade.demographics,function(param1:Array<ASAny>)
         {
            Logger.log("PhpTest:" + param1);
         },function(param1:Error)
         {
            Logger.log("PhpTest: ERROR:" + Std.string(param1));
         });
      }
      
      public function PhpUnlockAllMapNodes() 
      {
         var argsArray:Array<ASAny> = ["UnlockAllMapNodes",mDBFacade.dbAccountInfo.activeAvatarId];
         var requestFunc= JSONRPCService.getFunction("doMagicWord",mDBFacade.rpcRoot + "webMagicWord");
         requestFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,argsArray,mDBFacade.demographics,function(param1:Array<ASAny>)
         {
            Logger.log("UnlockAllMapNodes:" + param1);
            AskForAccountDetailsRefresh();
         },function(param1:Error)
         {
            Logger.log("UnlockAllMapNodes: ERROR:" + Std.string(param1));
         });
      }
      
      public function PhpLockAllMapNodes() 
      {
         var argsArray:Array<ASAny> = ["LockAllMapNodes",mDBFacade.dbAccountInfo.activeAvatarId];
         var requestFunc= JSONRPCService.getFunction("doMagicWord",mDBFacade.rpcRoot + "webMagicWord");
         requestFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,argsArray,mDBFacade.demographics,function(param1:Array<ASAny>)
         {
            Logger.log("LockAllMapNodes:" + param1);
            AskForAccountDetailsRefresh();
         },function(param1:Error)
         {
            Logger.log("LockAllMapNodes: ERROR:" + Std.string(param1));
         });
      }
      
      public function PhpUnlockMapNodes(param1:Int, param2:Int = 0) 
      {
         var argsArray:Array<ASAny>;
         var requestFunc:ASFunction;
         var startNode= param1;
         var endNode= param2;
         if(endNode < startNode)
         {
            endNode = startNode;
         }
         argsArray = ["UnlockMapNodes",mDBFacade.dbAccountInfo.activeAvatarId,startNode,endNode];
         requestFunc = JSONRPCService.getFunction("doMagicWord",mDBFacade.rpcRoot + "webMagicWord");
         requestFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,argsArray,mDBFacade.demographics,function(param1:Array<ASAny>)
         {
            Logger.log("UnlockMapNodes:" + param1);
            AskForAccountDetailsRefresh();
         },function(param1:Error)
         {
            Logger.log("UnlockMapNodes: ERROR:" + Std.string(param1));
         });
      }
      
      public function PhpGiveGems(param1:Int) 
      {
         var numGems= param1;
         var argsArray:Array<ASAny> = ["GiveGems",numGems];
         var requestFunc= JSONRPCService.getFunction("doMagicWord",mDBFacade.rpcRoot + "webMagicWord");
         requestFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,argsArray,mDBFacade.demographics,function(param1:Array<ASAny>)
         {
            Logger.log("GiveGems:" + param1);
            AskForAccountDetailsRefresh();
         },function(param1:Error)
         {
            Logger.log("GiveGems: ERROR:" + Std.string(param1));
         });
      }
      
      public function PhpGiveCoins(param1:Int) 
      {
         var numCoins= param1;
         var argsArray:Array<ASAny> = ["GiveCoins",numCoins];
         var requestFunc= JSONRPCService.getFunction("doMagicWord",mDBFacade.rpcRoot + "webMagicWord");
         requestFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,argsArray,mDBFacade.demographics,function(param1:Array<ASAny>)
         {
            Logger.log("GiveCoins:" + param1);
            AskForAccountDetailsRefresh();
         },function(param1:Error)
         {
            Logger.log("GiveCoins: ERROR:" + Std.string(param1));
         });
      }
      
      public function PhpGiveXp(param1:Int) 
      {
         var xpAmount= param1;
         var argsArray:Array<ASAny> = ["GiveXp",mDBFacade.dbAccountInfo.activeAvatarId,xpAmount];
         var requestFunc= JSONRPCService.getFunction("doMagicWord",mDBFacade.rpcRoot + "webMagicWord");
         requestFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,argsArray,mDBFacade.demographics,function(param1:Array<ASAny>)
         {
            Logger.log("GiveXp:" + param1);
            AskForAccountDetailsRefresh();
         },function(param1:Error)
         {
            Logger.log("GiveXp: ERROR:" + Std.string(param1));
         });
      }
      
      public function showHelp() 
      {
         Logger.log("Please use the command following this format:");
         Logger.log("/command parameter [optional parameter]");
      }
   }


