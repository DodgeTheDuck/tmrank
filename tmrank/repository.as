namespace TMRank {
    namespace Repository {

        TMRank::Model::MapPackType@[] _mapPackTypes;
        TMRank::Model::Map@[] _maps = {};

        dictionary _mapPackUserRank = dictionary();
        dictionary _mapPackLeaders = dictionary();
        dictionary _mapPackMaps = dictionary();
        dictionary _mapUserStats = dictionary();

        void AddMapPackType(TMRank::Model::MapPackType@ mapPackType) {
            _mapPackTypes.InsertLast(@mapPackType);
            _mapPackMaps[mapPackType.typeName] = array<TMRank::Model::Map@>();
            _mapPackLeaders[mapPackType.typeName] = array<TMRank::Model::Driver@>();
        }

        TMRank::Model::MapPackType@[] GetMapPackTypes() {
            return _mapPackTypes;
        }

        TMRank::Model::MapPackType@ GetMapPackTypeFromId(int packTypeId) {
            for(int i = 0; i < _mapPackTypes.Length; i++) {
                if(_mapPackTypes[i].typeID == packTypeId) {
                    return _mapPackTypes[i];
                }
            }
            return null;
        }

        TMRank::Model::MapPackType@ GetMapPackTypeFromType(const string &in typeName) {
            for(int i = 0; i < _mapPackTypes.Length; i++) {
                if(_mapPackTypes[i].typeName == typeName) {
                    return _mapPackTypes[i];
                }
            }
            return null;
        }

        void AddMap(string typeName, TMRank::Model::Map@ map) {
            _maps.InsertLast(@map);
            cast<TMRank::Model::Map@[]>(_mapPackMaps[typeName]).InsertLast(@map);
        }

        TMRank::Model::Map@[] GetMaps() {
            return _maps;
        }

        TMRank::Model::Map@[] GetMapsFromType(const string &in type, int offset, int count) {
            TMRank::Model::Map@[] result = {};
            auto maps = cast<TMRank::Model::Map@[]>(_mapPackMaps[type]);
            for(int i = offset; i < Math::Min(offset+count, maps.Length); i++) {
                result.InsertLast(maps[i]);
            }
            return result;
        }

        int GetMapCountFromType(const string &in type) {
            auto maps = cast<TMRank::Model::Map@[]>(_mapPackMaps[type]);
            return maps.Length;
        }

        TMRank::Model::Map@ GetMap(int index) {
            return _maps[index];
        }

        void AddLeaderboardUser(const string &in mapPackType, TMRank::Model::Driver@ driver) {
            auto drivers = cast<TMRank::Model::Driver@[]>(_mapPackLeaders[mapPackType]);
            for(int i = 0; i < drivers.Length; i++) {
                auto existingDriver = drivers[i];
                if(existingDriver.rank > driver.rank) {
                    drivers.InsertAt(i, driver);
                    return;
                }
            }
            drivers.InsertLast(driver);
        }

        TMRank::Model::Driver@[] GetLeaderboardUsers(const string &in mapPackType, int offset = 0, int count = -1) {            
            TMRank::Model::Driver@[] result = {};
            auto drivers = cast<TMRank::Model::Driver@[]>(_mapPackLeaders[mapPackType]);
            if(count == -1) {
                count = drivers.Length;
            }
            for(int i = offset; i < Math::Min(offset+count, drivers.Length); i++) {
                result.InsertLast(drivers[i]);
            }
            return result;
        }

        TMRank::Model::Driver@ GetLeaderboardUser(const string &in mapPackType, const string &in uid) {
            auto drivers = cast<TMRank::Model::Driver@[]>(_mapPackLeaders[mapPackType]);
            for(int i = 0; i < drivers.Length; i++) {
                if(drivers[i].uid == uid) {
                    return drivers[i];
                }
            }
            return null;
        }

        void AddMapUserStats(const string&in mapUid, TMRank::Model::UserMapStats@ userMapStats) {
            _mapUserStats[mapUid] = @userMapStats;
        }

        TMRank::Model::UserMapStats@ GetMapUserStats(const string &in mapUid) {
            return cast<TMRank::Model::UserMapStats@>(_mapUserStats[mapUid]);
        }

    }
}