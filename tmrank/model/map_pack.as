
namespace TMRank {
    namespace Model {

        class MapPack {

            // public properties
            int TypeID;
            string TypeName;

            // private properties
            private TMRank::Model::Map@[] _maps;
            private TMRank::Model::Driver@[] _drivers;
            private TMRank::Model::UserPackStats@ _userPackStats;

            MapPack(Json::Value &in json) {
                try {
                    TypeID = json["type_id"];
                    TypeName = json["type_name"];
                    _maps = {};
                    _drivers = {};
                } catch {
                    throw("Unable to parse MapPack json");
                }
            }

            void SetMaps(TMRank::Model::Map@[] maps) {
                _maps = maps;
            }

            TMRank::Model::Map@[] GetMaps() {
                return _maps;
            }

            void AddMap(TMRank::Model::Map@ map) {
                _maps.InsertLast(map);
            }

            TMRank::Model::Map@ GetMap(uint index) {
                return _maps[index];
            }

            void UpdateUserStats(TMRank::Model::UserMapStats@[] userStats) {
                for(int i = 0; i < userStats.Length; i++) {
                    TMRank::Model::UserMapStats@ userStat = userStats[i];
                    for(int j = 0; j < _maps.Length; j++) {
                        auto map = _maps[j];
                        if(map.UID == userStat.MapUid) {
                            @map.UserStats = userStat;
                            break;
                        }
                    }
                }
            }

            void SetDrivers(TMRank::Model::Driver@[] drivers) {
                _drivers = drivers;
            }

            TMRank::Model::Driver@[] GetDrivers() {
                return _drivers;
            }

            void SetUserPackStats(TMRank::Model::UserPackStats@ userPackStats) {
                @_userPackStats = userPackStats;
            }

            TMRank::Model::UserPackStats@ GetUserPackStats() {
                return _userPackStats;
            }

        }
    }
}