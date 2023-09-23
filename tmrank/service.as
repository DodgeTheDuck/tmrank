namespace TMRank {
    namespace Service {

        void LoadMapPacks() {
            TMRank::Api::GetMapPacks();
        }

        void LoadUserData() {
            TMRank::Api::GetUserMapStats(Internal::NadeoServices::GetAccountID());
        }

        void LoadMapData(int64 mapPackTypeID) {
            TMRank::Model::MapPackType@ mapPackType = TMRank::Repository::GetMapPackTypeFromId(mapPackTypeID);
            TMRank::Api::GetMaps(mapPackTypeID);
            TMRank::Api::GetRankings(mapPackTypeID);
        }

    }
}