package generatedCode;

import facade.DBFacade;
import networkCode.DcNetworkPacket;
import networkCode.DcSocket;
import networkCode.DcSocketGenerate;

class GeneratedDcSocket extends DcSocket implements DcSocketGenerate {
	public static inline final CLID_Trash = (0 : UInt);

	public static inline final CLID_DistributedDistrict = (19 : UInt);

	public static inline final CLID_ObjectServer = (23 : UInt);

	public static inline final CLID_StatAccumulator = (25 : UInt);

	public static inline final CLID_AreaManager = (26 : UInt);

	public static inline final CLID_DistributedNPCGameObject = (27 : UInt);

	public static inline final CLID_HeroGameObject = (28 : UInt);

	public static inline final CLID_PlayerGameObject = (29 : UInt);

	public static inline final CLID_PresenceManager = (30 : UInt);

	public static inline final CLID_DistributedDungeonFloor = (32 : UInt);

	public static inline final CLID_DistributedTownFloor = (33 : UInt);

	public static inline final CLID_DistributedDungionArea = (36 : UInt);

	public static inline final CLID_DistributedDungeonSummary = (38 : UInt);

	public static inline final CLID_DistributedTownArea = (39 : UInt);

	public static inline final CLID_DistributedDooberGameObject = (40 : UInt);

	public static inline final CLID_DistributedBuffGameObject = (41 : UInt);

	public static inline final CLID_MatchMaker = (42 : UInt);

	public static inline final DcHash = (1351928210 : UInt);

	public function new(facade:DBFacade, host:String, port:Int, playtoken:String, demographics:String, account:UInt) {
		super(facade, host, port, playtoken, demographics, account);
	}

	override public function getDcHash():UInt {
		return (1351928210 : UInt);
	}

	public function ObjectFactoryOwner(classid:UInt, do_id:UInt, game_packet:DcNetworkPacket) {
		switch (classid - 28) {
			case 0:
				Doid_NetInterfaces[Std.string(do_id)] = HeroGameObjectOwnerNetworkComponent.ownerFactory(game_packet, this, do_id);

			case 1:
				Doid_NetInterfaces[Std.string(do_id)] = PlayerGameObjectOwnerNetworkComponent.ownerFactory(game_packet, this, do_id);

			default:
				trace("Received generate for object of unknown Class ID " + classid);
		}
	}

	public function ObjectFactoryVisible(classid:UInt, do_id:UInt, game_packet:DcNetworkPacket) {
		switch (classid - 27) {
			case 0:
				Doid_NetInterfaces[Std.string(do_id)] = DistributedNPCGameObjectNetworkComponent.netFactory(game_packet, this, do_id);

			case 1:
				Doid_NetInterfaces[Std.string(do_id)] = HeroGameObjectNetworkComponent.netFactory(game_packet, this, do_id);

			case 2:
				Doid_NetInterfaces[Std.string(do_id)] = PlayerGameObjectNetworkComponent.netFactory(game_packet, this, do_id);

			case 3:
				Doid_NetInterfaces[Std.string(do_id)] = PresenceManagerNetworkComponent.netFactory(game_packet, this, do_id);

			case 5:
				Doid_NetInterfaces[Std.string(do_id)] = DistributedDungeonFloorNetworkComponent.netFactory(game_packet, this, do_id);

			case 6:
				Doid_NetInterfaces[Std.string(do_id)] = DistributedTownFloorNetworkComponent.netFactory(game_packet, this, do_id);

			case 9:
				Doid_NetInterfaces[Std.string(do_id)] = DistributedDungionAreaNetworkComponent.netFactory(game_packet, this, do_id);

			case 11:
				Doid_NetInterfaces[Std.string(do_id)] = DistributedDungeonSummaryNetworkComponent.netFactory(game_packet, this, do_id);

			case 12:
				Doid_NetInterfaces[Std.string(do_id)] = DistributedTownAreaNetworkComponent.netFactory(game_packet, this, do_id);

			case 13:
				Doid_NetInterfaces[Std.string(do_id)] = DistributedDooberGameObjectNetworkComponent.netFactory(game_packet, this, do_id);

			case 14:
				Doid_NetInterfaces[Std.string(do_id)] = DistributedBuffGameObjectNetworkComponent.netFactory(game_packet, this, do_id);

			case 15:
				Doid_NetInterfaces[Std.string(do_id)] = MatchMakerNetworkComponent.netFactory(game_packet, this, do_id);

			default:
				trace("Received generate for object of unknown Class ID " + classid);
		}
	}
}
