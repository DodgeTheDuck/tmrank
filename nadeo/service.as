
namespace Nadeo {

    namespace Service {

        const uint MAX_MAP_FETCH = 99;

        void Load(const string&in style) {

            array<TMRank::MapData@> mapData = TMRank::Service::GetMapsFromStyle(style);

            Logger::DevMessage("Fetching nadeo MapInfo for " + mapData.Length + " maps...");

            string uidCsv = "";
            for(int i = 0; i < Math::Min(mapData.Length, MAX_MAP_FETCH); i++) {
                uidCsv += mapData[i].uid + ",";
            }
            uidCsv = uidCsv.SubStr(0, uidCsv.Length-1);

            //fetch all mapinfos
            Async::Await(Nadeo::Api::GetMapInfoMultiple, uidCsv);

            //create mapid csv for personal records
            string idCsv = "";
            for(int i = 0; i < Math::Min(mapData.Length, MAX_MAP_FETCH); i++) {
                idCsv += Nadeo::Repository::GetMapFromUid(mapData[i].uid).mapId + ",";
            }
            idCsv = idCsv.SubStr(0, idCsv.Length-1);

            //fetch all records
            Nadeo::Api::MapRecordsRequest@ req = @Nadeo::Api::MapRecordsRequest();
            req.mapIdList = idCsv;
            req.accoudIdList = Internal::NadeoServices::GetAccountID();
            Async::Await(Nadeo::Api::GetMapRecords, req);

        }

    }

}