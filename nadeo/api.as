namespace Nadeo {
    namespace Api {

        class MapRecordsRequest {
            string accoudIdList;
            string mapIdList;
        }

        const string API_GET_MAP_INFO = "/api/token/map/{uid}";
        
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

        string GetMapDownloadUrl(const string &in mapUid) {
            string url = baseUrlLive + API_GET_MAP_INFO.Replace("{uid}", mapUid);
            Net::HttpRequest@ req = @NadeoServices::Get("NadeoLiveServices", url);
            req.Start();
            while(!req.Finished()) yield();
            auto res = Json::Parse(req.String());
            return res["downloadUrl"];
        }

    }
}