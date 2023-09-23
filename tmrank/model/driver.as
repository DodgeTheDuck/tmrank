
namespace TMRank {
    namespace Model {
        class Driver {
            string uid;
            string name;
            int score;
            int finishes;
            int authors;
            int golds;
            int silvers;
            int bronzes;
            int rank;

            Driver(const Json::Value &in json) {
                try {
                    uid = json["driver_uid"];
                    name = json["driver_name"];
                    score = json["score"];
                    finishes = json["fins"];
                    authors = json["ats"];
                    golds = json["golds"];
                    silvers = json["silvers"];
                    bronzes = json["bronzes"];
                    rank = json["rank"];
                } catch {
                    throw("Unable to parse Driver json");
                }
            }

        }
    }
}