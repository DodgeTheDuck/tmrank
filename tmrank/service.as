namespace TMRank {
    namespace Service {

        const int LEADERBOARD_MAX = 100;

        void LoadAllMapPacks() {
            auto mapPacks = TMRank::Api::GetMapPacks();
            string userId = Internal::NadeoServices::GetAccountID();
            auto userPackStats = TMRank::Api::GetUserPackStats(userId);

            for(int i = 0; i < userPackStats.Length; i++) {
                auto userPackStat = userPackStats[i];
                for(int j = 0; j < mapPacks.Length; j++) {
                    auto mapPack = mapPacks[j];
                    if(userPackStat.TypeID == mapPack.TypeID) {
                        mapPack.SetUserPackStats(userPackStat);
                    }
                }
            }

            for(int i = 0; i < mapPacks.Length; i++) {
                TMRank::Model::MapPack@ mapPack = mapPacks[i];
                mapPack.SetMaps(TMRank::Api::GetMapsForPack(mapPack));
                mapPack.UpdateUserStats(TMRank::Api::GetUserMapStats(mapPack, userId));
                mapPack.SetDrivers(TMRank::Api::GetRankings(mapPack, 100, 0));                
                TMRank::Cache::CacheMapPack(mapPack);
            }

        }

    }
}