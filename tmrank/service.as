namespace TMRank {
    namespace Service {

        const int LEADERBOARD_MAX = 100;

        void Reload() {
            Async::Await(TMRank::Service::LoadMapPacks);
            Async::Await(TMRank::Service::LoadUserData);
        }

        void LoadMapPacks() {
            TMRank::Api::GetMapPacks();
        }

        void LoadUserData() {
            TMRank::Api::GetUserMapStats(Internal::NadeoServices::GetAccountID());
        }

        void LoadMapData(int64 mapPackTypeID) {
            TMRank::Model::MapPackType@ mapPackType = TMRank::Repository::GetMapPackTypeFromId(mapPackTypeID);
            TMRank::Api::GetMaps(mapPackTypeID);
            TMRank::Api::GetRankings(mapPackTypeID, LEADERBOARD_MAX, 0);
        }

    }
}