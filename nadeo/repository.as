
namespace Nadeo {

    namespace Repository {

        dictionary maps = dictionary();

        Nadeo::MapInfo@ GetMapFromUid(string mapUid) {
            if(!maps.Exists(mapUid)) {
                return null;
            }
            return cast<Nadeo::MapInfo@>(maps[mapUid]);
        }

        Nadeo::MapInfo@ GetMapFromId(string mapId) {
            for(uint i = 0; i < maps.GetKeys().Length; i++) {
                auto mapInfo = cast<Nadeo::MapInfo@>(maps[maps.GetKeys()[i]]);
                if(mapInfo.mapId == mapId) {
                    return @mapInfo;
                }
            }
            return null;
        }

        void AddMap(string uid, Nadeo::MapInfo@ mapInfo) {
            maps[uid] = @mapInfo;
        }

    }

}