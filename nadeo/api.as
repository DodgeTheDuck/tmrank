
namespace Nadeo {
    namespace Api {

        class MapRecordsRequest {
            string accoudIdList;
            string mapIdList;
        }

        const string API_GET_MAP_INFO = "/api/token/map/{uid}";
        const string API_GET_MAP_LEADERBOARD = "/api/token/leaderboard/group/{groupUid}/map/{uid}/top?length={length}&onlyWorld=true&offset=0";
        const string API_GET_MAP_INFO_MULTIPLE = "/api/token/map/get-multiple?mapUidList={uids}";
        const string API_GET_MAP_RECORDS = "/mapRecords/?accountIdList={accountIdList}&mapIdList={mapIdList}";
        
        string baseUrlLive = "";
        string baseUrlCore = "";

        void Authenticate()
        {
            NadeoServices::AddAudience("NadeoServices");
            NadeoServices::AddAudience("NadeoLiveServices");
            while (!NadeoServices::IsAuthenticated("NadeoServices")) {
                yield();
            }
            while (!NadeoServices::IsAuthenticated("NadeoLiveServices")) {
                yield();
            }
            baseUrlLive = NadeoServices::BaseURL();
            baseUrlCore = "https://prod.trackmania.core.nadeo.online";
        }

        void GetMapRecords(ref@ mapRecordsRequest) {

            auto reqData = cast<Nadeo::Api::MapRecordsRequest@>(mapRecordsRequest);

            string url = baseUrlCore + API_GET_MAP_RECORDS;
            url = url.Replace("{accountIdList}", reqData.accoudIdList);
            url = url.Replace("{mapIdList}", reqData.mapIdList);

            Net::HttpRequest@ req = @NadeoServices::Get("NadeoServices", url);
            req.Start();

            while(!req.Finished()) yield();
            if(req.ResponseCode() != 200) {
                Logger::Error("GetMapRecords status " + req.ResponseCode());
                Logger::DevMessage("Response: " + req.String());
            } else {
                auto res = Json::Parse(req.String());
                for (uint i = 0; i < res.Length; i++) {
                    Nadeo::MapInfo@ mapInfo = Nadeo::Repository::GetMapFromId(res[i]["mapId"]);
                    mapInfo.personalRecord = res[i]["recordScore"]["time"];
                }
            }

        }

        void GetMapInfo(const string&in mapUid) {

            string url = baseUrlLive + API_GET_MAP_INFO.Replace("{uid}", mapUid);

            Net::HttpRequest@ req = @NadeoServices::Get("NadeoLiveServices", url);
            req.Start();

            while(!req.Finished()) yield();
            if(req.ResponseCode() != 200) {
                Logger::Error("GetMapInfo status " + req.ResponseCode());
                Logger::DevMessage("Response: " + req.String());
            } else {
                Nadeo::Repository::AddMap(mapUid, @Nadeo::MapInfo(Json::Parse(req.String())));
            }
            
        }

        void GetMapInfoMultiple(const string&in mapUids) {
            string url = baseUrlLive + API_GET_MAP_INFO_MULTIPLE.Replace("{uids}", mapUids);
            Net::HttpRequest@ req = @NadeoServices::Get("NadeoLiveServices", url);
            req.Start();

            while(!req.Finished()) yield();
            if(req.ResponseCode() != 200) {
                Logger::Error("GetMapInfo status " + req.ResponseCode());
                Logger::DevMessage("Response: " + req.String());
            } else {
                auto res = Json::Parse(req.String());
                for (uint i = 0; i < res["mapList"].Length; i++) {
                    Nadeo::Repository::AddMap(res["mapList"][i]["uid"], @Nadeo::MapInfo(res["mapList"][i]));
                }
            }
        }
    }
}