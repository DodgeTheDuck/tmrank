
namespace TMRank {
    namespace Model {

        class UserPackStats {

            int TypeID;
            string TypeName;
            int Score;
            int Finishes;
            int Authors;
            int Golds;
            int Silvers;
            int Bronzes;
            int64 FinishTime;
            int Rank;
            string Username;

            UserPackStats(const Json::Value &in json, const string &in username) {
                try {
                    TypeID = json["type_id"];
                    TypeName = json["type_name"];
                    Score = json["score"];
                    Finishes = json["fins"];
                    Authors = json["ats"];
                    Golds = json["golds"];
                    Silvers = json["silvers"];
                    Bronzes = json["bronzes"];
                    FinishTime = json["ftime"];
                    Rank = json["rank"];
                    Username = username;
                } catch {
                    throw("Unable to parse UserPackStats json");
                }
            }

        }

    }
}