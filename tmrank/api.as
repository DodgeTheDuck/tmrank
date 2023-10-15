
namespace TMRank {
    namespace Api {

        const string BASE_URL = "https://tmrank.jingga.app/api.php?";
        const string EP_MAP_PACK_TYPES = BASE_URL + "endpoint=types";
        const string EP_MAP_LIST = BASE_URL + "endpoint=maplist&type={type_id}";
        const string EP_RANKINGS = BASE_URL + "endpoint=ranking&type={type_id}&offset={offset}&limit={limit}&order={order_keyword}";
        const string EP_USER_MAP_MAP_STATS = BASE_URL + "endpoint=userstats&type={type_id}&uid={nadeo_user_id}";
        const string EP_USER_PACK_STATS = BASE_URL + "endpoint=user&uid={nadeo_user_id}";

        TMRank::Model::MapPack@[] GetMapPacks() {
            Json::Value res = Http::GetAsync(EP_MAP_PACK_TYPES);

            TMRank::Model::MapPack@[] result = {};
            for(int i = 0; i < res.GetKeys().Length; i++) {
                result.InsertLast(@TMRank::Model::MapPack(res[res.GetKeys()[i]]));
            }
            return result;
        }

        TMRank::Model::Map@[] GetMapsForPack(TMRank::Model::MapPack@ mapPack) {
            Json::Value res = Http::GetAsync(EP_MAP_LIST.Replace("{type_id}", "" + mapPack.TypeID));
            TMRank::Model::Map@[] result = {};
            for(int i = 0; i < res.GetKeys().Length; i++) {
                result.InsertLast(TMRank::Model::Map(res[res.GetKeys()[i]]));
            }
            return result;
        }

        TMRank::Model::Driver@[] GetRankings(const TMRank::Model::MapPack@ mapPack, int count, int offset) {
            string url = EP_RANKINGS;
            url = url.Replace("{type_id}", mapPack.TypeID + "");
            url = url.Replace("{offset}", offset + "");
            url = url.Replace("{limit}", count + "");
            url = url.Replace("{order_keyword}", "default");
            Json::Value res = Http::GetAsync(url);

            TMRank::Model::Driver@[] result = array<TMRank::Model::Driver@>(res.GetKeys().Length);
            for(int i = 0; i < res.GetKeys().Length; i++) {
                auto driver = TMRank::Model::Driver(res[res.GetKeys()[i]]);
                @result[driver.rank-1] = driver;
            }
            return result;
        }

        TMRank::Model::UserMapStats@[] GetUserMapStats(const TMRank::Model::MapPack@ mapPack, const string &in userId) {
            string url = EP_USER_MAP_MAP_STATS;
            url = url.Replace("{type_id}", mapPack.TypeID + "");
            url = url.Replace("{nadeo_user_id}", userId);
            Json::Value res = Http::GetAsync(url);
            TMRank::Model::UserMapStats@[] result = {};
            for(int i = 0; i < res.Length; i++) {
                result.InsertLast(TMRank::Model::UserMapStats(res[res.GetKeys()[i]], res.GetKeys()[i]));
            }
            return result;
        }

        TMRank::Model::UserPackStats@[] GetUserPackStats(const string &in userId) {
            string url = EP_USER_PACK_STATS;
            url = url.Replace("{nadeo_user_id}", userId);
            Json::Value res = Http::GetAsync(url);
            print(url);
            Json::Value types = res["types"];
            TMRank::Model::UserPackStats@[] result = {};
            for(int i = 0; i < types.GetKeys().Length; i++) {
                result.InsertLast(TMRank::Model::UserPackStats(types[types.GetKeys()[i]], res["driver_name"]));
            }
            return result;
        }

    }
}