
namespace Nadeo {

    namespace Service {

        // Nadeo multiple map info end point is currenly capped at 100 maps
        const uint MAX_MAP_FETCH = 100;

        // Authenticate plugin with nadeo web services
        void Authenticate() {
            Async::Await(Nadeo::Api::Authenticate);
        }

        // Use Nadeo API to get map information for each TMRank map of {style}
        void FetchMapInfoForStyle(const string&in style) {

            // //Sanity check: Have we actually fetched maps from TMRank?
            // if(TMRank::Repository::GetMaps().Length == 0) {
            //     Logger::Error("No maps download from TMRank");
            // }

            // TMRank::MapData@[] mapData = TMRank::Service::GetMapsFromStyle(style);

            // while(true) {

            //     if(mapData.Length <= 0) break;

            //     Logger::DevMessage("Fetching nadeo MapInfo for " + mapData.Length + " " + style + " maps...");
            //     Async::Await(Nadeo::Api::GetMapInfoMultiple, _ConcatMapUids(mapData, MAX_MAP_FETCH));

            //     Nadeo::Api::MapRecordsRequest@ req = @Nadeo::Api::MapRecordsRequest();
            //     req.mapIdList = _ConcatMapIds(mapData, MAX_MAP_FETCH);
            //     req.accoudIdList = Internal::NadeoServices::GetAccountID();
            //     Async::Await(Nadeo::Api::GetMapRecords, req);

            //     mapData.RemoveRange(0, 100);

            //     sleep(50);

            // }

        }

        string _ConcatMapUids(TMRank::MapData@[] mapData, uint max) {
            string result = "";
            for(int i = 0; i < Math::Min(mapData.Length, max); i++) {
                result += mapData[i].uid + ",";
            }
            return result.SubStr(0, result.Length-1);
        }

        string _ConcatMapIds(TMRank::MapData@[] mapData, uint max) {
            string result = "";
            for(int i = 0; i < Math::Min(mapData.Length, MAX_MAP_FETCH); i++) {
                result += Nadeo::Repository::GetMapFromUid(mapData[i].uid).mapId + ",";
            }
            return result.SubStr(0, result.Length-1);
        }

    }

}