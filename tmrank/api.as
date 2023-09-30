
namespace TMRank {
    namespace Api {

        const string BASE_URL = "https://tmrank.jingga.app/api.php?";
        const string EP_MAP_PACK_TYPES = BASE_URL + "endpoint=types";
        const string EP_MAP_LIST = BASE_URL + "endpoint=maplist&type={type_id}";
        const string EP_RANKINGS = BASE_URL + "endpoint=ranking&type={type_id}&offset={offset}&limit={limit}&order={order_keyword}";
        const string EP_USER_STATS = BASE_URL + "endpoint=userstats&type={type_id}&uid={nadeo_user_id}";

        void GetMapPacks() {
            Json::Value res = Http::GetAsync(EP_MAP_PACK_TYPES);
            for(int i = 0; i < res.GetKeys().Length; i++) {
                TMRank::Repository::AddMapPackType(TMRank::Model::MapPackType(res[res.GetKeys()[i]]));
            }
        }

        void GetMaps(int64 packTypeId) {
            TMRank::Model::MapPackType@ mapPackType = TMRank::Repository::GetMapPackTypeFromId(packTypeId);
            Logger::DevMessage("Fetching TMRank maps for type " + mapPackType.typeName);
            Json::Value res = Http::GetAsync(EP_MAP_LIST.Replace("{type_id}", "" + mapPackType.typeID));
            for(int i = 0; i < res.GetKeys().Length; i++) {
                TMRank::Repository::AddMap(mapPackType.typeName, TMRank::Model::Map(res[res.GetKeys()[i]]));
            }
        }

        void GetRankings(int64 packTypeId, int count, int offset) {
            TMRank::Model::MapPackType@ mapPackType = TMRank::Repository::GetMapPackTypeFromId(packTypeId);
            string url = EP_RANKINGS;
            url = url.Replace("{type_id}", packTypeId + "");
            url = url.Replace("{offset}", offset + "");
            url = url.Replace("{limit}", count + "");
            url = url.Replace("{order_keyword}", "default");
            Json::Value res = Http::GetAsync(url);

            for(int i = 0; i < res.GetKeys().Length; i++) {
                TMRank::Repository::AddLeaderboardUser(mapPackType.typeName, TMRank::Model::Driver(res[res.GetKeys()[i]]));
            }
        }

        void GetUserMapStats(const string&in userId) {
            TMRank::Model::MapPackType@[] mapPackTypes = TMRank::Repository::GetMapPackTypes();
            for(int i = 0; i < mapPackTypes.Length; i++) {
                string url = EP_USER_STATS;
                url = url.Replace("{type_id}", mapPackTypes[i].typeID + "");
                url = url.Replace("{nadeo_user_id}", userId);
                Json::Value res = Http::GetAsync(url);
                for(int j = 0; j < res.Length; j++) {
                     TMRank::Repository::AddMapUserStats(res.GetKeys()[j], TMRank::Model::UserMapStats(res[res.GetKeys()[j]]));
                }
            }
        }

    }
}