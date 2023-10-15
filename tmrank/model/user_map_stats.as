
namespace TMRank {
    namespace Model {
        class UserMapStats {

            string MapUid;
            int Score;
            int PB;

            UserMapStats(const Json::Value &in json, const string &in mapUid) {
                try {
                    Score = json["score"];
                    PB = json["finish_finish_time"];
                    MapUid = mapUid;
                } catch {
                    throw("Unable to parse UserMapStats json");
                }
            }

        }
    }
}